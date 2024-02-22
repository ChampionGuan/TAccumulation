using System;
using BattleCurveAnimator;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    [Serializable]
    [TrackClipType(typeof(CurveAnimPlayableAsset))]
    [TrackBindingType(typeof(GameObject))]
    public class CurveAnimTrack: TrackAsset, IInterruptTrack
    {
        [HideInInspector] public TrackExtData extData = null;
        
        [LabelText("不因打断而结束")]
        public bool isStopByTime = false;
        
        [LabelText("因逻辑结束而结束")]
        public bool isStopByLogic = false;


        public override void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {
            base.GatherProperties(director, driver);
            
            Object gameObject = director.GetGenericBinding(this);
            var timelineClips = GetClipsArray();
            foreach (var timelineClip in timelineClips)
            {
                CurveAnimPlayableAsset curveAnimPlayableAsset = timelineClip.asset as CurveAnimPlayableAsset;
                if (curveAnimPlayableAsset != null)
                {
                    curveAnimPlayableAsset.SetBindObj(gameObject as GameObject, (float)timelineClip.duration);
                }
            }
        }
        
        public TimelineClip CreateClip(GameObject bind, CurveAnimAsset asset)
        {
            if (asset == null  || asset.multiAnimData == null || asset.multiAnimData.anims.Length <= 0)
                return null;

            TimelineClip newClip = CreateClip<CurveAnimPlayableAsset>();
            newClip.start = 0;
            newClip.clipIn = 0;
            if(asset.multiAnimData.anims.Length == 3)
                newClip.duration = asset.multiAnimData.anims[0].length + asset.multiAnimData.anims[1].length + asset.multiAnimData.anims[2].length;
            else
                newClip.duration = asset.multiAnimData.anims[0].length;
            newClip.displayName = asset.name;
            
            CurveAnimPlayableAsset curveAnimPlayableAsset = newClip.asset as CurveAnimPlayableAsset;
            curveAnimPlayableAsset.multiAnimData = asset.multiAnimData;
            curveAnimPlayableAsset.SetBindObj(bind, (float)newClip.duration);            
            return newClip;
        }
        
        // 如果Control轨道勾选了不随Interrupt而结束，这里返回true
        public override bool IsIgnoreInterrupt()
        {
            return isStopByTime;
        }

        // 如果Control轨道勾选了不随Interrupt而结束，这里返回true
        public override bool IsSpecialEnd()
        {
            return isStopByLogic;
        }
    }
    
}