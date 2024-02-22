using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("展示引导提示\nActiveGuideTips")]
    public class FAShowGuideTips : FlowAction
    {
        public BBParameter<int> id = new BBParameter<int>();
        private FlowOutput _playEndOutput;
        private DialogueNode node = null;
        private Flow _flow;
        
        protected override void _OnRegisterPorts()
        {
            var o = AddFlowOutput("Out");
            _playEndOutput = AddFlowOutput("PlayEnd");
            AddFlowInput("In", (FlowCanvas.Flow f) =>
            {
                _Invoke();
                _RemoveListener();
                // DONE: 直接出.
                o.Call(f);
                
                //没有配置直接出
                var guideConfig = TbUtil.GetCfg<BattleGuide>(id.value);
                if (guideConfig == null || guideConfig.Sound == "")
                {
                    _playEndOutput.Call(f);
                    return;
                }
                
                //没有播放成功 直接出
                node =  _battle.dialogue.Play(guideConfig.Sound);
                if (node == null)
                {
                    _playEndOutput.Call(f);
                    return;
                }
                _flow = f;

                _AddListener();
            });
            
        }
        protected override void _Invoke()
        {
            var guideConfig = TbUtil.GetCfg<BattleGuide>(id.value);
            if (guideConfig == null)
            {
                return;
            }
            TipType tipType = (TipType)guideConfig.Type;
            switch (tipType)
            {
                case TipType.CenterTip:
                case TipType.LeftBoyDialog:
                    BattleEnv.LuaBridge.SetUiTipVisible(true, id.value);
                    break;
                case TipType.AffixTip:
                    BattleEnv.LuaBridge.SetAffixVisible(true, id.value);
                    break;
                case TipType.RightLevelTarget:
                case TipType.RightLevelTarget2:
                    BattleUtil.SetMissionTipsVisible(ShowMissionTipsType.Show, id.value);
                    break;
            }
        }
        
        private void _AddListener()
        {
            _battle.eventMgr.AddListener<EventDialoguePlayError>(EventType.DialoguePlayError, _DialoguePlayError,"_DialoguePlayError");
            _battle.eventMgr.AddListener<EventDialoguePlayEnd>(EventType.DialoguePlayEnd, _DialoguePlayEnd,"_DialoguePlayEnd");
        }

        private void _RemoveListener()
        {
            _battle.eventMgr.RemoveListener<EventDialoguePlayError>(EventType.DialoguePlayError, _DialoguePlayError);
            _battle.eventMgr.RemoveListener<EventDialoguePlayEnd>(EventType.DialoguePlayEnd, _DialoguePlayEnd);
        }

        private void _DialoguePlayError(EventDialoguePlayError eventDialoguePlayError)
        {
            if (node == eventDialoguePlayError.node)
            {
                _playEndOutput.Call(_flow);
                _RemoveListener();
            }
        }
        
        private void _DialoguePlayEnd(EventDialoguePlayEnd eventDialoguePlayEnd)
        {
            if (node == eventDialoguePlayEnd.node)
            {
                _playEndOutput.Call(_flow);
                _RemoveListener();
            }
        }
        
#if UNITY_EDITOR
        protected override void OnNodeGUI()
        {
            base.OnNodeGUI();
            UnityEditor.EditorGUILayout.LabelField($"引导提示ID: {id.value.ToString()}");
        }
#endif
    }
}
