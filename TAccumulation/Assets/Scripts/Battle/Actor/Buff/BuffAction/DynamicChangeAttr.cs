using System;
using BattleCurveAnimator;
using MessagePack;
using NodeCanvas.Tasks.Conditions;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("动态属性变更")]
    [MessagePackObject]
    [Serializable]
    public class DynamicChangeAttr : BuffActionBase
    {
        [BuffLable("MathParam")] [Key(0)] public string mathParam;
        [BuffLable("参数")] [Key(1)] public float[] param;
        [Key(2)] public string paramStr;
        
        [IgnoreMember] public float percent;
        [IgnoreMember] public float addition;
        [IgnoreMember] public int basicAttr;
        [IgnoreMember] public float basicInit;
        [IgnoreMember] public float basicFinal;
        [IgnoreMember] public int effectAttr;
        [IgnoreMember] public float effectAdditionInit;
        [IgnoreMember] public float effectPercentInit;
        [IgnoreMember] public float effectAdditionFinal;
        [IgnoreMember] public float effectPercentFinal;

        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.DynamicChangeAttr;
            if (!string.IsNullOrEmpty(mathParam) && mathParam.StartsWith("MathParam"))
            {
                var config = TbUtil.GetBuffLevelConfig(_owner);
                float[] temp = TbUtil.GetBuffMathParam(config, mathParam);

                if (temp != null)
                {
                    if (temp.Length != 7)
                    {
                        PapeGames.X3.LogProxy.LogError($"BuffLevelConfig表配置错误{_owner.ID}, 属性长度不等于7，联系策划卡宝宝");
                        return;
                    }
                    else
                    {
                        param = temp;
                    }
                }
            }
            
            if (param == null || param.Length != 7)
            {
                PapeGames.X3.LogProxy.LogError($"Buff参数配置有误{_owner.ID}，联系策划卡宝宝");
                return;
            }
            
            basicInit = param[0] / 1000f;
            basicFinal = param[1] / 1000f;

            effectAttr = (int)param[2];
            effectPercentInit = param[3] / 1000f;
            effectAdditionInit = param[4];
            effectPercentFinal = param[5] / 1000f;
            effectAdditionFinal = param[6];
            // 
            addition = BattleUtil.CalDynamicAttr(_actor.attributeOwner.GetAttrValue(AttrType.HP), _actor.attributeOwner.GetAttrValue(AttrType.MaxHP), basicInit, basicFinal, effectAdditionInit, effectAdditionFinal);
            percent = BattleUtil.CalDynamicAttr(_actor.attributeOwner.GetAttrValue(AttrType.HP), _actor.attributeOwner.GetAttrValue(AttrType.MaxHP), basicInit, basicFinal, effectPercentInit, effectPercentFinal);

            _actor.attributeOwner.GetAttr((AttrType)effectAttr).Add(addition, percent);

            _actor.battle.eventMgr.AddListener<EventActorHealthChangeForUI>(EventType.ActorHealthChangeForUI, _OnAttrChange, "DynamicChangeAttr._OnAttrChange");
        }

        public override void OnDestroy()
        {
            base.OnDestroy();
            // 将已修改的属性还原
            _actor.attributeOwner.GetAttr((AttrType)effectAttr).Sub(addition, percent);
            _actor.battle.eventMgr.RemoveListener<EventActorHealthChangeForUI>(EventType.ActorHealthChangeForUI, _OnAttrChange);
            ObjectPoolUtility.DynamicChangeAttrPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.DynamicChangeAttrPool.Get();
            action.mathParam = mathParam;
            action.param = param;
            action.paramStr = paramStr;
            return action;
        }

        private void _OnAttrChange(EventActorHealthChangeForUI arg)
        {
            if (arg.actor == _actor)
            {
                var addDelta = BattleUtil.CalDynamicAttr(_actor.attributeOwner.GetAttrValue(AttrType.HP),_actor.attributeOwner.GetAttrValue(AttrType.MaxHP), basicInit, basicFinal, effectAdditionInit, effectAdditionFinal) - addition;
                var perDelta = BattleUtil.CalDynamicAttr(_actor.attributeOwner.GetAttrValue(AttrType.HP),_actor.attributeOwner.GetAttrValue(AttrType.MaxHP), basicInit, basicFinal, effectPercentInit, effectPercentFinal) - percent;
                _actor.attributeOwner.GetAttr((AttrType)effectAttr).Add(addDelta, perDelta);

                addition += addDelta;
                percent += perDelta;
            }
        }
    }
}