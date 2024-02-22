using DG.Tweening;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using XLua;

[LuaCallCSharp]
[CSharpCallLua]
public class GachaEffectData : MonoBehaviour
{
    public Transform CenObj;//围绕的物体
    //速率衰减值
    [Header("速率衰减值")]
    [Range(0.1f,0.95f)]
    public float decelerationRate = 0.2f;
    public float RotateSpeed = 2;
    [HideInInspector]
    public Transform[] rotateZ;
    [HideInInspector]
    public float[] RingSpeed;
    [HideInInspector]
    public List<GachaRotateStruct> RotateParam= new List<GachaRotateStruct>();

    public Animation animation;
    [System.Serializable]
    public struct GachaRotateStruct
    {
        public Transform Target;
        public float XSpeed;
        public float YSpeed;
        public float ZSpeed;
    }
}