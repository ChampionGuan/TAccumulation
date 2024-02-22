using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/设置子节点显隐")]
    [Serializable]
    public class SetChildActiveAsset : BSActionAsset<ActionSetChildActive>
    {
        [LabelText("子节点路径")] public string childPath;

        [LabelText("显隐设置")] public bool childActive;
    }

    public class ActionSetChildActive : BSAction<SetChildActiveAsset>
    {
        private static int hashID;

        static ActionSetChildActive()
        {
            hashID = typeof(ActionSetChildActive).GetHashCode();
        }

        protected override void _OnEnter()
        {
            context.actor?.transform.AddModelChildVisible(hashID, clip.childPath, clip.childActive);
        }
    }
}