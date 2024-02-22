using PapeGames.X3;
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;
using X3.Impulse;
using static X3.Impulse.ImpulseParameter;

namespace X3Battle
{
    public class CameraImpulse : ECComponent
    {
        //处理单位打断结束逻辑
        public class EntityImpulse
        {
            public Actor actor;
            public object owner;
            public ImpulseBaseAsset impulseEvent;
            public bool isEndByInterrupt;
            public bool isEndByLine;
        }
        public int heroShortLayerPriority = 0;
        public int heroLongLayerPriority = 0;
        public int mobShortLayerPriority = 20;
        public int mobLongLayerPriority = 20;
        public int levelShortLayerPriority = 20;
        public int levelLongLayerPriority = 20;
        public int otherShortLayerPriority = 0;
        public int otherLongLayerPriority = 0;
        public static int performChannel = 2;

        protected List<EntityImpulse> _usingActorImpulses;
        protected List<EntityImpulse> _cacheActorImpulses;

        protected List<ImpulseBaseAsset> _usingWorldImpulses;

        protected float deltatime
        {
            get
            {
                var deltaTime = Time.deltaTime;
                if (_battle != null)
                    deltaTime = _battle.deltaTime;
                return deltaTime;
            }
        }

        private Battle _battle;
        private Action<EventEndSkill> _actionOnSkillEnd;
        
        public CameraImpulse(Battle battle, int type) : base(type)
        {
            _battle = battle;
            _actionOnSkillEnd = _OnSkillEnd;
        }

        protected override void OnAwake()
        {
            base.OnAwake();
            requiredPhysicalJobRunning = true;
            _usingWorldImpulses = new List<ImpulseBaseAsset>(3);
            _usingActorImpulses = new List<EntityImpulse>(3);
            _cacheActorImpulses = new List<EntityImpulse>() { new EntityImpulse(), new EntityImpulse() };
            _battle?.eventMgr.AddListener(EventType.EndSkill, _actionOnSkillEnd, "CameraImpulse._OnSkillEnd");
            //_actor?.eventMgr.AddListener<EventScalerChange>(EventType.OnScalerChange, _OnTimeScaleChange);//battle改变不会引起actor改变事件
            heroShortLayerPriority = TbUtil.battleConsts.HeroShortLayerImpulsePriority;
            heroLongLayerPriority = TbUtil.battleConsts.HeroLongLayerImpulsePriority;
            mobShortLayerPriority = TbUtil.battleConsts.MobShortLayerImpulsePriority;
            mobLongLayerPriority = TbUtil.battleConsts.MobLongLayerImpulsePriority;
            levelShortLayerPriority = TbUtil.battleConsts.LevelShortLayerImpulsePriority;
            levelLongLayerPriority = TbUtil.battleConsts.LevelLongLayerImpulsePriority;
            otherShortLayerPriority = TbUtil.battleConsts.OtherShortLayerImpulsePriority;
            otherLongLayerPriority = TbUtil.battleConsts.OtherLongLayerImpulsePriority;
        }

        /// 添加world震屏 GameObject或Pos作为震源
        /// <param name="actor">施加震屏actor类型决定优先级</param>
        public void AddWorldImpulse(string path, BattleImpulseParameter param, Actor actor = null, GameObject sourceGO = null, Vector3 sourcePos = default)
        {
            if (string.IsNullOrEmpty(path))
                return;

#if UNITY_EDITOR
            BattleResMgr.Instance.UnloadUnused(BattleResType.CameraImpulseAsset, true);//unload让策划可以运行时调试
#endif
            ImpulseBaseAsset impulse;
            using (ProfilerDefine.CameraImpulseAddWorldImpulseLoadAsset.Auto())
            {
                impulse = BattleResMgr.Instance.Load<ImpulseBaseAsset>(path, BattleResType.CameraImpulseAsset);
            }
            if (impulse == null)
                return;
            if (param.IsDefaultLayer)//策划规则选择层
            {
                param.ShakeLayer = _HasCustomImpulse(impulse) ? CameraShakeLayer.Long : CameraShakeLayer.Short;
            }
            if (param.IsDefaultPriority && actor != null)//策划规则选择优先级
            {
                param.ShakePriority = _GetDefaultPriority(actor, (int)param.ShakeLayer);
            }
            LogProxy.LogFormat("【震屏】根据规则 timeline震屏:{0} 层:{1} 优先级:{2}", path, param.ShakeLayer, param.ShakePriority);

            if (!ImpulseMgr.Instance.IsPriority((int)param.ShakeLayer, param.ShakePriority))
                return;

            using (ProfilerDefine.CameraImpulseAddWorldImpulseAddImpulse.Auto())
            {
                for (int i = _usingWorldImpulses.Count - 1; i >= 0; i--)
                {
                    if (_usingWorldImpulses[i] == impulse)
                    {
                        _usingWorldImpulses.RemoveAt(i);
                        break;
                    }
                }
                impulse.m_Param.SetParam(param.ShakeChannel, (int)param.ShakeLayer, param.ShakePriority,
                (DirectionType)param.ShakeDirType,
                    param.ShakePowerfullRadius, param.ShakePowerlessRadius,
                (CurveType)param.ShakePowerlessType,
                     sourceGO, sourcePos);//先设置层 再Add
                impulse.StartTime = 0;
                impulse.RunningTime = deltatime;
                ImpulseMgr.Instance.AddImpulse(impulse);

                _usingWorldImpulses.Add(impulse);
            }
        }

        /// <summary>
        /// 添加actor震屏  震源go为actor
        /// </summary>
        /// <param name="impulse">实例Asset</param>
        /// <param name="actor">Actor</param>
        /// <param name="owner">所属模块(如Skill,监听结束事件</param>
        /// <param name="isEndByInterrupt">因打断结束</param>
        /// <param name="isEndByLine">因时间结束</param>
        public void AddActorImpulse(ImpulseBaseAsset impulse, Actor actor, object owner, bool isEndByInterrupt = false, bool isEndByLine = false)
        {
            using (ProfilerDefine.CameraImpulseAddWorldImpulseAddActorImpulse.Auto())
            {
                if (impulse.m_Param.m_IsDefaultLayer)//策划规则选择层
                {
                    impulse.m_Param.m_Layer = _HasCustomImpulse(impulse) ? ImpulseLayer.Long : ImpulseLayer.Short;
                }
                if (impulse.m_Param.m_IsDefaultPriority && actor != null)//策划规则选择优先级
                {
                    impulse.m_Param.m_Priority = _GetDefaultPriority(actor, (int)impulse.m_Param.m_Layer);
                }
                _RemoveSame(impulse);//由于asset始终用的是一个 在此类内管理 所以先从列表中移除,否则deltaTime会add多次
            	LogProxy.LogFormat("【震屏】根据规则 打击震屏:{0} 层:{1} 优先级:{2}", impulse.name, impulse.m_Param.m_Layer, impulse.m_Param.m_Priority);
                ImpulseMgr.Instance.AddImpulse(impulse);//可能添加到同一个 先add,再设置
                impulse.StartTime = 0;
                impulse.RunningTime = deltatime;
                impulse.m_Param.ImpulseSource = actor?.GetDummy().gameObject;

                _GetCacheImpulse(out var actorImpulse);
                actorImpulse.actor = actor;
                actorImpulse.owner = owner;
                actorImpulse.impulseEvent = impulse;
                actorImpulse.isEndByInterrupt = isEndByInterrupt;
                actorImpulse.isEndByLine = isEndByLine;
                actorImpulse.impulseEvent.start = false;
            	_usingActorImpulses.Add(actorImpulse);            
            }
        }

        public void FadeOut(ImpulseBaseAsset impulse)
        {
            ImpulseMgr.Instance.FadeOutImpulse(impulse);
        }

        protected override void OnPhysicalJobRunning()
        {
            for (int i = _usingActorImpulses.Count - 1; i >= 0; i--)
            {
                if (_usingActorImpulses[i].impulseEvent.Expired || !_usingActorImpulses[i].impulseEvent.m_HoldByMgr)
                {
                    ImpulseMgr.Instance.RemoveImpulse(_usingActorImpulses[i].impulseEvent);
                    _RemoveImpulse(i);
                    continue;
                }
                if(!_usingActorImpulses[i].impulseEvent.start)
                {
                    _usingActorImpulses[i].impulseEvent.start = true;
                    return;
                }
                _usingActorImpulses[i].impulseEvent.RunningTime += deltatime;
            }
            for (int i = 0; i < _usingWorldImpulses.Count; i++)
            {
                if(_usingWorldImpulses[i].Expired || !_usingWorldImpulses[i].m_HoldByMgr)
                {
                    BattleResMgr.Instance.UnloadObj(_usingWorldImpulses[i]);
                    _usingWorldImpulses.RemoveAt(i);
                    continue;
                }
                _usingWorldImpulses[i].RunningTime += deltatime;
            }
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            for (int i = 0; i < _usingWorldImpulses.Count; i++)
            {
                if (_usingWorldImpulses[i].m_HoldByMgr)
                    BattleResMgr.Instance.UnloadObj(_usingWorldImpulses[i]);
            }
            _usingWorldImpulses.Clear();
            _usingActorImpulses.Clear();
            _cacheActorImpulses.Clear();
            ClearCameraShake(); 
            _battle?.eventMgr.RemoveListener<EventEndSkill>(EventType.EndSkill, _actionOnSkillEnd);
            //_actor?.eventMgr.RemoveListener<EventScalerChange>(EventType.OnScalerChange, _OnTimeScaleChange);
        }

        protected void _OnSkillEnd(EventEndSkill eventEndSkill)
        {
            for (int i = _usingActorImpulses.Count - 1; i >= 0; i--)
            {
                var impulse = _usingActorImpulses[i];
                if (impulse.actor != eventEndSkill.skill.actor)
                    continue;

                if (impulse.owner == eventEndSkill.skill)
                {
                    if (eventEndSkill.endType == SkillEndType.Complete)
                    {
                        if (impulse.isEndByLine)
                        {
                            ImpulseMgr.Instance.FadeOutImpulse(impulse.impulseEvent);
                        }
                    }
                    else if (impulse.isEndByInterrupt)
                    {
                        ImpulseMgr.Instance.FadeOutImpulse(impulse.impulseEvent);
                    }
                }
            }
        }

        protected void _GetCacheImpulse(out EntityImpulse impulse)
        {
            if (_cacheActorImpulses.Count > 0)
            {
                impulse = _cacheActorImpulses[0];
                _cacheActorImpulses.RemoveAt(0);
                return;
            }
            impulse = new EntityImpulse();
        }

        protected void _RemoveImpulse(int index)
        {
            var actorImpulse = _usingActorImpulses[index];
            _cacheActorImpulses.Add(actorImpulse);
            _usingActorImpulses.RemoveAt(index);
        }

        protected void _RemoveSame(ImpulseBaseAsset impulse)
        {
            for (int i = _usingActorImpulses.Count - 1; i >= 0; i--)
            {
                if (_usingActorImpulses[i].impulseEvent == impulse)
                {
                    _RemoveImpulse(i);
                    break;
                }
            }
        }

        public void ClearCameraShake()
        {
            ImpulseMgr.Instance.Clear();
        }

        protected bool _HasCustomImpulse(ImpulseBaseAsset impulse)
        {
            if (impulse is ImpulseCustomAsset)
            {
                return true;
            }
            else
            {
                var groupImpulse = impulse as ImpulseGroupAsset;
                if (groupImpulse == null)
                    return false;

                foreach (var sub in groupImpulse.impulseGroup)
                {
                    if (sub is ImpulseCustomAsset)
                        return true;
                }
            }
            return false;
        }

        protected int _GetDefaultPriority(Actor actor, int layer)
        {
            if (actor.IsHeroOrHeroSummons())
                return layer == (int)CameraShakeLayer.Short ? heroShortLayerPriority : heroLongLayerPriority;
            else if (actor.IsMonster())
                return layer == (int)CameraShakeLayer.Short ? mobShortLayerPriority : mobLongLayerPriority;
            else if (actor.type == ActorType.Stage)
                return layer == (int)CameraShakeLayer.Short ? levelShortLayerPriority : levelLongLayerPriority;
            else
                return layer == (int)CameraShakeLayer.Short ? otherShortLayerPriority : otherLongLayerPriority;
        }

        //public int GetStateChannel(BattleSequencer battleSequencer)
        //{
        //    var bcsCamera = battleSequencer.GetComponent<BSCControlCamera>();
        //    if (bcsCamera != null && bcsCamera.cinemachines.Count > 0)
        //    {
        //        var curCam = _battle.cameraTrace.GetVirtualCamera();
        //        foreach (var sCam in bcsCamera.cinemachines)
        //        {
        //            if (sCam == curCam)
        //            {
        //                return -1;//所有channel
        //            }
        //        }
        //    }
        //    return 1;//仅第default层
        //}
    }
}