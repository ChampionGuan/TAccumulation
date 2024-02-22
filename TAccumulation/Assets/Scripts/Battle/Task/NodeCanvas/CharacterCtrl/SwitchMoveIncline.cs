using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("开关移动侧倾（留作记录，后面删除）")]
    public class SwitchMoveIncline : CharacterAction
    {
        public BBParameter<bool> isOpen = new BBParameter<bool>();
        public BBParameter<bool> isReset = new BBParameter<bool>();

        protected override string info
        {
            get { return "侧倾:" + (isOpen.value ? "开启权重更新" : "逐渐关闭") +  
                    (isReset.value ? ",并立即设置侧倾与权重为0" : ""); }
        }

        protected override void OnExecute()
        {
            base.OnExecute();
            //_context.locomotionCtrl.SwitchMoveIncline(isOpen.value);
            //if(isReset.value)
            //{
            //    _context.locomotionCtrl.animator.SetFloat(AnimParams.MoveIncline, 0);
            //    _context.locomotionCtrl.animator.SetLayerWeight((int)RoleAnimLayer.BaseAdd, 0);
            //}
            EndAction();
        }
    }
}
