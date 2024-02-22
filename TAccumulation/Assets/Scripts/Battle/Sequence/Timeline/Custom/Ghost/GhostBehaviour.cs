using System;
using System.Collections.Generic;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Profiling;
using UnityEngine.SceneManagement;
using X3Battle;
using X3Battle.Timeline;

namespace UnityEngine.Timeline
{
    [Serializable]
    public class GhostBehaviour : InterruptBehaviour
    {
        GhostActionItem _ghostActionItem = new GhostActionItem();
        public void SetFadeScale(AnimationCurve scale)
        {
            _ghostActionItem.SetFadeScale(scale);
        }
        
        // 查找骨骼引用
        public void FindBoneSrc()
        {
            _ghostActionItem.FindBoneSrc();
        }
        
        public void SetGhostShaderData(GhostShaderData shaderData)
        {
           _ghostActionItem.SetGhostShaderData(shaderData);
        }
        
        public void SetTrackInfo(GameObject obj, Gradient defaultColor,
            PlayableDirector playableDirector, AnimationClip clip, GhostParam param, GameObject reference, GhostObjectPool pool)
        {
            _ghostActionItem.SetTrackInfo(obj, defaultColor, playableDirector, clip, param, reference, pool);
        }

        // 开始
        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            using (ProfilerDefine.GhostBehaviourOnStartMarker.Auto())
            {
                if (_ghostActionItem.director == null)
                {
                    return;    
                }
                _ghostActionItem.OnStart((float) _ghostActionItem.director.time);
            }
        }

        // 帧更新
        protected override void OnProcessFrame(Playable playable, FrameData info, object playerData)
        {
            using (ProfilerDefine.GhostBehaviourOnProcessFrameMarker.Auto())
            {
                if (_ghostActionItem.director == null)
                {
                    return;    
                }
                _ghostActionItem.OnProcessFrame((float) _ghostActionItem.director.time);
            }
        }

        // 结束
        protected override void OnStop()
        {
            using (ProfilerDefine.GhostBehaviourOnStopMarker.Auto())
            {
                _ghostActionItem.OnStop();

            }
        }
    }
}