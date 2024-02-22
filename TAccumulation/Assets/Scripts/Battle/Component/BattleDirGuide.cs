using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class BattleDirGuide : BattleComponent
    {
        public List<ActorDirGuide> _actorDirGuides;

        public BattleDirGuide() : base(BattleComponentType.BattleDirGuide)
        {
            requiredAnimationJobRunning = true;
        }

        protected override void OnAwake()
        {
            _actorDirGuides = new List<ActorDirGuide>(2);
        }

        protected override void OnAnimationJobRunning()
        {
            foreach (ActorDirGuide actorDirGuide in _actorDirGuides)
            {
                actorDirGuide.Update();
            }
        }

        private ActorDirGuide _FindActorDirGuide(Actor actor)
        {
            foreach (ActorDirGuide actorDirGuide in _actorDirGuides)
            {
                if (actorDirGuide.actor == actor)
                {
                    return actorDirGuide;
                }
            }

            return null;
        }

        public void AddActorDirGuide(int pointId, Actor actor = null)
        {
            PointConfig pointConfig = battle.actorMgr.GetPointConfig(pointId);
            if (pointConfig == null)
            {
                return;
            }
            actor = actor ?? battle.player;
            ActorDirGuide actorDirGuide = _FindActorDirGuide(actor);
            if (actorDirGuide != null)
            {
                actorDirGuide.targetPos = pointConfig.Position;
                return;
            }
            var fxPlayer = actor.effectPlayer.PlayFx(TbUtil.battleConsts.DirGuideFxId);
            if (fxPlayer == null)
            {
                return;
            }
            actorDirGuide = ObjectPoolUtility.ActorDirGuidePool.Get();
            actorDirGuide.actor = actor;
            actorDirGuide.fxPlayer = fxPlayer;
            actorDirGuide.targetPos = pointConfig.Position;
            _actorDirGuides.Add(actorDirGuide);
        }

        public void RemoveActorDirGuide(Actor actor = null)
        {
            actor = actor ?? battle.player;
            ActorDirGuide actorDirGuide = _FindActorDirGuide(actor);
            if (actorDirGuide != null)
            {
                _actorDirGuides.Remove(actorDirGuide);
                actorDirGuide.actor = null;
                actorDirGuide.fxPlayer.Stop();
                actorDirGuide.fxPlayer = null;
                ObjectPoolUtility.ActorDirGuidePool.Release(actorDirGuide);
            }
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            _actorDirGuides.Clear();
        }
    }

    public class ActorDirGuide
    {
        public Actor actor;
        public FxPlayer fxPlayer;
        public Vector3 targetPos;

        public void Update()
        {
            Vector3 forward = targetPos - actor.transform.position;
            forward.y = 0;
            fxPlayer.transform.forward = forward;
        }
    }
}