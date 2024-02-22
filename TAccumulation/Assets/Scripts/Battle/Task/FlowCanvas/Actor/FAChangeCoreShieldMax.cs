﻿using ParadoxNotion.Design;
using FlowCanvas;
using X3Battle;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("修改芯核护盾上限值\nChangeCoreShieldMax")]
    public class FAChangeCoreShieldMax : FlowAction
    {
        public BBParameter<ModifyShieldType> modifyType = new BBParameter<ModifyShieldType>();
        private ValueInput<Actor> _viSourceActor;
        private ValueInput<float> _viValue;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viSourceActor = AddValueInput<Actor>("actor");
            _viValue = AddValueInput<float>("value");
        }

        protected override void _Invoke()
        {
            var actor = _viSourceActor.GetValue();
            if(actor == null)
            {
                _LogError($"请联系策划【路浩】,【修改芯核护盾最大值】节点配置错误. 引脚【actor】{actor.name}为空.");
                return;
            }
            if (actor.actorWeak == null)
            {
                _LogError($"请联系策划【路浩】,【修改芯核护盾最大值】节点配置错误. 引脚【actor】{actor.name}没有虚弱组件.");
                return;
            }

            actor.actorWeak.ModifyShieldMax(_viValue.GetValue(), modifyType.GetValue());
        }
    }
}
