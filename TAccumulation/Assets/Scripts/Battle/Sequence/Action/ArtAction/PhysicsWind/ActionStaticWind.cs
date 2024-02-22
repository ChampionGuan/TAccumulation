using UnityEngine;
using UnityEngine.Profiling;
using UnityEngine.Timeline;
using X3.Character;

namespace X3Battle
{
    public class ActionStaticWind: BSAction
    {
        private static PhysicsWindParam _zeroWindData = new PhysicsWindParam();
        private PhysicsWindParam _windParam;
        private PhysicsWindParam _windParam2;
        private PhysicsWindParam _lerpWindParam; // 插值字段
        private PhysicsWindParam _oldWindParam;
        private X3PhysicsWind _wind;
        public GameObject bindObj { get; private set; }

        public PhysicsWindParam GetWinParam()
        {
            return _windParam;
        }
        
        public PhysicsWindParam GetLerpParam()
        {
            return _lerpWindParam;
        }
        
        // 初始化
        protected sealed override void _OnInit()
        {
            var needLerp = false;
            var isLerp = _GetLerpAndWindParam(out var windParam1, out var windParam2);
            if (isLerp)
            {
                if (windParam1 != null && windParam2 != null)
                {
                    if (windParam1.volumeParams?.Count == windParam2.volumeParams?.Count)
                    {
                        needLerp = true;
                    }
                }
            }
            
            if (needLerp)
            {
                _SetPhysicsWindParam(windParam1, windParam2);
            }
            else
            {
                _SetPhysicsWindParam(windParam1, null); 
            }

            bindObj = GetTrackBindObj<GameObject>();
        }

        protected virtual bool _GetLerpAndWindParam(out PhysicsWindParam param1, out PhysicsWindParam param2)
        {
            var clip = GetClipAsset<PhysicsWindPlayableAsset>();
            clip.Wind = this;
            param1 = clip.physicsWindParam;
            param2 = clip.physicsWindParam2;
            return clip.isLerp;
        }

        private void _SetPhysicsWindParam(PhysicsWindParam param, PhysicsWindParam param2)
        {
            _windParam = param;
            _windParam2 = param2;
            if (_windParam2 != null)
            {
                _lerpWindParam = _windParam.Clone();
            }
        }

        // 进入
        protected sealed override void _OnEnter()
        {
            using (ProfilerDefine.ActionStaticWindOnEnterMarker.Auto())
            {
                _oldWindParam = _zeroWindData;
                if (_windParam2 == null)
                {
                    _wind = PhysicsWindParamTool.SetToGameObject(_windParam, bindObj);
                }
                else
                {
                    _wind = PhysicsWindParamTool.SetToGameObject(_lerpWindParam, bindObj);
                    _Lerp(curOffsetTime);
                }
            }
        }

        // Update更新
        protected sealed override void _OnUpdate()
        {
            _Lerp(curOffsetTime);
            if (_wind != null)
            {
                _wind.OnUpdate();  // 显示调用一下wind的Update  
            }
        }

        private void _Lerp(float time)
        {
            if (_lerpWindParam == null || bindObj == null)
            {
                return;  
            }

            var process = time / duration;
            _lerpWindParam.Lerp2Self(_windParam, _windParam2, process);
        }

        // 退出
        protected sealed override void _OnExit()
        {
            using (ProfilerDefine.ActionStaticWindOnStopMarker.Auto())
            {
                PhysicsWindParamTool.SetToGameObject(_oldWindParam, bindObj);
#if UNITY_EDITOR
                // 编辑器下clip运行出去之后消除范围辅助线
                if (_windParam != null)
                {
                    _windParam.AttachGameObject(null);   
                }

                if (_lerpWindParam != null)
                {
                    _lerpWindParam.AttachGameObject(null);
                }
#endif 
            }
        }
    }
}