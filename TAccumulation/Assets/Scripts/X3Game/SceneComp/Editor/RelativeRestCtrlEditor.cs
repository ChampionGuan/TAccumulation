using System;
using System.Text;
using UnityEditor;
using UnityEngine;
using UnityEngine.Profiling;
using X3Game;
using PapeGames.X3;

namespace X3GameEditor
{
    [CustomEditor(typeof(RelativeRestCtrl))]
    public class RelativeRestCtrlEditor : Editor
    {
        public override bool HasPreviewGUI()
        {
            return Application.isPlaying;
        }
        
        private GUIStyle m_PreviewLabelStyle;
        protected GUIStyle previewLabelStyle
        {
            get
            {
                if (m_PreviewLabelStyle == null)
                {
                    m_PreviewLabelStyle = new GUIStyle("PreOverlayLabel")
                    {
                        richText = true,
                        alignment = TextAnchor.UpperLeft,
                        fontStyle = FontStyle.Normal
                    };
                }

                return m_PreviewLabelStyle;
            }
        }

        protected GameObject m_Character;
        protected String m_Bones;
        private bool m_IsShowBone;
        private bool m_IsShowState;

        public override void OnPreviewGUI(Rect rect, GUIStyle background)
        {
            base.OnPreviewGUI(rect, background);
            var ctrl = target as RelativeRestCtrl;
            if (ctrl == null)
                return;
            GUI.Label(rect, ctrl.GetPairString(), previewLabelStyle);
        }

        
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            var ctrl = target as RelativeRestCtrl;
            
            if(GUILayout.Button("UnLock All"))
            {
                ctrl.UnLockAll();
            }
            if(GUILayout.Button("Lock All"))
            {
                ctrl.LockAll();
            }
            
            // GUILayout.BeginHorizontal();
            // GUILayout.EndHorizontal();

            m_IsShowState = GUILayout.Toggle(m_IsShowState, "查看锁定状态");
            if (m_IsShowState)
            {
                var dict = ctrl.getDict;
                foreach (var i in dict)
                {
                    var pair = i.Value;
                    if (pair.target != null && pair.alignTo != null)
                    {
                        GUILayout.BeginHorizontal();
                        EditorGUILayout.ObjectField("", pair.target, typeof(GameObject), false);
                        if (pair.isLock)
                        {
                            GUILayout.Label("-->");
                        }
                        else
                        {
                            GUILayout.Label("--x");
                        }
                    
                        EditorGUILayout.ObjectField("", pair.alignTo, typeof(GameObject), false);
                        GUILayout.EndHorizontal();
                    }
                }
            }
            
            m_IsShowBone = GUILayout.Toggle(m_IsShowBone, "查看可用骨骼");
            if (m_IsShowBone)
            {
                m_Character = (GameObject)EditorGUILayout.ObjectField("放入一个 Character ", m_Character, typeof(GameObject), true);
                if (GUILayout.Button("查看可用骨骼"))
                {
                    m_Bones = ShowAviableBones(m_Character);
                }

                EditorGUILayout.TextField("可用骨骼", m_Bones);
            }
            
        }

        private string ShowAviableBones(GameObject ins)
        {
            var dic = DictionaryPool<string, int>.Get();
            if (ins != null)
            {
                var renderers = ins.GetComponentsInChildren<SkinnedMeshRenderer>();
                if (renderers != null && renderers.Length > 0)
                {
                    for (int i = 0; i < renderers.Length; ++i)
                    {
                        for (int j = 0; j < renderers[i].bones.Length; ++j)
                        {
                            int count;
                            if (!dic.TryGetValue(renderers[i].bones[j].name, out count))
                            {
                                dic.Add(renderers[i].bones[j].name, 1);
                            }
                            else
                            {
                                dic[renderers[i].bones[j].name] = dic[renderers[i].bones[j].name] + 1;
                            }
                        }
                    }
                }
            }

            var str = new StringBuilder();
            foreach (var v in dic)
            {
                str.AppendLine($"{v.Key}:{v.Value}");
            }
            DictionaryPool<string, int>.Release(dic);
            return str.ToString();
        }
    }
}