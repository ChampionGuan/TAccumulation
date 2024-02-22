using System;
using System.Collections.Generic;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/战斗沟通")]
    [Serializable]
    public class DialogueAsset : BSActionAsset<ActionDialogue>
    {
        [LabelText("沟通Key")]
        public List<string> keys;
        // //[LabelText("沟通权重")]
        // public List<int> weight;
        // [LabelText("延时触发，单位秒，<=0表示无延时")] 
        // public float delay;
        // //[LabelText("选择角色类型")] 
        // public List<ChooseActorType> types;
    }

    public class ActionDialogue : BSAction<DialogueAsset>
    {
        protected override void _OnEnter()
        {
            //ActorDialogue.Play(context.actor,  clip.keys,  clip.weight,  clip.delay,  clip.types == null || clip.types.Count == 0 ? null :  clip.types);
           X3Battle.Battle.Instance.dialogue.Play(clip.keys);
        }   
    }
}