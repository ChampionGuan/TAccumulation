using System;
using System.Collections;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using X3Battle;

#if UNITY_EDITOR
using UnityEditor;
#endif

[ExecuteInEditMode]
public class X3PhysicsDebug : MonoBehaviour
{
    private static X3PhysicsDebug _ins;
    public static X3PhysicsDebug Ins
    {
        get
        {
            if (_ins == null)
            {
                _ins = Create();
            }
            return _ins;
        }
    }
    public static bool isInit => _ins != null;

    private string PrefabPath = "Assets/Scripts/Battle/Physics/PhysicsTestDebug/ShapePrefabs/";
    private Dictionary<ShapeUseType, Dictionary<int, BaseShape>> m_dicAllShapes;
    private Dictionary<ShapeUseType, ShapeTypeCfg> _dicShapeCfg;
    private List<BaseShape> m_listNeedRemoveShape;
    private int curUpdateFrameNum;
    public bool mouseSelect;
    public bool autoRemove = true;
    
    public Dictionary<ShapeUseType, ShapeTypeCfg> ShapeCfgs => _dicShapeCfg;
    
    public static X3PhysicsDebug Create()
    {
        X3PhysicsDebug shapeDebug = GameObject.FindObjectOfType<X3PhysicsDebug>();
        if (shapeDebug != null)
        {
            return shapeDebug;
        }
        shapeDebug = new GameObject("x3PhysicDebug").AddComponent<X3PhysicsDebug>();
        shapeDebug.transform.position = Vector3.zero;
        shapeDebug.transform.localScale = Vector3.one;
        shapeDebug.TryInit();
        return shapeDebug;
    }
    
    public void TryInit()
    {
        if (m_dicAllShapes != null)
            return;
        m_dicAllShapes = new Dictionary<ShapeUseType, Dictionary<int, BaseShape>>();
        m_listNeedRemoveShape = new List<BaseShape>();
        _dicShapeCfg = new Dictionary<ShapeUseType, ShapeTypeCfg>()
        {
            [ShapeUseType.HurtBox] = new ShapeTypeCfg(ShapeUseType.HurtBox, Color.yellow),
            [ShapeUseType.AttackBox] = new ShapeTypeCfg(ShapeUseType.AttackBox, Color.red),
            [ShapeUseType.Collider] = new ShapeTypeCfg(ShapeUseType.Collider, Color.green),
            [ShapeUseType.IgnoreCollision] = new ShapeTypeCfg(ShapeUseType.IgnoreCollision, new Color(0, 1, 0, 0.2f)),
            [ShapeUseType.Trigger] = new ShapeTypeCfg(ShapeUseType.Trigger, Color.white),
            [ShapeUseType.CharacterCtrl] = new ShapeTypeCfg(ShapeUseType.CharacterCtrl, Color.blue),
            [ShapeUseType.Halo] = new ShapeTypeCfg(ShapeUseType.Halo, Color.white),
            [ShapeUseType.Magic] = new ShapeTypeCfg(ShapeUseType.Magic, Color.white),
            [ShapeUseType.CameraTest] = new ShapeTypeCfg(ShapeUseType.CameraTest, Color.white),
            [ShapeUseType.PhysicTest] = new ShapeTypeCfg(ShapeUseType.PhysicTest, Color.white),
        };
        // 用于程序快速查询问题使用，默认不显示
        _dicShapeCfg[ShapeUseType.PhysicTest].isClose = true;
        _dicShapeCfg[ShapeUseType.PhysicTest].delayTime = 0.1f;
    }

    public void OnDestroy()
    {
        if (m_dicAllShapes == null)
        {
            return;
        }
        foreach (var item in m_dicAllShapes)
        {
            foreach (var item2 in item.Value)
            {
                if (item2.Value != null)
                {
                    BattleUtil.DestroyObj(item2.Value.gameObject);
                }
            }
        }
        m_dicAllShapes.Clear();
    }
    
    public void Save()
    {
        foreach (var item in _dicShapeCfg)
        {
            item.Value.Save();
        }
    }

    public bool IsCloseShape(ShapeUseType useType)
    {
        if (_dicShapeCfg.TryGetValue(useType, out var cfg))
        {
            return cfg.isClose;
        }
        return false;
    }

    public void OpenAllShape()
    {
        foreach (var item in _dicShapeCfg)
        {
            item.Value.isClose = false;
        }
    }

    public void Update()
    {
        TryInit();
        curUpdateFrameNum = Time.frameCount;
        
        if (!Application.isPlaying || !autoRemove)
        {
            // 非运行时部分功能不开启
            return;
        }
        foreach (var item in m_dicAllShapes)
        {
            foreach (var item2 in item.Value)
            {
                var baseShape = item2.Value;
                if (baseShape.UpdateFrameNum != curUpdateFrameNum)
                {
                    if (baseShape.StartRemoveTime > 0)
                    {
                        continue; // 已经在等待移除了
                    }
                    baseShape.StartRemoveTime = Time.time;
                    m_listNeedRemoveShape.Add(baseShape);
                }
            }
        }
    }
    
    // 所有的Shape最短时间显示一帧
    public void LateUpdate()
    {
        float curTime = Time.time;
        for (int i = m_listNeedRemoveShape.Count - 1; i >= 0; i--)
        {
            BaseShape shape = m_listNeedRemoveShape[i];
            if (shape == null)
            {
                m_listNeedRemoveShape.RemoveAt(i);
                continue;
            }
            float remainTime = 0;
            if (_dicShapeCfg.TryGetValue(shape.ShapeUseType, out var cfg))
                remainTime = cfg.delayTime;
            float leftTime = (shape.StartRemoveTime + remainTime) - curTime;
            if (leftTime <= 0)
            {
                m_listNeedRemoveShape.Remove(shape);
                BattleUtil.DestroyObj(shape.gameObject);
                if (m_dicAllShapes.TryGetValue(shape.ShapeUseType, out var tempDic))
                {
                    if (tempDic.TryGetValue(shape.UniqueID, out var curShape))
                    {
                        if (curShape == shape)
                            tempDic.Remove(shape.UniqueID);
                    }
                }
            }
        }

        UpdateActorBoundBoxs();
    }

    private void UpdateActorBoundBoxs()
    {
        if (!mouseSelect)
        {
            RefreshActorShapes();
        }
        else
        {
#if UNITY_EDITOR
            var selectObj = Selection.activeObject;
            if (selectObj is GameObject)
            {
                var actorMono = (selectObj as GameObject).GetComponentInChildren<ActorMono>();
                if (actorMono != null)
                    RefreshActorShape(actorMono.actor);
            }
#endif
        }
    }
    
    public bool TryCreateShape(int uniqueID, ShapeUseType shapeUseType, BoundingShape boundingShape, ContinuousArg arg=null)
    {
        if (IsCloseShape(shapeUseType))
        {
            RemoveShape(uniqueID, shapeUseType);
            return false;
        }
        if (!m_dicAllShapes.TryGetValue(shapeUseType, out var tempDic))
        {
            tempDic = new Dictionary<int, BaseShape>();
            m_dicAllShapes[shapeUseType] = tempDic;
        }
        if (tempDic.TryGetValue(uniqueID, out var shape))
        {
            if (boundingShape.ShapeType != shape.ShapeType)
            {
                // id 一致，形状不一致
                RemoveShape(uniqueID, shapeUseType);
            }
        }

        if (!tempDic.ContainsKey(uniqueID))
        {
            shape = GetShape(boundingShape.ShapeType, arg != null);
            if (shape == null)
                return false;
            tempDic[uniqueID] = shape;
            shape.UniqueID = uniqueID;
        }
        InitShape(shapeUseType, shape, boundingShape, arg);
        return true;
    }

    public BaseShape GetShape(int uniqueID, ShapeUseType shapeUseType)
    {
        if (m_dicAllShapes.ContainsKey(shapeUseType))
        {
            if (m_dicAllShapes[shapeUseType].ContainsKey(uniqueID))
            {
                return m_dicAllShapes[shapeUseType][uniqueID];
            }
        }
        return null;
    }
    
    public void RemoveShape(int uniqueID, ShapeUseType shapeUseType)
    {
        float delayRemoveTime = 0;
        if (_dicShapeCfg.TryGetValue(shapeUseType, out var cfg))
            delayRemoveTime = cfg.delayTime;
        
        if (m_dicAllShapes.TryGetValue(shapeUseType, out var tempDic))
        {
            if (tempDic.ContainsKey(uniqueID))
            {
                BaseShape shape = tempDic[uniqueID];
                tempDic.Remove(uniqueID);
                if (shape == null)
                    return;
                if (delayRemoveTime > 0 && (Application.isPlaying && autoRemove))
                {
                    shape.StartRemoveTime = Time.time;
                    // 需要delay, 移动到delayRemove列表中
                    m_listNeedRemoveShape.Add(shape);
                }
                else
                {
                    BattleUtil.DestroyObj(shape.gameObject);
                }
            }
        }
    }

    public void UpdateShapePos(int uniqueID, ShapeUseType useType, Vector3 pos,  Vector3 rot)
    {
        _dicShapeCfg.TryGetValue(useType, out var cfg);
        if (m_dicAllShapes.TryGetValue(useType, out var tempDic))
        {
            if (tempDic.ContainsKey(uniqueID))
            {
                BaseShape shape = tempDic[uniqueID];
                if (shape == null)
                    return;
                shape.SetWorldPos(pos);
                shape.SetAngleY(rot);
                if (cfg != null)
                    shape.SetColor(cfg.color);
                shape.UpdateFrameNum = curUpdateFrameNum;
            }
        }
    }

    public static void AddCameraTestShape(Vector3 pos,  Vector3 rot, BoundingShape shape)
    {
        if (!Application.isEditor)
            return;
        if (isInit) // debug 模式
        {
            var tempShape = new BoundingShape();
            tempShape.CopyFrom(shape);
            int UUID = tempShape.GetHashCode();
            Ins.TryCreateShape(UUID, ShapeUseType.CameraTest, shape);
            Ins.UpdateShapePos(UUID, ShapeUseType.CameraTest, pos, rot);
        }
    }
    
    private void InitShape(ShapeUseType useType, BaseShape shape, BoundingShape boundingShape, ContinuousArg arg)
    {
        _dicShapeCfg.TryGetValue(useType, out var cfg);
        if (cfg == null)
            return;
        shape.SetUseType(useType, cfg);
        shape.SetShape(boundingShape, arg);
        ShapeType type = boundingShape.ShapeType;
    }
    
    public void ShowShapeBox(ShapeBox box, ShapeUseType type)
    {
        int uuID = box.GetHashCode();
        if (TryCreateShape(uuID, type, box.GetBoundingShape()))
        {
            UpdateShapePos(uuID, type, box.GetCurWorldPos(), box.GetCurWorldEuler());
        }
    }

    public void HideShapeBox(ShapeBox box, ShapeUseType type)
    {
        int uuID = box.GetHashCode();
        RemoveShape(uuID, type);
    }
    
    private BaseShape GetShape(ShapeType shapeType, bool isContinuous)
    {
        string prefabName = shapeType.ToString() + "Shape";
        if (isContinuous)
            prefabName = "Continuous" + prefabName;
        GameObject obj = LoadShapePrefab(prefabName);
        if (obj)
        {
            return obj.GetComponent<BaseShape>();
        }
        return null;
    }

    private GameObject LoadShapePrefab(string name)
    {
        string fullPath = PrefabPath + name + ".prefab";
#if UNITY_EDITOR
        GameObject obj = AssetDatabase.LoadAssetAtPath<GameObject>(fullPath);
#else
        GameObject obj = null;
#endif
        
        if (obj == null)
        {
            PapeGames.X3.LogProxy.LogErrorFormat("加载shapePrefab失败，路径：{0}", fullPath);
            return new GameObject("fullPath", typeof(BaseShape));
        }
        GameObject retObj = GameObject.Instantiate(obj, transform);
        retObj.transform.localScale = Vector3.one;
        return retObj;
    }
    
    private void RefreshActorShapes()
    {
        if (!Application.isPlaying)
        {
            return;
        }
        var battle = X3Battle.Battle.Instance;
        if (battle == null)
            return;
        var actors = battle.actorMgr.actors;
        if (actors == null)
            return;
        foreach (var actor in actors)
        {
            RefreshActorShape(actor);
        }
    }

    private void RefreshActorShape(Actor actor)
    {
        if (!Application.isPlaying)
        {
            return;
        }
        if (actor == null)
            return; 
        RefreshActorColliders(actor);
        RefreshActorSkillDamageBox(actor);
        RefreshActorBuffDamageBox(actor);
        RefreshActorHaoDamageBox(actor);
        RefreshActorMagicDamageBox(actor);
        RefreshObstacle(actor);
        RefreshTriggerArea(actor);
    }

    private void RefreshActorColliders(Actor actor)
    {
        if (actor.collider == null)
            return;
        foreach (var item in actor.collider.colliders)
        {
            foreach (var colliderMono in item.Value)
            {
                var actorCollider = colliderMono.Value;
                if (!actorCollider.enabled)
                    continue;
                var useType = GetShapeUseType(actorCollider.type, actorCollider.IsCharacterCtrl);
                int uuID = actorCollider.GetHashCode();
                if (!TryCreateShape(uuID, useType, actorCollider.shape))
                    continue;
                Vector3 pos = actorCollider.Collider.bounds.center;
                Vector3 rot = actorCollider.transform.eulerAngles;
                UpdateShapePos(uuID, useType, pos, rot);
            }
        }
    }
    
    private void RefreshActorSkillDamageBox(Actor actor)
    {
        if (actor.skillOwner == null)
            return;

        var skillSlots = actor.skillOwner.slots;
        foreach (var iter in skillSlots)
        {
            var skill = iter.Value.skill;
            foreach (var damageBox in skill.GetDamageBoxs())
            {
                if (!(damageBox is PhysicsDamageBox physicsDamageBox))
                {
                    continue;
                }

                var useType = ShapeUseType.AttackBox;
                var shapeBox = physicsDamageBox.ShapeBox;
                if (shapeBox == null)
                    continue;
                int uuID = damageBox.GetHashCode();
                if (!TryCreateShape(uuID, useType, shapeBox.GetBoundingShape()))
                    continue;
                Vector3 pos = shapeBox.GetCurWorldPos();
                Vector3 rot = shapeBox.GetCurWorldEuler();
                UpdateShapePos(uuID, useType, pos, rot);
            }
        }
    }
    
    private void RefreshActorBuffDamageBox(Actor actor)
    {
        if (actor.buffOwner == null)
            return;

        var buffs = actor.buffOwner.GetBuffs();
        foreach (var buff in buffs)
        {
            foreach (var damageBox in buff.GetDamageBoxs())
            {
                if (!(damageBox is PhysicsDamageBox physicsDamageBox))
                {
                    continue;
                }
                
                var useType = ShapeUseType.AttackBox;
                var shapeBox = physicsDamageBox.ShapeBox;
                if (shapeBox == null)
                    continue;
                int uuID = damageBox.damageBoxCfg.ID;
                if (!TryCreateShape(uuID, useType, shapeBox.GetBoundingShape()))
                    continue;
                Vector3 pos = shapeBox.GetCurWorldPos();
                Vector3 rot = shapeBox.GetCurWorldEuler();
                UpdateShapePos(uuID, useType, pos, rot);
            }
        }
    }
    
    // 光环
    private void RefreshActorHaoDamageBox(Actor actor)
    {
        if (actor.haloOwner == null)
            return;
        foreach (var halo in actor.haloOwner.GetAllHalo())
        {
            var useType = ShapeUseType.Halo;
            var shapeBox = halo.shapeBox;
            if (shapeBox == null)
                continue;
            int uuID = shapeBox.GetHashCode();
            if (!TryCreateShape(uuID, useType, shapeBox.GetBoundingShape()))
                continue;
            Vector3 pos = shapeBox.GetCurWorldPos();
            Vector3 rot = shapeBox.GetCurWorldEuler();
            UpdateShapePos(uuID, useType, pos, rot);
        }
    }
    
    // 法术场
    private void RefreshActorMagicDamageBox(Actor actor)
    {
        var list = new List<ShapeBox>();
        actor.GetMagicFieldShapes(ref list);
        foreach (var shapeBox in list)
        {
            var useType = ShapeUseType.Magic;
            if (shapeBox == null)
                continue;
            int uuID = shapeBox.GetHashCode();
            if (!TryCreateShape(uuID, useType, shapeBox.GetBoundingShape()))
                continue;
            Vector3 pos = shapeBox.GetCurWorldPos();
            Vector3 rot = shapeBox.GetCurWorldEuler();
            UpdateShapePos(uuID, useType, pos, rot);
        }
    }
    
    // 障碍物
    private void RefreshObstacle(Actor actor)
    {
        if (actor.obstacle == null)
            return;
        var actorCollider = actor.obstacle.x3ActorCollider;
        var useType = GetShapeUseType(actorCollider.type, actorCollider.IsCharacterCtrl);
        int uuID = actorCollider.GetHashCode();
        if (!TryCreateShape(uuID, useType, actorCollider.shape))
            return;
        Vector3 pos = actorCollider.Collider.bounds.center;
        Vector3 rot = actorCollider.transform.eulerAngles;
        UpdateShapePos(uuID, useType, pos, rot);
    }
    
    private void RefreshTriggerArea(Actor actor)
    {
        if (actor.triggerArea == null)
            return;
        var actorCollider = actor.triggerArea.x3ActorCollider;
        var useType = GetShapeUseType(actorCollider.type, actorCollider.IsCharacterCtrl);
        int uuID = actorCollider.GetHashCode();
        if (!TryCreateShape(uuID, useType, actorCollider.shape))
            return;
        Vector3 pos = actorCollider.Collider.bounds.center;
        Vector3 rot = actorCollider.transform.eulerAngles;
        UpdateShapePos(uuID, useType, pos, rot);
    }

    private ShapeUseType GetShapeUseType(ColliderType colliderType, bool isCharacterCtrl)
    {
        var useType = ShapeUseType.Collider;
        switch (colliderType)
        {
            case ColliderType.Collider:
                useType = ShapeUseType.Collider;
                break;
            case ColliderType.HurtBox:
                useType = ShapeUseType.HurtBox;
                break;
            case ColliderType.Trigger:
                useType = ShapeUseType.Trigger;
                break;
            case ColliderType.IgnoreCollision:
                useType = ShapeUseType.IgnoreCollision;
                break;
            default:
                LogProxy.LogError("不支持的类型：" + colliderType);
                break;
        }
        if (isCharacterCtrl)
            useType = ShapeUseType.CharacterCtrl;
        return useType;
    }

    public static void RayCast(Vector3 startPos, Vector3 dir, float dis)
    {
        if (_ins.IsCloseShape(ShapeUseType.PhysicTest))
            return;
        float remainTime = 0.1f;
        if (_ins._dicShapeCfg.TryGetValue(ShapeUseType.PhysicTest, out var cfg))
            remainTime = cfg.delayTime;
        Vector3 endPos = startPos + dir.normalized * dis;
        Debug.DrawLine(startPos, endPos, Color.red, remainTime);
    }
    
    public static void TriangleTest(Vector3 a, Vector3 b, Vector3 c, float angleInterval)
    {
        if (_ins.IsCloseShape(ShapeUseType.PhysicTest))
            return;
        float remainTime = 0.1f;
        if (_ins._dicShapeCfg.TryGetValue(ShapeUseType.PhysicTest, out var cfg))
            remainTime = cfg.delayTime;
        Vector3 ab = b - a;
        Vector3 ac = c - a;
        Vector3 bc = c - b;
        Vector3 bcNorm = bc.normalized;
        float bcLen = bc.magnitude;
        float angle = Vector3.Angle(ab, ac);
        int splitNum = (int)(angle / angleInterval);
        float splitDis = bcLen / splitNum;
        int resultNum = 0;
        // 射线数量 splitNum + 1 条（包括ab， ac）
        for (int i = 0; i <= splitNum; i++)
        {
            Vector3 rayEndPos = b + bcNorm * i * splitDis;
            Debug.DrawLine(a, rayEndPos, Color.red, remainTime);
        }
        // 为了方便看，额外绘制一条 bc
        Debug.DrawLine(b, c, Color.red, remainTime);
    }
}
