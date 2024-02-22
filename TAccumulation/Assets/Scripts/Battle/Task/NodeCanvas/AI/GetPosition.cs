using Holoville.HOTween.Core.Easing;
using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("获取角色位置")]
    public class GetPosition : BattleAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<Vector3> storeResult = new BBParameter<Vector3>();

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
            var actor = source.isNoneOrNull ? _actor : source.value;
            storeResult.value = actor.transform.position;
            EndAction(true);
        }
    }
}
