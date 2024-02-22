using PapeGames.X3;
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;
using X3Sequence;

namespace X3Battle
{
    [TimelineMenu("关闭碰撞器(退出时打开)")]
    [Serializable]
    public class DeactiveColliderAsset : BSActionAsset<DeactiveCollider>
    {
        [LabelText("挂点名(有碰撞器的)")] 
        public List<string> dummys;
    }

    public class DeactiveCollider : BSAction<DeactiveColliderAsset>
    {
        protected override void _OnEnter()
        {
            _ActiveCollider(false);
        }
        
        protected override void _OnExit()
        {
            _ActiveCollider(true);
        }

        private void _ActiveCollider(bool active)
        {
            if (clip.dummys == null || clip.dummys.Count <= 0)
                return;
            var colliderBehaviour = context.actor.collider;
            if (colliderBehaviour == null)
                return;
            
            foreach (var dummy in clip.dummys)
            {
                var colliderMono = colliderBehaviour.GetColliderMono(ColliderType.Collider, dummy);
                colliderMono?.Enable(active);
            }
        }
    }
}