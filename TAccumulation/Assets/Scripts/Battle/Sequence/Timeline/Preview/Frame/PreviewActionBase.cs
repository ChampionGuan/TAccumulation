
namespace X3Battle.Timeline.Extension
{
    // 预览时的action基类
    public class PreviewActionBase
    {
        private PreviewActionAsset _mRunTimePreviewAction;
        
        public void Init(PreviewActionAsset previewAction)
        {
            _mRunTimePreviewAction = previewAction;
            OnInit();
        }

        public double GetCurTime()
        {
            return _mRunTimePreviewAction.curTime;
        }
        public double GetDuration()
        {
            return _mRunTimePreviewAction.GetDuration();
        }

        public double GetRemainTime()
        {
            return _mRunTimePreviewAction.remainTime;
        }
        
        public float GetStartTime()
        {
            return _mRunTimePreviewAction.startTime;
        }
        public T GetRunTimeAction<T>() where T: class
        {
            return _mRunTimePreviewAction as T;
        }

        public void Enter()
        {
            OnEnter();
        }

        public void Update(float deltaTime)
        {
            OnUpdate(deltaTime);
        }

        public void Exit()
        {
            OnExit();
        }

        public void Destroy()
        {
            OnDestroy();
        }

        protected virtual void OnInit()
        {
            
        }
        
        protected virtual void OnEnter()
        {
            
        }
        
        protected virtual void OnUpdate(float deltaTime)
        {
            
        }
        
        protected virtual void OnExit()
        {
            
        }

        protected virtual void OnDestroy()
        {
            
        }
    }
}