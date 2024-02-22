using System;
using UnityEngine;
using X3Battle;

public class FanColumnShape : BaseShape
{
    public float Height;
    public float Angle;
    public override void SetShape(BoundingShape shape)
    {
        base.SetShape(shape);
        var annularSector  = GetComponentInChildren<AnnularSector>();
        annularSector.SetShape(shape);
        annularSector.transform.localPosition = new Vector3(0, shape.Height * 0.5f, 0);
    }
    
    public override void SetWorldPos(Vector3 offset)
    {
        base.SetWorldPos(offset);
        DrawRay();
    }
    
    private void DrawRay()
    {
        // 识别当pos不在角度内，但是collider与扇形有相交的情况
        Vector3 localFoward = transform.forward;
        Vector3 localUp = transform.up;
        Vector3 centerPos = transform.position;
        Vector3 point0 = centerPos + localUp * Height * 0.5f;
        Vector3 point1 = centerPos - localUp * Height * 0.5f;
        float rotAngle = Angle * 0.5f;
        // 上边一条射线
        Vector3 rayDir = Quaternion.AngleAxis(rotAngle, localUp) * localFoward;
        Ray ray = new Ray(point0, localFoward);
        Debug.DrawRay(ray.origin, ray.direction, Color.red);
        // 下边一条射线
        rayDir = Quaternion.AngleAxis(rotAngle, localUp) * localFoward;
        ray = new Ray(point1, localFoward);
        Debug.DrawRay(ray.origin, ray.direction, Color.red);
        // 右边三条射线
        rayDir = Quaternion.AngleAxis(rotAngle, localUp) * localFoward;
        ray = new Ray(centerPos, rayDir);
        Debug.DrawRay(ray.origin, ray.direction, Color.blue);
        ray.origin = point0;
        Debug.DrawRay(ray.origin, ray.direction, Color.red);
        ray.origin = point1;
        Debug.DrawRay(ray.origin, ray.direction, Color.green);
        // 左边三条射线
        rayDir = Quaternion.AngleAxis(rotAngle * -1, localUp) * localFoward;
        ray = new Ray(centerPos, rayDir);
        Debug.DrawRay(ray.origin, ray.direction, Color.blue);
        ray.origin = point0;
        Debug.DrawRay(ray.origin, ray.direction, Color.red);
        ray.origin = point1;
        Debug.DrawRay(ray.origin, ray.direction, Color.green);
    }
}












