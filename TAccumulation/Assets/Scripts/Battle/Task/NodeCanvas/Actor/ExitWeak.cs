using ParadoxNotion.Design;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using X3Battle;

[Category("X3Battle/Actor")]
[Description("退出虚弱状态")]
public class ExitWeak : CharacterAction
{
    protected override void OnExecute()
    {
        _actor.actorWeak.weakType = WeakType.None;
        _actor.mainState?.TryEndAbnormal(ActorAbnormalType.Weak, _actor.actorWeak);
        EndAction(true);
    }
}
