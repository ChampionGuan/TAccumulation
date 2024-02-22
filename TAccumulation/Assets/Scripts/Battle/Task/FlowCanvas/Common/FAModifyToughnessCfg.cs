using System.Collections;
using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;
using X3Battle;

namespace X3Battle
{
    [System.ComponentModel.Category("X3Battle/Actor/Action")]
    [Name("修正伤害盒攻击等级\nModifyToughnessCfg")]
    public class FAModifyToughnessCfg : FlowAction
    {
        public BBParameter<int> damageBoxID = new BBParameter<int>();
        public BBParameter<ModifyCfgType> modifyMode = new BBParameter<ModifyCfgType>();
        public BBParameter<float> value = new BBParameter<float>();

        protected override void _Invoke()
        {
            var damageBoxId = damageBoxID.GetValue();

            var damageBoxCfg = TbUtil.GetCfg<DamageBoxCfg>(damageBoxId);
            if (damageBoxCfg == null)
            {
                _LogError("[修正伤害盒攻击等级 ModifyToughnessCfg]节点配置错误. 配置的DamageId不存在.");
                return;
            }

            switch (modifyMode.value)
            {
                case ModifyCfgType.Add:
                    damageBoxCfg.ToughnessReduce += value.GetValue();
                    break;
                case ModifyCfgType.Sub:
                    damageBoxCfg.ToughnessReduce -= value.GetValue();
                    break;
                case ModifyCfgType.Set:
                    damageBoxCfg.ToughnessReduce = value.GetValue();
                    break;
            }
            
        }
    }
}
