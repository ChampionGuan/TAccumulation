using System;
using System.Collections.Generic;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    public class ActorSetStencilBehaviour : InterruptBehaviour
    {
        private List<Renderer> _renderers;
        private int _stencilValue = 2;
        private bool _onlyCloth = true; 
        private static readonly int _stencilRef = Shader.PropertyToID("_StencilRef");

        public void SetData(int value, bool onlyCloth)
        {
            _stencilValue = value;
            _onlyCloth = onlyCloth;
        }

        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            var bindObj = playerData as GameObject;
            if (bindObj == null)
                return;

            if (_renderers == null)
            {
                _renderers = new List<Renderer>();
                var renderers = bindObj.GetComponentsInChildren<SkinnedMeshRenderer>(true);
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

        protected override void OnStop()
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