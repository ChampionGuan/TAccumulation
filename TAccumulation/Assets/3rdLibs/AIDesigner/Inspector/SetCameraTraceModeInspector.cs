using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace AIDesigner
{
    //---@class AI.SetCameraTraceMode:AIAction
    // ---@field mode AIVar|Int|BattleCameraType
    // ---@field camName AIVar|string
    // ---@field isSmooth boolean
    // ---@field follow1st AIVar|Object
    // ---@field follow2nd AIVar|Object
    // ---@field lookAt1st AIVar|Object
    // ---@field lookAt2nd AIVar|Object
    // ---@field camPosition AIVar|Vector3
    // ---@field camEulerAngles AIVar|Vector3
    // ---@field camFov AIVar|Int

    [TaskName("SetCameraTraceMode")]
    public class SetCameraTraceModeInspector : TaskInspectorBase
    {
        private int m_mode;

        public override void OnInspector()
        {
            foreach (var var in CurrTask.Variables)
            {
                if (var.Key == "mode")
                {
                    m_mode = (int) var.Value;
                    break;
                }
            }

            base.OnInspector();
        }

        protected override void DrawSoloField(SharedVariable var, bool needWatch = true, string name = null)
        {
            if (var.Key == "mode")
            {
                base.DrawSoloField(var, needWatch, name);
                return;
            }

            // None
            if (m_mode == 0)
            {
                return;
            }

            if (var.Key == "camName" || var.Key == "isSmooth")
            {
                base.DrawSoloField(var, needWatch, name);
                return;
            }

            // FreeLook
            if (m_mode == 1 && (var.Key == "follow1st" || var.Key == "follow2nd"))
            {
                base.DrawSoloField(var, needWatch, name);
                return;
            }

            // TargetLook
            if (m_mode == 2 && (var.Key == "follow1st" || var.Key == "follow2nd" || var.Key == "lookAt1st" || var.Key == "lookAt2nd"))
            {
                base.DrawSoloField(var, needWatch, name);
                return;
            }

            // Static
            if (m_mode == 3 && (var.Key == "camPosition" || var.Key == "camEulerAngles" || var.Key == "camFov"))
            {
                base.DrawSoloField(var, needWatch, name);
                return;
            }
        }
    }
}