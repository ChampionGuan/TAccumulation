using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

namespace X3Game
{
    /// <summary>
    /// 爪子移动范围类型
    /// </summary>
    public enum RangeType
    {
        /// <summary>
        /// 长方形
        /// </summary>
        Square,

        /// <summary>
        /// 圆形
        /// </summary>
        Circle
    }
    
    public class ClawConfig : MonoBehaviour
    {
        /// <summary>
        /// 上升和下降的部分
        /// </summary>
        public GameObject liftObj;
        
        /// <summary>
        /// 玩家操作时移动速度
        /// </summary>
        public float playerMoveSpeed;

        /// <summary>
        /// 抓取时候的移动速度
        /// </summary>
        public float catchMoveSpeed;

        /// <summary>
        /// 爪子收紧的力
        /// </summary>
        public Vector3 torquePower = new Vector3(0, 10, 0);

        /// <summary>
        /// 爪子松开的力
        /// </summary>
        public Vector3 loosenPower = new Vector3(0, 50, 0);

        /// <summary>
        /// 爪子上的力组件
        /// </summary>
        public List<ConstantForce> constantForces;
        
        /// <summary>
        /// 爪子上所有的joint组件
        /// </summary>
        public List<HingeJoint> jointList;

        //爪子触发
        //冰冻效果的时候爪子的碰撞改为触发
        [FormerlySerializedAs("_triggerList")] public List<Collider> triggerList = new List<Collider>();
        
        /// <summary>
        /// 
        /// </summary>
        public List<Collider> freezeTriggerList = new List<Collider>();

        /// <summary>
        /// 
        /// </summary>
        public List<Rigidbody> rigidbodyList = new List<Rigidbody>();
        
        /// <summary>
        /// 移动范围限制类型
        /// </summary>
        public RangeType rangeType = RangeType.Square;

        /// <summary>
        /// X轴移动范围限制
        /// </summary>
        public Vector2 rangeX = new Vector2(-0.246f, 0.3f);

        /// <summary>
        /// Y轴移动范围限制
        /// </summary>
        public Vector2 rangeY = new Vector2(1f, 1.59f);

        /// <summary>
        /// 移动范围限制
        /// </summary>
        public Vector2 rangeZ = new Vector2(-0.24f, 0.30f);

        /// <summary>
        /// 初始位置
        /// </summary>
        public Vector2 backPos = new Vector2(0.3f, 0.3f);

        /// <summary>
        /// 按钮位移
        /// </summary>
        public float btnPressedY = -0.007f;
        
        /// <summary>
        /// 抓取按钮
        /// </summary>
        public GameObject catchBtn;
        
        /// <summary>
        /// 注入FixedUpdate
        /// </summary>
        public System.Action<float> OnFixedUpdate;

        private void FixedUpdate()
        {
            OnFixedUpdate?.Invoke(Time.deltaTime);
        }

        private void OnDestroy()
        {
            OnFixedUpdate = null;
        }
    }
}