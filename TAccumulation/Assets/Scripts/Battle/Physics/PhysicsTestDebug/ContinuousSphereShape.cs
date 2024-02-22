using UnityEngine;
using X3Battle;

public class ContinuousSphereShape : BaseShape
{
    // 胶囊体，由两个球 + 圆柱拼接而成
    private Transform _capsule;
    private Transform _sphere1;
    private Transform _sphere2;
    private Transform _cylinder;
    
    protected override void OnEnable()
    {
        _capsule = transform.Find("Capsule");
        _sphere1 = _capsule.Find("Sphere01");
        _sphere2 = _capsule.Find("Sphere02");
        _cylinder = _capsule.Find("Cylinder");
        base.OnEnable();
    }
    
    protected override void RefreshName()
    {
        base.RefreshName();
        name = "Continuous" + name;
    }
    
    public override void SetAngleY(Vector3 rot)
    {
        // 旋转，由开始点和结束点的朝向控制
    }
    
    public override void SetShape(BoundingShape shape, ContinuousArg arg)
    {
        base.SetShape(shape, arg);

        SetCapsuleShape(shape, arg);

        // 设置旋转,球的旋转没有意义，所以这里不在旋转
        // transform.localEulerAngles = arg.rot;
        
        // 设置朝向
        Vector3 dir = arg.endPos - arg.startPos;
        transform.up = dir.normalized;
    }
    
    private void SetCapsuleShape(BoundingShape shape, ContinuousArg arg)
    {
        // 高度设置
        Vector3 dir = arg.endPos - arg.startPos;
        float radius = shape.Radius;
        float cylinderHeight = dir.magnitude;
        float height = dir.magnitude + radius * 2;
        
        // 设置胶囊体的位置。 连续的球检测，root位置在胶囊体底部半球顶点
        _capsule.localPosition = new Vector3(0, height * 0.5f, 0);
        
        Vector3 curScale = _cylinder.localScale;
        curScale.x = radius * 2f;
        curScale.y = cylinderHeight * 0.5f; // 缩放为1时， 圆柱实际高度为2
        curScale.z = radius * 2f;
        _cylinder.localScale = curScale;
        
        Vector3 curPos = _cylinder.localPosition;
        Vector3 localUp = _cylinder.localRotation * Vector3.up;
        _sphere1.localPosition = curPos + localUp * cylinderHeight * 0.5f;
        _sphere2.localPosition = curPos - localUp * cylinderHeight * 0.5f;
        
        // 半径设置
        Vector3 sphere1LocalScale = _sphere1.localScale;
        sphere1LocalScale.x = radius * 2;
        sphere1LocalScale.y = radius * 2;
        sphere1LocalScale.z = radius * 2;
        _sphere1.localScale = sphere1LocalScale;
        _sphere2.localScale = sphere1LocalScale;
    }
    
}