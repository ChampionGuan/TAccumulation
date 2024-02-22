using System.Collections.Generic;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("暴击率修正\nCriticalModify")]
    public class FACriticalModify : FlowAction
    {
        public BBParameter<ModifiableCriticalType> ModifiableCriticalType = new BBParameter<ModifiableCriticalType>(X3Battle.ModifiableCriticalType.CritValue);
        public BBParameter<float> ModifyValue = new BBParameter<float>();

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
                _LogError("请联系策划【蜗牛君】,【暴击率修正 CriticalModify】节点配置错误. 引脚【HitInfo】没有赋值.");
                return;
            }
            
            var dynamicHitInfo = _viDynamicHitInfo.GetValue();
            if (dynamicHitInfo == null)
            {
                _LogError("请联系策划【蜗牛君】,【暴击率修正 CriticalModify】节点配置错误. 引脚【DynamicHitInfo】没有赋值.");
                return;
            }

            var modifiableCriticalType = ModifiableCriticalType.GetValue();
            float modifyValue = ModifyValue.GetValue();
            
            // DONE: 使用表格里的配置.
            var mathParam = _viMathParam.GetValue();
            if (mathParam != null)
            {
                if (mathParam.Count >= 1)
                {
                    modifyValue = mathParam[0];
                }
                else
                {
                    _LogError("请联系策划【蜗牛君】,【暴击率修正 CriticalModify】mathParam配置错误, 有可能为以下几种原因. 1:MathParam数组长度不足1个.");
                }
            }

            // DONE: 记录暴击修正数据.
            dynamicHitInfo.criticalModifies.Add(new CriticalModifyData()
            {
                modifiableCriticalType = modifiableCriticalType,
                modifyValue = modifyValue,
            });
        }
    }
}
