/*
    SyphonServer.m
    Syphon

    Copyright 2010-2011 bangnoise (Tom Butterworth) & vade (Anton Marini).
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY
    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SyphonServer.h"
#import "SyphonIOSurfaceImage.h"
#import "SyphonPrivate.h"
#import "SyphonServerConnectionManager.h"
#import "SyphonServerDrawingHelper.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#import <libkern/OSAtomic.h>

@interface SyphonServer(Private)
+ (void)addServerToRetireList:(NSString *)serverUUID;
+ (void)removeServerFromRetireList:(NSString *)serverUUID;
+ (void)retireRemainingServers;
@end

@implementation SyphonServer
{
    int32_t _mdLock;
    NSString *_name;
    NSString *_uuid;
    
    SyphonServerConnectionManager *_connectionManager;
    SyphonServerDrawingHelper *_drawingHelper;
    
    void *_surfaceRef;
    SyphonImage *_surfaceTexture;
    GLuint _surfaceFBO;
    BOOL _pushPending;
    
    id<NSObject> _activityToken;
}

#pragma mark
#pragma mark Initializers and finalizers

- (id)initWithName:(NSString*)serverName
{
	if (self = [super init])
	{
        _mdLock = OS_SPINLOCK_INIT;
        _name = [(serverName ? serverName : @"") copy];
        _uuid = SyphonCreateUUIDString();
		
        _drawingHelper = [[SyphonServerDrawingHelper alloc] init];
		
		_connectionManager = [[SyphonServerConnectionManager alloc] initWithUUID:_uuid];
		[_connectionManager addObserver:self forKeyPath:@"hasClients" options:NSKeyValueObservingOptionPrior context:nil];
        
		if (![_connectionManager start]) {
			[self release];
			return nil;
		}
        
        [[self class] addServerToRetireList:_uuid];
        [self startBroadcasts];

        // Prevent this app from being suspended or terminated eg if it goes off-screen (MacOS 10.9+ only)
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        if ([processInfo respondsToSelector:@selector(beginActivityWithOptions:reason:)]) {
            NSActivityOptions options = NSActivityAutomaticTerminationDisabled | NSActivityBackground;
            _activityToken = [[processInfo beginActivityWithOptions:options reason:_uuid] retain];
        }
	}
	return self;
}

- (void)shutDownServer
{
	if (_connectionManager) {
		[_connectionManager removeObserver:self forKeyPath:@"hasClients"];
		[_connectionManager stop];
		[_connectionManager release];
		_connectionManager = nil;
	}
	
	[self destroyIOSurface];
	
    [self stopBroadcasts];
    [[self class] removeServerFromRetireList:_uuid];

    if (_activityToken) {
        [[NSProcessInfo processInfo] endActivity:_activityToken];
        [_activityToken release];
        _activityToken = nil;
    }
}

- (void)finalize
{
	[self shutDownServer];
	[super finalize];
}

- (void)dealloc
{
    SYPHONLOG(@"Server deallocing, name: %@, UUID: %@", self.name, _uuid);
	[self shutDownServer];
	[_name release];
	[_uuid release];
	[super dealloc];
}

#pragma mark KVO implementation

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey
{
    if ([theKey isEqualToString:@"hasClients"])
        return NO;
    else
        return [super automaticallyNotifiesObserversForKey:theKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"hasClients"])
    {
        if ([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue] == YES)
            [self willChangeValueForKey:keyPath];
        else
            [self didChangeValueForKey:keyPath];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Public Properties

- (NSString*)name
{
    OSSpinLockLock(&_mdLock);
    NSString *result = [_name retain];
    OSSpinLockUnlock(&_mdLock);
    return [result autorelease];
}

- (void)setName:(NSString *)newName
{
    [newName retain];
    OSSpinLockLock(&_mdLock);
    [_name release];
    _name = newName;
    OSSpinLockUnlock(&_mdLock);
    [_connectionManager setName:newName];
    [self broadcastServerUpdate];
}

- (BOOL)hasClients
{
	return _connectionManager.hasClients;
}

#pragma mark Public Methods

- (void)publishFrameTexture:(GLuint)texID size:(NSSize)size
{
    if (texID != 0 && [self bindToDrawFrameOfSize:size])
    {
        if (self.linearToSRGB) glEnable(GL_FRAMEBUFFER_SRGB);
        [_drawingHelper drawFrameTexture:texID surfaceSize:_surfaceTexture.textureSize discardAlpha:self.discardsAlpha];
        [self unbindAndPublish];
    }
}

- (void)stop
{
    [self shutDownServer];
}

#pragma mark
#pragma mark Private Properties

- (NSDictionary *)serverDescription
{
    NSDictionary *surface = _connectionManager.surfaceDescription;
    if (!surface) surface = [NSDictionary dictionary];
    NSArray *surfaceKey = [NSArray arrayWithObject:surface];
    
    NSString *appName = [[NSRunningApplication currentApplication] localizedName];
    if (!appName) appName = [[NSProcessInfo processInfo] processName];
    if (!appName) appName = [NSString string];
    
    NSNumber *version = [NSNumber numberWithUnsignedInt:kSyphonDictionaryVersion];
    
    return @{SyphonServerDescriptionDictionaryVersionKey: version,
             SyphonServerDescriptionNameKey: self.name,
             SyphonServerDescriptionUUIDKey: _uuid,
             SyphonServerDescriptionAppNameKey: appName,
             SyphonServerDescriptionSurfacesKey: surfaceKey};
}

#pragma mark FBO & IOSurface handling

- (BOOL)bindToDrawFrameOfSize:(NSSize)size
{
    // If the dimensions of the image have changed, rebuild the IOSurface/FBO/Texture combo.
    if (!NSEqualSizes(_surfaceTexture.textureSize, size))
    {
        [self destroyIOSurface];
        [self setupIOSurfaceForSize:size];
        _pushPending = YES;
    }
    
    if (_surfaceTexture == nil) return NO;
    
    glBindFramebuffer(GL_FRAMEBUFFER, _surfaceFBO);
    
    return YES;
}

- (void)unbindAndPublish
{
    // flush to make sure IOSurface updates are seen globally.
    glFlushRenderAPPLE();
    
    if (_pushPending)
    {
        // Our IOSurface won't update until the next glFlush(). Usually we rely on our host doing this, but
        // we must do it for the first frame on a new surface to avoid sending surface details for a surface
        // which has no clean image.
        glFlush();
        // Push the new surface ID to clients
        [_connectionManager setSurfaceID:IOSurfaceGetID(_surfaceRef)];
        _pushPending = NO;
    }
    
    [_connectionManager publishNewFrame];
}

- (void)setupIOSurfaceForSize:(NSSize)size
{
    // init our texture and IOSurface
    NSDictionary* surfaceAttributes = @{(NSString*)kIOSurfaceIsGlobal: [NSNumber numberWithBool:YES],
                                        (NSString*)kIOSurfaceWidth: [NSNumber numberWithUnsignedInteger:(NSUInteger)size.width],
                                        (NSString*)kIOSurfaceHeight: [NSNumber numberWithUnsignedInteger:(NSUInteger)size.height],
                                        (NSString*)kIOSurfaceBytesPerElement: [NSNumber numberWithUnsignedInteger:4U]};
    _surfaceRef =  IOSurfaceCreate((CFDictionaryRef)surfaceAttributes);
    
    // make a new texture.
    _surfaceTexture = [[SyphonIOSurfaceImage alloc] initWithSurface:_surfaceRef];
    
    if(_surfaceTexture == nil)
    {
        [self destroyIOSurface];
    }
    else
    {
        glGenFramebuffers(1, &_surfaceFBO);
        glBindFramebuffer(GL_FRAMEBUFFER, _surfaceFBO);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_RECTANGLE, _surfaceTexture.textureName, 0);
        
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (status != GL_FRAMEBUFFER_COMPLETE)
        {
            SYPHONLOG(@"SyphonServer: Cannot create FBO (OpenGL Error %04X)", status);
            [self destroyIOSurface];
        }
    }
}

- (void) destroyIOSurface
{
	if (_surfaceFBO != 0)
	{
		glDeleteFramebuffers(1, &_surfaceFBO);
		_surfaceFBO = 0;
	}
	
	if (_surfaceRef != NULL)
	{		
		CFRelease(_surfaceRef);
		_surfaceRef = NULL;
	}
	
	[_surfaceTexture release];
	_surfaceTexture = nil;
}

#pragma mark Notification Handling for Server Presence

//
// Broadcast and discovery is done via NSDistributedNotificationCenter.
// Servers notify announce, change (currently only affects name) and retirement.
//
// Discovery is done by a discovery-request notification,
// to which servers respond with an announce.
//
// If this gets unweildy we could move it into a SyphonBroadcaster class
//

//
// We track all instances and send a retirement broadcast
// for any which haven't been stopped when the code is unloaded.
//

static OSSpinLock mRetireListLock = OS_SPINLOCK_INIT;
static NSMutableSet *mRetireList = nil;

+ (void)addServerToRetireList:(NSString *)serverUUID
{
    OSSpinLockLock(&mRetireListLock);
    if (mRetireList == nil)
        mRetireList = [[NSMutableSet alloc] initWithCapacity:1U];
    [mRetireList addObject:serverUUID];
    OSSpinLockUnlock(&mRetireListLock);
}

+ (void)removeServerFromRetireList:(NSString *)serverUUID
{
    OSSpinLockLock(&mRetireListLock);
    [mRetireList removeObject:serverUUID];
    if ([mRetireList count] == 0)
    {
        [mRetireList release];
        mRetireList = nil;
    }
    OSSpinLockUnlock(&mRetireListLock);
}

+ (void)retireRemainingServers
{
    // take the set out of the global so we don't hold the spin-lock while we send the notifications
    // even though there should never be contention for this
    NSMutableSet *mySet = nil;
    OSSpinLockLock(&mRetireListLock);
    mySet = mRetireList;
    mRetireList = nil;
    OSSpinLockUnlock(&mRetireListLock);
    for (NSString *uuid in mySet) {
        SYPHONLOG(@"Retiring a server at code unload time because it was not properly stopped");
        NSDictionary *fakeServerDescription = [NSDictionary dictionaryWithObject:uuid forKey:SyphonServerDescriptionUUIDKey];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:SyphonServerRetire 
                                                                       object:SyphonServerDescriptionUUIDKey
                                                                     userInfo:fakeServerDescription
                                                           deliverImmediately:YES];
    }
    [mySet release];
}

- (void)startBroadcasts
{
	// Register for any Announcement Requests.
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDiscoveryRequest:) name:SyphonServerAnnounceRequest object:nil];
	[self broadcastServerAnnounce];
}

- (void)handleDiscoveryRequest:(NSNotification*) aNotification
{
	SYPHON_UNUSED(aNotification);
	SYPHONLOG(@"Got Discovery Request");
	[self broadcastServerAnnounce];
}

- (void)broadcastServerAnnounce
{
    NSDictionary *description = self.serverDescription;
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:SyphonServerAnnounce 
                                                                   object:[description objectForKey:SyphonServerDescriptionUUIDKey]
                                                                 userInfo:description
                                                       deliverImmediately:YES];
}

- (void)broadcastServerUpdate
{
	NSDictionary *description = self.serverDescription;
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:SyphonServerUpdate
																   object:[description objectForKey:SyphonServerDescriptionUUIDKey]
																 userInfo:description
                                                       deliverImmediately:YES];
}

- (void)stopBroadcasts
{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	NSDictionary *description = self.serverDescription;
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:SyphonServerRetire 
																   object:[description objectForKey:SyphonServerDescriptionUUIDKey]
																 userInfo:description
                                                       deliverImmediately:YES];	
}

@end

#pragma mark
#pragma mark Local scope finalizer

__attribute__((destructor)) static void finalizer()
{
    [SyphonServer retireRemainingServers];
}
