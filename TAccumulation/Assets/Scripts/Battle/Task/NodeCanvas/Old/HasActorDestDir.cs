using NodeCanvas.Framework;
using ParadoxNotion.Design;


namespace X3Battle{

	[Category("X3Battle/Old")]
	[Description("角色是否有目标方向。如果是玩家可以理解为是否有遥感输入")]
	public class HasActorDestDir : BattleCondition
    {
        protected override bool OnCheck()
        {
            if (_actor.locomotion == null)
            {
                return false;
            }

            return _actor.locomotion.HasDestDir;
        }
    }
}
