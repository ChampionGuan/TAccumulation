using UnityEngine;
using System.Collections.Generic;
using UnityEngine.Playables;
using X3.Character;
using Res = PapeGames.X3.Res;
using X3Debug = PapeGames.X3.X3Debug;
using X3Animator = X3Game.X3Animator;
using ISubsystem = X3.Character.ISubsystem;

namespace PapeGames.CutScene
{
    public class X3CutSceneManager
    {
        static List<string> s_AutoPauseList = new List<string>();
        private static readonly List<string> s_NeedPauseEventNameList = new List<string>(){"RedEventMarker", "PinkEventMarker"};

        #region Play, Pause, Resume, Stop
        /// <summary>
        /// 播放CutScene
        /// </summary>
        /// <param name="cutScenePrefab"></param>
        /// <param name="playMode"></param>
        /// <param name="wrapMode"></param>
        /// <param name="fromStart"></param>
        /// <param name="isDefualt"></param>
        /// <returns></returns>
        public static CtsHandle PlayX3(GameObject cutScenePrefab, CutScenePlayMode playMode, DirectorWrapMode wrapMode = DirectorWrapMode.None, 
            float initialTime = 0,  float endTime = 0, bool autoPause = false, Transform parent = null, int tag = 0,float crossfadeDuration = -1,
            Vector3 initialPos = default(Vector3), Vector3 initialRot = default(Vector3),
            bool isMuteAudio =false,bool isMuteLipsync =false)
        {
            if (cutScenePrefab == null)
                return CtsHandle.Invalid;
            var mgr = CutSceneManager.Instance;
            if (autoPause)
            {
                if (!s_AutoPauseList.Contains(cutScenePrefab.name))
                    s_AutoPauseList.Add(cutScenePrefab.name);
            }
            else
            {
                s_AutoPauseList.Remove(cutScenePrefab.name);
            }
            CutSceneManager.UnregisterEventCallback(AutoPauseHandler);
            CutSceneManager.RegisterEventCallback(AutoPauseHandler);
            return mgr.Play(cutScenePrefab, playMode, wrapMode, initialTime, endTime, cutScenePrefab.name, parent, tag, crossfadeDuration, initialPos, initialRot, isMuteAudio, isMuteLipsync);
        }

        public static void ReplaceInsPrefab(System.Action<string> onReplacePrefab, int tag = 0)
        {
            if (onReplacePrefab == null)
                return;
            var handle = CutSceneManager.Instance.GetCurrent(tag);
            if (handle.IsValid())
            {
                string ctsName = handle.CtsName;
                //重新加载一次，此意义是重新绑定一下资产的参考对象。
                var prefab = Res.Load<GameObject>(CutSceneCollector.GetPath(handle.CtsName));
                if (prefab == null)
                    X3Debug.LogErrorFormat("CtsMgr.ReplaceInsPrefab: 加载Cts({0})失败", handle.CtsName);
                
                float time = handle.Time;
                float endTime = handle.EndTime;
                var wrapMode = handle.WrapMode;
                Transform parent = handle.Parent;
                bool isActorPaused = handle.IsActorPaused();
                handle.Stop(true);
                onReplacePrefab?.Invoke(ctsName);
                CutSceneParticipant.Crossfadable = false;
                handle = CutSceneManager.Instance.Play(prefab, CutScenePlayMode.Break, wrapMode, time, endTime, ctsName, parent, tag);
                if (handle.IsValid() && prefab != null)
                {
                    Res.AddRefObj(prefab, handle.Ctrl);
                }
                if (isActorPaused)
                {
                    handle.Pause();
                }
                CutSceneParticipant.Crossfadable = true;
            }
            else
            {
                X3Debug.LogFormat("CtsMgr.ReplaceInsPrefab: no cts is playing");
                onReplacePrefab.Invoke(null);
            }
        }

        public static CtsHandle PlayX3(string cutSceneName, CutScenePlayMode playMode, DirectorWrapMode wrapMode = DirectorWrapMode.None, 
            float initialTime = 0, float endTime = 0, bool autoPause = false, Transform parent = null, int tag = 0, float crossfadeDuration = -1,
            Vector3 initialPos = default(Vector3), Vector3 initialRot = default(Vector3),
            bool isMuteAudio =false,bool isMuteLipsync =false)
        {
            if (string.IsNullOrEmpty(cutSceneName))
            {
                Debug.LogErrorFormat("CutSceneManager.PlayX3: CutScene name is null");
                return CtsHandle.Invalid;
            }

            string assetPath = CutSceneCollector.GetPath(cutSceneName);
            if(string.IsNullOrEmpty(assetPath))
            {
                X3Debug.LogErrorFormat("CutSceneManager.PlayX3: Find no path for cutSceneName:{0}", cutSceneName);
                return CtsHandle.Invalid;
            }

            var cutScenPrefab = Res.Load<GameObject>(assetPath, Res.AutoReleaseMode.EndOfFrame);
            if (cutScenPrefab == null)
            {
                X3Debug.LogErrorFormat("CutSceneManager.PlayX3: Load CutScene({0}) faild", assetPath);
                return CtsHandle.Invalid;
            }

            var handle = PlayX3(cutScenPrefab, playMode, wrapMode, initialTime, endTime, autoPause, parent, tag, crossfadeDuration, initialPos, initialRot, isMuteAudio, isMuteLipsync);
            if(handle.IsValid())
                Res.AddRefObj(cutScenPrefab, handle.Ctrl);
            return handle;
        }

        public static CtsHandle PlayFromX3Animator(string ctsName, int tag, CutScenePlayMode playMode, DirectorWrapMode wrapMode, float initialTime, float endTime, float crossfadeDuration, Transform parentTF, Vector3 initialPos = default(Vector3), Vector3 initialRot = default(Vector3))
        {
            if (string.IsNullOrEmpty(ctsName))
            {
                Debug.LogErrorFormat("CtsMgr.PlayFromX3Animator: Cutscene name is null");
                return CtsHandle.Invalid;
            }

            string assetPath = CutSceneCollector.GetPath(ctsName);
            if (string.IsNullOrEmpty(assetPath))
            {
                X3Debug.LogErrorFormat("CtsMgr.PlayFromX3Animator: Find no path for cutSceneName:{0}", ctsName);
                return CtsHandle.Invalid;
            }

            var ctsPrefab = Res.Load<GameObject>(assetPath, Res.AutoReleaseMode.EndOfFrame);
            if (ctsPrefab == null)
            {
                X3Debug.LogErrorFormat("CtsMgr.PlayFromX3Animator: Load CutScene({0}) failed", assetPath);
                return CtsHandle.Invalid;
            }
            
            CutSceneManager.UnregisterEventCallback(AutoPauseHandler);
            CutSceneManager.RegisterEventCallback(AutoPauseHandler);
            
            var handle = CutSceneManager.Instance.Play(ctsPrefab, playMode, wrapMode, initialTime, endTime, null,
                parentTF, tag, crossfadeDuration, initialPos, initialRot);
            if (handle.IsValid())
            {
                Res.AddRefObj(ctsPrefab, handle.Ctrl);
            }
            return handle;
        }
        

        /// <summary>
        /// 暂停
        /// </summary>
        /// <param name="playId"></param>
        /// <returns></returns>
        public static bool PauseX3(int playId, bool withIdle = true)
        {
            X3Animator x3Aniamtor = null; 
            if ((x3Aniamtor = X3Animator.CtsPlayItemOwner(playId)) != null)
                x3Aniamtor.Pause();
            else
                CutSceneManager.PauseWithPlayId(playId, withIdle);
            return true;
        }
        
        /// <summary>
        /// 恢复
        /// </summary>
        /// <param name="playId"></param>
        /// <returns></returns>
        public static bool ResumeX3(int playId, bool withIdle = true)
        {
            X3Animator x3Aniamtor = null; 
            if ((x3Aniamtor = X3Animator.CtsPlayItemOwner(playId)) != null)
                x3Aniamtor.Resume();
            else
                CutSceneManager.ResumeWithPlayId(playId, withIdle);
            return true;
        }
        #endregion

        public static void SetNeedPauseEventNameList(IList<string> list)
        {
            if (list == null)
                return;
            s_NeedPauseEventNameList.Clear();
            s_NeedPauseEventNameList.AddRange(list);
        }
        
        static void AutoPauseHandler(CutSceneEventData evtData)
        {
            if(evtData.EventType == CutSceneEventType.KeyFrame)
            {
                bool pauseEligible = false;
                CutSceneManager.EvtInfo e = (CutSceneManager.EvtInfo)evtData.Data;
                foreach (var eventName in s_NeedPauseEventNameList)
                {
                    if (e.EventName == eventName)
                    {
                        pauseEligible = true;
                        break;
                    }
                }
                //X3Debug.LogFormat("CutSceneManager.AutoPauseHandler1({0})", evtData.Name);
                if (!pauseEligible || !s_AutoPauseList.Contains(evtData.Name))
                    return;
                //X3Debug.LogFormat("CutSceneManager.AutoPauseHandler2({0})", evtData.Name);
                CutSceneManager.PauseWithPlayId(evtData.PlayId);
            }
        }

        /// <summary>
        /// 设置AssetIns在CutScene播放完后是否需要保持世界坐标的位置
        /// </summary>
        /// <param name="ins"></param>
        /// <param name="isStay"></param>
        /// <returns></returns>
        public static bool SetStayWorldPosition(GameObject ins, bool isStay)
        {
            if (ins == null)
                return false;
            var participent = ins.GetComponent<CutSceneParticipant>();
            if (participent == null)
                participent = ins.AddComponent<CutSceneActor>();
            participent.StayWorldPosition = isStay;
            return true;
        }

        public static void SetCutSceneSoundSpeed(float speed)
        {
            CutSceneAudioPlayableBehaviour.SetSpeed(speed);
            X3Debug.LogFormat("SetCutSceneSoundSpeed: {0}", speed);
        }
        
        public static bool EnablePhysicsCloth(int ctsPlayId, bool enable)
        {
            var ctsHandle = CutSceneManager.Instance.GetHandle(ctsPlayId);
            if (!ctsHandle.IsValid())
            {
                X3Debug.LogErrorFormat("Find no cutscene with playId: {0}", ctsPlayId);
                return false;
            }

            foreach (var insInfo in ctsHandle.Ctrl.AssetInsInfoList)
            {
                if (insInfo.Ins == null)
                    continue;
                var characterComp = insInfo.Ins.GetComponent<X3Character>();
                if (characterComp == null)
                    continue;
                characterComp.EnableSubsystem(ISubsystem.Type.PhysicsCloth, enable);
            }
            X3Debug.LogFormat("EnablePhysicsCloth: {0}, {1}, {2}", ctsPlayId, ctsHandle.Name, enable);
            return true;
        }

        public static GameObject GetAssetIns(int ctsPlayId, int assetId)
        {
            var ctsHandle = CutSceneManager.Instance.GetHandle(ctsPlayId);
            if (!ctsHandle.IsValid())
            {
                X3Debug.LogErrorFormat("Find no cutscene with playId: {0}", ctsPlayId);
                return null;
            }

            foreach (var insInfo in ctsHandle.Ctrl.AssetInsInfoList)
            {
                if (insInfo.AssetId == assetId && insInfo.Ins != null)
                {
                    return insInfo.Ins;
                }
            }

            return null;
        }
        
        public static GameObject GetAssetInsWithTag(int tag, int assetId)
        {
            var ctsHandle = CutSceneManager.Instance.GetHandleWithTag(tag);
            if (!ctsHandle.IsValid())
            {
                X3Debug.LogErrorFormat("Find no cutscene with tag: {0}", tag);
                return null;
            }

            foreach (var insInfo in ctsHandle.Ctrl.AssetInsInfoList)
            {
                if (insInfo.AssetId == assetId && insInfo.Ins != null)
                {
                    return insInfo.Ins;
                }
            }

            return null;
        }

        public static void SendEvent(string eventName, float value)
        {
            CutSceneCtrl.SendEvent(eventName,value);
        }

        static X3CutSceneManager()
        {
            CutSceneManager.SetDelegate(new X3CtsMgrDelegate());
        }
        
        private class X3CtsMgrDelegate : ICtsMgrDelegate
        {
            public void OnStopAll()
            {
                s_AutoPauseList.Clear();
            }
        }

        /// <summary>
        /// CutScene标签
        /// </summary>
        public enum Tag
        {
            Default = 0,
            MainUI,
            SpecialDate,
            Photo,
            Other
        }
    }
}