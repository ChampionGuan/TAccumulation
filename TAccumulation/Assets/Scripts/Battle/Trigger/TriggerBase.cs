using X3.CustomEvent;

namespace X3Battle
{
    public abstract class TriggerBase
    {
        protected TriggerContext _triggerContext;
        
        private int _configId;
        private int _insId;
        public int configId => _configId;
        public int insId => _insId;

        // 累计时间
        private float _elapsedTime;
        
        public bool isEnd { get; protected set; }
        public bool autoStart { get; protected set; }

        public void Init(int insId, int configId, TriggerContext triggerContext, bool autoStart)
        {
            _insId = insId;
            _configId = configId;
            _triggerContext = triggerContext;
            _elapsedTime = 0f;
            isEnd = false;
            this.autoStart = autoStart;
            this.OnInit();
        }

        public void Destroy()
        {
            this.OnDestroy();
            _triggerContext = null;
        }

        public void Update()
        {
            // DONE: 采用战斗时间还是主体时间.
            this._elapsedTime += _triggerContext.deltaTime;
            this.OnUpdate();

            // DONE: 永久不处理.
            if (_triggerContext.lifeTime < 0)
                return;
            if (this._elapsedTime < _triggerContext.lifeTime)
                return;
            // DONE: 标记触发器死亡
            isEnd = true;
        }

        public void Disable(bool disabled)
        {
            OnDisable(disabled);
        }
        
        public void TriggerEvent(NotionGraphEventType key, IEventData arg, bool autoRecycle = true)
        {
            OnTriggerEvent(key, arg, autoRecycle);
        }

        protected virtual void OnInit()
        {
        }

        protected virtual void OnDestroy()
        {
        }

        protected virtual void OnUpdate()
        {
        }

        protected virtual void OnDisable(bool disabled)
        {
            
        }

        protected virtual void OnTriggerEvent(NotionGraphEventType key, IEventData arg, bool autoRecycle = true)
        {
            
        }
    }
}