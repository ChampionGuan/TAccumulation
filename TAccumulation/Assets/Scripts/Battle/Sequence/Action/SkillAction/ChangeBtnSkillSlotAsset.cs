using System;
using PapeGames.X3;
using UnityEngine.Timeline;

namespace X3Battle
{
    // TimelineClip
    [TrackClipYellowColor]
    [TimelineMenu("技能动作/技能槽位映射变更")]
    [Serializable]
    public class ChangeBtnSkillSlotAsset : BSActionAsset<ActionChangeBtnSkillSlot>
    {
        [LabelText("目标类型")] public HeroType heroType;

        [LabelText("按钮类型")] public PlayerBtnType playerBtnType;

        [LabelText("技能ID")] public int skillId;

        [LabelText("CD模式")] public ChangeSkillCdType changeSkillCdType;
    }
    
    // playable
    public class ActionChangeBtnSkillSlot : BSAction<ChangeBtnSkillSlotAsset>
    {
        protected override void _OnEnter()
        {
            Actor target = clip.heroType == HeroType.Boy ? Battle.Instance.actorMgr.boy : Battle.Instance.actorMgr.girl;
            if (target == null)
            {
                return;
            }

            if (target.skillOwner == null)
            {
                LogProxy.Log($"timeline【技能槽位映射变更 ChangeBtnSkillSlotAsset】配置错误, 【Actor】没有SkillOwner组件.");
                return;
            }

            var slotId = target.skillOwner.GetSlotIDBySkillID(clip.skillId);
            if (slotId == null)
            {
                LogProxy.LogFormat($"timeline【技能槽位映射变更 ChangeBtnSkillSlotAsset】配置错误, 该角色{target.name} 身上没有没有【skillID={clip.skillId}】的技能.");
                return;
            }

            var curSlotId = target.skillOwner.TryGetBaseSlotID(clip.playerBtnType);
            if (curSlotId == null)
            {
                return;
            }
            
            //清除CD
            var curSlot = target.skillOwner.GetSkillSlot(curSlotId.Value);
            if (curSlot != null && clip.changeSkillCdType == ChangeSkillCdType.RefreshCd)
            {
                curSlot.SetRemainCD(0);
            }

            target.skillOwner.changeBtnSlotData.SetData(clip.playerBtnType, slotId.Value);
        }
    }
}