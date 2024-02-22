using UnityEngine;
using X3Battle;

public class RayShape : BaseShape
{
    public float scale = 0.05f;

    public override void SetShape(BoundingShape shape)
    {
        base.SetShape(shape);
        float value = Mathf.Min(shape.Length, 9999999f);
        Vector3 curScale = transform.localScale;
        curScale.z = 1 * value;
        curScale.x = scale;
        curScale.y = scale;
        transform.localScale = curScale;
    }
}