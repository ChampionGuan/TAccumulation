using PapeGames.X3;
using System;
using System.Collections.Generic;
using UnityEngine;
using X3.Character;
using X3.PlayableAnimator;

namespace X3Battle
{
    public class LocomotionView : ActorComponent
    {
        protected Dictionary<int, bool> _isLateStopFxs = new Dictionary<int, bool>(); //fxID, 是否删除
        protected List<int> _stopFxKeys = new List<int>();
        protected Dictionary<string, bool> _isLateStopSounds = new Dictionary<string, bool>(); //eventName
        protected List<string> _stopSounds = new List<string>();
        protected X3FootIK _x3FootIK;
        private bool _footIKPaused;
        public float dampTime { get; private set; }
        public S2StrInt[] relaxWeights = null;

        private Action<EventScalerChange> _actionScalerChange;
        public float _actualDampTime 
        { 
            get
            {
                if (actor.timeScale != 0)
                    return dampTime * (_footIKPaused ? float.MaxValue : 1.0f) / actor.timeScale;
                else
                    return float.MaxValue;
            } 
        }

        public LocomotionView() : base(ActorComponentType.LocomotionView)
        {
            requiredPhysicalJobRunning = true;
            _actionScalerChange = _OnScalerChange;
        }

        protected override void OnStart()
        {
            base.OnStart();
            InitRelaxWeight();
            if (actor.IsBoy() || actor.IsGirl())
            {
                X3Character character = actor.EnsureComponent<X3Character>(actor.GetDummy(ActorDummyType.Model).gameObject);
                X3.Character.ISubsystem subsystem = character.GetSubsystem(X3.Character.ISubsystem.Type.FootIK);
                if (subsystem == null)
                    return;
                _x3FootIK = subsystem as X3FootIK;
                _x3FootIK.EnabledSelf = true;
            }
        }

        public void InitRelaxWeight()
        {
            if (actor.IsGirl())
            {
                relaxWeights = actor.weapon.weaponSkinCfg.RelaxWeight;
            }
            else if (actor.IsBoy())
            {
                if (actor.suitCfg is MaleSuitConfig suitCfg)
                {
                    relaxWeights = suitCfg.RelaxWeight;
                }
            }
        }

        protected override void OnDestroy()
        {
        }

        public override void OnBorn()
        {
            base.OnBorn();
            battle.eventMgr.AddListener<EventScalerChange>(EventType.OnScalerChange, _actionScalerChange, "LocomotionView.OnSCalerChange");
        }

        public override void OnDead()
        {
            base.OnDead();

            battle.eventMgr.RemoveListener<EventScalerChange>(EventType.OnScalerChange, _actionScalerChange);
            foreach (var stop in _isLateStopFxs)
            {
                actor.effectPlayer.StopFX(stop.Key);
            }

            foreach (var stop in _isLateStopSounds)
            {
                WwiseManager.Instance.StopSound(stop.Key);
            }

            _isLateStopFxs.Clear();
            _isLateStopSounds.Clear();
            _stopSounds.Clear();
            _stopFxKeys.Clear();
        }

        public void EnableFootIk(bool enable, float dampTime)
        {
            if(null == _x3FootIK) return;
            _x3FootIK.enabled = enable;
            if (dampTime >= 0)
            {
                this.dampTime = dampTime;
                _x3FootIK.dampTime = _actualDampTime;
            }
        }

        public void EditorSetRelaxWeightFull(int index)
        {
            for (int i = 0; i < relaxWeights.Length; i++)
            {
                relaxWeights[i].IntVal = i == index ? 100 : 0;
            }
            actor.locomotion.TriggerFSMEvent("OnIdleEnter");
            actor.locomotion.SetAnimFSMVariable("RelaxDelayTime", 0.5f);
        }

        protected override void OnPhysicalJobRunning()
        {
            _stopFxKeys.Clear();
            foreach (var stopFx in _isLateStopFxs)
            {
                if (stopFx.Value)
                {
                    actor.effectPlayer.StopFX(stopFx.Key);
                    _stopFxKeys.Add(stopFx.Key);
                }
            }

            foreach (var removeKey in _stopFxKeys)
            {
                _isLateStopFxs.Remove(removeKey);
            }

            _stopSounds.Clear();
            foreach (var stopSound in _isLateStopSounds)
            {
                if (stopSound.Value)
                {
                    WwiseManager.Instance.StopSound(stopSound.Key);
                    _stopSounds.Add(stopSound.Key);
                }
            }

            foreach (var removeKey in _stopSounds)
            {
                _isLateStopSounds.Remove(removeKey);
            }
        }

        public void PlayRunFx(int groupID, Vector3 pos, Vector3 eulerAngle, GameObject footSoundObj)
        {
            if (DrawSoundsMap.s_SoundsMapAssets == null)
                return;
            var soundIndex = DrawSoundsMap.GetSoundIndex(footSoundObj.transform.position);
            if (soundIndex < 0)
                return;
            var moveFxCfg = TbUtil.GetCfg<GroundMoveFx>(groupID, soundIndex);
            if (moveFxCfg == null)
                return;

            actor.effectPlayer.PlayFx(moveFxCfg.FxID, offsetPos:pos, angle:eulerAngle, isWorldParent: true);

            WwiseManager.Instance.SetSwitch3D(TbUtil.battleConsts.MoveSwitchGroup, moveFxCfg.SwitchState, footSoundObj);
            
            battle?.wwiseBattleManager.PlaySound(moveFxCfg.EventName, footSoundObj, actorInsId: actor.insID);
            LogProxy.LogFormat("【步尘音效】Index:{0}, Event:{1}, Group:{2}, State:{3}", soundIndex, moveFxCfg.EventName, TbUtil.battleConsts.MoveSwitchGroup, moveFxCfg.SwitchState);
        }

        public void PlayOnlyFx(int fxCfgID)
        {
            if (!_isLateStopFxs.ContainsKey(fxCfgID))
            {
                actor.effectPlayer.PlayFx(fxCfgID);
            }

            _isLateStopFxs[fxCfgID] = false;
        }

        public void LateStopFx(int fxCfgID)
        {
            _isLateStopFxs[fxCfgID] = true;
        }

        public void PlayOnlySound(string eventName)
        {
            if (!_isLateStopSounds.ContainsKey(eventName))
            {
                battle?.wwiseBattleManager.PlaySound(eventName, actor.GetDummy(ActorDummyType.Model).gameObject, actorInsId: actor.insID);
            }

            _isLateStopSounds[eventName] = false;
        }

        public void LateStopSound(string eventName)
        {
            _isLateStopSounds[eventName] = true;
        }

        public void PauseFootIk(bool isPause)
        {
            if (_x3FootIK == null)
                return;
            _footIKPaused = isPause;
            _x3FootIK.dampTime = _actualDampTime;
        }

        private void _OnScalerChange(EventScalerChange arg)
        {
            if (!(arg.timeScalerOwner is Actor actor) || actor != this.actor)
                return;
            if(_x3FootIK != null)
                _x3FootIK.dampTime = _actualDampTime;
        }

        public void _OnAnimStateChange(int layerIndex, StateNotifyType notifyType, string stateName)
        {
            // footIK开启与否与动画状态绑定，目前只有Idle动画开启
            if (_x3FootIK == null)
                return;
            if (layerIndex != AnimConst.DefaultLayer)
                return;

            if (notifyType == StateNotifyType.PrepEnter)
            {
                if (stateName == AnimStateName.Idle)
                {
                    _x3FootIK.enabled = true;
                }
                else
                {
                    _x3FootIK.enabled = false;
                }
            }
        }
    }
}
