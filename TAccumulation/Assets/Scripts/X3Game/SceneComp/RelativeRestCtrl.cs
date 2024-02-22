using System;
using UnityEngine;
using System.Collections.Generic;
using System.Text;
using PapeGames.X3;

namespace X3Game
{
    [MonoSingletonAttr(true, "RelativeRestCtrl")]
    [XLua.LuaCallCSharp]
    public class RelativeRestCtrl  : MonoSingleton<RelativeRestCtrl>
    {
        [Flags]
        public enum LockType
        {
            Position = 1,
            Rotation = 2
        }

        public class LockPair
        {
            public bool       isLock;
            public LockType   lockType;
            public Transform  target;
            public Transform  alignTo;
            public Vector3    relativePosition;
            public Vector3    relativeRotation;
            public Vector3    targetOriginalPos;
            public Vector3    alignToOriginalPos;
        }
        
        private int id = 0;
        private Dictionary<int, LockPair> m_Dic = new Dictionary<int, LockPair>();

        /// <summary>
        /// 添加一对相对静止的物体
        /// </summary>
        /// <param name="target">相对静止的物体</param>
        /// <param name="alignTo">参考物体</param>
        /// <param name="type">相对静止的类型</param>
        /// <param name="isLock">是否锁定</param>
        /// <returns>锁定对id</returns>
        public static int AddRelativeRestPair(Transform target, Transform alignTo, LockType type = LockType.Position, bool isLock = true)
        {
            return Instance.AddRelativeRestPairInternal(target, alignTo, type, isLock);
        }

        /// <summary>
        /// 移除一对相对静止的物体
        /// </summary>
        /// <param name="id">锁定对id</param>
        /// <param name="backToStart">是否将锁定对 Transform 恢复的初始状态</param>
        public static void RemoveRelativeRestPair(int id, bool backToStart = true)
        {
            Instance.RemoveRelativeRestPairInternal(id, backToStart);
        }

        /// <summary>
        /// 锁定
        /// </summary>
        public static void LockUp(int id, bool isLock)
        {
            Instance.LockUpInternal(id, isLock);
        }

        /// <summary>
        /// 修改锁定类型
        /// </summary>
        public static void ModifyLockType(int id, LockType type)
        {
            Instance.ModifyLockTypeInternal(id, type);
        }

        /// <summary>
        /// 修改相对坐标
        /// </summary>
        public static void UpdateRelativePosition(int id, Vector3 relativePosition)
        {
            Instance.UpdateRelativePositionInternal(id, relativePosition);
        }

        /// <summary>
        /// 修改对齐物体起始坐标
        /// </summary>
        public static void UpdateAlignToObjOriginalPosition(int id, Vector3 position)
        {
            Instance.UpdateAlignToObjOriginalPositionInternal(id, position);
        }
        
        /// <summary>
        /// 修改目标物体起始坐标
        /// </summary>
        public static void UpdateTargetObjOriginalPosition(int id, Vector3 position)
        {
            Instance.UpdateTargetObjOriginalPositionInternal(id, position);
        }

        #region Internal Functions

        private int AddRelativeRestPairInternal(Transform target, Transform alignTo, LockType type, bool isLock)
        {
            if (target == null || alignTo == null)
            {
                return -1;
            }
            id++;
            var pair = new LockPair();
            pair.target = target;
            pair.alignTo = alignTo;
            var targetPos = target.position;
            var alignToPos = alignTo.position;
            pair.relativePosition = targetPos - alignToPos;
            pair.targetOriginalPos = targetPos;
            pair.alignToOriginalPos = alignToPos;
            // pair.relativeRotation = target.rotation - alignTo.rotation;
            pair.lockType = type;
            pair.isLock = isLock;
            m_Dic.Add(id, pair);
            return id;
        }

        private void RemoveRelativeRestPairInternal(int id, bool backToStart)
        {
            if (!m_Dic.TryGetValue(id, out var pair))
            {
                Debug.LogError("The Index value is invalidate ");
                return;
            }

            if (backToStart && pair.target != null && pair.alignTo != null)
            {
                pair.target.position = pair.targetOriginalPos; 
                pair.alignTo.position = pair.alignToOriginalPos;
            }
            m_Dic.Remove(id);
        }

        private void LockUpInternal(int id, bool isLock)
        {
            if (!m_Dic.TryGetValue(id, out var pair))
            {
                Debug.LogError("The Index value is invalidate ");
                return;
            }
            pair.isLock = isLock;
            if (isLock && pair.target != null && pair.alignTo != null)
            {
                pair.relativePosition = pair.target.position - pair.alignTo.position;
            }
        }

        private void ModifyLockTypeInternal(int id, LockType type)
        {
            if (!m_Dic.TryGetValue(id, out var pair))
            {
                Debug.LogError("The Index value is invalidate ");
                return;
            }
            pair.lockType = type;
        }

        private void UpdateRelativePositionInternal(int id, Vector3 relativePosition)
        {
            if (!m_Dic.TryGetValue(id, out var pair))
            {
                Debug.LogError("The Index value is invalidate ");
                return;
            }
            pair.relativePosition = relativePosition;
            if ((pair.lockType & LockType.Position) > 0 && pair.isLock && pair.target != null && pair.alignTo != null)
            {
                pair.target.position = pair.alignTo.position + pair.relativePosition;
            }
        }

        private void UpdateAlignToObjOriginalPositionInternal(int id, Vector3 position)
        {
            if (!m_Dic.TryGetValue(id, out var pair))
            {
                Debug.LogError("The Index value is invalidate ");
                return;
            }

            pair.alignToOriginalPos = position;
            pair.relativePosition = pair.targetOriginalPos - pair.alignToOriginalPos;
            if ((pair.lockType & LockType.Position) > 0 && pair.isLock && pair.target != null && pair.alignTo != null)
            {
                pair.target.position = position + pair.relativePosition;
            }
        }

        private void UpdateTargetObjOriginalPositionInternal(int id, Vector3 position)
        {
            if (!m_Dic.TryGetValue(id, out var pair))
            {
                Debug.LogError("The Index value is invalidate ");
                return;
            }

            pair.targetOriginalPos = position;
            pair.relativePosition = pair.targetOriginalPos - pair.alignToOriginalPos;
            if ((pair.lockType & LockType.Position) > 0 && pair.isLock && pair.target != null && pair.alignTo != null)
            {
                pair.target.position = pair.alignTo.position + position;
            }
        }

        #endregion
        
        void Update()
        {
            foreach (var i in m_Dic)
            {
                var pair = i.Value;
                if ((pair.lockType & LockType.Position) > 0 && pair.isLock && pair.target != null && pair.alignTo != null)
                {
                    pair.target.position = pair.alignTo.position + pair.relativePosition;
                }

                if ((pair.lockType & LockType.Rotation) > 0 && pair.isLock && pair.target != null && pair.alignTo != null)
                {
                    // TODO ...
                }
            }
        }
        
#if UNITY_EDITOR

        public string GetPairString()
        {
            StringBuilder buffer = new StringBuilder();
            foreach (var i in m_Dic)
            {
                var pair = i.Value;
                if (pair.target != null && pair.alignTo != null)
                {
                    buffer.Append(pair.target.ToString());
                    buffer.Append("-->");
                    buffer.Append(pair.alignTo.ToString());
                    buffer.Append("\n");
                }
            }
            return buffer.ToString();
        }
        
        public void UnLockAll()
        {
            foreach (var i in m_Dic)
            {
                var pair = i.Value;
                pair.isLock = false;
            }
        }
        
        public void LockAll()
        {
            foreach (var i in m_Dic)
            {
                var pair = i.Value;
                pair.isLock = true;
            }
        }

        public Dictionary<int, LockPair> getDict
        {
            get => m_Dic;
        }
#endif
    }
}