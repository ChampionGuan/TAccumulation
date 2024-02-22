using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("创建直接命中打击盒\nCreateDirectDamageBox")]
    public class FACreateDirectDamageBox : FlowAction
    {
        public BBParameter<int> damageBoxID = new BBParameter<int>();
        public BBParameter<float> duration = new BBParameter<float>();

        private ValueInput<Actor> _sourceActor;
        private ValueInput<DamageExporter> _viDamageExporter;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _sourceActor = AddValueInput<Actor>("SourceActor");
            _viDamageExporter = AddValueInput<DamageExporter>(nameof(DamageExporter));
        }

        protected override void _Invoke()
        {
            var target = _sourceActor.GetValue();
            if (target == null)
            {
                _LogError("请联系策划【卡宝】,【创建直接命中包围盒 CreateDirectDamageBox】节点配置错误. 引脚【SourceActor】没有正确赋值.");
                return;
            }

            var damageBoxId = damageBoxID.GetValue();
            var damageBoxCfg = TbUtil.GetCfg<DamageBoxCfg>(damageBoxId);
            if (damageBoxCfg == null)
            {
                _LogError("请联系策划【卡宝】,【创建直接命中包围盒 CreateDirectDamageBox】节点配置错误. 引脚【SourceActor】没有正确赋值.");
                return;
            }

            // DONE: 强制将配置改为直接命中类型的.
            damageBoxCfg.CheckTargetType = CheckTargetType.Direct;
            damageBoxCfg.DirectSelectType = DirectSelectType.SpecifyTarget;
            
            DamageExporter damageExporter = _viDamageExporter?.GetValue() ?? _source as DamageExporter;
            if (damageExporter == null)
            {
                _LogError($"请联系策划【蜗牛君】, 该蓝图非技能orBuff图, 请在正确的蓝图里使用这个节点【创建系数修正直接命中打击盒 CastCoefficientDamageBox】, graph.name:{_graphOwner.gameObject.name}, boxId:{damageBoxId}");
                return;
            }
            damageExporter.CastDamageBox(null, damageBoxCfg, target, _level, out _, null, null, duration.GetValue());
        }
    }
}
