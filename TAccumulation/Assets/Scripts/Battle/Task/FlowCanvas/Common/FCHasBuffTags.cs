using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("是否有某个指定类别和标签的Buff\nHasBuffTags")]
    public class FCHasBuffTTags : FlowCondition
    {
        private ValueInput<Actor> _viBuffOwner;
        [Name("buff类别1")]
        public BuffTag buffTypeTag = BuffTag.Buff;
        [Name("无视类别1")]
        public bool ignoreBuffTag = false;
        [Name("buff类别2")]
        public BuffType buffType = BuffType.Attribute;
        [Name("无视类别2")]
        public bool ignoreBuffType = false;
        [Name("buff类别3")]
        public int buffMultipleTags = 0;
        [Name("无视类别3")]
        public bool ignoreBuffMultipleTags = true;
        [Name("状态标签")]
        public int buffConflictTag = 0;

        protected override void _OnAddPorts()
        {
            _viBuffOwner = AddValueInput<Actor>("BuffOwner");
        }

        protected override bool _IsMeetCondition()
        {
            var actor = _viBuffOwner.GetValue();
            if (actor == null || actor.buffOwner == null)
                return false;
            int buffID = actor.buffOwner.FindFirstMatchBuff(buffType, buffTypeTag, buffMultipleTags,buffConflictTag,ignoreBuffType,ignoreBuffTag,ignoreBuffMultipleTags);
            return buffID != 0;
        }
    }
}
