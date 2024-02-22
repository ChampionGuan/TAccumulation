using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace AIDesigner
{
    // ---@class AI.TreeReference:AIAction
    // ---@field treeName String

    [TaskName("GetActor")]
    public class GetActorInspector : TaskInspectorBase
    {
        private bool m_byConfigID = false;

        public override void OnInspector()
        {
            foreach (var var in CurrTask.Variables)
            {
                if (var.Key == "byConfigID")
                {
                    m_byConfigID = (bool) var.Value;
                    break;
                }
            }

            base.OnInspector();
        }

        protected override void DrawSoloField(SharedVariable var, bool needWatch = true, string name = null)
        {
            if (var.Key == "byConfigID" || var.Key == "storeResult")
            {
                base.DrawSoloField(var, needWatch, name);
                return;
            }

            if (m_byConfigID && var.Key == "actorConfigID")
            {
                base.DrawSoloField(var, needWatch, name);
                return;
            }

            if (!m_byConfigID && var.Key == "actorType")
            {
                base.DrawSoloField(var, needWatch, name);
                return;
            }
        }
    }
}