using System.Collections;
using System.Collections.Generic;
using BattleCurveAnimator;
using CollisionQuery;
using PapeGames;
using PapeGames.X3;
using Pathfinding;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Profiling;
using UnityEngine.Timeline;
using X3.Character;
using X3.SceneInfomation;

namespace X3Battle
{
    public class BattleMisc : BattleComponent
    {
        protected GameObject _ground;
        protected GameObject _pathfinderGo;
        protected GameObject _cameraCollider;
        protected GameObject _3DUICamera;
        protected VisiblePoolItem _sceneRootItem;
        private NavMeshData _altitudeMap;
        private Vector3 listenerPos = Vector3.zero;
        public CurveAnimAsset hitMatEffect { get; private set; }
        public AstarPath astarPath { get; private set; }
        public LookAtConfig lookAtCfg { get; private set; }
        public ModelInfoCommonAsset modelInfoCommon { get; private set; }
        public PhysicsWindConfigAsset physicsWindConfigAsset { get; private set; }

        public BattleMisc() : base(BattleComponentType.BattleMisc)
        {
        }

        protected override void OnAwake()
        {
            base.OnAwake();
            // CreateGround();
            LoadSceneMap();
            LoadSceneNavMesh();
            LoadSceneAltitudeMap();
            InitBattleCurveAnimator();
            LoadLookAtBlendSpace();
            LoadModelInfoCommonAsset();
            LoadCameraColliders();
            Load3DUICamera();
            var sceneRoot = Res.GetSceneRoot();
            _sceneRootItem = VisiblePoolTool.RecordPoolItem(sceneRoot);
            float[] poss = TbUtil.battleConsts.Listener3DPos;
            if (poss.Length >= 3)
            {
                listenerPos.Set(poss[0],poss[1],poss[2]);
            }
            WwiseEnvironment.OnEnableListerer(false);
            WwiseEnvironment.Create3DListener(listenerPos);
            physicsWindConfigAsset = BattleResMgr.Instance.Load<PhysicsWindConfigAsset>(BattleConst.PhysicsWindConfigName, BattleResType.PhysicsWindConfigAsset);
            
            if (!string.IsNullOrEmpty(TbUtil.battleConsts.MonsterHitEffectPath))
            {
                hitMatEffect = BattleResMgr.Instance.Load<CurveAnimAsset>(TbUtil.battleConsts.MonsterHitEffectPath, BattleResType.MatCurveAsset);
            }
            
        }

        public override void OnBattleBegin()
        {
            base.OnBattleBegin();
            BattleEnv.ClientBridge.PlayMusic(TbUtil.battleConsts.BGMEventName, battle.config.BackgroundMusic, TbUtil.battleConsts.BGMStateGroupName, true);
        }

        public override void OnBattleEnd()
        {
            base.OnBattleEnd();
            BattleEnv.LuaBridge.SetSoundMgrMode(true);
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            BattleResMgr.Instance.Unload(physicsWindConfigAsset);
            WwiseEnvironment.OnEnableListerer(true);
            WwiseEnvironment.Destroy3DListener();
            BattleUtil.DestroyObj(_ground);
            BattleResMgr.Instance.Unload(_pathfinderGo);
            BattleResMgr.Instance.Unload(_3DUICamera);
            WeaponBakeMeshUtility.DistoryBakedMesh(null);
            BattleEnv.LuaBridge.SetSoundMgrMode(true);
            if (DrawSoundsMap.s_SoundsMapAssets != null)
            {
                BattleResMgr.Instance.Unload(DrawSoundsMap.s_SoundsMapAssets);
                DrawSoundsMap.s_SoundsMapAssets = null;
            }
            if (lookAtCfg)
            {
                BattleResMgr.Instance.Unload(lookAtCfg);
                lookAtCfg = null;
            }
            if (modelInfoCommon)
            {
                BattleResMgr.Instance.Unload(modelInfoCommon);
                modelInfoCommon = null;
            }
            if(_cameraCollider)
            {
                BattleResMgr.Instance.Unload(_cameraCollider);
                _cameraCollider = null;
            }
            if (_altitudeMap)
            {
                HeightInquirer.UnloadCuurentNavMesh();
                BattleResMgr.Instance.Unload(_altitudeMap);
                _altitudeMap = null;
            }
            
            if (null != astarPath?.data)
            {
                astarPath.data.SetData(null);
                astarPath.data.OnDestroy();
                astarPath = null;
            }

            if (hitMatEffect != null)
            {
                BattleResMgr.Instance.Unload(hitMatEffect);
            }
            hitMatEffect = null;
        }

        private void LoadSceneMap()
        {
            string relativePath = BattleUtil.GetSceneMapRelativePath(battle.arg.levelID);
            if (!BattleResMgr.Instance.IsExists(relativePath, BattleResType.SceneMapData))
            {
                LogProxy.LogError($"【地图信息】加载失败,确认是否制作:{relativePath}");
                return;
            }

            DrawSoundsMap.s_SoundsMapAssets = BattleResMgr.Instance.Load<SoundsMapAssets>(relativePath, BattleResType.SceneMapData);
        }

        private void LoadSceneNavMesh()
        {
            var sceneName = BattleUtil.GetSceneName();
            //寻路数据
            var pathAsset = BattleResMgr.Instance.Load<TextAsset>(sceneName, BattleResType.ScenePathGraph);
            //可行走区域数据
            var walkAsset = BattleResMgr.Instance.Load<TextAsset>(sceneName + BattleUtil.Walk, BattleResType.ScenePathGraph);

            if (null == pathAsset || null == walkAsset)
            {
                 LogProxy.LogError($"【地图导航网格】加载失败，确认是否存在此场景:{BattleUtil.GetSceneName()}的NavMesh数据！！");
                 return;
            }

            using (ProfilerDefine.LoadSceneNavMesh.Auto())
            {
                _pathfinderGo = BattleResMgr.Instance.Load<GameObject>(BattleConst.PathfinderGoName, BattleResType.Misc);
                if (_pathfinderGo == null)
                {
                    return;
                }
                astarPath = _pathfinderGo.GetComponent<AstarPath>();
                astarPath.data.DeserializeGraphs(pathAsset.bytes);
                BattleResMgr.Instance.Unload(pathAsset);
                astarPath.data.DeserializeGraphsAdditive(walkAsset.bytes);
                BattleResMgr.Instance.Unload(walkAsset);

                //初始化边界边数据
                astarPath.data.InitBoundaryLine();
                //强制设置nearestSearchOnlyXZ
                var graphs = AstarPath.active.graphs;
                for (int i = 0; i < graphs.Length; i++) 
                {
                    var navmeshBase = graphs[i] as NavmeshBase;
                    if (navmeshBase != null) navmeshBase.nearestSearchOnlyXZ = true;
                }
            }
        }

        private void LoadSceneAltitudeMap()
        {
            var sceneName = BattleUtil.GetSceneName();
            //高度数据
            _altitudeMap = BattleResMgr.Instance.Load<NavMeshData>(sceneName, BattleResType.SceneAltitudeMap);
            if (null == _altitudeMap)
            {
                LogProxy.LogError($"【场景高度图】加载失败，确认是否存在此场景:{sceneName}的高度图数据！！");
                return;
            }
            HeightInquirer.LoadNavMesh(_altitudeMap);
        }
        
        public void SetSceneActive(bool isActive)
        {
            if (_sceneRootItem != null)
            {
                VisiblePoolTool.EnablePoolItemBehavioursByItem(_sceneRootItem, isActive);   
            }
        }

        private void InitBattleCurveAnimator()
        {
            if (TbUtil.battleConsts.TargetShaderName != null)
                BattleCurveAnimator.CurveAnimatorUtil.SetTargetShader(TbUtil.battleConsts.TargetShaderName);
            if (TbUtil.battleConsts.MatAnimIgnoreGo != null)
                BattleCurveAnimator.CurveAnimatorUtil.SetIgnoreGoName(TbUtil.battleConsts.MatAnimIgnoreGo);
        }

        private void LoadLookAtBlendSpace()
        {
            lookAtCfg = BattleResMgr.Instance.Load<LookAtConfig>(LookAtBehaviour.MONSTER_CONFIG_PATH, BattleResType.LookAtCfgAsset);
        }

        private void LoadModelInfoCommonAsset()
        {
            modelInfoCommon = BattleResMgr.Instance.Load<ModelInfoCommonAsset>(ModelInfoCommonAsset.ASSET_NAME, BattleResType.ModelInfoCommonAsset);
        }

        private void LoadCameraColliders()
        {
            var sceneName = BattleUtil.GetSceneName();
            foreach (var sceneCollider in TbUtil.battleSceneCameraColliders.Values)
            {
                if (sceneCollider.SceneName == sceneName)
                {
                    _cameraCollider = BattleResMgr.Instance.Load<GameObject>(sceneCollider.SceneCameraColliderName, BattleResType.CameraCollider);
                    _cameraCollider.transform.position = Vector3.zero;
                    break;
                }
            }
        }

        private void Load3DUICamera()
        {
            //3DUI - ppv不影响此相机
            _3DUICamera = BattleResMgr.Instance.Load<GameObject>("3DUICamera", BattleResType.Camera);
        }
    }
}
