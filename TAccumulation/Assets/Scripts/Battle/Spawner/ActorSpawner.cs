using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public abstract class ActorSpawner
    {
        public Battle battle { get; }
        public virtual List<Type> requiredComponents { get; protected set; }

        private readonly Type _timerType = typeof(BattleTimer);
        private readonly Type _aiType = typeof(AIOwner);

        public ActorSpawner(Battle battle)
        {
            this.battle = battle;
        }

        public virtual T1 CreateActorBornCfg<T1>(PointBase pointCfg) where T1 : ActorBornCfg
        {
            return null;
        }

        public virtual ActorCfg CreateActorCfg(ActorBornCfg bornCfg, int? actorCfgID = null)
        {
            var cfgID = bornCfg?.CfgID ?? actorCfgID.Value;
            if (TbUtil.TryGetCfg(cfgID, out ActorCfg actorCfg))
            {
                return actorCfg;
            }

            PapeGames.X3.LogProxy.LogError($"【ActorSpawner.CreateActor()】创建Actor失败,角色configID:{cfgID}的配置信息不存在,请联系策划【五当/五当】，进行检查!");
            return null;
        }

        public virtual Actor CreateActor(ActorCfg actorCfg, ActorCreateCfg createCfg)
        {
            return _GenerateActor(actorCfg, null, createCfg);
        }

        protected Actor _GenerateActor(ActorCfg actorCfg, ActorSuitCfg suitCfg, ActorCreateCfg createCfg)
        {
            if (null == actorCfg)
            {
                PapeGames.X3.LogProxy.LogError("[ActorSpawner._GenerateActor()]创建Actor失败，请传入正确的config信息！");
                return null;
            }

            var entity = new ECEntity((int)ActorComponentType.Num, "ActorEntity");
            var actor = new Actor(battle, actorCfg, suitCfg, createCfg);
            entity.AddComponent(actor);
            entity.AddComponent(new ActorTimeScaler(actor));
            entity.AddComponent<ActorEventMgr>();
            entity.AddComponent<ActorTransform>();

            //非女主&不存在AI配置
            bool isAddAiAndHate = actorCfg.Type == ActorType.Hero && actorCfg.SubType == (int)HeroType.Girl || !string.IsNullOrEmpty(actorCfg.CombatAIName);
            if (null != requiredComponents)
            {
                foreach (var component in requiredComponents)
                {
                    if (!isAddAiAndHate && component == _aiType)
                    {
                        continue;
                    }

                    if (component == _timerType)
                    {
                        entity.AddComponent(new BattleTimer(actor, (int)ActorComponentType.Timer));
                    }
                    else
                    {
                        entity.AddComponent(component);
                    }
                }
            }

            if (!isAddAiAndHate)
            {
                return actor;
            }

            if (createCfg.IsPlayer)
            {
                entity.AddComponent<PlayerHate>();
            }
            else
            {
                switch (actorCfg.Type)
                {
                    case ActorType.Hero:
                        entity.AddComponent<FriendHate>();
                        break;
                    case ActorType.Monster:
                        entity.AddComponent<EnemyHate>();
                        break;
                }
            }

            return actor;
        }

        protected void _GenerateCommonBornCfg(ActorBornCfg bornCfg, ActorPointBase actorPointBase)
        {
            bornCfg.SpawnID = actorPointBase.ID;
            bornCfg.CfgID = actorPointBase.ConfigID;
            bornCfg.FactionType = actorPointBase.FactionType;
            bornCfg.Position = actorPointBase.Position;
            bornCfg.Forward = Quaternion.Euler(actorPointBase.Rotation) * Vector3.forward;
        }

        protected void _GenerateActorPropertyFromServer(ActorBornCfg bornCfg)
        {
            var id = bornCfg.CfgID;
            if (!battle.arg.cacheBornCfgs.TryGetValue(id, out var cacheBornCfg))
            {
                PapeGames.X3.LogProxy.LogErrorFormat("在线模式没有找到id:{0} 的actor数据, 联系程序解决", id);
                return;
            }

            // DONE: 角色怪物都读服务器等级.
            bornCfg.Level = cacheBornCfg.Level;
            foreach (var item in cacheBornCfg.AttrsOnline)
            {
                if (Enum.IsDefined(typeof(AttrType), item.Key))
                {
                    bornCfg.Attrs.Add((AttrType)item.Key, item.Value);
                }
                else
                {
                    PapeGames.X3.LogProxy.LogErrorFormat("AttrType枚举中没有定义数字为：{0} 的类型", item.Key);
                }
            }

            // HP如果服务器不发，则使用MaxHP
            if (!bornCfg.Attrs.ContainsKey(AttrType.HP))
            {
                bornCfg.Attrs.TryGetValue(AttrType.MaxHP, out var maxHP);
                bornCfg.Attrs.Add(AttrType.HP, maxHP);
            }

            // MoveSpeed如果服务器不发，或者值小于等于0
            if (!bornCfg.Attrs.ContainsKey(AttrType.MoveSpeed) || bornCfg.Attrs.TryGetValue(AttrType.MoveSpeed, out var moveSpeed) && moveSpeed <= 0)
            {
                bornCfg.Attrs.Add(AttrType.MoveSpeed, 1000);
            }

            // // CoreDamageRatio如果服务器不发，或者值小于等于0
            if (!bornCfg.Attrs.ContainsKey(AttrType.CoreDamageRatio) || bornCfg.Attrs.TryGetValue(AttrType.CoreDamageRatio, out var coreDamageRatio) && coreDamageRatio <= 0)
            {
                bornCfg.Attrs.Add(AttrType.CoreDamageRatio, 1);
            }

            bornCfg.BuffDatas = cacheBornCfg.BuffDatas;
        }
    }
}