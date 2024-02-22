using System;
using System.Collections.Generic;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("判断指定区域内是否有指定角色\nIfTargetAreaHasTargetActor")]
    public class FAIsTargetInTriggerArea  : FlowAction
    {
        public LevelTargetType targetType = LevelTargetType.None;
        [ShowIf(nameof(targetType), (int)LevelTargetType.None)]
        public BBParameter<int> targetId = new BBParameter<int>();
        [ShowIf(nameof(targetType), (int)LevelTargetType.Monster)]
        public BBParameter<int> groupId = new BBParameter<int>(-1);
        [ShowIf(nameof(targetType), (int)LevelTargetType.Monster)]
        [Name("MonsterTemplateID")]
        public BBParameter<int> templateId = new BBParameter<int>(-1);
        
        public BBParameter<int> triggerId = new BBParameter<int>();

        private FlowOutput _trueOutput;
        private FlowOutput _falseOutput;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _trueOutput = AddFlowOutput("True");
            _falseOutput = AddFlowOutput("False");
        }

        protected override void _Invoke()
        {
            if (triggerId.isNone)
            {
                _falseOutput.Call(new Flow());
                return;
            }
            
            Actor triggerActor = Battle.Instance.actorMgr.GetActor(triggerId.value);
            if (triggerActor?.triggerArea == null)
            {
                _falseOutput.Call(new Flow());
                return;
            }

            var targetList = ObjectPoolUtility.CommonActorList.Get();
            switch (targetType)
            {
                case LevelTargetType.None:
                    targetList.Add(Battle.Instance.actorMgr.GetActor(targetId.value));
                    break;
                case LevelTargetType.Girl:
                    targetList.Add(Battle.Instance.actorMgr.girl);
                    break;
                case LevelTargetType.Boy:
                    targetList.Add(Battle.Instance.actorMgr.boy);
                    break;
                case LevelTargetType.BoyOrGirl:
                    targetList.Add(Battle.Instance.actorMgr.girl);
                    targetList.Add(Battle.Instance.actorMgr.boy);
                    break;
                case LevelTargetType.Monster:
                    Battle.Instance.actorMgr.GetMonstersByCondition(LevelMonsterMode.Alive, groupId.GetValue(), templateId.GetValue(), -1, targetList);
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            // 倒序移除列表里获取可能为空的情况.
            for (int i = targetList.Count - 1; i >= 0; i--)
            {
                if (targetList[i] == null)
                {
                    targetList.RemoveAt(i);
                }
            }
            
            if (targetList.Count <= 0)
            {
                ObjectPoolUtility.CommonActorList.Release(targetList);
                _falseOutput.Call(new Flow());
                return;
            }
            
            bool b = false;
            List<Actor> actors = triggerActor.triggerArea.GetInnerActors();
            foreach (Actor actor in actors)
            {
                if (targetList.Contains(actor))
                {
                    b = true;
                    break;
                }
            }

            if (!b)
            {
                ObjectPoolUtility.CommonActorList.Release(targetList);
                _falseOutput.Call(new Flow());
                return;
            }

            ObjectPoolUtility.CommonActorList.Release(targetList);
            _trueOutput.Call(new Flow());
        }
    }
}
