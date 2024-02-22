using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using X3Game;
using PapeGames.X3Editor;

[CustomEditor(typeof(TileScreenAdaptation), true)]
[CanEditMultipleObjects]
public class TileScreenAdaptationEditor : Editor
{
    SerializedProperty m_Padding;
    SerializedProperty m_StartAxis;


    TileScreenAdaptation tgt;
    protected virtual void OnEnable()
    {
        tgt = target as TileScreenAdaptation;
        m_Padding = serializedObject.FindProperty("m_Padding");
        m_StartAxis = serializedObject.FindProperty("m_StartAxis");
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        EditorGUILayout.PropertyField(m_Padding, true);
        EditorGUILayout.PropertyField(m_StartAxis, true);

        serializedObject.ApplyModifiedProperties();

        if (!EditorApplication.isPlaying)
        {
            tgt.Adaptation();
        }
    }
}
