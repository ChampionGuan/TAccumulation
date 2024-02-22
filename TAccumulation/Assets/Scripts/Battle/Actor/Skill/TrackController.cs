using System.Collections.Generic;

namespace X3Battle
{
    public class TrackController
    {
        private SkillOwner _skillOwner;
        /// <summary>
        ///  存储的track禁用信息
        /// </summary>
        private List<TrackEnableInfo> _enableInfos;
        

        public TrackController(SkillOwner owner)
        {
            _enableInfos = new List<TrackEnableInfo>();
            _skillOwner = owner;
        }
        public void AddEnableInfo(TrackEnableInfo info)
        {
            _enableInfos.Add(info);
        }

        public void SetEnableInfo()
        {
            foreach (var enableInfo in _enableInfos)
            {
                SetEnableInfo(enableInfo);
            }
        }

        public void SetEnableInfo(TrackEnableInfo info)
        {
            //禁用技能track
            var skillSlot = _skillOwner?.GetSkillSlot(info.skillSlotType, info.skillSlotIndex);
            if (skillSlot == null)
            {
                return;
            }

            if (skillSlot.skill is SkillTimeline skillTimeline)
            {
                skillTimeline.curBattleSequencer?.EnableLogicSquenceTrack(info.enable, info.tags);
            }
        }

        public void Clear()
        {
            //还原所有track的禁用状态
            foreach (var enableInfo in _enableInfos)
            {
                var skillSlot = _skillOwner?.GetSkillSlot(enableInfo.skillSlotType, enableInfo.skillSlotIndex);
                if (skillSlot == null)
                {
                    return;
                }

                if (skillSlot.skill is SkillTimeline skillTimeline)
                {
                    skillTimeline.curBattleSequencer?.logicSequencer?.EnableTrack();
                }
            }

            _enableInfos.Clear();
        }
    }
}