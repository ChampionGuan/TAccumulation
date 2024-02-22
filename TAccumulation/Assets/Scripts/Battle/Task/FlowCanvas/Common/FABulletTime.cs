using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("子弹时间（全局时间缩放）\nBulletTime")]
    public class FABulletTime : FlowAction
    {
        [Name("缩放倍率")]
        [SliderField(0f, 1f)]
        public float scale = 1;
        
        [Name("持续时间 (-1一直持续)")]
        public float scaleDuration = -1;

        protected override void _Invoke()
        {
            if (scaleDuration <= 0)
            {
                _battle.SetTimeScale(scale, null, (int)LevelTimeScaleType.Bullet);
            }
            else
            {
                _battle.SetTimeScale(scale, scaleDuration, (int)LevelTimeScaleType.Bullet);
            }
        }
    }
}
