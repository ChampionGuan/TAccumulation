using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Profiling;
using UnityEngine.SceneManagement;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class GhostActionItem
    {
        private static int FRAMERATE = 30;
        public PlayableDirector director;

        private GameObject originObj;
        private Transform rootMotionObj;
        private Vector3? originPos;
        private Quaternion? originRotate;
        private AnimationClip animationClip;

        private Gradient color;
        private MaterialPropertyBlock block;
        public GhostParam ghostParam { get; private set; }
        private Transform referenceTarget;
        private Stack<GhostItem> _itemCache = new Stack<GhostItem>(32);
        private GhostObjectPool _pool;
        private GhostShaderData _ghostShaderData;
        public GameObject boneSrc { get; private set; }
        
        // fade值
        public AnimationCurve fadeScale { get; private set; }

        #region Stop时需要清理的字段
        private float startTime;  // 开始运行时的时间
        private int curGhostNum = 0;  // 当前残影数量
        private float lastAddTime = 0; // 上次添加残影时间
        private Queue<GhostItem> usedGhosts = new Queue<GhostItem>(32);  // 正在活跃的残影
        private Stack<GhostItem> unusedGhosts = new Stack<GhostItem>(32);  // 已经回收的空闲残影
        private Dictionary<int, Vector4> recordPoss = new Dictionary<int, Vector4>(128);  // clip运行时
        #endregion
        
        private GhostItem _GetItem()
        {
            if (_itemCache.Count > 0)
            {
                return _itemCache.Pop();
            }
            return new GhostItem();
        }

        private void _ReleaseItem(GhostItem item)
        {
            item.Reset();
            _itemCache.Push(item);
        }

        public void SetFadeScale(AnimationCurve scale)
        {
            fadeScale = scale;
        }
        
        // 查找骨骼引用
        public void FindBoneSrc()
        {
            boneSrc = null;
            if (ghostParam.isCloneBone)
            {
                if (ghostParam.bindRoleType == TrackBindRoleType.Female)
                {
                    if (Application.isPlaying)
                    {
                        var girl = X3Battle.Battle.Instance.actorMgr.girl;
                        var root = girl.GetDummy(ActorDummyType.Root);
                        boneSrc = root.gameObject;
                    }
                    else
                    {
                        var scene = SceneManager.GetActiveScene();
                        var objs = scene.GetRootGameObjects();
                        foreach (var obj in objs)
                        {
                            if (TimelineExtInfo.IsGirlRoot(obj))
                            {
                                boneSrc = obj;
                            }
                        }
                    }
                }
                else if (ghostParam.bindRoleType == TrackBindRoleType.Male)
                {
                    if (Application.isPlaying)
                    {
                        var boy = X3Battle.Battle.Instance.actorMgr.boy;
                        var model = boy.GetDummy(ActorDummyType.Root);
                        boneSrc = model.gameObject;
                    }
                    else
                    {
                        var scene = SceneManager.GetActiveScene();
                        var objs = scene.GetRootGameObjects();
                        foreach (var obj in objs)
                        {
                            if (TimelineExtInfo.IsBoyRoot(obj))
                            {
                                boneSrc = obj;
                            }
                        }
                    }
                }
            }
        }
        public void SetGhostShaderData(GhostShaderData shaderData)
        {
            _ghostShaderData = shaderData;
        }

        private static List<KeyValuePair<float, float>> _auxiliaryDurationList = new List<KeyValuePair<float, float>>();
        private static List<GhostAnimPlayable> _auxiliaryPreaload = new List<GhostAnimPlayable>();
        private static int _preloadMaxCount = 8;
        
        public void PreloadGhostItem(float clipDuration)
        {
            _auxiliaryDurationList.Clear();
            _auxiliaryPreaload.Clear();
            
            if (_pool != null && ghostParam != null && animationClip != null)
            {
                if (ghostParam.maxGhostNum <= 2)
                {
                    // 已经提前预加载了2个，此处直接return即可
                    return;
                }
                var spawnInterval = ghostParam.spawnInterval;
                if (spawnInterval <= 0)
                {
                    spawnInterval = BattleConst.AnimFrameTime;
                }
                // 生成次数
                int spawnCount = Mathf.FloorToInt(clipDuration / spawnInterval);
                
                // 每个item持续时长
                var itemDuration = ghostParam.duration;
                if (itemDuration < 0)
                {
                    itemDuration = clipDuration;
                }
                else if(itemDuration == 0)
                {
                    itemDuration = BattleConst.AnimFrameTime;
                }

                var maxCount = 0;
                for (int i = 0; i < spawnCount; i++)
                {
                    var curTime = i * spawnInterval;
                    var vanishTime = curTime + itemDuration;
                    _auxiliaryDurationList.Add(new KeyValuePair<float, float>(curTime, vanishTime));
                    
                    var count = 0;
                    foreach (var pair in _auxiliaryDurationList)
                    {
                        if (pair.Key <= curTime && curTime < pair.Value)  // 前闭后开区间
                        {
                            count++;
                        }
                    }
                    if (maxCount < count)
                    {
                        maxCount = count;
                    }
                }

                // 最大数量做个限制
                if (ghostParam.maxGhostNum > 0 && maxCount > ghostParam.maxGhostNum)
                {
                    maxCount = ghostParam.maxGhostNum;
                }

                if (maxCount > _preloadMaxCount)
                {
                    maxCount = _preloadMaxCount;
                }

                for (int i = 0; i < maxCount; i++)
                {
                    var item = _pool.Get(animationClip);
                    _auxiliaryPreaload.Add(item);
                }

                foreach (var item in _auxiliaryPreaload)
                {
                    _pool.Release(animationClip, item);
                }
            }
            
            _auxiliaryDurationList.Clear();
            _auxiliaryPreaload.Clear();
        }
        
        public void SetTrackInfo(GameObject obj, Gradient defaultColor,
            PlayableDirector playableDirector, AnimationClip clip, GhostParam param, GameObject reference, GhostObjectPool pool)
        {
            _pool = pool;
            if (_pool != null)
            {
                // TODO 避免GC，提前搞两个，不够再加
                var item1 = _pool.Get(clip);
                var item2 = _pool.Get(clip);
                _pool.Release(clip, item1);
                _pool.Release(clip, item2);
                
                for (int i = 0; i < 16; i++)
                {
                    _ReleaseItem(new GhostItem());
                }
            }
            originObj = obj;
            if (originObj != null)
            {
                rootMotionObj = originObj.transform.Find("RootMotionRecorder");
                var com = originObj.GetComponent<RootMotionUpdater>();
                if (com != null)
                {
                    com.enabled = param.isPausePosition;
                }
            }
            color = defaultColor;
            director = playableDirector;
            animationClip = clip;
            ghostParam = param;
            referenceTarget = reference?.transform;
            if (originObj != null)
            {
                originObj.SetVisible(false);
                if (!originObj.activeSelf)
                {
                    originObj.SetActive(true);
                }
            }
            ResetField();
        }

        // 初始化或结束运行时重置字段
        private void ResetField()
        {
            startTime = 0;
            curGhostNum = 0;
            lastAddTime = 0;
            if (usedGhosts.Count > 0)
            {
                foreach (var item in usedGhosts)
                {
                    item.Destroy();
                    _ReleaseItem(item);
                }
                usedGhosts.Clear();
            }

            if (unusedGhosts.Count > 0)
            {
                foreach (var item in unusedGhosts)
                {
                    item.Destroy();
                    _ReleaseItem(item);
                }  
                unusedGhosts.Clear();
            }
            recordPoss.Clear();
        }

        // recordPos, 用timeline运行时间记录
        private void Record(float time)
        {
            if (referenceTarget != null)
            {
                int frame = Convert.ToInt32(time * FRAMERATE);
                var targetPos = referenceTarget.position;
                var targetForward = referenceTarget.forward;  // 每次取forward内部进行一次乘法
                // 前两个字段存位置
                // 后两个字段存偏移量（四元数转欧拉角计算量比forward大, 多一个float省计算量）
                var pos = new Vector4(targetPos.x, targetPos.z, targetForward.x, targetForward.z);
                recordPoss[frame] = pos;
            }
        }

        //回复recordpos
        public void SetGhostPos(GameObject obj, float time)
        {
            if (obj != null)
            {
                int frame = Convert.ToInt32(time * FRAMERATE);
                if (recordPoss.ContainsKey(frame))
                {
                    var pos = recordPoss[frame];
                    obj.transform.position = new Vector3(pos.x, 0, pos.y);
                    obj.transform.forward = new Vector3(pos.z, 0, pos.w);
                }
            }
        }
        
        // 通过比例设置颜色
        public void SetMatColorByPercent(SkinnedMeshRenderer[] meshs, float percent)
        {
            if (meshs != null && color != null)
            {
                var newColor = color.Evaluate(percent);
                // var newColor = new Color(color.r, color.g, color.b, Mathf.Max(0,
                    // color.a * percen));

                if (block == null)
                    block = new MaterialPropertyBlock();

                foreach (var VARIABLE in meshs)
                {
                    VARIABLE.GetPropertyBlock(block);
                    block.SetColor("_Color", newColor);
                    VARIABLE.SetPropertyBlock(block);
                }
            }
        }
        
        // 同步属性参数
        public void SetShaderDataToMeshes(SkinnedMeshRenderer[] meshes)
        {
            if (_ghostShaderData != null)
            {
                if (block == null)
                {
                    block = new MaterialPropertyBlock();
                }
                _ghostShaderData.SetToMeshes(block, meshes);
            }   
        }

        private void TryAddGhostItem(float curTime, bool isFirst = false)
        {
            if ((ghostParam.maxGhostNum == -1 || curGhostNum < ghostParam.maxGhostNum) &&
                ((curTime - lastAddTime >= ghostParam.spawnInterval) || isFirst))
            {
                GhostItem item = null;
                if (unusedGhosts.Count > 0)
                {
                    item = unusedGhosts.Pop();
                }
                else
                {
                    item = _GetItem();
                    item.Init(originObj, animationClip, this, isFirst, objPool:_pool);   
                }
                item.Start(curTime, ghostParam.isPauseAnim, ghostParam.globalDelayPlayTime, ghostParam.duration);
                usedGhosts.Enqueue(item);
                curGhostNum++;
                lastAddTime = curTime;
            }
        }

        // 开始
        public void OnStart(float time)
        {
            using (ProfilerDefine.GhostActionItemOnStartMarker.Auto())
            {
                startTime = time;
                Record(startTime);
                if (rootMotionObj != null)
                {
                    rootMotionObj.localPosition = Vector3.zero;
                    rootMotionObj.localRotation = Quaternion.identity;
                }
                if (originObj != null)
                {
                    originPos = originObj.transform.localPosition;
                    originRotate = originObj.transform.localRotation;
                    // originObj.SetVisible(true);
                    TryAddGhostItem(startTime, true);
                }
            }
        }

        // 帧更新
        public void OnProcessFrame(float time)
        {
            using (ProfilerDefine.GhostActionItemOnProcessFrameMarker.Auto())
            {
                var curTime = time;
                Record(curTime);
                var isBeginAnim = curTime - startTime >= ghostParam.globalDelayPlayTime;
            
                // 更新老的
                if (usedGhosts.Count > 0)
                {
                    foreach (var item in usedGhosts)
                    {
                        item.Update(curTime, isBeginAnim);
                    }

                    var usedItem = usedGhosts.Peek();
                    while (usedItem != null && usedItem.IsEnd())
                    {
                        usedItem.Stop();
                        usedGhosts.Dequeue();
                        unusedGhosts.Push(usedItem);
                        usedItem = usedGhosts.Count > 0 ? usedGhosts.Peek() : null;
                    }
                }
                // 添加新的
                TryAddGhostItem(curTime);
            }
        }

        // 结束
        public void OnStop()
        {
            using (ProfilerDefine.GhostActionItemOnStopFrameMarker.Auto())
            {
                if (originObj != null)
                {
                    if (originPos != null)
                    {
                        originObj.transform.localPosition = originPos.Value; 
                    }
                    if (originRotate != null)
                    {
                        originObj.transform.localRotation = originRotate.Value;
                    }
                    if (rootMotionObj != null)
                    {
                        rootMotionObj.localPosition = Vector3.zero;
                        rootMotionObj.localRotation = Quaternion.identity;
                    }
                    originObj.SetVisible(false);
                    ResetField();
                }
            }
        }
    }
}