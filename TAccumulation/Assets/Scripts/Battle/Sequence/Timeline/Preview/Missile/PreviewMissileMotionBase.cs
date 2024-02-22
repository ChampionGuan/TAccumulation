using UnityEngine;
using X3Battle;

public class PreviewMissileMotionBase
{
    protected MissileCfg _cfg;  // 子弹配置
    protected float _curSpeed;
    protected Vector3 targetPosition;//目标位置
    protected Vector3 targetForward;//目标方向
    protected GameObject _missile;//子弹
    protected Vector3 startPos;
    protected Vector3 startForward;
    protected float suspendTime;//悬停时间
    protected double curTime;
    private double m_lastCurTime;
    private ShapeBox _shapeBox = null;
    private ShapeUseType _shapeUseType = ShapeUseType.AttackBox;
    public MissileCfg cfg
    {
        get { return _cfg; }
    }
    public GameObject missile
    {
        get { return _missile; }
    }
    // 初始化
    public void Init(MissileCfg cfg, GameObject missile, Vector3 targetPosition, Vector3 targetForward, Vector3 startPos, Vector3 startForward, float suspendTime)
    {
        this._missile = missile;
        _cfg = cfg;
        _curSpeed = _cfg.MotionData.InitialSpeed;
        this.targetPosition = targetPosition;
        this.targetForward = targetForward;
        this.startPos = startPos;
        this.startForward = startForward;
        this.suspendTime = suspendTime;
        _OnInit();
        InitShapeBox();
    }

    public void InitShapeBox()
    {
        var damageBoxCfg = TbUtil.GetCfg<DamageBoxCfg>(_cfg.DamageBox);
        _shapeBox = new ShapeBox();
        _shapeBox.Init(damageBoxCfg.ShapeBoxInfo, new VirtualTrans(_missile.transform));
        _ShowShapeBox();
    }
    private void _ShowShapeBox()
    {
        if (_shapeBox == null)
            return;
        _shapeBox.Update();
        X3PhysicsDebug.Ins.autoRemove = false;
        if (X3PhysicsDebug.Ins.ShapeCfgs != null && !X3PhysicsDebug.Ins.ShapeCfgs[_shapeUseType].isClose)
        {
            X3PhysicsDebug.Ins.ShowShapeBox(_shapeBox, _shapeUseType);
        }
    }
    
    public void HideShapeBox()
    {
        if (_shapeBox == null)
            return;
        X3PhysicsDebug.Ins.HideShapeBox(_shapeBox, _shapeUseType);
        _shapeBox = null; 
    }
    public void Start()
    {
        _OnStart();
    }

    public void SetCurTime(double curTime)
    {
        this.curTime = curTime;
    }
    
    public void Update(float deltaTime)
    {
        //如果这一次操作和上一次操作都处于悬停时间内 不操作
        if (curTime <= suspendTime && m_lastCurTime <= suspendTime)
        {
            return;
        }

        //如果上一次操作不在悬停时间内 这一次操作在悬停时间内
        if (curTime < suspendTime && m_lastCurTime > suspendTime)
        {
            deltaTime = (float)(suspendTime - m_lastCurTime);
        }
        
        _curSpeed = _curSpeed + _cfg.MotionData.Accelerate * deltaTime;

        if (_cfg.MotionData.MaxSpeed > 0f)
        {
            if (_cfg.MotionData.Accelerate < 0f && _curSpeed < _cfg.MotionData.MaxSpeed)
            {
                _curSpeed = _cfg.MotionData.MaxSpeed;
            }
            else if (_cfg.MotionData.Accelerate >= 0f && _curSpeed > _cfg.MotionData.MaxSpeed)
            {
                _curSpeed = _cfg.MotionData.MaxSpeed;
            }
        }
        _OnUpdate(deltaTime);
        m_lastCurTime = curTime;
        _ShowShapeBox();
    }

    // ------------------ 提供给子类实现的方法 ---------------------------

    /// <summary>
    /// 初始化方法，不需要可以不重写
    /// </summary>
    protected virtual void _OnInit()
    {
            
    }

    /// <summary>
    /// 每次悬停结束，开始运动时会调用一次
    /// </summary>
    protected virtual void _OnStart()
    {
        
    }

    /// <summary>
    /// 每次Start之后，end之前会调用
    /// </summary>
    /// <param name="deltaTime"></param>
    protected virtual void _OnUpdate(float deltaTime)
    {
        
    }
    
    /// <summary>
    /// 每次子弹运动结束会调用一次，不需要可以不重写
    /// </summary>
    protected virtual void _OnStop()
    {
        
    }
    
    /// <summary>
    /// 每次Update之后会调用，这里需要告诉上层逻辑，自己是否结束了
    /// </summary>
    /// <returns></returns>
    public virtual bool IsComplete()
    {
        return false;
    }
}
