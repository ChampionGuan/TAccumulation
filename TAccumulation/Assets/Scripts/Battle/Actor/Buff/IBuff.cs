using System.Collections.Generic;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [NonInspectable]
    public class IBuff:DamageExporter
    {
        public int layer => _buffLayers.Layer;

        public int ID { get => _config.ID; }
        public float totalTime { get => GetTotalTime(); }
        public float curTime { get => _curTime; }
        public float leftTime { get => _totalTime + _extraTime - _curTime; }
        public BuffCfg config { get => _config; }
        public BuffOwner owner { get => _owner; }
        public bool isDestroyed = false;
        protected BuffLayers _buffLayers;

        protected BuffCfg _config;
        protected BuffOwner _owner;
        protected float _totalTime; // 持续总时间 （策划称的 常驻时区）
        protected float _curTime; // 已持续时间
        protected float _extraTime; //临时额外时间（策划称的 临时时区）

        public IBuff() : base(DamageExporterType.Buff)
        {
            _buffLayers = new BuffLayers();
        }

        private float GetTotalTime()
        {
            if (_totalTime <= 0)
            {
                return _totalTime;
            }

            return _totalTime + _extraTime;
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="owner"></param>
        /// <param name="config"></param> buff配置
        /// <param name="time"></param> 持续时间
        /// <param name="layer"></param> 层数
        public void Init(BuffOwner owner, BuffCfg config, float time, DamageExporter damageExporter)
        {
            base.Init(config.ID, owner?.actor, damageExporter);
            _config = config;
            _totalTime = time;
            _curTime = 0;
            _extraTime = 0;
            _owner = owner;
            isDestroyed = false;
        }

        //已有buff的时候又重复添加
        public virtual void OnAddRepeatedly()
        {
            
        }

        public override int GetCfgID()
        {
            return config.ID;
        }

        public void Update(float deltaTime)
        {
            _UpdateDamageBoxes(deltaTime);
            OnUpdate(deltaTime);
        }
        
        public virtual void OnUpdate(float deltaTime)
        {

        }

        public float GetDeltaTime()
        {
            return owner.actor.deltaTime;
        }

        public void RefreshTime()
        {
            //刷新持续时间
            _curTime = 0;
            _extraTime = 0;
        }

        public void AddExtraTime(float time)
        {
            _extraTime += time;
        }
        
        public void AddResidentTime(float time)
        {
            _totalTime += time;
        }
        
        public void SetResidentTime(float time)
        {
            _totalTime = time;
        }

        public virtual void AddLayer(int num)
        {
            // PapeGames.X3.LogProxy.Log($"Buff: {_config.ID} Add Layer :{num}");
            // _layer += num;
            // _layer = Mathf.Min(layer, _config.MaxStack);
        }

        public virtual void ReduceLayer(int num)
        {
            // _layer -= num;
            //
            // if (_config.StackClear)
            // {
            //     // 刷新持续时间
            //     RefreshTime();
            // }
            // if (_layer <= 0)
            // {
            //     _layer = 0;  // layer最小为0
            //                 // 层数为0则销毁buff
            //     _owner.DestroyBuff(_config.ID);
            // }
        }

        public void SetBuffDamageBox(X3Vector3 angle)
        {
            _buffLayers.DamageBoxAngle = angle;
        }
        public override string ToString()
        {
            if (this._config != null)
            {
                return this._config.Name + " " + this._config.ID;
            }
            return "";
        }
        
        public bool MatchTypeAndTag(BuffType buffType, BuffTag buffTag, int buffMultipleTags,int buffConflictTag,
            bool ignoreBuffType = false, bool ignoreBuffTag = false,bool ignoreBuffMultipleTags = true)
        {
            if (this.isDestroyed)
            {
                return false;
            }
            if ((ignoreBuffType || this.config.BuffType == buffType) &&
                (ignoreBuffTag || this.config.BuffTag == buffTag) &&
                (ignoreBuffMultipleTags || (this.config.BuffMultipleTags != null &&
                                            this.config.BuffMultipleTags.Contains(buffMultipleTags))))
            {
                if (buffConflictTag == 0 || buffConflictTag == this.config.BuffConflictTag)
                {
                    return true;
                }
            }
            return false;
        }
    }
}
