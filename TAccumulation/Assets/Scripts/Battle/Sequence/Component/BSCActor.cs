namespace X3Battle
{
    public class BSCActor: BSCBase, IReset
    {
        protected override void _OnInit()
        {
            // 处理关卡Actor.
            var actionContext = _battleSequencer.bsCreateData.bsActionContext;
            var actor = actionContext?.actor;
            if (actor != null && actor.type == ActorType.Stage)
            {
                _BuildStageSkill(actor);
            }
        }

        public void Reset()
        {
        }

        private void _BuildStageSkill(Actor actor)
        {
            var bindCom = _battleSequencer.GetComponent<BSCTrackBind>();
            bindCom.notBindCreator = true;
            bindCom.manModel = actor.battle.actorMgr.boy?.GetDummy(ActorDummyType.Model).gameObject;
            bindCom.womanModel = actor.battle.actorMgr.girl?.GetDummy(ActorDummyType.Model).gameObject;
        }
    }
}