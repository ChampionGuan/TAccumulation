using System.Collections;
using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [System.ComponentModel.Category("X3Battle/关卡/Action")]
    [Name("开启/关闭关卡相机\nActiveLevelCamera")]
    public class FASwitchLevelCamera : FlowAction
    {
        [Name("开关")] public BBParameter<bool> enable = new BBParameter<bool>(false);
        [ShowIf("enable", 1)] public BBParameter<int> ID;
        protected override void _Invoke()
        {
            if (enable.GetValue())
            {
                Battle.Instance.cameraTrace.EnableLevelCamera(ID.GetValue());
            }
            else
            {
                Battle.Instance.cameraTrace.DisableLevelCamera();
            }
        }
    }
}
