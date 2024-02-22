using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle{

	[Category("X3Battle/Actor")]
	[Description("销毁单位")]
	public class DestroyActor : BattleAction{
        //This is called once each time the task is enabled.
        //Call EndAction() to mark the action as finished, either in success or failure.
        //EndAction can be called from anywhere.
        protected override void OnExecute(){
            Battle.Instance.actorMgr.RecycleActor(_actor);
            EndAction();
        }
    }
}
