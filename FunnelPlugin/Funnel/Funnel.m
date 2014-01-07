//
// Funnel: Minimal Syphon Server Plugin for Unity
// By Keijiro Takahashi, 2013, 2014
//
// - There are 256 slots for servers.
// - This plugin uses render event IDs from 0xf9100 to 0xf92ff.
//

#import <Foundation/Foundation.h>
#import <Syphon/Syphon.h>
#import "FunnelServerHandler.h"

// Event ID
#define FUNNEL_EVENT_PUBLISH 0xfa9100
#define FUNNEL_EVENT_RELEASE 0xfa9200

// Server slots.
static NSPointerArray *servers;

// Mutex object.
OSSpinLock localLock = OS_SPINLOCK_INIT;

#pragma mark
#pragma mark Expoerted functions

// Set a frame texture.
void FunnelSetFrameTexture(int slotIndex, const char* frameNameCString, int textureName, int width, int height)
{
    if (!servers) return;
    
    OSSpinLockLock(&localLock);
    
    // Retrieve the handler from the server slot.
    FunnelServerHandler *handler = [servers pointerAtIndex:slotIndex];
    
    // Allocate a new handler if it's an unknown slot.
    if (!handler)
    {
        handler = [[FunnelServerHandler alloc] init];
        [servers replacePointerAtIndex:slotIndex withPointer:handler];
        [handler release];
        NSLog(@"Funnel: A new handler was created on slot %d.", slotIndex);
    }

    // Update the status.
    handler.serverName = [NSString stringWithUTF8String:frameNameCString];
    handler.frameTextureName = textureName;
    handler.frameTextureRect = NSMakeRect(0, 0, width, height);
    
    OSSpinLockUnlock(&localLock);
}

#pragma mark
#pragma mark Unity rendering callbacks

// Callback function for graphics device initialization/shutdown.
void UnitySetGraphicsDevice(void *device, int deviceType, int eventType)
{
    OSSpinLockLock(&localLock);
    
    if (eventType == 0) // kGfxDeviceEventInitialize
    {
        NSLog(@"Funnel: The graphics device was initialized.");
        if (servers) [servers release];
        servers = [[NSPointerArray strongObjectsPointerArray] retain];
        servers.count = 256;
    }
    else if (eventType == 1) // kGfxDeviceEventShutdown
    {
        NSLog(@"Funnel: The graphics device was shut down.");
        [servers release];
        servers = nil;
    }

    OSSpinLockUnlock(&localLock);
}

// Callback function for rendering events.
void UnityRenderEvent(int eventID)
{
    if (!servers) return;

    OSSpinLockLock(&localLock);
    
    // Retrieve the arguments.
    int slotIndex = eventID & 0xff;
    eventID -= slotIndex;
    
    if (eventID == FUNNEL_EVENT_PUBLISH)
    {
        // Retrieve the server handler from the server slot.
        FunnelServerHandler *handler = [servers pointerAtIndex:slotIndex];
        if (handler)
        {
            // Create a Syphon server if not yet.
            if (!handler.syphonServer)
            {
                SyphonServer *server = [[SyphonServer alloc] initWithName:handler.serverName context:CGLGetCurrentContext() options:nil];
                handler.syphonServer = server;
                [server release];
                NSLog(@"Funnel: A Syphon server was created on slot %d.", slotIndex);
            }
            
            // Publish the frame if it has clients.
            if (handler.syphonServer.hasClients)
            {
                [handler.syphonServer publishFrameTexture:handler.frameTextureName
                                            textureTarget:GL_TEXTURE_2D
                                              imageRegion:handler.frameTextureRect
                                        textureDimensions:handler.frameTextureRect.size
                                                  flipped:NO];
            }
        }
    }
    else if (eventID == FUNNEL_EVENT_RELEASE)
    {
        // Release the resources on the slot.
        [servers replacePointerAtIndex:slotIndex withPointer:nil];
        NSLog(@"Funnel: slot %d was released.", slotIndex);
    }
    
    OSSpinLockUnlock(&localLock);
}
