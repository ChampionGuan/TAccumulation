using System;
using System.Threading.Tasks;
using UnityEngine;
using PapeGames.X3;
using X3Game.Platform;

namespace X3Game
{
    /// <summary>
    /// 吹气检测
    /// </summary>
    public class BlowChecker : MonoBehaviour
    {
        /// <summary>
        /// 检测音量
        /// </summary>
        public float Volume = 3;

        /// <summary>
        /// 连续帧数，最近FrameCount帧的音量都>=Volume才会调用OnBlow
        /// </summary>
        public int FrameCount = 10;

        /// <summary>
        /// 是否打印检测到的音量
        /// </summary>
        public bool IsDebugVolume;

        /// <summary>
        /// 是否在进行吹气动作中
        /// </summary>
        private bool m_IsBlowing;

        /// <summary>
        /// 开始吹气动作的回调
        /// </summary>
        public Action OnBlowStart;

        /// <summary>
        /// 停止吹气动作的回调
        /// </summary>
        public Action OnBlowStop;

        /// <summary>
        /// 吹气进度
        /// </summary>
        public Action<float> OnBlowProgress;

        /// <summary>
        /// 吹气检测成功后的回调
        /// </summary>
        public Action OnBlowSuccess;

        /// <summary>
        /// 保存录音的音频片段
        /// </summary>
        private AudioClip m_RecodingAudioClip;

        /// <summary>
        /// 缓存区大小
        /// </summary>
        private const int BUFFER_SIZE = 128;

        /// <summary>
        /// 音频数据缓存
        /// </summary>
        private float[] m_Buffer;

        /// <summary>
        /// 满足Volume大小的音频数据的计数器
        /// </summary>
        private int m_Counter;

        /// <summary>
        /// 是否正在吹气检测中
        /// </summary>
        private bool m_IsRecording;

        /// <summary>
        /// 当前录音的麦克风设备名
        /// </summary>
        private string curDeviceName;

        /// <summary>
        /// 当前设备音量
        /// </summary>
        private float m_deviceVolume = 0;

        public float DeviceVolume
        {
            get { return m_deviceVolume; }
        }

        public int Counter
        {
            get { return m_Counter; }
        }

        public bool IsRecording
        {
            get { return m_IsRecording; }
        }

        public int DevicesLength
        {
            get { return Microphone.devices.Length; }
        }

        private void Awake()
        {
            m_Buffer = new float[BUFFER_SIZE];
            X3Game.Platform.MicPuff.VolumeThreshold = Volume;
            X3Game.Platform.MicPuff.PuffFrameCountThreshold = FrameCount;
        }

        private void Update()
        {
            if (!m_IsRecording)
            {
                //没在检测 不处理了
                return;
            }

            m_deviceVolume = GetVolume();

            if (m_deviceVolume < Volume)
            {
                //计数器重置
                m_Counter = 0;

                if (m_IsBlowing)
                {
                    //停止了吹气动作
                    m_IsBlowing = false;
                    OnBlowStop?.Invoke();
                }

                return;
            }

            if (m_Counter == 0)
            {
                if (!m_IsBlowing)
                {
                    //开始了吹气动作
                    m_IsBlowing = true;
                    OnBlowStart?.Invoke();
                }
            }

            //增加计数器
            m_Counter++;
            if (m_Counter >= FrameCount)
            {
                //最近FrameCount帧的音量都满足条件了 调用回调 
                OnBlowSuccess?.Invoke();
                PapeGames.X3.X3Debug.Log($"BlowWin吹气检测成功，当前麦克风名:{curDeviceName}");

                //EndCheck();  不自动结束检测了 现在需要使用者手动调用EndCheck
                m_Counter = 0;
            }
            else
            {
                OnBlowProgress?.Invoke(m_Counter / FrameCount);
            }
        }

        private void OnDestroy()
        {
            EndCheck();
        }

        /// <summary>
        /// 开始吹气检测
        /// </summary>
        public void StartCheck()
        {
            X3Debug.Log($"C# StartCheck m_IsRecording={(m_IsRecording ? 1 : 0)}");
            if (!IsMicroExist())
            {
                X3Debug.LogError("Blow 没有找到设备麦克风");
                return;
            }

            if (m_IsRecording)
            {
                //检测中 不处理了
                return;
            }

            ExeStartCheck();
        }

        private async Task ExeStartCheck()
        {
            foreach (string device in Microphone.devices)
            {
                PapeGames.X3.X3Debug.Log($"设备麦克风名:{device}");
            }

            PFWwiseUtility.SetAudioSessionCategory((int)AVAudioSessionCategory.Record, 0, (int)AVAudioSessionMode.Default);

            curDeviceName = Microphone.devices[0];
            m_RecodingAudioClip = Microphone.Start(curDeviceName, true, 2, 44100);
            m_IsRecording = true;
            m_IsBlowing = false;
            X3Debug.Log($"BlowStart开始吹气检测，当前麦克风名:" + curDeviceName);
        }

        /// <summary>
        /// 检测当前设备是否有麦克风
        /// </summary>
        /// <returns></returns>
        private bool IsMicroExist()
        {
            return Microphone.devices.Length > 0;
        }

        /// <summary>
        /// 结束吹气检测
        /// </summary>
        public void EndCheck()
        {
            X3Debug.LogFormat("C# Blow EndCheck isRecording={0},curDeviceName={1}", m_IsRecording ? 1 : 0, curDeviceName);
            if (m_IsRecording)
            {
                m_IsRecording = false;

                m_Counter = 0;

                if (m_IsBlowing)
                {
                    m_IsBlowing = false;
                    OnBlowStop?.Invoke();
                }

                m_RecodingAudioClip = null;
                Array.Clear(m_Buffer, 0, m_Buffer.Length);
                Microphone.End(curDeviceName);
                X3Debug.LogFormat("BlowEnd结束吹气检测，当前麦克风名:{0}", curDeviceName);
                curDeviceName = null;
                PFWwiseUtility.ResetAudioSessionCategory();
            }
        }

        /// <summary>
        /// 获取当前帧音量
        /// </summary>
        private float GetVolume()
        {
            //取倒数的BufferSize个音频数据
            int offset = Microphone.GetPosition(curDeviceName) - (BUFFER_SIZE - 1);

            if (offset < 0)
            {
                X3Debug.Log("BlowGetVolume Offset is less 0! =" + offset);
                return 0;
            }

            Array.Clear(m_Buffer, 0, m_Buffer.Length);
            m_RecodingAudioClip.GetData(m_Buffer, offset);

            //找出最大值 视为当前帧音量
            float max = 0;
            for (int i = 0; i < m_Buffer.Length; i++)
            {
                float cur = m_Buffer[i];
                if (cur > max)
                {
                    max = cur;
                }

                if (max >= Volume)
                {
                    //符合条件 直接打断循环
                    break;
                }
            }

            //扩大100倍 否则太小了
            max *= 100;

            return max;
        }
    }
}