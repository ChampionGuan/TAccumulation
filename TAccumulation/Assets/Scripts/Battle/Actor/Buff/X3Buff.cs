using System;
using PapeGames.X3;
using System.Collections.Generic;
using System.Linq;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class X3Buff : IBuff
    {
        public static BuffCfg sDynamicFixedBuffCfg  = new BuffCfg()
        {
            ID = -1,//固定-1
            Name = "固定免配置的添加动态BuffAction的buff配置",
            Time = -1f,
            MutexRelation = MutexRelationType.NotReplace,
            MaxStack = 0,
            Triggers = Array.Empty<BuffTriggerConfig>(),
            LayersDatas = new List<LayersData>()
            {
                new LayersData(),
            },
        };
        public static BuffCfg sDamageTestBuffCfg = new BuffCfg()
        {
            ID = -1,//固定-1
            Name = "调试器测试受击状态用buff",
            Time = -1f,
            MutexRelation = MutexRelationType.NotReplace,
            MaxStack = 0,
            Triggers = Array.Empty<BuffTriggerConfig>(),
            LayersDatas = new List<LayersData>()
            {
                new LayersData(){},
            },
        };
        public int level { get; private set; }
        public Actor caster { get; private set; }
        public int actionTypes { get; private set; }
        public string icon { get; private set; }

        public bool showLayer
        {
            get => config.IconFlag == IconShowType.ShowWithLayer&&config.MultiplyStack;
        }

        private List<BuffActionBase> _buffActions = new List<BuffActionBase>();
        private List<int> _triggerInsIDs;
        private Actor _master;

        public override int GetLevel()
        {
            return level;
        }

        public override int GetLayer()
        {
            return layer;
        }

        public X3Buff()
        {
            _triggerInsIDs = new List<int>();
        }
        public void Init(BuffOwner owner, BuffCfg config, float time, int level, int layer = 1, Actor caster = null, DamageExporter damageExporter = null)
        {
            base.Init(owner, config, time, damageExporter);
            LogProxy.Log("Create Buff " + " id = " + config.ID + " skilltype = " + GetSkillType());
            this.level = level;
            icon = config.BuffIcon;
            _triggerInsIDs.Clear();
            _buffActions.Clear();
            this.caster = caster;
            if (caster != actor) this.caster.AddRef(this);
            //层数初始化（没有依赖actions的逻辑）但是会调用和layer相关的damageBox，目前仅有BuffHPShield在受击时获取action
            //部分buffAction在init的时候依赖layer
            _buffLayers.Init(this, layer, config.FxOnlyOne);
            
            if (config.BuffActions != null)
            {
                foreach (var action in config.BuffActions)
                {
                    var actionIns = action.DeepCopy();
                    actionIns.Init(this);
                    _buffActions.Add(actionIns);
                }
            }

            //配置在buff及BattleBuff表中的属性变化配置Action
            var buffActionAttrModifier =  ObjectPoolUtility.BuffActionAttrModifierPool.Get();
            buffActionAttrModifier.Init(this);
            _buffActions.Add(buffActionAttrModifier);
            
            _buffLayers.InitLayerDamage();
        }
        /// <summary>
        /// 动态buff的添加buffaction，不能添加引用资源的action
        /// </summary>
        /// <param name="action">不能添加引用了资源的action</param>
        public void AddDynamicBuffAction(BuffActionBase action)
        {
            action.Init(this);
            _buffActions.Add(action);
        }
        
        /// <summary>
        /// buff中是否有对应的action
        /// </summary>
        /// <param name="actionType"></param> 每中buffaction都定义一个action Type值为2的整数次方
        /// <returns></returns>
        public bool HasBuffAction(BuffAction actionType)
        {
            for (int i = 0; i < _buffActions.Count; i++)
            {
                if (_buffActions[i].buffActionType == actionType)
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// 获取buff中的action
        /// </summary>
        /// <param name="actionType"></param> 值为2的整数次方
        /// <returns></returns>
        public BuffActionBase GetBuffAction(BuffAction actionType)
        {
            for (int i = 0; i < _buffActions.Count; i++)
            {
                if (_buffActions[i].buffActionType == actionType)
                    return _buffActions[i];
            }

            return null;
        }

        public override Actor GetCaster()
        {
            if (_master != null)
            {
                return _master;
            }
            
            Actor master = caster;
            while (master != null)
            {
                if (master.attributeOwner != null)
                {
                    break;
                }

                master = master.master;
            }

            _master = master;
            return master;
        }

        public override void OnAddRepeatedly()
        {
            foreach (var buffAction in _buffActions)
            {
                buffAction.OnAddRepeatedly(layer);
            }
        }
        public void OnCreate()
        {
            // buff被创建
            // PapeGames.X3.LogProxy.Log($"Buff: {_config.ID} is Added");
            foreach (var buffAction in _buffActions)
            {
                buffAction.OnAdd(layer);
            }

            foreach (var buffTrigger in config.Triggers)
            {
                if (buffTrigger.ID <= 0)
                    continue;

                if (buffTrigger.attachToBuff)
                {
                    // 持续时间与buff绑定
                    int insID = owner.battle.triggerMgr.AddTrigger(buffTrigger.ID, new TriggerBuffContext(this));
                    _triggerInsIDs.Add(insID);
                }
                else
                {
                    // 使用配置的时长
                    int insID = owner.battle.triggerMgr.AddTrigger(buffTrigger.ID,
                        new TriggerBuffContext(this, buffTrigger.time));
                    _triggerInsIDs.Add(insID);
                }
            }
            
            SendBuffAddEvent();
        }

        public void SendBuffAddEvent(bool isNewCreate = true)
        {
            using (ProfilerDefine.SendBuffAddEventPMarker.Auto())
            {
                var eventData = _owner.battle.eventMgr.GetEvent<EventBuffChange>();
                eventData.Init(this, caster, _owner.actor, BuffChangeType.Add, EventBuffChange.DestroyedReason.None);
                _owner.battle.eventMgr.Dispatch(isNewCreate ? EventType.BuffChange : EventType.BuffAdd, eventData);
            }
        }

        public override void OnUpdate(float deltaTime)
        {
            base.OnUpdate(deltaTime);
            
            if (_totalTime > 0)
            {
                _curTime += deltaTime;
            }

            foreach (var buffAction in _buffActions)
            {
                buffAction.Update(deltaTime);
            }
        }

        public override void AddLayer(int num)
        {
            using (ProfilerDefine.X3BuffAddLayerPMarker.Auto())
            {
                if (_buffLayers.LayerChange(layer + num))
                {
                    foreach (var buffAction in _buffActions)
                    {
                        buffAction.OnAddLayer(num);
                    }
                }

                if (config.MultiplyStack)
                {
                    var eventData = _owner.battle.eventMgr.GetEvent<EventBuffLayerChange>();
                    eventData.Init(this, caster, _owner.actor, num, BuffChangeType.AddLayer);
                    _owner.battle.eventMgr.Dispatch(EventType.BuffLayerChange, eventData);
                }
            }
        }

        public override void ReduceLayer(int num)
        {
            using (ProfilerDefine.X3BuffReduceLayerPMarker.Auto())
            {

                if (layer < num)
                    num = layer;
                if (_buffLayers.LayerChange(layer - num))
                {
                    foreach (var buffAction in _buffActions)
                    {
                        buffAction.OnRemoveLayer(num);
                    }
                }

                if (config.MultiplyStack)
                {
                    var eventData = _owner.battle.eventMgr.GetEvent<EventBuffLayerChange>();
                    eventData.Init(this, caster, _owner.actor, num, BuffChangeType.ReduceLayer);
                    _owner.battle.eventMgr.Dispatch(EventType.BuffLayerChange, eventData);
                }

                //清掉额外临时时间
                _extraTime = 0;
            }
        }

        public void Destroy(EventBuffChange.DestroyedReason destroyedReason)
        {
            if (isDestroyed)
            {
                return;
            }
            isDestroyed = true;
            
            //发送事件
            LogProxy.Log($"Buff id: {config.ID} 发起销毁");
            //buff的触发器中可能监听BuffChange事件用于监听buff消除，先发事件再销毁buff
            var eventData = owner.battle.eventMgr.GetEvent<EventBuffChange>();
            eventData.Init(this, caster, owner.actor, BuffChangeType.Destroy,destroyedReason);
            owner.battle.eventMgr.Dispatch(EventType.BuffChange, eventData);
            //停下功能
            foreach (var buffAction in _buffActions)
            {
                buffAction.OnRemoveLayer(layer); // 移除剩余层数
                buffAction.OnDestroy();
            }
            
            _buffLayers.Destroy();
            
            //移除触发器
            foreach (int insID in _triggerInsIDs)
            {
                owner.battle.triggerMgr.RemoveTrigger(insID);
            }
            
            _triggerInsIDs.Clear();
        }
        
        //作为DamageExporter被销毁时，只是标记被销毁，真正销毁在下一帧的update
        public override void Destroy()
        {
            Destroy(EventBuffChange.DestroyedReason.Others);
        }

        /// <summary>
        /// 真正执行销毁,脱离BuffOwner的管理
        /// </summary>
        public void Recycle()
        {
            caster.RemoveRef(this);
            caster = null;
            _master = null;

            
            base.Destroy();
            _buffActions.Clear();
            ObjectPoolUtility.X3BuffPool.Release(this);
        }
        
        public void Reset(float newTime)
        {
            RefreshTime();
            _totalTime = newTime;
            foreach (var buffAction in _buffActions)
            {
                buffAction.OnReset();
            }
            foreach (int insID in _triggerInsIDs)
            {
                owner.battle.triggerMgr.RemoveTrigger(insID);
            }
            
            _triggerInsIDs.Clear();
            
            foreach (var buffTrigger in config.Triggers)
            {
                if (buffTrigger.ID <= 0)
                    continue;

                //TODO:Trigger提供reset接口
                if (buffTrigger.attachToBuff)
                {
                    // 持续时间与buff绑定
                    int insID = owner.battle.triggerMgr.AddTrigger(buffTrigger.ID, new TriggerBuffContext(this));
                    _triggerInsIDs.Add(insID);
                }
                else
                {
                    // 使用配置的时长
                    int insID = owner.battle.triggerMgr.AddTrigger(buffTrigger.ID,
                        new TriggerBuffContext(this, buffTrigger.time));
                    _triggerInsIDs.Add(insID);
                }
            }

        }
    }
}