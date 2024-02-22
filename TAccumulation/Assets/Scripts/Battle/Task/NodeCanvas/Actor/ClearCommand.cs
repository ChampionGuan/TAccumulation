using ParadoxNotion.Design;
using UnityEngine;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("清除当前角色的所有指令")]
    public class ClearCommand : BattleAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();

        /*
        protected override string info
        {
            get
            {
                if ((Application.isPlaying && source.isNoneOrNull) || (!source.useBlackboard || source.isNone))
                {
                    return "清除自身的所有指令";
                }

                return "清除目标单位的所有指令";
            }
        }
        */
        
        protected override void OnExecute()
        {
            if (source.isNoneOrNull)
            {
                _actor.commander?.ClearCmd();
            }
            else
            {
                source.value.commander?.ClearCmd();
            }

            EndAction(true);
        }
    }
}
