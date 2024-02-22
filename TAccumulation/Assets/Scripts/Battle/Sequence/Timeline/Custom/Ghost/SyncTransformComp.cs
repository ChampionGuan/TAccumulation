using System;
using X3;
using X3Battle;

namespace UnityEngine.Timeline
{
    public class SyncTransformComp: MonoBehaviour
    {
        private GameObject _src;
        private GameObject _ghost;
        
        private Transform _srcTrans;
        
        private TransformSyncTask _syncTask;
        private bool _isLateEntered;
        
        public void ResetData(GameObject src, GameObject ghost)
        {
            if (src != null && ghost != null)
            {
                if (_src == src && _ghost == ghost)
                {
                    // 如果前后相同直接跳出即可，不需要重刷_syncTask
                    return;
                }
                _src = src;
                _ghost = ghost;
                
                _srcTrans = src.transform.Find("Model");
                if (Application.isPlaying)
                {
                    // 运行时走JobSystem同步位置
                    _ClearSyncTask();
                    _syncTask = new TransformSyncTask(_srcTrans, ghost.transform);
                    _syncTask.Execute();  // preload模式先走一下，后面消耗小   
                    _isLateEntered = false;
                }
            }
        }

        public void TrySync()
        {
            if (Application.isPlaying)
            {
                _isLateEntered = false;
            }
            else
            {
                // 非运行时直接遍历骨骼节点同步位置
                if (_srcTrans != null && _ghost != null)
                {
                    X3TimelineUtility.SyncTrans(_srcTrans, _ghost.transform);
                }
            }
        }

        private void _ClearSyncTask()
        {
            if (_syncTask != null)
            {
                _syncTask.Destroy();
                _syncTask = null;
            }
        }

        private void LateUpdate()
        {
            if (_isLateEntered)
            {
                return;
            }
            _isLateEntered = true;
            
            _syncTask?.Execute();
        }

        private void OnDestroy()
        {
            _ClearSyncTask();
        }
    }
}