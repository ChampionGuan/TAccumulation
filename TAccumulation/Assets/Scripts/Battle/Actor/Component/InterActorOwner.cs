using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class InterActorOwner : ActorComponent
    {
        private InterActorComponentConfig _cfg;
        private InterActorState _state;
        private Dictionary<int, float> _checkActorsAndTimes;
        private List<Actor> _checkActors;
        private float _lastCheckTime;//上一次检测的时间
        private float _lastCheckDoneTime;//上一次交互完成时间
        private float _checkInterval = 0.1f;//检测间隔
        private List<int> _btnDescList;
        private string _descStr;
        private Action<int> _action;
        private string _desc;
        private int _InterActorId;
        private List<int> _triggerInsIDs;
        private TriggerActorContext _actorContext;
        public InterActorOwner() : base(ActorComponentType.InteractorOwner)
        {
            _checkActors = new List<Actor>(4);
            _checkActorsAndTimes = new Dictionary<int, float>(4);
            _lastCheckTime = 0;
            _state = InterActorState.Not;
            _btnDescList = new List<int>(4);
            _triggerInsIDs = new List<int>(4);
            _action = _ActivateDone;
            _cfg = null;
        }

        protected override void OnStart()
        {
            _actorContext = new TriggerActorContext(this.actor);
        }

        public override void OnBorn()
        {
            if (!(this.actor.bornCfg is RoleBornCfg roleBornCfg))
            {
                LogProxy.LogErrorFormat("创建交互物组件失败 insID = {0}", this.actor.insID);
                return;
            }

            if (!TbUtil.interActorComponentCfgs.TryGetValue(roleBornCfg.InterActorComponentId, out InterActorComponentConfig cfg))
            {
                _state = InterActorState.Not;
                return;
            }

            _cfg = cfg;
            _InterActorId = roleBornCfg.InterActorId;
            _SetBtnDesc();
            _state = roleBornCfg.interActorState;
            
            if (!string.IsNullOrEmpty(roleBornCfg.InterActorDesc))
            {
                _desc = roleBornCfg.InterActorDesc;
            }
            
            if (_cfg.DefaultEnable == (int) InterActorBornState.Open)
            {
                Enable();
            }

            foreach (var triggleID in _cfg.TriggleIDs)
            {
                _actorContext.actor = this.actor;
                _triggerInsIDs.Add(battle.triggerMgr.AddTrigger(triggleID, _actorContext));
            }
        }
        
        public override void OnRecycle()
        {
            _checkActors.Clear();
            _checkActorsAndTimes.Clear();
            _lastCheckTime = 0;
            _state = InterActorState.Not;
            _btnDescList.Clear();
            _cfg = null;
            //移除触发器
            foreach (var triggerInsID in _triggerInsIDs)
            {
                battle.triggerMgr.RemoveTrigger(triggerInsID);
            }
            _triggerInsIDs.Clear();
        }
        
        protected override void OnUpdate()
        {
            base.OnUpdate();
            if(_cfg == null) return;
            
            switch (_state)
            {
                case InterActorState.Check:
                {
                    if(_lastCheckTime == 0)
                    {
                        _lastCheckTime = Time.realtimeSinceStartup;
                    }

                    var intervalTime = Time.realtimeSinceStartup - _lastCheckTime;
                    if (intervalTime > _checkInterval)
                    {
                        _CheckObj(intervalTime);
                        _lastCheckTime = Time.realtimeSinceStartup;
                    }
                }
                    break;
                case InterActorState.Doing:
                {
                    var actors = _FindObj();
                    if (actors.Count <= 0)
                    {
                        _CloseUI(); 
                        _state = InterActorState.Check;
                    }
                }
                    break;
                case InterActorState.Done:
                {
                    if (_cfg.AllowRepeat == (int)InterActorAllowRepeat.Allow &&
                        Time.realtimeSinceStartup - _lastCheckDoneTime > _cfg.RepetitionInterval)
                    {
                        Enable();
                    }
                }
                    break;
            }
        }

        /// <summary>
        /// 启用交互物
        /// </summary>
        /// <param name="cfg"></param>
        public void Enable(bool onEnable = true)
        {
            if (onEnable)
            {
                _state = InterActorState.Check;
            }
            else
            {
                _state = InterActorState.Not;
            }
        }
        /// <summary>
        /// 检测周围可以交互的物体
        /// </summary>
        private void _CheckObj(float checkTime)
        {
            _FindObj();
            
            //如果激活时间小于等于0 
            if (_cfg.EnableTime <= 0 && _checkActors.Count > 0)
            {
                _Interaction((InterActorCheckType)_cfg.InteractType);
                _checkActorsAndTimes.Clear();
                return;
            }
            
            //时间判断
            foreach (var checkActor in _checkActors)
            {
                if (_checkActorsAndTimes.ContainsKey(checkActor.insID))
                {
                    _checkActorsAndTimes[checkActor.insID] += checkTime;
                    
                    if (_checkActorsAndTimes[checkActor.insID] < _cfg.EnableTime)
                    {
                        continue;
                    }
                    
                    _Interaction((InterActorCheckType)_cfg.InteractType);
                    _checkActorsAndTimes.Clear();
                    break;
                }
                else
                {
                    _checkActorsAndTimes.Add(checkActor.insID, 0.0f);
                }
            }
        }

        private List<Actor> _FindObj()
        {
            var findActors = Battle.Instance.actorMgr.actors;
            _checkActors.Clear();
            
            foreach (var findActor in findActors)
            {
                //自身跳过
                if (findActor == this.actor)
                {
                    continue;
                }
                
                //check 类型
                switch ((InterActorCheckActorType)_cfg.InteractObject)
                {
                    case InterActorCheckActorType.Girl:
                    {
                        if (!findActor.IsGirl())
                        {
                            continue;
                        }
                    }
                        break;
                    case InterActorCheckActorType.Boy:
                    {
                        if (!findActor.IsBoy())
                        {
                            continue;
                        }
                    }
                        break;
                    case InterActorCheckActorType.Monster:
                    {
                        if (!findActor.IsMonster())
                        {
                            continue;
                        }
                    }
                        break;
                    case InterActorCheckActorType.All:
                    {
                        if (!(findActor.IsMonster() || findActor.IsGirl() || findActor.IsBoy()))
                        {
                            continue;
                        }
                    }
                        break;
                }

                //check 半径
                float distance = BattleUtil.GetActorDistance(findActor, actor);
                if (distance > _cfg.EnableRadius)
                {
                    continue;
                }
                
                _checkActors.Add(findActor);
            }

            return _checkActors;
        }
        
        /// <summary>
        /// 交互物交互
        /// </summary>
        /// <param name="type"></param>
        private void _Interaction(InterActorCheckType type)
        {
            switch (type)
            {
                case InterActorCheckType.DirectConfirm:
                {
                    _state = InterActorState.Done;
                    _ActivateDone();
                }
                    break;
                case InterActorCheckType.UIConfirm:
                {
                    _state = InterActorState.Doing;
                    _PopUI();
                }
                    break;
            }
        }

        /// <summary>
        /// 交互完成
        /// res = -1 表示交互失败 即直接关闭交互界面
        /// res = 0 表示直接交互完成，不需要点按钮
        /// res = 1 2 3 4 表示点击了那个按钮交互完成
        /// </summary>
        private void _ActivateDone(int res = 0)
        {
            if (res == -1)
            {
                _state = InterActorState.Check;
            }
            else
            {
                _state = InterActorState.Done;
                _lastCheckDoneTime = Time.realtimeSinceStartup;
            }

            if (res > 0)
            {
                _CloseUI();
            }
            
            var eventData = battle.eventMgr.GetEvent<EventInterActorDone>();
            eventData.Init(_InterActorId, res, _cfg.ID, actor.insID);
            battle.eventMgr.Dispatch(EventType.InterActorDone, eventData);
            
            LogProxy.LogFormat("关卡编辑器ID = {0} 交互物模板 ID = {1} insID = {2} 交互完成 ，交互结果 = {3}",_InterActorId, _cfg.ID, this.actor.insID, res);
        }
        
        /// <summary>
        /// 弹出交互的UI
        /// </summary>
        private void _PopUI()
        {
            BattleEnv.LuaBridge.ShowBattleInterActorPopup(_desc, _btnDescList, _action);
        }

        /// <summary>
        /// 弹出交互的UI
        /// </summary>
        private void _CloseUI()
        {
            BattleEnv.LuaBridge.CloseBattleInterActorPopup();
        }
        
        private void _SetBtnDesc()
        {
            _desc = BattleEnv.ClientBridge.GetUIText(_cfg.DesText);
            _btnDescList.Clear();
            if(_cfg.ButtonText1 > 0) _btnDescList.Add(_cfg.ButtonText1);
            if(_cfg.ButtonText2 > 0) _btnDescList.Add(_cfg.ButtonText2);
            if(_cfg.ButtonText3 > 0) _btnDescList.Add(_cfg.ButtonText3);
            if(_cfg.ButtonText4 > 0) _btnDescList.Add(_cfg.ButtonText4);
        }
    }
}