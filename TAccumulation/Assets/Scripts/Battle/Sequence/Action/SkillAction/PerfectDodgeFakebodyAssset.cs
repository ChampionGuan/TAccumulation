using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("技能动作/创建完美闪避假身")]
    [Serializable]
    public class PerfectDodgeFakebodyAssset : BSActionAsset<ActionPerfectDodgeFakebody>
    {
    }

    public class ActionPerfectDodgeFakebody : BSAction<PerfectDodgeFakebodyAssset>
    {
        private Actor _fakebodyActor;

        protected override void _OnInit()
        {
            context.actor?.battle.actorMgr.PreloadSummonFakebody(context.actor);
        }

        protected override void _OnEnter()
        {
            _fakebodyActor = context.actor?.battle.actorMgr.SummonFakebody(context.actor);
            if (_fakebodyActor == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("【完美闪避】{0}的假身创建失败！", context.actor.name);
            }
            else
            {
                PapeGames.X3.LogProxy.LogFormat("【完美闪避】{0}的假身创建成功！", context.actor.name);
            }
        }

        protected override void _OnExit()
        {
            if (_fakebodyActor != null)
            {
                PapeGames.X3.LogProxy.LogFormat("【完美闪避】{0}的假身被销毁！", context.actor.name);
            }
            _fakebodyActor?.Dead();
            _fakebodyActor = null;
        }
    }
}
