using System;
using CollisionQuery;
using UnityEngine;
using X3Battle;

public class CapsuleShape : BaseShape
{
    private Transform _sphere1;
    private Transform _sphere2;
    private Transform _cylinder;

    protected override void Awake()
    {
        _sphere1 = transform.Find("Sphere01");
        _sphere2 = transform.Find("Sphere02");
        _cylinder = transform.Find("Cylinder");
    }
    
    public override void SetShape(BoundingShape shape)
    {
        base.SetShape(shape);
        var actorShape = shape as ActorBoundingShape;
        // 高度设置
        Vector3 curScale = _cylinder.localScale;
        float hegiht = shape.Height - shape.Radius * 2;
        curScale.y = hegiht * 0.5f; // 缩放为1时， 圆柱实际高度为2
        _cylinder.localScale = curScale;
        if (actorShape?.direction == Direction.X)
        {
            _cylinder.localEulerAngles = new Vector3(0, 0, 90f);
        }
        else if (actorShape?.direction == Direction.Z)
        {
            _cylinder.localEulerAngles = new Vector3(90f, 0, 0);
        }
        Vector3 curPos = _cylinder.localPosition;
        Vector3 localUp = _cylinder.localRotation * Vector3.up;
        _sphere1.localPosition = curPos + localUp * hegiht * 0.5f;
        _sphere2.localPosition = curPos - localUp * hegiht * 0.5f;

        
        // 半径设置
        Vector3 sphere1LocalScale = _sphere1.localScale;
        sphere1LocalScale.x = shape.Radius * 2;
        sphere1LocalScale.y = shape.Radius * 2;
        sphere1LocalScale.z = shape.Radius * 2;
        _sphere1.localScale = sphere1LocalScale;
        _sphere2.localScale = sphere1LocalScale;

        sphere1LocalScale.y = _cylinder.localScale.y;
        _cylinder.localScale = sphere1LocalScale;
    }

}