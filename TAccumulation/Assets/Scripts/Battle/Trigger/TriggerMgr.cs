using System.Collections.Generic;
using UnityEngine.Profiling;
using X3.CustomEvent;

namespace X3Battle
{
    public class TriggerMgr : BattleComponent
    {
        private List<TriggerBase> _triggers = new List<TriggerBase>(20);
        private int _idGenerate = 0;

        public TriggerMgr() : base(BattleComponentType.TriggerMgr)
        {
            
        }

        public int AddTrigger(int triggerId, TriggerContext context, bool autoStart = true)
        {
            if (triggerId == 0)
            {
                return -1;
            }

            using (ProfilerDefine.TriggerMgrAddTriggerPMarker.Auto())
            {
                int insId = ++_idGenerate;
                var triggerFlow = ObjectPoolUtility.TriggerFlowPool.Get();
                triggerFlow.Init(insId, triggerId, context, autoStart);
                _triggers.Add(triggerFlow);

                PapeGames.X3.LogProxy.LogFormat("[TriggerMgr] 添加触发器 InsId={0}, triggerId={1}", insId, triggerId);
                return insId;
            }
        }
        
        public bool RemoveTrigger(int triggerInsId)
        {
            for (int i = 0; i < _triggers.Count; i++)
            {
                if (_triggers[i].insId == triggerInsId)
                {
                    return _RemoveTriggerAt(i);
                }
            }

            return false;
        }

        public void DisableTrigger(int triggerInsId, bool disable)
        {
            var trigger = _GetTrigger(triggerInsId);
            if (trigger == null)
                return;
            trigger.Disable(disable);
        }

        public void PreloadTrigger(int triggerId, TriggerContext context)
        {
            if (!battle.isPreloading) return;
            AddTrigger(triggerId, context, false);
        }
        
        public void PreloadFinished()
        {
            // DONE: 先预热Trigger
            for (int i = 0; i < _triggers.Count; i++)
            {
                if (_triggers[i].autoStart)
                {
                    continue;
                }

                DisableTrigger(_triggers[i].insId, false);
            }

            // DONE: Preload结束, 倒序移除所有触发器.
            for (int i = _triggers.Count - 1; i >= 0; i--)
            {
                _RemoveTriggerAt(i);
            }
        }

        public void TriggerEvent(int triggerInsId, NotionGraphEventType key, IEventData arg, bool autoRecycle = true)
        {
            var trigger = _GetTrigger(triggerInsId);
            if (trigger == null)
                return;
            trigger.TriggerEvent(key, arg, autoRecycle);
        }

        protected override void OnAwake()
        {
            
        }

        protected override void OnDestroy()
        {
            // DONE: 战斗结束, 倒序移除所有触发器.
            for (int i = _triggers.Count - 1; i >= 0; i--)
            {
                _RemoveTriggerAt(i);
            }
        }
        
        protected override void OnUpdate()
        {
            for (int i = 0; i < _triggers.Count; i++)
            {
                // DONE: 触发器死亡移除.
                if (_triggers[i].isEnd)
                {
                    if (_RemoveTriggerAt(i))
                    {
                        i--;
                    }

                    continue;
                }

                _triggers[i].Update();
            }
        }
        
        private bool _RemoveTriggerAt(int index)
        {
            if (index < 0 || index >= _triggers.Count)
            {
                return false;
            }

            PapeGames.X3.LogProxy.LogFormat("[TriggerMgr] 移除触发器 InsId={0}, triggerId={1}", _triggers[index].insId, _triggers[index].configId);
            var trigger = _triggers[index];
            _triggers.RemoveAt(index);
            trigger.Destroy();
            
            if (trigger is TriggerFlow triggerFlow)
            {
                ObjectPoolUtility.TriggerFlowPool.Release(triggerFlow);
            }
            return true;
        }

        private TriggerBase _GetTrigger(int insId)
        {
            for (var i = _triggers.Count - 1; i >= 0; i--)
            {
                if (_triggers[i].insId == insId)
                {
                    return _triggers[i];
                }
            }
            return null;
        }
    }
}