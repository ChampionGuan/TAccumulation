using System.Collections.Generic;
using FlowCanvas;
using FlowCanvas.Nodes;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    
    [Category("X3Battle/通用/Function")]
    [Name("运算函数RemapToFloatUnClamp\nRemapToFloatUnClamp")]
    public class RemapToFloatUnClamp : PureFunctionNode<float, float, float, float, float, float>
    {
        public override float Invoke(float current, float iMin, float iMax = 1f, float oMin = 0, float oMax = 100) {
            if (iMin == iMax)
            {
                return oMin;
            }

            float temp = (current - iMin) / (iMax - iMin);
            
            return Mathf.LerpUnclamped(oMin, oMax, temp);
        }
    }
}
