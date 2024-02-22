using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    [CreateAssetMenu(fileName = "HurtBackCurve", menuName = "HurtBack", order = 1)]
    public class HurtBackCurve : ScriptableObject
    {
        [SerializeField] public AnimationCurve Curve = new AnimationCurve();
    }
}