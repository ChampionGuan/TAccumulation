using System;
using UnityEngine.Timeline;
using UnityEngine;

namespace X3Battle
{
    [TimelineMenu("角色动作/修改战斗相机跟随挂点")]
    [Serializable]
    public class SetCameraFollowDummyAsset : BSActionAsset<ActionSetCameraFollowDummy>
    {

    }

    public class ActionSetCameraFollowDummy : BSAction<SetCameraFollowDummyAsset>
    {
        protected override void _OnEnter()
        {
            context.battle.cameraTrace.SetFollowDummyType(ActorDummyType.PointCameraFollow);
        }

        protected override void _OnExit()
        {
            context.battle.cameraTrace.SetFollowDummyType(ActorDummyType.PointCamera);
        }
    }
}
