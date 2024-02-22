namespace X3Battle
{
    /// <summary>
    /// 防作弊统计的事件信息
    /// </summary>
    public class CheatEventBase
    {
        public float time;

        public void InitTime()
        {
            time = Battle.Instance.time;
        }

        // 一次性的不需要intern
        public virtual string GetString()
        {
            using (zstring.Block())
            {
                var str=  (zstring)(GetType().Name) + ":";
                return str;
            }
        }
    }
    

    public class CheatBuffEvent : CheatEventBase
    {
        private int m_buffID;
        private  int m_casterID;
        private  int m_targetID;
        private  BuffChangeType m_type;

        public CheatBuffEvent()
        {
        }

        public void Init(int buffId, int casterId, int targetId, BuffChangeType type)
        {
            InitTime();
            this.m_buffID = buffId;
            this.m_casterID = casterId;
            this.m_targetID = targetId;
            this.m_type = type;
        }

        public override string GetString()
        {
            using (zstring.Block())
            {
                var child = (zstring)time + "|" +  m_casterID + "|" + m_targetID + "|" + m_buffID + "|" + (int)m_type;
                var parent = base.GetString();
                return parent + child;
            }
        }
    }

    public class CheatAttrChangeEvent : CheatEventBase
    {
        private int m_actorId;
        private float m_oldValue;
        private float m_newValue;
        private AttrType m_type;

        public CheatAttrChangeEvent()
        {
        }
        public void Init(int actorId, AttrType type,float oldValue, float newValue)
        {
            InitTime();
            this.m_actorId = actorId;
            this.m_type = type;
            this.m_newValue = newValue;
            this.m_oldValue = oldValue;
        }
        
        public override string GetString()
        {
            using (zstring.Block())
            {
                var child = (zstring)time + "|" + (int)m_type + "|" + m_oldValue + "|" + m_newValue + "|" + m_actorId;
                var parent = base.GetString();
                return parent + child;
            }
        }
    }

    public class CheatCastSkill : CheatEventBase
    {
        private int m_skillId;
        private int m_casterId;
        private int m_skillTargetId;

        public CheatCastSkill()
        {
        }

        public void Init(int skillId, int skillTargetId, int casterId)
        {
            InitTime();
            this.m_skillId = skillId;
            this.m_skillTargetId = skillTargetId;
            this.m_casterId = casterId;
        }
        
        public override string GetString()
        {
            using (zstring.Block())
            {
                var child = (zstring)time + "|" + (int)m_casterId + "|" + m_skillId;
                var parent = base.GetString();
                return parent + child;
            }
        }
    }

    public class CheatEndSkill : CheatEventBase
    {
        private int m_skillID;
        private SkillEndType m_type;
        private int m_casterId;
        public CheatEndSkill()
        {
        }
        public void Init(int skillId, SkillEndType type, int casterId)
        {
            InitTime();
            this.m_skillID = skillId;
            this.m_type = type;
            this.m_casterId = casterId;
        }
        
        public override string GetString()
        {
            using (zstring.Block())
            {
                var child = (zstring)time + "|" + (int)m_casterId + "|" + m_skillID;
                var parent = base.GetString();
                return parent + child;
            }
        }
    }

    public class CheatOnKillTarget : CheatEventBase
    {
        private int m_killerID;
        private int m_deaderID;
        
        public CheatOnKillTarget()
        {
        }
        public void Init(int killerId, int deaderID)
        {
            InitTime();
            this.m_killerID = killerId;
            this.m_deaderID = deaderID;
        }
        
        public override string GetString()
        {
            using (zstring.Block())
            {
                var child = (zstring)time + "|" + (int)m_killerID + "|" + m_deaderID;
                var parent = base.GetString();
                return parent + child;
            }
        }
    }

    public class CheatActor : CheatEventBase
    {
        private int m_actorID;
        private ActorLifeStateType m_type;

        public CheatActor()
        {
        }
        public void Init(int actorId, ActorLifeStateType type)
        {
            InitTime();
            this.m_actorID = actorId;
            this.m_type = type;
        }
        
        public override string GetString()
        {
            using (zstring.Block())
            {
                var child = (zstring)time + "|" + (int)m_type + "|" + m_actorID;
                var parent = base.GetString();
                return parent + child;
            }
        }
    }

    public class CheatLockHp : CheatEventBase
    {
        private int m_actorID;
        private int m_lockBuffID;
        private float m_lockHPValue;
        
        public CheatLockHp()
        {
        }
        public void Init(int actorId,int lockBuffId, float lockHpValue)
        {
            InitTime();
            this.m_actorID = actorId;
            this.m_lockBuffID = lockBuffId;
            this.m_lockHPValue = lockHpValue;
        }
        
        public override string GetString()
        {
            using (zstring.Block())
            {
                var child = (zstring)time + "|" + m_actorID;
                var parent = base.GetString();
                return parent + child;
            }
        }
    }
    
    public class CheatCoreChange : CheatEventBase
    {
        private int _actorId;
        private int _value;
        
        public CheatCoreChange()
        {
        }
        public void Init(int actorId,int value)
        {
            InitTime();
            this._actorId = actorId;
            this._value = value;
        }
        public override string GetString()
        {
            using (zstring.Block())
            {
                var child = (zstring)time + "|" + _actorId + "|" + _value;
                var parent = base.GetString();
                return parent + child;
            }
        }
    }
    
    public class CheatTauntChange : CheatEventBase
    {
        private int _actorId;
        private int _tauntTargetId;
        
        public CheatTauntChange()
        {
        }
        public void Init(int actorId,int tauntTargetId)
        {
            InitTime();
            this._actorId = actorId;
            this._tauntTargetId = tauntTargetId;
        }
        
        public override string GetString()
        {
            using (zstring.Block())
            {
                var child = (zstring)time + "|" + _actorId + "|" + _tauntTargetId;
                var parent = base.GetString();
                return parent + child;
            }
        }
    }
    
    public class CheatBattleEnd : CheatEventBase
    {
        public CheatBattleEnd()
        {
        }
        public void Init()
        {
            InitTime();
        }
        public override string GetString()
        {
            using (zstring.Block())
            {
                var child = (zstring)time;
                var parent = base.GetString();
                return parent + child;
            }
        }
    }
}
