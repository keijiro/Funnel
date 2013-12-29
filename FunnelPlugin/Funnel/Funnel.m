//
// Funnel: Minimal Syphon Server Plugin for Unity
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
void FunnelSetFrameTexture(int slotIndex, const char* frameNameCString, int textureName, int width, int height)
{
    if (!servers) return;
    
    // Temporary make a string with the name.
    NSString *frameName = [NSString stringWithUTF8String:frameNameCString];
    
    // Retrieve the handler from the server slot.
    FunnelServerHandler *handler = [servers pointerAtIndex:slotIndex];
    
    // Allocate a new handler if it's an unknown slot.
    if (!handler)
    {
        // Create a new handler.
        handler = [[FunnelServerHandler alloc] init];
        [servers replacePointerAtIndex:slotIndex withPointer:handler];
        [handler release];
        
        // Create a new Syphon server.
        SyphonServer *server = [[SyphonServer alloc] initWithName:frameName context:glContext options:nil];
        handler.syphonServer = server;
        [server release];
    }
    else
    {
        // Update the server name if it was changed.
        if (![handler.syphonServer.name isEqualToString:frameName])
        {
            handler.syphonServer.name = frameName;
        }
    }
    
    // Update the status.
    handler.frameTextureName = textureName;
    handler.frameTextureRect = NSMakeRect(0, 0, width, height);
}

// Release a slot.
void FunnelReleaseSlot(int slotIndex)
{
    if (!servers) return;
    [servers replacePointerAtIndex:slotIndex withPointer:nil];
}

#pragma mark
#pragma mark Unity rendering callbacks

// Callback function for graphics device initialization/shutdown.
void UnitySetGraphicsDevice(void *device, int deviceType, int eventType)
{
    if (eventType == 0) // kGfxDeviceEventInitialize
    {
        glContext = CGLGetCurrentContext();
        if (servers) [servers release];
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
