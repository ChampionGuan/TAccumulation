using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("创建打击盒\nCastDamageBox")]
    public class FACastDamageBox : FlowAction
    {
        public BBParameter<int> BoxID = new BBParameter<int>();
        public BBParameter<float> Duration = new BBParameter<float>();
        public BBParameter<Vector3> OffsetAngle = new BBParameter<Vector3>();
        public BBParameter<Vector3> OffsetPos = new BBParameter<Vector3>();

        private ValueInput<DamageExporter> _viDamageExporter;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viDamageExporter = AddValueInput<DamageExporter>(nameof(DamageExporter));
        }

        protected override void _Invoke()
        {
            var boxId = BoxID.GetValue();

            DamageExporter damageExporter = _viDamageExporter?.GetValue() ?? _source as DamageExporter;
            if (damageExporter == null)
            {
                _LogError($"请联系策划【卡宝】, 该蓝图非技能orBuff图, 请在正确的蓝图里使用这个节点【创建打击盒 CastDamageBox】, graph.name:{_graphOwner.gameObject.name}, boxId:{boxId}");
                return;
            }
            
            damageExporter.CastDamageBox(null, boxId, _level, out _, OffsetAngle.GetValue(), OffsetPos.GetValue(), Duration.GetValue());
        }
    }
}
