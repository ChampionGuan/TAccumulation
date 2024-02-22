using System;
using UnityEngine;

namespace X3Game
{
    [Serializable]
    public class PathSDF : ScriptableObject
    {
        [SerializeField] public byte[] sdf = new byte[128 * 128];   // 曲线的距离场
        [SerializeField] public byte[] samples = new byte[16 * 16]; // 曲线的上的采样点
        [SerializeField] public byte samplesCount;
    }
}