using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Serializable]
    public class BBIsTimerOver
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        [X3TimerID]
        public BBParameter<int> id = new BBParameter<int>();

        public bool IsOver(Actor actor)
        {
            Actor curActor = source.isNoneOrNull ? actor : source.value;
            return curActor.timer.IsTimerOver(id.value);
        }
    }
}
