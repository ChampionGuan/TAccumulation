using FlowCanvas;
using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("创建交互物\nCreateInterActor")]
    public class FACreateInterActor : FlowAction
    {
        private ValueInput<int> _viInterActorId;//覆盖InterActorID
        public BBParameter<int> GroupId = new BBParameter<int>();
        public BBParameter<int> Tag = new BBParameter<int>();
        [Name("SpawnID")]
        public BBParameter<int> InterActorId = new BBParameter<int>();
        private Actor _target;
        private int _InsID;
        
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viInterActorId = AddValueInput<int>("InterActorId");
            
            AddValueOutput("Target", () => _target);
            AddValueOutput("InsID", () => _InsID);
        }
        
        protected override void _Invoke()
        {
            if (Battle.Instance.actorMgr == null)
            {
                return;
            }

            var actorMgr = Battle.Instance.actorMgr;
            Actor tempActor = null; 
            if (GroupId.value != 0)
            {
                foreach (var stageConfigInterActor in actorMgr.stageConfig.InterActors)
                {
                    if(stageConfigInterActor.GroupID != GroupId.value) continue;
                    tempActor = actorMgr.CreateInterActor(stageConfigInterActor.ID);
                }
            }
            else if (Tag.value != 0)
            {
                foreach (var stageConfigInterActor in actorMgr.stageConfig.InterActors)
                {
                    if(stageConfigInterActor.Tag != Tag.value) continue;
                    tempActor = actorMgr.CreateInterActor(stageConfigInterActor.ID, _viInterActorId.value);
                }
            }
            else if (InterActorId.value != 0)
            {
                tempActor = actorMgr.CreateInterActor(InterActorId.value, _viInterActorId.value);
            }

            if (tempActor == null)
            {
                _LogError("创建交互物失败");
                return;
            }

            _target = tempActor;
            _InsID = tempActor.insID;
        }
    }
}
