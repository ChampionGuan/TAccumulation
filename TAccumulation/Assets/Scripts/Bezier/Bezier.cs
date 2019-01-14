using UnityEngine;

public class Bezier
{
    private Vector3 startPos;
    private Vector3 endPos;
    private Vector3 middlePos;
    private Vector3 resultPos;
    private float distance;

    private void Clear()
    {
        distance = 0;
        startPos = Vector3.zero;
        endPos = Vector3.zero;
        middlePos = Vector3.zero;
        resultPos = Vector3.zero;
    }

    public void SetBezierPoints(Vector3 _startPos, Vector3 _endPos, float _heightFactor)
    {
        Clear();
        distance = Vector3.Distance(_startPos, _endPos);
        startPos = _startPos;
        endPos = _endPos;
        middlePos = 0.5f * (startPos + endPos) + new Vector3(0, distance, 0) * _heightFactor;
    }

    public void SetLinePoints(Vector3 _startPos, Vector3 _endPos)
    {
        Clear();
        startPos = _startPos;
        endPos = _endPos;
        middlePos = 0.5f * (startPos + endPos);
    }

    public Vector3 GetPointAtTime(float value)
    {
        value = value > 1 ? 1 : value;
        value = value < 0 ? 0 : value;
        resultPos.x = value * value * (endPos.x - 2 * middlePos.x + startPos.x) + startPos.x + 2 * value * (middlePos.x - startPos.x);
        resultPos.y = value * value * (endPos.y - 2 * middlePos.y + startPos.y) + startPos.y + 2 * value * (middlePos.y - startPos.y);
        resultPos.z = value * value * (endPos.z - 2 * middlePos.z + startPos.z) + startPos.z + 2 * value * (middlePos.z - startPos.z);

        return resultPos;
    }
}
