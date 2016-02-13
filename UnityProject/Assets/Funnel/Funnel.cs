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

using UnityEngine;
using System.Runtime.InteropServices;

namespace Funnel
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    [AddComponentMenu("Rendering/Syphon/Funnel")]
    public class Funnel : MonoBehaviour
    {
        #region Exposed properties

        /// Width of the screen to be sent
        public int screenWidth {
            get { return Mathf.Clamp(_screenWidth, 8, 8192); }
            set { _screenWidth = value; }
        }
        [SerializeField] int _screenWidth = 1280;

        /// Height of the screen to be sent
        public int screenHeight {
            get { return Mathf.Clamp(_screenHeight, 8, 8192); }
            set { _screenHeight = value; }
        }
        [SerializeField] int _screenHeight = 720;

        /// Anti-aliasing (MSAA) option
        public int antiAliasing {
            get { return _antiAliasing; }
            set { _antiAliasing = value; }
        }
        [SerializeField] int _antiAliasing = 1;

        /// Discards alpha channel before sending
        public bool discardAlpha {
            get { return _discardAlpha; }
            set { _discardAlpha = value; }
        }
        [SerializeField] bool _discardAlpha = true;

        /// Determines how to handle the rendered screen
        public RenderMode renderMode {
            get { return _renderMode; }
            set { _renderMode = value; }
        }
        [SerializeField] RenderMode _renderMode = RenderMode.RenderToTarget;
        public enum RenderMode { SendOnly, RenderToTarget, PreviewOnGameView }

        /// Screen render target
        public Texture renderTexture {
            get { return _renderTexture; }
        }
        RenderTexture _renderTexture; // should not be serialized

        #endregion

        #region Private members

        // Slot index counter
        static int _slotCount = 0;

        // Server slot index
        int _slotIndex;

        // Gamma correction shader
        [SerializeField] Shader _gammaShader;
        Material _gammaMaterial;

        // Material with lazy shader initialization
        Material gammaMaterial {
            get {
                if (_gammaMaterial == null) {
                    _gammaMaterial = new Material(_gammaShader);
                    _gammaMaterial.hideFlags = HideFlags.DontSave;
                }
                return _gammaMaterial;
            }
        }

        // Detects changes on the screen settings.
        bool ScreenSettingsChanged {
            get {
                return _renderTexture && (
                    _renderTexture.width != screenWidth ||
                    _renderTexture.height != screenHeight ||
                    _renderTexture.antiAliasing != antiAliasing
                );
            }
        }

        #endregion

        #region Native plugin interface

        [DllImport("Funnel", EntryPoint="FunnelSetFrame")]
        static extern void SetSourceFrame(
            int slotIndex, string frameName,
            System.IntPtr texture, int width, int height,
            bool linearToSrgb, bool discardAlpha
        );

        [DllImport("Funnel")]
        static extern System.IntPtr GetRenderEventFunc();

        static void InvokePublishEvent(int slot)
        {
            const int publishEventID = 0x10000;
            GL.IssuePluginEvent(GetRenderEventFunc(), publishEventID + slot);
        }

        static void InvokeReleaseEvent(int slot)
        {
            const int releaseEventID = 0x20000;
            GL.IssuePluginEvent(GetRenderEventFunc(), releaseEventID + slot);
        }

        #endregion

        #region MonoBehaviour functions

        void OnEnable()
        {
            // Grab a new slot.
            _slotIndex = _slotCount++;

            // Create a render target.
            _renderTexture = new RenderTexture(screenWidth, screenHeight, 24);
            _renderTexture.hideFlags = HideFlags.DontSave;
            _renderTexture.antiAliasing = antiAliasing;

            // Override the camera.
            var camera = GetComponent<Camera>();
            camera.targetTexture = _renderTexture;
            camera.ResetAspect();
        }

        void OnDisable()
        {
            // Release the slot.
            InvokeReleaseEvent(_slotIndex);

            // Release the camera.
            var camera = GetComponent<Camera>();
            camera.targetTexture = null;
            camera.ResetAspect();

            // Release temporary assets.
            if (_gammaMaterial) DestroyImmediate(_gammaMaterial);
            if (_renderTexture) DestroyImmediate(_renderTexture);
            _gammaMaterial = null;
            _renderTexture = null;
        }

        void Update()
        {
            // Update the render target when the screen settings are changed.
            if (ScreenSettingsChanged)
            {
                var camera = GetComponent<Camera>();

                // Detach the render rexture temporarily because changes on
                // camera target texture is not allowed.
                camera.targetTexture = null;

                _renderTexture.Release();

                _renderTexture.width = screenWidth;
                _renderTexture.height = screenHeight;
                _renderTexture.antiAliasing = antiAliasing;

                camera.targetTexture = _renderTexture;

                GetComponent<Camera>().ResetAspect();
            }
        }

        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            var linear = QualitySettings.activeColorSpace == ColorSpace.Linear;

            // Screen blit
            if (_renderMode == RenderMode.PreviewOnGameView && linear)
                Graphics.Blit(source, destination, gammaMaterial, 0);
            else if (_renderMode != RenderMode.SendOnly)
                Graphics.Blit(source, destination);

            // Publish the content of the source buffer.
            SetSourceFrame(
                _slotIndex, gameObject.name,
                source.GetNativeTexturePtr(), source.width, source.height,
                linear, _discardAlpha);

            InvokePublishEvent(_slotIndex);
        }

        void OnGUI()
        {
            // Blit the render texture if preview is enabled.
            if (_renderMode != RenderMode.PreviewOnGameView) return;
            var rect = new Rect(0, 0, Screen.width, Screen.height);
            GUI.DrawTexture(rect, _renderTexture, ScaleMode.ScaleToFit, false);
        }

        #endregion
    }
}
