using NodeCanvas.Framework;
using ParadoxNotion.Design;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("设置footIK")]
    public class EnableFootIK : CharacterAction
    {
        [RequiredField]
        [LabelText("是否开启footIK")]
        public bool enable = true;

        [LabelText("缓动时间")]
        public BBParameter<float> dampTime = 0.4f;

        protected override void OnExecute()
        {
            _context.actor.locomotionView.EnableFootIk(enable, dampTime.value);
            EndAction();
        }
    }
}
