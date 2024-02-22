using System.Collections;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEditor;
using UnityEngine;
using X3Game;
using PapeGames.X3Editor;

namespace X3GameEditor
{
    [CustomEditor(typeof(ECGSimulator))]
    public class ECGSimulatorInspector : BaseInspector<ECGSimulator>
    {
        private int strength = 0;
        private ECGSimulator script
        {
            get => (ECGSimulator) target;
        }


        public override void OnInspectorGUI()
        {
            DrawDefaultInspector();
            strength = EditorGUILayout.IntField("Strength", strength);
            if (GUILayout.Button("Beat"))
            {
                script.Beat(strength, () => { Debug.Log("[ECG] Reach crest!"); });
            }
        }
    }
}