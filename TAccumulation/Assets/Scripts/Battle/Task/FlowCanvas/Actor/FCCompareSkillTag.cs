using FlowCanvas;
using ParadoxNotion;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor/Condition")]
    [Name("判断技能Tag\nCompareSkillTag")]
    public class FCCompareSkillTag : FlowCondition
    {
        private ValueInput<ISkill> _viSkill;
        public int skillTag;

        protected override void _OnAddPorts()
        {
            _viSkill = AddValueInput<ISkill>(nameof(ISkill));
        }

        protected override bool _IsMeetCondition()
        {
            var skill = _viSkill.GetValue();
            if (skill == null)
                return false;
            if (!skill.HasSkillTag(skillTag))
            {
                return false;
            }

            return true;
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
