#import <Foundation/Foundation.h>
#import <Syphon/Syphon.h>

// Event ID: Publish a frame texture.
#define FUNNEL_EVENT_PUBLISH 0xfa910

// Syphon server and bound OpenGL context.
static SyphonServer *server;
static CGLContextObj glContext;

// Frame texture.
static GLint frameTextureID;
static NSRect frameTextureRect;

// Exported functions.

// Set a frame texture.
void FunnelSetFrameTexture(int textureID, int width, int height)
{
    frameTextureID = textureID;
    frameTextureRect = NSMakeRect(0, 0, width, height);
}

// Callback function for graphics device initialization/shutdown.
void UnitySetGraphicsDevice(void *device, int deviceType, int eventType)
{
    if (eventType == 0) // kGfxDeviceEventInitialize
    {
        glContext = CGLGetCurrentContext();
        server = [[SyphonServer alloc] initWithName:@"Funnel (Unity)" context:glContext options:nil];
    }
    else if (eventType == 1) // kGfxDeviceEventShutdown
    {
        [server stop];
        [server release];
        server = nil;
    }
}

// Callback function for rendering events.
void UnityRenderEvent(int eventID)
{
    if (eventID == FUNNEL_EVENT_PUBLISH)
    {
        [server publishFrameTexture:frameTextureID textureTarget:GL_TEXTURE_2D imageRegion:frameTextureRect textureDimensions:frameTextureRect.size flipped:NO];
    }
}
