using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("跳转至技能所属的某个动作模组\nSkillGotoActionModule")]
    public class FASkillGotoActionModule : FlowAction
    {
        public BBParameter<int> actionModuleIndex = new BBParameter<int>();

        protected override void _Invoke()
        {
            var index = actionModuleIndex.GetValue();
            if (!(_source is SkillTimeline skillTimeline))
            {
                return;
            }

            if (index < 0)
            {
                _LogError("请联系策划【卡宝】,【FC】【跳转至技能所属的某个动作模组 SkillGotoActionModule】节点【actionModuleIndex】参数配置错误, 索引不能小于0");
                return;
            }
            skillTimeline.SwitchActionModule(index);
        }
    }
}
