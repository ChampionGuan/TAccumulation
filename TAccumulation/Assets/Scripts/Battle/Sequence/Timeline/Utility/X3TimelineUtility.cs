using Cinemachine;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace X3
{
    /// <summary>
    /// lua层会使用的工具类
    /// </summary>
    public static class X3TimelineUtility
    {
        // 创建换手动画, clip不符合条件返回Playable.Null
        public static Playable TryCreateCustomAnimPlayable(PlayableDirector director, TrackAsset track, PlayableGraph graph, AnimationPlayableAsset playableAsset)
        {
            if (track != null && graph.IsValid() && playableAsset != null && playableAsset.clip != null)
            {
                var orioginObj = director.GetGenericBinding(track);
                var animator = orioginObj as Animator;
                if (animator == null)
                {
                    var gameObj = orioginObj as GameObject;
                    animator = gameObj?.GetComponent<Animator>();
                }
                return TryCreateCustomAnimPlayable(graph, playableAsset, animator);
            }
            return Playable.Null;
        }

        public static Playable TryCreateCustomAnimPlayable(PlayableGraph graph, AnimationPlayableAsset playableAsset, Animator animator)
        {
            if (animator != null && playableAsset != null && playableAsset.clip && graph.IsValid())
            {
                if (AnimationClipWithIK.IsValid(playableAsset.clip))
                {
                    return AnimationClipWithIK.CreatePlayable(animator, graph, playableAsset.clip);
                }
                else if (WeaponSwitchAnimPlayer.IsWeaponSwitchAnimation(playableAsset.clip))
                {
                    return WeaponSwitchAnimPlayer.CreateWeaponSwitchAnimPlayable(animator, graph, playableAsset.clip);
                }
            }
            return Playable.Null;
        }
        
        // 获取timeline上的音频资源（EventName列表）
        public static List<string> GetTimelineAudioEvents(GameObject goTimeline)
        {
            List<string> results = null;
            var director = goTimeline.GetComponent<PlayableDirector>();
            var playable = director.playableAsset;
            var timelineAsset = (TimelineAsset)(playable);
            if (timelineAsset == null)
            {
                return results;
            }
            var allTracks = timelineAsset.GetOutputTracks();
            for (int i = 0; i < allTracks.Length; i++)
            {
                var baseTrack = allTracks[i];
                if (baseTrack is SimpleAudioTrack)
                {
                    var timelineClips = baseTrack.GetClipsArray();
                    for (int j = 0; j < timelineClips.Length; j++)
                    {
                        var audioClip = timelineClips[j].asset as SimpleAudioPlayableClip;
                        if (audioClip != null)
                        {
                            if (results == null)
                            {
                                results = new List<string>(); 
                            }
                            results.Add(audioClip.EventName);
                            results.Add(audioClip.StopEventName);
                        }
                    }
                }
            }
            return results;
        }
        
        // 通过timeline对象获取依赖的资源
        public static List<string> GetTimelineFxPaths(GameObject goTimeline, bool ignoreMutedEmpty = false)
        {
            var results = new List<string>();

            var director = goTimeline.GetComponent<PlayableDirector>();
            var playable = director.playableAsset;
            var timelineAsset = (TimelineAsset)(playable);
            if (timelineAsset == null)
            {
                return results;
            }

            var allTracks = timelineAsset.GetOutputTracks();
            for (int i = 0; i < allTracks.Length; i++)
            {
                var baseTrack = allTracks[i];
                if (ignoreMutedEmpty && baseTrack.muted)
                {
                    continue;  // muted状态不统计资源
                }
                var clips = baseTrack.GetClipsArray();
                var noClips = clips == null || clips.Length == 0;
                if (baseTrack is ControlTrack)
                {
                    if (ignoreMutedEmpty && noClips)
                    {
                        continue;  // 没有clip，并且不统计资源
                    }
                    TrackExtData extData = (baseTrack as ControlTrack).extData;
                    if (extData.trackType == TrackExtType.HookEffect || extData.trackType == TrackExtType.IsolateEffect || extData.trackType == TrackExtType.ChildHookEffect)
                    {
                        results.Add(extData.bindPath);
                    }
                }
                else if (baseTrack is AnimationTrack animationTrack)
                {
                    if (ignoreMutedEmpty && noClips && animationTrack.infiniteClip == null)
                    {
                        continue;  // 没有clip，没有infiniteClip，并且不统计资源
                    }
                    TrackExtData extData = animationTrack.extData;
                    if (extData.trackType == TrackExtType.IsolateEffectAnim)
                    {
                        results.Add(extData.bindPath);
                    }
                }
            }
            return results;
        }
        
        
        // 设置playableDirector时间缩放  
        public static void SetDirectorTimeScale(PlayableDirector director,float timeScale)
        {
            if (director != null && director.playableGraph.IsValid())
            {
                int roots = director.playableGraph.GetRootPlayableCount();
                for (int i = 0; i < roots; i++)
                {
                    var rootPlayable = director.playableGraph.GetRootPlayable(i);
                    if (rootPlayable.IsValid())
                    {
                        rootPlayable.SetSpeed(timeScale);
                    }
                }
            }
        }

        // 设置音频轨速度
        public static void SetSimpleAudioSpeed(TimelineAsset timeline, float speed)
        {
            if (timeline == null)
            {
                return;     
            }
            
            var trasks = timeline.GetOutputTracks();
            for (int i = 0; i < trasks.Length; i++)
            {
                var track = trasks[i] as SimpleAudioTrack;
                if (track != null)
                {
                    var clips = track.GetClipsArray();
                    for (int j = 0; j < clips.Length; j++)
                    {
                        var clip = clips[j].asset as SimpleAudioPlayableClip;
                        if (clip != null)
                        {
                            clip.SetPlaySpeed(speed);   
                        }
                    }
                }
            }
        }
        
        // 手动设置playableDirector时间
        public static void SetDirectorManualTime(PlayableDirector director, float time, IPlayableInsInterface iplayableIns = null)
        {
            if (director == null)
            {
                return;
            }
            
            director.time = time;
            director.Evaluate();

            if (iplayableIns != null)
            {
                iplayableIns.SetTime(time);    
            }
        }
        
        // playable结束时是否为hold状态
        public static bool IsDirectorHoldOnEnd(PlayableDirector director)
        {
            if (director != null)
            {
                var wrapMode = director.extrapolationMode;
                return wrapMode == DirectorWrapMode.Hold;   
            }
            else
            {
                return false;
            }
        }
        
        
        // 设置cinemachineClip值
        public static void BindCinemachineClip(PlayableDirector director, CinemachineShot asset, CinemachineVirtualCamera camera)
        {
            director.SetReferenceValue(asset.VirtualCamera.exposedName, camera);
        }
        
        // 设置ControlClip值
        public static void BindControlClip(PlayableDirector director, ControlPlayableAsset asset, GameObject obj)
        {
            asset.postPlayback = ActivationControlPlayable.PostPlaybackState.Ignore;
            director.SetReferenceValue(asset.sourceGameObject.exposedName, obj);
        }
        
        // 设置位置
        public static void SetTransLocalPositionByExtData(Transform trans, TrackExtData extData)
        {
            trans.localPosition = extData.localPosition;
        }
        
        public static void SetTransPositionByExtData(Transform trans, TrackExtData extData, Transform referTrans)
        {
            if (referTrans != null)
            {
                trans.position = referTrans.TransformPoint(extData.localPosition);
            }
            else
            {
                trans.position = extData.localPosition;
            }
        }
        
        // 设置旋转
        public static void SetTransLocalRotationByExtData(Transform trans, TrackExtData extData)
        {
            trans.localRotation = Quaternion.Euler(extData.localRotation);
        }
        
        public static void SetTransRotationByExtData(Transform trans, TrackExtData extData, Transform referTrans)
        {
            if (referTrans != null)
            {
                trans.rotation = referTrans.rotation * Quaternion.Euler(extData.localRotation);
            }
            else
            {
                trans.rotation = Quaternion.Euler(extData.localRotation);
            }
        }
        
        // 设置缩放
        public static void SetTransLocalScaleByExtData(Transform trans, TrackExtData extData)
        {
            trans.localScale = extData.localScale;
        }
        
        // 同步骨骼映射
        public static void SyncTrans(Transform srcRoot, Transform destRoot)
        {
            if (srcRoot != null && destRoot != null)
            {
                // 同步根节点
                destRoot.position = srcRoot.position;
                destRoot.rotation = srcRoot.rotation;
                destRoot.localScale = srcRoot.localScale;
                _SyncChildrenByRecursion(srcRoot, destRoot, false);
            }
        }
        
        // 记录一下骨骼映射
        private static void _SyncChildrenByRecursion(Transform src, Transform dest, bool needRecord = true)
        {
            if (needRecord)
            {
                dest.localPosition = src.localPosition;
                dest.localRotation = src.localRotation;
                dest.localScale = src.localScale;
            }

            var childCount = dest.childCount;
            for (int i = 0; i < childCount; i++)
            {
                var destChild = dest.GetChild(i);
                var srcChild = src.Find(destChild.name);
                if (srcChild != null)
                {
                    _SyncChildrenByRecursion(srcChild, destChild);
                }
            }
        }
    }
}