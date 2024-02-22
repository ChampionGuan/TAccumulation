using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    /// <summary>
    /// 娃娃机爪子铰链阻力检测器，当阻力大于某个值时就停止绳子伸长，以免爪子继续向下把娃娃戳飞
    /// </summary>
    public class UFOCatcherClawForceDetecter : MonoBehaviour
    {
        /// <summary>
        /// 铰链阻力大于固定值则停止绳子
        /// </summary>
        public float stopForce;

        /// <summary>
        /// 物件上绑定的所有铰链组件
        /// </summary>
        private HingeJoint[] m_Joints;

        void Awake()
        {
            m_Joints = gameObject.GetComponents<HingeJoint>();
        }

        void Update()
        {
            foreach (HingeJoint joint in m_Joints)
            {
                if (joint.currentForce.magnitude > stopForce)
                {
                    EventMgr.Dispatch("GoingDownStop", true);
                }
            }
        }
    }
}