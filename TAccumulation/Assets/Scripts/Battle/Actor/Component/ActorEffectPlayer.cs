using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class ActorEffectPlayer : ActorComponent
    {
        private Transform _modelTf;

        private HashSet<string> _groupFxs;
        private HashSet<FxPlayer> _bodyFxs;

        private ShakeBone _hitShake;
        private Transform[] _shakeBones;

        private Action<EventScalerChange> _actionScalerChange;
        private Action<EventActorVisible> _actionActorVisible;

        public ActorEffectPlayer() : base(ActorComponentType.EffectPlayer)
        {
            _groupFxs = new HashSet<string>();
            _bodyFxs = new HashSet<FxPlayer>();
            _actionScalerChange = _OnScalerChange;
            _actionActorVisible = _OnActorVisible;
        }

        protected override void OnAwake()
        {
            _modelTf = actor.GetDummy(ActorDummyType.Model);
            _InitHurtShake();
        }

        public override void OnBorn()
        {
            _PlayCommonEffectFx();
            _PlayPerformGroupFx();
            battle.eventMgr.AddListener(EventType.OnScalerChange, _actionScalerChange, "ActorFx._OnScalerChange");
            actor.eventMgr.AddListener(EventType.ActorVisible, _actionActorVisible, "ActorFx._OnActorActive()");
        }

        public override void OnDead()
        {
            if (_hitShake != null) _hitShake.enabled = false;
            StopBodyFX();
            battle.eventMgr.RemoveListener(EventType.OnScalerChange, _actionScalerChange);
            actor.eventMgr.RemoveListener(EventType.ActorVisible, _actionActorVisible);
        }

        public override void OnRecycle()
        {
            _StopAllFx();
        }

        /// <summary>
        /// 播放组特效
        /// 此处不涉及皮肤特效替换
        /// </summary>
        public void PlayGroupFx(string groupName)
        {
            using (ProfilerDefine.ActorPlayGroupFxPMarker.Auto())
            {
                if (_groupFxs.Contains(groupName)) return;
                actor.battle.fxMgr.PlayGroupFx(actor.insID, groupName);
                _groupFxs.Add(groupName);
            }
        }

        /// <summary>
        /// 移除组特效
        /// </summary>
        public void StopGroupFx(string groupName)
        {
            if (!_groupFxs.Remove(groupName)) return;
            actor.battle.fxMgr.StopGroupFx(actor.insID, groupName);
        }

        /// <summary>
        /// 播放预警特效
        /// </summary>
        /// <param name="warnEffectData"></param>
        /// <returns></returns>
        public FxPlayer PlayWarnFx(WarnEffectData warnEffectData)
        {
            using (ProfilerDefine.ActorPlayWarnFxPMarker.Auto())
            {
                var warnFxCfg = BattleUtil.ConvertWarnFxCfg(warnEffectData);
                var fxObj = battle.fxMgr.PlayWarnFx(warnFxCfg, actor.insID, warnFxCfg.isFollow ? 1 : (int?)null, warnFxCfg.targetType);
                return fxObj;
            }
        }

        /// <summary>
        /// 停止预警特效
        /// </summary>
        /// <param name="fxObj"></param>
        public void StopWarnFx(FxPlayer fxObj)
        {
            StopFX(fxObj, true);
        }

        /// <summary>
        /// 参数说明详见FxMgr
        /// 特别说明，特效会根据皮肤进行替换
        /// </summary>
        /// <param name="creator">让此单位播放特效的施法者</param>
        /// <param name="isBodyFx">是否加入身体特效列表，会随着角色死亡调用结束</param>
        /// <returns></returns>
        public FxPlayer PlayFx(int fxID, Vector3? offsetPos = null, Vector3? angle = null, bool? isWorldParent = null,
            TargetType? targetType = TargetType.Skill, BattleResType resType = BattleResType.FX,
            int? isFollow = null, bool? isOnly = false, FxPlayer.TimeScaleType? timeScaleType = null,
            Actor creator = null, bool isBodyFx = false)
        {
            using (ProfilerDefine.ActorPlayFxPMarker.Auto())
            {
                // DONE: 特效ID皮肤替换.
                fxID = BattleUtil.GetFxIDBySkinID(creator?.bornCfg?.SkinID ?? actor.bornCfg.SkinID, fxID);
                var fxObj = battle.fxMgr.PlayBattleFx(fxID, actor.insID, offsetPos, angle, isWorldParent,
                    targetType, resType, isFollow, isOnly, timeScaleType);

                if (null == fxObj)
                    return null;

                if (fxObj.cfg.timeScaleType == FxPlayer.TimeScaleType.Actor)
                    fxObj.SetSpeed(actor.GetScaleData((int)ActorTimeScaleType.Witch).timeScale, FxPlayer.SpeedType.Actor);

                if (isBodyFx)
                    _bodyFxs.Add(fxObj);

                return fxObj;
            }
        }

        /// <summary>
        /// 参数说明详见FxMgr
        /// 特别说明，特效会根据皮肤进行替换
        /// </summary>
        /// <param name="creator">让此单位播放特效的施法者</param>
        public void StopFX(int fxID, bool isStopAndClear = false, Actor creator = null)
        {
            // DONE: 特效ID皮肤替换.
            fxID = BattleUtil.GetFxIDBySkinID(creator?.bornCfg?.SkinID ?? actor.bornCfg.SkinID, fxID);
            StopFX(battle.fxMgr.GetFx(actor.insID, fxID), isStopAndClear);
        }

        /// <summary>
        /// 停止特效播放
        /// </summary>
        public void StopFX(FxPlayer fx, bool isStopAndClear = false)
        {
            if (null == fx) return;
            if (_StopBodyFx(fx, isStopAndClear)) return;
            battle.fxMgr.StopFx(fx, isStopAndClear);
        }

        /// <summary>
        /// 停止身体特效
        /// </summary>
        /// <param name="isSkipEnd"></param>
        public void StopBodyFX(bool isSkipEnd = false)
        {
            foreach (var fx in _bodyFxs)
            {
                if (fx.cfg.isFollow == 1)
                    fx.SetParentNull();
                if (!_modelTf.gameObject.activeSelf) //隐藏对象不播End
                    isSkipEnd = true;
                fx.Stop(isSkipEnd);
            }

            _bodyFxs.Clear();
        }

        /// <summary>
        /// 播放抖动
        /// </summary>
        /// <param name="shakeDir"> 抖动方向</param>
        /// <param name="index">抖动强度（0，1，2）</param>
        public void PlayShake(Vector3 shakeDir, int index)
        {
            if (!_CheckShake()) return;
            _hitShake.enabled = true;
            _hitShake.StartShake(_hitShake.mainShakeAsset, index, shakeDir, _shakeBones);
        }

        /// <summary>
        /// 调用这个方法开始y轴抖动
        /// </summary>
        /// <param name="index"></param>
        public void PlayShake(int index)
        {
            if (!_CheckShake()) return;
            _hitShake.enabled = true;
            _hitShake.StartShake(_hitShake.mainShakeAsset, index, _shakeBones);
        }

        private bool _CheckShake()
        {
            if (_hitShake == null || _hitShake.mainShakeAsset == null)
            {
                return false;
            }

            return !actor.frozen.isFrozen;
        }

        private void _PlayCommonEffectFx()
        {
            var commonEffect = actor.createCfg.ModelCfg.CommonEffect;
            if (commonEffect == null || commonEffect.Count <= 0)
                return;
            foreach (var id in commonEffect)
            {
                PlayFx(id, isBodyFx: true);
            }
        }

        private void _PlayPerformGroupFx()
        {
            if (actor.modelInfo?.fxPerformGroups == null)
                return;
            foreach (var groupName in actor.modelInfo.fxPerformGroups.Keys)
            {
                if (actor.modelInfo.fxPerformGroups[groupName].defaultOpen)
                    PlayGroupFx(groupName);
            }
        }

        private bool _StopBodyFx(FxPlayer fx, bool isSkipEnd = false)
        {
            if (null == fx || !_bodyFxs.Remove(fx))
                return false;
            if (fx.cfg.isFollow == 1)
                fx.SetParentNull();
            fx.Stop(isSkipEnd);
            return false;
        }

        private void _StopAllFx()
        {
            foreach (var groupName in _groupFxs)
            {
                actor.battle.fxMgr.StopGroupFx(actor.insID, groupName);
            }

            foreach (var fxPlayer in _bodyFxs)
            {
                battle.fxMgr.StopFx(fxPlayer);
            }

            _groupFxs.Clear();
            _bodyFxs.Clear();
        }

        private void _OnScalerChange(EventScalerChange arg)
        {
            if (!(arg.timeScalerOwner is Battle))
                return;

            if (_hitShake != null)
            {
                _hitShake.timeScale = arg.timeScale;
            }
        }

        private void _OnActorVisible(EventActorVisible arg)
        {
            foreach (var fx in _bodyFxs)
            {
                if (fx.transform.parent == battle.root)
                {
                    fx.gameObject.SetVisible(arg.visible);
                }
            }
        }

        private void _InitHurtShake()
        {
            // 目前只有怪物会有受击抖动 by:sanxi 2023.7.19
            if (string.IsNullOrEmpty(actor.config.HurtInfo?.HurtShakeName)) return;

            var rootM = _modelTf.Find("Roots/Root_M");
            if (rootM == null) return;

            _hitShake = BattleUtil.EnsureComponent<ShakeBone>(rootM.gameObject);
            var shakeBoneAsset = BattleResMgr.Instance.Load<ShakeBoneAsset>(actor.config.HurtInfo.HurtShakeName, BattleResType.ShakeBone);
            if (shakeBoneAsset == null) return;

            _hitShake.mainShakeAsset = shakeBoneAsset;
            BattleResMgr.Instance.Unload(shakeBoneAsset);

            if (actor.roleCfg.HurtShakeBone == null || actor.roleCfg.HurtShakeBone.Length <= 0) return;
            _shakeBones = new Transform[actor.roleCfg.HurtShakeBone.Length];
            for (var i = 0; i < _shakeBones.Length; i++)
            {
                _shakeBones[i] = rootM.Find(actor.roleCfg.HurtShakeBone[i]);
            }
        }
    }
}