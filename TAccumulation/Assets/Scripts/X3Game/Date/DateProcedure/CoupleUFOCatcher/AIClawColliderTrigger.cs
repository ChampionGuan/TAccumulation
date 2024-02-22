/*
using PapeGames.X3;
using UnityEngine;

namespace PapeGames
{
    /// <summary>
    /// 双人娃娃机AI爪子碰到玩家爪子检测，用来告诉AI爪子已经卡住不能再移动了
    /// </summary>
    public class AIClawColliderTrigger : MonoBehaviour
    {
        /// <summary>
        /// 绑定的爪子控制器
        /// </summary>
        private ClawController m_ClawController;

        private void Start()
        {
            m_ClawController = transform.GetComponent<ClawController>();
        }

        private void OnTriggerEnter(Collider other)
        {
            var otherClawController = other.GetComponent<ClawController>();
            if (otherClawController && !m_ClawController.isGetStuck)
            {
                m_ClawController.isGetStuck = true;
            }
        }
    }
}
*/
