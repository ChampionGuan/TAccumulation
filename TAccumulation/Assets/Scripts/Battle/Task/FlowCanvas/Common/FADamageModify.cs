using System.Collections.Generic;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("伤害修饰\nDamageModify")]
    public class FADamageModify : FlowAction
    {
        public BBParameter<ModifiableAttrType> ModifiableAttrType = new BBParameter<ModifiableAttrType>(X3Battle.ModifiableAttrType.FinalDamageAdd);
        public BBParameter<float> ModifyAdditionalValue = new BBParameter<float>();
        public BBParameter<float> ModifyPercentValue = new BBParameter<float>();

        private ValueInput<HitInfo> _viHitInfo;
        private ValueInput<DynamicHitInfo> _viDynamicHitInfo;
        private ValueInput<List<float>> _viMathParam;
        
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viHitInfo = AddValueInput<HitInfo>(nameof(HitInfo));
            _viDynamicHitInfo = AddValueInput<DynamicHitInfo>(nameof(DynamicHitInfo));
            _viMathParam = AddValueInput<List<float>>("MathParam");
        }

        protected override void _Invoke()
        {
            var hitInfo = _viHitInfo.GetValue();
            if (hitInfo == null)
            {
                _LogError("请联系策划【卡宝】,【伤害修饰 DamageModify】节点配置错误. 引脚【HitInfo】没有赋值.");
                return;
            }
            
            var dynamicHitInfo = _viDynamicHitInfo.GetValue();
            if (dynamicHitInfo == null)
            {
                _LogError("请联系策划【卡宝】,【伤害修饰 DamageModify】节点配置错误. 引脚【DynamicHitInfo】没有赋值.");
                return;
            }

            AttrType attrType = AttrType.None;
            float additionalValue = 0f;
            float percentValue = 0f;
            var mathParam = _viMathParam.GetValue();
            // DONE: 使用表格里的配置.
            if (mathParam != null && mathParam.Count > 0)
            {
                int param0 = (int) mathParam[0];
                if (mathParam.Count >= 3 && System.Enum.IsDefined(typeof(ModifiableAttrType), param0))
                {
                    attrType = (AttrType) param0;
                    percentValue = mathParam[1] * 0.001f;
                    additionalValue = mathParam[2];
                }
                else
                {
                    _LogError("请联系策划【卡宝】,【伤害修饰 DamageModify】mathParam配置错误, 有可能为以下几种原因. 1:MathParam数组长度不足3个. 2:MathParam[0]不为ModifiableAttrType内可临时修改的属性.");
                }
            }
            // DONE: 使用节点上的参数.
            else
            {
                attrType = (AttrType) ModifiableAttrType.GetValue();
                additionalValue = ModifyAdditionalValue.GetValue();
                percentValue = ModifyPercentValue.GetValue();
            }

            if (attrType == AttrType.None)
            {
                _LogError("请联系策划【卡宝】,【伤害修饰 DamageModify】mathParam配置错误, 按前面调试修改.");
                return;
            }

            Actor target = hitInfo.damageCaster;
            
            // DONE: 伤害加深 和 受到治疗效果增强 默认给受击方修改.
            if (attrType == AttrType.FinalDamageDec 
                || attrType == AttrType.CuredAdd 
                || attrType == AttrType.WeakHurtAdd
                || attrType == AttrType.PhyDefence)
            {
                target = hitInfo.damageTarget;
            }

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
