using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class Funnel : MonoBehaviour
{
    public int screenWidth = 1280;
    public int screenHeight = 720;
    RenderTexture renderTexture;
    const int RenderEventID = 0xfa910;

    [DllImport("Funnel")]
    static extern void FunnelSetFrameTexture (int textureID, int width, int height);

    void Awake ()
    {
        renderTexture = new RenderTexture (screenWidth, screenHeight, 24);
        camera.targetTexture = renderTexture;
    }

    void Update ()
    {
        FunnelSetFrameTexture (renderTexture.GetNativeTextureID (), screenWidth, screenHeight);
        GL.IssuePluginEvent (RenderEventID);
    }
}
