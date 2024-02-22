using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Game
{
    public enum DollColliderType
    {
        Head = 0,

        Body,

        LeftHand,

        RightHand,

        LeftLeg,

        RightLeg,

        /// <summary>
        /// 所有目标部位
        /// </summary>
        All = 998,

        /// <summary>
        /// 当前选择的目标部位
        /// </summary>
        CurTarget = 999
    }

    /// <summary>
    /// 指定娃娃碰撞体部位类型的脚本
    /// </summary>
    public class DollCollider : MonoBehaviour
    {
        public Collider head;
        public Collider body;
        public Collider leftHand;
        public Collider rightHand;
        public Collider leftLeg;
        public Collider rightLeg;
        private List<Collider> m_ColliderList;

        private void Awake()
        {
            m_ColliderList = new List<Collider>();
            m_ColliderList.Add(head);
            m_ColliderList.Add(body);
            m_ColliderList.Add(leftHand);
            m_ColliderList.Add(rightHand);
            m_ColliderList.Add(leftLeg);
            m_ColliderList.Add(rightLeg);
        }

        /// <summary>
        /// 离目标碰撞体的最近距离
        /// </summary>
        /// <param name="globalPosition"></param>
        /// <returns></returns>
        public float NearestDistanceToTargetCollider(Vector3 globalPosition)
        {
            float nearestDistance = 999;
            foreach (Collider collider in m_ColliderList)
            {
                Vector3 closestPoint = collider.ClosestPoint(new Vector3(globalPosition.x, collider.transform.position.y, globalPosition.z));

                //横向距离 = 娃娃机坐标系下X轴差值绝对值
                float distance = Math.Abs(this.transform.parent.InverseTransformPoint(globalPosition).x -
                    this.transform.parent.InverseTransformPoint(closestPoint).x);

                if (distance <= nearestDistance)
                {
                    nearestDistance = distance;
                }
            }
            return nearestDistance;
        }

        /// <summary>
        /// 获取娃娃头部碰撞体边缘位置，XZ平面一共四个方向
        /// </summary>
        /// <param name="x"></param>
        /// <param name="z"></param>
        /// <returns></returns>
        public Vector3 GetBorderPosition(int x, int z)
        {
            Collider headCollider = GetCollider(DollColliderType.Head);
            Vector3 headColliderLocalPosition = transform.parent.InverseTransformPoint(headCollider.transform.position);
            if (x > 0)
            {
                headColliderLocalPosition.x = 10;
            }
            else if (x < 0)
            {
                headColliderLocalPosition.x = -10;
            }
            else if (z > 0)
            {
                headColliderLocalPosition.z = 10;
            }
            else
            {
                headColliderLocalPosition.z = -10;
            }
            Vector3 globalPosition = transform.parent.TransformPoint(headColliderLocalPosition);
            return headCollider.ClosestPoint(globalPosition);
        }


        /// <summary>
        /// 某个坐标在Y轴的投影是否落在娃娃碰撞体内
        /// </summary>
        /// <param name="dollColliderType"></param>
        /// <param name="globalPosition"></param>
        /// <returns></returns>
        public bool InColliderRange(DollColliderType dollColliderType, Vector3 globalPosition)
        {
            Collider collider = GetCollider(dollColliderType);
            Ray ray = new Ray(globalPosition, Vector3.down);
            RaycastHit hitInfo = new RaycastHit();
            return collider.Raycast(ray, out hitInfo, 5);
        }

        /// <summary>
        /// 未指定碰撞体类型就遍历所有碰撞体 有一个为True就返回
        /// </summary>
        /// <param name="globalPosition"></param>
        /// <returns></returns>
        public bool InColliderRange(Vector3 globalPosition)
        {
            foreach (Collider collider in m_ColliderList)
            {
                Ray ray = new Ray(globalPosition, Vector3.down);
                RaycastHit hitInfo = new RaycastHit();
                bool result = collider.Raycast(ray, out hitInfo, 5);
                if (result)
                {
                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// 获取对应类型的Collider
        /// </summary>
        /// <param name="dollColliderType"></param>
        /// <returns></returns>
        public Collider GetCollider(DollColliderType dollColliderType)
        {
            Collider collider = null;
            switch (dollColliderType)
            {
                case DollColliderType.Head:
                    collider = head;
                    break;
                case DollColliderType.Body:
                    collider = body;
                    break;
                case DollColliderType.LeftHand:
                    collider = leftHand;
                    break;
                case DollColliderType.RightHand:
                    collider = rightHand;
                    break;
                case DollColliderType.LeftLeg:
                    collider = leftLeg;
                    break;
                case DollColliderType.RightLeg:
                    collider = rightLeg;
                    break;
            }
            return collider;
        }
    }
}