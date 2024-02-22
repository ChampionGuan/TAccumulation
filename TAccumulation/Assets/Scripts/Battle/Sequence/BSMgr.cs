using System;
using System.Collections.Generic;

namespace X3Battle
{
    public class BSMgr
    {
        // bs进度改变 (目前是编辑器下运行时显示调试信息用，真机逻辑用不到)
        public static event Action<string, float> OnBSTimeChange;
        
        // BS销毁时的回调
        public event Action<BattleSequencer> OnBSDestroy;
        private List<BattleSequencer> _sequencers;
        private BSContext _context;
        private bool _isDestroy;

        public BSMgr()
        {
            this._sequencers = new List<BattleSequencer>();
            this._context = new BSContext();
            _isDestroy = false;
        }

        public BattleSequencer CreateBS(BSType type, BSCreateData bsCreateData)
        {
            var bs = ObjectPoolUtility.BS.Get();
            bs.Init(this, type, _context, bsCreateData);
            return bs;
        }

        private void _ReleaseBS(BattleSequencer battleSequencer)
        {
            ObjectPoolUtility.BS.Release(battleSequencer);
        }
        
        /// <summary>
        /// 更新方法，外部调用驱动BS更新
        /// </summary>
        /// <param name="deltaTime">帧间隔时间</param>
        public void Update(float deltaTime)
        {
            // 取消补帧
            _Update(deltaTime);
        }

        public void _Update(float deltaTime)
        {
            for (int i = _sequencers.Count - 1; i >= 0; i--)
            {
                var bs = _sequencers[i];
                bs.Update(deltaTime);

                // 有可能在Tick中就把自己销毁了
                if (_isDestroy)
                {
                    return;   
                }

                if (bs.bsState == BSState.Destroy)
                {
                    // 销毁状态直接移除
                    _sequencers.RemoveAt(i);
                    OnBSDestroy?.Invoke(bs);
                    _ReleaseBS(bs);
                }
#if UNITY_EDITOR
                else if(bs.bsState == BSState.Playing)
                {
                    // 非销毁状态同步时间, 只有编辑器下才有同步需求
                    var name = bs.name;
                    var time = bs.GetTime();
                    OnBSTimeChange?.Invoke(name, time);
                }
#endif
            }    
        }

        public void LateUpdate()
        {
            for (int i = _sequencers.Count - 1; i >= 0; i--)
            {
                var bs = _sequencers[i];
                bs.LateUpdate();
            }
        }

        // 销毁函数
        public void Destroy()
        {
            for (int i = _sequencers.Count - 1; i >= 0; i--)
            {
                var bs = _sequencers[i];
                if (!bs.IsDestroyed())
                {
                    bs.Destroy();
                    _ReleaseBS(bs);
                }
            }
            _sequencers.Clear();
            _isDestroy = true;
        }

        // 友元函数，外部不要调用
        public void __OnBSPlay(BattleSequencer battleSequencer)
        {
            _sequencers.Add(battleSequencer);
        }
    }
}