using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using XAssetsManager;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("增加动作模组\nAddSequence")]
    public class FAAddSequence : FlowAction
    {
        public BBParameter<SkillSlotType> skillSlotType = new BBParameter<SkillSlotType>(SkillSlotType.SkillID);
        public BBParameter<int> skillSlotIndex = new BBParameter<int>(0);
        public BBParameter<List<int>> actionModule = new BBParameter<List<int>>();
        public BBParameter<HeroType> heroType = new BBParameter<HeroType>();
        
        //todo 
        protected override void _Invoke()
        {
            Actor target = null;
            if (heroType.value == HeroType.Boy)
            {
                target = _battle.actorMgr?.boy;
            }
            else
            {
                target = _battle.actorMgr?.girl;
            }
            
            if (target == null)
            {
                _LogError("请联系策划【楚门】,【激活(禁用)Track轨道】heroType, 目前为null");
                return;
            }
            if (target.skillOwner == null)
            {
                _LogError($"请联系策划【楚门】,【激活(禁用)Track轨道】_viActor的引脚没有正确配置, {target.name}没有SkillOwner组件.");
                return;
            }
            AttachSequencerController.SequencerInfo info = new AttachSequencerController.SequencerInfo();
            info.skillSlotIndex = skillSlotIndex.value;
            info.skillSlotType = skillSlotType.value;
            info.sequencerIds = actionModule.value.ToHashSet();
            target.skillOwner.attachSequencerController.AddInfo(info);
        }
    }
}
