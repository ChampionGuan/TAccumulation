using PapeGames.X3;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;
using static FxPlayer;

namespace X3Battle
{
    public class FxMgr
    {
        protected class FxParam
        {
            public bool isPlay;
            public int cfgID;
            public int actorInsID = 0;
            public Vector3? pos = null;
            public Vector3? angle = null;
            public bool? isWorldParent = null;
            public TargetType? targetType = TargetType.Skill;
            public BattleResType resType = BattleResType.FX;
            public int? isFollow = null; 
            public bool? isOnly = false;
            public TimeScaleType? timeScaleType = null;
        }
        protected Transform _root;
        protected int _fxInsID = 10000;
        protected float _deltaTime => Battle.Instance != null ? Battle.Instance.deltaTime : Time.deltaTime;
        protected float _unscaledDeltaTime => Battle.Instance != null ? Battle.Instance.unscaledDeltaTime : Time.unscaledDeltaTime;

        //播放列表
        protected Dictionary<int, List<FxPlayer>> _actorFxs;//角色特效<actorInsID, List<Fx>>>
        protected Dictionary<int, FxParam> _requestFxs;//LatePlay特效<fxInsID, FxParam>
        protected Dictionary<int, Dictionary<string, List<FxPlayer>>> _actorGroupFxs;//组特效 <InsID, <groupName, List<List<Fx>>>>

        //缓存池
        private Stack<List<FxPlayer>> _tempListFxPlays;
        private Stack<Dictionary<string, List<FxPlayer>>> _tempDicFxPlayers;
        private Stack<FxParam> _tempFxParam;
        private int MaxPreloadNum = 20;

        public FxMgr(Transform root = null)
        {
            _root = root;
            FxSetting.root = root;
            FxSetting.warnTime = TbUtil.battleConsts.SkillWarnFxRemarkableTime;
            FxPlayerUtility.SetGoundHeightFunc(BattleUtil.GetGroundHeight);
            _actorFxs = new Dictionary<int, List<FxPlayer>>(MaxPreloadNum);
            _actorGroupFxs = new Dictionary<int, Dictionary<string, List<FxPlayer>>>(MaxPreloadNum);
            _requestFxs = new Dictionary<int, FxParam>(MaxPreloadNum);

            //缓存池
            _tempListFxPlays = new Stack<List<FxPlayer>>();
            for (int i = 0; i < MaxPreloadNum * 2; i++)
                _tempListFxPlays.Push(new List<FxPlayer>(MaxPreloadNum));
            _tempDicFxPlayers = new Stack<Dictionary<string, List<FxPlayer>>>();
            for (int i = 0; i < MaxPreloadNum; i++)
                _tempDicFxPlayers.Push(new Dictionary<string, List<FxPlayer>>(MaxPreloadNum));
            _tempFxParam = new Stack<FxParam>();
            for (int i = 0; i < MaxPreloadNum; i++)
                _tempFxParam.Push(new FxParam());

            if (Battle.Instance != null)
            {
                Battle.Instance.onPostPhysicalJobRunning.Add(OnLateUpdateTick);
                Battle.Instance.eventMgr.AddListener<EventScalerChange>(EventType.OnScalerChange, _OnTimeScaleChange, "FxMgr._OnTimeScaleChange");
            }
        }

        public void OnLateUpdateTick()
        {
            using (ProfilerDefine.FxMgrRequestPMarker.Auto())
            {
                foreach(var item in _requestFxs)
                {
                    var fxIns = item.Key;
                    var fxParam = item.Value;
                    if (fxParam.isPlay)
                    {
                        _PlayFx(fxParam.cfgID, fxParam.actorInsID, fxIns, fxParam.pos, fxParam.angle, fxParam.isWorldParent,
                            fxParam.targetType, fxParam.resType, fxParam.isFollow, fxParam.isOnly, fxParam.timeScaleType);
                    }
                    else
                    {
                        StopFx(fxIns);
                    }
                    _tempFxParam.Push(fxParam);
                }
                _requestFxs.Clear();
            }
            using (ProfilerDefine.FxMgrUpdatePMarker.Auto())
            {
                foreach (var fxs in _actorFxs.Values)
                {
                    for (int i = fxs.Count - 1; i >= 0; i--)
                    {
                        var fx = fxs[i];
                        if (fx == null) continue;
                        if (fx.cfg.fxType != FxType.Warn) //预警由timeline去驱动
                        {
                            if (fx.cfg.timeScaleType == TimeScaleType.UnScale)
                                fx.OnUpdate(_unscaledDeltaTime);
                            else
                                fx.OnUpdate(_deltaTime); //ActorSpeed通过*Speed实现
                        }

                        if (fx.IsDestroy)
                        {
                            _Unload(fx.gameObject);
                            fxs.RemoveAt(i);
                        }
                        else
                        {
                            fx.OnLateUpdateTick();
                        }
                    }
                }

                foreach (var actorGroupFx in _actorGroupFxs.Values)
                {
                    foreach (var group in actorGroupFx.Values)
                    {
                        bool allFinish = true;
                        foreach (var fx in group)
                        {
                            fx.OnUpdate(_deltaTime);
                            allFinish &= fx.IsDestroy;
                        }

                        if (allFinish)
                        {
                            foreach (var fx in group)
                                _Unload(fx.gameObject);
                            group.Clear();
                        }
                    }
                }
            }
        }

        /// 战斗播放特效接口 (换肤与时间缩放走Actor播放接口)
        /// <param name="cfgID">特效配置ID</param>
        /// <param name="actorInsID">特效所属单位实例化ID</param>
        /// <param name="time">8.21废弃不再支持覆盖时间,不定时长需用停止循环实现</param>
        /// <param name="offsetPos">覆盖配置 - 偏移位置</param>
        /// <param name="angle">覆盖配置 - 特效本身旋转角度</param>
        /// <param name="isWorldParent">覆盖配置 - 出生在世界父节点下</param>
        /// <param name="targetType">覆盖配置 - 目标类型</param>
        /// <param name="resType">资源类型</param>
        /// <param name="isFollow">覆盖配置 - 是否跟随</param>//TODO enum
        /// <param name="isOnly">仅播放一个,如果存在,重播</param>
        /// <param name="timeScaleType">是否跟随角色时间缩放</param>
        public FxPlayer PlayBattleFx(int cfgID, int actorInsID = 0,
            Vector3? offsetPos = null, Vector3? angle = null, bool? isWorldParent = null, 
            TargetType? targetType = TargetType.Skill, BattleResType resType = BattleResType.FX, 
            int? isFollow = null, bool? isOnly = false, TimeScaleType? timeScaleType = null)
        {
            return _PlayFx(cfgID, actorInsID, null, offsetPos, angle, isWorldParent, targetType, resType, isFollow, isOnly, timeScaleType);
        }

        /// LateUpdate播放特效
        /// <returns>FxInsID</returns>
        public int PlayBattleFxAsync(int cfgID, int actorInsID = 0,
            Vector3? pos = null, Vector3? angle = null, bool? isWorldParent = null,
            TargetType? targetType = TargetType.Skill, BattleResType resType = BattleResType.FX,
            int? isFollow = null, bool? isOnly = false, TimeScaleType? timeScaleType = null)
        {
            var fxParam = GetFxParam();
            fxParam.isPlay = true;
            fxParam.cfgID = cfgID;
            fxParam.actorInsID = actorInsID;
            fxParam.pos = pos;
            fxParam.angle = angle;
            fxParam.isWorldParent = isWorldParent;
            fxParam.targetType = targetType;
            fxParam.resType = resType;
            fxParam.isFollow = isFollow;
            fxParam.isOnly = isOnly;
            fxParam.timeScaleType = timeScaleType;

            var fxInsID = _fxInsID++;
            _requestFxs.Add(fxInsID, fxParam);
            return fxInsID;
        }

        private FxPlayer _PlayFx(int cfgID, int actorInsID = 0, int? fxInsID = null,
            Vector3? offsetPos = null, Vector3? angle = null, bool? isWorldParent = null,
            TargetType? targetType = TargetType.Skill, BattleResType resType = BattleResType.FX,
            int? isFollow = null, bool? isOnly = false, TimeScaleType? timeScaleType = null)
        {
            if (cfgID == 0)
                return null;
            var cfg = TbUtil.GetCfg<FXConfig>(cfgID);
            if (cfg == null)
            {
                LogProxy.LogError($"特效配置(id={cfgID})不存在!");
                return null;
            }

            if (isOnly.HasValue && isOnly.Value)
            {
                if (_actorFxs.TryGetValue(actorInsID, out var fxs))
                {
                    for (int i = fxs.Count - 1; i >= 0; i--)
                    {
                        var onlyFx = fxs[i];
                        if (onlyFx.cfg.cfgID == cfgID)
                        {
                            onlyFx.RePlay();
                            return onlyFx;
                        }
                    }
                }
            }

            if (cfg.IsFullPath == 1)
                resType = BattleResType.AllFX;
            
            FxPlayer fx = null;
            using (ProfilerDefine.FxMgrLoadFxPMarker.Auto())
            {
                fx = _LoadFxPlayer(cfg.PrefabName, resType);
                if (fx == null)
                    return null;
            }

            Transform parent = _GetBattleFxParent(actorInsID, cfg, isWorldParent, targetType);
            Vector3 setOffsetPos = Vector3.zero;
            if (offsetPos != null)
            {
                setOffsetPos = offsetPos.Value;
            }
            else
            {
                if (cfg.Offset.Length == 3)
                    setOffsetPos = new Vector3(cfg.Offset[0], cfg.Offset[1], cfg.Offset[2]);
                else if (cfg.Offset.Length != 0)
                    LogProxy.LogError($"FxConfig Offset配置错误 长度:{cfg.Rotation.Length}");
            }
            fx.SetIsGround(cfg.IsGround);
            Vector3 setAngle = Vector3.zero;
            if (angle != null)
            {
                setAngle = angle.Value;
            }
            else
            {
                if (cfg.Rotation.Length == 3)
                    setAngle = new Vector3(cfg.Rotation[0], cfg.Rotation[1], cfg.Rotation[2]);
                else if (cfg.Rotation.Length != 0)
                    LogProxy.LogError($"FxConfig Rotation配置错误 长度:{cfg.Rotation.Length}");
            }
            if (cfg.RandomRotateType == (int)BattleFXRandomRotateType.Random)//1不随机 2随机
            {
                setAngle += new Vector3(
                    Random.Range(-cfg.XAxisRandomAngel, cfg.XAxisRandomAngel),
                    Random.Range(-cfg.YAxisRandomAngel, cfg.YAxisRandomAngel),
                    Random.Range(-cfg.ZAxisRandomAngel, cfg.ZAxisRandomAngel));
            }
            Vector3 setScale = Vector3.one;
            if (cfg.Scale.Length == 3)
                setScale = new Vector3(cfg.Scale[0], cfg.Scale[1], cfg.Scale[2]);
            else if (cfg.Scale.Length != 0)
                LogProxy.LogError($"FxConfig Scale配置错误 长度:{cfg.Scale.Length}");

            var transfomr = fx.gameObject.transform;
            transfomr.localScale = setScale;//不跟随父节点大小
            transfomr.SetParent(parent);
            transfomr.localPosition = setOffsetPos;
            transfomr.localEulerAngles = setAngle;

            //增加特效自适应缩放处理
            ChangeScale(actorInsID, fx, cfg, targetType);

            int followType = isFollow.HasValue ? isFollow.Value : cfg.IsFollow;
            if (followType == (int)BattleFXFollowType.Not || followType == (int)BattleFXFollowType.PosOnly)
            {
                transfomr.SetParent(FxSetting.root);
            }

            var setFxInsID = fxInsID.HasValue ? fxInsID.Value : _fxInsID++;
            var timeScaleValue = timeScaleType.HasValue ? timeScaleType.Value : (TimeScaleType)cfg.TimeScaleType;
            fx.SetLogicFxData(cfgID, FxType.Normal, followType, setOffsetPos, parent, timeScaleValue, actorInsID, setFxInsID);
            fx.RePlay();

            if (!_actorFxs.ContainsKey(actorInsID))
                _actorFxs[actorInsID] = GetListFxPlayer();
            _actorFxs[actorInsID].Add(fx);
            LogProxy.LogFormat("[FxMgr] PlayBattleFx:cfgID={0},actorInsID:{1} ", cfgID, actorInsID);
            return fx;
        }

        public void StopBattleFxAsync(int fxInsID)
        {
            if (_requestFxs.ContainsKey(fxInsID))
            {
                _requestFxs[fxInsID].isPlay = false;
            }
            else
            {
                var fxParam = GetFxParam();
                fxParam.isPlay = false;
                _requestFxs.Add(fxInsID, fxParam);
            }
        }

        /// 自适应特效缩放
        private void ChangeScale(int insID, FxPlayer fx, FXConfig cfg, TargetType? targetType = TargetType.Lock)
        {
#if UNITY_EDITOR
            if (!Application.isPlaying)
                return;
#endif

            if (cfg.FxAdjust == 0)
                return;

            if (!_GetActorBodySize(insID, cfg, targetType.Value, out var sizeName, out var sizeNum))
            {
                fx.SetSize(TbUtil.battleConsts.FxConstSizeName, TbUtil.battleConsts.FxConstSizeNum);
                return;
            }

            fx.SetSize(sizeName, sizeNum);

            if (TbUtil.battleConsts.FxConstSizeNum == 0)
                return;
            float fxScale = sizeNum - TbUtil.battleConsts.FxConstSizeNum;
            if (fxScale == 0)
                return;

            fxScale /= 1000f;
            fx.transform.localScale = new Vector3(fx.transform.localScale.x + fxScale, fx.transform.localScale.y + fxScale, fx.transform.localScale.z + fxScale);
        }

        /// 获取特效挂载的对象的体型Name,Num
        private bool _GetActorBodySize(int insID, FXConfig cfg, TargetType targetType, out string sizeName, out int sizeNum)
        {
            //其余类型一并返回标准体型大小
            sizeName = TbUtil.battleConsts.FxConstSizeName;
            sizeNum = TbUtil.battleConsts.FxConstSizeNum;

            if (cfg.MountType != (int)MountType.Self && cfg.MountType != (int)MountType.Target)
                return false;

            var actor = Battle.Instance.actorMgr.GetActor(insID);
            if (actor == null)
                return false;

            if (cfg.MountType == (int)MountType.Target)
            {
                actor = actor.GetTarget(targetType);
            }

            //怪物返回怪物体型大小
            if (actor.type == ActorType.Monster)
            {
                sizeName = actor.roleCfg.FxSizeName;
                sizeNum = actor.roleCfg.FxSizeNum;
            }
            return true;
        }

        /// 特效组播放
        public void PlayGroupFx(int insID, string fxGroupName)
        {
            var actor = Battle.Instance.actorMgr.GetActor(insID);
            if (!_actorGroupFxs.ContainsKey(insID))
                _actorGroupFxs[insID] = GetDicFxPlayer();

            var groups = _actorGroupFxs[insID];
            if (!groups.ContainsKey(fxGroupName))
                groups[fxGroupName] = GetListFxPlayer();

            var group = groups[fxGroupName];

            if (actor.modelInfo.fxPerformGroups.TryGetValue(fxGroupName, out var groupConfig))
            {
                foreach (var perform in groupConfig.fxPerforms)
                {
                    Transform parent = actor.GetDummy(perform.dummyName);
                    if (string.IsNullOrEmpty(perform.fxPath))
                        continue;
                    var fx = _LoadFxPlayer(perform.fxPath, BattleResType.FX);
                    fx.transform.SetParent(parent);
                    fx.transform.localPosition= Vector3.zero;
                    fx.transform.localRotation = Quaternion.identity;
                    fx.transform.localScale = Vector3.one;
                    fx.RePlay();
                    fx.SetLogicFxData(-1, FxType.Normal, 1, Vector3.zero, parent, actorInsID: insID);
                    group.Add(fx);
                }
            }
        }

        /// 停止特效组
        public void StopGroupFx(int insID, string fxGroupName, bool stopAndClear = false)
        {
            if(_actorGroupFxs.TryGetValue(insID, out var groups))
            {
                if(groups.TryGetValue(fxGroupName, out var group))
                {
                    foreach(var fx in group)
                        fx.Stop(stopAndClear);
                }
            }
        }

        /// 播放预警特效,需要由外部驱动
        public FxPlayer PlayWarnFx(WarnFxCfg warnCfg, int insID, int? isFollow = null, TargetType? targetType = TargetType.Skill)
        {
            if (warnCfg.fxID == 0)
                return null;
            var fxCfg = TbUtil.GetCfg<FXConfig>(warnCfg.fxID);
            if (fxCfg == null)
            {
                LogProxy.LogError($"特效配置(id={warnCfg.fxID})不存在!");
                return null;
            }

            var fx = _LoadFxPlayer(fxCfg.PrefabName, BattleResType.FX);
            if (fx == null)
                return null;

            Transform parent = _GetBattleFxParent(insID, fxCfg, null, targetType);
			
			//Sub类型确定
            var subType = WarnForm.Progress;
            if (warnCfg.type == WarnType.Shine || warnCfg.type == WarnType.Lock || warnCfg.type == WarnType.Ray)
                subType = WarnForm.Normal;

            float setTime = warnCfg.duration;
            if (subType == WarnForm.Normal)//普通特效的预警 不随Clip时间变化
                setTime = fx.duration;
            Vector3 offsetPos = warnCfg.pos;
            Vector3 setAngle = warnCfg.angle;
            Vector3 setScale = Vector3.one;
            if (warnCfg.type == WarnType.Circle)
            {
                setScale.x = setScale.z = warnCfg.radius;
            }
            else if (warnCfg.type == WarnType.Sector)
            {
                setScale.x = setScale.z = warnCfg.radius;
            }
            fx.gameObject.transform.localScale = setScale;
            fx.gameObject.transform.SetParent(parent);
            fx.gameObject.transform.localPosition = offsetPos;
            fx.gameObject.transform.localEulerAngles = setAngle;

            int followType = isFollow.HasValue ? isFollow.Value : fxCfg.IsFollow;
            if (followType == (int)BattleFXFollowType.Not || followType == (int)BattleFXFollowType.PosOnly)
            {
                fx.gameObject.transform.SetParent(FxSetting.root);
            }
            fx.SetLogicFxData(warnCfg.fxID, FxType.Warn, followType, offsetPos, parent,  actorInsID: insID);
            fx.SetWarnData(setTime, (int)subType);
            fx.RePlay();

            if (subType == WarnForm.Progress)
            {
                var effect = fx.gameObject.GetComponentInChildren<PredictionEffect>();
                if (effect)
                {
                    if (warnCfg.type == WarnType.Sector)
                    {
                        effect.HalfAngle = warnCfg.centralAngle * (Mathf.PI / 360);
                    }
                    else if (warnCfg.type == WarnType.Rectangle)
                    {
                        effect.SizeOffset = new Vector4(warnCfg.width / 2f, warnCfg.length / 2f, 0, 0);
                    }
                    effect.Update();
                }
            }

            if (!_actorFxs.ContainsKey(insID))
                _actorFxs[insID] = GetListFxPlayer();
            _actorFxs[insID].Add(fx);
            return fx;
        }

        protected Transform _GetBattleFxParent(int insID, FXConfig cfg, bool? isWorldParent = null, TargetType? targetType = TargetType.Lock)
        {
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                if (isWorldParent.HasValue && isWorldParent.Value)
                {
                    return _root;
                }
                if (cfg.MountType == (int)MountType.Self)
                    return Timeline.Preview.TimelinePreviewTool.instance.GetDummy(cfg.DummyNodeName);
                else
                {
                    LogProxy.LogWarning("非运行时挂载不能找到target:" + ((MountType)cfg.MountType).ToString());
                    return _root;
                }
            }
#endif
            var parent = _root;
            if (isWorldParent.HasValue && isWorldParent.Value)
            {
                return _root;
            }
            if (cfg.MountType == (int)MountType.World)
            {
                return _root;
            }
            else
            {
                var actor = Battle.Instance.actorMgr.GetActor(insID);
                var dummyName = string.IsNullOrEmpty(cfg.DummyNodeName) ? ActorDummyType.Model : cfg.DummyNodeName;
                if (actor == null)
                {
                    return parent;
                }
                if (cfg.MountType == (int)MountType.Self)
                {
                    parent = actor.GetDummy(dummyName);
                }
                else if (cfg.MountType == (int)MountType.Target)
                {
                    var target = actor.GetTarget(targetType.Value);
                    if (target != null)
                    {
                        parent = target.GetDummy(dummyName);
                    }
                }
            }
            return parent;
        }

        /// 停止特效 此InsID的Actor的所有cfgID特效
        public void StopFx(int cfgID, int actorInsID, bool isStopAndClear = false)
        {
            if (!TbUtil.HasCfg<FXConfig>(cfgID))
            {
                LogProxy.LogError($"FxMgr.StopFx 特效配置(id={cfgID})不存在!");
                return;
            }
            if (!_actorFxs.TryGetValue(actorInsID, out var fxs))
                return;

            for (int i = fxs.Count - 1; i >= 0; i--)
            {
                var fx = fxs[i];
                if (fx.cfg.cfgID != cfgID) continue;

                fx.Stop(isStopAndClear);
                if (fx.IsDestroy)
                {
                    _Unload(fx.gameObject);
                    fxs.RemoveAt(i);
                }
            }
        }
        /// 停止特效 停止传入FxPlayer
        public void StopFx(FxPlayer fx, bool isStopAndClear = false)
        {
            // TODO 临时判空解决, 待长空考虑设计.
            if (_actorFxs == null)
            {
                return;
            }
            if (!_actorFxs.TryGetValue(fx.cfg.actorInsID, out var fxs))
                return;

            for (int i = fxs.Count - 1; i >= 0; i--)
            {
                if (fxs[i] != fx) continue;

                fx.Stop(isStopAndClear);
                if (fx.IsDestroy)
                {
                    _Unload(fx.gameObject);
                    fxs.RemoveAt(i);
                }
                return;
            }
        }
        /// 停止特效 特效实例:fxInsID
        public void StopFx(int fxInsID, bool isStopAndClear = false)
        {
            foreach (var allActorFxs in _actorFxs)
            {
                var actorFxs = allActorFxs.Value;
                for (int i = 0; i < actorFxs.Count; i++)
                {
                    var fx = actorFxs[i];
                    if (fx == null) continue;
                    if (fx.cfg.fxInsID != fxInsID) continue;

                    fx.Stop(isStopAndClear); 
                    if (fx.IsDestroy)
                    {
                        _Unload(fx.gameObject);
                        actorFxs.RemoveAt(i);
                    }
                    return;
                }
            }
        }

        /// 获取特效
        public FxPlayer GetFx(int actorInsID, int cfgID)
        {
            if (!TbUtil.HasCfg<FXConfig>(cfgID))
            {
                LogProxy.LogError($"FxMgr.StopFx 特效配置(id={cfgID})不存在!");
                return null;
            }
            if (!_actorFxs.TryGetValue(actorInsID, out var fxs))
                return null;

            for (int i = fxs.Count - 1; i >= 0; i--)
            {
                var fx = fxs[i];
                if (fx == null) continue;
                if (fx.cfg.cfgID != cfgID) continue;

                return fx;

            }
            return null;
        }

        public FxPlayer GetFx(int fxInsID)
        {
            foreach (var allActorFxs in _actorFxs)
            {
                var actorFxs = allActorFxs.Value;
                for (int i = 0; i < actorFxs.Count; i++)
                {
                    var fx = actorFxs[i];
                    if (fx == null) continue;
                    if (fx.cfg.fxInsID != fxInsID) continue;
                    return fx;
                }
            }
            return null;
        }

        public void OnDestroy()
        {
            DestroyAllFx();
            if (Battle.Instance != null)
            {
                Battle.Instance.onPostPhysicalJobRunning.Remove(OnLateUpdateTick);
                Battle.Instance.eventMgr.RemoveListener<EventScalerChange>(EventType.OnScalerChange, _OnTimeScaleChange);
            }
        }

        private void _OnTimeScaleChange(EventScalerChange arg)
        {
            if (!(arg.timeScalerOwner is Actor actor))
                return;

            foreach (var fxActor in _actorFxs)
            {
                if (fxActor.Key == actor.insID)
                {
                    for (int i = fxActor.Value.Count - 1; i >= 0; i--)
                    {
                        if (fxActor.Value[i].cfg.timeScaleType == TimeScaleType.Actor &&
                            arg.changeDatas.TryGetValue((int)ActorTimeScaleType.Witch, out var speed))
                        {
                            fxActor.Value[i].SetSpeed(speed, SpeedType.Actor);
                        }
                    }
                    break;
                }
            }
            foreach (var actorGroupFx in _actorGroupFxs)
            {
                if (actorGroupFx.Key == actor.insID)
                {
                    var groups = actorGroupFx.Value;
                    foreach (var group in groups.Values)
                    {
                        foreach (var fx in group)
                        {
                            if (fx.cfg.timeScaleType == TimeScaleType.Actor && 
                                arg.changeDatas.TryGetValue((int)ActorTimeScaleType.Witch, out var speed))
                            {
                                fx.SetSpeed(speed, SpeedType.Actor);
                            }
                        }
                    }
                    break;
                }
            }
        }
        
        /// <summary>
        /// 摧毁所有Fx
        /// </summary>
        public void DestroyAllFx()
        {
            foreach (var requestFx in _requestFxs)
            {
                _tempFxParam.Push(requestFx.Value);
            }
            _requestFxs.Clear();
            foreach (var actorFx in _actorFxs.Values)
            {
                foreach (var fx in actorFx)
                {
                    if (fx == null || fx.gameObject == null)
                    {
                        continue; // 不太符合预期，按道理讲不应该有外部摧毁FxMgr中管理的fx
                    }

                    fx.Stop(true);
                    _Unload(fx.gameObject);
                }
            }
            _actorFxs.Clear();
            foreach (var groupFx in _actorGroupFxs.Values)
            {
                foreach (var fxs in groupFx.Values)
                {
                    foreach (var fx in fxs)
                    {
                        fx.Stop(true);
                        _Unload(fx.gameObject);
                    }
                }
            }
            _actorGroupFxs.Clear();
        }

        private FxPlayer _LoadFxPlayer(string name, BattleResType resType)
        {
            FxPlayer fx = null;
            //Editor非运行时预览用
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                var fullPath = BattleUtil.GetResPath(name, resType);
                var go = Res.Load<GameObject>(fullPath, Res.AutoReleaseMode.GameObject);
                fx = go.GetComponent<FxPlayer>();
                fx.Init();
                return fx;
            }
#endif
            using (ProfilerDefine.FxMgrLoadFxPMarker.Auto())
            {
                fx = BattleResMgr.Instance.LoadFxPlayer(name, resType);
                return fx;
            }
        }

        private void _Unload(GameObject go)
        {
            //Editor非运行时预览用
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                GameObject.DestroyImmediate(go);
                return;
            }
#endif

            using (ProfilerDefine.FxMgrUnloadFxPMarker.Auto())
            {
                if (go != null)
                    BattleResMgr.Instance.Unload(go);
            }
        }

        private List<FxPlayer> GetListFxPlayer()
        {
            if (_tempListFxPlays.Count > 0)
            {
                return _tempListFxPlays.Pop();
            }
            return new List<FxPlayer>(MaxPreloadNum);
        }
        private Dictionary<string, List<FxPlayer>> GetDicFxPlayer()
        {
            if (_tempDicFxPlayers.Count > 0)
            {
                return _tempDicFxPlayers.Pop();
            }
            return new Dictionary<string, List<FxPlayer>>(MaxPreloadNum);
        }
        private FxParam GetFxParam()
        {
            if (_tempFxParam.Count > 0)
            {
                return _tempFxParam.Pop();
            }
            return new FxParam();
        }

    }
}