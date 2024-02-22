using System;
using System.Collections;
using PapeGames.X3;
using ParadoxNotion;
using ResourcesPacker.Runtime;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;
using System.Collections.Generic;
using Object = System.Object;

namespace X3Game.AutoColor
{
    [XLua.LuaCallCSharp]
    public class AutoColorTool : Singleton<AutoColorTool>
    {
        private ComputeShader shader;
        private Texture backgroundTexture;
        public bool isGpuReadback = true;
        private bool isDeviceSupportGpuReadback = true;
        private Color finalColor;
        //空数据填充用
        private List<uint> zeroData1; 
        private List<uint> zeroData2;
        private uint[] resultData;
        // public float finalStrength;
        private bool isReady;
        
        public enum AutoColorAdaptationMode
        {
            Progressive,
            Instant
        }

        public enum AutoColorMeteringMaskMode
        {
            Procedural,
            Textural
        }


        //private ComputeBuffer constDataBuffer;

        private int mainKernel;
        private int updateKernel;
        private int iterationKernel, iterationKernel2;
        private bool isFirst = true;

        private uint threadGroupSizeX;
        private uint threadGroupSizeY;
        //private ComputeBuffer modifiableDataBuffer;
        private ComputeBuffer iterationDataBuffer, iterationDataBuffer2;
        //AutoColorData autoColor = new AutoColorData();
        private int texSizeX, texSizeY, dataSizeX, dataSizeY, dataSizeX_2, dataSizeY_2;
        public void SetTexture(Texture targetTexture, int width, int height)
        {
            backgroundTexture = targetTexture;
            if (LoadComputeShader() && backgroundTexture != null)
            {
                OnCameraSetup();
                isReady = true;
            }
            else
            {
                isReady = false;
            }

            if (isReady)
            {
                texSizeX = width;
                texSizeY = height;
                dataSizeX = GetGroupCount(width, threadGroupSizeX);
                dataSizeY = GetGroupCount(height, threadGroupSizeY);
                dataSizeX_2 = GetGroupCount(dataSizeX, threadGroupSizeX);
                dataSizeY_2 = GetGroupCount(dataSizeY, threadGroupSizeY);
                if(iterationDataBuffer != null)
                    iterationDataBuffer.Dispose();
                if(iterationDataBuffer2 != null)
                    iterationDataBuffer2.Dispose();
                iterationDataBuffer = new ComputeBuffer(dataSizeX * dataSizeY, sizeof(uint) * 3);
                X3Debug.LogFormat("Texture Size:{0}. {1}Buffer Size1:{2},{3},Buffer Size2:{4},{5}", texSizeX, texSizeY,dataSizeX,dataSizeY,dataSizeX_2,dataSizeY_2);
                //Debug.LogFormat("Buffer Size1:{0}. {1}", dataSizeX, dataSizeY);
                iterationDataBuffer2 = new ComputeBuffer(dataSizeX_2 * dataSizeY_2, sizeof(uint) * 3);
                //Debug.LogFormat("Buffer Size2:{0}. {1}", dataSizeX_2, dataSizeY_2);
                /*
                if (constDataBuffer == null)
                    constDataBuffer = new ComputeBuffer(1, sizeof(int) * 3 + sizeof(float) * 7 + sizeof(uint) * 2);
                if(modifiableDataBuffer == null)
                    modifiableDataBuffer = new ComputeBuffer(1, sizeof(uint) * 2 + sizeof(uint) * 4 + sizeof(float) * 2);
                */
                int zeroSize1 = 3 * dataSizeX * dataSizeY;
                int zeroSize2 = 3 * dataSizeY_2 * dataSizeX_2;
                if (zeroData1 == null)
                {
                    zeroData1 = new List<uint>(zeroSize1);
                    for(int i = 0; i < zeroSize1; i++)
                        zeroData1.Add(0);
                }
                else if(zeroData1.Count != zeroSize1)
                {
                    zeroData1.Clear();
                    for(int i = 0; i < zeroSize1; i++)
                        zeroData1.Add(0);
                }
                if (zeroData2 == null)
                {
                    zeroData2 = new List<uint>(zeroSize2);
                    for(int i = 0; i < zeroSize2; i++)
                        zeroData2.Add(0);
                }
                else if(zeroData2.Count != zeroSize2)
                {
                    zeroData2.Clear();
                    for(int i = 0; i < zeroSize2; i++)
                        zeroData2.Add(0);
                }
                if (isGpuReadback && isDeviceSupportGpuReadback) //如果设备不支持GPU异步回读 则使用传统方式
                {
                    if(resultData == null || resultData.Length != 3 * dataSizeY_2 * dataSizeX_2)
                        resultData = new uint[3 * dataSizeY_2 * dataSizeX_2];
                }
            }
        }
        //异步完成颜色检测，目前需要三帧，实时进行检测时异步节约性能
        public void DoColorDetectionAsync()
        {
            if (isReady && stepCount == 1)
                CoroutineProxy.StartCoroutine(UpdateColor());
        }
        //当帧内完成颜色检测
        public void DoColorDetectionSync()
        {
            if (isReady) 
                Execute(false);
        }
        public Color GetAutoColor()
        {
            return finalColor;
        }

        private IEnumerator UpdateColor()
        {
            Execute();
            yield return null;
            Execute();
            yield return null;
            Execute();
        }
        
    
        protected override void Init()
        {
            shader = (ComputeShader)Res.Load("Assets/Build/Res/SourceRes/Shader/Beautycam/AutoColor.compute", Res.AutoReleaseMode.None);
            if (shader == null)
                X3Debug.Log("Load AutoColor Fail");
        }
        protected override void UnInit()
        {
            if (shader != null)
                Res.Unload(shader);
            if (isReady)
            {
                iterationDataBuffer.Dispose();
                iterationDataBuffer2.Dispose();
                //constDataBuffer.Dispose();
                //modifiableDataBuffer.Dispose();
                zeroData1 = null;
                zeroData2 = null;
                resultData = null;
                backgroundTexture = null;
            }
        }
        
        int stepCount = 1;

        private void Execute(bool isStepPerFrame = true)
        {
            if (isStepPerFrame)
            {
                switch (stepCount)
                {
                    case 1:
                        Step1();
                        stepCount++;
                        break;
                    case 2:
                        Step2();
                        stepCount++;
                        break;
                    case 3:
                        Step3();
                        stepCount = 1;
                        break;
                    default:
                        break;
                }
            }
            else
            {
                Step1();
                Step2();
                Step3();
            }

            //初始化
            void Step1()
            {
                iterationDataBuffer.SetData(zeroData1); //暂时每一帧都去清 但是可以几帧了再去清理的
                //第一次迭代 在gpu上计算
                //texSizeX = backgroundTexture.width;
                //texSizeY = backgroundTexture.height;
                //dataSizeX = GetGroupCount(backgroundTexture.width, threadGroupSizeX);
                //dataSizeY = GetGroupCount(backgroundTexture.height, threadGroupSizeY);

                shader.SetBuffer(iterationKernel, ShaderParams.IterationData, iterationDataBuffer);
                shader.SetTexture(iterationKernel, ShaderParams.AutoColorTarget, backgroundTexture);
                shader.SetInt(ShaderParams.IterationScreenSize_X, texSizeX);
                shader.SetInt(ShaderParams.IterationScreenSize_Y, texSizeY);
                shader.Dispatch(iterationKernel, dataSizeX, dataSizeY, 1);
                //debug
                // uint[] resData1 = new uint[3 * dataSizeX * dataSizeY];
                // iterationDataBuffer.GetData(resData1);
            }

            void Step2()
            {
                //第二次迭代 仍然在GPU上
                //dataSizeX_2 = GetGroupCount(dataSizeX, threadGroupSizeX);
                //dataSizeY_2 = GetGroupCount(dataSizeY, threadGroupSizeY);
                iterationDataBuffer2.SetData(zeroData2); //暂时每一帧都去清 但是可以几帧了再去清理的

                shader.SetBuffer(iterationKernel2, ShaderParams.IterationData2, iterationDataBuffer2);
                shader.SetBuffer(iterationKernel2, ShaderParams.IterationData, iterationDataBuffer);

                shader.SetInt(ShaderParams.IterationScreenSize_X, dataSizeX);
                shader.SetInt(ShaderParams.IterationScreenSize_Y, dataSizeY);

                shader.SetInt(ShaderParams.dataSizeX, dataSizeX_2);
                shader.SetInt(ShaderParams.dataSizeY, dataSizeY_2);
                shader.Dispatch(iterationKernel2, dataSizeX_2, dataSizeY_2, 1);
            }

            void Step3()
            {
                //第三步直接在cpu上进行计算 16*32的线程在gpu上跑也不是很划算 

                //
                if (isGpuReadback && isDeviceSupportGpuReadback) //如果设备不支持GPU异步回读 则使用传统方式
                {

                    AsyncGPUReadback.Request(iterationDataBuffer2, OnGetGpuRequest);

                    void OnGetGpuRequest(AsyncGPUReadbackRequest request)
                    {
                        if (request.hasError)
                        {
                            isDeviceSupportGpuReadback = false;
                            X3Debug.Log("当前设备不支持GPU异步回读！");
                            return;
                        }

                        NativeArray<uint> datas = request.GetData<uint>();
                        for (int i = 0; i < dataSizeY_2 * dataSizeX_2; i++) //
                        {
                            finalColor.r += (float)datas[3 * i];
                            finalColor.g += (float)datas[3 * i + 1];
                            finalColor.b += (float)datas[3 * i + 2];
                        }

                        int pixelCount = texSizeX * texSizeY;
                        finalColor.r /= (255 * pixelCount);
                        finalColor.g /= (255 * pixelCount);
                        finalColor.b /= (255 * pixelCount);
                    }

                }
                else
                {
                    iterationDataBuffer2.GetData(resultData);
                    for (int i = 0; i < dataSizeY_2 * dataSizeX_2; i++) //
                    {
                        finalColor.r += (float)resultData[3 * i];
                        finalColor.g += (float)resultData[3 * i + 1];
                        finalColor.b += (float)resultData[3 * i + 2];
                    }

                    int pixelCount = texSizeX * texSizeY;
                    finalColor.r /= (255 * pixelCount);
                    finalColor.g /= (255 * pixelCount);
                    finalColor.b /= (255 * pixelCount);
                }
            }
        }

        bool LoadComputeShader()
        {
            if (shader != null) return true;
            return false;
        }

        int GetGroupCount(int textureDimension, uint groupSize)
        {
            return Mathf.CeilToInt((textureDimension + groupSize - 1) / groupSize);
        }

        void OnCameraSetup()
        {
            mainKernel = shader.FindKernel("AutoExposure");
            updateKernel = shader.FindKernel("UpdateTargetLum");
            iterationKernel = shader.FindKernel("AutoColorIteration");
            iterationKernel2 = shader.FindKernel("AutoColorIteration2");
            shader.GetKernelThreadGroupSizes(iterationKernel, out threadGroupSizeX, out threadGroupSizeY, out _);
        }

        struct ConstantData
        {
            public ConstantData(
                float evMin,
                float evMax,
                float evCompensation,
                int adaptationMode,
                float darkToLightSpeed,
                float lightToDarkSpeed,
                float deltaTime,
                uint screenSizeX,
                uint screenSizeY,
                int isFirstFrame,
                int meteringMaskMode,
                float meteringProceduralFalloff
            )
            {
                this.evMin = evMin;
                this.evMax = evMax;
                this.evCompensation = evCompensation;
                this.adaptationMode = adaptationMode;
                this.DarkToLightSpeed = darkToLightSpeed;
                this.LightToDarkSpeed = lightToDarkSpeed;
                this.deltaTime = deltaTime;
                this.screenSizeX = screenSizeX;
                this.screenSizeY = screenSizeY;
                this.isFirstFrame = isFirstFrame;
                this.meteringMaskMode = meteringMaskMode;
                this.meteringProceduralFalloff = meteringProceduralFalloff;
            }

            public float evMin;
            public float evMax;
            public float evCompensation;
            public int adaptationMode;
            public float DarkToLightSpeed;
            public float LightToDarkSpeed;
            public float deltaTime;
            public uint screenSizeX;
            public uint screenSizeY;
            public int isFirstFrame;
            public int meteringMaskMode;
            public float meteringProceduralFalloff;
        };

        private static class ShaderParams
        {
            //  public static int MeteringMaskTexture = Shader.PropertyToID("MeteringMaskTexture");
            public static int Constants = Shader.PropertyToID("Constants");
            public static int Data = Shader.PropertyToID("Data");
            public static int IterationData = Shader.PropertyToID("iterationData");
            public static int IterationData2 = Shader.PropertyToID("iterationData2");
            public static int AutoColorTarget = Shader.PropertyToID("_AutoColorTarget");
            public static int IterationScreenSize_X = Shader.PropertyToID("IterationScreenSize_X");
            public static int IterationScreenSize_Y = Shader.PropertyToID("IterationScreenSize_Y");
            public static int dataSizeX = Shader.PropertyToID("dataSizeX");
            public static int dataSizeY = Shader.PropertyToID("dataSizeY");

        }
    }
    [Serializable]
    public class AutoColorData
    {
        public AutoColorTool.AutoColorAdaptationMode adaptationMode;
        public float evMin=0, evMax=12, evCompensation=0;
        public float darkToLightSpeed=3, lightToDarkSpeed=1;
        public float meteringProceduralFalloff=2;
        public TextureCurve compensationCurveParameter;
        public AutoColorTool.AutoColorMeteringMaskMode meteringMaskMode = AutoColorTool.AutoColorMeteringMaskMode.Procedural;
        public Texture meteringMaskTexture;
    }
}




