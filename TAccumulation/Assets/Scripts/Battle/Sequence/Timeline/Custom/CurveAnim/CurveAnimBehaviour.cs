using System;
using BattleCurveAnimator;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    [Serializable]
    public class CurveAnimBehaviour : InterruptBehaviour
    {
        public MultiAnimData multiAnimData;
        public GameObject bindObj;
        public float clipDuration;

        protected CurveAnimator _curveAnimator;
        protected bool enterEnd = false;

        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            if (!(playerData is GameObject))
                return;

            bindObj = playerData as GameObject;
                if (bindObj == null)
                    return;

            if (multiAnimData == null)
                return;

#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                //TODO 去掉BattleEffect,会update影响材质
                var battleEffects = bindObj.GetComponentsInChildren<BattleBaseEffect>();
                foreach (var be in battleEffects)
                    be.enabled = false;
            }
#endif

            _curveAnimator = bindObj.GetComponent<CurveAnimator>();
            if (!_curveAnimator)
            {
                _curveAnimator = bindObj.AddComponent<CurveAnimator>();
                _curveAnimator.Init();
            }
            _curveAnimator.Play(multiAnimData, 0, clipDuration);
        }

        protected override void OnProcessFrame(Playable playable, FrameData info, object playerData)
        {
            var newTime = (float)playable.GetTime();
            if (multiAnimData != null && _curveAnimator != null)
            {
                _curveAnimator.Sample(multiAnimData.name, newTime);

                //三段式Stop 进入End阶段
                if (multiAnimData.anims.Length == 3)
                {
                    if (!enterEnd && 
                        newTime > multiAnimData.anims[0].length + multiAnimData.anims[1].length)
                    {
                        enterEnd = true;
                        _curveAnimator.Stop(multiAnimData.name);
                    }
                }
            }
        }

        protected override void OnStop()
        {
            enterEnd = false;
            //一段 Stop
            if (_curveAnimator != null && multiAnimData != null)
            {
                if(multiAnimData.anims.Length == 1)
                    _curveAnimator.Stop(multiAnimData.name);
                else
                    _curveAnimator.Sample(multiAnimData.name, float.MaxValue);
#if UNITY_EDITOR
                //editor下移除动画 修改属性得到更新
                if (!Application.isPlaying)
                    _curveAnimator.Remove(multiAnimData.name);
#endif
            }
        }
    }
}