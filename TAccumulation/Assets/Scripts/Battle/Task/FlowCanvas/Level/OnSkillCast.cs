using System;
using NodeCanvas.Framework;
using ParadoxNotion;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("技能释放监听器\nOnSkillCast")]
    [Description("SkillID默认等于-1, 即为不生效改SkillID逻辑判断，只判断技能类型")]
    public class OnSkillCast : FlowListener
    {
        public BBParameter<SkillType> SkillType = new BBParameter<SkillType>(X3Battle.SkillType.Active);

        [Description("-1 即为不生效改SkillID逻辑判断，只判断技能类型")]
        public BBParameter<int> SkillID = new BBParameter<int>(-1);
        
        public int skillTag = -1;

        private Action<EventCastSkill> _actionOnCastSkill;

        public OnSkillCast()
        {
            _actionOnCastSkill = _OnCastSkill;
        }
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventCastSkill>(EventType.CastSkill, _actionOnCastSkill, "OnSkillCast._OnCastSkill");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventCastSkill>(EventType.CastSkill, _actionOnCastSkill);
        }

        private void _OnCastSkill(EventCastSkill eventCastSkill)
        {
            if (IsReachMaxCount())
            {
                return;
            }

            if (eventCastSkill == null || eventCastSkill.skill == null)
            {
                return;
            }
            
            if (skillTag != -1 && !eventCastSkill.skill.HasSkillTag(skillTag))
            {
                return;
            }
            
            if (eventCastSkill.skill.actor.type == ActorType.SkillAgent)
            {
                return;
            }

            var skillID = SkillID.GetValue();
            
            if (skillID > 0)
            {
                if (skillID != eventCastSkill.skill.config.ID)
                {
                    return;    
                }
            }
            else if (SkillType.GetValue() != eventCastSkill.skill.config.Type)
            {
                return;
            }
            
            _Trigger();
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
