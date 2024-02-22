using PapeGames.X3;
using UnityEditor;
using UnityEngine;
using PapeGames.X3Editor;
using X3Game;
using PapeGames.X3Editor;

namespace X3GameEditor
{
    [CustomEditor(typeof(LuaUICtrl))]
    public class LuaUICtrlInspector : BaseInspector<LuaUICtrl>
    {
        private SerializedProperty m_PropFuncStr;
        protected override void Init()
        {
            base.Init();
            m_PropFuncStr = this.GetSP("m_FuncStr");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            EditorGUILayout.Space();
            EditorGUILayout.HelpBox(Target.LuaPath, MessageType.None);
            EditorGUILayout.Space();
            if (GUILayout.Button("定位Lua代码"))
            {
                Target.OnHierarchyItemIconClicked();
            }
            EditorGUILayout.Space();
            this.DrawPF(m_PropFuncStr);
            if (GUILayout.Button("执行成员方法"))
            {
                DoFuncString(Target.gameObject, Target.LuaPath, m_PropFuncStr.stringValue);
            }

            serializedObject.ApplyModifiedProperties();
        }

        private void DoFuncString(GameObject go, string luaPath, string funcStr)
        {
            var sb = StringUtility.GetStringBuilder();
            sb.AppendLine("local helper = require('Runtime.System.Framework.GameBase.Helper.LuaBindHelper')");
            sb.AppendLine($"local tbl = helper.GetCtrl(CS.PapeGames.X3UI.LuaUICtrl.GetObject({go.GetInstanceID()}), '{luaPath}')");
            sb.AppendLine($"if tbl == nil then");
            sb.AppendLine($" print('find no lua ctrl: {luaPath}')");
            sb.AppendLine($"else");
            if (!funcStr.Contains("("))
                sb.AppendLine($" tbl:{funcStr}()");
            else
                sb.AppendLine($" tbl:{funcStr}");
            sb.AppendLine($"end");
            X3Lua.DoString(sb.ToString());
            StringUtility.ReleaseStringBuilder(sb);
        }
    }
}