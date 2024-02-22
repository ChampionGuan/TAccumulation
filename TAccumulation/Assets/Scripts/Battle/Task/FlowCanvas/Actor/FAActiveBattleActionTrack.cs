using System.Collections.Generic;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("激活(禁用)Track轨道\nActiveBattleActionTrack")]
    public class FAActiveBattleActionTrack : FlowAction
    {
        public BBParameter<SkillSlotType> skillSlotType = new BBParameter<SkillSlotType>(SkillSlotType.SkillID);
        public BBParameter<int> skillSlotIndex = new BBParameter<int>(0);
        public BBParameter<List<int>> tags = new BBParameter<List<int>>();
        public BBParameter<bool> active = new BBParameter<bool>();
        public BBParameter<HeroType> heroType = new BBParameter<HeroType>();
        protected override void _Invoke()
        {
            Actor target = null;
            if (heroType.value == HeroType.Boy)
            {
                target = _battle.actorMgr?.boy;
            }
            else
            {
                target = _battle.actorMgr?.girl;
            }
            
            if (target == null)
            {
                _LogError("请联系策划【楚门】,【激活(禁用)Track轨道】heroType, 目前为null");
                return;
            }
            if (target.skillOwner == null)
            {
                _LogError($"请联系策划【楚门】,【激活(禁用)Track轨道】_viActor的引脚没有正确配置, {target.name}没有SkillOwner组件.");
                return;
            }
            TrackEnableInfo info = new TrackEnableInfo();
            info.enable = active.value;
            info.tags = tags.value;
            info.skillSlotIndex = skillSlotIndex.value;
            info.skillSlotType = skillSlotType.value;
            target.skillOwner.trackController.AddEnableInfo(info);
            target.skillOwner.trackController.SetEnableInfo(info);
        }
        
#if UNITY_EDITOR

        protected override void OnNodeInspectorGUI()
        {
            if ( this.GetType().RTIsDefined<HasRefreshButtonAttribute>(true) ) {
                if ( GUILayout.Button("Refresh") ) { GatherPorts(); }
                EditorUtils.Separator();
            }
            
            var objectDrawer = PropertyDrawerFactory.GetObjectDrawer(this.GetType());
            var content = EditorUtils.GetTempContent(name.SplitCamelCase());
            objectDrawer.DrawGUI(content, this, new InspectedFieldInfo());
            
            EditorUtils.Separator();
            DrawValueInputsGUI();
        }
#endif
    }
}
