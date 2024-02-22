using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("发送引导事件\nSendGuideEvent")]
    public class FASendGuideEvent : FlowAction
    {
        public BBParameter<string> eventName = new BBParameter<string>();
        
        protected override void _Invoke()
        {
            BattleEnv.LuaBridge.SendGuideEvent(eventName.value);
            LogProxy.LogFormat("【新手引导】【发送引导事件】Graph:{0}, 发送事件:{1}", this._graphOwner.name, eventName.value);
        }

#if UNITY_EDITOR
        protected override void OnNodeGUI()
        {
            base.OnNodeGUI();
            UnityEditor.EditorGUILayout.LabelField($"引导事件: {eventName.value}");
        }
#endif
    }
}
