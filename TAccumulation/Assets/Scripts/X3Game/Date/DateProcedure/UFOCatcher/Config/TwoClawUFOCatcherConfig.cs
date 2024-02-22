using UnityEngine;

namespace X3Game
{
    /// <summary>
    /// 二爪娃娃机控制器
    /// </summary>
    public class TwoClawUFOCatcherConfig : UFOCatcherConfig
    {
        /// <summary>
        /// 二爪娃娃机的初始化位置
        /// </summary>
        public Vector3 dollInitPosition = new Vector3(0, 1.16f, 0);

        /// <summary>
        /// 二爪移动娃娃机的滚动条
        /// </summary>
        public GameObject slider;

        /// <summary>
        /// 二爪机杆子移动速度配置
        /// </summary>
        public float sliderSpeed = 0.1f;

        /// <summary>
        /// 二爪机杆子移动范围配置
        /// </summary>
        public Vector2 sliderMoveRange = new Vector2(-0.2f, 0.2f);
    }
}