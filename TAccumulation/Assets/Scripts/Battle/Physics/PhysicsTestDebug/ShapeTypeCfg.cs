using System;
using System.Collections.Generic;
using UnityEngine;
using X3Battle;
using EventType = X3Battle.EventType;

#if UNITY_EDITOR
using UnityEditor;
#endif


public enum ShapeUseType
{
    Collider = 1,
    HurtBox = 2,
    Trigger = 3,
    AttackBox = 4,
    CharacterCtrl = 5,
    AttackHit = 6, //攻击命中
    Halo = 7, //光环
    Magic = 8, //光环
    PhysicTest = 9, //物理检测接口
    IgnoreCollision, // 忽略碰撞的Collider
    CameraTest, // 相机碰撞检测
}

[Serializable]
public class ShapeTypeCfg
{
    private Color _color;
    private bool _isClose;
    private float _delayTime;
    private bool _isShowWireFrame; // 是否需要显示线框
    
    private ShapeUseType _useType;
    private string _saveKey;

    public Color color
    {
        get => _color;
        set => _color = value;
    }
    public bool isClose
    {
        get => _isClose;
        set => _isClose = value;
    }
    public float delayTime
    {
        get => _delayTime;
        set => _delayTime = value;
    }
    public bool isShowWireFrame
    {
        get => _isShowWireFrame;
        set => _isShowWireFrame = value;
    }
    public ShapeUseType useType=>_useType;
    
    public ShapeTypeCfg(ShapeUseType useType, Color defaultColor)
    {
        _saveKey = "PhysicsShapeDebug_" + useType.ToString();
        string cfg = PlayerPrefs.GetString(_saveKey, "");
        _useType = useType;
        if (string.IsNullOrEmpty(cfg))
        {
            _color = defaultColor;
            _isClose = false;
            return;
        }
        var strs = cfg.Split('*');
        float r = float.Parse(strs[0]);
        float g = float.Parse(strs[1]);
        float b = float.Parse(strs[2]);
        float a = float.Parse(strs[3]);
        _color = new Color(r, g, b, a);
        _isClose = int.Parse(strs[4]) == 1 ? true : false;
        delayTime = float.Parse(strs[5]);
        _isShowWireFrame = int.Parse(strs[6]) == 1 ? true : false;
    }

    public void Save()
    {
        PlayerPrefs.SetString(_saveKey, ToString());
    }

    public override string ToString()
    {
        string str = string.Format("{0}*{1}*{2}*{3}*{4}*{5}*{6}", 
            _color.r, _color.g, _color.b, _color.a, 
            _isClose ? 1 : 0, 
            _delayTime, 
            _isShowWireFrame ? 1 : 0);
        return str;
    }
}
