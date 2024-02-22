using System.Collections.Generic;
using UnityEngine.Playables;
using X3Battle;

namespace UnityEngine.Timeline
{
    // 主体可见（只设置根，子节点不需要做特殊处理）
    // 主体不可见，根不可见 (只设置根，子节点不需要做特殊处理)
    // 主体不可见，根可见（需要特殊处理子节点）
    public class VisibilityPlayable : InterruptBehaviour
    {
        private GameObject _bindObj;

        private bool _visible;
        private bool _rootBoneVisible;
        
        private int _hashID;
        public VisibilityPlayable()
        {
            _hashID = GetHashCode();
        }
        
        public void SetParam(bool visible, bool onlyMesh)
        {
            _visible = visible;
            _rootBoneVisible = onlyMesh;
        }

        // 开始运行
        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            if (!(playerData is GameObject go)) return;
            _bindObj = go;
            if (_bindObj == null) return;
            BattleUtil.AddCharacterVisibleClip(_hashID, go, _visible, _rootBoneVisible);
        }

        protected override void OnStop()
        {
            if (!_bindObj)
            {
                return;
            }

            BattleUtil.RemoveCharacterVisibleClip(_hashID, _bindObj);
        }
    }
}