using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle{

	[Category("X3Battle/Actor")]
	[Description("播放Timeline")]
	public class PlayTimeline : BattleAction{
		[Tooltip("资源相对路径，如果不存在，则action不做任何事情")]
		public BBParameter<string> relativePath = new BBParameter<string>();
		[Tooltip("是否等待timeline结束")]
        public BBParameter<bool> waitFinish = new BBParameter<bool>();
        //This is called once each time the task is enabled.
        //Call EndAction() to mark the action as finished, either in success or failure.
        //EndAction can be called from anywhere.
        protected override void OnExecute(){
			if(string.IsNullOrEmpty(relativePath.GetValue()))
            {
				EndAction();
				return;
            }

			if(waitFinish.GetValue())
            {
                _actor.sequencePlayer.PlayBornTimeline(relativePath.GetValue(), _OnTimelineEnd);
            }
            else
            {
                _actor.sequencePlayer.PlayBornTimeline(relativePath.GetValue());
                EndAction(true);
            }
		}

		protected void _OnTimelineEnd()
        {
            EndAction(true);
        }
    }
}
