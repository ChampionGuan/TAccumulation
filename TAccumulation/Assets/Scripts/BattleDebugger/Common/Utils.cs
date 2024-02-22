#if DEBUG_GM || UNITY_EDITOR
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using PapeGames.X3;
using UnityEngine;
using X3.PlayableAnimator;
using Debug = UnityEngine.Debug;

namespace X3Battle.Debugger
{
    public class Utils
    {
        public static object GetFieldInfo(object ins, string fieldName, bool includingBaseType = true)
        {
            if (null == ins)
            {
                return null;
            }

            FieldInfo fieldInfo = null;
            var baseType = ins.GetType();
            while (null != baseType)
            {
                fieldInfo = baseType.GetField(fieldName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
                if (null != fieldInfo)
                {
                    break;
                }

                if (!includingBaseType)
                {
                    break;
                }

                baseType = baseType.BaseType;
            }

            return fieldInfo?.GetValue(ins);
        }

        public static void SetFieldInfo(object ins, string fieldName, object fieldValue)
        {
            if (null == ins)
            {
                return;
            }

            var fieldInfo = ins.GetType().GetField(fieldName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
            if (null == fieldInfo)
            {
                return;
            }

            fieldInfo.SetValue(ins, fieldValue);
        }

        public static object GetPropertyInfo(object ins, string propertyName, bool includingBaseType = true)
        {
            if (null == ins)
            {
                return null;
            }

            PropertyInfo propertyInfo = null;
            var baseType = ins.GetType();
            while (null != baseType)
            {
                propertyInfo = baseType.GetProperty(propertyName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
                if (null != propertyInfo)
                {
                    break;
                }

                if (!includingBaseType)
                {
                    break;
                }

                baseType = baseType.BaseType;
            }

            if (propertyInfo != null && propertyInfo.CanRead)
            {
                return propertyInfo.GetValue(ins);
            }

            return null;
        }

        public static void SetPropertyInfo(object ins, string propertyName, object propertyValue)
        {
            if (null == ins)
            {
                return;
            }

            var propertyInfo = ins.GetType().GetProperty(propertyName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
            if (null == propertyInfo)
            {
                return;
            }

            if (!propertyInfo.CanWrite)
            {
                var setterMethod = propertyInfo.GetSetMethod(true);
                if (setterMethod != null)
                {
                    setterMethod.Invoke(ins, new[] { propertyValue });
                }
                else
                {
                    var fieldInfo = GetBackingFieldForProperty(propertyInfo);
                    if (fieldInfo != null)
                    {
                        fieldInfo.SetValue(ins, propertyValue);
                    }
                }
				return;
            }

            propertyInfo.SetValue(ins, propertyValue);
        }
        
        public static FieldInfo GetBackingFieldForProperty(PropertyInfo propertyInfo)
        {
            string backingFieldName = $"<{propertyInfo.Name}>k__BackingField"; // 构造隐式字段的命名规则
            return propertyInfo.DeclaringType.GetFields(BindingFlags.NonPublic | BindingFlags.Instance).FirstOrDefault(f => f.Name == backingFieldName); // 查找符合条件的隐式字段
        }

        public static void ForceIdle(Actor actor)
        {
            if (null == actor || actor.isRecycled) return;
            // 移除所有异常态
            if (null != actor.mainState)
            {
                var list = new List<ActorMainState.AbnormalInfo>();
                actor.mainState.GetAllAbnormalInfo(list);
                foreach (var abnormal in list)
                {
                    actor.mainState.TryEndAbnormal(abnormal.type, abnormal.adder);
                }
            }

            // 强制进入Idle
            actor.ForceIdle();
        }

        public static void PrintActorInfo(int type)
        {
            var actorMgr = Battle.Instance?.actorMgr;
            if (null == actorMgr) return;

            var result = "";
            // 打印女主信息
            if (type == 0 || type == 3)
            {
                if (null == actorMgr.girl) return;
                result += $"{GetActorInfo(actorMgr.girl)}\n";
            }

            // 打印男主信息
            if (type == 1 || type == 3)
            {
                if (null == actorMgr.boy) return;
                result += $"{GetActorInfo(actorMgr.boy)}\n";
            }

            // 打印所有怪信息
            if (type == 2 || type == 3)
            {
                var actors = new List<Actor>();
                actorMgr.GetActors(ActorType.Monster, null, actors);
                foreach (var actor in actors)
                {
                    result += $"{GetActorInfo(actor)}\n";
                }
            }

            if (!string.IsNullOrEmpty(result))
            {
                Debug.LogWarning(result);
            }
        }

        public static string GetActorInfo(Actor actor)
        {
            if (null == actor)
            {
                return "BattleDebug:GetActorInfo actor 为 null";
            }

            var result = $"{actor.name}   {actor.insID}\n";

            result += "\n被动技能:\n";
            if (null != actor.skillOwner)
            {
                var skillSlots = actor.skillOwner.slots;
                foreach (var iter in skillSlots)
                {
                    var skill = iter.Value.skill;
                    if (!skill.IsPositive())
                    {
                        result += $"\tSkillID: {skill.GetID()}, Name: {skill.config.Name}, Level: {skill.level} \n";
                    }
                }
            }

            result += "\nBuff信息:\n";
            if (null != actor.buffOwner)
            {
                var buffs = actor.buffOwner.GetBuffs();
                foreach (var buff in buffs)
                {
                    if (null != buff)
                    {
                        result += $"\tID: {buff.ID} , Name:{buff.config.Name}, 层数: {buff.layer}, 当前时长: {buff.leftTime}\n";
                    }
                }
            }

            result += "\n基础标签:\n";
            if (null != actor.stateTag)
            {
                var stateTags = (List<ActorStateTagType>)GetFieldInfo(actor.stateTag, "_stateTags");
                foreach (var tag in stateTags)
                {
                    result += $"\t{tag.ToString()}\n";
                }
            }

            result += "\n异常状态:\n";
            if (null != actor.mainState)
            {
                result += $"当前: {actor.mainState.abnormalType.ToString()}\n";
                var abnormalTypes = (List<ActorAbnormalType>)GetFieldInfo(actor.mainState, "_abnormalTypes");
                result += "生效中: \n";
                foreach (var abnormalType in abnormalTypes)
                {
                    result += $"\t{abnormalType.ToString()}\n";
                }
            }

            return result;
        }

        public static bool IsNeedRecord()
        {
            return PerformanceDebugger.GetDebugKey(PerformanceDebugger.RecordeReplayFile);
        }

        public static bool IsDisableTimelineFX()
        {
            return PerformanceDebugger.GetDebugKey(PerformanceDebugger.DisableTimelineFX);
        }

        private static bool _showFriendUI = true;

        public static bool ShowFriendUI
        {
            get => _showFriendUI;
            set
            {
                if (value == _showFriendUI) return;
                _showFriendUI = value;
                var eventData = Battle.Instance.eventMgr.GetEvent<EventDebugHideUI>();
                eventData.Init(DebugUIHideType.FriendUI, _showFriendUI);
                Battle.Instance.eventMgr.Dispatch(EventType.DebugHideUI, eventData);
            }
        }

        private static bool _showEnemyUI = true;

        public static bool ShowEnemyUI
        {
            get => _showEnemyUI;
            set
            {
                if (value == _showEnemyUI) return;
                _showEnemyUI = value;
                var eventData = Battle.Instance.eventMgr.GetEvent<EventDebugHideUI>();
                eventData.Init(DebugUIHideType.EnemyUI, _showEnemyUI);
                Battle.Instance.eventMgr.Dispatch(EventType.DebugHideUI, eventData);
            }
        }

        private static bool _showOperatingTips = true;

        public static bool ShowOperatingTips
        {
            get => _showOperatingTips;
            set
            {
                if (value != _showOperatingTips)
                {
                    _showOperatingTips = value;
                    var eventData = Battle.Instance.eventMgr.GetEvent<EventDebugHideUI>();
                    eventData.Init(DebugUIHideType.OperatingTips, _showOperatingTips);
                    Battle.Instance.eventMgr.Dispatch(EventType.DebugHideUI, eventData);
                }

                Battle.Instance.playerSelectFx.SetFxActive(value);
            }
        }

        private static bool _showJumpWords = true;

        public static bool ShowJumpWords
        {
            get => _showJumpWords;
            set
            {
                if (value == _showJumpWords) return;
                _showJumpWords = value;
                var eventData = Battle.Instance.eventMgr.GetEvent<EventDebugHideUI>();
                eventData.Init(DebugUIHideType.JumpWords, _showJumpWords);
                Battle.Instance.eventMgr.Dispatch(EventType.DebugHideUI, eventData);
            }
        }

        private static bool _showCommunicateUI = true;

        public static bool ShowCommunicateUI
        {
            get => _showCommunicateUI;
            set
            {
                if (value == _showCommunicateUI) return;
                _showCommunicateUI = value;
                var eventData = Battle.Instance.eventMgr.GetEvent<EventDebugHideUI>();
                eventData.Init(DebugUIHideType.CommunicateUI, _showCommunicateUI);
                Battle.Instance.eventMgr.Dispatch(EventType.DebugHideUI, eventData);
            }
        }

        private static bool _showOutScreenTipUI = true;

        public static bool ShowOutScreenTipUI
        {
            get => _showOutScreenTipUI;
            set
            {
                if (value == _showOutScreenTipUI) return;
                _showOutScreenTipUI = value;
                var eventData = Battle.Instance.eventMgr.GetEvent<EventDebugHideUI>();
                eventData.Init(DebugUIHideType.OutScreenTipUI, _showOutScreenTipUI);
                Battle.Instance.eventMgr.Dispatch(EventType.DebugHideUI, eventData);
            }
        }


        public static bool GetDebugBattle()
        {
            return BattleEnv.DontEndBattleNonManual;
        }

        public static void SetDebugBattle(bool debugBattle)
        {
            BattleEnv.DontEndBattleNonManual = debugBattle;
            SetPropertyInfo(Battle.Instance.levelFlow, "lifeTime", debugBattle ? 86400 : Battle.Instance.config.TimeLimit);
        }

        public static void SetCameraType(CameraModeType modeType)
        {
            Battle.Instance.cameraTrace.SetCameraMode(modeType);
        }

        public static CameraModeType GetCameraType()
        {
            return Battle.Instance.cameraTrace.currMode;
        }

        //---切换武器 start---
        public static void ChangeWeapon(int curSkinId, int lastSkinId)
        {
            Battle.Instance.player.weapon.TryRemoveWeapon();
            Battle.Instance.arg.girlWeaponID = curSkinId == 0 ? 71010 : curSkinId;
            Battle.Instance.player.weapon.TryAddWeapon();

            Battle.Instance.player.skillOwner.TryEndSkill();
            UpdatePlayerWeaponConfig(curSkinId, lastSkinId);

            string animatorName = _GenAnimatorConf();
            Battle.Instance.player.animator.OnStart(Battle.Instance.player, animatorName);

            var animator = Battle.Instance.player.animator;
            var ctrl = AnimatorController.CopyInstance(animator.runtimeAnimatorController);

            Battle.Instance.eventMgr.Dispatch(EventType.RefreshSlotData, null);

            List<StateMotion> states = new List<StateMotion>();
            List<StateMotion> playStates = new List<StateMotion>();
            AnimatorController animatorController = null;
            animatorController = Battle.Instance.player.animator.runtimeAnimatorController;
            if (animatorController == null)
            {
                LogProxy.LogFormat("主角的AnimatorController为空");
                return;
            }

            var layer1 = animatorController.GetLayer(0);
            for (int i = 0; i < layer1.statesCount; i++)
            {
                StateMotion state = layer1.GetState<StateMotion>(i);
                if (StateIsUsable(state))
                {
                    states.Add(layer1.GetState<StateMotion>(i));
                }
            }

            states.Sort((a, b) => string.Compare(a.name, b.name));
            AnimatorController playController = ScriptableObject.Instantiate(animatorController);
            var layer2 = playController.GetLayer(0);
            for (int i = 0; i < layer2.statesCount; i++)
            {
                StateMotion state = layer2.GetState<StateMotion>(i);
                if (StateIsUsable(state))
                {
                    playStates.Add(state);
                }
            }

            playStates.Sort((a, b) => string.Compare(a.name, b.name));
        }

        public static bool StateIsUsable(StateMotion state)
        {
            if (!state.isBlendTree && (state.motion as ClipMotion).clip == null)
            {
                return false;
            }

            return true;
        }

        public static void UpdatePlayerWeaponConfig(int curSkinId, int lastSkinId = 0)
        {
            RoleBornCfg bornCfg = Battle.Instance.player.roleBornCfg;
            UpdateGirlWeaponConfig(bornCfg, curSkinId, lastSkinId);
        }

        public static void UpdateGirlWeaponConfig(RoleBornCfg bornCfg, int curSkinId, int lastSkinId = 0)
        {
            if (lastSkinId > 0)
            {
                var lastLogicCfg = TbUtil.GetWeaponLogicConfigBySkinId(lastSkinId);
                if (lastLogicCfg != null)
                {
                    RemoveSkillSlotByConfigIds(bornCfg, SkillSlotType.Attack, lastLogicCfg.AttackIDs);
                    RemoveSkillSlotByConfigIds(bornCfg, SkillSlotType.Active, lastLogicCfg.ActiveSkillIDs);
                    RemoveSkillSlotByConfigIds(bornCfg, SkillSlotType.Born, lastLogicCfg.BornSkillIDs);
                    RemoveSkillSlotByConfigIds(bornCfg, SkillSlotType.Passive, lastLogicCfg.PassiveSkillIDs);
                    RemoveSkillSlotByConfigIds(bornCfg, SkillSlotType.Dodge, lastLogicCfg.DodgeSkillIDs);
                    RemoveSkillSlotByConfigIds(bornCfg, SkillSlotType.Dead, lastLogicCfg.DeadSkillIDs);
                }
            }

            WeaponSkinConfig curSkinConfig = TbUtil.GetCfg<WeaponSkinConfig>(curSkinId);
            if (curSkinConfig == null)
            {
                LogProxy.LogError(string.Format("【UpdateGirlWeaponConfig】武器皮肤(id ={0})配置错误", curSkinId));
                return;
            }
            
            WeaponLogicConfig curLogicCfg = TbUtil.GetCfg<WeaponLogicConfig>(curSkinConfig.WeaponLogicID);
            if (curLogicCfg == null)
            {
                LogProxy.LogError(string.Format("【UpdateGirlWeaponConfig】武器逻辑(id ={0})配置错误", curSkinConfig.WeaponLogicID));
                return;
            }

            CreateSkillSlotByConfigIds(bornCfg, SkillSlotType.Attack, curLogicCfg.AttackIDs);
            CreateSkillSlotByConfigIds(bornCfg, SkillSlotType.Active, curLogicCfg.ActiveSkillIDs);
            CreateSkillSlotByConfigIds(bornCfg, SkillSlotType.Born, curLogicCfg.BornSkillIDs);
            CreateSkillSlotByConfigIds(bornCfg, SkillSlotType.Passive, curLogicCfg.PassiveSkillIDs);
            CreateSkillSlotByConfigIds(bornCfg, SkillSlotType.Dodge, curLogicCfg.DodgeSkillIDs);
            CreateSkillSlotByConfigIds(bornCfg, SkillSlotType.Dead, curLogicCfg.DeadSkillIDs);
        }

        public static void RemoveSkillSlotByConfigIds(RoleBornCfg roleBornCfg, SkillSlotType slotType, int[] skillConfigIds)
        {
            if (skillConfigIds == null)
            {
                return;
            }

            for (int i = 0; i < skillConfigIds.Length; i++)
            {
                _RemoveSkillSlot(roleBornCfg, slotType, i);
            }
        }

        private static void _RemoveSkillSlot(RoleBornCfg roleBornCfg, SkillSlotType skillSlotType, int index)
        {
            int slotId = BattleUtil.GetSlotID(skillSlotType, index);
            roleBornCfg.SkillSlots.Remove(slotId);
            Battle.Instance.player.skillOwner.RemoveSkillSlot(slotId);
        }

        public static void CreateSkillSlotByConfigIds(RoleBornCfg roleBornCfg, SkillSlotType slotType, int[] skillConfigIds)
        {
            if (skillConfigIds == null)
            {
                return;
            }

            IDLevel[] idLevels = BattleUtil.CreateIdLevels(skillConfigIds);
            for (int i = 0; i < idLevels.Length; i++)
            {
                _AddSkillSlot(roleBornCfg, slotType, i, idLevels[i]);
            }
        }

        private static void _AddSkillSlot(RoleBornCfg roleBornCfg, SkillSlotType skillSlotType, int index, IDLevel skillIdLevel)
        {
            int slotId = BattleUtil.GetSlotID(skillSlotType, index);
            int skillId = skillIdLevel.ID;
            int skillLevel = skillIdLevel.Level;
            SkillSlotConfig skillSlotConfig = new SkillSlotConfig
            {
                ID = slotId,
                SlotType = skillSlotType,
                SkillID = skillId,
                SkillLevel = skillLevel,
            };
            roleBornCfg.SkillSlots[skillSlotConfig.ID] = skillSlotConfig;
            Battle.Instance.player.skillOwner.CreateSkillSlotByDebugEditor(slotId, skillId, skillLevel);
        }

        /// <summary>
        /// 根据score 和 武器 重新生成女主动画状态机名称
        /// </summary>
        /// <returns></returns>
        private static string _GenAnimatorConf()
        {
            var boyId = Battle.Instance.player.battle.arg.boyID;
            var girlSkinId = Battle.Instance.player.battle.arg.girlWeaponID;

            if (Battle.Instance.player.IsGirl())
            {
                string animatorName = BattleUtil.GenGirlAnimatorCtrlName(girlSkinId, boyId);
                if (animatorName != null)
                {
                    Battle.Instance.player.bornCfg.AnimatorCtrlName = animatorName;
                    return animatorName;
                }
                else
                {
                    LogProxy.LogError($"角色状态机获取失败：武器id={girlSkinId}, scoreID={boyId}");
                }
            }

            return "";
        }

        //---切换武器 end---
        public static void ClearFriendSkillsCd()
        {
            BattleUtil.ClearFriendSkillsCdForEditor();
        }

        public static void RemoveRole(int actorId)
        {
            Actor actor = Battle.Instance.actorMgr.GetActor(actorId);
            actor?.Dead();
        }

        public static void SetUnlimitedHp(int actorId, bool unlimitedHp)
        {
            Actor actor = Battle.Instance.actorMgr.GetActor(actorId);
            if (actor == null)
            {
                return;
            }

            Attribute hpAttr = actor.attributeOwner.GetAttr(AttrType.HP);
            Attribute maxHpAttr = actor.attributeOwner.GetAttr(AttrType.MaxHP);
            if (unlimitedHp)
            {
                maxHpAttr.Add(100000000, 0, 0);
                hpAttr.Add(100000000, 0, 0);
            }
            else
            {
                maxHpAttr.Sub(100000000, 0, 0);
                hpAttr.Sub(100000000, 0, 0);
            }
        }

        public static bool IsUnlimitedHp(int actorId)
        {
            Actor actor = Battle.Instance.actorMgr.GetActor(actorId);
            if (actor == null)
            {
                return false;
            }

            return actor.attributeOwner.GetAttrValue(AttrType.MaxHP) > 100000000;
        }

        /// <summary>
        /// 释放技能
        /// </summary>
        /// <param name="actorId"></param>
        /// <param name="skillId"></param>
        /// <param name="targetId"></param>
        public static void CastSkill(int actorId, int skillId, int targetId)
        {
            if (BattleEnv.NoCdForPlayerSkills)
            {
                Battle.Instance.ClearSkillsCd(actorId);
            }

            Actor actor = Battle.Instance.actorMgr.GetActor(actorId);
            var slotIdVar = actor.skillOwner.GetSlotIDBySkillID(skillId);
            if (slotIdVar == null)
            {
                return;
            }

            ActorSkillCommand cmd = ObjectPoolUtility.GetActorCmd<ActorSkillCommand>();
            cmd.Init(slotIdVar.Value, targetId);
            actor.commander.TryExecute(cmd);
        }

        /// <summary>
        /// 释放技能
        /// </summary>
        /// <param name="actorId"></param>
        /// <param name="skillId"></param>
        /// <param name="targetId"></param>
        public static void CastSkillByEditor(int actorId, int skillId)
        {
            Actor actor = Battle.Instance.actorMgr.GetActor(actorId);
            var slotIdVar = actor.skillOwner.GetSlotIDBySkillID(skillId);
            if (slotIdVar == null)
            {
                return;
            }

            SkillSlot skillSlot = actor.skillOwner.GetSkillSlot(slotIdVar.Value);
            if (!skillSlot.skill.IsPositive())
            {
                Debug.LogError("被动技能不支持手动释放");
                return;
            }

            //ClearSkillsCd(actorId);
            actor.skillOwner.TryCastSkillBySlot(slotIdVar.Value, safeCheck: false);
        }

        public static int GetActorHp(int actorId)
        {
            return Mathf.RoundToInt(Battle.Instance.actorMgr.GetActor(actorId).attributeOwner.GetAttrValue(AttrType.HP));
        }

        public static void SetActorHp(int actorId, int hp)
        {
            var attrOwner = Battle.Instance.actorMgr.GetActor(actorId).attributeOwner;
            attrOwner.SetAttrValueByDebugEditor(AttrType.MaxHP, hp);
            attrOwner.SetAttrValueByDebugEditor(AttrType.HP, hp);
        }

        public static int GetActorAttack(int actorId)
        {
            return Mathf.RoundToInt(Battle.Instance.actorMgr.GetActor(actorId).attributeOwner.GetAttrValue(AttrType.PhyAttack));
        }

        public static void SetActorAttack(int actorId, int attack)
        {
            var attrOwner = Battle.Instance.actorMgr.GetActor(actorId).attributeOwner;
            attrOwner.SetAttrValueByDebugEditor(AttrType.PhyAttack, attack);
        }

        public static void SetAttr(Attribute attr, float value)
        {
            attr.SetByDebugEditor(value);
        }

        public static float GetAttr(Attribute attr)
        {
            return attr.GetValue();
        }

        public static void SetBornMonstersToIdle(Actor filterActor)
        {
            foreach (Actor actor in Battle.Instance.actorMgr.actors)
            {
                if (actor == filterActor || !actor.IsMonster() || !actor.mainState.IsState(ActorMainStateType.Born))
                {
                    continue;
                }

                actor.ForceIdle();
            }
        }

        public static void SetAiState(int actorId, bool enableAi)
        {
            Actor actor = Battle.Instance.actorMgr.GetActor(actorId);
            if (actor == null)
            {
                return;
            }

            actor.aiOwner?.DisableAI(!enableAi, AISwitchType.Debug);
            actor.aiOwner?.SetIsStrategy(enableAi);
            if (!enableAi)
            {
                actor.commander?.ClearMoveCmd();
            }
        }

        public static bool AiSwitchIsOn(Actor actor)
        {
            return actor.aiOwner != null && actor.aiOwner.SwitchIsOn(AISwitchType.Debug);
        }

        public static Vector3 GetActorPosition(int actorId)
        {
            Actor actor = Battle.Instance.actorMgr.GetActor(actorId);
            if (actor == null)
            {
                return Vector3.zero;
            }

            return actor.transform.position;
        }

        public static void AddWeak(int actorId)
        {
            Actor actor = Battle.Instance.actorMgr.GetActor(actorId);
            actor?.attributeOwner.GetAttr(AttrType.WeakPoint).Set(0);
            actor?.actorWeak.ShieldBreak();
        }

        public static void AddShield(int actorId)
        {
            Actor actor = Battle.Instance.actorMgr.GetActor(actorId);
            actor?.attributeOwner.GetAttr(AttrType.WeakPoint).Add(5, 0, 0);
        }

        public static void SetSkillTime(int actorId, int skillId, int time)
        {
            Actor actor = Battle.Instance.actorMgr.GetActor(actorId);
            if (actor == null)
            {
                return;
            }

            var curSkill = actor.skillOwner.GetSkillByDebugEditor(skillId);
            curSkill?.SetLength(time);
        }

        public static void CreateRole(int actorCfgId, int actorSuitID, int actorSpawnId, float x, float y, float z, bool ai, bool isFriend, bool bornProcess, bool bornCamera)
        {
            if (!TbUtil.HasCfg<ActorCfg>(actorCfgId))
            {
                return;
            }

            FactionType factionType = isFriend ? FactionType.Hero : FactionType.Monster;
            Vector3 position = new Vector3(x, y, z);
            Battle.Instance.player.commander?.TryExecute(new CreateRoleCmd(actorCfgId, actorSuitID, position, ai, factionType, actorSpawnId, bornProcess, bornCamera));
        }

        private static int _buffSortFun(DebugBuff buff1, DebugBuff buff2)
        {
            if (buff1.id < buff2.id)
            {
                return -1;
            }
            else if (buff1.id > buff2.id)
            {
                return 1;
            }

            return 0;
        }

        private static int _intSortFun(int id1, int id2)
        {
            if (id1 < id2)
            {
                return -1;
            }
            else if (id1 > id2)
            {
                return 1;
            }

            return 0;
        }

        public static List<DebugBuff> GetDebugBuffList()
        {
            List<DebugBuff> buffs = new List<DebugBuff>();
            DebugBuff buff = null;
            foreach (var buffConfigsItem in TbUtil.buffCfgs)
            {
                var buffConfig = buffConfigsItem.Value;
                int id = buffConfig.ID;
                int level = 1; //buffConfig.Level;
                if (buff != null && buff.id != id)
                {
                    List<string> levelStrList = new List<string>();
                    buff.levels.Sort(_intSortFun);
                    for (int j = 0; j < buff.levels.Count; j++)
                    {
                        levelStrList.Add(buff.levels[j].ToString());
                    }

                    buff.levelStrs = levelStrList.ToArray();
                    buff = null;
                }

                if (buff == null)
                {
                    buff = new DebugBuff();
                    buff.id = id;
                    buff.name = id + buffConfig.Name;
                    buff.levelIndex = 0;
                    buff.levels = new List<int>();
                    buffs.Add(buff);
                }

                buff.levels.Add(level);
            }

            buffs.Sort(_buffSortFun);
            return buffs;
        }

        public static void SetCameraDistance(float distance)
        {
            Battle.Instance.cameraTrace.SetDistanceFactor(distance);
        }

        public static int GetCameraDistance()
        {
            return Mathf.RoundToInt(Battle.Instance.cameraTrace.GetDistanceFactor());
        }

        public static void SetCameraFov(float fov)
        {
            Battle.Instance.cameraTrace.SetFov(Mathf.RoundToInt(fov));
        }

        public static int GetCameraFov()
        {
            return Battle.Instance.cameraTrace.GetFov();
        }

        public static void SetPlaySpeed(float speed)
        {
            BattleClient.Instance.SetUnityTimescale(speed / 100);
        }

        public static int GetPlaySpeed()
        {
            return Mathf.RoundToInt(BattleClient.Instance.GetUnityTimescale() * 100);
        }

        public static void SetGameFrame(int gameFrame)
        {
            Application.targetFrameRate = gameFrame;
        }

        public static int GetGameFrame()
        {
            return Application.targetFrameRate;
        }

        public static void AddBuff(Actor actor, int id, int level)
        {
            actor.buffOwner.Add(id, 1, null, level, actor);
        }

        public static void RemoveBuff(Actor actor, int id)
        {
            actor.buffOwner.Remove(id);
        }

        public static void ReduceBuffLayer(Actor actor, int id)
        {
            actor.buffOwner.ReduceStack(id, 1);
        }
        
        /// <summary>
        /// 获得Roll奖励次数；by 伟龙
        /// </summary>
        /// <returns></returns>
        public static int GetRollEntryTimes()
        {
            if (Battle.Instance.rogue == null)
            {
                return 0;
            }
            return Battle.Instance.rogue.rogueEntriesLibrary.RollTimes;
        }
        
        /// <summary>
        /// 设置Roll奖励次数；by 伟龙
        /// </summary>
        /// <param name="rollTimes"></param>
        public static void SetRollEntryTimes(int rollTimes)
        {
            if (Battle.Instance.rogue == null)
            {
                return;
            }
            Battle.Instance.rogue.rogueEntriesLibrary.SetRollTimes(rollTimes);
        }
        
        /// <summary>
        /// 添加额外奖励；by 伟龙
        /// </summary>
        /// <param name="id"></param>
        public static void AddExtraRollEntryParam(int id)
        {
            if (Battle.Instance.rogue == null)
            {
                return;
            }
            Battle.Instance.rogue.AddExtraRollEntryParam(id);
        }
        
        /// <summary>
        /// 移除额外奖励；by 伟龙
        /// </summary>
        /// <param name="rogueEntriesExtraRollParam"></param>
        public static void RemoveExtraRollEntryParam(RogueEntriesExtraRollParam rogueEntriesExtraRollParam)
        {
            if (Battle.Instance.rogue == null)
            {
                return;
            }
            Battle.Instance.rogue.RemoveExtraRollEntryParam(rogueEntriesExtraRollParam);
        }
        
        /// <summary>
        /// 获得额外奖励列表；by 伟龙
        /// </summary>
        /// <returns></returns>
        public static List<RogueEntriesExtraRollParam> GetRogueEntriesExtraRollParams()
        {
            if (Battle.Instance.rogue == null)
            {
                return null;
            }
            return Battle.Instance.rogue.extraEntriesRollParamList;
        }

        /// <summary>
        /// 获得Roll门次数；by 三夕
        /// </summary>
        /// <returns></returns>
        public static int GetRollDoorTimes()
        {
            if (Battle.Instance.rogue == null)
            {
                return 0;
            }
            return Battle.Instance.rogue.rollDoorTimes;
        }
        
        /// <summary>
        /// 设置Roll门次数；by 三夕
        /// </summary>
        /// <param name="rollTimes"></param>
        public static void SetRollDoorTimes(int rollTimes)
        {
            if (Battle.Instance.rogue == null)
            {
                return;
            }
            Battle.Instance.rogue.rollDoorTimes = rollTimes;
        }

        /// <summary>
        /// 添加词条；by 伟龙
        /// </summary>
        /// <param name="id"></param>
        /// <param name="level"></param>
        public static void AddEntry(int id, int level)
        {
            if (Battle.Instance.rogue == null || !TbUtil.HasCfg<RogueEntryCfg>(id))
            {
                return;
            }
            Battle.Instance.rogue.rogueEntriesLibrary.AddEntry(new RogueEntry(TbUtil.GetCfg<RogueEntryCfg>(id)));
            Battle.Instance.rogue.AddTrophyData(RogueRewardType.Entry, id, level);
        }
        
        /// <summary>
        /// 移除词条；by 伟龙
        /// </summary>
        /// <param name="entry"></param>
        public static void RemoveEntry(RogueEntry entry)
        {
            if (Battle.Instance.rogue == null)
            {
                return;
            }
            Battle.Instance.rogue.rogueEntriesLibrary.RemoveEntry(entry);
            Battle.Instance.rogue.RemoveTrophyData(RogueRewardType.Entry, entry.ID);
        }
        
        /// <summary>
        /// 获取词条列表；by 伟龙
        /// </summary>
        /// <returns></returns>
        public static List<RogueEntry> GetEntryList()
        {
            if (Battle.Instance.rogue == null)
            {
                return null;
            }
            return  Battle.Instance.rogue.rogueEntriesLibrary.CurrentObtainEntriesList;
        }
        
        

        public static List<DebugAttr> GetDebugAttrs(Actor actor)
        {
            List<DebugAttr> attrs = new List<DebugAttr>();
            foreach (var attrItem in actor.attributeOwner.attrs)
            {
                Attribute attr = attrItem.Value;
                if (attr.GetAttrType() == AttrType.HP || attr.GetAttrType() == AttrType.MaxHP ||
                    attr.GetAttrType() == AttrType.PhyAttack)
                {
                    continue;
                }

                DebugAttr debugAttr = new DebugAttr();
                debugAttr.type = attr.GetAttrType();
                debugAttr.attr = attr;
                debugAttr.name = debugAttr.type.ToString();
                debugAttr.value = attr.GetValue();
                attrs.Add(debugAttr);
            }

            return attrs;
        }

        public static Dictionary<int, int> GetActorSuitInfosByCfgID(int cfgID)
        {
            var list = new List<int>();
            TbUtil.GetActorSuitIDsByCfgID(cfgID, list);
            Dictionary<int, int> infos = new Dictionary<int, int>();
            foreach (var suitID in list)
            {
                if (TbUtil.TryGetCfg(suitID, out ActorSuitCfg suitCfg))
                {
                    infos[suitID] = suitCfg.NameID;
                }
            }

            return infos;
        }
        
        /// <summary>
        /// 跳层；by 老艾
        /// </summary>
        /// <param name="debugRogueCfgs"></param>
        /// <param name="startIndex"></param>
        /// <param name="endIndex"></param>
        public static void JumpRogueLayer(List<DebugRogueCfg> debugRogueCfgs, int startIndex, int endIndex)
        {
            var rogueGameplay = Battle.Instance.rogue;
            var saveData = BattleUtil.ReadRogueLocalData();
            var saveArg = (RogueArg)rogueGameplay.arg.Clone();
            saveData.Arg = saveArg;
            saveArg.LayerDatas.RemoveAt(saveArg.LayerDatas.Count - 1);

            for (int i = startIndex; i <= endIndex; i++)
            {
                DebugRogueCfg curDebugRogueCfg = debugRogueCfgs[i];
                DebugRogueLevelCfg curDebugRogueLevelCfg = curDebugRogueCfg.levelCfgs[curDebugRogueCfg.levelIndex];
                RogueLayerData rogueLayerData = new RogueLayerData();
                rogueLayerData.LayerID = curDebugRogueCfg.id;
                rogueLayerData.LevelID = curDebugRogueLevelCfg.id;
                rogueLayerData.TrophyDatas = new List<RogueTrophyData>();

                if (i < endIndex && curDebugRogueLevelCfg.rewardCfgs.Count > 0)
                {
                    DebugRogueRewardCfg curRogueRewardCfg = curDebugRogueLevelCfg.rewardCfgs[curDebugRogueLevelCfg.rewardIndex];
                    RogueTrophyData trophyData = new RogueTrophyData()
                    {
                        LayerID = curDebugRogueCfg.id,
                        Type = curDebugRogueLevelCfg.rewardType,
                        IsReceive = true,
                    };
                    trophyData.Data = new RogueEntryRewardData { ID = curRogueRewardCfg.id, Level = 1 };
                    rogueLayerData.TrophyDatas.Add(trophyData);
                }
                saveArg.LayerDatas.Add(rogueLayerData);
            }
            
            BattleUtil.SaveRogueLocalData(saveData);
        }

        /// <summary>
        /// 获取Rogue玩法当前层的配置数据.
        /// </summary>
        /// <returns></returns>
        public static BattleRogueConfig GetCurrentRogueConfig()
        {
            return Battle.Instance?.rogue?.config;
        }

        /// <summary>
        /// 获取Rogue玩法当前关的配置数据.
        /// </summary>
        /// <returns></returns>
        public static BattleRogueLevelConfig GetCurrentRogueLevelConfig()
        {
            return Battle.Instance?.rogue?.levelConfig;
        }

        /// <summary>
        /// 获取Rogue玩法当前层的配置数据.
        /// </summary>
        /// <returns></returns>
        public static BattleRogueConfig GetNextRogueConfig()
        {
            var currRogueConfig = GetCurrentRogueConfig();
            if (currRogueConfig == null)
            {
                return null;
            }

            var nextRogueConfig = TbUtil.GetCfg<BattleRogueConfig>(currRogueConfig.NextID);
            return nextRogueConfig;
        }
        
        /// <summary>
        /// 切换自动模式和手动模式，目前锁定模式只有AI和Smart 只在editor下使用
        /// </summary>
        /// <param name="ai"></param>
        [Conditional("UNITY_EDITOR"),Conditional("DEBUG_GM")]
        public static void TrySwitchAuto(bool ai)
        {
            var actor = Battle.Instance.player;
            if (actor == null)
            {
                return;
            }

            using (ProfilerDefine.EditorTrySwitchAutoPMarker.Auto())
            {
                Battle.Instance.input.SetLockMode(ai ? TargetLockModeType.AI : TargetLockModeType.Smart);
                //TODO,移到某个指令中
                actor.aiOwner?.DisableAI(!ai,
                    AISwitchType.Player | AISwitchType.Active | AISwitchType.Debug | AISwitchType.Revive |
                    AISwitchType.ActionModule);
                actor.commander.ClearCmd();
                // 清除输入缓存
                actor.input?.ClearCache();
            }
        }
        
        /// <summary>
        /// 在启动游戏后调用
        /// 测试自动战斗入口 注意只给自动测试战斗调用！！！
        /// 3006 200011 1 210101 2101 71010  //测试参数
        /// </summary>
        /// <param name="levelID"></param>
        /// <param name="girlSuitID"></param>
        /// <param name="girlID"></param>
        /// <param name="boySuitID"></param>
        /// <param name="boyID"></param>
        /// <param name="girlWeaponID"></param>
        [Conditional("UNITY_EDITOR"),Conditional("DEBUG_GM")]
        public static void TestStartBattle(int levelID, int girlSuitID, int girlID, int boySuitID, int boyID, int girlWeaponID)
        {
            var battleArg = new BattleArg
            {
                isNumberMode = true,
                replayPath = "",
                sceneName = "",
                startupType = BattleStartupType.OfflineQuickBattle,
                levelID = levelID,
                girlSuitID = girlSuitID,
                girlID = girlID,
                boySuitID = boySuitID,
                boyID = boyID,
                girlWeaponID = girlWeaponID,
                isOpenAuto = true
            };

            var luaTable = BattleEnv.ClientBridge.DoLuaString("return require('Runtime.Battle.BattleLauncher')")[0];
            BattleEnv.ClientBridge.CallLuaFunction(luaTable, "StartupByCustom", new []{luaTable, battleArg }, out _);
        }
    }

    public class DebugExtraRewardCfg
    {
        public string[] rewardNames;
        public int rewardIndex;
        public List<int> entriesTagIds;
        public int entriesTagId => entriesTagIds[rewardIndex];
    }
    
    public class DebugRogueEntryCfg
    {
        public int id;
        public int lastId;
        public int level;
        public int lastLevel;
        public RogueEntryCfg rogueEntryCfg => TbUtil.GetCfg<RogueEntryCfg>(lastId);
    }
    
    public class DebugRogueCfg
    {
        public int id;
        public BattleRogueConfig cfg;
        public List<DebugRogueLevelCfg> levelCfgs;
        public string[] levelNames;
        public int levelIndex;
        public int lastLevelIndex;
    }

    public class DebugRogueLevelCfg
    {
        public int id;
        public int levelId;
        public string name;
        public string type;
        public RogueRewardType rewardType;
        public List<DebugRogueRewardCfg> rewardCfgs;
        public string[] rewardNames;
        public int rewardIndex;
        public int lastRewardIndex;
    }

    public class DebugRogueRewardCfg
    {
        public int id;
        public RogueRewardType type;
        public string name;

        public override string ToString()
        {
            return $"{id}-{name}";
        }
    }
}
#endif