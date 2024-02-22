using PapeGames.X3;
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.U2D;
using PapeGames.X3UI;

namespace X3Game
{
    /// <summary>
    /// GIF动图组件
    /// </summary>
    [RequireComponent(typeof(X3Image))]
    [DisallowMultipleComponent]
    [AddComponentMenu("X3UI/Comp/GIFImage")]
    [HelpURL("https://papergames.feishu.cn/docx/doxcnTylF1WnbRx1t9vOixXHkWg")]
    public class GIFImage : MonoBehaviour
    {
        /// <summary>
        /// 播放状态
        /// </summary>
        public enum PlayState
        {
            /// <summary>
            /// 停止播放
            /// </summary>
            Stop,

            /// <summary>
            /// 首次播放延迟中
            /// </summary>
            FirstPlayDelay,

            /// <summary>
            /// 动图播放中
            /// </summary>
            Playing,

            /// <summary>
            /// 循环播放等待中
            /// </summary>
            LoopWaiting,

            /// <summary>
            /// 暂停播放
            /// </summary>
            Pause,
        }

        /// <summary>
        /// 缓存的Sprite数组，用于从SpriteAtlas中取图
        /// </summary>
        private static Sprite[] s_CachedSpriteArray;

        /// <summary>
        /// 缓存的Sprite及其名字的字典,避免排序时频繁调用sprite.name造成的GC Alloc
        /// </summary>
        private static Dictionary<Sprite, string> s_CachedSpriteNameDict;

        /// <summary>
        /// 目标Image组件
        /// </summary>
        private X3Image m_Image;

        /// <summary>
        /// 序列帧图片组
        /// </summary>
        [SerializeField]
        private List<Sprite> m_Sprites;

        /// <summary>
        /// 序列帧图片组名前缀
        /// </summary>
        [SerializeField] private string m_PrefixName;
        
        /// <summary>
        /// 某前缀名的序列帧图片组数量
        /// </summary>
        [SerializeField] private int m_PrefixNameCount;
        
        /// <summary>
        /// 序列帧图片数量
        /// </summary>
        public int SpriteCount
        {
            get
            {
                return m_Sprites.Count;
            }
        }

        /// <summary>
        /// 计时器
        /// </summary>
        private float m_Timer;

        /// <summary>
        /// 单张序列帧图片的持续时间
        /// </summary>
        private float m_SingleSpriteDuration;

        /// <summary>
        /// 当前显示的序列帧图片在序列帧图片组中的索引
        /// </summary>
        public int CurSpriteIndex
        {
            get;
            private set;
        }

        private int m_ShowingSpriteIndex;

        /// <summary>
        /// 上一个播放状态，用于恢复动图
        /// </summary>
        private PlayState m_PreState;

        /// <summary>
        /// 当前播放状态
        /// </summary>
        public PlayState CurState
        {
            get;
            private set;
        }

        /// <summary>
        /// 是否在Awake时播放
        /// </summary>
        public bool PlayOnAwake = true;

        /// <summary>
        /// 是否使用原序列帧图的尺寸
        /// </summary>
        public bool UseNativeSize = true;

        /// <summary>
        /// 动图总时长
        /// </summary>
        public float GIFTime = 0.5f;

        /// <summary>
        /// 每帧的时长
        /// </summary>
        // public Dictionary<int, float> perFrameTime;
        public float[] perFrameTime;

        /// <summary>
        /// 是否循环播放
        /// </summary>
        public bool IsLoop = true;

        /// <summary>
        /// 首次播放的延迟时长
        /// </summary>
        public float FirstPlayDelayTime;

        /// <summary>
        /// 循环播放的间隔时间
        /// </summary>
        public float LoopWaitTime;


        private void Awake()
        {
            m_Image = GetComponent<X3Image>();
            
            if (PlayOnAwake)
            {
                Play();
            }
        }

        private void Update()
        {

            switch (CurState)
            {
                //首次播放延迟
                case PlayState.FirstPlayDelay:

                    m_Timer += Time.deltaTime;
                    if (m_Timer >= FirstPlayDelayTime)
                    {
                        //延迟结束 转移到播放状态
                        CurState = PlayState.Playing;
                        m_Timer = 0;
                        CurSpriteIndex = 0;
                        m_ShowingSpriteIndex = CurSpriteIndex;
                    }

                    break;

                //播放中
                case PlayState.Playing:

                    m_Timer += Time.deltaTime;

                    if (m_Timer >= m_SingleSpriteDuration)
                    {
                        //当前序列帧图片的持续时间到了 切换到下一张
                        m_Timer = 0;
                        CurSpriteIndex++;
                        if(CurSpriteIndex < m_Sprites.Count) 
                            m_SingleSpriteDuration = GetDeltaTimeFromSpriteIndex(CurSpriteIndex);
                    }

                    if (CurSpriteIndex < m_Sprites.Count)
                    {
                        if (m_ShowingSpriteIndex != CurSpriteIndex)
                        {
                            //显示对应序列帧图片
                            m_Image.sprite = m_Sprites[CurSpriteIndex];
                            X3GameUIWidgetEntry.EventDelegate?.GIFImage_OnKeyFrame(this, this.GetInstanceID(), CurSpriteIndex);
                            m_ShowingSpriteIndex = CurSpriteIndex;
                        }
#if UNITY_EDITOR
                        //编辑器预览用
                        if (!Application.isPlaying)
                        {
                            UnityEditor.EditorUtility.SetDirty(m_Image);
                        }
#endif
                    }
                    else
                    {
                        //播放完毕了
                        m_Timer = 0;
                        CurSpriteIndex = 0;
                        m_ShowingSpriteIndex = CurSpriteIndex;
                        X3GameUIWidgetEntry.EventDelegate?.GIFImage_OnComplete(this, this.GetInstanceID());
                        if (IsLoop)
                        {
                            m_SingleSpriteDuration = GetDeltaTimeFromSpriteIndex(0);
                            //需要循环播放 转移到循环等待状态
                            CurState = PlayState.LoopWaiting;
                        }
                        else
                        {
                            //不需要循环播放 直接停止了
                            Stop();
                        }
                    }

                    break;

                //循环等待中
                case PlayState.LoopWaiting:

                    m_Timer += Time.deltaTime;
                    if (m_Timer >= LoopWaitTime)
                    {
                        //循环间隔等待结束 转移到播放状态
                        CurState = PlayState.Playing;
                        m_Timer = 0;
                    }

                    break;

            }
        }
        

        /// <summary>
        /// 设置当前显示的动图序列帧图片索引
        /// </summary>
        public void SetGIFSpriteIndex(int index)
        {
            if (index == 0)
            {
                X3GameUIWidgetEntry.EventDelegate?.GIFImage_OnBegin(this, this.GetInstanceID());
            }
            
            if (index >= SpriteCount)
            {
                X3GameUIWidgetEntry.EventDelegate?.GIFImage_OnComplete(this, this.GetInstanceID());
                return;
            }

            CurSpriteIndex = index;
            
            X3GameUIWidgetEntry.EventDelegate?.GIFImage_OnKeyFrame(this, this.GetInstanceID(), index);
            
            //显示对应序列帧图片
            m_Image.sprite = m_Sprites[CurSpriteIndex];
            
            m_ShowingSpriteIndex = CurSpriteIndex;
            m_Timer = 0;
        }
        
        /// <summary>
        /// 设置序列帧图片组,设置好后会自动播放
        /// </summary>
        public void SetSprites(List<Sprite> sprites)
        {
            if (sprites == null)
            {
                X3Debug.LogError(gameObject.name + "设置序列帧图片组失败，sprites参数为null");
                return;
            }

            m_Sprites = sprites;

            Stop();
            Play();
        }
        
        /// <summary>
        /// 以 gif 前缀名的形式设置序列帧图片组
        /// </summary>
        public void SetGIFPrefixName(string prefix, int count)
        {
            m_PrefixName = prefix;
            m_PrefixNameCount = count;

            if (prefix == null)
            {
                X3Debug.LogError(gameObject.name + "以前缀名的形式设置序列帧图片组失败，prefix参数为null");
                return;
            }

            SetSpritesFromPrefixName();
            
            Stop();
            Play();
        }

        private void SetSpritesFromPrefixName()
        {
            if (m_Sprites == null)
            {
                m_Sprites = new List<Sprite>(m_PrefixNameCount);
            }
            else
            {
                m_Sprites.Clear();
            }
            
            for (int i = 0; i < m_PrefixNameCount; i++)
            {
                //根据命名前缀和当前序号把序列帧散图的名字拼出来
                string spriteName = $"{m_PrefixName}_{string.Format("{0:000}", i + 1)}";
                Sprite sprite = UISystem.LocaleDelegate?.OnGetSprite(spriteName,gameObject);
                m_Sprites.Add(sprite);
            }
        }
        
        /// <summary>
        /// 以图片名的形式设置序列帧图片组
        /// </summary>
        public void SetSpriteNames(List<string> names)
        {
            if (names == null)
            {
                X3Debug.LogError(gameObject.name + "以图片名的形式设置序列帧图片组失败，names参数为null");
                return;
            }
            
            if (m_Sprites == null)
            {
                m_Sprites = new List<Sprite>(names.Count);
            }
            else
            {
                m_Sprites.Clear();
            }

            for (int i = 0; i < names.Count; i++)
            {
                Sprite sprite = UISystem.LocaleDelegate?.OnGetSprite(names[i], gameObject);
                m_Sprites.Add(sprite);
            }
            
            Stop();
            Play();
        }

        /// <summary>
        /// 以图集的形式设置序列帧图片组，适用于1个图集只有1组gif的情况,设置好后会自动播放
        /// </summary>
        public void SetSpriteAtlas(SpriteAtlas atlas)
        {
            if (atlas == null)
            {
                X3Debug.LogError(gameObject.name + "以图集的形式设置序列帧图片组失败，atlas参数为null");
                return;
            }

            if (s_CachedSpriteArray == null)
            {
                //初始化静态缓存容器
                s_CachedSpriteArray = new Sprite[atlas.spriteCount];
                s_CachedSpriteNameDict = new Dictionary<Sprite, string>(atlas.spriteCount);
            }


            if (s_CachedSpriteArray.Length < atlas.spriteCount)
            {
                //缓存数组长度不够 需要扩容
                Array.Resize(ref s_CachedSpriteArray, Mathf.Max(atlas.spriteCount, s_CachedSpriteArray.Length * 2));
            }
            
            if (m_Sprites == null)
            {
                m_Sprites = new List<Sprite>(atlas.spriteCount);
            }
            else
            {
                m_Sprites.Clear();
            }

            //从图集取图 放进缓存数组里

            atlas.GetSprites(s_CachedSpriteArray);



            //将缓存中的图放进序列帧图片组中
            for (int i = 0; i < atlas.spriteCount; i++)
            {
                m_Sprites.Add(s_CachedSpriteArray[i]);
            }

            //需要按名字排序 因为从图集里取出的图是按区域排序的
            m_Sprites.Sort((x, y) => {
                return GetSpriteName(x).CompareTo(GetSpriteName(y));
            });

            //清理缓存
            Array.Clear(s_CachedSpriteArray, 0, SpriteCount);
            s_CachedSpriteNameDict.Clear();

            Stop();
            Play();
        }

        /// <summary>
        /// 以图集的形式设置序列帧图片组，适用于1个图集有多组gif的情况，会根据gifNamePrefix和count把散图名字拼出来,设置好后会自动播放
        /// </summary>
        /// <param name="atlas">图集</param>
        /// <param name="gifNamePrefix">序列帧的命名前缀</param>
        /// <param name="count">序列帧数量</param>
        public void SetSpriteAtlas(SpriteAtlas atlas, string gifNamePrefix, int count)
        {
            if (atlas == null)
            {
                X3Debug.LogError(gameObject.name + "以图集的形式设置序列帧图片组失败，atlas参数为null");
                return;
            }

            if (m_Sprites == null)
            {
                m_Sprites = new List<Sprite>(atlas.spriteCount);
            }
            else
            {
                m_Sprites.Clear();
            }

            for (int i = 0; i < count; i++)
            {
                //根据命名前缀和当前序号把序列帧散图的名字拼出来
                string spriteName = $"{gifNamePrefix}_{string.Format("{0:000}", i + 1)}";
                Sprite sprite = UISystem.LocaleDelegate?.OnGetSprite(spriteName,gameObject);
                m_Sprites.Add(sprite);
            }

            Stop();
            Play();

        }

        /// <summary>
        /// 以大图的形式通过运行时分割（左下角为原点）设置序列帧图片组,设置好后会自动播放
        /// </summary>
        /// <param name="tex">序列帧散图合成的大图</param>
        /// <param name="row">行数</param>
        /// <param name="col">列数</param>
        /// <param name="count">序列帧散图总数</param>
        public void SetTexture2D(Texture2D tex, int row, int col, int count)
        {
            if (tex == null)
            {
                X3Debug.LogError(gameObject.name + "以大图的形式设置序列帧图片组失败，tex参数为null");
                return;
            }

            if (m_Sprites == null)
            {
                m_Sprites = new List<Sprite>(count);
            }
            else
            {
                m_Sprites.Clear();
            }

            //已获取的序列帧小图计数器
            int counter = 0;

            //单张小图宽度
            int width = tex.width / col;

            //单张小图高度
            int height = tex.height / row;

            //遍历小图格子
            for (int y = 0; y < col; y++)
            {
                for (int x = 0; x < row; x++)
                {
                    if (counter > count)
                    {
                        //可能出现小图没填满大图所有格子的情况，需要打断循环
                        break;
                    }

                    counter++;

                    int posX = x * width;
                    int posY = y * height;

                    Rect rect = new Rect(posX, posY, width, height);

                    Sprite sprite = Sprite.Create(tex, rect, new Vector2(0.5f, 0.5f));

                    m_Sprites.Add(sprite);
                }
            }


            Stop();
            Play();

        }

        /// <summary>
        /// 从缓存中获取Sprite名字
        /// </summary>
        private static string GetSpriteName(Sprite sprite)
        {
            if (!s_CachedSpriteNameDict.TryGetValue(sprite, out string name))
            {
                name = sprite.name;
                s_CachedSpriteNameDict.Add(sprite, name);
            }
            return name;
        }

        /// <summary>
        /// 是否可播放
        /// </summary>
        public bool CanPlay()
        {
            return (CurState == PlayState.Pause || CurState == PlayState.Stop) && ((m_Sprites != null && m_Sprites.Count > 1) || (!string.IsNullOrEmpty(m_PrefixName) && m_PrefixNameCount > 1));
        }

        /// <summary>
        /// 是否可停止
        /// </summary>
        public bool CanStop()
        {
            return CurState != PlayState.Stop;
        }

        /// <summary>
        /// 是否可暂停
        /// </summary>
        public bool CanPause()
        {
            return CurState == PlayState.FirstPlayDelay || CurState == PlayState.Playing || CurState == PlayState.LoopWaiting;
        }

        /// <summary>
        /// 是否可恢复
        /// </summary>
        public bool CanResume()
        {
            return CurState == PlayState.Pause;
        }

        /// <summary>
        /// 播放动图
        /// </summary>
        public void Play()
        {
            if (!CanPlay())
            {
                return;
            }

            if ((m_Sprites == null || m_Sprites.Count < 1) && !string.IsNullOrEmpty(m_PrefixName))
            {
                SetSpritesFromPrefixName();
            }
            
            if (m_Image == null)
            {
                m_Image = GetComponent<X3Image>();
            }

#if UNITY_EDITOR
            //编辑器预览用
            if (!Application.isPlaying)
            {
                UnityEditor.EditorApplication.update += Update;
            }
#endif

            //计算单张序列帧的持续时间
            // m_SingleSpriteDuration = GIFTime / m_Sprites.Count;
            m_SingleSpriteDuration = GetDeltaTimeFromSpriteIndex(0);
            
            //转移到首次播放延迟状态
            CurState = PlayState.FirstPlayDelay;

            X3GameUIWidgetEntry.EventDelegate?.GIFImage_OnBegin(this, this.GetInstanceID());

            if (UseNativeSize)
            {
                //需要使用序列帧图原本的尺寸
                m_Image.sprite = m_Sprites[0];
                m_Image.SetNativeSize();
            }
        }

        /// <summary>
        /// 停止播放
        /// </summary>
        public void Stop()
        {
            if (!CanStop())
            {
                return;
            }

            CurState = PlayState.Stop;


            m_Image.sprite = m_Sprites[0];


#if UNITY_EDITOR
            //编辑器预览用
            if (!Application.isPlaying)
            {
                UnityEditor.EditorUtility.SetDirty(m_Image);
                UnityEditor.EditorApplication.update -= Update;
            }
#endif
        }

        /// <summary>
        /// 暂停播放
        /// </summary>
        public void Pause()
        {
            if (!CanPause())
            {
                return;
            }

            m_PreState = CurState;
            CurState = PlayState.Pause;
        }

        /// <summary>
        /// 恢复播放
        /// </summary>
        public void Resume()
        {
            if (!CanResume())
            {
                return;
            }

            CurState = m_PreState;
        }

        /// <summary>
        /// 清理数据
        /// </summary>
        public void Clear()
        {
            Stop();
            
            m_Sprites?.Clear();
            
            m_Image.sprite = null;
        }


        /// <summary>
        /// 从 SpriteName 中拆分出该帧持续的时间
        /// </summary>
        private float GetDeltaTimeFromSpriteIndex(int index)
        {
            float result = 0.1f;

            if (perFrameTime != null && perFrameTime.Length > index)
            {
                result = perFrameTime[index];
            }
            else if (m_Sprites != null && GIFTime > 0 && m_Sprites.Count > 0)
            {
                result = GIFTime / m_Sprites.Count;
            }
            return result;
        }

    }

}


