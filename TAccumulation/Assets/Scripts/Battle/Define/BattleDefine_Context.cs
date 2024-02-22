using System;
using System.Collections.Generic;

namespace X3Battle
{
    public interface IBattleContext
    {
        Battle battle { get; }
    }

    public interface IActorContext
    {
        Actor actor { get; }
    }

    public interface IGraphCreater
    {
        object creater { get; }
    }
    
    public interface IGraphLevel
    {
        int level { get; }
    }

    public interface IGraphActorList
    {
        List<Actor> actorList { get; }
    }

    public class GraphContext
    { 
        public virtual NotionGraphEventMgr eventMgr { get; }
    }

    public class BattleContext : GraphContext, IBattleContext
    {
        public Battle battle { get; }

        public BattleContext(Battle battle)
        {
            this.battle = battle;
        }
    }

    public class ActorContext : BattleContext, IActorContext
    {
        public Actor actor { get; }

        public ActorContext(Actor actor) : base(actor.battle)
        {
            this.actor = actor;
        }
    }

    public class ActorCharacterContext : BattleContext, IActorContext
    {
        public LocomotionCtrl locomotionCtrl { get; private set; }

        public Actor actor { get; set; }

        public new Battle battle { get; set; }

        public ActorCharacterContext(LocomotionCtrl locomotionCtrl) : base(null)
        {
            this.locomotionCtrl = locomotionCtrl;
        }
    }

    public class ActorMainStateContext : ActorCharacterContext
    {
        private Action<ActorMainStateType, bool> _lockAction; // 设置标记的Callback.
        private Action<ActorAbnormalType> _abnormalAction; // 设置异常状态的Callback.

        public ActorMainStateContext(Actor actor, Action<ActorMainStateType, bool> lockAction, Action<ActorAbnormalType> abnormalAction) : base(actor?.locomotion)
        {
            this.actor = actor;
            this.battle = actor?.battle;
            this._lockAction = lockAction;
            this._abnormalAction = abnormalAction;
        }

        public void SetLock(ActorMainStateType toStateType, bool isLock)
        {
            this._lockAction?.Invoke(toStateType, isLock);
        }

        public void SetAbnormalType(ActorAbnormalType toAbnormalType)
        {
            this._abnormalAction?.Invoke(toAbnormalType);
        }
    }
}