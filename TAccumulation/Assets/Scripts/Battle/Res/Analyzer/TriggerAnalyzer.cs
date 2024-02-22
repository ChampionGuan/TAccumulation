using FlowCanvas;
using NodeCanvas.Framework;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    /// <summary>
    /// // 解析触发器
    /// </summary>
    public class TriggerAnalyzer : ResAnalyzer
    {
        private int _triggerID;
        public override int ResID => _triggerID;
        
        public TriggerAnalyzer(ResModule parent, int triggerID) : base(parent)
        {
            _triggerID = triggerID;
        }

        protected override void DirectAnalyze()
        {
            if (_triggerID <= 0)
            {
                return;
            }

            var triggerCfg = TbUtil.GetCfg<TriggerCfg>(_triggerID);
            if (triggerCfg == null)
            {
                return;
            }

            if (string.IsNullOrEmpty(triggerCfg.GraphPath) || string.IsNullOrWhiteSpace(triggerCfg.GraphPath))
            {
                return;
            }

            ResModule performTriggerModule = resModule.AddChild("performTriggerAsset");
            performTriggerModule.AddResultByPath(triggerCfg.GraphPath, BattleResType.TriggerGraph);
            AnalyzeFromLoadedRes<GameObject>(triggerCfg.GraphPath, BattleResType.TriggerGraph, AnalyzerTriggerGraph,
                performTriggerModule, triggerCfg);
        }

        private void AnalyzerTriggerGraph(GameObject triggerGraph, ResModule resModule, object arg)
        {
            if (triggerGraph == null)
            {
                return;
            }

            var triggerCfg = arg as TriggerCfg;
            var flowScriptController = triggerGraph.GetComponent<FlowScriptController>();
            if (flowScriptController != null)
            {
#if UNITY_EDITOR
                // DONE: 仅编辑器环境下需要加该步骤.
                if (!Application.isPlaying)
                {
                    if (flowScriptController.graph == null)
                    {
                        flowScriptController.Validate();
                    }
                }
#endif

                if (triggerCfg != null && !string.IsNullOrEmpty(triggerCfg.ConfigPath) &&
                    !string.IsNullOrWhiteSpace(triggerCfg.ConfigPath))
                {
                    resModule.AddResultByPath(triggerCfg.ConfigPath, BattleResType.TriggerBlackboard);
                    var blackboard =
                        BattleResMgr.Instance.Load<AssetBlackboard>(triggerCfg.ConfigPath,
                            BattleResType.TriggerBlackboard);

                    // DONE: 将配置文件的黑板设置过来.
                    if (blackboard != null && flowScriptController.blackboard != null)
                    {
                        var variables = blackboard.GetVariables();
                        foreach (Variable variable in variables)
                        {
                            if (variable == null)
                                continue;
                            flowScriptController.blackboard.SetVariableValue(variable.name, variable.value);
                        }
                    }

                    // DONE: 黑板用完了, 卸载掉.
                    if (blackboard != null)
                    {
                        BattleResMgr.Instance.Unload(blackboard);
                    }
                }

                // DONE: 对图进行分析.
                ResAnalyzeUtil.AnalyzerGraph(resModule, flowScriptController.graph);
            }

        }


        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is TriggerAnalyzer analyzer)
            {
                return analyzer._triggerID == _triggerID;
            }

            return false;
        }
    }
}