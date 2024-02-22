using System;
using System.Collections.Generic;
using UnityEngine;
using Framework;
using PapeAnimation;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using X3;
using X3Battle;

public class PerformPlayableInstance : GenericAnimationNode, IPlayableInsInterface
{
    private EStaticSlot groupType;
    private bool isDestroy = true;
    private Func<TrackAsset, bool> trackBuildFilter = null;
    private DynamicAnimationGraph thisGraph = null;
    private PlayableDirector timelineDirector = null;
    private Animator cachedAnimator = null;
    private Playable timelinePlayable;

    private void _Reset()
    {
        groupType = EStaticSlot.Invalid;
        isDestroy = true;
        trackBuildFilter = null;
        thisGraph = null;
        timelineDirector = null;
        cachedAnimator = null;
        timelinePlayable = Playable.Null;
    }

    public PerformPlayableInstance()
    {
        SetWeight(1);
    }
    
    // 播放表演时尝试生成换手动画
    private Playable _TryCreateCustomAnimPlayable(TrackAsset track, PlayableGraph graph, AnimationPlayableAsset clip)
    {
        return X3TimelineUtility.TryCreateCustomAnimPlayable(graph, clip, cachedAnimator);
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
    
     // 设置build时轨道筛选只有怪物
     public void SetOnlyMonster()
      {
          trackBuildFilter = (track) =>
          {
              var animationTrack = track as AnimationTrack;
              if (animationTrack != null)
              {
                  var extData = animationTrack.extData;
                  if ((extData.trackType == TrackExtType.CreatureAnim || extData.trackType == TrackExtType.Creature_K_Anim) && !BattleUtil.IsSuit(extData.bindSuitID))
                  {
                      animationTrack.muted = false;
                      animationTrack.extCreateAnimPlayable = this._TryCreateCustomAnimPlayable;
                      return true;
                  }
              }
              return false;
            };
        }

     // 设置播放时开启BattleAnimator
     private bool _isOpenBattleAnimator;
     public void SetOpenBattleAnimator(bool isOpen)
     {
         _isOpenBattleAnimator = isOpen;
     }
        
    // 设置build时轨道筛选只有女主
    public void SetOnlyFemale()
    {
        trackBuildFilter = (track) =>
        {
            var animationTrack = track as AnimationTrack;
            if (animationTrack != null)
            {
                var extData = animationTrack.extData;
                if (BattleUtil.IsGirlSuit(extData.bindSuitID))
                {
                    animationTrack.muted = false;
                    animationTrack.extCreateAnimPlayable = this._TryCreateCustomAnimPlayable;
                    return true;
                }
            }
            return false;
        };
    }

    // 设置build时轨道筛选只有男主
    public void SetOnlyMale()
    {
        trackBuildFilter = (track) =>
        {
            var animationTrack = track as AnimationTrack;
            if (animationTrack != null)
            {
                var extData = animationTrack.extData;
                if (BattleUtil.IsBoySuit(extData.bindSuitID))
                {
                    animationTrack.muted = false;
                    animationTrack.extCreateAnimPlayable = this._TryCreateCustomAnimPlayable;
                    return true;
                }
            }
            return false;
        };
    }

    // 用timeline资源构建材质动画Playable
    public void BuildTimelinePerformPlayable(PlayableDirector director)
    {
        timelineDirector = director;
        var timelineAsset = director.playableAsset as TimelineAsset;
        timelineAsset.trackBuildFilter = trackBuildFilter;
        PlayableAnimationManager.Instance().AddAnimation(cachedAnimator, this, groupType);
    }

    private void StopOtherInstance()
    {
        if (_isOpenBattleAnimator)
        {
            return;    
        }
        
        GenericAnimationTree tree = thisGraph.GetStaticSlotTree(groupType);
        if (tree == null)
            return;

        List<GenericAnimationNode> instances = tree.GetSubNodes();
        if (instances == null)
            return;

        for (int i = 0; i < instances.Count; i++)
        {
            var ins = instances[i];
            if (ins != this)
            {
                ins.SetWeight(0);       
            }
        }
    }

    private void RecoverOtherInstance()
    {
        GenericAnimationTree tree = thisGraph.GetStaticSlotTree(groupType);
        if (tree == null)
            return;

        List<GenericAnimationNode> instances = tree.GetSubNodes();
        if (instances == null)
            return;

        for (int i = 0; i < instances.Count; i++)
        {
            var ins = instances[i];
            ins.SetWeight(1);
        }   
    }
    
    public void Destroy()
    {
        PlayableAnimationManager.Instance().RemoveAnimation(this);
        _Reset();
    }

    protected override void OnBuild()
    {
        if (timelineDirector == null || timelineDirector.playableAsset == null)
            return;

        isDestroy = false;
        
        var timelineAsset = timelineDirector.playableAsset as TimelineAsset;

        // 生成anim轨道，并把主parent轨道playable禁用
        timelinePlayable = timelineAsset.CreatePlayable(animationSystem.graph, cachedAnimator.gameObject);
        var timelineInputCount = timelinePlayable.GetInputCount();
        if (timelineInputCount > 0)
        {
            var layerPlayable = timelinePlayable.GetInput(0);
            for (int i = 0; i < layerPlayable.GetInputCount(); i++)
            {
                layerPlayable.SetInputWeight(i, 1);
            }    
        }
        else
        {
            PapeGames.X3.LogProxy.LogWarningFormat("PerformPlayableInstance绑定了角色，但是timeline里没K动画轨道，请检查Perform配置和美术资源！{0}", timelineAsset.name);
        }

        timelineAsset.trackBuildFilter = null;

        thisGraph = PlayableAnimationManager.Instance().FindPlayGraph(cachedAnimator.gameObject);
        StopOtherInstance();
    }

    protected override void OnDestroy()
    {
        isDestroy = true;

        if (timelinePlayable.IsValid())
            timelinePlayable.Destroy();

        RecoverOtherInstance();
    }

    public override GenericAnimationMixer GetMixer()
    {
        return null;
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
        if (weight == 0)
        {
            RecoverOtherInstance();
        }
        else if (weight == 1)
        {
            StopOtherInstance();
        }
        SetWeight(weight);
    }

    public override Playable GetOutput()
    {
        return timelinePlayable.IsValid() ? timelinePlayable : Playable.Null;
    }

    public override void Tick(float deltaTime)
    {
    }
}