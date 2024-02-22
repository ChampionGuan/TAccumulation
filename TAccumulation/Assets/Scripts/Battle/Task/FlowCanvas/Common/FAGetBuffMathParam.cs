using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("获取BuffMathParam\nGetBuffMathParam")]
    public class FAGetBuffMathParam : FlowAction
    {
        public BBParameter<MathParamType> MathParamType = new BBParameter<MathParamType>(X3Battle.MathParamType.MathParam1);

        protected override void _OnRegisterPorts()
        {
            AddValueOutput<List<float>>("MathParamList", () =>
            {
                // DONE: 数组.
                var buff = _source as X3Buff;
                if (buff == null)
                {
                    _LogError("请联系策划【卡宝】,【获取BuffMathParam GetBuffMathParam】请放置Buff图里使用.");
                    return null;
                }

                if (buff.isDestroyed)
                {
                    return null;
                }
                
                var buffLevelConfig = TbUtil.GetBuffLevelConfig(buff);
                if (buffLevelConfig == null)
                {
                    _LogError($"请联系策划【卡宝】,【获取BuffMathParam GetBuffMathParam】BuffLevelConfig没有ID={buff.ID}, Level={buff.level}的数据配置.");
                    return null;
                }

                var mathParamType = MathParamType.GetValue();
                float[] results = BattleUtil.GetBuffMathParam(buffLevelConfig, mathParamType);
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
