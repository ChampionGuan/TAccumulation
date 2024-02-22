using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("技能动作/记录虚拟Actor")]
    [Serializable]
    public class RecordTransInfoAsset : BSActionAsset<ActionRecordTransInfo>
    {
        [LabelText("记录ID")]
        public int recordID;
        
        [DrawCoorPoint("取位置参数")]
        public CoorPoint pointData;

        [LabelText("取朝向参数")]
        public CoorOrientation forwardData;
    }

    public class ActionRecordTransInfo : BSAction<RecordTransInfoAsset>
    {
        public static event Action<Vector3, Vector3> OnRecordEvent;
        
        protected override void _OnEnter()
        {
            var pos = clip.pointData.GetCoordinatePoint(context.actor, true, transInfoCache: bsSharedVariables.transInfoCache);
            var forward = clip.forwardData.GetCoordinateOrientation(context.actor, true, transInfoCache: bsSharedVariables.transInfoCache);
            bsSharedVariables.transInfoCache.Record(clip.recordID, pos, forward);

#if UNITY_EDITOR
            OnRecordEvent?.Invoke(pos, forward);
#endif
        }    
    }
}