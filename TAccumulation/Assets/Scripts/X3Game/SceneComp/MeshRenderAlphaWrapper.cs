using UnityEngine;
using XLua;
using System.Collections.Generic;

[LuaCallCSharp]
[Hotfix]
public class MeshRenderAlphaWrapper : MonoBehaviour
{
    [SerializeField]
    [Range(0, 1)]
    public float AlphaValue = 1.0f;

    List<Renderer> Renderers = new List<Renderer>();
    List<float> RenderersAlpha = new List<float>();
    MaterialPropertyBlock props = null;

    const string PROPERTY_NAME = "_Color";

    private void Awake()
    {
        var renderers = transform.GetComponentsInChildren<Renderer>();
        if (props == null)
        {
            props = new MaterialPropertyBlock();
        }
        for (int i = 0; i < renderers.Length; i++)
        {
            var renderer = renderers[i];
            if (renderer.sharedMaterial == null || !renderer.sharedMaterial.HasProperty(PROPERTY_NAME))
                continue;
            renderer.GetPropertyBlock(props);
            Color c = renderer.sharedMaterial.GetColor(PROPERTY_NAME);
            if (c == null)
                continue;
            Renderers.Add(renderer);
            RenderersAlpha.Add(c.a);
        }
    }

    void Update()
    {
        SetAlpha();
    }

    public void SetAlpha()
    {
        if (Renderers == null || Renderers.Count <= 0)
            return;

        for (int i = 0; i < Renderers.Count; i++)
        {
            var renderer = Renderers[i];
            renderer.GetPropertyBlock(props);
            Color c = renderer.sharedMaterial.GetColor(PROPERTY_NAME);
            c.a = AlphaValue;
            props.SetColor(PROPERTY_NAME, c);
            renderer.SetPropertyBlock(props);
        }
    }

    public void RevertAlpha()
    {
        if (Renderers == null || RenderersAlpha == null)
            return;
        if (RenderersAlpha.Count != Renderers.Count)
            return;

        for (int i = 0; i < Renderers.Count; i++)
        {
            var renderer = Renderers[i];
            renderer.GetPropertyBlock(props);
            Color c = renderer.sharedMaterial.GetColor(PROPERTY_NAME);
            c.a = RenderersAlpha[i];
            props.SetColor(PROPERTY_NAME, c);
            renderer.SetPropertyBlock(props);
        }
    }

    public void OnDestroy()
    {
        props = null;
    }
}
