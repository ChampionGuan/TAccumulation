using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("单位计时控制\nFAControlActorLifetime")]
    public class FAControlActorLifetime : FlowAction
    {
        public enum ControlLifeTimeMode
        {
            /// <summary> 暂停Lifetime的更新 </summary>
            Stop,
            /// <summary> 继续Lifetime的更新 </summary>
            Restart,
            /// <summary> 重置Lifetime的时长 </summary>
            Reset,
            /// <summary> 修改Lifetime的时长 </summary>
            Modify,
        }

        public ControlLifeTimeMode mode = ControlLifeTimeMode.Modify;

        [ShowIf(nameof(mode), (int)ControlLifeTimeMode.Modify)]
        public BBParameter<float> modifyValue = new BBParameter<float>(0.1f);
        
        private ValueInput<Actor> _viSourceActor;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viSourceActor = AddValueInput<Actor>("SourceActor");
        }

        protected override void _Invoke()
        {
            var actor = _viSourceActor.GetValue();
            if (actor == null)
            {
                _LogError("请联系策划【蜗牛君】,【单位计时控制 FAControlActorLifeTime】节点配置错误. 引脚[SourceActor]没有赋值.");
                return;
            }

            switch (mode)
            {
                case ControlLifeTimeMode.Stop:
                    actor.DisableLifetime(true);
                    break;
                case ControlLifeTimeMode.Restart:
                    actor.DisableLifetime(false);
                    break;
                case ControlLifeTimeMode.Reset:
                    actor.ResetLifetime();
                    break;
                case ControlLifeTimeMode.Modify:
                    var value = modifyValue.GetValue();
                    actor.ModifyLifetime(value);
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }
    }
}
