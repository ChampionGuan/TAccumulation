using System.Collections.Generic;

namespace X3Battle
{
    public class SkillLinkData
    {
        private Dictionary<int, SkillLinkDataItem> _links;
        public Dictionary<int, SkillLinkDataItem> links => _links;

        private Dictionary<int, SkillLinkDataItem> _dodgeOffsetDatas = new Dictionary<int, SkillLinkDataItem>(8);
        private HashSet<object> _dodgeActiveObjs = new HashSet<object>();

        public SkillLinkData()
        {
            _links = new Dictionary<int, SkillLinkDataItem>();
        }

        private int _GetHashCodeByType(PlayerBtnType playerBtnType, PlayerBtnStateType btnStateType)
        {
            return (int)playerBtnType * 1000 + (int)btnStateType;
        }

        /// <summary>
        /// 获取槽位ID
        /// </summary>
        /// <param name="playerBtnType"></param>
        /// <param name="btnStateType">按钮状态判断，如果null则所有状态都可以</param>
        /// <returns>槽位id，不存在返回null</returns>
        public int? TryGetLinkSlotID(PlayerBtnType playerBtnType, PlayerBtnStateType btnStateType)
        {
            // 优先判断连招
            var hash = _GetHashCodeByType(playerBtnType, btnStateType);
            _links.TryGetValue(hash, out var skillLink);
            if (skillLink != null && skillLink.IsActive())
            {
                var slotID = skillLink.slotID;   
                return slotID;
            }
            
            // 再判断dodgeOffset
            if (_dodgeActiveObjs.Count > 0 && _dodgeOffsetDatas.Count > 0)
            {
                _dodgeOffsetDatas.TryGetValue(hash, out var dodgeData);
                if (dodgeData != null)
                {
                    var slotID = dodgeData.slotID;
                    return slotID;
                }
            }
            return null;
        }
        
        /// <summary>
        /// 某个槽位ID是否在激活的连招中
        /// </summary>
        /// <param name="slotID"></param>
        /// <param name="btnStateType">按钮状态判断，如果null则所有状态都可以</param>
        /// <returns></returns>
        public bool IsActiveSkillLink(int slotID, PlayerBtnStateType? btnStateType = null)
        {
            foreach (var iter in _links)
            {
                var skillLink = iter.Value;
                if (skillLink.IsActive() && skillLink.slotID == slotID)
                {
                    if (btnStateType == null || btnStateType.Value == skillLink.btnStateType)
                    { 
                        return true;  
                    }
                }
            }
            return false;
        }

        // 添加普攻dodgeOffset功能
        public void AddDodgeOffsetData(int slotID, int debugSkillID)
        {
            var curSkillLink = ObjectPoolUtility.SkillLink.Get();
            curSkillLink.Init(PlayerBtnType.Attack, slotID, debugSkillID, -1, PlayerBtnStateType.Down);
            var hash = _GetHashCodeByType(curSkillLink.playerBtnType, curSkillLink.btnStateType);
            _dodgeOffsetDatas[hash] = curSkillLink;
        }

        // 激活 dodgeOffset
        public void ActiveDodgeOffset(bool isActive, object owner)
        {
            if (isActive)
            {
                _dodgeActiveObjs.Add(owner);
            }
            else
            {
                _dodgeActiveObjs.Remove(owner);
            }
        }
        
        /// <summary>
        /// 当前激活技能的SkillLink事件
        /// </summary>
        /// <param name="playerBtnType"></param>
        /// <param name="soltID"></param>
        /// <param name="debugSkillID"></param>
        /// <param name="duration"></param>
        public void AddLinkDataItem(PlayerBtnType playerBtnType, int soltID, int debugSkillID, float duration, PlayerBtnStateType btnStateType)
        {
            var hash = _GetHashCodeByType(playerBtnType, btnStateType);
            _links.TryGetValue(hash, out var skillLink);
            if (skillLink != null)
            {
                skillLink.Destroy();
                ObjectPoolUtility.SkillLink.Release(skillLink);
            }
            var curSkillLink = ObjectPoolUtility.SkillLink.Get();
            curSkillLink.Init(playerBtnType, soltID, debugSkillID, duration, btnStateType);
            _links[hash] = curSkillLink;
        }

        /// <summary>
        /// 更新函数
        /// </summary>
        /// <param name="deltaTime"></param>
        List<int> deleteKeys = new List<int>();
        public void Update(float deltaTime)
        {
            deleteKeys.Clear();
            foreach (var item in _links)
            {
                item.Value.Update(deltaTime);
                  // -- 超时的直接销毁
                  if (!item.Value.IsActive())
                  {
                      item.Value.Destroy();
                      deleteKeys.Add(item.Key);
                  }
            }

            for (int i = 0; i < deleteKeys.Count; i++)
            {
                var key = deleteKeys[i];
                var value = _links[key];
                ObjectPoolUtility.SkillLink.Release(value);
                _links.Remove(key);
            }
        }

        // 处理DodgeOffset数据，保留一部分数据，并且将连招按钮状态改为down，只保留 【按键类型】为attack类型，并且【输入状态】不为Hold的连招数据
        public void EvalDodgeOffset()
        {
            // 清除连招数据
            _ClearLinks();
            
            // // 插入新数据
            // foreach (var item in _dodgeOffsetDatas)
            // {
            //     AddLinkDataItem(item.playerBtnType, item.slotID, item.skillID, -1f, item.btnStateType);
            // }
            //
            // // 清除dodge数据
            // _ClearDodgeOffsets();
        }

        // 当技能结束时，skillOwner调用清理当前技能数据
        public void Clear()
        {
            _ClearLinks();
            _ClearDodgeOffsets();
        }

        private void _ClearLinks()
        {
            foreach (var iter in _links)
            {
                iter.Value.Destroy();
                ObjectPoolUtility.SkillLink.Release(iter.Value);
            }
            _links.Clear();
        }
        
        private void _ClearDodgeOffsets()
        {
            foreach (var item in _dodgeOffsetDatas)
            {
                item.Value.Destroy();
                ObjectPoolUtility.SkillLink.Release(item.Value);
            }
            _dodgeOffsetDatas.Clear();
            _dodgeActiveObjs.Clear();
        }
        
        // 销毁
        public void Destroy()
        {
            Clear();
        }
        
    }
}