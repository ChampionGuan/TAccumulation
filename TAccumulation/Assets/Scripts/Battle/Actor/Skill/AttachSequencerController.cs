using System.Collections.Generic;
using PapeGames.X3;
using XAssetsManager;

namespace X3Battle
{
    /// <summary>
    /// 技能新增的动作模组控制器
    /// </summary>
    public class AttachSequencerController
    {
        public struct SequencerInfo
        {
            public SkillSlotType skillSlotType { get; set; }
            public int skillSlotIndex { get; set; }
            public HashSet<int> sequencerIds { get; set; }
        }

        private SkillOwner _owner;
        /// <summary>
        /// 存储的增加动作模组信息 key = 技能ID value = 增加的动作模组
        /// </summary>
        private List<SequencerInfo> _infos;
        
        public AttachSequencerController(SkillOwner owner)
        {
            _infos =  new List<SequencerInfo>();
            _owner = owner;
        }
        public void CreateSequencers()
        {
            foreach (var info in _infos)
            {
                var skillSlot = _owner.GetSkillSlot(info.skillSlotType, info.skillSlotIndex);
                if (skillSlot == null)
                {
                    continue;
                }

                if (skillSlot.skill is SkillTimeline skillTimeline)
                {
                    foreach (var sequencerId in info.sequencerIds)
                    {
                        if (!skillTimeline.IsCreateAddSequence())
                        {
                            skillTimeline.CreateAddSequences(sequencerId);
                        }
                    }
                }
            }
        }
        
        public void AddInfo(SequencerInfo sequencerInfo)
        {
            LogProxy.LogFormat("增加动作模组 SkillSlotType = {0} skillSlotIndex = {1} sequencerIds = {2}",
                sequencerInfo.skillSlotType, sequencerInfo.skillSlotIndex, sequencerInfo.sequencerIds);
            
            foreach (var info in _infos)
            {
                if (info.skillSlotIndex == sequencerInfo.skillSlotIndex &&
                    info.skillSlotType == sequencerInfo.skillSlotType)
                {
                    info.sequencerIds.AddRange(sequencerInfo.sequencerIds);
                    return;
                }
            }
            
            _infos.Add(sequencerInfo);
        }
        
        public void Clear()
        {
            _infos.Clear();
        }
    }
}