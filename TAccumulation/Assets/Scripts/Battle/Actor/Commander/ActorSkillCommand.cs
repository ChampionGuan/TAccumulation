using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [MessagePackObject]
    public class ActorSkillCommand : ActorCmd
    {
        [Key(0)] public int slotId;
        [Key(1)] public int targetID;
        [Key(3)] public int? casterId;

        [Key(5)] public PlayerBtnType? playerBtnType;
        [Key(6)] public bool isUI;
        [Key(7)] public X3Vector3? curPlayerInputPos;

        public ActorSkillCommand()
        {
        }

        /// <param name="slotID">槽位ID</param>
        /// <param name="target">攻击目标，为空则由目标锁定系统重新筛选</param>
        /// <param name="casterID">技能释放者，为nil则所有者释放技能</param>
        /// <param name="isUi">是否需要Cache</param>
        /// <param name="playerBtnType">cache类型</param>
        public void Init(int slotID, int targetID = BattleConst.InvalidActorID, int? casterID = null, bool isUi = false, PlayerBtnType? playerBtnType = null, Vector3? _curPlayerInputPos = null)
        {
            this.slotId = slotID;
            this.targetID = targetID;
            this.casterId = casterID;
            this.isUI = isUi;
            this.playerBtnType = playerBtnType;
            if (_curPlayerInputPos != null)
            {
                this.curPlayerInputPos = _curPlayerInputPos.Value;
            }
        }

        protected override void _OnReset()
        {
            base._OnReset();
            this.slotId = 0;
            this.targetID = 0;
            this.casterId = 0;
            this.isUI = false;
            this.playerBtnType = PlayerBtnType.Attack;
            this.curPlayerInputPos = null;
        }

        protected override void _OnEnter()
        {
            // 设置释放者和释放者朝向
            var caster = actor;
            if (casterId != null)
            {
                caster = actor.battle.actorMgr.GetActor(casterId.Value);
            }

            if (caster == null)
            {
                return;
            }

            if (isUI)
            {
                // 技能指令顺便把DestDir同步给Caster
                if (caster.IsPlayer() && curPlayerInputPos != null)
                {
                    caster.SetDestDir(curPlayerInputPos.Value);
                }
                _UILogic(caster);
            }
            else
            {
                _AILogic(caster);
            }

            this.Finish();
        }

        // UI过来的逻辑
        private void _UILogic(Actor caster)
        {
            var target = caster.battle.actorMgr.GetActor(this.targetID);
            // UI过来的释放技能指令跟Down绑定, 获取当前槽位SlotID（内部已经处理了连招逻辑）
            var curSlotID = caster.skillOwner.TryGetCurSlotID(playerBtnType.Value, PlayerBtnStateType.Down);

            // TODO 稳了之后彻底删除
            // //  辉耀二测临时加一个潜规则，后面删掉：按下这一刻，如果没Down有Up，并且相同按钮有跑技能，就什么也不做跳出
            // var curSlot = caster.skillOwner.currentSlot;
            // if (curSlot != null && (int)curSlot.slotType == (int)playerBtnType.Value)
            // {
            //     var upSlotID = caster.skillOwner.TryGetLinkSlotID(playerBtnType.Value, PlayerBtnStateType.Up);
            //         if (upSlotID != null)
            //         {
            //             var downSlotID =  caster.skillOwner.TryGetLinkSlotID(playerBtnType.Value, PlayerBtnStateType.Down);
            //             if (downSlotID == null)
            //             {
            //                 return;
            //             }
            //         }
            // }

            if (curSlotID == null) return;
            // 尝试释放技能
            var result = caster.skillOwner.TryCastSkillBySlot(curSlotID.Value, target, stateType: PlayerBtnStateType.Down);
            if (result)
            {
                // 此处技能释放成功，就消耗掉Down缓存
                caster.input.TryConsumeCache(playerBtnType.Value, PlayerBtnStateType.Down);
            }

            // Todo:冰冻下点击攻击键会执行破冰逻辑,后面如果新加了破冰按钮的话，就新加个指令
            if(playerBtnType.Value == PlayerBtnType.Attack)
                caster.frozen?.BreakFrozen();
        }

        // AI过来的逻辑
        private void _AILogic(Actor caster)
        {
            var target = caster.battle.actorMgr.GetActor(this.targetID);
            caster.skillOwner.TryCastSkillBySlot(slotId, target);

            // 理论上上面接口就够了
            // if (tempActor.skillOwner.CanCastSkillBySlot(slotId, false, notCheckPriority))
            // {
            //     tempActor.skillOwner.TryCastSkillBySlot(slotId, target, !notCheckPriority);
            // }
            // else if (actor.skillOwner.IsActiveSkillLink(slotId))
            // {
            //     tempActor.skillOwner.TryCastSkillBySlot(slotId, target, false);
            // }
        }
    }
}
