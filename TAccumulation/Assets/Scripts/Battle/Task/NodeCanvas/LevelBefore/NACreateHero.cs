namespace X3Battle
{
    public class NACreateHero : NALevelBeforeActionBase
    {
        protected override void OnExecute()
        {
            Battle.Instance.actorMgr.CreateHero();
            EndAction(true);
        }
    }
}
