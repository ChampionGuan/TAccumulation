using PaperRopeSpace;
using UnityEngine;

namespace X3Game
{
    /// <summary>
    /// 三爪机器爪子配置，摇杆型, 有绳子，可选机械
    /// </summary>
    public class ThreeClawConfig : ClawConfig
    {
        /// <summary>
        /// 绑定的摇杆
        /// </summary>
        public GameObject joystick;
        
        /// <summary>
        /// 绳子
        /// </summary>
        public PaperRope rope;

        /// <summary>
        /// 横向控制轴
        /// </summary>
        public Transform controllerHorizontal;

        /// <summary>
        /// 纵向控制轴
        /// </summary>
        public Transform controllerVertical;
    }
}