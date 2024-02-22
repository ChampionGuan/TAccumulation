using System;
using System.Collections.Generic;
using System.Reflection;
using PapeGames.Rendering;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.Timeline;

namespace X3Battle
{
    /// <summary>
    /// 材质贴图K帧辅助脚本（实际只用在编辑器下）
    /// </summary>
    [RequireComponent(typeof(Renderer))]
    [ExecuteInEditMode]
    [DisallowMultipleComponent]
    public class MatTexAnimHelper : MonoBehaviour
    {
        public Texture2D BumpMap;
        public Texture2D DissolveMap;
        public Texture2D EffectAlbedoMap;
        public Texture2D EnvCubemap;
        public Texture2D FlowTex;
        public Texture2D FresnelGlowDistortMap;
        public Texture2D LightMapSHTex;
        public Texture2D LightMapTex;
        public Texture2D MetallicMap;
        public Texture2D RoughnessMap;
        public Texture2D ShadowMaskTex;
        public Texture2D TangentMap;
        public Texture2D CandywrapperTex;

        public Texture2D MainTex;
        public Texture2D NormalTex;
        public Texture2D VolumetricStyleTex;
        public Texture2D VolumetricColorTex;
        public Texture2D EmissionTex;
        public Texture2D GlowMap;
        public Texture2D EffectMatcap;//对应matcap
        
        protected Renderer _renderer;
        
        private void Awake()
        {
            _renderer = GetComponent<Renderer>();
        }

        protected void OnDidApplyAnimationProperties()
        {
// #if UNITY_EDITOR
//         _Update();
// #endif
        }

        public void Update()
        {
#if UNITY_EDITOR
            _Update();
#endif
        }

        public void _Update()
        {
            if (!_renderer)
            {
                return;
            }
            //获取所有字段
            var mat = this.GetComponent<MatTexAnimHelper>();
            if (mat == null)
                return;
            
            FieldInfo[] fields = mat.GetType().GetFields();

            foreach (var field in fields)
            {
                var obj = field.GetValue(this);
                var tex = obj as Texture2D;
                if(tex == null)
                    continue;
                
                _renderer.SetTextureToMPB(Shader.PropertyToID("_" + field.Name), tex);
            }
        }
    }
}