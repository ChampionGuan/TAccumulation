using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Game
{
    /// <summary>
    /// 音乐播放器管理类
    /// </summary>
    [XLua.LuaCallCSharp]
    public class MusicPlayerMgr : Singleton<MusicPlayerMgr>
    {
        /// <summary>
        /// 当前播放的音乐EventName
        /// </summary>
        private string m_CurEventName;

        /// <summary>
        /// 当前播放的音乐StateName
        /// </summary>
        private string m_CurStateName;

        /// <summary>
        /// 当前播放的音乐StateGroupName
        /// </summary>
        private string m_CurStateGroupName;

        /// <summary>
        /// 当前播放模式
        /// </summary>
        private PlayMode m_CurPlayMode = PlayMode.Single;

        /// <summary>
        /// 当前播放列表
        /// </summary>
        private List<MusicListData> m_CurMusicList = new List<MusicListData>();

        /// <summary>
        /// 程序需要通过Seek控制单曲循环的EventName
        /// </summary>
        private List<string> m_HaveExitNameList = new List<string>();

        /// <summary>
        /// 音乐播放完成事件
        /// </summary>
        private const string EVENT_MUSIC_COMPLETE = "EVENT_MUSIC_COMPLETE";

        /// <summary>
        /// 初始化音乐播放器
        /// </summary>
        public void Init()
        {
            base.Init();
        }

        /// <summary>
        /// 重置音乐播放器
        /// </summary>
        public void Reset()
        {
            Stop();
        }

        /// <summary>
        /// 清理操作
        /// </summary>
        public void UnInit()
        {
            base.UnInit();
            Reset();
        }

        /// <summary>
        /// 停止背景音乐
        /// </summary>
        public void Stop()
        {
            m_CurEventName = null;
            m_CurStateName = null;
            m_CurStateGroupName = null;
            WwiseManager.Instance.StopMusic();
        }

        /// <summary>
        /// 增加播放列表数据
        /// </summary>
        /// <param name="eventName">eventName</param>
        /// <param name="stateName">stateName</param>
        /// <param name="stateGroupName">stateGroupName</param>
        public void AddPlayMusicData(string eventName, string stateName, string stateGroupName)
        {
            MusicListData temp = new MusicListData(eventName, stateName, stateGroupName);
            m_CurMusicList.Add(temp);
        }

        /// <summary>
        /// 设置播放列表播放模式
        /// </summary>
        /// <param name="playMode">播放模式</param>
        public void SetPlayMode(PlayMode playMode)
        {
            m_CurPlayMode = playMode;
        }

        /// <summary>
        ///设置需要检查的EventName
        /// </summary>
        /// <param name="eventName">eventName</param>
        public void AddExitEventNameList(string eventName)
        {
            m_HaveExitNameList.Add(eventName);
        }

        /// <summary>
        /// 清理播放列表
        /// </summary>
        public void ClearMusicList()
        {
            m_CurMusicList.Clear();
        }

        /// <summary>
        /// 清理需要檢查的EventName
        /// </summary>
        public void ClearExitEventNameList()
        {
            m_HaveExitNameList.Clear();
        }

        /// <summary>
        /// 获取当前播放的eventName
        /// </summary>
        /// <returns>当前播放的eventName</returns>
        public string CurPlayEventName
        {
            get => m_CurEventName;
        }

        /// <summary>
        /// 获取当前播放的stateName
        /// </summary>
        /// <returns>stateName</returns>
        public string CurPlayStateName
        {
            get => m_CurStateName;
        }

        /// <summary>
        /// 播放背景音乐供外部调用
        /// </summary>
        /// <param name="eventName"></param>
        /// <param name="stateName"></param>
        /// <param name="stateGroupName"></param>
        /// <param name="isReset">是否重置播放</param>
        public void Play(string eventName, string stateName, string stateGroupName, bool isReset = false)
        {
            ExePlay(eventName, stateName, stateGroupName, isReset);
        }

        /// <summary>
        /// 播放音乐
        /// </summary>
        /// <param name="eventName">eventName</param>
        /// <param name="stateName">stateName</param>
        /// <param name="stateGroupName">stateGroupName</param>
        /// <param name="isReset">是否重置播放</param>
        private void ExePlay(string eventName, string stateName, string stateGroupName, bool isReset)
        {
            bool isLoadBnk = false;
            if (string.IsNullOrEmpty(eventName))
            {
                eventName = m_CurEventName;
                stateName = m_CurStateName;
                stateGroupName = m_CurStateGroupName;
            }

            //播放前判断 是否是同一首音乐
            if (m_CurEventName != eventName || m_CurStateName != stateName || m_CurStateGroupName != stateGroupName ||
                isReset)
            {
                if (m_CurEventName != eventName)
                {
                    if (!CheckEventNameIsExit(m_CurEventName))
                    {
                        WwiseManager.Instance.StopMusic();
                    }
                    WwiseManager.Instance.LoadBankWithEventName(eventName);
                    isLoadBnk = true;
                    WwiseManager.Instance.PlayMusic(eventName, OnComplete);
                }

                if (!string.IsNullOrEmpty(stateName) && !string.IsNullOrEmpty(stateGroupName))
                {
                    if (!isLoadBnk)
                    {
                        WwiseManager.Instance.LoadBankWithEventName(eventName);
                    }

                    if (CheckEventNameIsExit(eventName))
                    {
                        WwiseManager.Instance.SeekOnEvent(eventName, 0, null, WwiseManager.Instance.PlayingMusicId);
                    }

                    WwiseManager.Instance.SetState(stateGroupName, stateName);
                }

                m_CurEventName = eventName;
                m_CurStateName = stateName;
                m_CurStateGroupName = stateGroupName;
            }
        }

        /// <summary>
        /// 播放完成回调 Exit和EndOf 会触发
        /// </summary>
        /// <param name="eventName">eventName</param>
        private void OnComplete(string eventName, uint playingId)
        {
            if (!GameMgr.IsExit && Application.isPlaying && CheckEventNameIsExit(eventName) && eventName == m_CurEventName)
            {
                EventMgr.Dispatch(EVENT_MUSIC_COMPLETE, m_CurStateName);
                if (m_CurPlayMode == PlayMode.Single)
                {
                    Play(m_CurEventName, m_CurStateName, m_CurStateGroupName, true);
                }
                else
                {
                    PlayNext();
                }
            }
        }

        /// <summary>
        /// 播放下一首音乐
        /// </summary>
        private void PlayNext()
        {
            int curPlayIdx = GetCurPlayIdx();
            if (curPlayIdx == -1)
            {
                Play(m_CurEventName, m_CurStateName, m_CurStateGroupName, true);
                return;
            }

            int nextIdx = curPlayIdx + 1;
            if (nextIdx >= m_CurMusicList.Count)
            {
                nextIdx = 0;
            }

            MusicListData musicData = m_CurMusicList[nextIdx];
            Play(musicData.eventName, musicData.stateName, musicData.stateGroupName, true);
        }

        /// <summary>
        /// 检查eventName是否需要关心Exit事件
        /// </summary>
        /// <param name="eventName">eventName</param>
        /// <returns></returns>
        private bool CheckEventNameIsExit(string eventName)
        {
            for (int i = 0; i < m_HaveExitNameList.Count; i++)
            {
                var tempEventName = m_HaveExitNameList[i];
                if (tempEventName == eventName)
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// 获取当前播放音乐的Idx
        /// </summary>
        /// <returns>Idx -1为当前播放列表没找到正在播放的EventName</returns>
        private int GetCurPlayIdx()
        {
            if (m_CurMusicList.Count <= 0)
            {
                return -1;
            }

            for (int i = 0; i < m_CurMusicList.Count; i++)
            {
                var tempMusicData = m_CurMusicList[i];
                if (tempMusicData.stateName == m_CurStateName)
                {
                    return i;
                }
            }

            return -1;
        }

        /// <summary>
        /// 播放模式
        /// </summary>
        public enum PlayMode
        {
            /// <summary>
            /// 顺序播放
            /// </summary>
            Sequence = 0,

            /// <summary>
            /// 随机播放
            /// </summary>
            Rand = 1,

            /// <summary>
            /// 单曲循环
            /// </summary>
            Single = 2,
        }

        /// <summary>
        /// 播放列表数据
        /// </summary>
        private struct MusicListData
        {
            public string eventName;
            public string stateName;
            public string stateGroupName;

            public MusicListData(string _eventName, string _stateName, string _stateGroupName)
            {
                eventName = _eventName;
                stateName = _stateName;
                stateGroupName = _stateGroupName;
            }
        }
    }
}