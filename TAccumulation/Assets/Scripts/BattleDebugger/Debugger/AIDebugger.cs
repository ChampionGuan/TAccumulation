#if DEBUG_GM || UNITY_EDITOR
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace X3Battle.Debugger
{
    public class AIDebugger : IDebugger
    {
        public string name => "AI";
        private float _interval = 0f;

        private GUIStyle _fontStyle = new GUIStyle
        {
            fontSize = 15,
            normal = new GUIStyleState { textColor = Color.white },
            richText = true,
        };

        private List<Actor> _monsterActors = new List<Actor>(3);
        private List<bool> _showMonsterToggles;

        private string _girlAIActionInfo = "";
        private string _boyAIActionInfo = "";
        private string _monsterAIActionInfo = "";
        private bool _showGirl = true;
        private bool _showBoy = true;

        public AIDebugger()
        {
            _showMonsterToggles = Enumerable.Repeat(false, 5).ToList();
        }

        public void OnEnter()
        {
        }

        public void OnExit()
        {
        }

        public void OnGUI()
        {
            if (null == Battle.Instance)
            {
                return;
            }

            Battle.Instance.actorMgr.GetActors(ActorType.Monster, null, _monsterActors);
            if (_showGirl) _girlAIActionInfo = _GetActorAIActionInfo(Battle.Instance.actorMgr.girl);
            if (_showBoy) _boyAIActionInfo = _GetActorAIActionInfo(Battle.Instance.actorMgr.boy);
            _monsterAIActionInfo = "";
            for (int i = 0; i < _monsterActors.Count; i++)
            {
                if (i > _showMonsterToggles.Count - 1)
                {
                    _showMonsterToggles.Add(false);
                }

                if (_showMonsterToggles[i])
                {
                    _monsterAIActionInfo += _GetActorAIActionInfo(_monsterActors[i]);
                }
            }

            GUILayout.BeginHorizontal();
            GUILayout.BeginVertical();
            _showGirl = GUI.Toggle(new Rect(10, 10, 50, 50), _showGirl, "Girl");
            _showBoy = GUI.Toggle(new Rect(10, 50, 50, 50), _showBoy, "Boy");
            for (int i = 0; i < _monsterActors.Count; i++)
            {
                _showMonsterToggles[i] = GUI.Toggle(new Rect(10, 50 * i + 100, 100, 50), _showMonsterToggles[i], $"{_monsterActors[i].name}  {_monsterActors[i].insID}");
            }

            GUILayout.EndVertical();
            GUILayout.BeginVertical();
            if (_showGirl) GUI.Label(new Rect(100, 10, 500, 1000), _girlAIActionInfo, _fontStyle);
            if (_showBoy) GUI.Label(new Rect(600, 10, 500, 1000), _boyAIActionInfo, _fontStyle);
            GUI.Label(new Rect(1200, 10, 500, 1000), _monsterAIActionInfo, _fontStyle);
            GUILayout.EndVertical();
            GUILayout.EndHorizontal();
        }

        private string _GetActorAIActionInfo(Actor actor)
        {
            var ai = actor?.aiOwner?.combatAI;
            if (null == ai) return "";

            var info = $"<color=yellow>{actor.name} {actor.insID}</color>： paused:{ai.paused}  disabled:{ai.disabled} \n当前正在执行的指令：\n";
            if (actor.commander.currentCmd != null)
            {
                info += actor.commander.currentCmd.GetType().FullName;
            }

            info += "\n当前正在执行的行为：\n";
            var currAction = ai.currAction;
            var allAction = ai.waitActions;
            if (currAction != null)
            {
                info += currAction.ToString();
            }

            info += "\n行为队列中的行为: \n";
            foreach (var action in allAction)
            {
                info += action.ToString();
                info += "\n";
            }

            // 动画数据
            var preAnimatorState = actor.animator.GetPreviousAnimatorStateInfo(0);
            // 按30帧来算
            var preFrame = Mathf.RoundToInt(preAnimatorState.length * 30);
            var currAnimatorState = actor.animator.GetCurrentAnimatorStateInfo(0);
            var currFrame = Mathf.RoundToInt(currAnimatorState.length * 30);
            info += "当前动画信息：\n";
            info += $"{preAnimatorState.name} ({preAnimatorState.weight}) [{(int)Mathf.Floor(preFrame * (float)preAnimatorState.normalizedTime)}/{preFrame}]\n";
            info += $"{currAnimatorState.name} ({currAnimatorState.weight}) [{(int)Mathf.Floor(currFrame * (float)currAnimatorState.normalizedTime)}/{currFrame}]\n";
            info += "\n";
            return info;
        }
    }
}
#endif