using System;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Serializable]
    public class BBIsObstacleInArea
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<float> rotateAngle = new BBParameter<float>();
        public BBParameter<float> fanColumnAngle = new BBParameter<float>();
        public BBParameter<float> radius = new BBParameter<float>();

        public bool IsInArea(Actor actor)
        {
            Actor curActor = source.isNoneOrNull ? actor : source.value;
            return BattleUtil.IsObstacleInFanColumn(curActor, rotateAngle.value, fanColumnAngle.value, radius.value);
        }
    }
}
