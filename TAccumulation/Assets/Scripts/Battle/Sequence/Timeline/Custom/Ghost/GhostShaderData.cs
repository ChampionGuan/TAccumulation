using System;

namespace UnityEngine.Timeline
{
    [Serializable]
    public class GhostShaderData
    {
        public enum RenderType
        {
            TwoSize = 0, //Cull Off
            Back = 1, //Cull Front
            Front = 2 //Cull Back
        }

        // Common相关
        // RenderType
        public RenderType Cull = RenderType.TwoSize;

        // 菲涅尔相关
        // 范围 0~10
        public float FresnelPower = 5;
        // 强度 0~10
        public float FresnelFactor = 6;
        // 外部颜色 HDR
        [ColorUsage(false, true)] public Color FresnelColor = new Color(1, 1, 1, 1);
        // 外部透明度 0~1
        public float FresnelAlpha = 1.0f;
        // 内部颜色 HDR
        public Color FresnelInsideColor = new Color(0, 0, 0, 1);
        // 内部透明度 0~1
        public float FresnelInsideAlpha = 1.0f;

        public void SetToMeshes(MaterialPropertyBlock block, SkinnedMeshRenderer[] meshes)
        {
            if (block == null || meshes == null || meshes.Length <= 0)
            {
                return;
            }
            
            foreach (var renderer in meshes)
            {
                renderer.GetPropertyBlock(block);
                block.SetFloat("_Cull", (float)Cull);
                block.SetFloat("_FresnelPower", FresnelPower);
                block.SetFloat("_FresnelFactor", FresnelFactor);
                block.SetColor("_FresnelColor", FresnelColor.gamma);
                block.SetFloat("_FresnelAlpha", FresnelAlpha);
                block.SetColor("_FresnelInsideColor", FresnelInsideColor.gamma);
                block.SetFloat("_FresnelInsideAlpha", FresnelInsideAlpha);
                renderer.SetPropertyBlock(block);
            }
        }
    }
}