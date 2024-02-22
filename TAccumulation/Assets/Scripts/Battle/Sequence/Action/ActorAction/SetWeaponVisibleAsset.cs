using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/武器显隐")]
    [Serializable]
    public class SetWeaponVisibleAsset : BSActionAsset<ActionSetWeaponVisible>
    {
        [LabelText("是否可见")]
        public bool visible = true;
    }

    public class ActionSetWeaponVisible : BSAction<SetWeaponVisibleAsset>
    {
        protected override void _OnEnter()
        {
            //Debug.LogError($"{Time.frameCount} + {context.actor.name} + {battleSequencer.name} + {clip.GetHashCode()} Enter");
            context.actor.weapon.RequireCustomVisible(clip.visible, false, GetHashCode());
        }
        protected override void _OnExit()
        {
            //Debug.LogError($"{Time.frameCount} + {context.actor.name} + {battleSequencer.name} + {clip.GetHashCode()} Exit");
            context.actor.weapon.ReleaseCustomVisible(GetHashCode());
        }
    }
}