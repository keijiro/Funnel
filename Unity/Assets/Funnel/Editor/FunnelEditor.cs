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
using UnityEditor;
using System.Collections;

namespace Funnel {

[CustomEditor(typeof(Funnel))]
class FunnelEditor : Editor
{
    static GUIContent[] aaLabels = {
        new GUIContent("Off"),
        new GUIContent("x2"),
        new GUIContent("x4"),
        new GUIContent("x8")
    };

    static int[] aaValues = {1, 2, 4, 8};

    SerializedProperty propScreenWidth;
    SerializedProperty propScreenHeight;
    SerializedProperty propAntiAliasing;
    SerializedProperty propAlphaChannel;
    SerializedProperty propRenderMode;

    void OnEnable()
    {
        propScreenWidth  = serializedObject.FindProperty("_screenWidth");
        propScreenHeight = serializedObject.FindProperty("_screenHeight");
        propAntiAliasing = serializedObject.FindProperty("_antiAliasing");
        propAlphaChannel = serializedObject.FindProperty("_alphaChannel");
        propRenderMode   = serializedObject.FindProperty("_renderMode");
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        EditorGUILayout.PropertyField(propScreenWidth);
        EditorGUILayout.PropertyField(propScreenHeight);
        EditorGUILayout.IntPopup(propAntiAliasing, aaLabels, aaValues);

        EditorGUI.BeginChangeCheck();
        EditorGUILayout.PropertyField(propAlphaChannel);
        var changed = EditorGUI.EndChangeCheck();

        EditorGUILayout.PropertyField(propRenderMode);

        serializedObject.ApplyModifiedProperties();

        if (changed)
            foreach (var t in targets)
                (t as Funnel).SendMessage("ResetServerState");
    }
}

} // namespace Funnel
