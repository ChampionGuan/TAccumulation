using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Condition")]
    [Name("检测ActorStateTag\nCheckActorStateTag")]
    public class FCCheckActorStateTag : FlowCondition
    {
        public BBParameter<ActorStateTagType> stateTag = new BBParameter<ActorStateTagType>();
        
        private ValueInput<Actor> _viSourceActor;

        protected override void _OnAddPorts()
        {
            _viSourceActor = AddValueInput<Actor>("SourceActor");
        }

        protected override bool _IsMeetCondition()
        {
            if (_viSourceActor == null)
            {
                return false;
            }

            var actor = _viSourceActor.GetValue();
            if (actor == null)
            {
                _LogError("请联系策划【卡宝】, 【检测ActorStateTag CheckActorStateTag】节点 【SourceActor】参数配置不合法");
                return false;
            }
            
            if (actor.stateTag == null)
            {
                _LogError($"请联系策划【卡宝】, 【检测ActorStateTag CheckActorStateTag】节点 【SourceActor】{actor.name} 没有ActorStateTag组件");
                return false;
            }

            var stateTagType = stateTag.GetValue();
            if (!actor.stateTag.IsActive(stateTagType))
            {
                return false;
            }

            return true;
        }
    }
}
