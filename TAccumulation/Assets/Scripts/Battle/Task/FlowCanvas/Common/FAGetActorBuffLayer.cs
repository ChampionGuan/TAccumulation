using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("获取Actor上某个Buff的层数\nFAGetActorBuffLayer")]
    public class FAGetActorBuffLayer : FlowAction
    {
        public int buffID;
        private ValueInput<Actor> _actorInput;
        
        protected override void _OnRegisterPorts()
        {
            _actorInput = AddValueInput<Actor>(nameof(Actor));
            AddValueOutput<int>("buff层数", _GetBuffLayer);
        }
        
        private int _GetBuffLayer()
        {
            var actor = _actorInput?.GetValue();
            if (actor == null)
            {
                _LogError("获取Buff层数节点，传入的Actor为空！请联系【楚门】");
                return 0;
            }

            var buffLayer = actor.buffOwner?.GetLayerByID(buffID);
            if (buffLayer == null)
            {
                _LogError("获取Buff层数节点，buffID为空，或不可取层数，请联系【楚门】");
                return 0;
            }
            else
            {
                return buffLayer.Value;
            }
        }
    }
}