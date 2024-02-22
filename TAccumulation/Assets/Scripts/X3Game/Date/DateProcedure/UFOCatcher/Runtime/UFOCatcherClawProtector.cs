using UnityEngine;
using System.Collections.Generic;

namespace X3Game
{
    /// <summary>
    /// 绑定一个脚本保证爪子不散架，每帧更新自己的原始位置及信息
    /// </summary>
    public class UFOCatcherClawProtector : MonoBehaviour
    {
        /// <summary>
        /// 单个控制器所属的爪子
        /// </summary>
        public ThreeClawConfig claw;

        /// <summary>
        /// 单根爪子的初始位置
        /// </summary>
        private Vector3 m_OriginPos;

        /// <summary>
        /// 单根爪子的初始旋转
        /// </summary>
        private Vector3 m_OriginEulerAngles;

        void Awake()
        {
            m_OriginPos = transform.localPosition;
            m_OriginEulerAngles = transform.localEulerAngles;
        }

        void Update()
        {
            transform.localPosition = m_OriginPos;
            m_OriginEulerAngles.x = transform.localEulerAngles.x;
            transform.localEulerAngles = m_OriginEulerAngles;
        }
    }
}