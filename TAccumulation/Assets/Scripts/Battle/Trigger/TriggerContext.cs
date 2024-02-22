using UnityEngine;

namespace X3Battle
{
    public abstract class TriggerContext : BattleContext, IGraphLevel, IGraphCreater
    {
        public abstract float deltaTime { get; }

        /// <summary> 触发器图对象挂载的父对象 </summary>
        public virtual Transform parent { get; }

        /// <summary> 触发器生存时长, -1等于永久, 交由外界控制. </summary>
        public float lifeTime { get; }

        /// <summary> 触发器等级(继承至技能或Buff的等级) </summary>
        public int level { get; }
        
        /// <summary> 创建来源: 技能创建的是ISkill对象, 关卡创建的是LevelFlow对象, Buff创建的是IBuff对象 </summary>
        public abstract object creater { get; }

        public TriggerContext(Battle battle, float lifeTime = -1, int level = 1) : base(battle)
        {
            this.lifeTime = lifeTime;
            this.level = level;
            this.parent = battle.root;
        }
    }
}