using System.Collections.Generic;
using System.Linq;
using PapeGames.X3;
using UnityEngine;
using XAssetsManager;

namespace X3Battle
{
    public class ActorInput : ActorComponent
    {
        private struct BtnCache
        {
            public bool isDown;
            public PlayerBtnType btnType;

            public BtnCache(bool isDown, PlayerBtnType btnType)
            {
                this.isDown = isDown;
                this.btnType = btnType;
            }
        }
        private Dictionary<PlayerBtnType, PlayerBtnStateData> _datas;
        private Dictionary<PlayerBtnType, PlayerBtnStateData> _sortDatas;
        private Dictionary<PlayerBtnType, PlayerBtnStateData> _tempDatas;
        private List<BtnCache> _btnCaches = new List<BtnCache>(4);
        //非技能状态使用的输入缓存按钮类型
        public List<PlayerBtnType> commonUseBtns;
        public Dictionary<PlayerBtnType, PlayerBtnStateData> sortDatas
        {
            get { return _sortDatas; }
        }

        protected override void OnUpdate()
        {
            base.OnUpdate();
            SetBtnTime();
        }

        /// <summary>
        /// 按照时间和优先级排序
        /// </summary>
        /// <returns></returns>
        private Dictionary<PlayerBtnType, PlayerBtnStateData> _SortDatas()
        {
            _tempDatas.Clear();
            _sortDatas.Clear();
            _tempDatas.AddRange(_datas);
            if (_tempDatas.Values.Count <= 0)
            {
                return _sortDatas;
            }

            for (int i = _tempDatas.Count; i >= 0; i--)
            {
                int btnType = -1;
                PlayerBtnStateData stateData = null;
                int maxFrame = int.MinValue;
                
                foreach (var data in _tempDatas)
                {
                    if (data.Value == null)
                    {
                        continue;
                    }

                    if (maxFrame < data.Value.frame)
                    {
                        btnType = (int)data.Key;
                        stateData = data.Value;
                        maxFrame = data.Value.frame;
                    }
                }

                if (btnType != -1)
                {
                    _tempDatas.Remove((PlayerBtnType)btnType);
                    _sortDatas.Add((PlayerBtnType)btnType, stateData);
                }
            }
            return _sortDatas;
        }

        // 最近一次操作的按钮
        private PlayerBtnType _latestOperationBtn;
        public PlayerBtnType latestOperationBtn => _latestOperationBtn;
        
        public ActorInput() : base(ActorComponentType.ActorInput)
        {
            _sortDatas = new Dictionary<PlayerBtnType, PlayerBtnStateData>();
            _datas = new Dictionary<PlayerBtnType, PlayerBtnStateData>();
            _tempDatas = new Dictionary<PlayerBtnType, PlayerBtnStateData>();
            commonUseBtns = new List<PlayerBtnType>()
            {
                PlayerBtnType.Attack, PlayerBtnType.Active, PlayerBtnType.Dodge, PlayerBtnType.Coop,
                PlayerBtnType.Ultra, PlayerBtnType.CoopAttack
            };
            _datas.Add(PlayerBtnType.Ultra, null);
            _datas.Add(PlayerBtnType.Coop, null);
            _datas.Add(PlayerBtnType.Dodge, null);
            _datas.Add(PlayerBtnType.Active, null);
            _datas.Add(PlayerBtnType.Attack, null);
            _datas.Add(PlayerBtnType.CoopAttack, null);
        }

        public void ClearCache()
        {
            if (_datas != null)
            {
                foreach (var iter in _datas)
                {
                    iter.Value?.Clear();
                }       
            }
        }

        public void SetBtnState()
        {
            //update的时候再记录按钮状态 否者按钮时间不是当前帧时间
            foreach (var btnCach in _btnCaches)
            {
                _latestOperationBtn = btnCach.btnType;
                var stateData = _EnsureStateData(btnCach.btnType);
                if (btnCach.isDown)
                {
                    stateData.RecordDownState();
                }
                else
                {
                    stateData.RecordUpState();
                }
                ClearOtherCache(btnCach.btnType, stateData.frame, btnCach.isDown ? PlayerBtnStateType.Down : PlayerBtnStateType.Up);
                //Debug.LogError(btnCach.btnType + "记录时间 = " + actor.time + " Battle.frameCount = " + battle.frameCount + " stateData.frame =" + stateData.frame + " isDown = " + btnCach.isDown);
            }
        }

        public void SetBtnTime()
        {
            //update的时候再记录按钮状态 否者按钮时间不是当前帧时间
            foreach (var btnCach in _btnCaches)
            {
                _latestOperationBtn = btnCach.btnType;
                var stateData = _EnsureStateData(btnCach.btnType);
                if (btnCach.isDown) 
                {
                    stateData.RecordDownTime(actor.time);
                }
                else
                {
                    stateData.RecordUpTime(actor.time);
                }
                //Debug.LogError(btnCach.btnType + "记录时间 = " + actor.time + " Battle.frameCount = " + battle.frameCount + " stateData.frame =" + stateData.frame + " isDown = " + btnCach.isDown);
            }
            _SortDatas();
            _btnCaches.Clear();
        }

        /// <summary>
        /// 尝试消耗掉指令缓存（Up和Dow只能用一次，Hold可以多次）
        /// </summary>
        /// <param name="btnType">按键类型</param>
        /// <param name="stateType">按键状态</param>
        /// <param name="timeElapse">必须是多长时间之内的缓存才能用, -1无限制</param>
        /// <returns></returns>
        public bool TryConsumeCache(PlayerBtnType btnType, PlayerBtnStateType stateType, float timeElapse = -1, float tapDuration = -1, float tapDownElapse = -1)
        {
            _datas.TryGetValue(btnType, out var stateData);
            if (stateData == null)
            {
                return false;
            }
            
            var result = stateData.TryConsumeCache(stateType, actor.time, timeElapse, tapDuration:tapDuration, tapDownElapse:tapDownElapse); 
            return result;
        }

        /// <summary>
        /// 是否能消耗指令缓存
        /// </summary>
        /// <param name="btnType">按键类型</param>
        /// <param name="stateType">按键状态</param>
        /// <param name="timeElapse">必须是多长时间之内的缓存才能用, -1无限制</param>
        /// <returns></returns>
        public bool CanConsumeCache(PlayerBtnType btnType, PlayerBtnStateType stateType, float timeElapse = -1, float tapDuration = -1, float tapDownElapse = -1)
        {
            _datas.TryGetValue(btnType, out var stateData);
            if (stateData == null)
            {
                return false;
            }
            var result = stateData.CanConsumeCache(stateType, actor.time, timeElapse, tapDuration:tapDuration, tapDownElapse:tapDownElapse);
            return result;
        }

        /// <summary>
        /// 获取按钮状态能否使用 & 按钮状态的时间
        /// </summary>
        /// <param name="btnType"></param>
        /// <param name="stateType"></param>
        /// <param name="curTime"></param>
        /// <param name="btnTime"></param>
        /// <param name="tapDuration"></param>
        /// <returns></returns>
        public bool CanUseBtn(PlayerBtnType btnType, PlayerBtnStateType stateType, float curTime, out float btnTime,
            float tapDuration = -1)
        {
            btnTime = 0;
            _datas.TryGetValue(btnType, out var stateData);
            if (stateData == null)
            {
                return false;
            }

            var result = stateData.GetBtnTime(stateType, curTime, out btnTime, tapDuration);
            return result;
        }

        // 刷新按钮按下时间
        public void RecordBtnDownTime(PlayerBtnType btnType)
        {
            _btnCaches.Add(new BtnCache(true, btnType));
        }

        // 刷新按钮抬起时间
        public void RecordBtnUpTime(PlayerBtnType btnType)
        {
            _btnCaches.Add(new BtnCache(false, btnType));
        }

        /// <summary>
        /// 不清除同帧按钮的缓存
        /// </summary>
        /// <param name="btnType"></param>
        /// <param name="frame"></param>
        public void ClearOtherCache(PlayerBtnType btnType, int frame, PlayerBtnStateType stateType)
        {
            foreach (var iter in _datas)
            {
                if (iter.Key != btnType && iter.Value != null && iter.Value.frame != frame)
                {
                    // if (btnType != PlayerBtnType.Attack && iter.Key == PlayerBtnType.Attack && iter.Value.downCache)
                    // {
                    //     Debug.LogError(btnType + " "+ stateType + "清理普攻缓存 " + Battle.Instance.frameCount + " frame1: " + frame + " frame2: " + iter.Value.frame);
                    // }
                    iter.Value.ClearCache();   
                }   
            }       
        }

        // 获取或创建按钮状态数据
        private PlayerBtnStateData _EnsureStateData(PlayerBtnType btnType)
        {
            _datas.TryGetValue(btnType, out var stateData);
            if (stateData == null)
            {
                stateData = ObjectPoolUtility.PlayerBtnStateDatas.Get();
                if (_datas.ContainsKey(btnType))
                {
                    _datas[btnType] = stateData;
                }
                else
                {
                    _datas.Add(btnType, stateData);
                }
            }
            return stateData;
        }
    }
}