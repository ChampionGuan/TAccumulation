using System;
using PapeGames.X3;
using PapeGames.X3UI;
using UnityEngine;
using UnityEngine.UI;

namespace X3Game
{
    [ExecuteInEditMode]
    public class UIAlphaMaskForAtlas : MonoBehaviour
    {
        /// <summary>
        /// Mask图
        /// </summary>
        [SerializeField] Sprite SpriteMask = null;

        int alphaMaskVectorID1 = Shader.PropertyToID("_uvRectSprite");
        int alphaMaskTextureID = Shader.PropertyToID("_AlphaTex");
        private X3Image m_Image;
        private int m_InsId;


        private void Awake()
        {
            m_Image = GetComponent<X3Image>();
            if(m_Image!=null)
                m_InsId = m_Image.GetInstanceID();
        }


        // Use this for initialization
        void OnEnable()
        {
            Refresh();
            UISystem.OnImageSpriteChanged += OnSpriteChange;
        }

        private void OnDisable()
        {
            UISystem.OnImageSpriteChanged -= OnSpriteChange;
        }

        void OnSpriteChange(X3Image img, Sprite sp)
        {
            if (img != null && img == m_Image)
            {
                Refresh();
            }
        }

        void Refresh()
        {
            if (SpriteMask == null || m_Image == null || m_Image.sprite == null)
                return;

            Vector4 usingSpriteUV = UnityEngine.Sprites.DataUtility.GetOuterUV(m_Image.sprite);
            
            usingSpriteUV.z = 1 / (usingSpriteUV.z - usingSpriteUV.x);
            usingSpriteUV.w = 1 / (usingSpriteUV.w - usingSpriteUV.y);
            Material m = m_Image.materialForRendering;
            if (Application.isPlaying)
            {
                var copiedMat = MaskCopiedMaterialProvider.GetCopiedMaterial(m_Image,false);
                if (copiedMat != null && copiedMat != m)
                {
                    m_Image.material = copiedMat;
                    m = copiedMat;
                }
            }
            m.SetTexture(alphaMaskTextureID, SpriteMask.texture);
            m.SetVector(alphaMaskVectorID1, usingSpriteUV);
            
        }

        private void OnDestroy()
        {
            MaskCopiedMaterialProvider.EraseCopiedMaterials(m_InsId);
        }
#if UNITY_EDITOR
        private void OnValidate()
        {
            Refresh();
        }
#endif
    }
}