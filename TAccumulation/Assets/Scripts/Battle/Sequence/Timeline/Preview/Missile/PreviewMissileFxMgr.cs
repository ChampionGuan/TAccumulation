using PapeGames.X3;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using X3Battle;

public class PreviewMissileFxMgr : Singleton<PreviewMissileFxMgr> 
{
    protected List<PreviewFxPlayer> _cfgFxs;

    private FxMgr _fxMgr;
    private BattleFxLoaderPro _loader;
    public PreviewMissileFxMgr()
    {
        _cfgFxs = new List<PreviewFxPlayer>();
        TbUtil.Init();
        _fxMgr = new FxMgr(null);
        _loader = new BattleFxLoaderPro();
    }

    public void DestoryAll()
    {
        for (int i = _cfgFxs.Count - 1; i >= 0; i--)
        {            
            var fx = _cfgFxs[i];
            if (fx != null)
            {
                GameObject.DestroyImmediate(fx.gameObject);
            }
            _cfgFxs.RemoveAt(i);
        }

        _loader = null;
    }

    /// 战斗播放子弹特效
    public PreviewFxPlayer PlayBattleFx(int cfgID, Transform parent, MissileCfg missileCfg, Vector3 targetPos, Vector3 targetDir, Vector3 startPos, Vector3 startDir, float suspendTime)
    {
        FXConfig cfg = TbUtil.GetCfg<FXConfig>(missileCfg.FX);
        if (cfg == null)
        {
            LogProxy.LogError($"特效配置(id={cfgID})不存在!");
            return null;
        }
        
        var fx = LoadFx(cfg.PrefabName, BattleResType.FX);
        
        if (fx == null)
            return null;

        //创建子弹
        PreviewMissileMotionBase motionBase = null;
        var motionData = missileCfg.MotionData;
        if (motionData.MotionType == MissileMotionType.Line)
        {
            motionBase = new PreviewMissileMotionLine();
        }
        else if(motionData.MotionType == MissileMotionType.Curve)
        {
            motionBase = new PreviewMissileMotionCurve();
        }
        else if (motionData.MotionType == MissileMotionType.Bezier)
        {
            motionBase = new PreviewMissileMotionBezier();
        }

        
        Vector3 setAngle = Vector3.zero;
        if (cfg.RandomRotateType == (int)BattleFXRandomRotateType.Random)//1不随机 2随机
        {
            setAngle += new Vector3(
                Random.Range(-cfg.XAxisRandomAngel, cfg.XAxisRandomAngel),
                Random.Range(-cfg.YAxisRandomAngel, cfg.YAxisRandomAngel),
                Random.Range(-cfg.ZAxisRandomAngel, cfg.ZAxisRandomAngel));
        }
        
        Vector3 setScale = Vector3.one;
        if (cfg.Scale.Length == 3)
            setScale = new Vector3(cfg.Scale[0], cfg.Scale[1], cfg.Scale[2]);
        else if (cfg.Scale.Length != 0)
            LogProxy.LogError($"FxConfig Scale配置错误 长度:{cfg.Scale.Length}");
        
        fx.gameObject.transform.SetParent(parent);
        fx.gameObject.transform.localEulerAngles = setAngle;
        fx.gameObject.transform.localScale = setScale;
        fx.gameObject.transform.forward = startDir;
        fx.gameObject.transform.localPosition = startPos;
        
        motionBase.Init(missileCfg, fx.transform.gameObject,targetPos, targetDir, startPos,startDir, suspendTime);
        fx.SetMotion(motionBase);
        
        fx.RePlay();
        fx.MotionStart();
        
        _cfgFxs.Add(fx);

        return fx;
    }

    public PreviewFxPlayer LoadFx(string relativePath, BattleResType type)
    {
        Object obj = null;
        PreviewFxPlayer fxPlayer = null;
        
        ResLoadArg arg = new ResLoadArg();
        arg.relativePath = relativePath;
        arg.type = type;
        if(_loader == null) _loader = new BattleFxLoaderPro();
        obj = _loader.Load(arg);
        
        if (obj == null)
        {
            LogProxy.LogError("缺少资源类型配置，资源类型：" + type);
            return null;
        }
        
        switch (type)
        {
            case BattleResType.FX:
            case BattleResType.HurtFX:
                var tempObj = obj as GameObject;
                fxPlayer = tempObj.GetComponent<PreviewFxPlayer>();
                if (fxPlayer == null)
                {
                    fxPlayer = tempObj.AddComponent<PreviewFxPlayer>();
                }
                var tempPlayer = tempObj.GetComponent<FxPlayer>();
                if (tempPlayer)
                {
                    tempObj.RemoveComponent<FxPlayer>();
                }
                break;
        }

        return fxPlayer;
    }

    /// <summary>
    /// 播放特效
    /// </summary>
    public FxPlayer PlayFx(int cfgId,Vector3 pos)
    {
        _fxMgr.DestroyAllFx();

        var _boom = _fxMgr.PlayBattleFx(cfgId, 0, pos);
        return _boom;
    }
    
}

