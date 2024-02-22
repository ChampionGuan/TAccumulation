using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/怪物出生TipUI")]
    [Serializable]
    public class BornTipUIAsset : BSActionAsset<ActionBornTipUI>
    {
        // // 怪物prefab路径
        // [LabelText("怪物展示UI路径")]
        // public string monsterUIPath;
    }

    public class ActionBornTipUI : BSAction<BornTipUIAsset>
    {
        protected override void _OnEnter()
        {
            if (context.actor.bornCfg.ControlBornPerform)
            {
                if (TbUtil.HasCfg<BattleBossIntroduction>(context.actor.cfgID))
                {
                    BattleEnv.LuaBridge.ShowBossIntroductionUiTip(context.actor.cfgID,remainTime);
                }
                else
                {
                    PapeGames.X3.LogProxy.LogError($"怪物 {context.actor.cfgID} 的battleBossIntroductions表没配对应数据！"); 
                }
            }
        }
    }
}