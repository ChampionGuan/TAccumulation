using System.Collections.Generic;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断ActorTag\nContainsShowTags")]
    public class FCContainsShowTags : FlowCondition
    {
        public BBParameter<List<int>> Tags = new BBParameter<List<int>>();

        private ValueInput<Actor> _viActor;

        protected override void _OnAddPorts()
        {
            _viActor = AddValueInput<Actor>(nameof(Actor));
        }

        protected override bool _IsMeetCondition()
        {
            var target = _viActor.GetValue();
            if (target == null)
            {
                return false;
            }

            var tags = Tags.GetValue();
            bool result = target.ContainsAllShowTags(tags);
            return result;
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
