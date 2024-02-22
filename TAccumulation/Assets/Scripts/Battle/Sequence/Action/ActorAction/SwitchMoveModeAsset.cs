using System;
using EasyCharacterMovement;
using PapeGames.X3;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/设置移动类型")]
    [Serializable]
    public class SwitchMoveModeAsset : BSActionAsset<ActionSwitchMoveMode>
    {
        [LabelText("移动类型")]
        public MovementMode targetMode;
        [LabelText("是否结束时恢复")]
        public bool recover;
    }

    public class ActionSwitchMoveMode : BSAction<SwitchMoveModeAsset>
    {
        protected override void _OnEnter()
        {
            LogProxy.LogFormat("ActionSwitchMoveMode.Enter {0}设置移动类型{1}", context.actor.name, clip.targetMode);
            context.actor.transform.characterMove.SwitchMode(clip.targetMode);
        }

        protected override void _OnExit()
        {
            LogProxy.LogFormat("ActionSwitchMoveMode.Exit");
            if (clip.recover)
                context.actor.transform.characterMove.SwitchMode(MovementMode.walking);
        }
    }
}


