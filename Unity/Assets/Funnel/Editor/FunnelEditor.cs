//
// Funnel: Minimal Syphon Server Plugin for Unity
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
using UnityEditor;
using System.Collections;

[CustomEditor(typeof(Funnel))]
class FunnelEditor : Editor
{
    static string[] aaLabels = {"Off", "x2", "x4", "x8"};
    static int[] aaValues = {1, 2, 4, 8};

    public override void OnInspectorGUI ()
    {
        var funnel = target as Funnel;

        // Screen settings.
        funnel.screenWidth = EditorGUILayout.IntField ("Screen Width", funnel.screenWidth);
        funnel.screenHeight = EditorGUILayout.IntField ("Screen Height", funnel.screenHeight);
        funnel.antiAliasing = EditorGUILayout.IntPopup ("Anti-Aliasing", funnel.antiAliasing, aaLabels, aaValues);

        // Preview settings.
        funnel.drawGameView = EditorGUILayout.Toggle ("Draw Game View", funnel.drawGameView);

        if (funnel.previewOnInspector = EditorGUILayout.Foldout (funnel.previewOnInspector, "Preview"))
        {
            if (EditorApplication.isPlaying)
            {
                var texture = funnel.renderTexture;
                if (texture)
                {
                    EditorGUILayout.Space ();
                    var rect = GUILayoutUtility.GetAspectRect (1.0f * texture.width / texture.height);
                    EditorGUILayout.Space ();
                    EditorGUI.DrawPreviewTexture (rect, texture);
                    // Make it dirty to stay updated.
                    EditorUtility.SetDirty (target);
                }
            }
            else
            {
                EditorGUILayout.HelpBox("Available only on Play Mode", MessageType.None);
            }
        }
    }
}
