using System;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Profiling;
using UnityEngine.Timeline;
using X3Battle;


[Serializable]
public class SimpleAudioPlayableBehaviour : InterruptBehaviour
{
    [HideInInspector] public string EventName;
    [HideInInspector] public string StopEventName;

    public float playSpeed = 1f;
    public float cacheSpeed = 0;

    private object _playerData;
    // 开始运行
    protected override void OnStart(Playable playable, FrameData info, object playerData)
    {
        if (string.IsNullOrEmpty(EventName))
        {
            return;
        }

        _playerData = playerData;
        
        // 非运行时需要loadbank运行时预加载阶段已经提前load过了
        if (!Application.isPlaying)
        {
            WwiseManager.Instance.LoadBankWithEventName(EventName);   
        }

        if (Application.isPlaying)  // 编辑器下很多美术不知道怎么关wwise日志
        {
            if(WwiseManager.LogEnable)
                LogProxy.LogFormat("SimpleAudioPlayableBehaviour.OnStart.PlaySound.{0}", EventName);
        }

        using (ProfilerDefine.SimpleAudioPlaySoundMarker.Auto())
        {
            //战斗过程中load时候不播放音频
            if (Application.isPlaying && X3Battle.Battle.Instance != null && X3Battle.Battle.Instance.isPreloading)
            {
                return;
            }
            else
            {
                WwiseManager.Instance.PlaySound(EventName, (GameObject)playerData);
            }
        }
        
        using (ProfilerDefine.SimpleAudioSetSpeedMarker.Auto())
        {
            __RefreshSpeed(playSpeed);
        }
    }

    protected override void OnProcessFrame(Playable playable, FrameData info, object playerData)
    {
        if(cacheSpeed != 0)
        {
            RefreshPlaySpeed(cacheSpeed);
        }
    }

    private AKRESULT __RefreshSpeed(float pSpeed)
    {
        return WwiseManager.Instance.SetSpeed(EventName, pSpeed);  
    }

    public void RefreshPlaySpeed(float speed)
    {
        uint playingId = WwiseManager.Instance.GetPlayingId(EventName);
        if (playingId == 0)
        {
            if(playSpeed != speed)
            {
                cacheSpeed = speed;
            }
            return;
        }
        if (playSpeed == speed)
        {
            return;
        }
        AKRESULT result = __RefreshSpeed(speed);
        if (result == AKRESULT.AK_Success)
        {
            playSpeed = speed;
            cacheSpeed = 0;
        }
        else
        {
            cacheSpeed = speed;
        }
    }
        
    // 结束时或者被打断时调用，如果没有OnStart肯定不会调用过来
    protected override void OnStop()
    {
        if (string.IsNullOrEmpty(EventName))
        {
            return;
        }

        // DONE: 调用音频打断事件. 只有是打断状态进来才调用
        if (stopType == StopType.Abnormal)
        {
            if (!string.IsNullOrEmpty(StopEventName) && !string.IsNullOrWhiteSpace(StopEventName))
            {
                WwiseManager.Instance.PlaySound(StopEventName, (GameObject)_playerData);
            }
        }

        cacheSpeed = 0;
        RefreshPlaySpeed(1f);
    }
    
}