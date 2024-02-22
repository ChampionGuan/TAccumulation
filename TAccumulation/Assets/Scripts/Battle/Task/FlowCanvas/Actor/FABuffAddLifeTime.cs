using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("延长BUFF生命周期\nBuffAddLifeTime")]
    public class FABuffAddLifeTime : FlowAction
    {
        public enum ETimeAddType
        {
            Accumulate = 1,//常驻时区加值
            Once,//临时时区加值
            Reset,//常驻时区设置值
        }
        public BBParameter<float> addLifeTime = new BBParameter<float>(0.1f);
        
        private ValueInput<IBuff> _viSourcebuff;
        [Name("延时类型")]
        public ETimeAddType timeAddType;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();

            _viSourcebuff = AddValueInput<IBuff>("Sourcebuff");
        }

        protected override void _Invoke()
        {
            var buff = _viSourcebuff.GetValue();
            if (buff == null)
            {
                _LogError("请联系策划,延长BUFF生命周期 BuffAddLifeTime 节点配置错误. 引脚[Sourcebuff]没有赋值.");
                return;
            }

            if (buff.isDestroyed)
                return;

            var addValue = addLifeTime.GetValue();
            switch (timeAddType)
            {
                case ETimeAddType.Accumulate:
                    buff.AddResidentTime(addValue);
                    break;
                case ETimeAddType.Once:
                    buff.AddExtraTime(addValue);
                    break;
                case ETimeAddType.Reset:
                    buff.SetResidentTime(addValue);
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
 
        }
    }
}
