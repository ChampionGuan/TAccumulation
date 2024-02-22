using Unity.Profiling;
using UnityEngine.Playables;
using UnityEngine.Profiling;
using UnityEngine.Timeline;

namespace X3Battle.Timeline.Extension
{
    public class PreviewActionBehaviour :InterruptBehaviour
    {

        private IAction _action;

        private PreviewActionIContext _previewActionIContext;
        public PreviewActionIContext previewActionIContext => _previewActionIContext;

        private ActionParam _param;
        public ActionParam param => _param;

        private BattleSequencer _battleBattleSequencer;
        public BattleSequencer battleBattleSequencer => _battleBattleSequencer;

        private ProfilerMarker _debugStartNameMarker;
        private bool _IsInitdebugStartName;
        private ProfilerMarker _GetDebugStartName()
        {
            if (_IsInitdebugStartName == false)
            {
                _debugStartNameMarker = new ProfilerMarker(_action.GetType().Name + ".OnStart");
                _IsInitdebugStartName = true;
            }
            return _debugStartNameMarker;
        }

        private ProfilerMarker _debugStopNameMarker;
        private bool _IsInitdebugStopName;
        private ProfilerMarker _GetDebugStopName()
        {
            if (_IsInitdebugStopName == false)
            {
                _debugStopNameMarker = new ProfilerMarker(_action.GetType().Name + ".OnStop");
                _IsInitdebugStopName = true;
            }
            return _debugStopNameMarker;
        }

        private ProfilerMarker _debugUpdateNameMarker;
        private bool _IsInitdebugUpdateName;
        private ProfilerMarker _GetDebugUpdateName()
        {
            if (_IsInitdebugUpdateName == false)
            {
                _IsInitdebugUpdateName = true;
                _debugUpdateNameMarker = new ProfilerMarker(_action.GetType().Name + ".OnUpdate");
            }
            return _debugUpdateNameMarker;
        }
        
        public void SetContext(PreviewActionIContext runTimePreviewActionIContext)
        {
            _previewActionIContext = runTimePreviewActionIContext;
        }

        public void SetBattleTimeline(BattleSequencer runTimeBattleBattleSequencer)
        {
            _battleBattleSequencer = runTimeBattleBattleSequencer;
        }

        public void SetParam(ActionParam runTimeParam)
        {
            _param = runTimeParam;
        }
        
        public void SetRunTimeAction(IAction action)
        {
            _action = action;
            // 初始化时解决GC
            _GetDebugStartName();
            _GetDebugStopName();
            _GetDebugUpdateName();
        }
        
        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            using (_GetDebugStartName().Auto())
            {
                _action.Enter(this);
            }
        }

        protected override void OnStop()
        {
            using (_GetDebugStopName().Auto())
            {
                _action.Exit(this);  
            }
        }

        protected override void OnProcessFrame(Playable playable, FrameData info, object playerData)
        {
            using (_GetDebugUpdateName().Auto())
            {
                _action.Update(this);
            }
        }

        protected override void OnGraphDestroyInEditor()
        {
            _action.Destroy(this);
        }
    }
}