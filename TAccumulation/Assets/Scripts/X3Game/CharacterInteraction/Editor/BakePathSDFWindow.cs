using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using Unity.Collections;
using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.UI;

namespace X3Game
{
    public class BakePathSDFWindow : EditorWindow
    {
        public Texture2D sourceTex;

        [MenuItem("UI编辑器/FreeMotion/Bake Path SDF")]
        public static void ShowWindow()
        {
            GetWindow<BakePathSDFWindow>();
        }
        
        private void OnGUI()
        {
            sourceTex = (Texture2D)EditorGUILayout.ObjectField("Source Texture", sourceTex, typeof(Texture2D), false);
            if (GUILayout.Button("Bake"))
            {
                GenerateSDF();
            }
        }
        private static byte MaxDistance = 255;
        private void GenerateSDF()
        {
            if (sourceTex == null)
            {
                Debug.LogError("Source Texture is not found");
                return;
            }
            
            string root = Application.dataPath;
            string bakeSDFPath = EditorUtility.SaveFilePanelInProject("SDF saved path",
                "SDF.asset",
                "asset",
                "Please enter a file name to save the sdf to", root);

            var gen = new SDFGeneratorCore();
            var sdfTex = gen.CreateSDFTex(sourceTex);
            
            // 将距离场缩放到 128*128 上
            PathSDF sdfSO = ScriptableObject.CreateInstance<PathSDF>();
            int sdfWidth = 128, sdfHeight = 128;
            for (int j = 0; j < sdfHeight; j++)
            {
                for (int i = 0; i < sdfWidth; i++)
                {
                    float uvx = (float)i / sdfWidth;
                    float uvy = (float)j / sdfHeight;
                    float dis = sdfTex.GetPixelBilinear(uvx, uvy).r;
                    sdfSO.sdf[j * sdfWidth + i] = (byte)(Mathf.Clamp01(dis) * 255);
                }
            }
            
            // 将原图缩放到 16*16，得到曲线覆盖的格子，如果在绘图过程中经过了这些格子
            int samplesWidth = 16, samplesHeight = 16;
            byte samples = 0;

            var colors = sourceTex.GetPixels(5); // 512*512 的图片，mipmap 5 是一张 16*16 的图
            
            for (int j = 0; j < samplesHeight; j++)
            {
                for (int i = 0; i < samplesWidth; i++)
                {

                    float alpha = colors[j * samplesWidth + i].a;
                    if (alpha > 0)
                    {
                        sdfSO.samples[j * samplesWidth + i] = 1;
                        samples++;
                    }
                    else
                    {
                        sdfSO.samples[j * samplesWidth + i] = 0;
                    }
                }
            }

            
            sdfSO.samplesCount = samples;
            
            AssetDatabase.CreateAsset(sdfSO, bakeSDFPath);
            AssetDatabase.SaveAssets();
            // byte[] bytes = sdfTex.EncodeToPNG();
            // FileStream file = File.Open(bakeSDFPath, FileMode.Create);
            // BinaryWriter writer = new BinaryWriter(file);
            // writer.Write(bytes);
            // file.Close();
        }
    }
    
    public class SDFGeneratorCore
    {
        private const int MaxDistance = 2147483647;
        private enum Type
        {
            Object,
            Empty,
            None,
        }

        private struct Pixel
        {
            public Type type;
            public int dx;
            public int dy;
            public int sqrDistance;

            public Pixel(Type type, int dx, int dy)
            {
                this.type = type;
                this.dx = dx;
                this.dy = dy;
                sqrDistance = dx * dx + dy * dy;
            }
            public Pixel(Type type, int dx, int dy, int sqrDistance)
            {
                this.type = type;
                this.dx = dx;
                this.dy = dy;
                this.sqrDistance = sqrDistance;
            }
        }
        
        static Pixel _nonePixel = new Pixel(Type.None, 0, 0, MaxDistance);
        
        private struct TexData
        {
            private int sizeX,sizeY;
            public Pixel[,] pixels;
            public TexData(int x, int y)
            {
                pixels = new Pixel[x,y];
                sizeX = x - 1;
                sizeY = y - 1;
            }
            
            public ref Pixel GetPixel(int x, int y)
            {
                if (x < 0 || x > sizeX || y < 0 || y > sizeY)
                    return ref _nonePixel;
                else
                    return ref pixels[x, y];
            }
        }
        
        public Texture2D CreateSDFTex(Texture2D rawTex)
        {
            int width = rawTex.width;
            int height = rawTex.height;
            
            TexData data = new TexData(width, height);

            MarkRawData(ref data, rawTex, width, height);
            GenerateSDF(ref data, width, height);
            Texture2D newTex = new Texture2D(width, height, GraphicsFormat.R8_UNorm,0);
            WriteTex(newTex, ref data, width, height);
            return newTex;
        }
        
        void MarkRawData(ref TexData data, Texture2D tex, int width, int height)
        {
            for (int y = 0; y < height; y++)
            {
                for (int x = 0; x < width; x++)
                {
                    int value = (int)tex.GetPixel(x, y).a;
                    Pixel e = new Pixel(Type.Empty, 0, 0, MaxDistance);
                    Pixel o = new Pixel(Type.Object, 0, 0, MaxDistance);
                    data.pixels[x, y] = value == 1 ? o : e;
                }
            }
        }

        void ComparePixel(ref Pixel pixel, ref TexData data, int x, int y, int offsetX, int offsetY)
        {
            ref Pixel comparedPixel = ref data.GetPixel(x + offsetX, y + offsetY);
            
            if (comparedPixel.type == Type.None || (comparedPixel.type == pixel.type  && comparedPixel.sqrDistance == MaxDistance))
                return;

            int dx, dy;
            if (comparedPixel.type == pixel.type)
            {
                dx = comparedPixel.dx;
                dy = comparedPixel.dy;
            }
            else
            {
                dx = dy = 0;
            }
            
            Pixel tmp = new Pixel(pixel.type,dx + Mathf.Abs(offsetX),dy + Mathf.Abs(offsetY));

            if (pixel.sqrDistance > tmp.sqrDistance)
            {
                pixel = tmp;
            }
        }

        void ComparePixels(ref TexData data, int x, int y, int ox0, int oy0, int ox1, int oy1)
        {
            ref Pixel pixel = ref data.pixels[x, y];
            ComparePixel(ref pixel, ref data, x, y, ox0, oy0);
            ComparePixel(ref pixel, ref data, x, y, ox1, oy1);
        }
        
        void ComparePixels(ref TexData data, int x, int y, int ox0, int oy0, int ox1, int oy1, int ox2, int oy2)
        {
            ref Pixel pixel = ref data.pixels[x, y];
            ComparePixel(ref pixel, ref data, x, y, ox0, oy0);
            ComparePixel(ref pixel, ref data, x, y, ox1, oy1);
            ComparePixel(ref pixel, ref data, x, y, ox2, oy2);
        }
        
        void GenerateSDF(ref TexData data, int width, int height)
        {
            for (int y = 0; y < height; y++)
            {
                for (int x = 0; x < width; x++)
                {
                    ComparePixels(ref data, x, y, -1, 0, -1, -1, 0, -1);
                }

                for (int x = width-1; x >= 0 ; x--)
                {
                    ComparePixels(ref data, x, y, 1, -1, 1, 0);
                }
            }
            
            for (int y = height-1; y >= 0 ; y--)
            {
                for (int x = width-1; x >= 0 ; x--)
                {
                    ComparePixels(ref data, x, y, 1, 0, 1, 1, 0, 1);
                }

                for (int x = 0; x < width; x++)
                {
                    ComparePixels(ref data, x, y, -1, 1, -1, 0);
                }
            }
        }

        void WriteTex(Texture2D texture, ref TexData data, int width, int height)
        {
            NativeArray<byte> col = new NativeArray<byte>(width * height,Allocator.TempJob);
            float scale = height / 256f;
            for (int y = 0; y < height; y++)
            {
                for (int x = 0; x < width; x++)
                {
                    ref Pixel p = ref data.pixels[x, y];
                    float value = Mathf.Sqrt(p.sqrDistance) / scale;
                    byte v = (byte)(Mathf.Lerp(value, - value, (int)p.type) + 128);;
                    col[y * height + x] = v;
                }
            }
            texture.SetPixelData(col,0);
            col.Dispose();
        }
        
    }

}

