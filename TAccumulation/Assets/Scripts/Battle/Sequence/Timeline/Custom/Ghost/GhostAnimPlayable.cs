// using Framework;
// using PapeAnimation;
// using UnityEngine.Animations;
// using UnityEngine.Playables;
//
// namespace UnityEngine.Timeline
// {
//     public class GhostAnimPlayable : GenericAnimationNode, IPlayableInsInterface
//     {
//         private GameObject _obj;
//         public GameObject gameObject => _obj;
//         
//         private AnimationClip _animClip;
//         
//         private AnimationClipPlayable _animPlayable;
//         private bool _isDestroy = false;
//         
//         private SkinnedMeshRenderer[] _meshs;
//         public SkinnedMeshRenderer[] meshs => _meshs;
//         
//         // 构造时把外部数据一次性传入
//         public GhostAnimPlayable(GameObject obj, AnimationClip animClip)
//         {
//             _obj = obj;
//             _meshs = obj.transform.GetComponentsInChildren<SkinnedMeshRenderer>();
//             _animClip = animClip;
//             _Init();
//         }
//
//         // 外部接口，设置时间
//         public void SetTime(float time)
//         {
//             if (_isDestroy)
//             {
//                 return;
//             }
//             
//             SetOverrideTime(time);
//             // if (_animPlayable.IsValid())
//             // {
//             //     _animPlayable.SetTime(time);      
//             // }
//         }
//
//         public void SetPlayableWeight(float weight)
//         {
//             SetWeight(weight);
//         }
//
//         private void _Init()
//         {
//             if (_obj != null && _animClip != null)
//             {
//                 var animator = _obj.GetComponent<Animator>();
//                 if (animator == null)
//                 {
//                     animator = _obj.AddComponent<Animator>();
//                 }
//                 PlayableAnimationManager.Instance().AddAnimation(animator, this, EStaticSlot.Battle);
//             }  
//         }
//         
//         public override GenericAnimationMixer GetMixer()
//         {
//             return null;
//         }
//
//         public override Playable GetOutput()
//         {
//             return _animPlayable.IsValid() ? _animPlayable : Playable.Null;
//         }
//         
//         // 销毁
//         public void Destroy()
//         {
//             PlayableAnimationManager.Instance().RemoveAnimation(this);
//         }
//
//         // 构建
//         protected override void OnBuild()
//         {
//             if (_obj != null && _animClip != null)
//             {
//                 // 创建AnimationPlayable
//                 _animPlayable = AnimationClipPlayable.Create(animationSystem.graph, _animClip);
//             }
//         }
//
//         // 销毁
//         protected override void OnDestroy()
//         {
//             if (_isDestroy)
//             {
//                 return;
//             }
//
//             _isDestroy = true;
//
//             if (_animPlayable.IsValid())
//             {
//                 _animPlayable.Destroy();
//             }
//         }
//
//         public override void Tick(float deltaTime)
//         {
//         }
//     }
// }

// TODO 美术急用，先用原生的PlayableGraph，后面专门出场景验证, 后面重构时外部需要再封一层
using Framework;
using PapeAnimation;
using UnityEngine.Animations;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    public class GhostAnimPlayable: IPlayableInsInterface
    {
        private GameObject _obj;
        public GameObject gameObject => _obj;
        
        private AnimationClip _animClip;
        
        private AnimationClipPlayable _animPlayable;
        private bool _isDestroy = false;
        
        private SkinnedMeshRenderer[] _meshs;
        public SkinnedMeshRenderer[] meshs => _meshs;

        private PlayableGraph? _graph;

        // 放到这里，避免每次存取
        public SyncTransformComp syncComp { get; private set; }

        // 构造时把外部数据一次性传入
        public GhostAnimPlayable(GameObject obj, AnimationClip animClip)
        {
            _obj = obj;
            _meshs = obj.transform.GetComponentsInChildren<SkinnedMeshRenderer>();
            _animClip = animClip;
            if (_obj != null)
            {
                syncComp = _obj.GetComponent<SyncTransformComp>();
                if (syncComp == null)
                {
                    syncComp = obj.AddComponent<SyncTransformComp>();
                }
            }
            _Init();
        }
        
        // 外部接口，设置时间
        public void SetTime(float time)
        {
            if (_isDestroy)
            {
                return;
            }

            if (_animPlayable.IsValid())
            {
                _animPlayable.SetTime(time);      
            }

            if (_graph != null)
            {
                _graph.Value.Evaluate();
            }
        }

        public void SetActive(bool active)
        {
            // if (_graph != null)
            // {
            //     if (active)
            //     {
            //         _graph.Value.Stop();
            //     }
            //     else
            //     {
            //         _graph.Value.Play();
            //     }
            // }
        }

        public void SetPlayableWeight(float weight)
        {
            // SetWeight(weight);
        }

        private void _Init()
        {
            if (_obj != null && _animClip != null)
            {
                var animator = _obj.GetComponent<Animator>();
                if (animator == null)
                {
                    animator = _obj.AddComponent<Animator>();
                }
                
                var graph = PlayableGraph.Create(_obj.name);
                graph.SetTimeUpdateMode(DirectorUpdateMode.Manual);
                _animPlayable = AnimationClipPlayable.Create(graph, _animClip);
                var playableOutput = AnimationPlayableOutput.Create(graph, "Animation", animator);
                playableOutput.SetSourcePlayable(_animPlayable);
                _graph = graph;
            }  
        }
        
        
        // 销毁
        public void Destroy()
        {
            _OnDestroy();
        }
        
        private void _OnDestroy()
        {
            if (_isDestroy)
            {
                return;
            }

            _isDestroy = true;

            if (_animPlayable.IsValid())
            {
                _animPlayable.Destroy();
            }

            if (_graph != null)
            {
                _graph.Value.Destroy();
                _graph = null;
            }
        }
    }
}