using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断buff是否有某个指定类别和标签\nFCBuffHasTTags")]
    public class FCBuffHasTTags : FlowCondition
    {
        private ValueInput<IBuff> _buffInput;
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
            _buffInput = AddValueInput<IBuff>(nameof(IBuff));
        }

        protected override bool _IsMeetCondition()
        {
            var buff = _buffInput.GetValue();
            if (buff != null)
            {
                var result = buff.MatchTypeAndTag(buffType, buffTypeTag, buffMultipleTags,buffConflictTag,ignoreBuffType,ignoreBuffTag,ignoreBuffMultipleTags);
                return result;
            }
            return false;
        }
    }
}