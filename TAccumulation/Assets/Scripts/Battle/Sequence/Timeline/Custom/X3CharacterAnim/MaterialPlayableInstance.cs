using System.Collections.Generic;
using UnityEngine;
using Framework;
using PapeAnimation;
using UnityEngine.Playables;
using UnityEngine.Timeline;


public class MaterialPlayableInstance : GenericAnimationNode, IPlayableInsInterface
{
    private EStaticSlot groupType;
    private HashSet<TrackAsset> toolSet = new HashSet<TrackAsset>();
    private Animator cachedAnimator = null;
    private bool isDestroy = true;

    private TimelineAsset timelineAsset;
    private Playable timelinePlayable;

    private void _Reset()
    {
        groupType = EStaticSlot.Invalid;
        toolSet.Clear();
        cachedAnimator = null;
        isDestroy = true;
    }

    public MaterialPlayableInstance()
    {
        SetWeight(1);   
    }
    
    // build之前必须调用一下
    public void SetAnimatorByGameObject(GameObject animatorObj)
    {
        cachedAnimator = animatorObj.GetComponent<Animator>();
    }

    // build之前必须调用一下
    public void SetAnimationGroupType(int type)
    {
        groupType = (EStaticSlot)type;
    }
    
    // 用timeline资源构建材质动画Playable
    public void BuildTimelineMaterialPlayable(PlayableDirector director)
    {
        timelineAsset = director.playableAsset as TimelineAsset;
        PlayableAnimationManager.Instance().AddAnimation(cachedAnimator, this, groupType);
    }

    public void Destroy()
    {
        PlayableAnimationManager.Instance().RemoveAnimation(this);
        _Reset();
    }

    protected override void OnBuild()
    {
        if (timelineAsset == null)
            return;
        
        isDestroy = false;

        // 记录当前active轨道，并把creatureAnim轨道激活, 别的轨道关闭
        var tracks = timelineAsset.GetOutputTracks();
        for (int i = 0; i < tracks.Length; i++)
        {
            var track = tracks[i];
            if (!track.muted)
            {
                toolSet.Add(track);
            }

            track.muted = true;
            var animTrack = track as AnimationTrack;
            if (animTrack != null && animTrack.extData != null)
            {
                if (animTrack.extData.trackType == TrackExtType.CreatureAnim && animTrack.HasMaterialSubTrack)
                {
                    animTrack.muted = false;
                    animTrack.extCanCompileSelf = false;
                }
            }
        }

        // 生成anim轨道，并把主parent轨道playable禁用
        var cacheExtAsset = timelineAsset.GetExtBuildAsset();
        timelineAsset.SetExtBuildAsset(null);
        timelinePlayable = timelineAsset.CreatePlayable(animationSystem.graph, cachedAnimator.gameObject);
        timelineAsset.SetExtBuildAsset(cacheExtAsset);
        if (timelinePlayable.GetInputCount() > 0)
        {
            var layerPlayable = timelinePlayable.GetInput(0);
            for (int i = 0; i < layerPlayable.GetInputCount(); i++)
            {
                layerPlayable.SetInputWeight(i, 1);
            }   
        }

        // 恢复之前被禁用的轨道
        for (int i = 0; i < tracks.Length; i++)
        {
            var track = tracks[i];
            var animTrack = track as AnimationTrack;
            if (animTrack != null)
            {
                animTrack.extCanCompileSelf = true;
            }
            if (toolSet.Contains(track))
            {
                track.muted = false;
            }
            else
            {
                track.muted = true;
            }
        }
    }

    public void SetTime(float time)
    {
        if (isDestroy)
        {
            return;    
        }

        SetOverrideTime(time);

        if (timelinePlayable.IsValid())
        {
            timelinePlayable.SetTime(time);
        }
    }

    public void SetPlayableWeight(float weight)
    {
        SetWeight(weight);
    }

    public override GenericAnimationMixer GetMixer()
    {
        return null;
    }

    public override Playable GetOutput()
    {
        return timelinePlayable.IsValid() ? timelinePlayable : Playable.Null;
    }

    protected override void OnDestroy()
    {
        isDestroy = true;

        if (timelinePlayable.IsValid())
            timelinePlayable.Destroy();
    }

    public override void Tick(float deltaTime)
    {
        
    }
}