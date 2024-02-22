using System.Collections.Generic;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("显隐角色模型子节点\nFASetActorsChildNodesVisible")]
    public class FASetActorsChildNodesVisible : FlowAction
    {
        private static int _hashCode { get; } = typeof(FASetActorsChildNodesVisible).GetHashCode();
        private List<Actor> _spwanActors = new List<Actor>(5);
        public BBParameter<int> spwanId = new BBParameter<int>();
        public BBParameter<Dictionary<string, bool>> pathActiveMap = new BBParameter<Dictionary<string, bool>>();
        private ValueInput<ActorList> _viActorList;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viActorList = AddValueInput<ActorList>("activeList");
        }

        protected override void _Invoke()
        {
            ActorList actorList = _viActorList?.GetValue();
            if (actorList == null || actorList.Count == 0)
            {
                _battle.actorMgr.GetActorBySpawnID(spwanId.GetValue(), _spwanActors);
            }
            else
            {
                _spwanActors.Clear();
                foreach (Actor actor in actorList)
                {
                    _spwanActors.Add(actor);
                }
            }

            if (_spwanActors.Count == 0)
            {
                if (_actor != null)
                {
                    _spwanActors.Add(_actor);
                }
                else
                {
                    return;
                }
            }

            Dictionary<string, bool> pathActives = pathActiveMap.GetValue();
            foreach (Actor actor in _spwanActors)
            {
                foreach (var pathActive in pathActives)
                {
                    actor.transform.AddModelChildVisible(_hashCode, pathActive.Key, pathActive.Value);
                }
            }
        }
    }
}