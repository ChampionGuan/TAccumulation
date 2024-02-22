using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("延长Actor上buff生命周期\nBuffAddLifeTime")]
    public class FAAddActorBuffLifeTime : FlowAction
    {
        [Name("时间")]
        public BBParameter<float> addLifeTime = new BBParameter<float>(0.1f);
        [Name("延时类型")]
        public FABuffAddLifeTime.ETimeAddType timeAddType;
        [Name("buffID")] 
        public int buffID;
        
        private ValueInput<Actor> _actorInput;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _actorInput = AddValueInput<Actor>(nameof(Actor));
        }

        protected override void _Invoke()
        {
            var actor = _actorInput.GetValue();
            if (actor == null)
            {
                _LogError("请联系策划,延长BUFF生命周期 BuffAddLifeTime 节点配置错误. 引脚[SourceAcTOR]没有赋值.");
                return;
            }
            var addValue = addLifeTime.GetValue();
            var buffList = ObjectPoolUtility.CommonBuffList.Get();
            actor.buffOwner?.GetBuffsByID(buffID, buffList);
            if (buffList.Count > 0)
            {
                foreach (var buff in buffList)
                {
                    switch (timeAddType)
                    {
                        case FABuffAddLifeTime.ETimeAddType.Accumulate:
                            buff.AddResidentTime(addValue);
                            break;
                        case FABuffAddLifeTime.ETimeAddType.Once:
                            buff.AddExtraTime(addValue);
                            break;
                        case FABuffAddLifeTime.ETimeAddType.Reset:
                            buff.SetResidentTime(addValue);
                            break;
                        default:
                            throw new ArgumentOutOfRangeException();
                    }
                }
            }
            ObjectPoolUtility.CommonBuffList.Release(buffList);
        }
    }
}