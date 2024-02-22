#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;

namespace X3Battle
{
    [CustomEditor(typeof(LookAtBehaviour))]
    public class LookAtBehaviourEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            if (GUILayout.Button("Back To Normal"))
            {
                var behaviour = target as LookAtBehaviour;
                behaviour.LookAtTarget(null, behaviour.targetOffset);
            }
        }
    } 
}
#endif