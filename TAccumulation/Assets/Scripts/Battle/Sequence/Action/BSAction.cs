using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class BSAction : X3Sequence.Action
    {
        // 所属timelineTrack，不对子类开放
        private TrackAsset _trackAsset;
        public TrackAsset trackAsset => _trackAsset;  // 注意，这是UnityAsset，外部拿到之后不要改里面的内容
        // 轨道绑定的Obj，不对子类开放
        private Object _trackBindObj; 
        // 所属playableAsset，不对子类开放
        private PlayableAsset _clipAsset;  
        // 所属timeline资源，不对子类开放
        private TimelineAsset _timelineAsset { get; set; }  
        // 所属ActionClip
        protected BSActionAsset _bsActionAsset { get; private set;}
        // 战斗context
        public BSActionContext context { get; private set; }  
        
        public BattleSequencer battleSequencer { get; private set; }
        
        // 共享变量
        private BSSharedVariables _bsSharedVariables;
        protected BSSharedVariables bsSharedVariables
        {
            get
            {
                if (_bsSharedVariables == null)
                {
                    _bsSharedVariables = track.sequencer.variables as BSSharedVariables;
                }
                return _bsSharedVariables;
            }
        }

        // 共享变量中的蓝图
        protected BSBlackboard bsBlackboard => bsSharedVariables.blackboard;

        public void SetBattleData(BSActionAsset assetParam, BSActionContext contextParam, BattleSequencer sequencer)
        {
            context = contextParam;
            _bsActionAsset = assetParam;
            battleSequencer = sequencer;
        }

        public void SetArtData(TimelineAsset timelineAsset, TrackAsset trackAsset, PlayableAsset clipAsset, Object trackBindObj)
        {
            _timelineAsset = timelineAsset;
            _trackAsset = trackAsset;
            _clipAsset = clipAsset;
            _trackBindObj = trackBindObj;
        }

        // 获取clip资源
        protected T GetClipAsset<T>() where T: PlayableAsset
        {
            return _clipAsset as T;
        }

        // 获取track资源
        protected T GetTrackAsset<T>() where T : TrackAsset
        {
            return _trackAsset as T;
        }
        
        // 获取轨道上绑定的对象
        protected T GetTrackBindObj<T>() where T : Object
        {
            return _trackBindObj as T;
        }

        // 获取ExposeValue值
        protected T GetExposedValue<T>(ExposedReference<T> field) where T: Object
        {
            var director = battleSequencer.GetComponent<BSCRes>().artDirector;
            if (director != null)
            {
                var obj = field.Resolve(director);
                if (obj != null)
                {
                    return obj;
                }
            }
            return null;
        }

        // 获取Sequence的最大时长
        protected double GetSequenceDuration()
        {
            if (_timelineAsset != null)
            {
                return _timelineAsset.duration;
            }

            return 0;
        }
    }

    public class BSAction<T> : BSAction where T : BSActionAsset
    {
        public T clip => _bsActionAsset as T;
    }
}