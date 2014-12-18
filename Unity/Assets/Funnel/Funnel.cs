//
// Funnel - Minimal Syphon Server Plugin for Unity
//
// Copyright (C) 2014 Keijiro Takahashi
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

namespace Funnel {

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
[AddComponentMenu("Rendering/Syphon/Funnel")]
public class Funnel : MonoBehaviour
{
    #region Public Properties

    // Screen settings.
    [SerializeField] int _screenWidth = 1280;
    [SerializeField] int _screenHeight = 720;
    [SerializeField] int _antiAliasing = 1;
    [SerializeField] bool _alphaChannel = false;

    public int screenWidth {
        get { return Mathf.Clamp(_screenWidth, 8, 4096); }
        set { _screenWidth = value; }
    }

    public int screenHeight {
        get { return Mathf.Clamp(_screenHeight, 8, 4096); }
        set { _screenHeight = value; }
    }

    public int antiAliasing {
        get { return _antiAliasing; }
        set { _antiAliasing = value; }
    }

    public bool alphaChannel {
        get { return _alphaChannel; }
        set {
            // Reset the server when updating.
            if (_alphaChannel != value)
            {
                _alphaChannel = value;
                ResetServerState();
            }
        }
    }

    // Render mode.
    public enum RenderMode { SendOnly, RenderToTarget, PreviewOnGUI }
    [SerializeField] RenderMode _renderMode = RenderMode.RenderToTarget;

    public RenderMode renderMode {
        get { return _renderMode; }
        set { _renderMode = value; }
    }

    // Screen buffer.
    RenderTexture _renderTexture;

    public Texture renderTexture {
        get { return _renderTexture; }
    }

    #endregion

    #region Internal Class Members

    // Render event ID (0xfa9100 - 0xfa92ff).
    const int PublishEventID = 0xfa9100;
    const int ReleaseEventID = 0xfa9200;

    // Slot index counter.
    static int _slotCount = 0;

    #endregion

    #region Internal Instance Members

    // Gamma correction shader (used in preview display).
    [SerializeField] Shader _gammaCorrectShader;
    Material _gammaCorrectMaterial;

    // Slot index of this server.
    int _slotIndex = -1;

    #endregion

    #region Native Plugin Interface

    [DllImport("Funnel")]
    static extern void FunnelSetFrameTexture(
        int slotIndex,
        string frameName,
        int textureID,
        int width, int height,
        bool srgbColor, bool discardAlpha
    );

    #endregion

    #region Private Properties and Functions

    // Check if the screen settings are changed.
    bool ScreenSettingsChanged
    {
        get {
            return _renderTexture && (
                _renderTexture.width != screenWidth ||
                _renderTexture.height != screenHeight ||
                _renderTexture.antiAliasing != antiAliasing
            );
        }
    }

    // Screen rect for preview display.
    Rect PreviewRect {
        get {
            if ((float)Screen.width / Screen.height < (float)screenWidth / screenHeight)
            {
                var margin = Screen.height - screenHeight * Screen.width / screenWidth;
                return new Rect(0, margin / 2, Screen.width, Screen.height - margin);
            }
            else
            {
                var margin = Screen.width - screenWidth * Screen.height / screenHeight;
                return new Rect(margin / 2, 0, Screen.width - margin, Screen.height);
            }
        }
    }

    // Sets up resources.
    void SetUpResources()
    {
        // Grab a new slot.
        if (_slotIndex < 0)
            _slotIndex = _slotCount++;

        // Prepare gamma correction shader.
        if (_gammaCorrectMaterial == null && _gammaCorrectShader)
        {
            _gammaCorrectMaterial = new Material(_gammaCorrectShader);
            _gammaCorrectMaterial.hideFlags = HideFlags.DontSave;
        }

        // Make screen buffer.
        if (_renderTexture == null && _screenWidth > 0 && _screenHeight > 0)
        {
            _renderTexture = new RenderTexture(screenWidth, screenHeight, 24);
            _renderTexture.hideFlags = HideFlags.DontSave;
            _renderTexture.antiAliasing = antiAliasing;
        }

        // Override the camera.
        if (_renderTexture && camera.targetTexture != _renderTexture)
        {
            camera.targetTexture = _renderTexture;
            camera.ResetAspect();
        }
    }

    // Reset the state of the Syphon server.
    void ResetServerState()
    {
        if (_slotIndex >= 0)
            GL.IssuePluginEvent(ReleaseEventID + _slotIndex);
    }

    #endregion

    #region MonoBehaviour Functions

    void Awake()
    {
        SetUpResources();
    }

    void Start()
    {
        SetUpResources();
    }

    void OnEnable()
    {
        SetUpResources();
    }

    void OnDisable()
    {
        // Release the slot.
        if (_slotIndex >= 0)
            GL.IssuePluginEvent(ReleaseEventID + _slotIndex);

        // Release the camera.
        if (camera.targetTexture != null && camera.targetTexture == _renderTexture)
        {
            camera.targetTexture = null;
            camera.ResetAspect();
        }
    }


    void Update()
    {
        // Update the screen buffer when the screen settings are changed.
        if (ScreenSettingsChanged)
        {
            _renderTexture.Release();

            _renderTexture.width = screenWidth;
            _renderTexture.height = screenHeight;
            _renderTexture.antiAliasing = antiAliasing;

            if (camera.targetTexture && camera.targetTexture == _renderTexture)
                camera.ResetAspect();
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_slotIndex >= 0 && _renderTexture)
        {
            if (Application.isEditor || _renderMode != RenderMode.SendOnly)
            {
                // Blit and publish.
                Graphics.Blit(source, destination);
                FunnelSetFrameTexture(
                    _slotIndex,
                    gameObject.name,
                    destination.GetNativeTextureID(),
                    screenWidth, screenHeight,
                    _renderTexture.sRGB, !_alphaChannel
                );
            }
            else
            {
                // Publish only.
                FunnelSetFrameTexture(
                    _slotIndex,
                    gameObject.name,
                    source.GetNativeTextureID(),
                    screenWidth, screenHeight,
                    _renderTexture.sRGB, !_alphaChannel
                );
            }

            // Call the GL operation on the GL thread.
            GL.IssuePluginEvent(PublishEventID + _slotIndex);
        }
        else
        {
            // Resources are not ready: just blit.
            Graphics.Blit(source, destination);
        }
    }

    void OnGUI()
    {
        // Preview display.
        if (_renderMode == RenderMode.PreviewOnGUI &&
            Event.current.type.Equals(EventType.Repaint) &&
            _renderTexture && _gammaCorrectMaterial)
        {
            Graphics.DrawTexture(
                PreviewRect, _renderTexture,
                _renderTexture.sRGB ? _gammaCorrectMaterial : null
            );
        }
    }

    #endregion
}

} // namespace Funnel
