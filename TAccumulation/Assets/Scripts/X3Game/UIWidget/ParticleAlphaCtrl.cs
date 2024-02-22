using System;
using System.Collections.Generic;
using UnityEngine;

namespace PapeGames.X3UI
{
    public class ParticleAlphaCtrl : MonoBehaviour
    {
        private List<float> m_oriAlphaList = new List<float>();
        private List<Renderer> m_renderers = new List<Renderer>();

        static MaterialPropertyBlock s_MPB = null;
        static int s_NameId = Shader.PropertyToID("_Color");

        private int m_PreAlpha = 255;
        [Range(0, 255)] public int Alpha = 255;

        private void Awake()
        {
            ParticleSystem[] childs = GetComponentsInChildren<ParticleSystem>();
            for (int i = 0; i < childs.Length; i++)
            {
                Renderer renderer = childs[i].GetComponent<Renderer>();
                if (null == renderer || renderer.enabled == false || renderer.sharedMaterial == null)
                {
                    continue;
                }
                
                m_renderers.Add(renderer);
                var oriAlpha = GetAlpha(renderer);
                m_oriAlphaList.Add(oriAlpha);
            }
        }

        private void OnEnable()
        {
            UpdateMaterial();
        }


        private void Update()
        {
            if (m_PreAlpha != Alpha)
            {
                UpdateMaterial();
            }
        }

        private void UpdateMaterial()
        {
            m_PreAlpha = Alpha;
            float alpha = Alpha / 255f;
            for (int i = 0; i < m_renderers.Count; i++)
            {
                var renderer = m_renderers[i];
                if (renderer == null)
                    return;
                
                SetAlpha(renderer, alpha * m_oriAlphaList[i]);
            }
        }

        private float GetAlpha(Renderer renderer)
        {
            if (null == renderer)
            {
                return 1;
            }

            return renderer.sharedMaterial.GetColor(s_NameId).a;
        }

        private void SetAlpha(Renderer renderer, float alpha)
        {
            if (null == renderer)
            {
                return;
            }
            if (s_MPB == null)
                s_MPB = new MaterialPropertyBlock();
            s_MPB.Clear();
            Color c = renderer.sharedMaterial.GetColor(s_NameId);
            c.r = Mathf.LinearToGammaSpace(c.r);
            c.g = Mathf.LinearToGammaSpace(c.g);
            c.b = Mathf.LinearToGammaSpace(c.b);
            c.a = alpha;
            s_MPB.SetColor(s_NameId, c);
            renderer.SetPropertyBlock(s_MPB);
        }
    }
}