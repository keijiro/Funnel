//
// Funnel - Syphon Server Plugin for Unity
// By Keijiro Takahashi, 2013
//
// - There are 256 slots for servers.
// - This plugin uses render event IDs from 0xf9100 to 0xf91ff for handling the slots.
//

#import <Foundation/Foundation.h>
#import <Syphon/Syphon.h>
#import "FunnelServerHandler.h"

// Event ID
#define FUNNEL_EVENT_ID 0xfa9100

// Application bound OpenGL context.
static CGLContextObj glContext;

// Server slots.
static NSPointerArray *servers;

#pragma mark
#pragma mark Expoerted functions

// Set a frame texture.
void FunnelSetFrameTexture(int slotIndex, const char* frameName, int textureName, int width, int height)
{
    if (!servers) return;
    
    FunnelServerHandler *handler = [servers pointerAtIndex:slotIndex];
    
    // Allocate a new handler if it gets a new slot.
    if (!handler)
    {
        handler = [[FunnelServerHandler alloc] init];
        [servers replacePointerAtIndex:slotIndex withPointer:handler];
        
        NSString *name = [NSString stringWithUTF8String:frameName];
        handler.syphonServer = [[SyphonServer alloc] initWithName:name context:glContext options:nil];
    }
    
    handler.frameTextureName = textureName;
    handler.frameTextureRect = NSMakeRect(0, 0, width, height);
}

// Callback function for graphics device initialization/shutdown.
void UnitySetGraphicsDevice(void *device, int deviceType, int eventType)
{
    if (eventType == 0) // kGfxDeviceEventInitialize
    {
        glContext = CGLGetCurrentContext();
        servers = [[NSPointerArray strongObjectsPointerArray] retain];
        servers.count = 256;
    }
    else if (eventType == 1) // kGfxDeviceEventShutdown
    {
        glContext = nil;
        [servers release];
        servers = nil;
    }
}

// Callback function for rendering events.
void UnityRenderEvent(int eventID)
{
    if (!servers) return;

    // Check the event ID.
    if ((eventID & ~0xff) != FUNNEL_EVENT_ID) return;
    
    // Retrieve the server handler from the server slot.
    FunnelServerHandler *handler = [servers pointerAtIndex:(eventID & 0xff)];
    
    // Publish the frame if the handler is valid.
    if (handler)
    {
        [handler.syphonServer publishFrameTexture:handler.frameTextureName
                                    textureTarget:GL_TEXTURE_2D
                                      imageRegion:handler.frameTextureRect
                                textureDimensions:handler.frameTextureRect.size
                                          flipped:NO];
    }
}
