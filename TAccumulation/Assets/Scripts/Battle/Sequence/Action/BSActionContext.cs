using X3Battle.Timeline.Extension;

namespace X3Battle
{
    public class BSActionContext :PreviewActionIContext
    {
        private SkillActive _skill;
        public SkillActive skill => _skill;
        
        private Actor _actor;
        public Actor actor => _actor;
        
        private Battle _battle;
        public Battle battle => _battle;

        // 通过Battle创建， 只有battle
        public BSActionContext(X3Battle.Battle battleParam)
        {
            _ClearField();
            _battle = battleParam;
        }
        
        // 通过Actor创建， 有actor、battle
        public BSActionContext(Actor actorParam)
        {
            _ClearField();
            _actor = actorParam;
            _battle = _actor.battle;
        }
        
        // 通过技能创建， 有技能、actor、battle
        public BSActionContext(SkillActive skillParam)
        {
            _ClearField();
            _skill = skillParam;
            _actor = _skill.actor;
            _battle = _actor.battle;
        }

        private void _ClearField()
        {
            _skill = null;
            _actor = null;
            _battle = null;
        }
    }
}