using X3Battle;

public class PreviewMissileMotionLine : PreviewMissileMotionBase
{
    private bool _bIsComplete; // 标记是否完成.
    protected override void _OnUpdate(float deltaTime)
    {
        var deltaPos = targetForward * _curSpeed * deltaTime;
        var movePos = _missile.transform.localPosition + deltaPos;
        _missile.transform.SetLocalPositionAndRotation(movePos, _missile.transform.localRotation);
        
        // DONE: 当该次位移超过目标点时.
        if (movePos.sqrMagnitude >= targetPosition.sqrMagnitude)
        {
            _bIsComplete = true;
        }
    }
    public override bool IsComplete()
    {
        return _bIsComplete;
    }

}