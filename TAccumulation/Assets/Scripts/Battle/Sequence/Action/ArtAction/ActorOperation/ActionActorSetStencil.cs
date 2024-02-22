using System.Collections.Generic;
using PapeGames;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class ActionActorSetStencil : BSAction
    {
        private List<Renderer> _renderers;
        private int _stencilValue = 2;
        private bool _onlyCloth = true;
        private static readonly int _stencilRef = Shader.PropertyToID("_StencilRef");

        protected override void _OnInit()
        {
            // 获取playable绑定的clip
            var clip = GetClipAsset<ActorSetStencilClip>();
            _stencilValue = clip.StencilValue;
            _onlyCloth = clip.OnlyCloth;
        }

        protected override void _OnEnter()
        {
            // 获取轨道绑定的对象
            var obj = GetTrackBindObj<GameObject>();
            if (obj == null)
                return;

            if (_renderers == null)
            {
                _renderers = new List<Renderer>();
                var renderers = obj.GetComponentsInChildren<SkinnedMeshRenderer>(true);
                foreach (var r in renderers)
                {
                    if (!r || !r.sharedMaterial)
                        continue;
                    if (_onlyCloth && !r.sharedMaterial.shader.name.Contains("Papegame/Cloth"))
                        continue;

                    _renderers.Add(r);
                }
            }

            _SetStencil(_stencilValue);
        }

        protected override void _OnExit()
        {
            _SetStencil(0);
        }

        void _SetStencil(int value)
        {
            if (_renderers == null)
                return;

            foreach (var r in _renderers)
            {
                if (r && r.sharedMaterial)
                    r.sharedMaterial.SetInt(_stencilRef, value);
            }
        }
    }
}