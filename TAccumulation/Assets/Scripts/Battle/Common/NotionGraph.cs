using System;
using NodeCanvas.Framework;
using NodeCanvas.StateMachines;
using UnityEngine;
using UnityEngine.Profiling;
using X3.CustomEvent;

namespace X3Battle
{
    public class NotionGraph<T> where T : GraphOwner
    {
        private bool _isInited;

        public T owner { get; protected set; }
        public Transform trans { get; protected set; }
        public Graph graph => owner?.graph;
        public bool isBoundGraph => null != owner && owner.graphIsBound;
        public bool isRunning => null != graph && graph.isRunning;
        public bool isPaused => null != graph && graph.isPaused;
        public bool isValid => owner != null && graph != null;
        public bool isStarted { get; private set; }

        public void Init(GraphContext context, string relativePath, BattleResType resType, Transform parent = null, bool autoStart = true)
        {
            try
            {
                if (_isInited)
                    return;
                _isInited = true;
#if UNITY_EDITOR
                using (ProfilerDefine.NotionGraphInitIsExistsPMarker.Auto())
                {
                    if (!BattleResMgr.Instance.IsExists(relativePath, resType))
                    {
                        PapeGames.X3.LogProxy.LogError("NotionGraph:图资源缺失：" +
                                                       BattleUtil.GetResPath(relativePath, resType));
                        return;
                    }
                }
#endif
                var go = BattleResMgr.Instance.Load<GameObject>(relativePath, resType);
                if (go == null)
                {
                    return;
                }

                var owner = go.GetComponent<T>();
                if (owner == null)
                {
                    PapeGames.X3.LogProxy.LogError($"NotionGraph:组件不存在，请检查！！componentType：{typeof(T)} relativePath：{relativePath} resType:{resType.ToString()}");
                    return;
                }

                this.owner = owner;
                trans = owner.transform;
                if (parent != null) trans.SetParentInEditor(parent);
                owner.blackboard.SetVariableValue(BattleConst.ContextVariableName, context);
                owner.firstActivation = GraphOwner.FirstActivation.OnStart;
                owner.enableAction = GraphOwner.EnableAction.DoNothing;
                owner.disableAction = GraphOwner.DisableAction.DoNothing;
                owner.updateMode = Graph.UpdateMode.Manual;

                if (!autoStart) return;
                _Start();
            }
            catch (Exception e)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("NotionGraph:{0} , 战斗资源类型 {1} 加载失败，errorMsg:{2}", relativePath, resType, e);
            }
        }

        public void OnDestroy()
        {
            if (!_isInited)
            {
                return;
            }

            if (null != owner)
            {
                if (isRunning) owner.StopBehaviour();
                var context = owner.blackboard.GetVariableValue<GraphContext>(BattleConst.ContextVariableName);
                context?.eventMgr?.Clear();
                owner.blackboard.Reset();
                BattleResMgr.Instance.Unload(owner.gameObject);
            }

            _isInited = false;
            isStarted = false;
            trans = null;
            owner = null;
        }

        public void Update(float delaTime)
        {
            if (!isStarted || !isRunning)
            {
                return;
            }

            graph?.UpdateGraph(delaTime);
        }

        public void Disable(bool disabled)
        {
            if (!isStarted || null == owner) return;
            if (disabled)
            {
                if (!isRunning)
                {
                    return;
                }

                owner.StopBehaviour();
            }
            else
            {
                if (isRunning && !isPaused)
                {
                    return;
                }

                owner.StartBehaviour();
            }
        }

        public void Paused(bool paused)
        {
            if (!isStarted || null == owner) return;
            if (paused)
            {
                if (!isRunning || isPaused)
                {
                    return;
                }

                owner.PauseBehaviour();
            }
            else
            {
                if (isRunning && !isPaused)
                {
                    return;
                }

                owner.StartBehaviour();
            }
        }

        public void Restart(bool isResetBlackboard = false)
        {
            if (isResetBlackboard && null != owner)
            {
                var context = owner.blackboard.GetVariableValue<GraphContext>(BattleConst.ContextVariableName);
                owner.blackboard.Reset();
                owner.blackboard.SetVariableValue(BattleConst.ContextVariableName, context);
            }

            if (!isStarted)
            {
                _Start();
            }
            else
            {
                owner?.RestartBehaviour();
            }
        }

        public bool TriggerFSMEvent(string eventName)
        {
            if (graph is FSM fsm)
            {
                return fsm.TriggerEvent(eventName);
            }

            return false;
        }

        public void DispatchEvent(NotionGraphEventType key, IEventData arg, bool autoRecycle = true)
        {
            var context = owner.blackboard.GetVariableValue<GraphContext>(BattleConst.ContextVariableName);
            context?.eventMgr?.Dispatch(key, arg, autoRecycle);
        }

        public Variable<T> GetVariable<T>(string name, bool fromGraphBlackboard = false)
        {
            return fromGraphBlackboard ? graph?.blackboard.GetVariable<T>(name) : owner?.blackboard.GetVariable<T>(name);
        }

        public void SetVariableValue<T>(string varName, T _value, bool toGraphBlackboard = false)
        {
            if (null == graph)
            {
                return;
            }

            if (toGraphBlackboard)
            {
                graph.blackboard.SetVariableValue(varName, _value);
            }
            else
            {
                owner.blackboard.SetVariableValue(varName, _value);
            }
        }

        public T GetVariableValue<T>(string name, bool fromGraphBlackboard = false)
        {
            if (null == graph)
            {
                return default;
            }

            return fromGraphBlackboard ? graph.blackboard.GetVariableValue<T>(name) : owner.blackboard.GetVariableValue<T>(name);
        }

        private void _Start()
        {
            if (isStarted) return;
            isStarted = true;
            if (null == owner) return;
            owner.StartBehaviour();
        }
    }
}