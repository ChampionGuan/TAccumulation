using System;
using FlowCanvas;
using NodeCanvas.Framework;
using UnityEngine;
using UnityEngine.Profiling;
using X3.CustomEvent;

namespace X3Battle
{
    public class TriggerFlow : TriggerBase, IReset
    {
        private NotionGraph<FlowScriptController> _flow;
        private Battle _battle;

        protected override void OnInit()
        {
            isEnd = true;
            AssetBlackboard assetBlackboard = null;
            try
            {
                // DONE: 加载TriggerCfg.
                var triggerCfg = TbUtil.GetCfg<TriggerCfg>(configId);
                if (triggerCfg == null)
                {
                    PapeGames.X3.LogProxy.LogError($"请联系策划【卡宝宝】解决, 触发器配置TriggerCfg不存在. configId：{configId}");
                    return;
                }

                // DONE: 加载蓝图(FlowCanvas).
                if (string.IsNullOrEmpty(triggerCfg.GraphPath) || string.IsNullOrWhiteSpace(triggerCfg.GraphPath))
                {
                    PapeGames.X3.LogProxy.LogError($"请联系策划【卡宝宝】解决, 触发器配置TriggerCfg.GraphPath配置错误, Id={configId}");
                    return;
                }
                // DONE: 最后封装触发器流图.
                _flow = ObjectPoolUtility.FlowScriptControllerPool.Get();

                Transform parent = null;
#if UNITY_EDITOR
                parent = _triggerContext.parent;
#endif
                _flow.Init(_triggerContext, triggerCfg.GraphPath, BattleResType.TriggerGraph, parent, false);
                
                // DONE: 加载蓝图配置黑板(AssetBlackboard).
                if (!string.IsNullOrEmpty(triggerCfg.ConfigPath) && !string.IsNullOrWhiteSpace(triggerCfg.ConfigPath) && _flow.owner != null)
                {
                    assetBlackboard = BattleResMgr.Instance.Load<AssetBlackboard>(triggerCfg.ConfigPath, BattleResType.TriggerBlackboard);
                    if (assetBlackboard != null)
                    {
                        using (ProfilerDefine.TriggerFlowSetVariableValuePMarker.Auto())
                        {
                            // DONE: 设置黑板.
                            var variables = ((IBlackboard)assetBlackboard).variables;
                            foreach (var variableKV in variables)
                            {
                                var variable = variableKV.Value;
                                var targetVariable = _flow.owner.blackboard.GetVariable(variable.name);
                                if (targetVariable != null)
                                {
                                    if (!_TrySetVariableValueNoGC(targetVariable, variable))
                                    {
                                        targetVariable.SetValueBoxed(variable.value);
                                    }
                                }
                            }

                        }
                    }
                    else
                    {
                        PapeGames.X3.LogProxy.LogError($"请联系策划【卡宝宝】解决, 触发器配置黑板文件不存在. Blackboard:{triggerCfg.ConfigPath}");
                    }
                }
                if (this.autoStart)
                {
                    _flow.Restart();    
                }
                
                isEnd = false;
            }
            catch (Exception e)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("蓝图 {0} 加载失败，ErrorMsg: {1}", configId, e);
            }
            finally
            {
                // DONE: 黑板用完直接销毁.
                if (assetBlackboard != null)
                {
                    BattleResMgr.Instance.Unload(assetBlackboard);
                }
            }
        }

        protected override void OnDestroy()
        {
            if (_flow == null)
                return;
            _flow.OnDestroy();
            ObjectPoolUtility.FlowScriptControllerPool.Release(_flow);
            _flow = null;
        }

        protected override void OnDisable(bool disabled)
        {
            if (this._flow == null)
                return;
            if (!this._flow.isStarted && !disabled)
            {
                this._flow.Restart();
                return;
            }
            this._flow.Disable(disabled);
        }

        protected override void OnTriggerEvent(NotionGraphEventType key, IEventData arg, bool autoRecycle = true)
        {
            this._flow.DispatchEvent(key, arg, autoRecycle);
        }

        public void Reset()
        {
            _flow = null;
            _battle = null;
        }

        private static bool _TrySetVariableValueNoGC(Variable a, Variable b)
        {
            if (a is Variable<int> intVariable)
            {
                if (b is Variable<int> intVariable2)
                {
                    intVariable.SetValue(intVariable2.value);
                    return true;
                }
            }
            else if (a is Variable<float> floatVariable)
            {
                if (b is Variable<float> floatVariable2)
                {
                    floatVariable.SetValue(floatVariable2.value);
                    return true;
                }
            }
            else if (a is Variable<double> doubleVariable)
            {
                if (b is Variable<double> doubleVariable2)
                {
                    doubleVariable.SetValue(doubleVariable2.value);
                    return true;
                }
            }

            return false;
        }
    }
}