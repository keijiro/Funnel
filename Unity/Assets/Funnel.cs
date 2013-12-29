//
// Funnel: Minimal Syphon Server Plugin for Unity
//
// Copyright (C) 2013 Keijiro Takahashi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class Funnel : MonoBehaviour
{
    #region Class constants and variables

    // Render Event ID (0xfa9100 - 0xfa91ff)
    const int RenderEventID = 0xfa9100;

    // Slot index counter.
    static int slotCount = 0;

    #endregion

    #region Public properties

    public int screenWidth = 1280;
    public int screenHeight = 720;

    #endregion

    #region Private variables

    // Slot index for this server.
    int slotIndex;

    // Render texture which is to be sent.
    RenderTexture renderTexture;

    #endregion

    #region Native plugin interface

    [DllImport("Funnel")]
    static extern void FunnelSetFrameTexture (int slotIndex, string frameName, int textureID, int width, int height);

    [DllImport("Funnel")]
    static extern void FunnelReleaseSlot (int slotIndex);

    #endregion

    #region MonoBehaviour functions

    void Start ()
    {
        // Grab a slot.
        slotIndex = slotCount++;

        // Create a render texture and assign it to the camera.
        renderTexture = new RenderTexture (screenWidth, screenHeight, 24);
        camera.targetTexture = renderTexture;

        // Reset the aspect ratio.
        camera.ResetAspect ();
    }

    void OnDisable ()
    {
        // Release the slot.
        FunnelReleaseSlot (slotIndex);
    }

    void Update ()
    {
        // Set the previous frame to the slot.
        FunnelSetFrameTexture (slotIndex, gameObject.name, renderTexture.GetNativeTextureID (), screenWidth, screenHeight);

        // Call GL operations on the GL thread.
        GL.IssuePluginEvent (RenderEventID + slotIndex);
    }

    #endregion
}
