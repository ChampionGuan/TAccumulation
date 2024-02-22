using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/创建道具")]
    [Serializable]
    public class CreateItemAsset : BSActionAsset<ActionCreateItem>
    {
        [LabelText("道具ID", jumpType:JumpModuleType.ViewItem)]
        public int itemId;
        
        [LabelText("是否启用验证")]
        public bool enableValidation;
        
        [DrawCoorPoint("取位置参数")]
        public CoorPoint pointData;
        
        [LabelText("取朝向参数")]
        public CoorOrientation forwardData;

        [DrawCoorPoint("取位置参数2","enableValidation")]
        public CoorPoint pointData2;
        
        [LabelText("取朝向参数2", "enableValidation")]
        public CoorOrientation forwardData2;
    }

    public class ActionCreateItem : BSAction<CreateItemAsset>
    {
        protected override void _OnInit()
        {
            context.battle.actorMgr.PreloadItem(context.actor, context.skill, context.skill?.level ?? 1, clip.itemId);
        }
        
        protected override void _OnEnter()
        {
            CoorPoint coorPoint = clip.pointData;
            CoorOrientation coorOrientation = clip.forwardData;
            if (clip.enableValidation)
            {
                if (!CoorHelper.IsValidCoorConfig(context.actor, coorPoint, coorOrientation, true, cache: bsSharedVariables.transInfoCache))
                {
                    coorPoint = clip.pointData2;
                    coorOrientation = clip.forwardData2;
                }
            }

            context.battle.CreateItem(context.actor, context.skill, context.skill?.level ?? 1, clip.itemId, coorPoint, coorOrientation, true, transInfoCache: bsSharedVariables.transInfoCache);
        }   
    }
}