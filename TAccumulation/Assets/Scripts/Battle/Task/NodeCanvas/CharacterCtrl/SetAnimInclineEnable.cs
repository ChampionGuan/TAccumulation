using NodeCanvas.Framework;
using ParadoxNotion.Design;
using System.Collections.Generic;
using System.Runtime.Remoting.Contexts;
using UnityEngine;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("设置需要开启侧倾的动画状态")]
    public class SetAnimInclineEnable : CharacterAction
    {
        public List<string> animStateNames;

        protected override void OnExecute()
        {
            _context.locomotionCtrl.SetInclineAnims(animStateNames);
            
        }
    }
}
