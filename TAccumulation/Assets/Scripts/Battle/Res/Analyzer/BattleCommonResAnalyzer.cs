using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    public class BattleCommonResAnalyzer : ResAnalyzer
    {
        public override int ResID => 0;
        
        public BattleCommonResAnalyzer(ResModule parent) : base(parent)
        {

        }

        protected override void DirectAnalyze()
        {
            // TODO @长空 统一整理初始化时机.
            zstring.Init();
            
            // 战斗全局黑板.
            resModule.AddResultByPath(BattleConst.BattleGlobalBlackboard, BattleResType.GlobalBlackboard);
            AnalyzeFromLoadedRes<GameObject>(BattleConst.BattleGlobalBlackboard, BattleResType.GlobalBlackboard, _AnalyzerGlobalBlackboard, resModule);
            
            // 关卡前流程
            resModule.AddResultByPath(BattleConst.LevelBeforeFsmName, BattleResType.Fsm);

            // 分析相机
            //镜头预设
            resModule.AddResultByPath(CameraTrace.battleTrackCameraName, BattleResType.Camera);
            resModule.AddResultByPath(CameraTrace.camearModes[(int)CameraModeType.Battle], BattleResType.Camera);
            resModule.AddResultByPath(CameraTrace.camearModes[(int)CameraModeType.FreeLook], BattleResType.Camera);
            resModule.AddResultByPath(CameraTrace.camearModes[(int)CameraModeType.NotBattle], BattleResType.Camera);
            resModule.AddResultByPath(CameraTrace.camearModes[(int)CameraModeType.BossBattle], BattleResType.Camera);
            resModule.AddResultByPath(CameraTrace.camearModes[(int)CameraModeType.StartBattle], BattleResType.Camera);
            resModule.AddResultByPath(CameraTrace.camearModes[(int)CameraModeType.BoyDead], BattleResType.Camera);
            resModule.AddResultByPath(CameraTrace.fpsCameraName, BattleResType.Camera);
            //镜头动画控制器
            resModule.AddResultByPath("CameraPostProcess", BattleResType.CameraAnimatorController);
            //3DUI Camera
            resModule.AddResultByPath("3DUICamera", BattleResType.Camera);

            // 镜头blendSetting
            resModule.AddResultByPath(CameraTrace.blendSettingName, BattleResType.CameraAsset);
            //Lookat
            resModule.AddResultByPath(LookAtBehaviour.MONSTER_CONFIG_PATH, BattleResType.LookAtCfgAsset);
            //ModelInfo
            resModule.AddResultByPath(ModelInfoCommonAsset.ASSET_NAME, BattleResType.ModelInfoCommonAsset);

            // 风场配置文件
            resModule.AddResultByPath(BattleConst.PhysicsWindConfigName, BattleResType.PhysicsWindConfigAsset);

            // 关卡技能分析
            resModule.AddConditionAnalyze(new StageSkillAnalyze());
            
            // battleConst中配置的固定buff
            ResAnalyzeUtil.AnalyzeBuff(resModule, TbUtil.battleConsts.BoyActiveSkillTauntBuffID);
        }
        
        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is BattleCommonResAnalyzer)
            {
                return true;
            }
            return false;
        }

        private void _AnalyzerGlobalBlackboard(GameObject go, ResModule resModule)
        {
            if (go != null)
            {
                var globalBlackboard = go.GetComponent<GlobalBlackboard>();
                if (globalBlackboard)
                {
                    ResAnalyzeUtil.AnalyzeBlackboard(resModule, globalBlackboard);
                }
            }
        }
    }
}