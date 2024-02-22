#if DEBUG_GM || UNITY_EDITOR
using System.Collections.Generic;
using Cinemachine;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle.Debugger
{
    public class CamerasParamDebugger
    {
        private const string DebugPath = @"Assets/Build/Res/Battle/Debug/";
        #region 调试器数据

        public List<X3VirtualCamera> listNormalBattleCameras = new List<X3VirtualCamera>(11);
        public List<X3VirtualCamera> listBossBattleCameras = new List<X3VirtualCamera>(11);

        public List<string> listNormalCamerasNames = new List<string>();
        public List<string> listBossCamerasNames = new List<string>();

        public int NormalCameraIndex = 0;
        public int BossCameraIndex = 0;

        #endregion

        public static CamerasParamDebugger Instance
        {
            get
            {
                if (null != _instance) return _instance;
                _instance = new CamerasParamDebugger();
                _instance.Init();
                return _instance;
            }
        }

        public void Init()
        {
            //默认第一个选项是固定的
            var normalObj = BattleResMgr.Instance.Load<GameObject>("TrackCameraSetting_NormalBattle", BattleResType.Camera, "TrackCameraSetting_NormalBattle");
            if (normalObj)
            {
                var normalCamera = normalObj.GetComponent<X3VirtualCamera>();
                listNormalBattleCameras.Add(normalCamera);
                if (string.IsNullOrEmpty(normalCamera.showName))
                {
                    listNormalCamerasNames.Add("TrackCameraSetting_NormalBattle");
                }
                else
                {
                    listNormalCamerasNames.Add(normalCamera.showName);
                }
            }
            
            //默认第一个选项是固定的
            var bossObj = BattleResMgr.Instance.Load<GameObject>("TrackCameraSetting_BossBattle", BattleResType.Camera, "TrackCameraSetting_BossBattle");
            if (bossObj)
            {
                var bossCamera = normalObj.GetComponent<X3VirtualCamera>();
                listBossBattleCameras.Add(bossCamera);
                if (string.IsNullOrEmpty(bossCamera.showName))
                {
                    listBossCamerasNames.Add("TrackCameraSetting_BossBattle");
                }
                else
                {
                    listBossCamerasNames.Add(bossCamera.showName);
                }
            }

            //自定义选项
            foreach (var name in TbUtil.battleConsts.CameraSettingNormal)
            {
                string fullName = DebugPath + name + ".prefab";
                var obj = Res.Load<GameObject>(fullName, Res.AutoReleaseMode.GameObject);
                if (obj == null)
                {
                    LogProxy.LogError($"缺少镜头配置预制体 {name}");
                    continue;
                }
                var camera = obj.GetComponent<X3VirtualCamera>();
                listNormalBattleCameras.Add(camera);
                if (string.IsNullOrEmpty(camera.showName))
                {
                    listNormalCamerasNames.Add(name);
                }
                else
                {
                    listNormalCamerasNames.Add(camera.showName);
                }
            }

            foreach (var name in TbUtil.battleConsts.CameraSettingBoss)
            {
                string fullName = DebugPath + name + ".prefab";
                var obj = Res.Load<GameObject>(fullName, Res.AutoReleaseMode.GameObject);
                if (obj == null)
                {
                    LogProxy.LogError($"缺少镜头配置预制体 {name}");
                    continue;
                }
                
                var camera = obj.GetComponent<X3VirtualCamera>();
                listBossBattleCameras.Add(camera);
                if (string.IsNullOrEmpty(camera.showName))
                {
                    listBossCamerasNames.Add(name);
                }
                else
                {
                    listBossCamerasNames.Add(camera.showName);
                }
            }
        }

        private static CamerasParamDebugger _instance;

        public void SetNormalCamera(int index)
        {
            if (index < listNormalBattleCameras.Count)
            {
                Battle.Instance.cameraTrace.SetCameraParam(listNormalBattleCameras[index],CameraModeType.Battle);
            }
        }

        public void SetBossCamera(int index)
        {
            if (index < listBossBattleCameras.Count)
            {
                Battle.Instance.cameraTrace.SetCameraParam(listBossBattleCameras[index],CameraModeType.BossBattle);
            }
        }
    }
}
#endif