using UnityEngine;
using X3Battle;

public class SphereShape : BaseShape
{
    public override void SetShape(BoundingShape shape)
    {
        base.SetShape(shape);
        // 半径设置
        Vector3 curScale = transform.localScale;
        curScale.x = 2 * shape.Radius;
        curScale.y = 2 * shape.Radius;
        curScale.z = 2 * shape.Radius;
        transform.localScale = curScale;
    }
    
}