using NodeCanvas.Framework;
using ParadoxNotion.Design;
using System;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Old")]
    [Description("角色是否有目标方向。如果是玩家可以理解为是否有遥感输入")]
    public class IsActorMainState : BattleCondition
    {
        [Tooltip("此值如果为空，则取自身状态")]
        public BBParameter<Actor> source = new BBParameter<Actor>();

        public BBParameter<ActorMainStateType[]> checkStates = new BBParameter<ActorMainStateType[]>();

        protected override string info
        {
            get { return BattleUtil.GetArrayDesc(checkStates.GetValue()); }
        }

        protected override bool OnCheck()
        {
            var actor = null == source || source.isNoneOrNull ? _actor : source.value;
            return Array.IndexOf(checkStates.GetValue(), actor.mainState.mainStateType) >= 0;
        }
    }
}
