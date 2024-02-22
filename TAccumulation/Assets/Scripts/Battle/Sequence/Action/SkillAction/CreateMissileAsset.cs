using System;
using System.Collections.Generic;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;
using X3Battle.Timeline.Preview;

namespace X3Battle
{
    [PreviewActionCreator(typeof(PreviewMissileAction))]  // 加了这个就能预览新子弹方向
    [TimelineMenu("技能动作/创建子弹")]
    [Serializable]
    public class CreateMissileAsset : BSActionAsset<ActionCreateMissile>
    {
        [LabelText("子弹")]
        public List<CreateMissileParam> missiles;
    }

    public class ActionCreateMissile : BSAction<CreateMissileAsset>
    {
        private Action<int> _createMissileAction;
        
        protected override void _OnInit()
        {
            foreach (var param in clip.missiles)
            {
                param.IsTargetType = true;
                context.battle.actorMgr.PreloadMissile(context.skill, param);
            }

            _createMissileAction = _CreateMissile;
        }

        protected override void _OnEnter()
        {
            context.actor.timer.AddTimer(null, 0, 0, 0, null, null, null, _createMissileAction, TimerTickMode.LateUpdate);
        }

        private void _CreateMissile(int id)
        {
            foreach (var param in clip.missiles)
            {
                param.IsTargetType = true;
                context.battle.actorMgr.CreateMissile(context.skill, param, transInfoCache:bsSharedVariables.transInfoCache);
            }
        }
    }
}