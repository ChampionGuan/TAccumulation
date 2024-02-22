using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("技能动作/召唤创生物")]
    [Serializable]
    public class SummonCreatureAsset : BSActionAsset<ActionSummonCreature>
    {
        [LabelText("召唤物表ID")]
        public int summonId;
        
        [LabelText("是否启用验证")]
        public bool enableValidation;
        
        [DrawCoorPoint("取位置参数")]
        public CoorPoint pointData;
        
        [LabelText("取朝向参数")]
        public CoorOrientation forwardData;

        [DrawCoorPoint("取位置参数2","enableValidation")]
        public CoorPoint pointData2;
        
        [LabelText("取位置参数2", "enableValidation")]
        public CoorOrientation forwardData2;
        
        [LabelText("覆写阵营参数")]
        public bool isOverrideFaction = false;
        
        [LabelText("覆写阵营枚举", "isOverrideFaction")]
        public FactionType factionType = FactionType.Neutral;
    }

    public class ActionSummonCreature : BSAction<SummonCreatureAsset>
    {
        protected override void _OnInit()
        {
            context.battle.actorMgr.PreloadSummonCreature(context.skill, clip.summonId, Vector3.zero, 0);
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
            // DONE: 覆盖阵营逻辑.
            FactionType? faction = null;
            if (clip.isOverrideFaction)
            {
                faction = clip.factionType;
            }
            context.battle.SummonCreature(context.actor, context.skill, clip.summonId, faction, coorPoint, coorOrientation, true, transInfoCache: bsSharedVariables.transInfoCache);
        }   
    }
}