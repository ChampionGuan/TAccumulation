using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/魔女时间")]
    [Serializable]
    public class WitchTimeAsset : BSActionAsset<ActionWitchTime>
    {
        [LabelText("否先清除所有单位的魔女时间")]
        public bool isRestoreActorsScale = true;

        [LabelText("是否使用默认缩放倍率")]
        [Tooltip("如果为true，值见BattleConst.ActorDefaultWitchScale")]
        public bool isUseDefaultScale = true;

        [LabelText("缩放倍率", showCondition = "!isUseDefaultScale")]
        public float scale = 1;
        
        [LabelText("持续时间 (-1一直持续)", showCondition = "!useActionDuration")]
        public float scaleDuration = -1;

        [LabelText("是否使用轨道时长")]
        public bool useActionDuration = true;

        [LabelText("下方所选单位是否为排除")]
        [Tooltip("勾选则为排除，表示不进入魔女时间")]
        public bool isExclusion = true;
        
        [LabelText("所选单位列表")] 
        public List<WitchTimeIncludeData> excludeDatas;

        [LabelText("暂停音频播放")] 
        public bool isEnableSound = true;
    }

    public class ActionWitchTime : BSAction<WitchTimeAsset>
    {
        protected override void _OnEnter()
        {
            var duration = clip.useActionDuration ? this.duration : clip.scaleDuration;
            var scale = clip.isUseDefaultScale ? TbUtil.battleConsts.ActorDefaultWitchScale : clip.scale;
            context.battle.SetActorsWitchTime(context.actor, clip.isRestoreActorsScale, clip.isExclusion, clip.excludeDatas, scale, duration, clip.isEnableSound);
        }  
    }
}