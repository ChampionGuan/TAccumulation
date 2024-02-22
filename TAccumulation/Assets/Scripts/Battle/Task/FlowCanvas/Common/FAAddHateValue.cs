using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Description("给目标的仇恨列表的目标们添加对自己的仇恨值")]
    [Name("添加仇恨值\nAddHateValue")]
    public class FAAddHateValue : FlowAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<float> hateValue = new BBParameter<float>();
        
        protected override void _Invoke()
        {
            Actor role = source.isNoneOrNull ? _actor : source.value;
            List<HateDataBase> roleHates;
            if (role.factionType == FactionType.Hero && role != role.battle.player)
            {
                roleHates = role.battle.player.actorHate.hates;
            }
            else
            {
                roleHates = role.actorHate.hates;
            }
            if (roleHates == null)
            {
                return;
            }
            foreach (HateDataBase roleHate in roleHates)
            {
                Actor monster =  role.battle.actorMgr.GetActor(roleHate.insId);
                if (monster != null)
                {
                    EnemyHate enemyHate = monster.actorHate as EnemyHate;
                    if (enemyHate == null)
                    {
                        continue;
                    }
                    List<HateDataBase> monsterHates = monster.actorHate.hates;
                    if (monsterHates == null)
                    {
                        continue;
                    }

                    foreach (HateDataBase monsterHate in monsterHates)
                    {
                        Actor curActor = role.battle.actorMgr.GetActor(monsterHate.insId);
                        if (curActor == role)
                        {
                            enemyHate.AddHateValue(monsterHate.insId, hateValue.value);
                            break;
                        }
                    }
                }
            }
        }
    }
}
