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
using UnityEditor;

namespace Funnel
{
    [CustomEditor(typeof(Funnel))]
    class FunnelEditor : Editor
    {
        SerializedProperty _screenWidth;
        SerializedProperty _screenHeight;
        SerializedProperty _antiAliasing;
        SerializedProperty _discardAlpha;
        SerializedProperty _renderMode;

        static GUIContent[] _aaLabels = {
            new GUIContent("Off"),
            new GUIContent("x2"),
            new GUIContent("x4"),
            new GUIContent("x8")
        };

        static int[] _aaValues = {1, 2, 4, 8};

        void OnEnable()
        {
            _screenWidth  = serializedObject.FindProperty("_screenWidth");
            _screenHeight = serializedObject.FindProperty("_screenHeight");
            _antiAliasing = serializedObject.FindProperty("_antiAliasing");
            _discardAlpha = serializedObject.FindProperty("_discardAlpha");
            _renderMode   = serializedObject.FindProperty("_renderMode");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUILayout.PropertyField(_screenWidth);
            EditorGUILayout.PropertyField(_screenHeight);
            EditorGUILayout.IntPopup(_antiAliasing, _aaLabels, _aaValues);
            EditorGUILayout.PropertyField(_discardAlpha);
            EditorGUILayout.PropertyField(_renderMode);

            serializedObject.ApplyModifiedProperties();
        }
    }
}
