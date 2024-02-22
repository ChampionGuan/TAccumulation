using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using System.Collections.Generic;
using FlowCanvas;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("【关卡】给对象添加buff\nAddBuff")]
    public class FAAddBuff : FlowAction
    {
        [GatherPortsCallback]
        public LevelMonsterType type;
        [ShowIf("type", 2)]
        public BBParameter<int> groupId = new BBParameter<int>();
        [ShowIf("type", 2)]
        public BBParameter<int> monsterTemplateId = new BBParameter<int>();
        [ShowIf("type", 2)]
        public BBParameter<int> monsterInsId = new BBParameter<int>();

        public BBParameter<int> buffId = new BBParameter<int>();
        public BBParameter<int> buffLayer = new BBParameter<int>();
        public BBParameter<int> buffLevel = new BBParameter<int>();

        private List<Actor> _tempActors = new List<Actor>(5);
        private ValueInput<List<Actor>> _viActors;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            if (type == LevelMonsterType.ActorList)
            {
                _viActors = AddValueInput<List<Actor>>(nameof(List<Actor>));   
            }
        }

        protected override void _Invoke()
        {
            switch (type)
            {
                case LevelMonsterType.Boy:
                    _AddBuffToTarget(_battle.actorMgr.boy);
                    break;
                case LevelMonsterType.Girl:
                    _AddBuffToTarget(_battle.actorMgr.girl);
                    break;
                case LevelMonsterType.Monster:
                    if (groupId == null)
                        return;
                    if (monsterTemplateId == null)
                        return;
                    if (monsterInsId == null)
                        return;
                    _battle.actorMgr.GetMonstersByCondition(LevelMonsterMode.Alive, groupId.value, monsterTemplateId.value, monsterInsId.value, _tempActors);
                    foreach(var target in _tempActors)
                    {
                        _AddBuffToTarget(target);
                    }
                    _tempActors.Clear();
                    break;
                case LevelMonsterType.ActorList:
                    var list = _viActors?.GetValue();
                    if (list == null)
                    {
                        return;
                    }
                    
                    foreach(var target in list)
                    {
                        _AddBuffToTarget(target);
                    }
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }

        private void _AddBuffToTarget(Actor target)
        {
            if (target == null)
            {
                _LogError($"节点【【关卡】给对象添加buff】配置错误:: 找不到目标Actor, groupId={groupId.value}");
                return;
            }

            if (target.buffOwner == null)
            {
                _LogError($"节点【【关卡】给对象添加buff】配置错误: 目标Actor.cfgID:{target.cfgID}, Actor.name:{target.name}没有BuffOwner组件. ");
                return;
            }

            int level = buffLevel.GetValue();
            if (level <= 0)
            {
                var triggerLevel = (IGraphLevel)_context;
                if (triggerLevel != null)
                {
                    level = triggerLevel.level;
                }
            }

            target.buffOwner.Add(buffId.GetValue(), buffLayer.GetValue(), null, level, _actor);
        }
    }
}
