using System.Collections.Generic;
using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;
using UnityEngine;
using UnityEngine.Jobs;

namespace X3Battle
{
    // 获取位置到数组中
    [BurstCompile]
    struct TransformGet : IJobParallelForTransform
    {
        public NativeArray<Vector3> positions;
        public NativeArray<Quaternion> rotations;
        public NativeArray<Vector3> scales;
    
        public void Execute(int index, TransformAccess transform)
        {
            positions[index] = transform.localPosition;
            rotations[index] = transform.localRotation;
            scales[index] = transform.localScale;
        }
    }

    // 从数组中拿位置设置
    [BurstCompile]
    struct TransformSet : IJobParallelForTransform
    {
        public NativeArray<Vector3> positions;
        public NativeArray<Quaternion> rotations;
        public NativeArray<Vector3> scales;
    
        public void Execute(int index, TransformAccess transform)
        {
            transform.localPosition = positions[index];
            transform.localRotation = rotations[index];
            transform.localScale = scales[index];
        }
    }

    // 同步src的骨骼信息到desc
    public class TransformSyncTask
    {
        // 静态类数据区
        private static List<Transform> _srcTrans = new List<Transform>();
        private static List<Transform> _destTrans = new List<Transform>();

        // 动态数据区
        private Transform _srcRoot;
        private Transform _destRoot;
        
        private TransformAccessArray _srcTranAccess;
        private TransformAccessArray _destTranAccess;
        private NativeArray<Vector3> _positions;
        private NativeArray<Quaternion> _rotations;
        private NativeArray<Vector3> _scales;
        
        private TransformGet _transGet;
        private TransformSet _transSet;
        private JobHandle _lastSetHandle;

        public TransformSyncTask(Transform src, Transform dest)
        {
            _srcRoot = src;
            _destRoot = dest;
            _RecordTransByRecursion(src, dest, false);

            var count = _srcTrans.Count;  // src和dest数量应该是相同的
            _srcTranAccess = new TransformAccessArray(count);
            _destTranAccess = new TransformAccessArray(count);
            for (int i = 0; i < count; i++)
            {
                _srcTranAccess.Add(_srcTrans[i]);
                _destTranAccess.Add(_destTrans[i]);
            }
            
            _positions = new NativeArray<Vector3>(_srcTrans.Count, Allocator.Persistent);
            _rotations = new NativeArray<Quaternion>(_srcTrans.Count, Allocator.Persistent);
            _scales = new NativeArray<Vector3>(_srcTrans.Count, Allocator.Persistent);

            _transGet = new TransformGet
            {
                positions = _positions,
                rotations = _rotations,
                scales = _scales,
            };

            _transSet = new TransformSet
            {
                positions = _positions,
                rotations = _rotations,
                scales = _scales,
            };

            _srcTrans.Clear();
            _destTrans.Clear();
        }

        
        public void Execute()
        {
            // 同步根节点
            _destRoot.position = _srcRoot.position;
            _destRoot.rotation = _srcRoot.rotation;
            _destRoot.localScale = _srcRoot.localScale;
            
            // 同步子节点
            var handle = _transGet.Schedule(_srcTranAccess, _lastSetHandle);
            _lastSetHandle = _transSet.Schedule(_destTranAccess, handle);
        }
        
        // 记录一下骨骼映射
        private void _RecordTransByRecursion(Transform src, Transform dest, bool needRecord = true)
        {
            if (needRecord)
            {
                _srcTrans.Add(src);
                _destTrans.Add(dest);  
            }

            var childCount = dest.childCount;
            for (int i = 0; i < childCount; i++)
            {
                var destChild = dest.GetChild(i);
                var srcChild = src.Find(destChild.name);
                if (srcChild != null)
                {
                    _RecordTransByRecursion(srcChild, destChild);
                }
            }
        }
        
        public void Destroy()
        {
            _lastSetHandle.Complete();
            _lastSetHandle = default;
            
            _srcTranAccess.Dispose();
            _destTranAccess.Dispose();
            _positions.Dispose();
            _rotations.Dispose();
            _scales.Dispose();
        }
    }
}