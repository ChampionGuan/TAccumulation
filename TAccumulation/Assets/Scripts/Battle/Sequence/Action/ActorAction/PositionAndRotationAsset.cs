using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/设置自身位置旋转")]
    [Serializable]
    public class PositionAndRotationAsset : BSActionAsset<ActionPositionAndRotation>
    {
        [LabelText("让谁位移旋转")]
        public TargetType actorType = TargetType.Self;

        [LabelText("是否启用验证")]
        public bool enableValidation;
        
        [DrawCoorPoint("取位置参数")]
        public CoorPoint pointData;
        
        [LabelText("瞬移前特效")]
        public int PreTransportFX;
        
        [LabelText("瞬移后特效")]
        public int PostTransportFX;
        
        [LabelText("取朝向参数")]
        public CoorOrientation forwardData;
        
        [DrawCoorPoint("取位置参数2","enableValidation")]
        public CoorPoint pointData2;
        
        [LabelText("取位置参数2", "enableValidation")]
        public CoorOrientation forwardData2;
    }

    public class ActionPositionAndRotation : BSAction<PositionAndRotationAsset>
    {
        protected override void _OnEnter()
        {
            var actor = context.actor.GetTarget(clip.actorType);

            CoorPoint coorPoint = clip.pointData;
            CoorOrientation coorOrientation = clip.forwardData;
            if (clip.enableValidation)
            {
                if (!CoorHelper.IsValidCoorConfig(actor, coorPoint, coorOrientation, true, cache: bsSharedVariables.transInfoCache))
                {
                    coorPoint = clip.pointData2;
                    coorOrientation = clip.forwardData2;
                }
            }
            
            // 位置
            Vector3 _targetPos = CoorHelper.GetCoordinatePoint(coorPoint, actor, true, transInfoCache: bsSharedVariables.transInfoCache);
            _targetPos.y = 0;

            actor.stateTag.AcquireTag(ActorStateTagType.CollisionIgnore);
            actor.effectPlayer.PlayFx(clip.PreTransportFX);
            actor.transform.SetPosition(_targetPos);
            actor.effectPlayer.PlayFx(clip.PostTransportFX);
            actor.stateTag.ReleaseTag(ActorStateTagType.CollisionIgnore);

            // 看向目标 
            var lookForward = CoorHelper.GetCoordinateOrientation(coorOrientation, actor, true, transInfoCache: bsSharedVariables.transInfoCache);
            lookForward.y = 0;
            lookForward = lookForward.normalized;
            actor.transform.SetForward(lookForward);
        }    
    }
}