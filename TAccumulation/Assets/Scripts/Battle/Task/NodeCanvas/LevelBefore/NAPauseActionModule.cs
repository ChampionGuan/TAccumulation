using NodeCanvas.Framework;

namespace X3Battle
{
    public class NAPauseActionModule : BattleAction
    {
        public BBParameter<int> id = new BBParameter<int>();
        public BBParameter<bool> paused = new BBParameter<bool>();
        
        protected override void OnExecute()
        {
            Battle battle = Battle.Instance;
            battle.actorMgr.stage.sequencePlayer.PauseFlowCanvasModule(id.value, paused.value);
            battle.cameraTrace.SetEnable(!paused.value);
            EndAction(true);
        }
    }
}
