using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("Battle动作/设置场景显隐")]
    [Serializable]
    public class SetSceneActiveAsset : BSActionAsset<ActionSetSceneActive>
    {
        [LabelText("是否显示场景")] 
        public bool isActive = true;
    }

    public class ActionSetSceneActive : BSAction<SetSceneActiveAsset>
    {
        protected override void _OnEnter()
        {
            context.battle.misc.SetSceneActive(clip.isActive);
        }   
    }
}