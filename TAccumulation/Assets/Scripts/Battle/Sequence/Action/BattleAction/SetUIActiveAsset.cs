using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("Battle动作/设置UI显隐")]
    [Serializable]
    public class SetUIActiveAsset : BSActionAsset<ActionSetUIActive>
    {
        [LabelText("是否显示UI")] 
        public bool isActive = true;
        
        [HideInInspector]
        [LabelText("是否一直持续", showCondition = "!isActive")]
        public bool isEnternal = true;

        [HideInInspector]
        [LabelText("时长", showCondition = "!isEnternal")]
        public float time;
    }

    public class ActionSetUIActive : BSAction<SetUIActiveAsset>
    {
        protected override void _OnEnter()
        {
            if (clip.isActive)
            {
                BattleUtil.SetUIActive(true);
            }
            else
            {
                BattleUtil.SetUIActive(false);
                /*if (clip.isEnternal)
                {
                    BattleUtil.SetUIActive(false);
                }
                else
                {
                    var eventData = context.battle.eventMgr.GetEvent<EventUIActive>();
                    eventData.Init(false, clip.time, true);
                    context.battle.eventMgr.Dispatch(EventType.BattleUIActive, eventData);
                }*/
            }
        }   
    }
}
