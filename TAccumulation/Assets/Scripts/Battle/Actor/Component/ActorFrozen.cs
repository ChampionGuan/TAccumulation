using System;
using System.Collections.Generic;
using UnityEngine;
using X3Battle;
using EventType = X3Battle.EventType;
using Random = UnityEngine.Random;

/// <summary>
/// 处理冰冻相关的逻辑
/// </summary>
public class ActorFrozen : ActorComponent
{
    public bool isFrozen { get; private set; }
    private float _iceBreakingTime = 0.2f; // 每次破冰削减的冰冻时长
    private float _iceBreakingCD = 0.1f;
    private float _curCD; // 当前破冰CD时间
    private bool _isFrozenFootFx;
    public List<X3Buff> frozenBuffs; // 当前所有的冰冻buff，当所有冰冻buff被移除后，冰冻状态结束
    private Action<EventActorFrozen> _actionOnActorEnterFrozen;
    
    private float _frozenLeftTime // 冰冻剩余时间,即为所有buff剩余时长的最大值， 破冰UI在剩余一半时间的时候播放特效
    {
        get
        {
            float result = 0;
            foreach (var buff in frozenBuffs)
            {
                result = Math.Max(result, buff.leftTime);
            }

            return result;
        }
    }

    private float _lastLeftTime;

    private float _frozenTotalTime
    {
        get
        {
            float result = 0;
            foreach (var buff in frozenBuffs)
            {
                result = Math.Max(result, buff.totalTime);
            }

            return result;
        }
    }

    private static List<int> enableComps = new List<int>()
    {
        (int)ActorComponentType.Buff,
        (int)ActorComponentType.TimeScaler,
        (int)ActorComponentType.Model,
        (int)ActorComponentType.Weak,
        (int)ActorComponentType.Frozen,
        (int)ActorComponentType.Taunt,
        (int)ActorComponentType.ShadowPlayer,
        (int)ActorComponentType.Energy,
        (int)ActorComponentType.HP,
        (int)ActorComponentType.Halo,
        (int)ActorComponentType.TriggerArea,
        (int)ActorComponentType.Timer,
        (int)ActorComponentType.ActorInput,
    };

    private ShakeBone _shakeBone;
    public Dictionary<int, bool[]> FrozenActionCompsUpdateMarker = new Dictionary<int, bool[]>();

    public bool FrozenActionAnimatorEnabled = true;
    private Action<EventActorEnterStateBase> _onActorEnterSkillState;

    public ActorFrozen() : base(ActorComponentType.Frozen)
    {
        requiredAnimationJobRunning = true;
        frozenBuffs = new List<X3Buff>();
        _onActorEnterSkillState = _OnActorEnterSkillState;
        _actionOnActorEnterFrozen = _OnActorEnterFrozen;
    }

    protected override void OnAwake()
    {
        if (actor.IsGirl() || actor.IsBoy())
        {
            _iceBreakingTime = TbUtil.battleConsts.IceBreakingTime;
            _iceBreakingCD = TbUtil.battleConsts.IceBreakingCD;

            var rootM = actor.GetDummy().Find("Model/Roots/Root_M");
            if (rootM == null)
            {
                return;
            }

            _shakeBone = BattleUtil.EnsureComponent<ShakeBone>(rootM.gameObject);
            var shakeBoneAsset = BattleResMgr.Instance.Load<ShakeBoneAsset>(TbUtil.battleConsts.IceBreakingShakeAsset, BattleResType.ShakeBone);
            if (shakeBoneAsset == null)
            {
                return;
            }

            _shakeBone.mainShakeAsset = shakeBoneAsset;
#if UNITY_EDITOR
            BattleResMgr.Instance.Unload(shakeBoneAsset);
#endif
        }
    }

    protected override void OnDestroy()
    {
        if (actor.IsGirl() || actor.IsBoy())
        {
#if UNITY_EDITOR
            _shakeBone.mainShakeAsset = null;
#else
            BattleResMgr.Instance.Unload(_shakeBone.mainShakeAsset);
#endif
        }
    }

    public override void OnBorn()
    {
        isFrozen = false;
        frozenBuffs.Clear();
        actor.eventMgr.AddListener(EventType.OnActorEnterSkillState, _onActorEnterSkillState, "ActorFrozen._OnActorEnterSkillState()");
        actor.eventMgr.AddListener(EventType.ActorFrozen, _actionOnActorEnterFrozen, "ActorTimeScaler._OnActorEnterFrozen");
    }

    public override void OnDead()
    {
        isFrozen = false;
        actor.eventMgr.RemoveListener(EventType.ActorFrozen, _actionOnActorEnterFrozen);
    }

    public override void OnRecycle()
    {
        actor.eventMgr.RemoveListener(EventType.OnActorEnterSkillState, _onActorEnterSkillState);
    }
    
    /// <summary>
    /// 角色进入冰冻
    /// </summary>
    private void _OnActorEnterFrozen(EventActorFrozen data)
    {
        if (!data.isEnterFrozen || data.effectType != 0) return;
        // 清顿帧
        actor.SetTimeScale(1);
        // 解除魔女禁用
        actor.SetWitchDisabled(false);
    }

    protected override void OnAnimationJobRunning()
    {
        if (isFrozen)
        {
            _FrozenUpdate();
            _curCD += battle.deltaTime;
            if (actor.IsBoy() && _curCD >= _iceBreakingCD)
                BreakFrozen();
            else if (actor.IsPlayer() && actor.aiOwner != null && actor.aiOwner.enabled && _curCD >= 2 * _iceBreakingCD)
                BreakFrozen();

            //通知UI破冰逻辑
            if (actor.IsPlayer())
            {
                if (_lastLeftTime > _frozenTotalTime * 0.5f && _frozenLeftTime < _frozenTotalTime * 0.5f)
                {
                    // 抛出事件
                    _DispatchEvent(true, EventActorFrozen.sEffectHalfTime);
                }
            }

            _lastLeftTime = _frozenLeftTime;
        }
    }

    /// <summary>
    /// 目前进入/退出冰冻只能通过buff控制
    /// </summary>
    /// <param name="x3Buff"></param>
    public void OnEnterFrozen(X3Buff frozenBuff)
    {
        //第一次冻结
        foreach (var comp in actor.entity.comps)
        {
            if (null == comp || enableComps.Contains(comp.type))
            {
                continue;
            }

            FrozenActionCompsUpdateMarker.Add(comp.type, new[] { comp.requiredUpdate, comp.requiredLateUpdate, comp.requiredFixedUpdate });
            comp.requiredUpdate = false;
            comp.requiredLateUpdate = false;
            comp.requiredFixedUpdate = false;
        }

        //主控才播冰冻ppv
        if (actor.IsPlayer())
            battle.ppvMgr.Play(TbUtil.battleConsts.Frozen_PPV);

        //男女主播放冰冻脚底特效
        if (actor.IsBoy() || actor.IsGirl())
        {
        	_isFrozenFootFx = false;
            var groundPos = actor.GetDummy(ActorDummyType.Root).position;
            var groundHeight = BattleUtil.GetGroundHeight(groundPos);
            groundPos.y = groundHeight;
            var leftFoot = actor.GetDummy(ActorDummyType.PointFootL).position;
            var rightFoot = actor.GetDummy(ActorDummyType.PointFootR).position;
            if ((groundPos - leftFoot).sqrMagnitude < Mathf.Pow(TbUtil.battleConsts.FrozenGroundFXThreshold, 2) ||
               (groundPos - rightFoot).sqrMagnitude < Mathf.Pow(TbUtil.battleConsts.FrozenGroundFXThreshold, 2))
            {
                _isFrozenFootFx = true;
                actor.effectPlayer.PlayFx(TbUtil.battleConsts.FrozenGroundFXID);
            }
        }
        // 停止叠加受击
        actor.hurt.StopAdditiveHurt();

        if (null != actor.animator)
        {
            FrozenActionAnimatorEnabled = actor.animator.enabled;
            actor.animator.enabled = false;
        }

        // 暂停物理动画
        actor.model.SetPhysicsClothPaused(true);

        isFrozen = true;
        _SetSkillBanned(true);
        actor.stateTag.AcquireTag(ActorStateTagType.CannotMove);

        actor.lookAtOwner?.Pause(true);
        actor.locomotionView?.PauseFootIk(true);
        _curCD = 0;
        _lastLeftTime = _frozenLeftTime;

        // 抛出事件
        _DispatchEvent(true, 0);
    }

    public void OnExitFrozen()
    {
        foreach (var comp in actor.entity.comps)
        {
            if (null == comp)
            {
                continue;
            }

            if (FrozenActionCompsUpdateMarker.TryGetValue(comp.type, out var result))
            {
                comp.requiredUpdate = result[0];
                comp.requiredLateUpdate = result[1];
                comp.requiredFixedUpdate = result[2];
            }
        }

        if (null != actor.animator)
        {
            actor.animator.enabled = FrozenActionAnimatorEnabled;
        }

        //主控才播冰冻ppv
        if (actor.IsPlayer())
        {
            battle.ppvMgr.Stop(TbUtil.battleConsts.Frozen_PPV);
        }
        if (_isFrozenFootFx)
            actor.effectPlayer.StopFX(TbUtil.battleConsts.FrozenGroundFXID);
        // 恢复物理动画
        actor.model.SetPhysicsClothPaused(false);

        actor.lookAtOwner?.Pause(false);
        actor.locomotionView?.PauseFootIk(false);
        actor.stateTag.ReleaseTag(ActorStateTagType.CannotMove);
        _SetSkillBanned(false);
        FrozenActionCompsUpdateMarker.Clear();
        FrozenActionAnimatorEnabled = true;
        isFrozen = false;

        // 抛出事件
        _DispatchEvent(false, 0);
    }

    public void BreakFrozen()
    {
        if (isFrozen)
        {
            // 破冰CD还未结束
            if (_curCD < _iceBreakingCD)
                return;

            foreach (var buff in frozenBuffs)
            {
                buff.AddExtraTime(-_iceBreakingTime);
            }

            _curCD = 0;
            
            if (actor.IsPlayer())
            {
                _shakeBone?.StartShake(_shakeBone.mainShakeAsset, 0,
                    new Vector3(Random.value, Random.value, Random.value)); // 播放破冰抖动
                _DispatchEvent(true, EventActorFrozen.sEffectClick); // 通知UI破冰逻辑,播放特效与逻辑减CD时机相同
                actor.effectPlayer.PlayFx(TbUtil.battleConsts.IceBreakingFX);//尝试破冰特效
                if(_frozenLeftTime <= 0)
                {
                    actor.effectPlayer.PlayFx(TbUtil.battleConsts.IceBreakingEndFX);//破冰结束特效
                }
            }
        }
    }

    public void StopFrozen()
    {
        for (int i = frozenBuffs.Count - 1; i >= 0; i--)
        {
            actor.buffOwner.Remove(frozenBuffs[i].ID);
        }
    }

    /// <summary>
    /// 仅在冰冻期间调用Update方法，主要用于实现某些组件需要在冰冻期间部分Update的需求
    /// </summary>
    private void _FrozenUpdate()
    {
        actor.skillOwner.UpdateSlotCD();
    }

    /// <summary>
    /// 技能禁用
    /// </summary>
    private void _SetSkillBanned(bool banned)
    {
        int[] skillTypes = null;
        if (actor.IsGirl())
        {
            skillTypes = TbUtil.battleConsts.FemaleSkillTypeBannedDuringFrozen;
        }
        else if (actor.IsBoy())
        {
            skillTypes = TbUtil.battleConsts.MaleSkillTypeBannedDuringFrozen;
        }
        else
        {
            if (banned)
            {
                actor.stateTag.AcquireTag(ActorStateTagType.CannotCastSkill);
            }
            else
            {
                actor.stateTag.ReleaseTag(ActorStateTagType.CannotCastSkill);
            }
        }

        if (null != skillTypes)
        {
            actor.DisableSkills(this, skillTypes, banned);
        }
    }

    private void _OnActorEnterSkillState(EventActorEnterStateBase data)
    {
        // 如果当前有冰冻异常，结束冰冻
        if (isFrozen)
        {
            StopFrozen();
        }
    }

    /// <summary>
    /// 抛出事件
    /// </summary>
    private void _DispatchEvent(bool isEnterFrozen, int effectType)
    {
        // 抛出事件
        var eventData1 = Battle.Instance.eventMgr.GetEvent<EventActorFrozen>();
        eventData1.Init(actor, isEnterFrozen, effectType);
        actor.eventMgr.Dispatch(EventType.ActorFrozen, eventData1);
    }
}