using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("播放BGM\nPlayBGM")]
    public class FAPlayBGM : FlowAction
    {
        public BBParameter<string> bgmName = new BBParameter<string>();

        protected override void _OnRegisterPorts()
        {
            var output = AddFlowOutput("Out");
            AddFlowInput("In", flow =>
            {
                string musicName = bgmName.GetValue();
                // DONE: 播放BGM
                BattleEnv.ClientBridge?.PlayMusic(TbUtil.battleConsts.BGMEventName, musicName, TbUtil.battleConsts.BGMStateGroupName, true);
                // DONE: 直接出.
                output.Call(flow);
            });
        }
    }
}
