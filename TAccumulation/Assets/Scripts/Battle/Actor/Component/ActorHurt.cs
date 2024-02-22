using System;
using UnityEngine;
using System.Collections.Generic;
using EasyCharacterMovement;
using PapeGames.X3;
using UnityEngine.Profiling;
using X3.PlayableAnimator;

namespace X3Battle
{
    public class ActorHurt : ActorComponent
    {
        private enum VibrateType
        {
            Low=0,
            Medium,
            High,
            Num,
        }
        public HurtDirection hurtDirection { get; private set; }
        public float backSpeed { get; private set; }
        public float heightSpeed { get; private set; }
        /// <summary>
        /// 竖直方向阻力加速度
        /// </summary>
        public float heightResistance { get; private set; }
        public HurtType hurtType { get; private set; } // 当前受到的来自攻击者的受击类型
        public int hurtStateType { get; private set; } // 最终的受击类型
        public bool isHurt { get; private set; }
        public bool isHurtBack { get; private set; } // 是否击退过程中
        public bool isHurtFly { get; private set; } // 是否在击飞过程中
        public bool isLying { get; private set; }
        public float layDownTime { get; private set; }

        public float hurtProtectTime { get; private set; }
        public float hurtProtectPeriod { get; private set; }
        public float hurtProtectValue { get; private set; }
        public float hurtProtectDelayTime { get; private set; }

        public HurtInterruptController hurtInterruptController { get; private set; }//受击的打断控制器
        public bool isRising { get => isHurtFly && null != verticalCurve && _curHurtTime < TbUtil.battleConsts.HurtFlyProtectTime; } // 是否处于击飞上升阶段
        public float toughness => _toughness;
        public float hurtAddWeight;

        private DamageBoxCfg _config;

        public Vector3 vecHurtDir;
        public Vector3 vecFaceDir;

        public Vector3 formerFaceDir;
        private float _curHeight;

        private Vector3 _curPos;

        private float _curHurtTime; // 进入击飞\击浮空状态的时间

        private float _toughness; // 抗攻击等级
        private AnimationCurve verticalCurve;
        private AnimationCurve horizonalCurve;
        private float _hurtBackRatio;
        private float _hurtHeightRatio;
        private List<string[]> _hurtAnims;

        private float _vibrateCD = 0; // 受击震动CD
        private float _hurtAdditiveCD = 0; // 叠加受击CD

        private float _hurtBackDis;
        private float _hurtBackTotalDis;
        private float _hurtBackSpeed;
        private float _hurtBackDivisor = 1;
        private float _hurtFloatDivisor = 1;
        private float _hurtFlyDivisor = 1;

        private float _hurtDirectionOffset = Mathf.Cos(45f * Mathf.Deg2Rad); // 用于判断受击方向的阈值（怪物用）
        private float _playerHurtDirectionOffset = Mathf.Cos(135f * Mathf.Deg2Rad); // 判断受击方向的阈值（玩家用）


        private int _hurtTypeID;
        private HurtMaterialType _hurtMaterialType = HurtMaterialType.Default;
        private int _layDownHurtCount; // 倒地状态下受击次数计数
        private int _hurtAddAnimLayerIndex = -1;

        private Action<EventOnSwitchMoveMode> _actionSwitchMoveMode;
        private Action<int, StateNotifyType, string> _actionOnAnimStateChange;
        private Action<bool, ActorMainState.IArg> _setAbnormalCallback;
        private HurtTryAbnormalArg _hurtTryAbnormalArg = new HurtTryAbnormalArg();

        public ActorHurt() : base(ActorComponentType.Hurt)
        {
            backSpeed = 0;
            heightSpeed = 0;
            heightResistance = 0;
            requiredAnimationJobRunning = true;
            layDownTime = 0;
            _hurtTypeID = 1;
            hurtInterruptController = new HurtInterruptController();
            _actionSwitchMoveMode = _OnExitMode;
            _actionOnAnimStateChange = OnAnimStateChange;
            _setAbnormalCallback = _SetAbnormalCallback;
        }

        public override void OnBorn()
        {
            hurtStateType = 0;
            if (actor.IsGirl())
            {
                int weaponSkinID = actor.battle.arg.girlWeaponID;
                var weaponLogicConfig = TbUtil.GetWeaponLogicConfigBySkinId(weaponSkinID);
                _toughness = weaponLogicConfig.Toughness;
                _hurtTypeID = weaponLogicConfig.HurtType;
                _hurtAnims = HurtStateAnimName.HeroNormalHurt;
            }
            else if (actor.IsBoy())
            {
                _toughness = actor.config.HurtInfo.Toughness;
                _hurtTypeID = actor.config.HurtInfo.HurtTypeID;
                _hurtAnims = HurtStateAnimName.HeroNormalHurt;
            }
            else
            {
                _hurtAnims = HurtStateAnimName.MobNormalHurt;
                if (actor.IsMonster() && actor.monsterCfg.EquipShield == (int)CoreType.Elite)
                {
                    _toughness = TbUtil.battleConsts.ShieldToughness;
                }
                else if (actor.IsMonster() && actor.monsterCfg.EquipShield == (int)CoreType.Boss)
                {
                    _toughness = TbUtil.battleConsts.BossShieldToughness;
                }
                else
                {
                    _toughness = actor.config.HurtInfo.Toughness;
                }
                _hurtTypeID = actor.config.HurtInfo.HurtTypeID;
            }

            //击退因子匹配
            var hurtFactorRange = TbUtil.battleConsts.HurtBackFactorRange;
            if (hurtFactorRange != null && hurtFactorRange.Length % 3 == 0)
            {
                for (int i = 0; i < hurtFactorRange.Length; i += 3)
                {
                    if (hurtFactorRange[i] <= actor.config.Weight &&
                       actor.config.Weight < hurtFactorRange[i + 1])
                    {
                        _hurtBackDivisor = hurtFactorRange[i + 2];
                        break;
                    }
                }
            }
            var hurtFloatRange = TbUtil.battleConsts.HurtFloatFactorRange;
            if (hurtFloatRange != null && hurtFloatRange.Length % 3 == 0)
            {
                for (int i = 0; i < hurtFloatRange.Length; i += 3)
                {
                    if (hurtFloatRange[i] <= actor.config.Weight &&
                       actor.config.Weight < hurtFloatRange[i + 1])
                    {
                        _hurtFloatDivisor = hurtFloatRange[i + 2];
                        break;
                    }
                }
            }
            var hurtFlyFactorRange = TbUtil.battleConsts.HurtFlyFactorRange;
            if (hurtFlyFactorRange != null && hurtFlyFactorRange.Length % 3 == 0)
            {
                for (int i = 0; i < hurtFlyFactorRange.Length; i += 3)
                {
                    if (hurtFlyFactorRange[i] <= actor.config.Weight &&
                       actor.config.Weight < hurtFlyFactorRange[i + 1])
                    {
                        _hurtFlyDivisor = hurtFlyFactorRange[i + 2];
                        break;
                    }
                }
            }
            hurtInterruptController.Init(actor);
            _hurtMaterialType = null != actor.suitCfg ? (HurtMaterialType)actor.suitCfg.HurtMaterial : actor.config.HurtInfo.HurtMaterial;
            actor.eventMgr.AddListener<EventOnSwitchMoveMode>(EventType.OnExitMoveMode, _actionSwitchMoveMode, "ActorHurt._OnFoundGround");
            actor.animator?.onStateNotify.AddListener(_actionOnAnimStateChange);
            isHurt = false;
            isLying = false;
            _layDownHurtCount = 0;
            _hurtAdditiveCD = 0;
            if (actor.animator != null && actor.animator.runtimeAnimatorController != null)
            {
                _hurtAddAnimLayerIndex = actor.animator.GetLayerIndex(RoleAnimLayerName.HurtAdd);
                if (_hurtAddAnimLayerIndex != -1)
                {
                    actor.animator.PlayAnim("Empty", layerIndex: _hurtAddAnimLayerIndex);
                    if (actor.IsMonster())
                    {
                        actor.animator.SetLayerWeight(_hurtAddAnimLayerIndex, hurtAddWeight = actor.monsterCfg.HurtAddtiveWeight);
                    }
                }
            }
        }

        public override void OnDead()
        {
            StopAdditiveHurt();
        }

        public override void OnRecycle()
        {
            actor.eventMgr.RemoveListener<EventOnSwitchMoveMode>(EventType.OnExitMoveMode, _actionSwitchMoveMode);
            hurtInterruptController.Clear();
            actor.animator?.onStateNotify.RemoveListener(_actionOnAnimStateChange);
            _layDownHurtCount = 0;
        }

        protected override void OnAnimationJobRunning()
        {
            using (ProfilerDefine.HurtUpdatePMarker.Auto())
            {
                using (ProfilerDefine.HurtUpdateHurtBackPMarker.Auto())
                {
                    _UpdateHurtBack(actor.deltaTime);
                }

                _UpdateHurtProtect();
                _UpdateVibrateCD();
                _UpdateHurtAdditiveCD();
            }

        }

        public void OnAnimStateChange(int layerIndex, StateNotifyType notifyType, string stateName)
        {
            if (layerIndex == AnimConst.DefaultLayer)
            {
                if (notifyType == StateNotifyType.Complete)
                {
                    actor.locomotion.TriggerFSMEvent("HurtAnimExit");
                }
            }
            if(actor.IsMonster() && layerIndex == AnimConst.HurtAdditiveLayer && stateName == AnimStateName.HurtFrontAdditive)
            {
                if(notifyType == StateNotifyType.PrepEnter)
                    actor.animator.runtimeAnimatorController.SetEnableBoneLayerBlend(true);
                else if(notifyType == StateNotifyType.Exit)
                    actor.animator.runtimeAnimatorController.SetEnableBoneLayerBlend(false);
            }
        }

        /// <param name="hurtDir">攻击者→自身</param>
        /// <param name="damageBoxCfg"></param>
        /// <param name="isEnterHurt"></param> 是否由非受击态进入受击态
        public void TakeEffect(Vector3 hurtDir, float hurtDistance, DamageBoxCfg damageBoxCfg, bool ignoreToughness, out bool isEnterHurt)
        {
            isEnterHurt = false;
            _hurtBackTotalDis = hurtDistance;
            
            //状态优先判断
            using (ProfilerDefine.HurtEffectHurtIgnorePMarker.Auto())
            {
                if (null != actor.stateTag && actor.stateTag.IsActive(ActorStateTagType.HurtIgnore))
                    return;
            }

            // 空攻击类型
            using (ProfilerDefine.HurtEffectCheckHurtPMarker.Auto())
            {
                if (!CheckHurt(damageBoxCfg))
                    return;
            }

            //计算受击方向
            _CalcHurtDir(damageBoxCfg, hurtDir);

            //叠加受击
            using (ProfilerDefine.HurtEffectIsAdditiveHurtUpdatePMarker.Auto())
            {
                if (IsAdditiveHurt(damageBoxCfg, ignoreToughness))
                    return;
            }

            // Boss是不会进受击状态
            using (ProfilerDefine.HurtEffectCheckMonsterCfgPMarker.Auto())
            {

                if (actor.monsterCfg != null && actor.monsterCfg.EquipShield == (int)CoreType.Boss)
                    return;
            }

            //Rising中 轻重受击无效
            hurtType = damageBoxCfg.HurtType;
            using (ProfilerDefine.HurtEffectLightHurtPMarker.Auto())
            {
                if (isRising && (hurtType == HurtType.LightHurt || hurtType == HurtType.HeavyHurt))
                    return;
            }

            //计算受击状态
            int type;
            var selfHurtType = _hurtTypeID;
            if (actor.stateTag.IsActive(ActorStateTagType.CannotMove) &&
                TbUtil.battleConsts.CannotmoveTagHurtType != 0)//canotMove受击表现降级
            {
                selfHurtType = TbUtil.battleConsts.CannotmoveTagHurtType;
            }

            using (ProfilerDefine.HurtEffectHurtTypePMarker.Auto())
            {
                // 受击效果映射
                if (!isHurt)
                {
                    // 未处于受击
                    if (actor.transform.isGrounded)
                    {
                        // 处于地面
                        type = GetHurtStateType(selfHurtType, (int)BeforeHurtState.DefaultIdle);
                    }
                    else
                    {
                        // 处于空中
                        type = GetHurtStateType(selfHurtType, (int)BeforeHurtState.DefalutFloat);
                    }

                    isEnterHurt = true;
                }
                else
                {
                    // 已处于受击
                    if (actor.transform.isGrounded)
                    {
                        if (!isLying)
                        {
                            if (hurtStateType == (int)HurtStateType.LightHurt) // 当前处于轻受击
                                type = GetHurtStateType(selfHurtType, (int)BeforeHurtState.LightHurtState);
                            else if (hurtStateType == (int)HurtStateType.HeavyHurt) // 当前处于重受击
                                type = GetHurtStateType(selfHurtType, (int)BeforeHurtState.HeavyHurtState);
                            else
                                type = GetHurtStateType(selfHurtType, (int)BeforeHurtState.StandHurtState);
                        }
                        else
                        {
                            type = GetHurtStateType(selfHurtType, (int)BeforeHurtState.LayDownHurtState);
                            if (actor.IsMonster())
                            {
                                _layDownHurtCount += 1;
                                if (_layDownHurtCount >= TbUtil.battleConsts.HurtDownProtectTimes)
                                {
                                    type = GetHurtStateType(selfHurtType, (int)BeforeHurtState.LayDownHurtCountFull);
                                }
                            }
                        }
                    }
                    else
                    {
                        //女主/男主只要处于受击浮空态，那么就不会再次被轻/重和击飞/挑飞
                        if (actor.IsBoy() || actor.IsGirl())
                        {
                            return;
                        }

                        type = GetHurtStateType(selfHurtType, (int)BeforeHurtState.FloatHurtState);
                    }
                }
            }

            if (type == (int) HurtStateType.None)
                return;

            hurtStateType = type;

            using (ProfilerDefine.HurtEffectCalHurtDirPMarker.Auto())
            {
                if (!actor.IsGirl() && !actor.IsBoy())
                {
                    hurtDirection = HurtDirection.Forward; // 默认的前向受击
                    if (Vector3.Dot(vecHurtDir, actor.transform.forward) < -_hurtDirectionOffset)
                        hurtDirection = HurtDirection.Forward;
                    else if (Vector3.Dot(vecHurtDir, actor.transform.right) < -_hurtDirectionOffset)
                        hurtDirection = HurtDirection.Right;
                    else if (Vector3.Dot(vecHurtDir, -actor.transform.right) < -_hurtDirectionOffset)
                        hurtDirection = HurtDirection.Left;
                    else if (Vector3.Dot(vecHurtDir, -actor.transform.forward) < -_hurtDirectionOffset)
                        hurtDirection = HurtDirection.Back;
                    if (type == (int)HurtStateType.LightHurt || type == (int)HurtStateType.HeavyHurt)
                    {
                        var selfHurtDir = actor.transform.forward;
                        if (hurtDirection == HurtDirection.Forward)
                            selfHurtDir = actor.transform.forward;
                        else if (hurtDirection == HurtDirection.Right)
                            selfHurtDir = actor.transform.right;
                        else if (hurtDirection == HurtDirection.Left)
                            selfHurtDir = -actor.transform.right;
                        else if (hurtDirection == HurtDirection.Back)
                            selfHurtDir = -actor.transform.forward;
                        var sign = 1;
                        var cross = Vector3.Cross(selfHurtDir, -vecHurtDir).y;
                        if (cross < 0)
                            sign = -1;
                        var turnAngle = Vector3.Angle(selfHurtDir, -vecHurtDir) * sign;
                        vecFaceDir = Quaternion.AngleAxis(turnAngle, Vector3.up) * actor.transform.forward;
                    }
                    else if (type != (int)HurtStateType.LaydownHurt) //其他非倒地受击 需要面向攻击方向叠击退方向 
                    {
                        vecFaceDir = -vecHurtDir;
                        // 没多方向动画 所以一定是Forward
                        hurtDirection = HurtDirection.Forward;
                    }
                }
                else
                {
                    //地面 轻重受击有多方向 修正到击退方向的差角
                    if (type == (int)HurtStateType.LightHurt || type == (int)HurtStateType.HeavyHurt)
                    {
                        // 玩家只有前后受击
                        // 受到前向攻击则面朝目标，否则就背朝目标
                        if (Vector3.Dot(vecHurtDir, actor.transform.forward) < Mathf.Abs(_playerHurtDirectionOffset))
                        {
                            hurtDirection = HurtDirection.Forward;
                            vecFaceDir = -vecHurtDir;
                        }
                        else
                        {
                            hurtDirection = HurtDirection.Back;
                            vecFaceDir = vecHurtDir;
                        }
                    }
                    else if (type != (int)HurtStateType.LaydownHurt)
                    {
                        vecFaceDir = -vecHurtDir;
                        // 没多方向动画 所以一定是Forward
                        hurtDirection = HurtDirection.Forward;
                    }

                    _TryVibrate(type);
                }
            }

            if (!HasNormalHurtAnim())
                return;

            //进入受击状态
            using (ProfilerDefine.HurtEffectActorAbnormalTypePMarker.Auto())
            {
                if (null != actor.mainState)
                {
                    _hurtTryAbnormalArg.damageBoxCfg = damageBoxCfg;
                    _hurtTryAbnormalArg.hurtDistance = hurtDistance;
                    actor.mainState.TryEnterAbnormal(ActorAbnormalType.Hurt, this,  _setAbnormalCallback, _hurtTryAbnormalArg);
                }
            }
        }

        private void _SetAbnormalCallback(bool result, ActorMainState.IArg arg)
        {
            LogProxy.LogFormat("【战斗】【主状态机】角色(name={0}) ActorHurt._SetAbnormalCallback, 当前异常状态{1}", this.actor.name, actor.mainState.abnormalType);
            if (actor.mainState.abnormalType != ActorAbnormalType.Hurt)
            {
                return;
            }
            
            if (null != actor.frozen && actor.frozen.isFrozen)
            {
                return;
            }

            if (!(arg is HurtTryAbnormalArg hurtTryAbnormalArg))
            {
                return;
            }

            var damageBoxCfg = hurtTryAbnormalArg.damageBoxCfg;
            
            if (hurtDirection == HurtDirection.Forward || hurtDirection == HurtDirection.Back)
                actor.animator.SetRootMotionMultiplier(x: 1, z: damageBoxCfg.ForbidRootMotion ? 0 : 1f, live: true, type: RMMultiplierType.AbnormalState);
            else
                actor.animator.SetRootMotionMultiplier(x: damageBoxCfg.ForbidRootMotion ? 0 : 1f, z: 1, live: true, type: RMMultiplierType.AbnormalState);

            _curHeight = actor.transform.position.y;
            _curPos = actor.transform.position;
            _config = damageBoxCfg;

            if (damageBoxCfg.HurtType == HurtType.LayDownHurt)
                layDownTime = damageBoxCfg.HurtLayDownTime;

            using (ProfilerDefine.HurtEffectTryEndSkillPMarker.Auto())
            {
                actor.skillOwner.TryEndSkill(SkillEndType.Interrupt);
                actor.skillOwner.ClearSkillRemainFX();
            }

            using (ProfilerDefine.HurtEffectSendFSMEventPMarker.Auto())
            {
                LogProxy.LogFormat("【战斗】【主状态机】角色(name={0}) 异常状态 ActorHurt.GetHurt", this.actor.name);
                actor.locomotion.TriggerFSMEvent("GetHurt");
            }

            using (ProfilerDefine.HurtEffectSetScalePMarker.Auto())
            {
                actor.SetTimeScale(TbUtil.battleConsts.DuringDamageBoxTimeScale, damageBoxCfg.HurtScaleDuration, (int)ActorTimeScaleType.Base);
            }

            isHurt = true;
            hurtProtectDelayTime = 0f;
        }

        /// <summary>
        /// 受击时震动手机
        /// </summary>
        private void _TryVibrate(int type)
        {
            if (!BattleUtil.GetHurtVibrate())
                return;

            if (!actor.IsGirl() || !_CheckHP())
                return; 

            if (_vibrateCD > 0)
                return;

            if (TbUtil.battleConsts.VibrateOncePeriod.Length < (int)VibrateType.Num || TbUtil.battleConsts.VibrateTimes.Length < (int)VibrateType.Num)
                return;

            using (ProfilerDefine.HurtEffectPlayVirabratePMarker.Auto())
            {
                switch (type)
                {
                    case (int)HurtStateType.LightHurt:
                        BattleEnv.LuaBridge.PlayVirabrate((int)VibrateType.Low, TbUtil.battleConsts.VibrateOncePeriod[(int)VibrateType.Low], TbUtil.battleConsts.VibrateTimes[(int)VibrateType.Low]);
                        // LogProxy.Log($"【战斗】【受击】震动强度：{(int)VibrateType.Low}, 震动单次时长：{TbUtil.battleConsts.VibrateOncePeriod[(int)VibrateType.Low]}, 震动次数{TbUtil.battleConsts.VibrateTimes[(int)VibrateType.Low]}");
                        break;
                    case (int)HurtStateType.HeavyHurt:
                        BattleEnv.LuaBridge.PlayVirabrate((int)VibrateType.Medium, TbUtil.battleConsts.VibrateOncePeriod[(int)VibrateType.Medium], TbUtil.battleConsts.VibrateTimes[(int)VibrateType.Medium]);
                        // LogProxy.Log($"【战斗】【受击】震动强度：{(int)VibrateType.Medium}, 震动单次时长：{TbUtil.battleConsts.VibrateOncePeriod[(int)VibrateType.Medium]}, 震动次数{TbUtil.battleConsts.VibrateTimes[(int)VibrateType.Medium]}");
                        break;
                    case (int)HurtStateType.FloatHurt:
                        BattleEnv.LuaBridge.PlayVirabrate((int)VibrateType.High, TbUtil.battleConsts.VibrateOncePeriod[(int)VibrateType.High], TbUtil.battleConsts.VibrateTimes[(int)VibrateType.High]);
                        // LogProxy.Log($"【战斗】【受击】震动强度：{(int)VibrateType.High}, 震动单次时长：{TbUtil.battleConsts.VibrateOncePeriod[(int)VibrateType.High]}, 震动次数{TbUtil.battleConsts.VibrateTimes[(int)VibrateType.High]}");
                        break;
                    case (int)HurtStateType.HurtFly:
                        BattleEnv.LuaBridge.PlayVirabrate((int)VibrateType.High, TbUtil.battleConsts.VibrateOncePeriod[(int)VibrateType.High], TbUtil.battleConsts.VibrateTimes[(int)VibrateType.High]);
                        // LogProxy.Log($"【战斗】【受击】震动强度：{(int)VibrateType.High}, 震动单次时长：{TbUtil.battleConsts.VibrateOncePeriod[(int)VibrateType.High]}, 震动次数{TbUtil.battleConsts.VibrateTimes[(int)VibrateType.High]}");
                        break;
                }

            }

            _vibrateCD = TbUtil.battleConsts.VIbrateInsideCD;
        }

        private bool _CheckHP()
        {
            var maxHp = actor.attributeOwner.GetAttrValue(AttrType.MaxHP);
            var hp = actor.attributeOwner.GetAttrValue(AttrType.HP);

            if (maxHp <= 0)
                return false;

            return hp / maxHp <= TbUtil.battleConsts.VibrateHPThreshold;
        }

        /// 停止受击状态
        public void StopHurt()
        {
            if (!isHurt)
            {
                return;
            }
            
            actor.transform.characterMove.SwitchMode(MovementMode.walking);
            isHurt = false;
            _layDownHurtCount = 0;
            StopHurtBackAndHurtFly();
            actor.mainState?.TryEndAbnormal(ActorAbnormalType.Hurt, this);
            actor.animator.SetRootMotionMultiplier(z: 1, live: false, type: RMMultiplierType.AbnormalState);
            actor.transform.ForceFloor();
        }

        public void StopAdditiveHurt()
        {
            actor.animator?.PlayAnim(AnimStateName.Empty, skipSameState: false ,layerIndex: _hurtAddAnimLayerIndex);
            actor.animator?.SetBool(AnimParams.HurtFrontAdd, false);
        }

        public void SetHurtBackSpeed(float backSpeed, float heightSpeed)
        {
            //this.backSpeed = backSpeed / 1000f;
            //this.heightSpeed = heightSpeed / 1000f;
        }

        public void SetHurtBackAccelerate(float backAccelerate, float heightAccelerate)
        {
            //this.backResistance = backAccelerate / 1000f;
            //this.heightResistance = heightAccelerate / 1000f;
        }

        /// <summary>
        /// 设置受击曲线以及比例
        /// </summary>
        /// <param name="hurtBackCurve"></param>
        /// <param name="hurtHeightCurve"></param>
        /// <param name="backRatio"></param>
        /// <param name="heightRatio"></param>
        public void SetHurtBackParam(string hurtBackCurve, string hurtHeightCurve, float backRatio = 1, float heightRatio = 1)
        {
            if (!String.IsNullOrEmpty(hurtBackCurve))
            {
                using (ProfilerDefine.HurtBackParamHurtBackCurvePMarker.Auto())
                {
                    var horizonalCurveAsset = BattleResMgr.Instance.Load<HurtBackCurve>(hurtBackCurve, BattleResType.HurtBackCurve);
                    horizonalCurve = horizonalCurveAsset?.Curve;
                    BattleResMgr.Instance.Unload(horizonalCurveAsset);
                }
            }
            else
            {
                horizonalCurve = null;
            }

            if (!String.IsNullOrEmpty(hurtHeightCurve))
            {
                using (ProfilerDefine.HurtBackParamHurtHeightCurvePMarker.Auto())
                {
                    var verticalCurveAsset = BattleResMgr.Instance.Load<HurtBackCurve>(hurtHeightCurve, BattleResType.HurtBackCurve);
                    verticalCurve = verticalCurveAsset?.Curve;
                    BattleResMgr.Instance.Unload(verticalCurveAsset);
                }
            }
            else
            {
                verticalCurve = null;
            }
            _hurtBackRatio = backRatio;
            _hurtHeightRatio = heightRatio;
        }

        public void SetHeightResistance(float resistance)
        {
            heightResistance = resistance;
        }

        /// <summary>
        /// 开始击退
        /// </summary>
        /// <param name="hurtBackTime"></param> 击退时间
        /// <param name="hurtBackDisRatio"></param> 击退距离
        public void StartHurtBack(float hurtBackTime = 0, float hurtBackDisRatio = 1.0f)
        {
            _hurtBackDis = _hurtBackTotalDis * hurtBackDisRatio * _hurtBackDivisor;
            if (hurtBackTime != 0 && _hurtBackTotalDis != 0)
            {
                _hurtBackSpeed = _hurtBackTotalDis / hurtBackTime;
                isHurtBack = true;
            }
        }

        public void StartHurtFly()
        {
            if (hurtStateType == (int)HurtStateType.OnFlyHurt)
            {
                SetHurtBackParam(_config.HurtFlyBeHitCurveHorizontal, _config.HurtFlyBeHitCurveVertical, _config.HurtFlyBeHitCurveHorizontalRatio, _config.HurtFlyBeHitCurveVerticalRatio);
                SetHurtFlyFirstPos();
            }
            else if (_config.HurtType == HurtType.FloatHurt || _config.HurtType == HurtType.FlyHurt)
            {
                SetHurtBackParam(_config.HurtCurveHorizontal, _config.HurtCurveVertical, _config.CurveHorizontalRatio, _config.CurveVerticalRatio);
                SetHurtFlyFirstPos();
            }
            isHurtFly = true;
            _curHurtTime = 0;
        }
        private void SetHurtFlyFirstPos()
        {
            if (verticalCurve != null)
            {
                _curPos = actor.transform.position + new Vector3(0, verticalCurve.Evaluate(0), 0);
                actor.transform.SetPosition(_curPos);
            }
            else
            {
                LogProxy.LogError($"【战斗】【受击】伤害盒编号：{_config.ID} 击飞曲线：{_config.HurtCurveVertical}verticalCurve曲线为空");
            }
        }

        public void StopHurtBackAndHurtFly()
        {
            backSpeed = 0;
            heightSpeed = 0;
            heightResistance = 0;
            horizonalCurve = null;
            verticalCurve = null;
            _curPos = actor.transform.position;
            _curHeight = actor.transform.position.y;
            isHurtBack = false;
            isHurtFly = false;
        }

        public void SetIsLying(bool isLying)
        {
            // 从倒地变为非倒地，刷新倒地受击次数
            if (this.isLying && !isLying)
                _layDownHurtCount = 0;
            this.isLying = isLying;
        }

        public bool CheckHurt(DamageBoxCfg damageBoxCfg)
        {
            if (damageBoxCfg.HurtType == HurtType.Null || damageBoxCfg.ToughnessReduce <= 0)
                return false;

            return true;
        }

        /// 检测受击对象的抗攻击等级 以及 伤害盒的受击类型
        public bool IsAdditiveHurt(DamageBoxCfg damageBoxCfg, bool ignoreToughness)
        {
            
            if (actor.actorWeak.IsWeakOrLightWeak || actor.frozen.isFrozen) // 虚弱或冰冻状态下不播放叠加受击 
                return false;

            if (damageBoxCfg.HurtType == HurtType.AddAnimHurt)
            {
                if (_hurtAddAnimLayerIndex != -1)
                {
                    if (_hurtAdditiveCD <= 0)
                    { 
                        actor.animator.SetBool(AnimParams.HurtFrontAdd, true);
                        _hurtAdditiveCD = TbUtil.battleConsts.HurtAddtiveCD;
                    }
                }
                PlayBoneShake(damageBoxCfg);//策划:抖动和叠加是分开的 没有叠加动画层也可以播
                return true;
            }

            if (!ignoreToughness && damageBoxCfg.ToughnessReduce <= _toughness)
            {
                //7.12 受击<=攻击抗等级 且不处于大虚弱或是小虚弱 如果使用叠加动画 那么播放叠加动画
                if (_hurtAddAnimLayerIndex != -1 && damageBoxCfg.IsUseCalcToughnessAddAnimHurt)
                {
                    if (_hurtAdditiveCD <= 0)
                    { 
                        actor.animator.SetBool(AnimParams.HurtFrontAdd, true);
                        _hurtAdditiveCD = TbUtil.battleConsts.HurtAddtiveCD;
                    }
                }
                PlayBoneShake(damageBoxCfg);
                return true;
            }

            return false;
        }

        public bool HasNormalHurtAnim()
        {
            if (_hurtAnims == null)
                return true;
            var hurtAnims = _hurtAnims[hurtStateType - 1];
            if (hurtStateType <= 2)//轻重受击方向的动画
            {
                if (!actor.animator.GetAnimatorStateClip(hurtAnims[(int)hurtDirection - 1]))
                    return false;
            }
            else
            {
                foreach (var anim in hurtAnims)
                {
                    if (!actor.animator.GetAnimatorStateClip(anim))
                        return false;
                }
            }
            return true;
        }

        public int? GetHurtFxID(DamageBoxCfg damageBoxCfg)
        {
            if ((string)damageBoxCfg.hurtWeaponType == null)
                return null;
            TbUtil.TryGetCfg((string)damageBoxCfg.hurtWeaponType, out Dictionary<int, HurtMaterialConfig> weaponHurtCfg);
            if (weaponHurtCfg != null)
            {
                weaponHurtCfg.TryGetValue((int)_hurtMaterialType, out var materialHurtCfg);
                if (materialHurtCfg != null)
                {
                    return materialHurtCfg.HurtEffectID;
                }
            }
            return null;
        }

        public string GetHurtSound(DamageBoxCfg damageBoxCfg)
        {
            return BattleUtil.GetHurtSound(damageBoxCfg, _hurtMaterialType);
        }

        private void _UpdateHurtBack(float deltaTime)
        {
            if (!isHurtBack && !isHurtFly)
            {
                // 未处于受击状态时不更新位移
                return;
            }

            _curPos = actor.transform.position;
            _curHeight = _curPos.y;

            if (isHurtBack)
            {
                _curPos += _hurtBackSpeed * _hurtBackDivisor * deltaTime * vecHurtDir;
                _hurtBackDis -= _hurtBackSpeed * _hurtBackDivisor * deltaTime;
                if (_hurtBackDis < 0)
                    isHurtBack = false;
            }
            else if (isHurtFly)
            {
                var divisor = hurtType == HurtType.FloatHurt ? _hurtFloatDivisor : _hurtFlyDivisor;
                // 在击飞过程中受到击退，则击飞曲线和加速度都不生效
                if (horizonalCurve != null && _curHurtTime < horizonalCurve[horizonalCurve.length - 1].time)
                {
                    float deltaDis = 0;
                    if (_curHurtTime + deltaTime < horizonalCurve[horizonalCurve.length - 1].time)
                    {
                        deltaDis = horizonalCurve.Evaluate(_curHurtTime + deltaTime) - horizonalCurve.Evaluate(_curHurtTime);
                    }
                    else
                    {
                        deltaDis = horizonalCurve[horizonalCurve.length - 1].value - horizonalCurve.Evaluate(_curHurtTime);
                        backSpeed = deltaDis / (horizonalCurve[horizonalCurve.length - 1].time - _curHurtTime) * _hurtBackRatio;
                    }
                    _curPos += deltaDis * vecHurtDir * _hurtBackRatio * divisor;
                    LogProxy.Log($"【战斗】【受击】击飞中 : _curPos:{_curPos}, deltaPos:{deltaDis * _hurtBackRatio * divisor}");
                }
                else
                {
                    float deltaDis = backSpeed * deltaTime;
                    _curPos += deltaDis * vecHurtDir * divisor;
                }

                if (verticalCurve != null && _curHurtTime < verticalCurve[verticalCurve.length - 1].time)
                {
                    float deltaY = 0;
                    if (_curHurtTime + deltaTime < verticalCurve[verticalCurve.length - 1].time)
                        deltaY = verticalCurve.Evaluate(_curHurtTime + deltaTime) - verticalCurve.Evaluate(_curHurtTime);
                    else
                    {
                        deltaY = verticalCurve[verticalCurve.length - 1].value - verticalCurve.Evaluate(_curHurtTime);
                        heightSpeed = deltaY / (verticalCurve[verticalCurve.length - 1].time - _curHurtTime) * _hurtHeightRatio;
                    }
                    LogProxy.Log($"【战斗】【受击】击飞中 : curHeight:{_curHeight}, deltaHeight:{deltaY * _hurtHeightRatio}");
                    _curHeight += deltaY * _hurtHeightRatio * divisor;
                }
                else
                {
                    if (verticalCurve != null && _curHurtTime - verticalCurve[verticalCurve.length - 1].time <= deltaTime)
                    {
                        // 过了最高点开始下落
                        actor.locomotion?.TriggerFSMEvent("StartFalling");
                        LogProxy.Log($"【战斗】【受击】开始下落 : curHeight:{_curHeight}, curTime:{_curHurtTime}");
                    }
                    float deltaHeight = heightSpeed * deltaTime * divisor;
                    heightSpeed += heightResistance * deltaTime * divisor;
                    _curHeight += deltaHeight;
                }

                _curPos.y = _curHeight;
            }
            else
            {
                return;
            }

            _curHurtTime += deltaTime;
            using (ProfilerDefine.HurtBackSetPositionPMarker.Auto())
            {
                LogProxy.Log($"【战斗】【受击】BeforeSetPosition : position:{actor.transform.position}, curPos:{_curPos}");
                actor.transform.SetPosition(_curPos);
                LogProxy.Log($"【战斗】【受击】AfterSetPosition : position:{actor.transform.position}, curPos:{_curPos}");
            }
        }

        private void _UpdateHurtProtect()
        {
            if (!actor.IsMonster() || !actor.monsterCfg.IsHurtProtect)
                return;

            if(actor.actorWeak.weak)
            {               
                return;
            }

            //脱离受击后,延迟k秒,恢复韧性
            if (!isHurt)
            {
                if (hurtProtectValue > 0f || hurtProtectTime > 0f)
                {
                    hurtProtectDelayTime += battle.deltaTime;
                    if (hurtProtectDelayTime > TbUtil.battleConsts.HurtProtectDelayTime)
                    {
                        AddToughness(-hurtProtectValue);
                        hurtProtectTime = hurtProtectPeriod =0;
                        hurtProtectValue = hurtProtectDelayTime = 0f;
                    }
                }
            }

            //受击或延迟消除受击保护时 增加韧性
            if ((isHurt || hurtProtectDelayTime > 0f) &&
                hurtProtectValue < actor.monsterCfg.HurtProtectMaxValue)
            {
                //m秒后
                hurtProtectTime += battle.deltaTime;
                if (hurtProtectTime >= TbUtil.battleConsts.HurtProtectTime)
                {
                    //每n秒增加x
                    hurtProtectPeriod += battle.deltaTime;
                    if (hurtProtectPeriod >= TbUtil.battleConsts.HurtProtectPeriod)
                    {
                        hurtProtectPeriod = 0;
                        var newTotalToughness = hurtProtectValue + TbUtil.battleConsts.HurtProtectValue;
                        newTotalToughness = Mathf.Min(newTotalToughness, actor.monsterCfg.HurtProtectMaxValue);
                        var curAddToughness = newTotalToughness - hurtProtectValue;
                        hurtProtectValue += curAddToughness;
                        AddToughness(curAddToughness);
                    }
                }
            }
        }

        private void _UpdateVibrateCD()
        {
            if(_vibrateCD > 0)
            {
                _vibrateCD -= battle.deltaTime;
            }
        }

        private void _UpdateHurtAdditiveCD()
        {
            if(_hurtAdditiveCD > 0)
            {
                _hurtAdditiveCD -= battle.deltaTime;
            }
        }

        private void _CalcHurtDir(DamageBoxCfg damageBoxCfg, Vector3 hurtDir)
        {
            hurtDir.y = 0;
            hurtDir = hurtDir.normalized;
            switch (damageBoxCfg.HurtBackDir)
            {
                case HurtDirection.Back:
                    vecHurtDir = -hurtDir;
                    break;
                case HurtDirection.Left:
                    vecHurtDir = Quaternion.AngleAxis(-90f, Vector3.up) * hurtDir;
                    break;
                case HurtDirection.Forward:
                    vecHurtDir = hurtDir;
                    break;
                case HurtDirection.Right:
                    vecHurtDir = Quaternion.AngleAxis(90f, Vector3.up) * hurtDir;
                    break;
                default:
                    vecHurtDir = hurtDir;
                    break;
            }
        }

        public void RefreshHurtProtected()
        {
            if (hurtProtectValue > 0 || hurtProtectTime > 0f)
            {
                AddToughness(-hurtProtectValue);
                hurtProtectTime = hurtProtectPeriod = 0;
                hurtProtectValue = hurtProtectDelayTime = 0f;
            }
        }

        public void PlayBoneShake(DamageBoxCfg damageBoxCfg)
        {
            using (ProfilerDefine.HurtPlayBoneShakePMarker.Auto())
            {
                // DONE: 受击抖动
                if (GetBoneShakeStrength(damageBoxCfg) != HurtShakeStrength.None)
                {
                    if (damageBoxCfg.HurtShakeDirType == HurtShakeDirType.HurtDirProj)
                    {
                        var hurtShakeDir = GetBoneShakeDir(damageBoxCfg);
                        actor.effectPlayer.PlayShake(hurtShakeDir, (int)actor.hurt.GetBoneShakeStrength(damageBoxCfg));
                    }
                    else
                    {
                        actor.effectPlayer.PlayShake((int)actor.hurt.GetBoneShakeStrength(damageBoxCfg));
                    }
                }
            }
        }

        /// 骨骼抖动方向 = 受击方向 + 施力方向
        public Vector3 GetBoneShakeDir(DamageBoxCfg damageBoxCfg)
        {
            Vector3 shakeDir = Vector3.up;
            if (damageBoxCfg.AddForceDir == ForceDirectionType.Default)
                shakeDir = vecHurtDir;
            else if (damageBoxCfg.AddForceDir == ForceDirectionType.Right)
                shakeDir = Quaternion.AngleAxis(90, Vector3.up) * vecHurtDir;
            else if (damageBoxCfg.AddForceDir == ForceDirectionType.Left)
                shakeDir = Quaternion.AngleAxis(-90, Vector3.up) * vecHurtDir;
            else
                shakeDir = Quaternion.AngleAxis(180, Vector3.up) * vecHurtDir;

            return shakeDir;
        }

        public HurtShakeStrength GetBoneShakeStrength(DamageBoxCfg damageBoxCfg)
        {
            if (damageBoxCfg.HurtType == HurtType.Null)
                return HurtShakeStrength.None;
            else if (damageBoxCfg.HurtType == HurtType.LightHurt)
                return HurtShakeStrength.Low;
            else if (damageBoxCfg.HurtType == HurtType.HeavyHurt)
                return HurtShakeStrength.Medium;
            else
                return HurtShakeStrength.High;
        }

        private int GetHurtStateType(int hurtTypeID, int hurtState)
        {
            var config = TbUtil.GetCfg<HurtStateMapConfig>(hurtTypeID, hurtState);
            if (config == null)
            {
                var hurtID = hurtTypeID * 1000 + hurtState;
                LogProxy.LogError($"受击映射表配置错误 ID:{hurtID}");
                return 0;
            }

            if (hurtType == HurtType.LightHurt)
                return config.LightHurt;
            else if (hurtType == HurtType.HeavyHurt)
                return config.HeavyHurt;
            else if (hurtType == HurtType.FloatHurt)
                return config.CarryHurt;
            else if (hurtType == HurtType.FlyHurt)
                return config.FlyHurt;
            else if (hurtType == HurtType.LayDownHurt)
                return config.LayDownHurt;
            else
                return config.LightHurt;  // 保底
        }

        private void _OnExitMode(EventOnSwitchMoveMode arg)
        {
            if (arg.isEnter || arg.curMode.model != MovementMode.Flying)
                return;
            actor.locomotion?.TriggerFSMEvent("FoundGround");
            LogProxy.Log($"【战斗】【受击】检测到地面");
            StopHurtBackAndHurtFly();
        }

        public void AddToughness(float num)
        {
            _toughness += num;
        }
    }
}