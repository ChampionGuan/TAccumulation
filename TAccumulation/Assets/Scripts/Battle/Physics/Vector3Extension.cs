using Unity.Mathematics;
using UnityEngine;

namespace X3Battle
{
    public static class Vector3Extension
    {
        public static Vector3 Sub(this float3 pos1, Vector3 pos2)
        {
            return new Vector3(pos1.x - pos1.x, pos1.y - pos2.y, pos1.z - pos2.z);
        }
    }
}