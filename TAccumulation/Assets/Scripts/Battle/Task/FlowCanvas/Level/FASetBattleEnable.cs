using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("设置战斗暂停(恢复)\nSetBattlePause")]
    public class FASetBattleEnable : FlowAction
    {
        public BBParameter<bool> enable = new BBParameter<bool>();

        protected override void _Invoke()
        {
            LogProxy.LogFormat("【新手引导】【设置战斗暂停(恢复)】Graph:{0}, enable:{1}", this._graphOwner.name, enable.value);
            _battle.SetWorldEnable(enable.value, BattleEnabledMask.LevelFlow);
            if (!enable.value)
            {
                BattleEnv.LuaBridge.UpdateBtnState();
            }
        }
    }
}
