using System;
using MessagePack;

namespace X3Battle
{
    [BuffAction("Buff血量护盾")]
    [MessagePackObject]
    [Serializable]
    public class BuffHPShield : BuffActionBase
    {
        [BuffLable("HpShield")] 
        [Key(0)] public string HpShieldMathParam;
        [Key(1)] public float[] HpShieldParam;

        [IgnoreMember] public float curHPShield;

        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.HPShield;
        }

        public override void OnAdd(int layer)
        {
            curHPShield = 0;
            if (HpShieldParam != null && HpShieldParam.Length == 3)
            {
                // 如果配了数组
                if (HpShieldParam[0] != 0)
                {
                    curHPShield = _owner.actor.attributeOwner.GetAttrValue((AttrType)HpShieldParam[0]) * (HpShieldParam[1] * 0.001f);
                }

                curHPShield += HpShieldParam[2];
            }
            else
            {
                // 如果配了MathParam
                if (HpShieldMathParam.StartsWith("MathParam"))
                {
                    var layerConfig = TbUtil.GetBuffLevelConfig(_owner);
                    float[] temp = TbUtil.GetBuffMathParam(layerConfig, HpShieldMathParam);
                    if (temp != null)
                    {
                        if (temp.Length != 3)
                        {
                            PapeGames.X3.LogProxy.LogError($"BuffLevelConfig表配置有误buffID{_owner.ID}, 属性长度不等于3，联系策划卡宝宝");
                        }
                        else
                        {
                            if (temp[0] != 0)
                            {
                                curHPShield = _owner.actor.attributeOwner.GetAttrValue((AttrType)temp[0]) * (temp[1] * 0.001f);
                            }

                            curHPShield += temp[2];
                        }
                    }
                }
            }

            _actor.shield.AddHpShield(_owner, curHPShield);
        }

        public override void OnDestroy()
        {
            _actor.shield.RemoveHpShield(_owner);
            ObjectPoolUtility.BuffHPShieldPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffHPShieldPool.Get();
            action.HpShieldMathParam = HpShieldMathParam;
            action.HpShieldParam = HpShieldParam;
            return action;
        }
    }
}