using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("销毁指定ID的法术场\nFADestroyMagicField")]
    public class FADestroyMagicField : FlowAction
    {
        public BBParameter<int> MagicFieldID = new BBParameter<int>();
        public BBParameter<bool> HasStopEffect = new BBParameter<bool>(true);

        protected override void _Invoke()
        {
            var magicFields = ObjectPoolUtility.CommonActorList.Get();
            Battle.Instance.actorMgr.GetActors(ActorType.SkillAgent, (int)SkillAgentType.MagicField, magicFields, cfgId: MagicFieldID.GetValue());
            foreach (var magicField in magicFields)
            {
                if (!HasStopEffect.GetValue())
                {
                    magicField.effectPlayer.StopBodyFX(true);
                }
                magicField.Dead();
            }
            ObjectPoolUtility.CommonActorList.Release(magicFields);
        }
    }
}
