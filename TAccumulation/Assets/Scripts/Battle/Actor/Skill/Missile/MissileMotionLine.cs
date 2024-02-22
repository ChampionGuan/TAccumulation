namespace X3Battle
{
    public class MissileMotionLine : MissileMotionBase
    {
        protected override void _OnUpdate(float deltaTime)
        {
            var deltaPos = _model.forward * _curSpeed * deltaTime;
            var targetPos = _model.position + deltaPos;
            _model.SetPosition(targetPos);
        }
    }
}