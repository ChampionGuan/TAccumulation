using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace X3Battle
{
    //Editor下模拟播放特效
    //无法完全模拟,没有真实战斗环境,没传parent不会仅跟随位置,无自适应缩放
    [ExecuteInEditMode]
    public class FxMgrMono : MonoBehaviour
    {
        public FxMgr fxMgr;
        private void Start()
        {
            fxMgr = new FxMgr();
        }

        public void Reset()
        {
            fxMgr = new FxMgr();
        }

        private void LateUpdate()
        {
            fxMgr?.OnLateUpdateTick();
        }

        private void OnDestroy()
        {
            fxMgr?.OnDestroy();
        }
    }
}

#if UNITY_EDITOR
namespace X3Battle
{
    [CustomEditor(typeof(FxMgrMono))]
    public class FxMgrMonoEditor : Editor
    {
        FxMgrMono _script;
        int _cfgID;
        public void OnEnable()
        {
            _script = (FxMgrMono)target;
        }

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            GUILayout.BeginHorizontal();
            _cfgID = EditorGUILayout.IntField("ID:", _cfgID);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            if (GUILayout.Button("播放", GUILayout.Width(100)))
            {
                var fx = _script.fxMgr.PlayBattleFx(_cfgID, offsetPos: new Vector3(0, 1, 0));
            }
            if (GUILayout.Button("停止", GUILayout.Width(100)))
            {
                _script.fxMgr.StopFx(_cfgID, 0);
            }
            if (GUILayout.Button("清理", GUILayout.Width(100)))
            {
                _script.fxMgr.StopFx(_cfgID, 0, isStopAndClear: true);
            }
            GUILayout.EndHorizontal();
        }
    }
}
#endif