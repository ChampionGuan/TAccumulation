using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle")]
    [Description("获取是否在空中")]
    public class GetIsInAir : CharacterAction
    {
        public BBParameter<bool> result = new BBParameter<bool>();

        protected override void OnExecute()
        {
            result.value = !_context.actor.transform.isGrounded;
            EndAction(true);
        }
    }
}
