using System.Collections.Generic;
using Framework;

namespace UnityEngine.Timeline
{
    public class GhostObjectPool
    {
        // 没有clip的对象，用_defaultKey装载
        private AnimationClip _defaultKey;
        private GameObject _origin;
        private bool _originUsed;

        public Dictionary<AnimationClip, Stack<GhostAnimPlayable>> _cache =
            new Dictionary<AnimationClip, Stack<GhostAnimPlayable>>(4);
        
        public GhostObjectPool(GameObject origin)
        {
            _originUsed = false;
            _origin = origin;
            _defaultKey = new AnimationClip();
        }

        public void Destroy()
        {
            foreach (var iter in _cache)
            {
                foreach (var item in iter.Value)
                {
                    item.Destroy();
                    if (item.gameObject != _origin)
                    {
                        // 不为_origin才销毁
                        GameObject.Destroy(item.gameObject);   
                    }
                }   
            }

            if (_defaultKey != null)
            {
                Object.Destroy(_defaultKey);
                _defaultKey = null;
            }
        }
        
        public Stack<GhostAnimPlayable> GetStack(AnimationClip clip)
        {
            if (clip == null)
            {
                clip = _defaultKey;
            }
            _cache.TryGetValue(clip, out var stack);
            if (stack == null)
            {
                stack = new Stack<GhostAnimPlayable>(8);
                _cache.Add(clip, stack);
            }
            return stack;
        }
        
        public GhostAnimPlayable Get(AnimationClip clip)
        {
            if (clip == null)
            {
                clip = _defaultKey;
            }
            GhostAnimPlayable playable = null;
            var stack = GetStack(clip);
            if (stack.Count > 0)
            {
                playable = stack.Pop();
            }
            else
            {
                playable = _CreateObj(clip);  
            }
            playable.gameObject.SetVisible(true);

            var modelGraph = PlayableAnimationManager.Instance()?.FindPlayGraph(playable.gameObject);
            if (null != modelGraph) modelGraph.Active = true;

            return playable;
        }

        public void Release(AnimationClip clip, GhostAnimPlayable obj)
        {
            if (clip == null)
            {
                clip = _defaultKey;
            }
            obj.gameObject.SetVisible(false);
            var stack = GetStack(clip);
            stack.Push(obj);
            
            var modelGraph = PlayableAnimationManager.Instance()?.FindPlayGraph(obj.gameObject);
            if (null != modelGraph) modelGraph.Active = false;
        }

        private GhostAnimPlayable _CreateObj(AnimationClip clip)
        {
            if (clip == null)
            {
                clip = _defaultKey;
            }
            
            GameObject obj = null;
            if (_originUsed)
            {
                obj = GameObject.Instantiate(_origin, _origin.transform.parent);  
            }
            else
            {
                _originUsed = true;
                obj = _origin;
            }

            // 如果是defaultKey，就传null，内部不真正创建graph
            AnimationClip createClip = clip;
            if (createClip == _defaultKey)
            {
                createClip = null;
            }
            var playable = new GhostAnimPlayable(obj, createClip);
            return playable;
        }
        
    }
}