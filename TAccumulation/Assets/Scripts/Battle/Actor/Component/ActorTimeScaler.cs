using System;

namespace X3Battle
{
    public class ActorTimeScaler : TimeScaler, IActorComponent
    {
        private static int WitchTimeType = (int)ActorTimeScaleType.Witch;

        private Actor _actor;
        private float _ignoreWitchTick;

        public ActorTimeScaler(Actor actor) : base(actor, (int)ActorTimeScaleType.Num, (int)ActorComponentType.TimeScaler, _GetScaleInstance)
        {
            _actor = actor;
        }

        public void OnBorn()
        {
            SetDisable(WitchTimeType, false);
            _SyncMasterWitchTime(); 
        }

        public void OnDead()
        {
            SetDisable(WitchTimeType, true); 
        }

        public void OnRecycle()
        {
            _ignoreWitchTick = 0;
            Reset();
        }

        protected override void OnUpdate()
        {
            if (!_actor.isDead && _ignoreWitchTick > 0)
            {
                // 无视魔女缩放的时长受顿帧影响！！
                _ignoreWitchTick -= _actor.deltaTime;
                if (_ignoreWitchTick <= 0) SetWitchDisabled(false);
            }

            base.OnUpdate();
        }

        /// <summary>
        /// 设置某种类型的scale值
        /// </summary>
        public void SetScale(float timeScale, float? duration = null, int type = 0)
        {
            if (WitchTimeType == type)
            {
                base.SetScale(timeScale, duration, type, 0, TbUtil.battleConsts.ActorWitchScaleFadeoutDuration);
            }
            else
            {
                base.SetScale(timeScale, duration, type, 0, TbUtil.battleConsts.ActorBulletScaleFadeoutDuration);
            }
        }

        /// <summary>
        /// 设置魔女时间，与魔女设定
        /// </summary>
        public void SetWitchTime(float scale, float? duration, ActorWitchTimeSettings settings = null)
        {
            // XTBUG-29070 死亡后，不允许通过此接口设置魔女
            if (null == _actor || _actor.isDead) return;
            if (!(GetScaleData(WitchTimeType) is WitchTimeData data)) return;

            using (ProfilerDefine.ActorTimeScalerSetWitchTimePMarker.Auto())
            {
                // 进入魔女时，清一下这个单位的魔女禁用
                SetWitchDisabled(false);
                // 更新魔女设置
                data.RefreshSettings(settings);
                // 设置魔女缩放值
                SetScale(scale, duration, WitchTimeType);
            }
        }

        /// <summary>
        /// 设置魔女禁用
        /// </summary>
        public void SetWitchDisabled(bool disabled)
        {
            if (disabled)
            {
                _ignoreWitchTick = TbUtil.battleConsts.IgnoreWitchDuration;
                SetDisable(WitchTimeType, true);
            }
            else
            {
                _ignoreWitchTick = 0;
                SetDisable(WitchTimeType, false);
            }
        }

        /// <summary>
        /// 如果是魔女缩放改变
        /// </summary>
        protected override void _OnScaleChange()
        {
            // LogProxy.LogError($"{_actor.name} 时间缩放改变为： {scale}");
            if (!_changeDatas.TryGetValue(WitchTimeType, out var timeScale))
            {
                return;
            }

            using (ProfilerDefine.ActorTimeScalePauseActorSoundsPMarker.Auto())
            {
                if (timeScale == 1)
                {
                    Battle.Instance?.wwiseBattleManager.ResumeSoundActor(_actor.insID);
                    return;
                }

                if (GetScaleData(WitchTimeType) is WitchTimeData witchTime && witchTime.settings.pauseSoundForSelf)
                {
                    Battle.Instance?.wwiseBattleManager.PauseSoundActor(_actor.insID);
                }
            }
        }

        /// <summary>
        /// 时间缩放实例
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        private static ScaleData _GetScaleInstance(int type)
        {
            return type == WitchTimeType ? new WitchTimeData() : new ScaleData();
        }
        
        /// <summary>
        /// 依据父对象的魔女设定，调整自身魔女时间
        /// </summary>
        private void _SyncMasterWitchTime()
        {
            if (!(_actor.master?.GetScaleData(WitchTimeType) is WitchTimeData witchTime)) return;

            // 创生物
            if (_actor.IsCreature())
            {
                if (!witchTime.settings.syncCreatures)
                {
                    return;
                }
            }
            else
            {
                // 道具，法术场，子弹
                switch (_actor.type)
                {
                    case ActorType.Item when witchTime.settings.syncItems: break;
                    case ActorType.SkillAgent:
                        switch ((SkillAgentType)_actor.subType)
                        {
                            case SkillAgentType.Missile when witchTime.settings.syncBullets: break;
                            case SkillAgentType.MagicField when witchTime.settings.syncMagicFields: break;
                            default: return;
                        }

                        break;
                    default: return;
                }
            }

            var settings = ObjectPoolUtility.WitchTimeSettings.Get();
            settings.syncSelf = true;
            settings.pauseSoundForSelf = witchTime.settings.pauseSoundForSummon;
            SetWitchTime(witchTime.timeScaleForSummon, witchTime.leftTimeForSummon, settings);
            ObjectPoolUtility.WitchTimeSettings.Release(settings);
        }

        private class WitchTimeData : ScaleData
        {
            public float? endTimeForSummon { get; private set; }
            public float timeScaleForSummon { get; private set; } = 1;
            public float? leftTimeForSummon => endTimeForSummon - _currTime;
            public ActorWitchTimeSettings settings { get; } = new ActorWitchTimeSettings();

            public void RefreshSettings(ActorWitchTimeSettings settings)
            {
                if (null == settings)
                {
                    this.settings.Reset();
                }
                else
                {
                    this.settings.CopyFrom(settings);
                }
            }

            public override void SetValue(float tgtScale, float startTime, float? endTime, float fadeInDuration, float fadeOutDuration)
            {
                endTimeForSummon = endTime;
                timeScaleForSummon = tgtScale;
                if (settings.syncSelf)
                {
                    base.SetValue(tgtScale, startTime, endTime, fadeInDuration, fadeOutDuration);
                }
            }

            public override bool EvalScale(float currTime)
            {
                if (currTime > endTimeForSummon)
                {
                    _Reset();
                }

                return base.EvalScale(currTime);
            }

            public override void Reset()
            {
                _Reset();
                base.Reset();
            }

            private void _Reset()
            {
                timeScaleForSummon = 1;
                endTimeForSummon = null;
                settings.Reset();
            }
        }
    }
}