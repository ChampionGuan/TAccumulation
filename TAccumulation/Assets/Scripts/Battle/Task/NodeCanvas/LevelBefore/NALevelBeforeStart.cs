using System;
using UnityEngine;

namespace X3Battle
{
    public class NALevelBeforeStart: NALevelBeforeActionBase
    {
        private Action _cameraActionModuleAction;
        
        protected override void _OnGraphStart()
        {
            _cameraActionModuleAction = _CameraActionModuleFinish;
        }
        
        protected override void OnExecute()
        {
            var battle = Battle.Instance;
            var stageActor = battle.actorMgr.stage;
            
            // DONE: 去查找女主的出生配置点, 然后将关卡Actor设置过去.
            var pointConfig = battle.actorMgr.GetBornPointConfig(HeroType.Girl);
            if (pointConfig != null)
            {
                Vector3 targetPos = pointConfig.Position;
                Vector3 targetEuler = pointConfig.Rotation;
                stageActor.transform.SetPosition(targetPos);
                stageActor.transform.SetEulerAngles(targetEuler);
            }
            
            stageActor.sequencePlayer.CreateFlowCanvasModule(BattleConst.LevelBeforeCameraActionModuleId, true);
            battle.cameraTrace.SetCameraMode(CameraModeType.NotBattle);
            stageActor.sequencePlayer.PlayFlowCanvasModule(BattleConst.LevelBeforeCameraActionModuleId, _cameraActionModuleAction);
            
            EndAction(true);
        }
        
        private void _CameraActionModuleFinish()
        {
            _fsm?.TriggerEvent("PerformComplete");
        }
    }
}
