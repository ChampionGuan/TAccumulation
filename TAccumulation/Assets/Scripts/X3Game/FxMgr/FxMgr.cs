using System.Collections.Generic;
using JetBrains.Annotations;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;
using XLua;

namespace X3Game
{
    [MonoSingletonAttr(true, "X3Game.FxMgr")]
    [LuaCallCSharp]
    public class FxMgr : MonoSingleton<FxMgr>
    {
        private static bool logEnable = false;
        protected Dictionary<int, FxPlayer> _fxDic = new Dictionary<int, FxPlayer>();
        protected Dictionary<int, GameObject> _objDic = new Dictionary<int, GameObject>();
        private List<int> _deleteKeyList = new List<int>();
        private int _playID = 0;

        public void OnUpdate(float dt, float unscaledDT)
        {
            if (_fxDic == null) return;
            //接管fx的tick
            Profiler.BeginSample("FxMgr.Update()");
            foreach (var fxPair in _fxDic)
            {
                var fx = fxPair.Value;
                if (fx == null || fx.gameObject == null)
                {
                    _deleteKeyList.Add(fxPair.Key);
                    continue;
                }

                if (fx.cfg.timeScaleType == FxPlayer.TimeScaleType.UnScale)
                    fx.OnUpdate(Time.unscaledDeltaTime);
                else
                    fx.OnUpdate(Time.deltaTime);
                if (fx.IsDestroy)
                {
                    _Unload(fx.gameObject);
                    _deleteKeyList.Add(fxPair.Key);
                }
            }

            //清理
            if (_deleteKeyList.Count > 0)
            {
                foreach (var key in _deleteKeyList)
                {
                    _fxDic.Remove(key);
                }

                _deleteKeyList.Clear();
            }

            Profiler.EndSample();
        }

        public void OnLateUpdate()
        {
            foreach (var fxPair in _fxDic)
            {
                var fx = fxPair.Value;
                if (fx == null || fx.gameObject == null)
                {
                    continue;
                }

                fx.OnLateUpdateTick();
            }
        }

        #region public

        /// <summary>
        /// 播放fx
        /// </summary>
        /// <param name="fxPath">fx路径（全路径）</param>
        /// <param name="parent">父节点</param>
        /// <param name="fadeDuration"></param>
        /// <returns></returns>
        public int PlayFx(string fxPath, [CanBeNull] Transform parent, float fadeDuration)
        {
            var setScale = Vector3.one;
            var playID = GetPlayID();
            if (_fxDic.TryGetValue(playID, out var fx))
            {
                fx.Reinit();
                fx.SetLogicFxData(fx.gameObject.GetInstanceID(), FxPlayer.FxType.Normal, 1, Vector3.zero, parent,
                    FxPlayer.TimeScaleType.UnScale);
                if (parent)
                {
                    fx.transform.SetParent(parent, true);
                }

                fx.RePlay();
                if (fadeDuration == 0)
                {
                    fx.SetPlayTime(fx.startTime);
                }

                return playID;
            }

            var fxIns = Res.LoadGameObject(fxPath);
            if (fxIns == null)
            {
                if (logEnable)
                    LogProxy.LogError($"FxMgr fxPath no exit path:{fxPath}");
                return playID;
            }

            fxIns.SetActive(true);
            var tr = fxIns.transform;
            if (parent)
            {
                tr.SetParent(parent, false);
            }
            else
            {
                tr.SetParent(this.transform, false);
            }

            fx = fxIns.GetComponent<FxPlayer>();
            if (fx == null)
            {
                _objDic.Add(playID, fxIns);
                if (logEnable)
                    LogProxy.LogError($"FxMgr fxPath no exit path:{fxPath}");
                return playID;
            }

            fx.Init();
            tr.localScale = setScale;
            fx.SetLogicFxData(fx.gameObject.GetInstanceID(), FxPlayer.FxType.Normal, 1, Vector3.zero, parent,
                FxPlayer.TimeScaleType.UnScale);
            if (fadeDuration == 0)
            {
                fx.SetPlayTime(fx.startTime);
            }

            fx.Play();

            if (!_fxDic.ContainsKey(playID))
            {
                _fxDic.Add(playID, fx);
            }

            return playID;
        }

        /// <summary>
        /// stop
        /// </summary>
        /// <param name="playID"></param>
        /// <param name="fadeDuration"></param>
        public void StopFx(int playID, float fadeDuration)
        {
            if (_fxDic.TryGetValue(playID, out var fx))
            {
                fx.Stop(fadeDuration == 0);
            }

            if (_objDic.TryGetValue(playID, out var ins))
            {
                _Unload(ins);
                _objDic.Remove(playID);
            }
        }


        /// <summary>
        /// PlayFade
        /// </summary>
        /// <param name="playID"></param>
        /// <param name="fadeType"></param>
        /// <param name="fadeDuration"></param>
        public void PlayFade(int playID, FxPlayer.FadeType fadeType, float fadeDuration)
        {
            if (_fxDic.TryGetValue(playID, out var fx))
            {
                fx.PlayFade(fadeType, fadeDuration);
            }
        }

        /// <summary>
        /// 获取Fx
        /// </summary>
        /// <param name="playID"></param>
        /// <returns></returns>
        public FxPlayer GetFxPlayer(int playID)
        {
            if (_fxDic.TryGetValue(playID, out var fx))
            {
                return fx;
            }

            if (logEnable)
                LogProxy.LogError($"FxMgr not exit FxPlayer by playID {playID}");
            return null;
        }

        public GameObject GetFxGameObjIns(int playID)
        {
            if (_fxDic.TryGetValue(playID, out var fx))
            {
                return fx.gameObject;
            }

            if (_objDic.TryGetValue(playID, out var ins))
            {
                return ins;
            }

            if (logEnable)
                LogProxy.LogError($"FxMgr.GetFxGameObjIns  Invalid playID  {playID}");
            return null;
        }

        public void Clear()
        {
            foreach (var fxPlayer in _fxDic.Values)
            {
                fxPlayer.Stop(true);
                _Unload(fxPlayer.gameObject);
            }

            _fxDic.Clear();
            foreach (var ins in _objDic.Values)
            {
                _Unload(ins);
            }

            _objDic.Clear();
        }

        #endregion


        private void _Unload(GameObject go)
        {
            //Editor非运行时预览用
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                GameObject.DestroyImmediate(go);
                return;
            }
            else
            {
                Destroy(go);
                return;
            }
#endif

            Profiler.BeginSample("FxMgr.Unload");
            if (go != null)
            {
                Res.DiscardGameObject(go);
                go.SetActive(false);
            }

            Profiler.EndSample();
        }


        protected int GetPlayID()
        {
            return _playID++;
        }

        #region UnityEvent

        protected override void Init()
        {
            base.Init();
            if (_fxDic == null) _fxDic = new Dictionary<int, FxPlayer>();
            _fxDic.Clear();
            if (_objDic == null) _objDic = new Dictionary<int, GameObject>();
            _objDic.Clear();
            _playID = 0;
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            Clear();
        }

        #endregion
    }
}