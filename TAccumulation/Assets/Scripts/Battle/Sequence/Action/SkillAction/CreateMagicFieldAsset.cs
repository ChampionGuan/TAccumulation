using System;
using UnityEngine;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;
using X3Battle.Timeline.Preview;

namespace X3Battle
{
    [PreviewActionCreator(typeof(PreviewShapeBoxAction))]  // 加了这个属性就能预览shape盒
    [TimelineMenu("技能动作/创建法术场")]
    [Serializable]
    public class CreateMagicFieldAsset : BSActionAsset<ActionCreateMagicField>
    {
        [LabelText("法术场ID (>0有效)", jumpType:JumpModuleType.ViewMagicField)]
        public int magicFieldID;

        [LabelText("创建参数")] 
        public CreateMagicFieldParam createParam;
        
        [LabelText("是否启用验证")]
        public bool enableValidation;
        
        [LabelText("是否关联法术场时长")]
        public bool enableTime;
        
        [DrawCoorPoint("取位置参数")]
        public CoorPoint pointData;
                
        [LabelText("取朝向参数")]
        public CoorOrientation forwardData;

        [DrawCoorPoint("取位置参数2","enableValidation")]
        public CoorPoint pointData2;
        
        [LabelText("取位置参数2", "enableValidation")]
        public CoorOrientation forwardData2;
    }

    public class ActionCreateMagicField : BSAction<CreateMagicFieldAsset>
    {
        private Actor _actor;
        protected override void _OnInit()
        {
           context.battle.actorMgr.PreloadSummonMagicField(context.skill, clip.magicFieldID, Vector3.zero, Vector3.zero);
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

            _actor = context.battle.CreateMagicField(context.actor, context.skill, clip.magicFieldID, coorPoint, coorOrientation, true, clip.createParam, transInfoCache: bsSharedVariables.transInfoCache);
        }

        protected override void _OnExit()
        {
            if (clip.enableTime && _actor != null)
            {
                _actor.Dead();
            }
        }
    }
}
