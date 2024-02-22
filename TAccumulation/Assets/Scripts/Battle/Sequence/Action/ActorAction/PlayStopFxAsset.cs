using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/角色播放停止唯一特效音效")]
    [Serializable]
    public class PlayStopFxAsset : BSActionAsset<ActionPlayStopFx>
    {
        public int fxCfgID = 0;
        public string soundEventName;
    }

    public class ActionPlayStopFx : BSAction<PlayStopFxAsset>
    {
        //不支持播放多个同样ID的特效/音效
        protected override void _OnEnter()
        {
            if(context.actor.locomotionView == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("动作模组节点:角色播放停止唯一特效音效 不支持用在了非角色上 actorID:{0}", context.actor.cfgID);
                return;
            }

            if(clip.fxCfgID != 0)
                context.actor.locomotionView.PlayOnlyFx(clip.fxCfgID);

            if (!string.IsNullOrEmpty(clip.soundEventName))
                context.actor.locomotionView.PlayOnlySound(clip.soundEventName);
        }

        protected override void _OnExit()
        {
            if (context.actor.locomotionView == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("动作模组节点:角色播放停止唯一特效音效 不支持用在了非角色上 actorID:{0}", context.actor.cfgID);
                return;
            }

            if (clip.fxCfgID != 0)
                context.actor.locomotionView.LateStopFx(clip.fxCfgID);

            if (!string.IsNullOrEmpty(clip.soundEventName))
                context.actor.locomotionView.LateStopSound(clip.soundEventName);
        }
    }
}