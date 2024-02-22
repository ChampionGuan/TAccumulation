using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/动作")]
    [Name(("SetGlobalCD"))]
    [Description("设置【全局技能间隔】")]
    public class NASetGlobalCD : BattleAction
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<float> globalSkillCD = new BBParameter<float>();
        
        protected override void OnExecute()
        {
            var actor = target.isNoneOrNull ? _actor : target.value;
            if (actor == null)
            {
                EndAction(false);
                return;
            }
            actor.aiOwner?.SetGlobalCD(globalSkillCD.value);
            EndAction(true);
        }
    }
}
