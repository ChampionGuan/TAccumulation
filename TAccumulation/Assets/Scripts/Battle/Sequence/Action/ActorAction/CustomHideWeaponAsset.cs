using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/设置隐藏武器样式")]
    [Serializable]
    public class CustomHideWeaponAsset : BSActionAsset<ActionCustomHideWeapon>
    {
        [LabelText("消失特效")]
        public int[] FadeOutFxs = new int[1] { 0 };

        [LabelText("消失音效Event")]
        public string FadeOutSound;

        [LabelText("消失材质动画")]
        public string FadeOutMatAnim = "Common/Weapon_dissolve_01";
    }

    public class ActionCustomHideWeapon : BSAction<CustomHideWeaponAsset>
    {
        protected override void _OnEnter()
        {
            var weapon = context.actor.weapon;
            if (weapon != null)
            {
                weapon.SetOnceOutEffect(clip.FadeOutFxs, clip.FadeOutSound, clip.FadeOutMatAnim);
            }
        }
        protected override void _OnExit()
        {
            var weapon = context.actor.weapon;
            if (weapon != null)
            {
                weapon.ClearOnceOutEffectLate();
            }
        }
    }
}