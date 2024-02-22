using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class ActionDynamicWind : ActionStaticWind
    {
        protected override bool _GetLerpAndWindParam(out PhysicsWindParam param1, out PhysicsWindParam param2)
        {
            var clip = GetClipAsset<PhysicsWindDynamicClip>();
            clip.Wind = this;
            clip.bindObj = GetTrackBindObj<GameObject>();
            
            clip.LoadAsset();
            param1 = clip.physicsWindParamAsset?.physicsWindParam;
            param2 = clip.physicsWindParamAsset?.physicsWindParam2;
            var isLerp = clip.physicsWindParamAsset?.isLerp ?? false;
            clip.UnloadAsset();
            
            return isLerp;
        }
    }
}