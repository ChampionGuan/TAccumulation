using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class TriggerHaloContext : TriggerContext, IGraphActorList
    {
        public override float deltaTime => halo.master.deltaTime;
        public override Transform parent => actor.GetDummy();

        public override object creater => halo;

        public Actor actor => halo.master;

        public Halo halo { get; }
        
        public List<Actor> actorList { get; } = new List<Actor>(5);
        public override NotionGraphEventMgr eventMgr { get; } = new NotionGraphEventMgr();

        public TriggerHaloContext(Halo halo) : base(halo.master.battle, level: halo.level)
        {
            this.halo = halo;
        }
    }
}