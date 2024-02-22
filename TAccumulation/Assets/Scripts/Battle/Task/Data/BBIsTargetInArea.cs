using System;
using System.Collections.Generic;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Serializable]
    public class BBIsTargetInArea
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<float> rotateAngle = new BBParameter<float>();
        public BBParameter<float> fanColumnAngle = new BBParameter<float>();
        public BBParameter<float> radius = new BBParameter<float>();

        public bool IsInArea(Actor actor)
        {
            Actor curActor = source.isNoneOrNull ? actor : source.value;
            if (curActor == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("源角色信息配置错误，请找【楚门】");
                return false;
            }
            return BattleUtil.IsTargetInFanColumn(curActor, target.value, rotateAngle.value, fanColumnAngle.value, radius.value);
        }
    }
}
