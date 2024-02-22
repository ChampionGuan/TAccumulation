namespace X3Battle
{
    public abstract class BaseMainState
    {
        public abstract ActorMainStateType stateType { get; } 
        
        protected ActorMainState _mainState;

        protected Actor _actor { get; }

        protected Battle _battle { get; }

        public BaseMainState(ActorMainState actorMainState)
        {
            this._mainState = actorMainState;
            this._actor = actorMainState.actor;
            this._battle = actorMainState.battle;
        }

        public void Init()
        {
            OnInit();
        }

        public void UnInit()
        {
            OnUnInit();
        }

        public void Enter()
        {
            OnEnter();
        }

        public void Update()
        {
            OnUpdate();
        }

        public void Exit(ActorMainStateType toStateType)
        {
            OnExit(toStateType);
        }

        protected virtual void OnEnter()
        {
            
        }

        protected virtual void OnUpdate()
        {
            
        }

        protected virtual void OnExit(ActorMainStateType toStateType)
        {
            
        }

        protected virtual void OnInit()
        {
            
        }

        protected virtual void OnUnInit()
        {
            
        }
    }
}