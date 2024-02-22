using System;
using System.Collections.Generic;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("区域触发监听器\nListener:TriggerArea")]
    public class OnTriggerArea : FlowListener
    {
        [Flags]
        public enum DetectType
        {
            CC = 1 << 0,
            Collider = 1 << 1,
        }

        /// <summary>
        /// 区域触发器种植点Id
        /// </summary>
        [Name("SpawnID")]
        public BBParameter<int> uId = new BBParameter<int>();
        /// <summary>
        /// 触发响应时设置的角色类型
        /// </summary>
        [GatherPortsCallback]
        public RoleType roleType;
        /// <summary>
        /// RoleType为Other时的角色实例Id
        /// </summary>
        private ValueInput<int> otherUId;
        /// <summary>
        /// 触发响应时设置的触发类型
        /// </summary>
        [GatherPortsCallback]
        public TriggerType triggerType;

        public DetectType detectType = DetectType.CC;

        private ValueInput<int> groupId;
        private ValueInput<int> templateId;

        /// <summary>
        /// TriggerType为Stay时设置的停留时间
        /// </summary>
        private ValueInput<int> stayTime;

        /// <summary>
        /// TriggerType为间隔时长
        /// </summary>
        private ValueInput<float> stayInIntervalTime;

        private HashSet<Actor> _checkActors = new HashSet<Actor>();
        private int _timerId = -1;
        private Action<int, int> _triggerInterval;
        private Action<int> _triggerComplete;
        private int _stayInIntervalTimerId = -1;
        private Action<int, int> _stayInIntervalActionTick;
        
        private Action<EventOnTriggerArea> _actionOnTriggerArea;
        private Action<EventActorBase> _actionOnActorDead;

        public OnTriggerArea()
        {
            _triggerInterval = _TriggerInterval;
            _triggerComplete = _TriggerComplete;
            _actionOnTriggerArea = _OnTriggerArea;
            _actionOnActorDead = _OnActorDead;
        }

        protected override void _OnAddPorts()
        {
            if (roleType == RoleType.Other)
            {
                if (otherUId == null)
                {
                    otherUId = AddValueInput<int>(nameof(otherUId));
                }
                else
                {
                    inputPorts[nameof(otherUId)] = otherUId;
                }
                
            }
            else if (roleType == RoleType.Monster)
            {
                if (groupId == null)
                {
                    groupId = AddValueInput<int>(nameof(groupId));
                    groupId.SetDefaultAndSerializedValue(-1);
                }
                else
                {
                    inputPorts[nameof(groupId)] = groupId;
                }

                if (templateId == null)
                {
                    templateId = AddValueInput<int>(nameof(templateId));
                    templateId.SetDefaultAndSerializedValue(-1);
                }
                else
                {
                    inputPorts[nameof(templateId)] = templateId;
                }
            }

            if (triggerType == TriggerType.Stay)
            {
                if (stayTime == null)
                {
                    stayTime = AddValueInput<int>(nameof(stayTime));
                }
                else
                {
                    inputPorts[nameof(stayTime)] = stayTime;
                }
            }
            else if (triggerType == TriggerType.StayIn)
            {
                if (stayInIntervalTime == null)
                {
                    stayInIntervalTime = AddValueInput<float>(nameof(stayInIntervalTime));
                }
                else
                {
                    inputPorts[nameof(stayInIntervalTime)] = stayInIntervalTime;
                }
            }
        }
        
        protected override void _OnActiveEnter()
        {
            if (IsReachMaxCount())
                return;
            if (triggerType != TriggerType.Stay && triggerType != TriggerType.StayIn)
                return;
            Actor curActor = Battle.Instance.actorMgr.GetActor(uId.value);
            if (curActor?.triggerArea == null)
                return;
            List<Actor> actors = curActor.triggerArea.GetInnerActors();
            foreach (Actor actor in actors)
            {
                if (_CheckActor(actor))
                {
                    _checkActors.Add(actor);
                }
            }
            _UpdateCheckActors();
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener(EventType.OnTriggerArea, _actionOnTriggerArea, "OnTriggerArea._OnTriggerArea");
            Battle.Instance.eventMgr.AddListener(EventType.ActorDead, _actionOnActorDead, "OnTriggerArea._OnActorDead");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.OnTriggerArea, _actionOnTriggerArea);
            Battle.Instance.eventMgr.RemoveListener(EventType.ActorDead, _actionOnActorDead);
            _checkActors.Clear();
            
            if (_timerId > 0)
            {
                Battle.Instance.battleTimer.Discard(null, _timerId);
                _timerId = -1;
            }
            if (_stayInIntervalTimerId > 0)
            {
                Battle.Instance.battleTimer.Discard(null, _stayInIntervalTimerId);
                _stayInIntervalTimerId = -1;
            }
        }

        private void _UpdateCheckActors()
        {
            if (triggerType == TriggerType.Stay)
            {
                if (_checkActors.Count > 0)
                {
                    if (_timerId < 0)
                    {
                        _timerId = Battle.Instance.battleTimer.AddTimer(null, stayTime.GetValue() * 0.001f, 0f, 0, "", null, null,_triggerComplete);
                    }
                }
                else
                {
                    if (_timerId > 0)
                    {
                        Battle.Instance.battleTimer.Discard(null, _timerId);
                        _timerId = -1;
                    }
                }
            }
            else
            {
                if (_checkActors.Count > 0)
                {
                    var intervalTime = stayInIntervalTime.GetValue();
                    if (intervalTime < 0.1f)
                    {
                        intervalTime = 0.1f;
                    }
                    // 已经创建间隔计时器就不在创建了.
                    if (_stayInIntervalTimerId < 0)
                    {
                        _stayInIntervalTimerId = Battle.Instance.battleTimer.AddTimer(null, 0f, intervalTime, -1, null, null, _triggerInterval);   
                    }
                }
                else
                {
                    if (_stayInIntervalTimerId > 0)
                    {
                        Battle.Instance.battleTimer.Discard(null, _stayInIntervalTimerId);
                        _stayInIntervalTimerId = -1;
                    }
                }
            }
        }
        
        private void _OnTriggerArea(EventOnTriggerArea arg)
        {
            if (IsReachMaxCount())
                return;
            if (!_IsTargetCollider(arg.isCharacterCollider))
            {
                return;
            }

            if (arg.actor.spawnID != uId.GetValue())
                return;

            if (_CheckActor(arg.triggerActor))
            {
                if (triggerType == TriggerType.Enter && arg.isEnter ||
                    triggerType == TriggerType.Exit && !arg.isEnter ||
                    triggerType == TriggerType.EnterAndExit)
                {
                    _Trigger();
                }
                else if (triggerType == TriggerType.Stay || triggerType == TriggerType.StayIn)
                {
                    if (arg.isEnter)
                    {
                        _checkActors.Add(arg.triggerActor);
                    }
                    else
                    {
                        _checkActors.Remove(arg.triggerActor);
                    }
                    _UpdateCheckActors();
                }
            }
        }
        
        private void _OnActorDead(EventActorBase eventActor)
        {
            _checkActors.Remove(eventActor.actor);
            _UpdateCheckActors();
        }

        private bool _CheckActor(Actor actor)
        {
            if (actor == null || actor.isDead)
            {
                return false;
            }
            if (roleType == RoleType.Girl && actor == Battle.Instance.actorMgr.girl ||
                roleType == RoleType.Boy && actor == Battle.Instance.actorMgr.boy ||
                roleType == RoleType.BoyAndGirl && (actor == Battle.Instance.actorMgr.girl || actor == Battle.Instance.actorMgr.boy) ||
                roleType == RoleType.Other && actor.spawnID == otherUId.value ||
                roleType == RoleType.Monster && actor.IsMonster() && (groupId.value < 0 || groupId.value == actor.groupId) && (templateId.value < 0 || templateId.value == actor.config.ID))
            {
                return true;
            }
            return false;
        }

        private void _TriggerInterval(int id, int repeatCount)
        {
            _Trigger();
        }
        
        private void _TriggerComplete(int id)
        {
            _Trigger();
        }

        private bool _IsTargetCollider(bool isCharacterCollider)
        {
            // DONE: detectType 是否包含 Collider 选项.
            bool includeCollider = (detectType & DetectType.Collider) != 0;
            // DONE: detectType 是否包含 CC 选项.
            bool includeCC = (detectType & DetectType.CC) != 0;
            
            // DONE: 即全没有选.
            if (!includeCollider && !includeCC)
            {
                return false;
            }

            // DONE: 即全选了.
            if (includeCollider && includeCC)
            {
                return true;
            }

            // DONE: 即只选了Collider.
            if (includeCollider)
            {
                return !isCharacterCollider;
            }
            
            // DONE: 即只选了CC.
            return isCharacterCollider;
        }
    }
}
