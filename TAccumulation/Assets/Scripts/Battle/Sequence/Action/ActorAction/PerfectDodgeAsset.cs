using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/触发完美闪避")]
    [Serializable]
    public class PerfectDodgeAsset : BSActionAsset<PerfectDodge>
    {

    }

    public class PerfectDodge : BSAction<PerfectDodgeAsset>
    {
        protected override void _OnEnter()
        {
            Battle.Instance.eventMgr.Dispatch(EventType.OnPerfectDodge, null);
        }   
    }
}