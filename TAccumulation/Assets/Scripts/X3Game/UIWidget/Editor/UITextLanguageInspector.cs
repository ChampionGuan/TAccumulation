using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;
using PapeGames.X3;
using X3Game;
using PapeGames.X3Editor;
using X3GameEditor.EditorTable;

namespace X3GameEditor
{
    [CustomEditor(typeof(UITextLanguage))]
    class UITextLanguageInspector : BaseInspector<UITextLanguage>
    {
        SerializedProperty m_PropLanguageId;
        string ui_text = string.Empty;
        private int m_id = 0;
        private static string[] s_Des;

        protected override void Init()
        {
            m_PropLanguageId = this.GetSP("languageId");
            RefreshText();
            FillText();
            LoadData();
        }

        void RefreshText()
        {
            ui_text = UITextLanguage.GetUIText(m_PropLanguageId.intValue);
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            if (string.IsNullOrEmpty(ui_text))
            {
                EditorGUILayout.HelpBox("languageId不存在", MessageType.Error);
            }

            EditorGUILayout.BeginHorizontal();
            EditorGUI.BeginChangeCheck();
            this.DrawPF(m_PropLanguageId);
            if (EditorGUI.EndChangeCheck())
            {
                m_id = GetIdx(m_PropLanguageId.intValue);
            }

            EditorGUI.BeginChangeCheck();
            m_id = PapeGames.X3Editor.X3EditorGUILayout.SearchablePopup(m_id, s_Des, GUILayout.Width(150));
            if (EditorGUI.EndChangeCheck())
            {
                m_PropLanguageId.intValue = GetId(s_Des[m_id]);
                RefreshText();
                FillText();
            }

            EditorGUILayout.EndHorizontal();
            EditorGUILayout.Space();
            if (PapeGames.X3Editor.X3EditorGUILayout.Button("刷新Text内容"))
            {
                RefreshText();
                FillText();
            }

            EditorGUILayout.Space();
            if (PapeGames.X3Editor.X3EditorGUILayout.Button("刷新配置数据"))
            {
                ParseCfg();
                LoadData();
                m_id = GetIdx(m_PropLanguageId.intValue);
                RefreshText();
                FillText();
            }

            if (!string.IsNullOrEmpty(ui_text))
            {
                EditorGUILayout.Space();
                PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
                PapeGames.X3Editor.X3EditorGUILayout.MultiLabel(ui_text);
            }

            serializedObject.ApplyModifiedProperties();
        }

        static int GetId(string des)
        {
            if (string.IsNullOrEmpty(des)) return 0;
            int startId = des.LastIndexOf("[");
            int endId = des.LastIndexOf("]");
            string sub = des.Substring(startId + 1, endId - startId - 1);
            if (int.TryParse(sub, out var id))
            {
                return id;
            }

            return 0;
        }

        static int GetIdx(int textId)
        {
            if (s_Des != null)
            {
                var des = $"[{textId}]";
                for (int i = 0; i < s_Des.Length; i++)
                {
                    if (s_Des[i].EndsWith(des))
                    {
                        return i;
                    }
                }
            }

            return 0;
        }

        static void LoadData()
        {
            ParseCfg();
            s_Des = null;
            List<string> temp = ListPool<string>.Get();
            temp.Add("[NONE]");
            var list = EditorTableCfgMgr.Instance.GetAll<UITextData_ETC>();
            foreach (var it in list)
            {
                temp.Add($"{it.Text}[{it.TextID}]");
            }

            s_Des = temp.ToArray();
            ListPool<string>.Release(temp);
        }

        static void ParseCfg()
        {
            EditorTableCfgMgr.Instance.Reload<UITextData_ETC>();
            EditorTableCfgMgr.Instance.Reload<UITextDataAuto_ETC>();
        }

        void FillText()
        {
            UIUtility.SetText(m_Target, ui_text);
        }
    }
}