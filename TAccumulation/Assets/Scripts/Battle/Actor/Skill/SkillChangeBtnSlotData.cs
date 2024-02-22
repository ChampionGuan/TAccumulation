using System.Collections.Generic;

namespace X3Battle
{
    public class SkillChangeBtnSlotData
    {
        private Dictionary<PlayerBtnType, int> _dictionary = new Dictionary<PlayerBtnType, int>(10);
        private SkillOwner _owner;
        
        public SkillChangeBtnSlotData(SkillOwner owner)
        {
            this._owner = owner;
        }
        
        public void SetData(PlayerBtnType playerBtnType, int slotID)
        {
            _dictionary[playerBtnType] = slotID;
            
            // 不用事件，直接调用性能更高, 通知UI层替换技能按钮
            var skillSlot = _owner.GetSkillSlot(slotID);
            if (skillSlot != null)
            {
                BattleEnv.LuaBridge.SetSkillSlot(_owner.actor, playerBtnType, skillSlot);
            }
        }

        public int? TryGetSlotID(PlayerBtnType playerBtnType)
        {
            int? result = null;
            if (_dictionary.TryGetValue(playerBtnType, out int slotID))
            {
                result = slotID;
            }

            return result;
        }

        public void Clear()
        {
            _dictionary.Clear();
        }
    }
}