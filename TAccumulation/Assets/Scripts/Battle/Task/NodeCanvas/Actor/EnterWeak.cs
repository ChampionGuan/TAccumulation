using NodeCanvas.Framework;
using ParadoxNotion.Design;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using X3Battle;

[Category("X3Battle/Actor")]
[Description("进入虚弱，获取虚弱类型")]
public class EnterWeak : CharacterAction
{
    public BBParameter<int> weakType = new BBParameter<int>();

    protected override void OnExecute()
    {
        weakType.value = (int)_context.actor.actorWeak.weakType;
        EndAction(true);
    }

}
