using System.Collections.Generic;
using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("播放战斗沟通")]
    public class PlayDialogue : BattleAction
    {
        public BBParameter<List<string>> keys = new BBParameter<List<string>>();

        /*
        protected override string info => "播放战斗沟通";
        */
        
        protected override void OnExecute()
        {
            //ActorDialogue.Play(_actor, keys.value, weight.value, delay.value, types.isNoneOrNull ? null : types.value);
            _battle.dialogue.Play(keys.value);
            EndAction(true);
        }
    }
}
