using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("获取Actor的受击类型")]
    public class EnteHurt : CharacterAction
    {
        public BBParameter<int> hurtActionType = new BBParameter<int>();
        public BBParameter<float> layDownTime = new BBParameter<float>();

        protected override void OnExecute()
        {
            hurtActionType.value = (int)_context.actor.hurt.hurtStateType;
            if(layDownTime!= null)
                layDownTime.value = _context.actor.hurt.layDownTime;
            EndAction(true);
        }
    }
}
