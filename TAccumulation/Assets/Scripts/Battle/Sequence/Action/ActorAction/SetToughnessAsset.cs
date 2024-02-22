using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/设置抗攻击等级")]
    [Serializable]
    public class SetToughnessAsset:BSActionAsset<ActionSetToughness>
    {
        [LabelText("修改模式")]
        public ToughnessSetType setType;
        [LabelText("数值")]
        public float value;
        [LabelText("是否永久性修改")]
        public bool eternal;
    }

    public class ActionSetToughness:BSAction<SetToughnessAsset>
    {
        private float _addValue;

        protected override void _OnEnter()
        {
            if (context.actor.hurt == null)
            {
                return;
            }
            if (clip.setType == ToughnessSetType.Add)
                _addValue = clip.value;
            else
                _addValue = clip.value - context.actor.hurt.toughness;
            context.actor.hurt.AddToughness(_addValue);
        }

        protected override void _OnExit()
        {
            if (context.actor.hurt == null)
            {
                return;
            }
            if(!clip.eternal)
                context.actor.hurt.AddToughness(-_addValue);
        }
    }
}
