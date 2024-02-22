using System;
using UnityEngine;
using X3Battle;

[ExecuteInEditMode]
public class AnnularSectorShape : BaseShape
{
    public override void SetShape(BoundingShape shape)
    {
        base.SetShape(shape);
        var annularSector  = GetComponentInChildren<AnnularSector>();
        annularSector.SetShape(shape);
        annularSector.transform.localPosition = new Vector3(0, shape.Height * 0.5f, 0);
    }

    public override void SetUseType(ShapeUseType type, ShapeTypeCfg cfg)
    {
        base.SetUseType(type, cfg);
        ShapeUseType = type;
        RefreshName();
    }
}












