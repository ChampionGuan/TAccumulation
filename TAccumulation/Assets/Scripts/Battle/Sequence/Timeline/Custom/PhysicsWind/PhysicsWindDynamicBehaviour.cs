using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine.Playables;
using UnityEngine.Profiling;
using X3.Character;
using X3Battle;

namespace UnityEngine.Timeline
{
    // TODO 考虑用一个behavior
    public class PhysicsWindDynamicBehaviour : InterruptBehaviour
    {
        private PhysicsWindParam windParam;
        private PhysicsWindParam windParam2;
        private PhysicsWindParam lerpWindParam; // 插值字段
        private PhysicsWindParam oldWindParam;
        private X3PhysicsWind _wind;
        public GameObject bindObj { get; private set; }
        private float duration;

        private static PhysicsWindParam _zeroWindData = new PhysicsWindParam(); 

        public PhysicsWindParam GetWinParam()
        {
            return windParam;
        }
        
        public PhysicsWindParam GetLerpParam()
        {
            return lerpWindParam;
        }
        
        public void SetPhysicsWindParam(PhysicsWindParam param, PhysicsWindParam param2)
        {
            windParam = param;
            windParam2 = param2;
            if (windParam2 != null)
            {
                lerpWindParam = windParam.Clone();
            }
        }

        public void SetDuration(float time)
        {
            duration = time;
        }
        

        // 开始运行
        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            using (ProfilerDefine.PhysicsWindDynamicBehaviourOnStartMarker.Auto())
            {
                if (playerData is GameObject)
                {
                    bindObj = playerData as GameObject;
                    // oldWindParam = PhysicsWindParamTool.CreateByGameObject(bindObj);
                    oldWindParam = _zeroWindData;
                    if (windParam2 == null)
                    {
                        _wind = PhysicsWindParamTool.SetToGameObject(windParam, bindObj);
                    }
                    else
                    {
                        _wind = PhysicsWindParamTool.SetToGameObject(lerpWindParam, bindObj);
                        Lerp((float)playable.GetTime());
                    }
                }
            }
        }

        protected override void OnProcessFrame(Playable playable, FrameData info, object playerData)
        {
            Lerp((float) playable.GetTime());
            if (_wind != null)
            {
                _wind.OnUpdate();  // 显示调用一下wind的Update  
            }
        }

        private bool Lerp(float time)
        {
            if (lerpWindParam == null || bindObj == null)
            {
                return false;  
            }

            var process = time / duration;
            lerpWindParam.Lerp2Self(windParam, windParam2, process);
            return true;
        }
        
        // 结束时或者被打断时调用，如果没有OnStart肯定不会调用过来
        protected override void OnStop()
        {    
            using (ProfilerDefine.PhysicsWindDynamicBehaviourOnStopMarker.Auto())
            {
                PhysicsWindParamTool.SetToGameObject(oldWindParam, bindObj);
#if UNITY_EDITOR
                // 编辑器下clip运行出去之后消除范围辅助线
                if (windParam != null)
                {
                    windParam.AttachGameObject(null);   
                }

                if (lerpWindParam != null)
                {
                    lerpWindParam.AttachGameObject(null);
                }
#endif 
            }
        }
    }
}