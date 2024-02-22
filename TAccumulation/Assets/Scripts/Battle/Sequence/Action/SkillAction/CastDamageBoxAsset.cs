using System;
using UnityEngine;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;
using X3Battle.Timeline.Preview;

namespace X3Battle
{
    [PreviewActionCreator(typeof(PreviewShapeBoxAction))]  // 加了这个属性就能预览shape盒
    [TrackClipYellowColor]
    [TimelineMenu("技能动作/释放攻击包围盒")]
    [Serializable]
    public class CastDamageBoxAsset : BSActionAsset<ActionCastDamageBox>
    {
        [LabelText("包围盒Id", jumpType:JumpModuleType.ViewDamageBox)]
        public int boxId;
        
        [LabelText("局部欧拉角旋转偏移")]
        public Vector3 offsetAngle;

        [LabelText("局部坐标偏移")]
        public Vector3 offsetPos;

        [LabelText("权重0~1", editorCondition = "false")]
        public float weight;

        [LabelText("打击盒组ID")]
        public int boxGroupID; 
    }

    public class ActionCastDamageBox: BSAction<CastDamageBoxAsset>
    {
        protected override void _OnEnter()
        {
            context.skill.CastDamageBox(null, clip.boxId, context.skill.level, out _, clip.offsetAngle, clip.offsetPos, remainTime, clip.weight, damageBoxGroupID: clip.boxGroupID);
        }   
    }
}