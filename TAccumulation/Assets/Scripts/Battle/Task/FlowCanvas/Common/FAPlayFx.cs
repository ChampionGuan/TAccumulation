using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("播放特效\nPlayFx")]
    public class FAPlayFx : FlowAction
    {
        public BBParameter<int> fxID = new BBParameter<int>();
        private ValueInput<Actor> _viTarget;
        //private ValueInput<bool> _isOverrideDuration;//8.21不在支持覆盖时间,且检查没有节点在用
        //private ValueInput<float> _duration;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viTarget = AddValueInput<Actor>("Target");
            //_isOverrideDuration = AddValueInput<bool>("Is Override Duration");
            //_duration = AddValueInput<float>("Duration");
        }
        protected override void _Invoke()
        {
            if(fxID == null)
            {
                _LogError("FA PlayFx 没有特效ID");
                return;
            }
            if(_viTarget.value != null)
            {
                _viTarget.value.effectPlayer.PlayFx(fxID.value);
            }
            else
            {
                _battle.fxMgr.PlayBattleFx(fxID.value);
            }
        }
    }
}
