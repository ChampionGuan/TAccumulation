using UnityEngine;
using System.Collections.Generic;
using UnityEngine.Animations;
using UnityEngine.Playables;
using XLua;

[LuaCallCSharp]
[DisallowMultipleComponent]
public class CameraTrackBindCtrl : MonoBehaviour
{
    private PlayableGraph _playableGraph;
    private AnimationPlayableOutput _playableOutput;

    //目前只考虑5个动画融合的问题,如果超出，就给出警告
    private AnimationMixerPlayable _unifiedTrackMixer;
    //当前绑定的轨道数量
    private Dictionary<TimelineExtInfo, AnimationClipPlayable> _bindedTrackDic = 
        new Dictionary<TimelineExtInfo, AnimationClipPlayable>();
    
    //正在起作用的port
    private Dictionary<TimelineExtInfo, int> _workingInputPortDic = new Dictionary<TimelineExtInfo, int>();
    //最多正在显示的port
    private int _maxPort = 5;
    private Animator _curAnim;

    private bool _init = false;

    void Start()
    {
        Init();
        _bindedTrackDic.Clear();
        _workingInputPortDic.Clear();
    }

    void Init()
    {
        if (_init)
        {
            return;
        }
        
        _playableGraph = PlayableGraph.Create("bind_" + transform.name);
        _playableGraph.SetTimeUpdateMode(DirectorUpdateMode.GameTime);
        _curAnim = GetComponent<Animator>();
        _curAnim.enabled = true;
        
        _playableOutput = AnimationPlayableOutput.Create(_playableGraph,
            "Output", _curAnim);
        
        _unifiedTrackMixer = AnimationMixerPlayable.Create(_playableGraph, _maxPort);
        
        _playableOutput.SetSourcePlayable(_unifiedTrackMixer);

        _init = true;
    }

    void Uninit()
    {
        if (_init)
        {
            _unifiedTrackMixer.Destroy();
            _playableGraph.Destroy();
            _init = false;
        }
    }

    private int GetAvailablePort()
    {
        for (int i = 0; i < _maxPort; i++)
        {
            if (false == _workingInputPortDic.ContainsValue(i))
            {
                return i;
            }
        }

        PapeGames.X3.X3Debug.LogError("超过5个clip同时在起作用");
        return 0;
    }

    public void PlayNewTrack(TimelineExtInfo timelineExtInfo, AnimationClip animClip)
    {
        if (_init == false)
        {
            return;
        }
        if (_bindedTrackDic.ContainsKey(timelineExtInfo))
        {
            return;
        }
        PapeGames.X3.X3Debug.Log("lta test Start to Bind Camera: " + timelineExtInfo.name);
        var weight = 1f / (float)(_bindedTrackDic.Count + 1);
        int inputPort = 0;
        foreach (var VARIABLE in _workingInputPortDic)
        {
            _unifiedTrackMixer.SetInputWeight(VARIABLE.Value, weight);
        }
        
        var clipPlayable = AnimationClipPlayable.Create(_playableGraph, animClip);
        clipPlayable.SetTime(0);
        _bindedTrackDic[timelineExtInfo] = clipPlayable;

        var newPort = GetAvailablePort();
        _workingInputPortDic[timelineExtInfo] = newPort;
        
        _unifiedTrackMixer.ConnectInput(newPort, clipPlayable, 0);
        _unifiedTrackMixer.SetInputWeight(clipPlayable, weight);
        
        _playableGraph.Play();
    }
    
    public void StopNewTrack(TimelineExtInfo timelineExtInfo)
    {
        if (_init == false)
        {
            return;
        }
        int inputPort = 0;
        if (false == _workingInputPortDic.TryGetValue(timelineExtInfo, out inputPort))
        {
            return;
        }
        PapeGames.X3.X3Debug.Log("lta test Start to Unbind Camera: " + timelineExtInfo.name);
        _unifiedTrackMixer.DisconnectInput(inputPort);
        _workingInputPortDic.Remove(timelineExtInfo);
        _bindedTrackDic.Remove(timelineExtInfo);

        var curPortCount = _bindedTrackDic.Count;
        if (curPortCount > 0)
        {
            var weight = 1f / curPortCount;
            foreach (var VARIABLE in _workingInputPortDic)
            {
                _unifiedTrackMixer.SetInputWeight(VARIABLE.Value, weight);
            }
        }
    }

    void OnDestroy()
    {
        _bindedTrackDic.Clear();
        _workingInputPortDic.Clear();
        Uninit();
    }
}
