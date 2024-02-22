using System;

namespace X3Battle
{
    public class PlayerHate : ActorHate
    {
        private bool _isInit;
        private Action<EventActorBase> _actionMonsterActive;
        protected override void OnAwake()
        {
            base.OnAwake();
            _actionMonsterActive = _OnMonsterAIActive;
            _isInit = false;
            _isPlayerFriend = false;
            WeaponLogicConfig weaponLogicConfig = BattleUtil.GetCurrentWeaponLogicConfig();
            if (weaponLogicConfig == null)
            {
                PapeGames.X3.LogProxy.LogError($"PlayerHate:武器数据ID={actor.battle.arg.girlWeaponID}缺失!");
                return;
            }
            TbUtil.TryGetCfg(weaponLogicConfig.StrategyID, out BattleWomanStrategy womanStrategy);
            if (womanStrategy == null)
            {
                PapeGames.X3.LogProxy.LogError($"PlayerHate:女主策略数据ID={weaponLogicConfig.StrategyID}缺失!");
                return;
            }
            _updateHateCd = weaponLogicConfig.ChangeTargetCD;
            _monsterTypePoints = womanStrategy.HateMonsterTypePoint;
            _cameraPoints = womanStrategy.HateCameraPoint;
            _distancePoints = womanStrategy.HateDistancePoint;
            
            _upSqrDistance = new float[womanStrategy.UpDistance.Length];
            for (int i = 0; i < womanStrategy.UpDistance.Length; i++)
            {
                _upSqrDistance[i] = womanStrategy.UpDistance[i] * womanStrategy.UpDistance[i];
            }
            _hateSqrRadius = TbUtil.battleConsts.RoleHateRange * TbUtil.battleConsts.RoleHateRange;
        }

        public override void OnBorn()
        {
            base.OnBorn();
            _isInit = true;
            UpdateHates();
            SelectHate();
            battle.eventMgr.AddListener(EventType.MonsterActive, _actionMonsterActive, "PlayerHate._OnMonsterActive");
            battle.eventMgr.Dispatch(EventType.UpdateFriendHate, null);
        }
        
        public override void OnRecycle()
        {
            _isInit = false;
            battle.eventMgr.RemoveListener(EventType.MonsterActive, _actionMonsterActive);
            base.OnRecycle();
        }

        /// <summary>
        /// 更新仇恨目标
        /// </summary>
        protected override void SelectHate()
        {
            if (!_isInit)
            {
                return;
            }
            _SelectRoleHate(_hates, true);
        }

        protected override HateDataBase CreateHate(Actor actor)
        {
            PlayerHateData playerHate = ObjectPoolUtility.PlayerHateData.Get();
            playerHate.insId = actor.insID;
            playerHate.lockable = !actor.stateTag?.IsActive(ActorStateTagType.LockIgnore) ?? true;
            playerHate.active = actor.aiOwner?.isActive ?? true;
            playerHate.threatenPoint = actor.monsterCfg?.HatePoint ?? 0;
            return playerHate;
        }

        /// <summary>
        /// 怪物激活
        /// </summary>
        /// <param name="actorBase"></param>
        private void _OnMonsterAIActive(EventActorBase actorBase)
        {
            for (int i = 0; i < _hates.Count; i++)
            {
                PlayerHateData hate = _hates[i] as PlayerHateData;
                if (hate.insId == actorBase.actor.insID)
                {
                    hate.active = true;
                    break;
                }
            }
        }

        public void PlayerIsHated()
        {
            battle.player.aiOwner.SetCombatTreeStatus(ActorAIStatus.Attack);
            battle.actorMgr.boy?.aiOwner.SetCombatTreeStatus(ActorAIStatus.Attack);
        }
    }
}