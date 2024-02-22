using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public static class ActorExtension
    {
        public static bool IsPlayer(this Actor actor)
        {
            return actor == actor.battle.player;
        }

        public static bool IsRole(this Actor actor)
        {
            return actor.config is RoleCfg;
        }

        public static bool IsStage(this Actor actor)
        {
            return actor.type == ActorType.Stage;
        }

        public static bool IsGirl(this Actor actor)
        {
            return actor.type == ActorType.Hero && actor.subType == (int)HeroType.Girl;
        }

        public static bool IsBoy(this Actor actor)
        {
            return actor.type == ActorType.Hero && actor.subType == (int)HeroType.Boy;
        }

        public static bool IsBoss(this Actor actor)
        {
            return actor.type == ActorType.Monster && actor.subType == (int)MonsterType.Boss;
        }

        public static bool IsMonster(this Actor actor)
        {
            return actor.type == ActorType.Monster;
        }

        public static bool IsHeroOrHeroSummons(this Actor actor)
        {
            return actor.type == ActorType.Hero || (actor.master != null && actor.master.type == ActorType.Hero);
        }

        public static float GetSelectRadius(this Actor actor)
        {
            if (actor.type == ActorType.Monster)
            {
                return actor.monsterCfg.SelectRadius;
            }

            return 0;
        }

        /// <summary>
        /// 该Actor是否为道具
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        public static bool IsItem(this Actor actor)
        {
            return actor.type == ActorType.Item;
        }

        /// <summary>
        /// 该Actor是否为创生物.
        /// </summary>
        public static bool IsCreature(this Actor actor)
        {
            return actor.bornCfg.CreatureType != CreatureType.None;
        }

        /// <summary>
        /// 该Actor是否为假身
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        public static bool IsFakebody(this Actor actor)
        {
            return actor.bornCfg.CreatureType == CreatureType.Fakebody;
        }

        /// <summary>
        /// 该Actor是否为技能召唤物
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        public static bool IsSkillAgent(this Actor actor)
        {
            return actor.config.Type == ActorType.SkillAgent;
        }

        /// <summary>
        /// 该Actor是否为召唤物
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        public static bool IsSummoner(this Actor actor)
        {
            return null != actor.master;
        }

        /// <summary>
        /// 此单位的master是否为目标master
        /// </summary>
        /// <param name="actor"></param>
        /// <param name="master"></param>
        /// <returns></returns>
        public static bool IsSummonedActor(this Actor actor, Actor master = null)
        {
            if (null == master || null == actor.master)
            {
                return false;
            }

            return master == actor.master;
        }

        /// <summary>
        /// 获取此单位的所有创生物
        /// </summary>
        /// <param name="summonID"> BattleSummon.ID(可以为null, 为null时即统计该actor召唤的所有创生物) </param>
        /// <param name="outActors"> 用于接收统计的创生物 </param>
        /// <returns></returns>
        public static int GetCreatures(this Actor master, int? summonID = null, List<Actor> outActors = null)
        {
            var count = 0;
            outActors?.Clear();
            var actors = master.battle.actorMgr.actors;
            for (var i = 0; i < actors.Count; i++)
            {
                var actor = actors[i];
                if (actor.isDead || !actor.IsCreature() || actor.master != master) continue;
                if (null != summonID && actor.bornCfg.SummonID != summonID) continue;
                count++;
                outActors?.Add(actor);
            }

            return count;
        }

        /// <summary>
        /// 是否为能量模式
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        public static bool IsEnergyMode(this Actor actor)
        {
            if (actor.IsBoy())
            {
                return !string.IsNullOrEmpty(actor.boyCfg.MaleEnergyFillUI) && !string.IsNullOrEmpty(actor.boyCfg.MaleEnergyBGUI);
            }

            return false;
        }

        /// <summary>
        /// 以合适的方向向目标forward转身（XZ平面）（目前是动作模组Update中用）
        /// </summary>
        /// <param name="actor"></param>
        /// <param name="destForward">目标forward</param>
        /// <param name="turnSpeed">转身速度</param>
        /// <param name="deltaTime">deltaTime</param>
        /// <param name="curForward">不传使用actor.model.forward</param>
        /// <returns>新面向</returns>
        public static Vector3 RotateToTargetXZ(this Actor actor, Vector3 destForward, float turnSpeed, float deltaTime, Vector3? curForward = null)
        {
            var _curForward = actor.transform.forward;
            if (curForward != null) _curForward = curForward.Value;
            if (destForward == Vector3.zero) return _curForward;

            var angle = Vector3.Angle(_curForward, destForward);
            var deltaAngle = deltaTime * turnSpeed;
            var isLeft = Vector3.Cross(_curForward, destForward).y < 0;
            if (isLeft)
            {
                // 判断是顺时针还是逆时针
                angle = -angle;
                deltaAngle = -deltaAngle;
            }

            if (Mathf.Abs(angle) > Mathf.Abs(deltaAngle))
            {
                var newForward = Quaternion.AngleAxis(deltaAngle, Vector3.up) * _curForward;
                _curForward = newForward;
                actor.transform.SetForward(newForward);
            }
            else
            {
                actor.transform.SetForward(destForward);
            }

            return _curForward;
        }

        /// <summary>
        /// 获取单位所有的法术场ShapeBox信息
        /// </summary>
        public static void GetMagicFieldShapes(this Actor actor, ref List<ShapeBox> shapeBoxes)
        {
            if (shapeBoxes == null)
            {
                return;
            }

            var skillOwner = actor.skillOwner;
            if (skillOwner == null)
            {
                return;
            }

            var slots = skillOwner.slots;
            foreach (var iter in slots)
            {
                if (iter.Value.skill is SkillMagicField magicSkill)
                {
                    shapeBoxes.Add(magicSkill.shapeBox);
                }
            }
        }

        /// <summary>
        /// 获取目标：默认是锁定目标与lua层保持一致
        /// </summary>
        /// <param name="actor"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public static Actor GetTarget(this Actor actor, TargetType type = TargetType.Lock)
        {
            switch (type)
            {
                case TargetType.Skill:
                    return actor.skillOwner?.GetTarget();
                case TargetType.Lock:
                    return actor.targetSelector?.GetTarget();
                case TargetType.Self:
                    return actor;
                case TargetType.Girl:
                    return actor.battle.actorMgr.girl;
                case TargetType.Boy:
                    return actor.battle.actorMgr.boy;
                case TargetType.NearestEnemy:
                    return BattleUtil.GetNearestEnemy(actor);
                case TargetType.Move:
                    return actor.moveTarget;
                default:
                    return null;
            }
        }

        /// <summary>
        /// lua call
        /// </summary>
        /// <returns></returns>
        public static bool IsTopHud(this Actor actor)
        {
            if (actor.config.Type != ActorType.Monster)
            {
                return false;
            }

            if (actor.roleBornCfg.MonsterHudControl)
            {
                return actor.roleBornCfg.MonsterHudIsTop;
            }

            return actor.config.SubType == (int)MonsterType.Boss;
        }

        public static bool IsEnableBossCamera(this Actor actor)
        {
            if (actor.config.Type != ActorType.Monster)
            {
                return false;
            }

            if (actor.roleBornCfg == null)
            {
                return false;
            }

            return actor.roleBornCfg.EnableBossCamera;
        }

        /// <summary>
        /// lua call
        /// </summary>
        /// <returns></returns>
        public static bool IsHeadHud(this Actor actor)
        {
            if (actor.config.Type != ActorType.Monster)
            {
                return false;
            }

            if (actor.roleBornCfg.MonsterHudControl)
            {
                return actor.roleBornCfg.MonsterHudIsHead;
            }

            return actor.config.SubType != (int)MonsterType.Boss;
        }

        /// <summary>
        /// 获取挂点
        /// </summary>
        /// <param name="actor"></param>
        /// <param name="dummyName"></param>
        /// <returns></returns>
        public static Transform GetDummy(this Actor actor, string dummyName = ActorDummyType.Root)
        {
            return actor.transform.GetDummy(dummyName);
        }

        /// <summary>
        /// 获取在A的角度，B是什么阵营关系（AB的顺序也很重要，可能出现A看B是敌方，B看A是友方）
        /// </summary>
        /// <param name="actorA"></param>
        /// <param name="actorB"></param>
        /// <returns></returns>
        public static FactionRelationship GetFactionRelationShip(this Actor actorA, Actor actorB)
        {
            if (null == actorA || null == actorB)
            {
                LogProxy.LogError("BattleUtil.GetRelationShip 传入了空参数，请查看调用堆栈，联系对应程序！");
                return FactionRelationship.Neutral;
            }

            return BattleUtil.GetFactionRelationShipByType(actorA.factionType, actorB.factionType);
        }

        /// <summary>
        /// 是否所有ShowTag列表都比对通过. (目前就怪物有ShowTag, 其他比对都不通过.)
        /// tags列表不能为null，长度不能为0，否则算没有完全比较成功.
        /// </summary>
        /// <param name="actor"> 目标Actor </param>
        /// <param name="tags"> 待比较的Tags列表 </param>
        /// <returns></returns>
        public static bool ContainsAllShowTags(this Actor actor, List<int> tags)
        {
            if (tags == null || tags.Count <= 0)
            {
                return false;
            }

            if (actor.monsterCfg == null)
            {
                return false;
            }

            var showTags = actor.monsterCfg.ShowTags;
            if (showTags == null || showTags.Length <= 0)
            {
                return false;
            }

            foreach (int tag in tags)
            {
                if (!actor.ContainsShowTag(tag))
                {
                    return false;
                }
            }

            return true;
        }

        /// <summary>
        /// 该Actor是否包含该ShowTag.
        /// </summary>
        /// <param name="actor"> 目标Actor </param>
        /// <param name="tag"> 待比较的tag </param>
        /// <returns></returns>
        public static bool ContainsShowTag(this Actor actor, int tag)
        {
            if (actor.monsterCfg == null)
            {
                return false;
            }

            var showTags = actor.monsterCfg.ShowTags;
            if (showTags == null || showTags.Length <= 0)
            {
                return false;
            }

            bool result = false;
            foreach (var showTag in showTags)
            {
                if (showTag == tag)
                {
                    result = true;
                    break;
                }
            }

            return result;
        }

        /// <summary>
        /// 禁用指定的技能
        /// </summary>
        /// <param name="actor"></param>
        /// <param name="skillTypeFlags"></param>
        public static void DisableSkills(this Actor actor, object adder, int[] skillTypeFlags, bool isDisable)
        {
            if (null == skillTypeFlags || skillTypeFlags.Length < 1) return;
            foreach (var skillType in skillTypeFlags)
            {
                var flag = 1 << skillType;
                if (!Enum.IsDefined(typeof(SkillTypeFlag), flag))
                {
                    continue;
                }

                if (isDisable)
                {
                    actor.skillOwner.disableController.AcquireDisableFlag(adder, (SkillTypeFlag)flag);
                }
                else
                {
                    actor.skillOwner.disableController.RemoveDisableFlag(adder, (SkillTypeFlag)flag);
                }
            }
        }

        public static T EnsureComponent<T>(this Actor actor, GameObject tgt = null) where T : Component
        {
            return actor.transform.EnsureComponent<T>(tgt);
        }

        public static bool HasComponent<T>(this Actor actor, GameObject tgt = null) where T : Component
        {
            return actor.transform.HasComponent<T>(tgt);
        }

        public static void RemoveComponent<T>(this Actor actor, GameObject tgt = null) where T : Component
        {
            actor.transform.RemoveComponent<T>(tgt);
        }
    }
}