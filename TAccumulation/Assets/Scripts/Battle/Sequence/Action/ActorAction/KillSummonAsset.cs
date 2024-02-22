using System;
using System.Collections.Generic;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/杀死召唤物")]
    [Serializable]
    public class KillSummonAsset : BSActionAsset<ActionKillSummon>
    {
    }

    public class ActionKillSummon : BSAction<KillSummonAsset>
    {
        protected override void _OnEnter()
        {
            if (context.actor == null)
            {
                return;
            }

            var list = ObjectPoolUtility.CommonActorList.Get();
            context.actor.GetCreatures(null, list);

            // DONE: 杀死召唤物.
            for (int i = 0; i < list.Count; i++)
            {
                list[i].Dead();
            }

            ObjectPoolUtility.CommonActorList.Release(list);
        }   
    }
}