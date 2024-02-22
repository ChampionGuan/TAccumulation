using System.Collections;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace X3Battle
{
    //Editor时预览
    [ExecuteInEditMode]
    public class DummiesMono : MonoBehaviour
    {
        public Dummies dummies;
        public void Init(List<Dummy> dummys, Transform root)
        {
            dummies = new Dummies();
            dummies.Init(dummys, root);
        }

        public bool TryAddDummy(string name, Transform dummyTrans, Transform boneTrans)
        {
            if (dummies == null)
                LogProxy.LogError("【DummiesMonoInEditor】未Init");

            return dummies.TryAddDummy(name, dummyTrans, boneTrans);
        }

        public Transform GetDummyTrans(string name)
        {
            if (dummies == null)
                LogProxy.LogError("【DummiesMonoInEditor】未Init");

            return dummies.GetDummyTrans(name);
        }

        public Dummy GetDummy(string name)
        {
            if (dummies == null)
                LogProxy.LogError("【DummiesMonoInEditor】未Init");

            return dummies.GetDummy(name);
        }

        private void LateUpdate()
        {
            dummies?.Update();
        }
    }

#if UNITY_EDITOR
    public class DummiesEditorGUI
    {
        private Dummies m_Dummies;

        public DummiesEditorGUI(Dummies target)
        {
            m_Dummies = target;
        }

        public void OnInspectorGUI()
        {
            EditorGUILayout.LabelField("标准挂点，骨骼挂点详见X3Character");
            foreach (var dummy in m_Dummies.AllDummies)
            {
                EditorGUILayout.ObjectField(dummy.Key, dummy.Value.GetDummy(), typeof(Transform), false);
            }
        }
    }

    [CustomEditor(typeof(DummiesMono))]
    public class DummiesMonoEditor : Editor
    {
        DummiesMono _script;
        DummiesEditorGUI editorGUI;

        private void OnEnable()
        {
            _script = (DummiesMono)target;
            editorGUI = new DummiesEditorGUI(_script.dummies);
        }

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            using (new EditorGUILayout.VerticalScope("box"))
            {
                editorGUI.OnInspectorGUI();
            }
        }
    }
#endif
}
