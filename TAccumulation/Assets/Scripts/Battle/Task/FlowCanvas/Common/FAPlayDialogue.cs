using System;
using System.Collections.Generic;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("播放战斗沟通\nPlayDialogue")]
    public class FAPlayDialogue : FlowAction
    {
        public BBParameter<List<string>> keys = new BBParameter<List<string>>();
        
        private FlowOutput _playEndOutput;
        private FlowOutput _interruptOutput;
        private Flow _flow;
        private DialogueNode node = null;
        public FAPlayDialogue()
        {
        }
        
        protected override void _OnRegisterPorts()
        {
            var o = AddFlowOutput("Out");
            _playEndOutput = AddFlowOutput("PlayEnd");
            _interruptOutput = AddFlowOutput("Interrupt");
            AddFlowInput("In", (FlowCanvas.Flow f) =>
            {
                _RemoveListener();
                // DONE: 直接出.
                o.Call(f);
                
                //没有播放成功
                node =  _battle.dialogue.Play(keys.value);
                if (node == null)
                {
                    return;
                }
                _flow = f;

                _AddListener();
            });
            
            AddFlowInput("InterruptIn", (FlowCanvas.Flow f) =>
            {
                if (node != null && node == _battle.dialogue.currDialogue)
                {
                    _battle.dialogue.StopCurNode();
                    _interruptOutput.Call(f);
                }
                _RemoveListener();
            });
        }

        private void _AddListener()
        {
            _battle.eventMgr.AddListener<EventDialoguePlayError>(EventType.DialoguePlayError, _DialoguePlayError,"_DialoguePlayError");
            _battle.eventMgr.AddListener<EventDialoguePlayEnd>(EventType.DialoguePlayEnd, _DialoguePlayEnd,"_DialoguePlayEnd");
            _battle.eventMgr.AddListener<EventDialogueInterrupt>(EventType.DialogueInterrupt, _DialogueInterrupt,"_DialogueInterrupt"); 
        }

        private void _RemoveListener()
        {
            _battle.eventMgr.RemoveListener<EventDialoguePlayError>(EventType.DialoguePlayError, _DialoguePlayError);
            _battle.eventMgr.RemoveListener<EventDialoguePlayEnd>(EventType.DialoguePlayEnd, _DialoguePlayEnd);
            _battle.eventMgr.RemoveListener<EventDialogueInterrupt>(EventType.DialogueInterrupt, _DialogueInterrupt);
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
        
        private void _DialogueInterrupt(EventDialogueInterrupt eventDialogueInterrupt)
        {
            if (node == eventDialogueInterrupt.currNode)
            {
                _interruptOutput.Call(_flow);
                _RemoveListener();
            }
        }
    }
}
