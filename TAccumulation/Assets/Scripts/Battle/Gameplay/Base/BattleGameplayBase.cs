using System;

namespace X3Battle
{
    public abstract class BattleGameplayBase : BattleComponent
    {
        public abstract LevelFlowBase levelFlow { get; }

        protected BattleGameplayBase() : base(BattleComponentType.Gameplay)
        {
        }

        public void Preload()
        {
            OnPreload();
            levelFlow.Preload();
        }

        public void StartupFinished()
        {
            levelFlow.StartupFinished();
        }
        
        protected override void OnAwake()
        {
            levelFlow.Awake();
        }

        protected override void OnDestroy()
        {
            levelFlow.Destroy();
        }

        protected virtual void OnPreload()
        {
            
        }

        public override void OnBattleBegin()
        {
            levelFlow.BattleBegin();
        }
        
        public override void OnBattleEnd()
        {
            levelFlow.BattleEnd();
        }
        
        protected override void OnUpdate()
        {
            levelFlow.Update();
        }
    }
}