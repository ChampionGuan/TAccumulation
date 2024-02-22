using System;
using System.Collections;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[Serializable]
public class SimpleAudioPlayableClip : InterruptClip
{
    public override double duration { get { return realDuration; } }

    public float realDuration = 1;

    public string EventName = "";

    public string StopEventName = "";

    [NonSerialized] 
    public float playSpeed = 1f;
    
    [NonSerialized]
    public SimpleAudioPlayableBehaviour behaviour;

    // 虚函数：继承自InterruptClip的类只实现这个方法
    protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
    {
        var playable = ScriptPlayable<SimpleAudioPlayableBehaviour>.Create(graph);
        realDuration = WwiseManager.Instance.GetLength(EventName);
        behaviour = playable.GetBehaviour();
        behaviour.EventName = EventName;
        behaviour.StopEventName = StopEventName;
        behaviour.playSpeed = playSpeed;
        interruptBehaviourParam = behaviour;
        return playable;
    }

    public void SetPlaySpeed(float speed)
    {
        playSpeed = speed;
        if (behaviour != null)
        {
            behaviour.RefreshPlaySpeed(speed);   
        }
    }

    //虚函数
    protected override ClipCaps OnGetClipCaps()
    {
        return ClipCaps.Blending;
    }
}