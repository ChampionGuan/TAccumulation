using System;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("Actor筛选过滤开始\nFilterActorStart")]
    public class FEFilterActorStart : FlowEvent
    {
        private Action<NotionEventFilterActorStart> _actionFilterActor;
        private Actor _beFilterActor;

        public FEFilterActorStart()
        {
            _actionFilterActor = _OnFilterActorStart;
        }
        
        protected override void _RegisterEvent()
        {
            _eventMgr?.AddListener(NotionGraphEventType.FilterActorStart, _actionFilterActor, "FEFilterActorStart.FilterActor");
        }

        protected override void _UnRegisterEvent()
        {
            _beFilterActor = null;
            _eventMgr?.RemoveListener(NotionGraphEventType.FilterActorStart, _actionFilterActor);
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput(nameof(Actor), () => _beFilterActor);
        }

        private void _OnFilterActorStart(NotionEventFilterActorStart args)
        {
            if (args.beFilteredList == null || args.beFilteredList.Count <= 0)
            {
                return;
            }
            
            if (_context is IGraphActorList graphActorList)
            {
                graphActorList.actorList?.Clear();
            }

            foreach (Actor actor in args.beFilteredList)
            {
                _beFilterActor = actor;
                _Trigger();
            }
        }
    }
}