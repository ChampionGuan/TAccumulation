using PapeGames.X3;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class BSCRes : BSCBase, IReset
    {
        private enum TimelineResType
        {
            None,  // 两种资源都为空
            ArtOnly,  // 只有美术资源
            LogicOnly,  // 只有逻辑资源
            ArtAndLogic,  // 美术资源和逻辑资源都有
        }
        
        private TimelineResType _resType;  // 给到的资源类型
        
        public GameObject artObject { get; set; } // 实例对象
        public TimelineAsset artAsset { get; private set; } // 实例对象上的asset资源
        public TimelineAsset logicAsset { get; set; } // 逻辑资源
        
        public TimelineExtInfo artTimelineExtInfo { get; private set; } // 实例对象上的信息
        public PlayableDirector artDirector { get; private set; } // 实例对象上的director组件
        
        public void Reset()
        {
            artObject = null;
            artAsset = null;
            logicAsset = null;
            artTimelineExtInfo = null;
            artDirector = null;
            _resType = TimelineResType.None;
        }
        
        protected override void _OnInit()
        {
            var resPath = _battleSequencer.bsCreateData.artResPath;
            var logicAssetPath = _battleSequencer.bsCreateData.logicAssetPath;
            
            bool hasResPath = !string.IsNullOrEmpty(resPath);
            bool hasLogicAssetPath = !string.IsNullOrEmpty(logicAssetPath);

            if (hasResPath && hasLogicAssetPath)
            {
                // 都不为空, 把LogicAsset附加到Art上，时间用Logic的
                _resType = TimelineResType.ArtAndLogic;
                artObject = _context.LoadTimelineObject(resPath);
                if (artObject == null)
                {
                    LogProxy.LogError($"呼叫【卡宝宝】【清心】timeline资源 {resPath} 不存在！");
                    return;
                }
                
                artDirector = artObject.GetComponent<PlayableDirector>();
                artTimelineExtInfo = artObject.GetComponent<TimelineExtInfo>();
                artAsset = artDirector?.playableAsset as TimelineAsset;
                logicAsset = _context.LoadTimelineAsset(logicAssetPath);

                
                if (artAsset == null)
                {
                    LogProxy.LogError($"呼叫【卡宝宝】【清心】timeline资源 {resPath} 上没有PlayableAsset资源！");
                    return;
                }

                if (logicAsset == null)
                {
                    LogProxy.LogError($"呼叫【卡宝宝】【清心】timeline资源 {logicAssetPath} 不存在！");
                    return; 
                }
                
                artObject.transform.parent = _context.GetRootTransform();
                _battleSequencer.name = artAsset.name;
                _SetDuration(artAsset.duration, logicAsset.duration);
            }
            else if (hasResPath)
            {
                // 美术不为空，走之前的逻辑 
                _resType = TimelineResType.ArtOnly;
                artObject = _context.LoadTimelineObject(resPath);
                if (artObject == null)
                {
                    LogProxy.LogError($"呼叫【卡宝宝】【清心】timeline资源 {resPath} 不存在！");
                    return;
                }
                _battleSequencer.name = artObject.name;
                artDirector = artObject.GetComponent<PlayableDirector>();
                artTimelineExtInfo = artObject.GetComponent<TimelineExtInfo>();
                artAsset = artDirector?.playableAsset as TimelineAsset;
                if (artAsset != null)
                {
                    if (_battleSequencer.bsCreateData.defaultDuration != null)
                    {
                        _SetDuration(artAsset.duration, _battleSequencer.bsCreateData.defaultDuration.Value);
                    }
                    else
                    {
                        _SetDuration(artAsset.duration, artAsset.duration);
                    }
                }
                artObject.transform.parent = _context.GetRootTransform();;
            }
            else if (hasLogicAssetPath)
            {
                // 策划不为空，新构建一个Obj，时间用Logic的
                _resType = TimelineResType.LogicOnly;   
                logicAsset = _context.LoadTimelineAsset(logicAssetPath);
                logicAsset = logicAsset;
                
                if (logicAsset == null)
                {
                    LogProxy.LogError($"呼叫【卡宝宝】【清心】timeline资源 {logicAssetPath} 不存在！");
                    return; 
                }
                _battleSequencer.name = logicAsset.name;
                _SetDuration(logicAsset.duration, logicAsset.duration);
            }
            else
            {
                // 都为空 
                _resType = TimelineResType.None;
                LogProxy.LogError($"呼叫【卡宝宝】【清心】动作模组上没有配ArtTimeline，也没有配LogicTimeline");
                return;
            }
            return;
        }

        private void _SetDuration(double artDuration, double logicDuration)
        {
            _battleSequencer.artDuration = (float)artDuration;
            _battleSequencer.logicDuration = (float)logicDuration;
            if (_battleSequencer.artDuration < _battleSequencer.logicDuration)
            {
                _battleSequencer.artDuration = _battleSequencer.logicDuration.Value;
            }
        }
        
        protected override void _OnDestroy()
        {
            if (this.artObject != null)
            {
                _context.UnloadGameObject(this.artObject);
            }

            if (logicAsset != null)
            {
                _context.UnloadTimelineAsset(logicAsset);
            }
        }
    }
}