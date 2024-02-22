using UnityEngine;
using X3Battle;

public class CylinderShape : BaseShape
{
    public override void SetShape(BoundingShape shape)
    {
        base.SetShape(shape);
        // 高度设置
        Vector3 curScale = transform.localScale;
        curScale.y = 1 * shape.Height;
        
        // 半径设置
        curScale.x = shape.Radius * 2;
        curScale.z = shape.Radius * 2;
        transform.localScale = curScale;
    }
}