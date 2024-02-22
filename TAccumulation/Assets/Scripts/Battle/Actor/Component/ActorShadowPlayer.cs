using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class ActorShadowPlayer : ActorComponent
    {
        private const int _preloadCount = 5;  // 预加载数量
        private string _shadowObjPath;
        private List<Shadow> _showShadows;  // 处于激活状态的Shadow列表
        private Stack<Shadow> _hideShadows;  // 处于隐藏状态的Shadow列表

        private bool isRunning = false;
        private ShadowData _curData;
        public ShadowData curData => _curData;

        private GhostShaderData _ghostShaderData;
        public GhostShaderData ghostShaderData => _ghostShaderData;
        // todo 优化
        private ShadowDataAsset _curDataAsset;
        private float spawnRemainTime;

        public ActorShadowPlayer() : base(ActorComponentType.ShadowPlayer)
        {
            requiredPhysicalJobRunning = true;
            _showShadows = new List<Shadow>(_preloadCount);
            _hideShadows = new Stack<Shadow>(_preloadCount);
        }

        protected override void OnAwake()
        {
            // TODO 策划侧删了功能，程序暂时保留代码，过一段时间稳了彻底删除
            // _shadowObjPath = actor.roleCfg?.ShadowPrefabPath;
            
            // 预加载
            if (!string.IsNullOrEmpty(_shadowObjPath))
            {
                for (int i = 0; i < _preloadCount; i++)
                {
                    var shadow = _CreateShadow(true);
                    _hideShadows.Push(shadow);
                }
            }
            
            // 编辑器下添加控制器方便美术调试
            if (Application.isEditor)
            {
                var com = actor.GetDummy().gameObject.AddComponent<ShadowEditorController>();
                com.SetShadowPlayer(this);
            }
        }

        public override void OnRecycle()
        {
            _Stop();
        }

        protected override void OnDestroy()
        {
            for (int i = 0; i < _showShadows.Count; i++)
            {
                _showShadows[i].Destroy();
            }
            _showShadows.Clear();

            foreach (var shadow in _hideShadows)
            {
                shadow.Destroy();   
            }
            _hideShadows.Clear();

            _UnloadCurShadowAsset();
        }

        private void _UnloadCurShadowAsset()
        {
            if (_curDataAsset != null)
            {
                BattleResMgr.Instance.Unload(_curDataAsset);
                _curDataAsset = null;
            }
        }
        
        /// <summary>
        /// 对外接口：释放残影 (参数走美术配置，所以需要传资源路径)
        /// </summary>
        /// <param name="shadowCfgPath"></param>
        public void StartShadow(string shadowCfgPath)
        {
            if (string.IsNullOrEmpty(shadowCfgPath))
            {
                PapeGames.X3.LogProxy.LogErrorFormat("联系【卡宝宝】，{0}的残影Action资源路径没配！", actor.name);
                return;
            }

            _UnloadCurShadowAsset();
            _curDataAsset = BattleResMgr.Instance.Load<ShadowDataAsset>(shadowCfgPath, BattleResType.ShadowData);
            if (_curDataAsset == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("联系【卡宝宝】，残影参数资源 {0} 不存在！", shadowCfgPath);
                return;
            }

            StartShadow(_curDataAsset.shadowData, _curDataAsset.ghostShaderData);
        }

        public void StartShadow(ShadowData data, GhostShaderData shaderData)
        {
            _Stop();
            _curData = data;
            _ghostShaderData = shaderData;
            _Start();
        }

        /// <summary>
        /// 对外接口：结束残影
        /// </summary>
        public void StopShadow()
        {
            _Stop();
        }

        /// <summary>
        /// 对外接口：是否开启残影
        /// </summary>
        public bool IsShadowActive()
        {
            return isRunning;
        }

        private void _Start()
        {
            isRunning = true;
        }

        private void _Stop()
        {
            for (int i = 0; i < _showShadows.Count; i++)
            {
                var shadow = _showShadows[i];
                shadow.Hide();
                _hideShadows.Push(shadow);
            }
            _showShadows.Clear();
            
            isRunning = false;
            _curData = null;
            spawnRemainTime = 0;
        }

        protected override void OnPhysicalJobRunning()
        {
            if (!isRunning)
            {
                return;
            }

            var deltaTime = actor.deltaTime;

            // 处理Update和删除逻辑
            var count = _showShadows.Count;
            for (int i = count - 1; i >= 0; i--)
            {
                var shadow = _showShadows[i];
                shadow.Update(deltaTime);
                if (shadow.IsEnd())
                {
                    shadow.Hide();
                    _showShadows.RemoveAt(i);
                    _hideShadows.Push(shadow);
                }
            }

            // 处理添加逻辑
            if (spawnRemainTime > 0)
            {
                spawnRemainTime -= deltaTime;
            }

            // CD时间到了
            if (spawnRemainTime <= 0)
            {
                // CD判断 数量判断
                if (_curData.maxNum < 0 || _showShadows.Count < _curData.maxNum)
                {
                    Shadow shadow = null;
                    if (_hideShadows.Count > 0)
                    {
                        shadow = _hideShadows.Pop();
                    }
                    else
                    {
                        shadow = _CreateShadow(false);
                    }
                    shadow.Show(_curData.duration, _curData.colorCurve, _ghostShaderData);
                    _showShadows.Add(shadow);
                    spawnRemainTime = _curData.spawnInterval;
                }
            }
        }

        // 创建残影
        private Shadow _CreateShadow(bool isPreload)
        {
            var src = actor.GetDummy(ActorDummyType.Model);
            var shadow = new Shadow(src, _shadowObjPath, isPreload);
            return shadow;
        }
    }
}
