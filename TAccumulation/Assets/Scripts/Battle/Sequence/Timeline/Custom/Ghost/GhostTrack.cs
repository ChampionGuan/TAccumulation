using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace X3Battle
{
    // 现有的逻辑大概：
    // ①不使用动画区间情况下，程序每帧会对主体单位进行位置收集，然后item运行时会对anim和pos采样
    // ②使用动画区间情况下，会使用区间采样，同时编辑器强制勾选不跟随人物位置。
    // ③美术有设置位置需求应该设置一个父节点。
    // ④颜色采样迭代：美术要求在持续时间内采样。如果无限持续则采0点
    // 具体需求：
    //
    // 1.新增采样区间参数，可以自定义Clip采样的起始和终止时间, 配置了采样区间，动画采样就从区间min开始，人物的位置采样也从区间min开始。
    //
    // 2.新增是否跟随人物移动参数，不跟随的情况下，美术可以在scene中拖动相对位置。之前的【是否定帧】参数含有两种功能控制：①动画定帧 ②跟随人物移动，现在需要拆分开。拆分开之后，美术可以调节子节点位置。
    //
    // 3.新增是否定帧参数，勾选之后在人物持续时间内clip播完或者播到终止时间后，保持定帧状态（经过讨论做成默认机制）
    //
    // 4.当使用采样区间时，固定设置不跟随人物移动。
    //
    // 5.颜色变成颜色曲线。采样区间对应持续时间参数，如果残影时间无限，取color curve 第一帧效果。
    [Serializable]
    [TrackClipType(typeof(GhostClip))]
    [TrackBindingType(typeof(GameObject))]
    public class GhostTrack : TrackAsset, IInterruptTrack
    {
        [NonSerialized]
        public GameObject referTarget;  // 动态设置，不序列化。clip执行期间记录参考对象的位置旋转信息

        [NonSerialized] 
        public GhostObjectPool ghostObjPool;  // 池

        [LabelText("不因打断而结束")]
        public bool isStopByTime = false;
        
        [LabelText("因逻辑结束而结束")]
        public bool isStopByLogic = false;

        // 属性变化时重新设置资源
        public override void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                referTarget = null;
                var trackBinding = director.GetGenericBinding(this) as GameObject;
                if (trackBinding == null)
                { 
                    return; 
                }
                
                var timeline = director.playableAsset as TimelineAsset;
                TrackAsset[] tracks = timeline.GetOutputTracks();
                for (int i = 0; i < tracks.Length; i++)
                {
                    if (tracks[i] == this && i > 0)
                    {
                        var referTrack = tracks[i - 1];
                        if (referTrack is GhostTrack ghostTrack)
                        {
                            referTarget = ghostTrack.referTarget;
                        }
                        else
                        {
                            referTarget = (director.GetGenericBinding(referTrack) as Animator)?.gameObject;
                            if (referTarget == null)
                            {
                                referTarget =  director.GetGenericBinding(referTrack) as GameObject; 
                            }   
                        }
                    }   
                }
            }
#endif
            RefreshClipInfo(director);
            base.GatherProperties (director, driver);
        }

        public void RefreshClipInfo(PlayableDirector director)
        {
            if (director != null)
            {
                var trackBinding = director.GetGenericBinding(this) as GameObject;
                if (trackBinding != null)
                {
                    foreach (var clip in m_Clips)
                    {
                        var myAsset = clip.asset as GhostClip;
                        if (myAsset)
                        {
                            myAsset.SetInfo(trackBinding, director, referTarget, ghostObjPool);
                        }
                    }
                }
            }
            ghostObjPool = null;
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