using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    // todo 和NodeCanvas整合一下
    [Category("X3Battle/关卡/Action")]
    [Name("播放Timeline\nPlayTimeline")]
    public class MPlayTimeline : FlowAction
    {
        [Tooltip("资源相对路径")]
        public BBParameter<string> timelineName = new BBParameter<string>();
        
        private FlowOutput _out;
        private FlowOutput _waitOut;

        protected override void _OnRegisterPorts()
        {
            AddFlowInput(" ", Invoke);
            _out = AddFlowOutput(" ");
            _waitOut = AddFlowOutput("waitOut");
        }
        
        public void Invoke(Flow flow)
        {
            // todo 使用合适的play timeline 接口
            _actor.sequencePlayer.PlayBornTimeline(timelineName.value, OnStop);
            _out.Call(new Flow());
        }

        private void OnStop()
        {
            _waitOut.Call(new Flow());
        }
        
    }
}
