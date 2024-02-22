using Framework;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;
using UnityEngine.Timeline;

namespace X3Battle
{
    // 残影逻辑对象
    public class Shadow
    {
        private GameObject _shadowObj;  // 残影对象
        private Transform _shadowTrans;  // 残影对象Transform
        private float _remainTime;  // 剩余时间
        private float _duration;  // 持续时间
        private Gradient _color;  // 颜色
        private MaterialPropertyBlock _block;
        private SkinnedMeshRenderer[] _meshs;
        private TransformSyncTask _syncTask;
        private GhostShaderData _ghostShaderData;
        
        public Shadow(Transform model, string _shadowObjPath, bool isPreload)
        {
            var obj = BattleResMgr.Instance.Load<GameObject>(_shadowObjPath, BattleResType.Shadow);
            if (obj == null)
            {
                LogProxy.LogErrorFormat("联系【卡宝宝】，配置了不存在的残影prefab，路径：{0}", _shadowObjPath);
                return;
            }
            _shadowTrans = obj.transform;
            _meshs = obj.transform.GetComponentsInChildren<SkinnedMeshRenderer>();
            obj.SetVisible(false);
            _shadowObj = obj;
            _syncTask = new TransformSyncTask(model, _shadowTrans);
            if (isPreload)
            {
                _syncTask.Execute();  // preload模式先走一下
            }
        }
        
        // 显示
        public void Show(float remainTime, Gradient color, GhostShaderData shaderData)
        {
            using (ProfilerDefine.ShadowShowPMarker.Auto())
            {
                _ghostShaderData = shaderData;
                _color = color;
                _remainTime = remainTime;
                if (_remainTime <= 0)
                {
                    LogProxy.LogWarning("残影持续时间<=0, 直接跳出！");
                    return;
                }

                _duration = remainTime;
                _shadowObj.SetVisible(true);

                var modelGraph = PlayableAnimationManager.Instance()?.FindPlayGraph(_shadowObj);
                if (null != modelGraph) modelGraph.Active = true;

                using (ProfilerDefine.ShadowSyncTransformPMarker.Auto())
                {
                    if (_syncTask != null)
                    {
                        _syncTask.Execute();
                    }
                }

                // TODO 后面考虑优化（放到init）
                SetShaderDataToMeshes(_meshs);
                _UpdateColor();
            }
        }
        
        // 隐藏
        public void Hide()
        {
            using (ProfilerDefine.ShadowHidePMarker.Auto())
            {
                _remainTime = 0;
                _duration = 0;
                _shadowObj.SetVisible(false);
                var modelGraph = PlayableAnimationManager.Instance()?.FindPlayGraph(_shadowObj);
                if (null != modelGraph) modelGraph.Active = false;
            }
        }
        
        // 是否已结束
        public bool IsEnd()
        {
            return _remainTime <= 0 || _shadowTrans == null;
        }

        // 销毁时卸载
        public void Destroy()
        {
            if (_shadowTrans != null)
            {
                BattleResMgr.Instance.Unload(_shadowTrans.gameObject);
                _shadowTrans = null;
            }

            if (_syncTask != null)
            {
                _syncTask.Destroy();
                _syncTask = null;
            }
        }

        // Update计算CD
        public void Update(float deltaTime)
        {
            _remainTime -= deltaTime;
            _UpdateColor();
        }

        // 更新颜色
        private void _UpdateColor()
        {
            using (ProfilerDefine.ShadowUpdateColorPMarker.Auto())
            {
                var percent = _remainTime / _duration;
                _SetMatColorByPercent(percent);
            }
        }
        
        // 同步Shader属性参数
        public void SetShaderDataToMeshes(SkinnedMeshRenderer[] meshes)
        {
            if (_ghostShaderData != null)
            {
                if (_block == null)
                {
                    _block = new MaterialPropertyBlock();
                }
                _ghostShaderData.SetToMeshes(_block, meshes);
            }   
        }
        
        // 通过比例设置颜色
        private void _SetMatColorByPercent(float percent)
        {
            if (_meshs != null && _color != null)
            {
                var newColor = _color.Evaluate(percent);

                if (_block == null)
                    _block = new MaterialPropertyBlock();

                foreach (var VARIABLE in _meshs)
                {
                    VARIABLE.GetPropertyBlock(_block);
                    _block.SetColor("_Color", newColor);
                    VARIABLE.SetPropertyBlock(_block);
                }
            }
        }
    }
}



































