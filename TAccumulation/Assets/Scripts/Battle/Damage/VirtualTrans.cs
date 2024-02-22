using UnityEngine;

namespace X3Battle
{
    // 虚拟trans，结构体
    public struct VirtualTrans
    {
        public struct StaticInfo
        {
            public Vector3 position { get; private set; }
            public Quaternion rotation { get; private set; }

            public Vector3 right { get; private set; }
            public Vector3 up { get; private set; }
            public Vector3 forward { get; private set; }

            public StaticInfo(Vector3 position, Quaternion rotation)
            {
                this.position = position;
                this.rotation = rotation;
                this.right = rotation * Vector3.right;
                this.up = rotation * Vector3.up;
                this.forward = rotation * Vector3.forward;
            }
        }
        public StaticInfo? info { get; private set; }
        public Transform trans { get; private set; }

        public VirtualTrans(Vector3 position, Quaternion rotation)
        {
            info = new StaticInfo(position, rotation);
            trans = null;
        }

        public VirtualTrans(Transform transform)
        {
            info = null;
            trans = transform;
        }

        // 获取世界空间位置
        public Vector3 GetWorldPos(Vector3 localOffsetPos)
        {
            if (localOffsetPos == Vector3.zero)
            {
                if (trans == null)
                {
                    return info.Value.position;
                }
                else
                {
                    return trans.position;
                }
            }
            else
            {
                var position = Vector3.zero;
                var right = Vector3.right;
                var up = Vector3.up;
                var forward = Vector3.forward;
            
                if (trans == null)
                {
                    position = info.Value.position;
                    right = info.Value.right;
                    up = info.Value.up;
                    forward = info.Value.forward;
                }
                else
                {
                    position = trans.position;
                    right = trans.right;
                    up = trans.up;
                    forward = trans.forward;
                }
            
                return position + right * localOffsetPos.x + up * localOffsetPos.y + forward * localOffsetPos.z; 
            }
        }

        // 获取世界空间欧拉角
        public Vector3 GetWorldEuler(Vector3 localOffsetEuler)
        {
            if (localOffsetEuler == Vector3.zero)
            {
                if (trans == null)
                {
                    return info.Value.rotation.eulerAngles;
                }
                else
                {
                    return trans.eulerAngles;
                }
            }
            else
            {
                var rotation = Quaternion.identity;

                if (trans == null)
                {
                    rotation = info.Value.rotation;
                }
                else
                {
                    rotation = trans.rotation;
                }
            
                var finalRotation = rotation * Quaternion.Euler(localOffsetEuler);
                return finalRotation.eulerAngles;
            }
        }
    }
}