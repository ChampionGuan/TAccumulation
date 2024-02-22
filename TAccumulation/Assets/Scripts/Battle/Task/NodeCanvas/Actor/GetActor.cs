using ParadoxNotion.Design;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("获取战斗单位")]
    public class GetActor : BattleAction
    {
        public BBParameter<bool> byConfigID = new BBParameter<bool>();
        [Name("SpawnID")]
        public BBParameter<int> insID = new BBParameter<int>();
        public BBParameter<int> configID = new BBParameter<int>();
        public BBParameter<Actor> storeResult = new BBParameter<Actor>();

        protected override void OnExecute()
        {
            var isByConfig = !byConfigID.isNoneOrNull && byConfigID.value;
            storeResult.value = isByConfig ? _battle.actorMgr.GetActor(insID.value) : _battle.actorMgr.GetActorByCfgID(configID.value, includeSummoner: false);
            EndAction(true);
        }
//
// #if UNITY_EDITOR
//
//         protected override void OnTaskInspectorGUI() {
//             if (!byConfigID.isNoneOrNull && byConfigID.value)
//             {
//                 
//             }
//             else
//             {
//                 
//             }
//         }
// #endif
    }
}
