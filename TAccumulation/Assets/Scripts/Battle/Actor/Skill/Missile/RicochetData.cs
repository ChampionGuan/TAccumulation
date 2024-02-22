using UnityEngine;

namespace X3Battle
{
    // 子弹弹射时，父子弹创建子子弹需要的参数
    public struct RicochetData
    {
        public int createMissileID;  // 创建出的子弹ID
        public Actor hitActor;  // 命中的单位
        public Vector3 hitPosition;  // 上个命中点
        public Actor targetActor;  // 目标Actor
    }
}