using UnityEngine;
using X3Battle;

public class CubeShape : BaseShape
{
    public override void SetShape(BoundingShape shape)
    {
        base.SetShape(shape);
        // length 
        Vector3 curScale = transform.localScale;
        curScale.x = 1 * shape.Length;
        // widith 
        curScale.z = 1 * shape.Width;
        // height
        curScale.y = 1 * shape.Height;
        
        transform.localScale = curScale;
    }

}