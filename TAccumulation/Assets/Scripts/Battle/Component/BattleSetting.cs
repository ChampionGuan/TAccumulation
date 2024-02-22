namespace X3Battle
{
    public class BattleSetting : BattleComponent
    {
        public TargetLockModeType lockModeType { get; private set; }
        public bool lockBtnActive { get; private set; }
        
        public BattleSetting() : base(BattleComponentType.BattleSetting)
        {
        }

        protected override void OnAwake()
        {
            lockModeType = TargetLockModeType.Smart; // battle.arg.startedLockMode;
            lockBtnActive = false; //battle.arg.startedLockBtnActive;
        }

        public void SetLockModeType(TargetLockModeType lockModeType)
        {
            this.lockModeType = lockModeType;
        }

        public void SetLockBtnActive(bool lockBtnActive)
        {
            this.lockBtnActive = lockBtnActive;
        }
    }
}