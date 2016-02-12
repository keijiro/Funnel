//
// Funnel - Syphon server plugin for Unity
//
// Copyright (C) 2013-2016 Keijiro Takahashi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "Syphon/Syphon.h"
#import "FunnelServerHandler.h"
#import "IUnityGraphics.h"

// Event IDs
#define FUNNEL_EVENT_PUBLISH 0x10000
#define FUNNEL_EVENT_RELEASE 0x20000

// Server slot table
static NSPointerArray *s_servers;
OSSpinLock s_lock = OS_SPINLOCK_INIT;

#pragma mark Native plugin functions

// Set a frame texture to a given slot
void UNITY_INTERFACE_EXPORT UNITY_INTERFACE_API FunnelSetFrame(
    int slotIndex, const char* frameNameCString,
    int textureName, int width, int height,
    bool linearToSRGB, bool discardAlpha)
{
    if (!s_servers) return;
    
    OSSpinLockLock(&s_lock);
    
    FunnelServerHandler *handler = [s_servers pointerAtIndex:slotIndex];
    
    // Allocate a new handler if it's an unused slot.
    if (!handler)
    {
        handler = [[FunnelServerHandler alloc] init];
        [s_servers replacePointerAtIndex:slotIndex withPointer:handler];
        [handler release];
        NSLog(@"Funnel: slot %d created", slotIndex);
    }
    
    // Status update
    handler.serverName = [NSString stringWithUTF8String:frameNameCString];
    handler.frameTextureName = textureName;
    handler.frameTextureRect = NSMakeRect(0, 0, width, height);
    handler.linearToSRGB = linearToSRGB;
    handler.discardAlpha = discardAlpha;
    
    OSSpinLockUnlock(&s_lock);
}

#pragma mark Rendering callbacks

// Graphics device event handler
void UNITY_INTERFACE_API OnGraphicsDeviceEvent(UnityGfxDeviceEventType eventType)
{
    OSSpinLockLock(&s_lock);
    
    if (eventType == kUnityGfxDeviceEventInitialize)
    {
        NSLog(@"Funnel: initialized");
        if (s_servers) [s_servers release];
        s_servers = [[NSPointerArray strongObjectsPointerArray] retain];
        s_servers.count = 256;
    }
    else if (eventType == kUnityGfxDeviceEventShutdown)
    {
        NSLog(@"Funnel: shut down");
        [s_servers release];
        s_servers = nil;
    }

    OSSpinLockUnlock(&s_lock);
}

// Render event handler
void UNITY_INTERFACE_API OnRenderEvent(int eventID)
{
    if (!s_servers) return;

    int slotIndex = eventID & 0xffff;
    eventID -= slotIndex;
    
    OSSpinLockLock(&s_lock);
    
    if (eventID == FUNNEL_EVENT_PUBLISH)
    {
        FunnelServerHandler *handler = [s_servers pointerAtIndex:slotIndex];
        if (handler)
        {
            SyphonServer *server = handler.syphonServer;
            
            // Create a new server if not yet.
            if (!server)
            {
                server = [[SyphonServer alloc] initWithName:handler.serverName];
                handler.syphonServer = server;
                [server release];
                NSLog(@"Funnel: created a new server with slot %d", slotIndex);
            }
            
            // Publish the frame if it has clients.
            if (server.hasClients)
            {
                server.linearToSRGB = handler.linearToSRGB;
                server.discardsAlpha = handler.discardAlpha;
                [server publishFrameTexture:handler.frameTextureName size:handler.frameTextureRect.size];
            }
        }
    }
    else if (eventID == FUNNEL_EVENT_RELEASE)
    {
        // Release the resources in the slot.
        [s_servers replacePointerAtIndex:slotIndex withPointer:nil];
        NSLog(@"Funnel: slot %d released", slotIndex);
    }
    
    OSSpinLockUnlock(&s_lock);
}
