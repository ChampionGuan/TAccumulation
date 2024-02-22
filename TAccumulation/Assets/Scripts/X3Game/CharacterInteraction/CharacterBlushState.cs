using System;
using Framework;
using PapeAnimation;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;

namespace X3Game
{
    public class CharacterBlushState
    {
        public int playId = 0;

        private float _moveinTime;
        private float _moveoutTime;
        
        private GenericAnimationTree _blushTree;
        private AnimationClipInstanceNode _moveinNode;
        private AnimationClipInstanceNode _moveoutNode;
        private AnimationClipInstanceNode _loopNode;
        private BlushStage _curStage;
        private Action<int> m_MoveinCallback;
        private Action<int> m_MoveoutCallback;

        enum BlushStage
        {
            None,
            Movein,
            Loop,
            Moveout,
            Finish,
        }

        public CharacterBlushState(GenericAnimationTree parent, int id)
        {
            _blushTree = GenericAnimationTree.Create(MixerType.Mixer);
            parent.AddSubNode(_blushTree);
            playId = id;
        }

        public GenericAnimationTree GetTreeRoot()
        {
            return _blushTree;
        }

        public void SetAnimationClips(AnimationClip moveinClip, AnimationClip moveoutClip, AnimationClip loopClip)
        {
            if (_blushTree == null)
                return;
            if (_moveinNode != null) _blushTree.RemoveSubNode(_moveinNode);
            if (_moveoutNode != null) _blushTree.RemoveSubNode(_moveoutNode);
            if (_loopNode != null) _blushTree.RemoveSubNode(_loopNode);

            if (moveinClip)
            {
                _moveinNode = new AnimationClipInstanceNode(moveinClip); // blush
            }
            else
            {
                _moveinNode = null;
            }

            if (moveoutClip)
            {
                _moveoutNode = new AnimationClipInstanceNode(moveoutClip); // unblush
            }
            else
            {
                _moveoutNode = null;
            }

            if (loopClip)
            {
                _loopNode = new AnimationClipInstanceNode(loopClip); // loop
            }
            else
            {
                _loopNode = null;
            }

            _moveinTime = moveinClip.length;
            _moveoutTime = moveoutClip.length;

            if (_blushTree != null)
            {
                if (_moveinNode != null)
                {
                    _blushTree.AddSubNode(_moveinNode);
                }

                if (_moveoutNode != null)
                {
                    _blushTree.AddSubNode(_moveoutNode);
                }

                if (_loopNode != null)
                {
                    _blushTree.AddSubNode(_loopNode);
                }
            }

            _curStage = BlushStage.None;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="autoTick"></param>
        public void SetAutoTick(bool autoTick)
        {
            if (_moveinNode != null)
            {
                _moveinNode.ShouldOverrideNodeTime = !autoTick;
            }
            
            if (_loopNode != null)
            {
                _loopNode.ShouldOverrideNodeTime = !autoTick;
            }

            if (_moveoutNode != null)
            {
                _moveoutNode.ShouldOverrideNodeTime = !autoTick;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="progress"></param>
        public void SetProgress(float progress)
        {
            if (_moveinNode != null)
            {
                _moveinNode.SetOverrideTime(_moveinNode.Length * progress);
            }
            
            if (_loopNode != null)
            {
                _loopNode.SetOverrideTime(_loopNode.Length * progress);
            }

            if (_moveoutNode != null)
            {
                _moveoutNode.SetOverrideTime(_moveoutNode.Length * progress);
            }
        }

        /// <summary>
        /// 设置Movein和out的回调
        /// </summary>
        /// <param name="moveinCallback"></param>
        /// <param name="moveoutCallback"></param>
        public void SetCallback(Action<int> moveinCallback, Action<int> moveoutCallback)
        {
            m_MoveinCallback = moveinCallback;
            m_MoveoutCallback = moveoutCallback;
        }

        public void Play()
        {
            if (_blushTree.HasValidOutput() && _curStage == BlushStage.None)
            {
                _curStage = BlushStage.Movein;
                if (_moveinNode != null)
                {
                    _moveinNode.time = 0;
                    _moveinNode.SetWeight(1f);
                }

                if (_moveoutNode != null)
                {
                    _moveoutNode.SetWeight(0f);
                }

                if (_loopNode != null)
                {
                    _loopNode.SetWeight(0f);
                }
            }
        }


        public void Stop()
        {
            if (_blushTree.HasValidOutput() && _curStage == BlushStage.Loop)
            {
                _curStage = BlushStage.Moveout;
                if (_moveinNode != null)
                {
                    _moveinNode.SetWeight(0f);
                }

                if (_moveoutNode != null)
                {
                    _moveoutNode.time = 0;
                    _moveoutNode.SetWeight(1f);
                }

                if (_loopNode != null)
                {
                    _loopNode.SetWeight(0f);
                }
            }
        }

        public void SetBlushLoop()
        {
            if (_blushTree.HasValidOutput())
            {
                _curStage = BlushStage.Loop;
                if (_moveinNode != null)
                {
                    _moveinNode.SetWeight(0f);
                }

                if (_moveoutNode != null)
                {
                    _moveoutNode.SetWeight(0f);
                }

                if (_loopNode != null)
                {
                    _loopNode.time = 0;
                    _loopNode.SetWeight(1f);
                }
            }
        }

        public void Finish()
        {
            if (_curStage == BlushStage.Movein)
            {
                m_MoveinCallback?.Invoke(playId);
            }

            if (_curStage == BlushStage.Moveout)
            {
                m_MoveoutCallback?.Invoke(playId);
            }

            _curStage = BlushStage.Finish;
        }

        /// <summary>
        /// 判断是否播放完毕了
        /// </summary>
        /// <returns></returns>
        public bool IsFinish()
        {
            return _curStage == BlushStage.Finish;
        }

        public void LateUpdate()
        {
            if ((_moveinNode == null || _moveinNode.time >= _moveinTime) && _curStage == BlushStage.Movein)
            {
                m_MoveinCallback?.Invoke(playId);
                SetBlushLoop();
            }
            
            if ((_moveoutNode == null || _moveoutNode.time >= _moveoutTime) && _curStage == BlushStage.Moveout)
            {
                m_MoveoutCallback?.Invoke(playId);
                _curStage = BlushStage.Finish;
            }
        }

        public void CleanUp()
        {
            if (_blushTree.HasValidOutput())
            {
                if (_moveoutNode != null)
                {
                    _moveoutNode.time = _moveoutNode.Length;
                    _moveoutNode.SetWeight(1f);
                }

                if (_moveinNode != null)
                {
                    _moveinNode.SetWeight(0f);
                }

                if (_loopNode != null)
                {
                    _loopNode.SetWeight(0f);
                }
            }
        }

        public void Destroy()
        {
            Finish();
            _blushTree.RemoveFromParent();
            _blushTree = null;
        }
    }
}