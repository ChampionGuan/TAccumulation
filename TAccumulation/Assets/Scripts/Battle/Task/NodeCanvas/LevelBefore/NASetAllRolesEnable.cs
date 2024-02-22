namespace X3Battle
{
    public class NASetAllRolesEnable : NALevelBeforeActionBase
    {
        public bool enabled;
        
        protected override void OnExecute()
        {
            _battle.SetActorsEnable(enabled);
            EndAction(true);
        }
    }
}
