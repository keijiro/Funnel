//
// Unity low-level native plugin interface
//
#import "IUnityInterface.h"
#import "IUnityGraphics.h"

namespace
{
    IUnityInterfaces* s_interfaces;
    IUnityGraphics* s_graphics;
}

extern "C"
{
    void UNITY_INTERFACE_API OnGraphicsDeviceEvent(UnityGfxDeviceEventType eventType);
    void UNITY_INTERFACE_API OnRenderEvent(int eventID);
    
    // Plugin load event
    void UNITY_INTERFACE_EXPORT UNITY_INTERFACE_API UnityPluginLoad(IUnityInterfaces* interfaces)
    {
        s_interfaces = interfaces;
        s_graphics = s_interfaces->Get<IUnityGraphics>();
        
        s_graphics->RegisterDeviceEventCallback(OnGraphicsDeviceEvent);
        
        // Run OnGraphicsDeviceEvent(initialize) manually on plugin load
        OnGraphicsDeviceEvent(kUnityGfxDeviceEventInitialize);
    }
    
    // Plugin unload event
    void UNITY_INTERFACE_EXPORT UNITY_INTERFACE_API UnityPluginUnload()
    {
        s_graphics->UnregisterDeviceEventCallback(OnGraphicsDeviceEvent);
    }
    
    // Render event callback referer
    UnityRenderingEvent UNITY_INTERFACE_EXPORT UNITY_INTERFACE_API GetRenderEventFunc()
    {
        return OnRenderEvent;
    }
}


