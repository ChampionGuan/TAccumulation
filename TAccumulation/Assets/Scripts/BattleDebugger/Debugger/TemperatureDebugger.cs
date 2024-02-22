#if DEBUG_GM || UNITY_EDITOR
using Framework;
using PapeGames.Rendering;
using UnityEngine;
using X3.Character;

namespace X3Battle.Debugger
{
    public class TemperatureDebugger : IDebugger
    {
        public string name => "温度测试";

        private bool _enableBattle;
        private bool _enableNonBattle;

        private bool _enable3DCamera;
        private bool _enableUICamera;

        private BattleClient _battleClient;

        public void OnEnter()
        {
            _battleClient = BattleClient.Instance;
            _enableUICamera = BattleUtil.UICamera.enabled;
            _enable3DCamera = BattleUtil.MainCamera.enabled;
            _enableNonBattle = FrameworkMainEntry.Instance.enabled;

            if (null == _battleClient) return;
            _enableBattle = _battleClient.enabled;
            _battleClient.onPostUpdate.AddListener(PostUpdate);
        }

        public void OnExit()
        {
            _EnableNotBattle(true);
            if (null != BattleUtil.UICamera)
                BattleUtil.UICamera.enabled = true;
            if (null != BattleUtil.MainCamera)
                BattleUtil.MainCamera.enabled = true;
            if (null != _battleClient)
            {
                _battleClient.enabled = true;
                _battleClient.onPostUpdate.RemoveListener(PostUpdate);
            }

            _battleClient = null;
        }

        private void PostUpdate()
        {
            if (!_enableNonBattle && null != Battle.Instance)
                PlayableAnimationManager.Instance().Update();
        }

        public void OnGUI()
        {
            GUILayout.BeginArea(new Rect(Screen.width / 4f, 50, Screen.width / 2f, Screen.height / 1.5f));

#if ProfilerEnable && UNITY_ANDROID
            GUILayout.Label($"当前电流：{AssetPerformanceTest.Battery.AndroidBatteryMonitor.CurrentAmpere}", GUILayout.Width(120), GUILayout.Height(25));
#else
            GUILayout.Label($"<color=yellow>当前电流：{0} </color>", GUILayout.Width(120), GUILayout.Height(25));
#endif
            if (null != _battleClient)
            {
                GUILayout.Space(25);
                _enableBattle = GUILayout.Toggle(_enableBattle, "暂停战斗主逻辑", GUILayout.Width(120), GUILayout.Height(25));
                if (GUI.changed) _EnableBattle(_enableBattle);

                _enableNonBattle = GUILayout.Toggle(_enableNonBattle, "暂停非战斗主逻辑", GUILayout.Width(120), GUILayout.Height(25));
                if (GUI.changed) _EnableNotBattle(_enableNonBattle);

                if (null != Battle.Instance)
                {
                    Battle.Instance.floatWordMgr.dontShowFloatWord = GUILayout.Toggle(Battle.Instance.floatWordMgr.dontShowFloatWord, "不显示伤害飘字", GUILayout.Width(120), GUILayout.Height(25));
                }
            }

            GUILayout.Space(25);
            _enable3DCamera = GUILayout.Toggle(_enable3DCamera, "关闭3D相机", GUILayout.Width(120), GUILayout.Height(25));
            if (GUI.changed) BattleUtil.MainCamera.enabled = _enable3DCamera;

            _enableUICamera = GUILayout.Toggle(_enableUICamera, "关闭UI相机", GUILayout.Width(120), GUILayout.Height(25));
            if (GUI.changed) BattleUtil.UICamera.enabled = _enableUICamera;

            GUILayout.EndArea();
        }

        private void _EnableBattle(bool enabled)
        {
            _battleClient.enabled = enabled;

            if (null == Battle.Instance) return;
            foreach (var actor in Battle.Instance.actorMgr.actors)
            {
                var playableGraph = PlayableAnimationManager.Instance()?.FindPlayGraph(actor.GetDummy(ActorDummyType.Model)?.gameObject);
                if (null != playableGraph) playableGraph.Active = enabled;
            }
        }

        private void _EnableNotBattle(bool enabled)
        {
            FrameworkMainEntry.Instance.enabled = enabled;

            if (null == Battle.Instance) return;
            foreach (var actor in Battle.Instance.actorMgr.actors)
            {
                var go = actor.GetDummy(ActorDummyType.Model)?.gameObject;
                var character = go.GetComponent<X3Character>();
                if (null != character) character.enabled = enabled;
                var renderActor = go.GetComponent<RenderActor>();
                if (null != renderActor) renderActor.enabled = enabled;
            }
        }
    }
}
#endif