using System;
using UnityEngine;

namespace X3Battle
{
    // 残影数据（美术编辑策划不编辑，不用加MessaPack需列化）
    [Serializable]
    public class ShadowData
    {
        [LabelText("残影上限(<0无限制)")]
        public int maxNum = -1;
        
        [LabelText("生成间隔")]
        public float spawnInterval = 0.1f;
        
        [LabelText("持续时间 (>0有效)")] 
        public float duration = 0.5f;
        
        [GradientUsage(true)]
        public Gradient colorCurve;
    }
}