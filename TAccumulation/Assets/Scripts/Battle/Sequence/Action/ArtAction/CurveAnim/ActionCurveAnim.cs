using System;
using BattleCurveAnimator;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class ActionCurveAnim : BSAction
    {
        public MultiAnimData multiAnimData;
        public GameObject bindObj;

        protected CurveAnimator _curveAnimator;
        protected bool enterEnd = false;
        protected override void _OnInit()
        {
            var clipAsset = GetClipAsset<CurveAnimPlayableAsset>();
            multiAnimData = clipAsset.multiAnimData;
        }
        
        protected override void _OnEnter()
        {
            var bindObj = GetTrackBindObj<GameObject>();
            if (bindObj == null)
            {
                return;
            }
            
            if (multiAnimData == null)
                return;

            _curveAnimator = bindObj.GetComponent<CurveAnimator>();
            if (!_curveAnimator)
            {
                _curveAnimator = bindObj.AddComponent<CurveAnimator>();
                _curveAnimator.Init();
            }
            _curveAnimator.Play(multiAnimData, overrideDuration : duration);
        }

        protected override void _OnUpdate()
        {
            var newTime = this.curOffsetTime;// (float)playable.GetTime();
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

        protected override void _OnExit()
        {
            enterEnd = false;
            //一段 Stop
            if (_curveAnimator != null && multiAnimData != null)
            {
                if(multiAnimData.anims.Length == 1)
                    _curveAnimator.Stop(multiAnimData.name);
                else
                    _curveAnimator.Sample(multiAnimData.name, float.MaxValue);
            }
        }
    }
}