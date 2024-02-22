using FlowCanvas;
using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("切换可激活状态\nInterActorChangeState")]
    public class FAInterActorChangeState : FlowAction
    {
        private ValueInput<int> _viInsId;
        public BBParameter<bool> IsEnable = new BBParameter<bool>();
        private int _insID;
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viInsId = AddValueInput<int>("InsID");
            
            AddValueOutput("insID", () => _insID);
        }
        
        protected override void _Invoke()
        {
            var actorMgr = Battle.Instance.actorMgr;
            if (actorMgr == null)
            {
                return;
            }

            if (_viInsId.value <= 0)
            {
                return;
            }
            var tempActor = actorMgr.GetActor(_viInsId.value);
            if (tempActor == null)
            {
                LogProxy.LogFormat("修改交互物状态失败 ID = {0}", _viInsId.value);
                return;
            }

            tempActor.interActorOwner?.Enable(IsEnable.value);
            _insID = tempActor.insID;
        }
    }
}
