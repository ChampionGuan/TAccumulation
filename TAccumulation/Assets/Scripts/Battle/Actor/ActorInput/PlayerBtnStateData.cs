using UnityEngine;

namespace X3Battle
{
    // 输入状态
    public class PlayerBtnStateData
    {
        private bool _lastIsDown = false;  // 最后一次按下是否为down
        // 按下时间点
        private float _downTime;
        // 抬起时间点
        private float _upTime;
        // tap时间点
        private float _tapTime;
        
        //按下或抬起的帧率
        private int _frame;

        //按下的帧率
        private int _downframe;
        
        //抬起的帧率
        private int _upframe;
        public int frame
        {
            get => _frame;
            set => _frame = value;
        }

        // TODO 优化：Cache单独抽出去
        // TODO 优化：isDown
        // Down缓存数据
        private bool _downCache;
        public bool downCache => _downCache;
        // Up缓存数据
        private bool _upCache;
        // Tap缓存数据
        private bool _tapCache;

        // 清理缓存
        public void Clear()
        {
            _downTime = 0;
            _upTime = 0;
            _tapTime = 0;
            _frame = 0;
            _downCache = false;
            _upCache = false;
            _tapCache = false;
            _lastIsDown = false;
        }
        
        // 是否处于hold状态
        public bool IsHolding()
        {
            //这里判断down = up 也为hold的状态原因是：在同帧内，down和up会一起发生，导致downTime = UpTime
            bool result = false;
            if (_lastIsDown)
            {
                // 最近一次是down，当downTime = upTime时，认为处于holding状态
                result = _downframe > 0 && _downframe >= _upframe;
            }
            else
            {
                // 最近一次是up, 当upTime = downTime时，认为不处于holding状态
                result = _downframe > 0 && _downframe > _upframe;
            }
            
            return result;
        }

        /// <summary>
        /// 有指令缓存且可用
        /// </summary>
        /// <param name="type">按钮类型</param>
        /// <param name="curTime">当前时间</param>
        /// <param name="timeElapse">必须是多长时间之内的缓存才能用, -1无限</param>
        /// <returns></returns>
        public bool CanConsumeCache(PlayerBtnStateType type, float curTime, float timeElapse, float tapDuration = -1, float tapDownElapse = -1)
        {
            if (type == PlayerBtnStateType.Down)
            {
                if (timeElapse < 0)
                {
                    return _downCache;
                }
                else
                {
                    return _downCache && _downTime + timeElapse > curTime;
                }
                
            }
            else if(type == PlayerBtnStateType.Hold)
            {
                // 只要处于hold状态，就可以无限使用Hold指令
                if (IsHolding())
                {
                    if (timeElapse < 0)
                    {
                        return true;    
                    }
                    else
                    {
                        // hold状态判断的是hold中持续时间
                        return curTime - _downTime >= timeElapse;
                    }
                   
                }
            }
            else if (type == PlayerBtnStateType.Up)
            {
                if (timeElapse < 0)
                {
                    return _upCache;
                }
                else
                {
                    //Debug.LogError(" _UpTime = " + _upTime + " curTime = " + curTime + " frame = " + Battle.Instance.frameCount + " timeElapse = " + timeElapse +  " " + (_upCache && _upTime + timeElapse > curTime));
                    return _upCache && _upTime + timeElapse >= curTime;
                }
            }
            else if (type == PlayerBtnStateType.Tap)
            {
                if (_tapCache)
                {
                    // 判断timeElapse是否满足需求
                    if (timeElapse < 0 || curTime - _tapTime < timeElapse)
                    {
                        // 判断duration是否满足需求
                        if (tapDuration< 0 || _tapTime - _downTime < tapDuration)
                        {
                            // 判断这次tap的down行为，时间是否满足需求
                            if (tapDownElapse < 0 ||  curTime - _downTime < tapDownElapse)
                            {
                                return true;
                            }
                        }
                    }
                }
                return false;
            }
            return false;
        }

        /// <summary>
        /// 获取按钮状态时间 判断按钮状态是否可以使用
        /// </summary>
        /// <param name="type"></param>
        /// <param name="curTime"></param>
        /// <param name="btnTime"></param>
        /// <param name="tapDuration"></param>
        /// <returns></returns>
        public bool GetBtnTime(PlayerBtnStateType type, float curTime, out float btnTime, float tapDuration = -1)
        {
            btnTime = 0;
            if (type == PlayerBtnStateType.Down)
            {
                btnTime = _downTime;
                return _downCache;
            }
            else if (type == PlayerBtnStateType.Hold)
            {
                // 只要处于hold状态，就可以无限使用Hold指令
                if (IsHolding())
                {
                    // hold状态判断的是hold中持续时间
                    btnTime = curTime;
                    return true;
                }
            }
            else if (type == PlayerBtnStateType.Up)
            {
                btnTime = _upTime;
                return _upCache;
            }
            else if (type == PlayerBtnStateType.Tap)
            {
                if (_tapCache)
                {
                    // 判断duration是否满足需求
                    if (tapDuration < 0 || _tapTime - _downTime < tapDuration)
                    {
                        btnTime = _upTime;
                        return true;
                    }
                }
            }

            return false;
        }

        /// <summary>
        /// 尝试使用指令缓存
        /// </summary>
        /// <param name="type">按钮类型</param>
        /// <param name="curTime">当前时间</param>
        /// <param name="timeElapse">必须是多长时间之内的缓存才能用， -1无限</param>
        /// <returns></returns>
        public bool TryConsumeCache(PlayerBtnStateType type, float curTime, float timeElapse, float tapDuration = -1, float tapDownElapse = -1)
        {
            if (CanConsumeCache(type, curTime, timeElapse, tapDuration:tapDuration, tapDownElapse:tapDownElapse))
            {
                // hold状态无限用，不使用Cache，Up和Down使用之后就要置空所有Cache
                if (type != PlayerBtnStateType.Hold)
                {
                    _downCache = false;
                    _upCache = false;
                    _tapCache = false;
                }  
                return true;
            }
            return false;
        }

        // 更新Down时间
        public void RecordDownTime(float time)
        {
            _downTime = time;
        }
        
        public void RecordDownState()
        {
            _downCache = true;
            _lastIsDown = true;
            _frame = Battle.Instance.frameCount;
            _downframe = Battle.Instance.frameCount;
        }
        
        // 更新Up时间
        public void RecordUpState()
        {
            _lastIsDown = false;
            _frame = Battle.Instance.frameCount;
            _upframe = Battle.Instance.frameCount;
            if (IsHolding())
            {
                // holding状态如果downcache为false，这里也为false
                _upCache = _downCache;
            }
            else
            {
                _upCache = true;
            }
            _tapCache = _downCache;  // tap比较特殊，记录tap时如果dow被用过了，则tap直接标记为不可用
        }

        public void RecordUpTime(float time)
        {
            _upTime = time;
            _tapTime = time;
        }

        // 清理缓存
        public void ClearCache()
        {
            _upCache = false;
            _downCache = false;
            _tapCache = false;
        }
        
    }
}