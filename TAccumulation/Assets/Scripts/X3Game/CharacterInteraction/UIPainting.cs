using PapeGames.X3;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.UI;
using UnityEngine.VFX;
using Random = UnityEngine.Random;

namespace X3Game
{
    [RequireComponent(typeof(RawImage))]
    public class UIPainting : MonoBehaviour
    {
        public Color brushColor = Color.grey;
        public float lineWidth = 15.0f;
        public Color underlayColor = Color.white;
        public float underlayWidth = 20.0f;
        public Vector2 underlayOffset = Vector2.zero;
        private Shader m_BrushShader;
        private Material m_BrushMat;
        // private ComputeShader m_BrushShader;
        private RenderTexture m_Rt;
        private RenderTexture m_RtCopy;
        private RawImage m_Image;
        private Camera m_UICamera;
        private int m_FrameCout = 0;
        private bool m_IsDrawing = false;
        private Vector2 m_Begin;
        private Vector2 m_End;
        
        private VisualEffect m_VFX;
        // 采样绘制轨迹，生成位置贴图，设置 VFX 
        private Color[] m_Samples = new Color[m_PositionMapWidth * m_PositionMapHeight];
        private static int m_PositionMapWidth = 16;
        private static int m_PositionMapHeight = 16;
        private Texture2D m_PositionMap;

        // private static int s_ResultId;
        private static int s_StartId;
        private static int s_EndId;
        
        private static int s_BrushColorId;
        private static int s_UnderlayColorId;
        private static int s_LineWidthId;
        private static int s_UnderlayWidthId;
        private static int s_UnderlayOffsetId;
        private static int s_TextureSize;

        private void OnEnable()
        {
            m_Image = GetComponent<RawImage>();
            m_UICamera = RTUtility.GetUICamera(transform as RectTransform);
            m_PositionMap = new Texture2D(m_PositionMapWidth, m_PositionMapHeight, GraphicsFormat.R32G32B32A32_SFloat, 1, TextureCreationFlags.None);
            // m_BrushShader = Res.Load<ComputeShader>("Assets/Build/Res/SourceRes/Shader/Brush/Brush.compute");

            m_BrushShader = Res.Load<Shader>("Assets/Build/Res/SourceRes/Shader/Brush/UI-Brush.shader", Res.AutoReleaseMode.None);
            m_BrushMat = new Material(m_BrushShader);
            
            m_VFX = GetComponentInChildren<VisualEffect>();
            // s_ResultId = Shader.PropertyToID("_Result");
            s_StartId = Shader.PropertyToID("_Start");
            s_EndId = Shader.PropertyToID("_End");
            s_BrushColorId = Shader.PropertyToID("_Color");
            s_UnderlayColorId = Shader.PropertyToID("_UnderlayColor");
            s_LineWidthId = Shader.PropertyToID("_LineWidth");
            s_UnderlayWidthId = Shader.PropertyToID("_UnderlayWidth");
            s_UnderlayOffsetId = Shader.PropertyToID("_UnderOffset");
            s_TextureSize = Shader.PropertyToID("_TextureSize");
            
            SetRt();
        }
        
        private void OnDisable()
        {
            ClearRt();
            Res.Unload(m_BrushShader);
        }

        void SetRt()
        {
            RectTransform rectTransform = transform as RectTransform;;
            int width = Mathf.FloorToInt(rectTransform.rect.width * 0.5f);
            int height = Mathf.FloorToInt(rectTransform.rect.height * 0.5f);

            if (!m_Rt)
                m_Rt = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);

            if (!m_RtCopy)
                m_RtCopy = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);
            
            m_Rt.Create();
            m_RtCopy.Create();

            m_Image.texture = m_Rt;
        }

        void ClearRt()
        {
            if (m_Rt)
                RenderTexture.ReleaseTemporary(m_Rt);
            
            if(m_RtCopy)
                RenderTexture.ReleaseTemporary(m_RtCopy);
            
            m_Rt = null;
            m_RtCopy = null;
        }

        public void RePaint()
        {
            ClearRt();
            SetRt();
        }
        
        public void BeginPainting()
        {
            if (!m_IsDrawing)
            {
                m_IsDrawing = true;
                m_FrameCout = 0;
                
                if(underlayColor.a >= brushColor.a)
                    underlayColor.a = brushColor.a * 0.99f; // 特殊要求，底层的 alpha 值需要必须小于顶层的 alpha 值
                
                if (m_VFX)
                {
                    var camTrans = CameraUtility.MainCamera.transform;
                    var vfxTrans = m_VFX.transform;
                    vfxTrans.parent = camTrans;
                    vfxTrans.position = camTrans.position;
                    vfxTrans.rotation = Quaternion.identity;
                    vfxTrans.localScale = Vector3.one;
                    m_VFX.gameObject.layer = LayerMask.NameToLayer("Default");
                    m_VFX.Reinit();
                    
                    for (int i = 0; i < m_PositionMapWidth; i++)
                    {
                        for (int j = 0; j < m_PositionMapHeight; j++)
                        {
                            m_Samples[j * m_PositionMapWidth + i] = Color.black;
                        }
                    }
                
                    m_PositionMap.SetPixels(m_Samples);
                    m_PositionMap.Apply();
                }
            }
        }

        public void EndPainting()
        {
            if (m_IsDrawing)
            {
                m_IsDrawing = false;
                if (m_VFX)
                {
                    m_VFX.transform.parent = transform;
                }
            }
        }

        private void FixedUpdate()
        {
            if (m_IsDrawing)
            {
                Vector2 localPos;
                RectTransform rectTransform = transform as RectTransform;
                RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTransform, Input.mousePosition,
                    m_UICamera, out localPos);
                Vector2 offset = new Vector2(rectTransform.rect.width / 2, rectTransform.rect.height / 2);
                localPos += offset;
                if (m_FrameCout > 0)
                {
                    Graphics.Blit(m_Rt, m_RtCopy); // 上一帧的绘制结果
                    m_Begin = m_End;
                    m_BrushMat.SetVector(s_StartId, m_Begin);
                    m_End = localPos;
                    m_End.x /= rectTransform.rect.width;
                    m_End.y /= rectTransform.rect.height;
                    m_BrushMat.SetVector(s_EndId, m_End);
                    m_BrushMat.SetVector(s_BrushColorId, brushColor);
                    m_BrushMat.SetVector(s_UnderlayColorId, underlayColor);
                    m_BrushMat.SetVector(s_UnderlayOffsetId, underlayOffset);
                    m_BrushMat.SetFloat(s_LineWidthId, lineWidth);
                    m_BrushMat.SetFloat(s_UnderlayWidthId, underlayWidth);
                    m_BrushMat.SetVector(s_TextureSize, new Vector4(m_Rt.width, m_Rt.height,0,0));
                    Graphics.Blit(m_RtCopy, m_Rt, m_BrushMat);
                }
                else
                {
                    m_End = localPos;
                    m_End.x /= rectTransform.rect.width;
                    m_End.y /= rectTransform.rect.height;
                }

                if (m_VFX)
                {
                    Vector3 posTmp = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 1.0f);
                    Vector3 worldPos = CameraUtility.MainCamera.ScreenToWorldPoint(posTmp);
                    worldPos -= CameraUtility.MainCamera.transform.position;

                    if (m_FrameCout <= m_PositionMapWidth * m_PositionMapHeight - 1)
                    {
                        m_Samples[m_FrameCout].r = worldPos.x;
                        m_Samples[m_FrameCout].g = worldPos.y;
                        m_Samples[m_FrameCout].b = worldPos.z;
                    }
                    else
                    {
                        int index = Random.Range(0, m_PositionMapWidth * m_PositionMapHeight - 1);
                        m_Samples[index].r = worldPos.x;
                        m_Samples[index].g = worldPos.y;
                        m_Samples[index].b = worldPos.z;
                    }
                
                    m_PositionMap.SetPixels(m_Samples);
                    m_PositionMap.Apply();
                    
                    m_VFX.SetTexture("position map", m_PositionMap);
                }

                m_FrameCout++;
            }
        }
    }
}