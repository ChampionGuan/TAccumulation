namespace X3Battle
{
    public class SkillLinkDataItem : IReset
    {
        private PlayerBtnType _playerBtnType;
        public PlayerBtnType playerBtnType => _playerBtnType;
        
        private int _soltID;
        public int slotID => _soltID;
        
        private int _skillID;
        public int skillID => _skillID;
        
        private float _duration;
        public float duration => _duration;
        
        private PlayerBtnStateType _btnStateType;
        public PlayerBtnStateType btnStateType => _btnStateType;

        private int _initFrameCount;
        /// <param name="playerBtnType">按钮类型</param>
        /// <param name="soltID">槽位ID</param>
        /// <param name="debugSkillID">技能ID</param>
        /// <param name="duration">持续时长</param>
        public void Init(PlayerBtnType playerBtnType, int soltID, int debugSkillID, float duration, PlayerBtnStateType stateType)
        {
            _playerBtnType = playerBtnType;
            _duration = duration;
            _soltID = soltID;
            _skillID = debugSkillID;
            _btnStateType = stateType;
            _initFrameCount = Battle.Instance.frameCount;
        }

        public void Reset()
        {
            _playerBtnType = 0;
            _duration = 0;
            _soltID = 0;
            _skillID = 0;
            _btnStateType = 0;
            _initFrameCount = 0;
        }
        
        public bool IsActive()
        {
            return _duration > 0 || _duration < 0;
        }

        public void Destroy()
        {
        }

        public void Update(float deltaTime)
        {
            if (Battle.Instance.frameCount == _initFrameCount)
            {
                return;  // 兼容时序，这一帧被添加出来就不能再Update
            }
            if (_duration > 0)
            {
                _duration -= deltaTime;
                if (_duration < 0)
                {
                    _duration = 0;
                }
            }
        }
        
    }
}