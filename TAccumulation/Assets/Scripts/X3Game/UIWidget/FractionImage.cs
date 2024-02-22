using System;
using System.Collections.Generic;
using PapeGames.X3;
#if UNITY_EDITOR
using Unity.Mathematics;
using UnityEditor;
#endif
using UnityEngine;
using PapeGames.X3UI;

namespace X3Game
{
    [Serializable]
    public class FractionThemeData
    {
        public bool IsFoldout = false;
        public int Theme;
        public string ThemePath;
        public List<FractionImageData> ImageDatas = new List<FractionImageData>(10);
    }

    [Serializable]
    public class FractionImageData
    {
        public int Index;
        public Vector4 Field;

        public Rect GetRect()
        {
            return new Rect(Field.x, Field.y, Field.z, Field.w);
        }

        //动态设置的
        [NonSerialized] public Sprite Texture;

        public FractionImageData()
        {
            this.Index = 0;
            this.Field = Vector4.zero;
        }

        public FractionImageData(int index, Vector4 field)
        {
            this.Index = index;
            this.Field = field;
        }
    }

    [RequireComponent(typeof(X3Image))]
    [DisallowMultipleComponent]
    public class FractionImage : MonoBehaviour
    {
        [SerializeField] private X3Image m_Image;
        [SerializeField] private List<FractionThemeData> m_ThemeDatas = new List<FractionThemeData>(5);
        private readonly Vector2 m_Pivot = new Vector2(0.5f, 0.5f);
        private RectTransform m_RectTransform;
        private static Dictionary<string, Texture2D> s_BigTexture = new Dictionary<string, Texture2D>(5);

        public void SetIdx(int theme, int index)
        {
            var isFind = false;
            foreach (var imageData in m_ThemeDatas)
            {
                if (theme == imageData.Theme)
                {
                    foreach (var data in imageData.ImageDatas)
                    {
                        if (data.Index == index)
                        {
                            SetImageData(imageData.ThemePath, data);
                            isFind = true;
                            break;
                        }
                    }

                    break;
                }
            }

            if (!isFind)
            {
                LogProxy.LogErrorFormat("找不到对应的主题{0}和索引{1}", theme, index);
            }
        }

        public void Clear(int theme)
        {
            string themePath = null;
            foreach (var imageData in m_ThemeDatas)
            {
                if (theme == imageData.Theme)
                {
                    foreach (var data in imageData.ImageDatas)
                    {
                        if (data.Texture != null)
                        {
                            data.Texture = null;
                        }
                    }

                    themePath = imageData.ThemePath;
                    break;
                }
            }

            if (!string.IsNullOrEmpty(themePath))
            {
                if (s_BigTexture.TryGetValue(themePath, out Texture2D texture))
                {
                    Res.Unload(texture);
                    s_BigTexture.Remove(themePath);
                }
            }
        }

        public void SetImageData(string themePath, FractionImageData imageData)
        {
            if (!s_BigTexture.TryGetValue(themePath, out Texture2D texture))
            {
                texture = Res.Load<Texture2D>(themePath, Res.AutoReleaseMode.None);
                s_BigTexture.Add(themePath, texture);
            }

            if (texture == null)
            {
                LogProxy.LogError("[SetImageData] image is null.");
                return;
            }

            if (imageData.Texture == null)
            {
                imageData.Texture = Sprite.Create(texture, imageData.GetRect(), m_Pivot);
            }

            UIUtility.SetImage(m_Image, imageData.Texture);
        }

        public Vector2 GetRectSize()
        {
            if (m_RectTransform == null)
            {
                m_RectTransform = GetComponent<RectTransform>();
            }

            return m_RectTransform.sizeDelta;
        }

#if UNITY_EDITOR
        public void RandomGenAllDataEditor()
        {
            m_ThemeDatas.Clear();
            var size = GetRectSize();
            for (int i = 0; i < 5; i++)
            {
                var themeData = new FractionThemeData();
                themeData.Theme = i + 1;
                themeData.ThemePath =
                    string.Format("Assets/Build/Res/GameObjectRes/UI/UIDynamicTexture/B2Loading/b2_loading_bg0{0}.png",
                        i + 1);
                themeData.ImageDatas = new List<FractionImageData>();
                for (int j = 0; j < 10; j++)
                {
                    var imageData = new FractionImageData();
                    imageData.Index = j + 1;
                    imageData.Field = new Vector4(j, j, size.x, size.y);
                    themeData.ImageDatas.Add(imageData);
                }

                m_ThemeDatas.Add(themeData);
            }
        }

        public void SetIdxEditor(int theme, int index)
        {
            foreach (var imageData in m_ThemeDatas)
            {
                if (theme == imageData.Theme)
                {
                    foreach (var data in imageData.ImageDatas)
                    {
                        if (data.Index == index)
                        {
                            var texture = AssetDatabase.LoadAssetAtPath<Texture2D>(imageData.ThemePath);
                            m_Image.sprite = Sprite.Create(texture, data.GetRect(), m_Pivot);
                            break;
                        }
                    }

                    break;
                }
            }
        }

        public void GenRandomImg(int theme, int index)
        {
            var rand = new System.Random();
        
            var size = GetRectSize();
            
            foreach (var imageData in m_ThemeDatas)
            {
                if (theme == imageData.Theme)
                {
                    foreach (var data in imageData.ImageDatas)
                    {
                        if (data.Index == index)
                        {
                            float width = size.x;
                            float height = size.y;
                            
                            var rawTexture = AssetDatabase.LoadAssetAtPath<Texture2D>(imageData.ThemePath);
                            float rawTextureWidth = rawTexture.width;
                            float rawTextureHeight = rawTexture.height;

                            float maxPosX = rawTextureWidth - width;
                            float maxPosY = rawTextureHeight - height;

                            float randomPosX = rand.Next(0, (int)maxPosX);
                            float randomPosY = rand.Next(0, (int)maxPosY);
                            
                            data.Field = new Vector4(randomPosX, randomPosY, width, height);
                            
                            break;
                        }
                    }
        
                    break;
                }
            }
        }
#endif
    }
}