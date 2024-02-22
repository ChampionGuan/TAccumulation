using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("楚门专用, 设置角色位置\nFAPositionAndRotation")]
    public class FAPositionAndRotation : FlowAction
    {
        public BBParameter<Vector3> offset = new BBParameter<Vector3>();
        private ValueInput<Actor> _acotr1;
        private ValueInput<Actor> _acotr2;
        private ValueInput<DamageExporter> _viDamageExporter;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _acotr1 = AddValueInput<Actor>("Actor1");
            _acotr2 = AddValueInput<Actor>("Actor2");
            
            _viDamageExporter = AddValueInput<DamageExporter>(nameof(DamageExporter));
        }
        
        protected override void _Invoke()
        {
            var damageExporter = _viDamageExporter?.GetValue() ?? _source as DamageExporter;
            if (damageExporter == null)
            {
                _LogError($"请联系策划【楚门】, 该蓝图非技能orBuff图, 请在正确的蓝图里使用这个节点【楚门专用, 设置角色位置 FAPositionAndRotation】");
                return;
            }

            var actor = damageExporter.actor;
            if (actor == null)
            {
                return;
            }
            
            var actor1 = _acotr1.GetValue();
            var actor2 = _acotr2.GetValue();
            if (actor1 == null || actor2 == null)
            {
                return;
            }

            var zAxis = (actor2.transform.position - actor1.transform.position).normalized;
            var yAxis = Vector3.up;
            var xAxis = Vector3.Cross(yAxis, zAxis);

            var offsetParam = offset.value;
            var offsetValue = xAxis * offsetParam.x + yAxis * offsetParam.y + zAxis * offsetParam.z;
            var pos = actor1.transform.position + offsetValue;
            actor.transform.SetPosition(pos);

            var forward = (actor2.transform.position - pos).normalized;
            actor.transform.SetForward(forward);
        }
        
    }
}
