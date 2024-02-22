using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("获取最近敌方单位")]
    public class GetNearestEnemy : BattleAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<Actor> storeResult = new BBParameter<Actor>();

        /*
        protected override string info
        {
            get
            {
                if ((Application.isPlaying && source.isNoneOrNull) || (!source.useBlackboard || source.isNone))
                {
                    return "获取自身最近的敌方单位";
                }

                return "获取目标单位最近的敌方单位";
            }
        }
        */

        protected override void OnExecute()
        {
            storeResult.value = BattleUtil.GetNearestEnemy(source.isNoneOrNull ? _actor : source.value);
            EndAction(true);
        }
    }
}
