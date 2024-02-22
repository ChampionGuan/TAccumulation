using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor/Function")]
    [Name("获取PassiveMathParam\nGetPassiveMathParam")]
    public class FAGetPassiveMathParam : FlowAction
    {
        public BBParameter<MathParamType> MathParamType = new BBParameter<MathParamType>(X3Battle.MathParamType.MathParam1);

        protected override void _OnRegisterPorts()
        {
            AddValueOutput<List<float>>("MathParamList", () =>
            {
                // DONE: 数组.
                var skill = _source as SkillPassive;
                if (skill == null)
                {
                    _LogError("请联系策划【卡宝】,【获取PassiveMathParam GetPassiveMathParam 】请放置被动skill图里使用.");
                    return null;
                }

                if (skill.levelConfig == null)
                    return null;

                var mathParamType = MathParamType.GetValue();
                float[] results = BattleUtil.GetSkillMathParam(skill.levelConfig, mathParamType);
                var list = new List<float>();
                if (results != null && results.Length > 0)
                {
                    foreach (var f in results)
                    {
                        list.Add(f);
                    }
                }

                return list;
            });
        }
    }
}
