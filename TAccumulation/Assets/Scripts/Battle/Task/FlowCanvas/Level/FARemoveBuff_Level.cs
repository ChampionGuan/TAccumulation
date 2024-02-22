using NodeCanvas.Framework;
using ParadoxNotion.Design;
using System;
using System.Collections.Generic;
using FlowCanvas;

namespace X3Battle
{    
    [Category("X3Battle/关卡/Action")]
    [Name("【关卡】给对象移除buff\nActorRemoveBuffInLevel")]
    public class FARemoveBuff_Level : FlowAction
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
        public BBParameter<BuffTagFlag> buffTagFlag = new BBParameter<BuffTagFlag>(X3Battle.BuffTagFlag.Buff);
        public BBParameter<int> buffLayer = new BBParameter<int>();

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
                    _RemoveBuffOnTarget(_battle.actorMgr.boy);
                    break;
                case LevelMonsterType.Girl:
                    _RemoveBuffOnTarget(_battle.actorMgr.girl);
                    break;
                case LevelMonsterType.Monster:
                    if (groupId == null)
                        return;
                    if (monsterTemplateId == null)
                        return;
                    if (monsterInsId == null)
                        return;
                    _battle.actorMgr.GetMonstersByCondition(LevelMonsterMode.Alive, groupId.value, monsterTemplateId.value, monsterInsId.value, _tempActors);
    
                    foreach (var target in _tempActors)
                    {
                        _RemoveBuffOnTarget(target);
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
                        _RemoveBuffOnTarget(target);
                    }
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }

        private void _RemoveBuffOnTarget(Actor target)
        {
            if (target == null)
            {
                _LogError($"节点【【关卡】给对象移除buff】配置错误:: 找不到目标Actor, 参数为groupId={groupId.value}");
                return;
            }

            if (target.buffOwner == null)
            {
                _LogError($"节点【【关卡】给对象移除buff】配置错误: 目标Actor.cfgID:{target.cfgID}, Actor.name:{target.name}没有BuffOwner组件.");
                return;
            }

            if (buffId.value > 0)
                target.buffOwner.ReduceStack(buffId.GetValue(), buffLayer.GetValue()); // 当value配置了大于0时，直接移除对应的buffId
            else
            {
                if (buffTagFlag.isNoneOrNull)
                    return;
                for(int i = 0; i < Enum.GetValues(typeof(BuffTag)).Length; i ++)
                {
                    var buffTagFlagValue = buffTagFlag.value;
                    BuffTag tag = (BuffTag)Enum.GetValues(typeof(BuffTag)).GetValue(i);

                    if (((BuffTagFlag)(1 << (int)tag) & buffTagFlagValue) == 0)
                        continue;

                    target.buffOwner.RemoveAllMatchBuff(BuffType.Attribute, tag, 0, 0, true, false);
                }
            }
        }
    }
}
