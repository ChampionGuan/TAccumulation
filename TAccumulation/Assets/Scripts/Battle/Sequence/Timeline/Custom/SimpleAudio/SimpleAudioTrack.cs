using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[TrackColor(0, 1, 0)]
// [TrackBindingType(typeof(GameObject))]
[TrackClipType(typeof(SimpleAudioPlayableClip))]
[TrackBindingType(typeof(GameObject))]
public class SimpleAudioTrack : TrackAsset, IInterruptTrack
{
    [LabelText("打断时不结束")]
    public bool isStopByTime = false;
        
    [LabelText("逻辑结束时结束")]
    public bool isStopByLogic = false;
    
    [LabelText("是否仅出生镜头演出时播放")]
    public bool isBornCamPlay = false;
    
    [HideInInspector] public TrackExtData extData = null; 
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