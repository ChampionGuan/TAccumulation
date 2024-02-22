using System;
using BattleCurveAnimator;
using MessagePack;

using UnityEngine.Profiling;

namespace X3Battle
{
    [BuffAction("动态伤害修饰")]
    [MessagePackObject]
    [Serializable]
    public class DynamicDamageModify : BuffActionBase
    {
        [BuffLable("MathParam")] [Key(0)] public string mathParam;
        [BuffLable("参数")] [Key(1)] public float[] param;
        [Key(2)] public string paramStr;

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
            buffActionType = BuffAction.DynamicDamageModify;
            if (!string.IsNullOrEmpty(mathParam) && mathParam.StartsWith("MathParam"))
            {
                var layerConfig = TbUtil.GetBuffLevelConfig(_owner);
                float[] temp = TbUtil.GetBuffMathParam(layerConfig, mathParam);

                if (temp != null)
                {
                    if (temp.Length != 7)
                    {
                        PapeGames.X3.LogProxy.LogError($"BuffLevelConfig表没有配置{_owner.ID}，联系策划卡宝宝");
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

            _actor.battle.eventMgr.AddListener<EventBeforeHit>(EventType.OnBeforeHit, _OnBeforeHit, "DynamicDamageModify._OnBeforeHit");
            basicInit = param[0] / 1000f;
            basicFinal = param[1] / 1000f;

            effectAttr = (int)param[2];
            effectPercentInit = param[3]/1000f;
            effectAdditionInit = param[4];
            effectPercentFinal = param[5]/1000f;
            effectAdditionFinal = param[6];
        }

        public override void OnDestroy()
        {
            _actor.battle.eventMgr.RemoveListener<EventBeforeHit>(EventType.OnBeforeHit, _OnBeforeHit);
            ObjectPoolUtility.DynamicDamageModifyPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.DynamicDamageModifyPool.Get();
            action.mathParam = mathParam;
            action.param = param;
            action.paramStr = paramStr;
            return action;
        }

        private void _OnBeforeHit(EventBeforeHit arg)
        {
            if (arg.damageExporter.GetCaster() == _actor)
            {
                using (ProfilerDefine.DynamicDamageModifyOnBeforeHitPMarker.Auto())
                {

                    var dynamicHitInfo = arg.dynamicHitInfo;
                    var hitInfo = arg.hitInfo;

                    var source = arg.target;

                    var additionalValue = BattleUtil.CalDynamicAttr(source.attributeOwner.GetAttrValue(AttrType.HP),
                        source.attributeOwner.GetAttrValue(AttrType.MaxHP), basicInit, basicFinal, effectAdditionInit,
                        effectAdditionFinal);
                    var percentValue = BattleUtil.CalDynamicAttr(source.attributeOwner.GetAttrValue(AttrType.HP),
                        source.attributeOwner.GetAttrValue(AttrType.MaxHP), basicInit, basicFinal, effectPercentInit,
                        effectPercentFinal);

                    Actor target = hitInfo.damageCaster;
                    var attrType = (AttrType)effectAttr;

                    // DONE: 伤害加深默认给受击方修改.
                    if (attrType == AttrType.FinalDamageDec)
                    {
                        target = hitInfo.damageTarget;
                    }

                    using (ProfilerDefine.DynamicDamageModifyAttrModifiesPMarker.Auto())
                    {
                        // DONE: 修改属性.
                        dynamicHitInfo.attrModifies.Add(new AttrModifyData()
                        {
                            actor = target,
                            attrType = attrType,
                            additionalValue = additionalValue,
                            percentValue = percentValue,
                        });
                    }
                }
            }
        }
    }
}