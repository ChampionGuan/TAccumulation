using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("停止特效\nStopFx")]
    public class FAStopFx : FlowAction
    {
        private ValueInput<Actor> _viTarget;
        private ValueInput<int> _viFxID;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viTarget = AddValueInput<Actor>("Target");
            _viFxID = AddValueInput<int>("FxID");
        }
        protected override void _Invoke()
        {
            if (_viFxID == null)
            {
                _LogError("FA StopFx 没有特效ID");
                return;
            }
            if (_viTarget.value != null)
            {
                _viTarget.value.effectPlayer.StopFX(_viFxID.value);
            }
            else
            {
                _battle.fxMgr.StopFx(_viFxID.value, 0);
            }
        }
    }
}
