using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using PapeGames.X3;
using X3Battle;
using Object = UnityEngine.Object;
[ExecuteInEditMode]
public class PreviewFxPlayer : MonoBehaviour
{
    //Logic
    protected float _speed = 1;

    //Component
    protected List<ParticleSystem> _rootParticles = new List<ParticleSystem>(0);
    protected ParticleSystem[] _allParticles;
    protected Dictionary<ParticleSystem, Vector4> _psStates;//LastPlayTime LastParticleTime , Speed, Delay

    private float _playTime;
    //轨道路线
    private PreviewMissileMotionBase _motion;
    
    //爆炸特效
    private FxPlayer _boom;
    
    #region Init
    public void Awake()
    {
        Init();
    }
    public void Init()
    {
        if (gameObject == null)
            return;
        _psStates = new Dictionary<ParticleSystem, Vector4>();
        _rootParticles = FxPlayerUtility.GetParticleSystemRoots(gameObject);
        foreach (var ps in _rootParticles)
        {
            _psStates[ps] = new Vector4(FxSetting.kUnsetTime, FxSetting.kUnsetTime, 1, 0);
        }
        _allParticles = GetComponentsInChildren<ParticleSystem>();
    }
    
    #endregion

    #region Set
    public void SetMotion(PreviewMissileMotionBase motion)
    {
        _motion = motion;
    }
    public void MotionStart()
    {
        _motion.Start();
    }
    public PreviewMissileMotionBase GetMotion()
    {
        return _motion;
    }
    public void SetSpeed(float value)
    {
        _speed = value;
        for (int i = 0; i < _allParticles.Length; ++i)
        {
            ParticleSystem ps = _allParticles[i];
            ParticleSystem.MainModule main = ps.main;
            main.simulationSpeed = value;
        }
    }
    #endregion

    #region Play
    public void Play()
    {
        if (gameObject.visibleSelf == false)
            gameObject.SetVisible(true);
        
        foreach (var ps in _rootParticles)
        {
            ps.Play();
        }
    }
    public void RePlay()
    {
        Reset();
        Play();
    }
    public void Reset()
    {
        if (!Application.isPlaying)
            Init();
        
        SetSpeed(_speed);
        foreach (var ps in _rootParticles)
        {
            if (ps != null)
                ps.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
        }
    }
    
    public void OnUpdate(float deltaTime)
    {
        if (_motion == null)
            return;
        _playTime += deltaTime;
        _motion.Update(deltaTime);
        _UpdateParticles();
        if (_motion.IsComplete())
        {
            gameObject.SetActive(false);
            PlayBoom();
        }
    }
    
    private void _UpdateParticles()
    {
        for (int i = 0; i < _rootParticles.Count; i++)
        {
            var ps = _rootParticles[i];
            if (!_psStates.TryGetValue(ps, out var psTime))
                continue;

            var time = (_playTime - psTime.w) * psTime.z;
            if (time < 0)
                continue;
            var particleTime = ps.time;

            // if particle system time has changed externally, a re-sync is needed
            if (psTime.y > time || !Mathf.Approximately(particleTime, psTime.y))
                Simulate(ps, time, true);
            else if (psTime.x < time)
                Simulate(ps, time - psTime.x, false);
            else
                Simulate(ps, Time.deltaTime, false);

            psTime.x = time;
            psTime.y = ps.time;
            _psStates[ps] = psTime;
        }
    }
    private void Simulate(ParticleSystem particleSystem, float time, bool restart)
    {
        const bool withChildren = true; // timeline1.6.4这里默认用false，这里延用之前版本的true，避免引发其他未知bug
        const bool fixedTimeStep = false;
        float maxTime = Time.maximumDeltaTime;

        if (restart)
            particleSystem.Simulate(0, withChildren, true, fixedTimeStep, false);

        // simulating by too large a time-step causes sub-emitters not to work, and loops not to
        // simulate correctly
        while (time > maxTime)
        {
            particleSystem.Simulate(maxTime, withChildren, false, fixedTimeStep, false);
            time -= maxTime;
        }

        if (time > 0)
            particleSystem.Simulate(time, withChildren, false, fixedTimeStep, false);
    }
    public void Destroy()
    {
        if (_motion != null)
        {
            _motion.HideShapeBox();
        }
        _motion = null;

        if (this != null && gameObject != null)
        {
            DestroyImmediate(gameObject);
        }
    }

    public void SetMotionCurTime(double duraTion)
    {
        _motion.SetCurTime(duraTion);
    }

    /// <summary>
    /// 播放爆炸特效
    /// </summary>
    public void PlayBoom()
    {
        if (_motion.cfg.BlastFX > 0 && _boom == null)
        {
            _boom = PreviewMissileFxMgr.Instance.PlayFx(_motion.cfg.BlastFX, _motion.missile.transform.localPosition);
            _boom.Awake();
            PreviewBoom previewBoom = _boom.gameObject.AddComponent<PreviewBoom>();
            previewBoom.Init(_boom, _motion.cfg.BlastDamageBox);
        }
    }
    #endregion
}