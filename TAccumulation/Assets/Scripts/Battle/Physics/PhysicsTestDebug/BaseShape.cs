using System;
using System.Collections.Generic;
using UnityEngine;
using X3Battle;

[Serializable]
public class ContinuousArg
{
    public Vector3 startPos;
    public Vector3 endPos;
    public Vector3 rot;
}

[ExecuteInEditMode]
public class BaseShape : MonoBehaviour
{
    private ShapeType _shapeType;
    protected List<Material> m_materials;
    public ShapeUseType ShapeUseType;
    public BoundingShape Shape;
    public ContinuousArg ContinuousArg;
    [HideInInspector]
    public float StartRemoveTime;
    public int UniqueID;
    public int UpdateFrameNum;
    public ShapeType ShapeType => _shapeType;
    protected Color _curColor;

    protected virtual void Awake()
    {
    }

    protected virtual void OnEnable()
    {
        SetShape(Shape, ContinuousArg);
    }

    private void InitShader(bool isNeedWireFrame)
    {
        MeshRenderer[] renderers = GetComponentsInChildren<MeshRenderer>();
        m_materials = new List<Material>();
        for (int i = 0; i < renderers.Length; i++)
        {
            if (Application.isPlaying)
            {
                Material[] mats = renderers[i].materials;
                bool isHaveWireframeMat = false;
                foreach (var mat in mats)
                {
                    isHaveWireframeMat = mat.name.Contains("ShowWireFrame")  || isHaveWireframeMat;
                    if (isHaveWireframeMat && !isNeedWireFrame)
                    {
                        continue;
                    }
                    m_materials.Add(mat);
                }
                
                List<Material> tempMats = new List<Material>(m_materials);
                if (!isHaveWireframeMat && isNeedWireFrame)
                {
                    Material tempMat = new Material(Shader.Find("Papegame/ShowWireframe"));
                    tempMats.Add(tempMat);
                }
                renderers[i].materials = tempMats.ToArray();
            }
            else
            {
                Material[] mats = renderers[i].sharedMaterials;
                foreach (var mat in mats)
                {
                    if (!renderers[i].sharedMaterial)
                    {
                        continue;
                    }
                    Material tempMat = new Material(renderers[i].sharedMaterial);
                    renderers[i].material = tempMat;
                    m_materials.Add(tempMat);
                }
            }
        }
    }
    
    public virtual void SetUseType(ShapeUseType type, ShapeTypeCfg cfg)
    {
        ShapeUseType = type;
        if (m_materials == null)
        {
            InitShader(cfg.isShowWireFrame);
            return;
        }
        _curColor = cfg.color;
        for (int i = 0; i < m_materials.Count; i++)
        {
            m_materials[i].SetColor("_Color", _curColor);
        }
        RefreshName();
    }

    public virtual void SetShape(BoundingShape shape)
    {
        Shape = shape;
        _shapeType = shape.ShapeType;
        RefreshName();
    }
    
    public virtual void SetShape(BoundingShape shape, ContinuousArg arg)
    {
        SetShape(shape);
        ContinuousArg = arg;
    }

    protected virtual void RefreshName()
    {
        string shapeTypeName = Enum.GetName(typeof(ShapeType), this.ShapeType);
        string useTypeName = Enum.GetName(typeof(ShapeUseType), this.ShapeUseType);
        this.name = shapeTypeName + "_" + useTypeName;
    }
    
    public virtual void SetLength(float value)
    {
        Shape.Length = value;
        SetShape(Shape);
    }

    public virtual void SetWidth(float value)
    {
        Shape.Width = value;
        SetShape(Shape);
    }

    public virtual void SetHeight(float value)
    {
        Shape.Height = value;
        SetShape(Shape);
    }

    public virtual void SetRadius(float value)
    {
        Shape.Radius = value;
        SetShape(Shape);
    }

    public virtual void SetAngle(float value)
    {
        Shape.Angle = value;
        SetShape(Shape);
    }
    
    public void SetColor(Color color)
    {
        if (color == _curColor)
        {
            return;
        }
        _curColor = color;
        if (m_materials == null)
        {
            return;
        }
        for (int i = 0; i < m_materials.Count; i++)
        {
            m_materials[i].SetColor("_Color", _curColor);
        }
    }
    
    public virtual void SetWorldPos(Vector3 pos)
    {
        transform.localPosition = pos;
    }

    public virtual void SetAngleY(Vector3 rot)
    {
        transform.localEulerAngles = rot;
    }
}