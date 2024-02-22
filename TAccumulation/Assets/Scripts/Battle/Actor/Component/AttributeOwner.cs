using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class AttributeOwner : ActorComponent
    {
        private static List<AttrType> ATTR_TYPES = new List<AttrType>();

        private Dictionary<AttrType, Attribute> _attrs;
        private static int instanceKey = 1000;
        private const float SPerMil = 0.001f; //千分比参数系数
        public Dictionary<AttrType, Attribute> attrs => _attrs;

        static AttributeOwner()
        {
            foreach (AttrType attrType in Enum.GetValues(typeof(AttrType)))
            {
                ATTR_TYPES.Add(attrType);
            }
        }

        public AttributeOwner() : base(ActorComponentType.Attribute)
        {
            _attrs = new Dictionary<AttrType, Attribute>(new AttrUtil.AttrTypeComparer());
        }

        public override void OnDead()
        {
            if (_attrs == null)
            {
                return;
            }
            foreach (var attr in _attrs)
            {
                attr.Value.OnDead();
            }
        }

        public override void OnBorn()
        {
            _Reset();
            
            if (null == actor.bornCfg.Attrs)
            {
                return;
            }

            using (ProfilerDefine.AttributeOwnerOnbornPMarker.Auto())
            {
                foreach (var item in actor.bornCfg.Attrs)
                {
                    if ((int)item.Key < instanceKey) // todo：1000以上是即时属性
                    {
                        var attribute = ObjectPoolUtility.Attribute.Get();

                        attribute.Init(this, item.Key, item.Value, minValue: TbUtil.GetAttrMinValue(item.Key));
                        _attrs[item.Key] = attribute;
                    }
                    else
                    {
                        Attribute instantAttr = ObjectPoolUtility.InstantAttr.Get();
                        instantAttr.Init(this, item.Key, item.Value, minValue: TbUtil.GetAttrMinValue(item.Key));
                        _attrs[item.Key] = instantAttr;
                    }
                }

                // 给未设bornConfig的属性初值0
                foreach (var attrType in ATTR_TYPES)
                {
                    using (ProfilerDefine.AttributeOwnerATTR_TYPESPMarker.Auto())
                    {
                        if (!_attrs.ContainsKey(attrType))
                        {
                            if ((int)attrType < instanceKey)
                            {
                                var attribute = ObjectPoolUtility.Attribute.Get();

                                attribute.Init(this, attrType, 0, minValue: TbUtil.GetAttrMinValue(attrType));
                                _attrs[attrType] = attribute;
                            }
                            else
                            {
                                var instantAttr = ObjectPoolUtility.InstantAttr.Get();

                                instantAttr.Init(this, attrType, 0, minValue: TbUtil.GetAttrMinValue(attrType));
                                _attrs[attrType] = instantAttr;
                            }
                        }
                    }
                }
                
                //实时属性继承
                if (actor.bornCfg.RealTimeInherit && actor.bornCfg.Master != null)
                {
                    var summonConfig =  TbUtil.GetCfg<BattleSummon>(actor.bornCfg.SummonID);
                    _RealTimeInherit(actor.bornCfg.Master,summonConfig.AttrScale,summonConfig.IgnoreAttr);
                }
            }
        }

        public Attribute GetAttr(AttrType type)
        {
            if (!_attrs.ContainsKey(type))
                return null;

            return _attrs[type];
        }

        public float GetAttrValue(AttrType type)
        {
            if (!_attrs.TryGetValue(type, out var attr))
            {
                //PapeGames.X3.LogProxy.LogError($"attr({type}) not found!");
                return 0;
            }

            return attr.GetValue();
        }

        /// <summary>
        /// 获取千分比的值，TODO 优化，修改所有用到千分比值的属性
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public float GetPerthAttrValue(AttrType type)
        {
            if (!_attrs.TryGetValue(type, out var attr))
            {
                //PapeGames.X3.LogProxy.LogError($"attr({type}) not found!");
                return 0;
            }

            return attr.GetValue() * SPerMil;
        }

        public bool ContainAttr(AttrType type)
        {
            return _attrs.ContainsKey(type);
        }

        public bool SetAttrValue(AttrType type, float value)
        {
            if (!_attrs.ContainsKey(type))
            {
                if ((int) type < instanceKey) // todo：1000以上是即时属性
                {
                    var attribute = ObjectPoolUtility.Attribute.Get();
                    attribute.Init(this, type, value, minValue: TbUtil.GetAttrMinValue(type));
                    _attrs[type] = attribute;
                }
                else
                {
                    var instantAttr = ObjectPoolUtility.InstantAttr.Get();
                    instantAttr.Init(this, type, value, minValue: TbUtil.GetAttrMinValue(type));
                    _attrs[type] = instantAttr;
                }
            }

            _attrs[type].Set(value);
            return true;
        }

        public void SetAttrMinValue(AttrType type, float value)
        {
            if (!_attrs.ContainsKey(type))
            {
                PapeGames.X3.LogProxy.LogError($"attr({type}) not found!");
                return;
            }

            _attrs[type].SetMinValue(value);
        }

        public bool SetAttrValueByDebugEditor(AttrType type, float value)
        {
            if (!_attrs.ContainsKey(type))
            {
                PapeGames.X3.LogProxy.LogError($"attr({type}) not found!");
                return false;
            }

            _attrs[type].SetByDebugEditor(value);
            return true;
        }

        public void OnAttrChanged(Attribute attr, float oldValue, float newValue)
        {
            //事件拆分
            if (!actor.isDead && attr.GetAttrType() == AttrType.HP)
            {
                var eventData = actor.eventMgr.GetEvent<EventActorHealthChangeForUI>();
                eventData.Init(actor);
                eventData.currentValue = attr.GetValue();
                actor.eventMgr.Dispatch(EventType.ActorHealthChangeForUI, eventData);
            }
            var eventData2 = actor.eventMgr.GetEvent<EventAttrChange>();
            eventData2.Init(actor, attr.GetAttrType(), oldValue, newValue);
            
            if (attr.GetAttrType() == AttrType.RootMotionMutiplierXZ)
            {
                actor.eventMgr.Dispatch(EventType.RootMotionMutiplierChange, eventData2,false);
            }
            else if (attr.GetAttrType() == AttrType.MoveSpeed)
            {
                actor.eventMgr.Dispatch(EventType.MoveSpeedChange, eventData2,false);
            }
            else if (attr.GetAttrType() == AttrType.MaxHP)
            {
                actor.eventMgr.Dispatch(EventType.MaxHpChange, eventData2);
            }
            
            actor.eventMgr.Dispatch(EventType.AttrChange, eventData2);
        }

        public override void OnRecycle()
        {

        }

        // TODO for 朝冠 XTBUG-23794，临时修复.
        private void _Reset()
        {
            if (_attrs == null)
            {
                return;
            }
            foreach (var attr in _attrs)
            {
                if (attr.Value is InstantAttr)
                {
                    ObjectPoolUtility.InstantAttr.Release(attr.Value as InstantAttr);
                }
                else
                {
                    ObjectPoolUtility.Attribute.Release(attr.Value);
                }
            }
            _attrs.Clear();
        }
        
        //创生物实时继承属性
        private void _RealTimeInherit(Actor master,S2Int[] scaleList,int[] ignoreAttr)
        {
            //在scaleList中，但是不在ignoreAttr中的缩放属性。TODO：优化
            Dictionary<int, int> tempDict = scaleList.ToDictionary(p=>p.ID,p=>p.Num);
            //默认没有scale的也是全部常规属性都继承
            foreach (var item in master.attributeOwner.attrs)
            {
                int attrType = (int)item.Key;
                if (attrType < instanceKey&&!ignoreAttr.Contains(attrType))
                {
                    var masterAttrbute = item.Value;
                    int scale = 1000;
                    if (tempDict.TryGetValue(attrType, out int scaleValue))
                    {
                        scale = scaleValue;
                    }
                    masterAttrbute.RegisterInheritSummonAttr(_attrs[item.Key], scale);
                }
            }
        }

            #region 动态属性修饰

        //用于防止循环
        private static HashSet<IAttrModifier> _sTempSet =
            new HashSet<IAttrModifier>();

        public static float ExecuteModify(List<IAttrModifier> sections, float value,Attribute contextInfo)
        {
            if (sections == null)
            {
                return value;
            }

            using (ProfilerDefine.AttributeOwnerExecuteModifyPMarker.Auto())
            {

                foreach (var section in sections)
                {
                    if (_sTempSet.Contains(section))
                    {
                        PapeGames.X3.LogProxy.LogError($"存在循环嵌套调用！,Attribute = {contextInfo}!");
                        break;
                    }

                    if (section == null)
                    {
                        PapeGames.X3.LogProxy.LogError(
                            $"存在null的AttrValueAddtionalChangeSection！,Attribute = {contextInfo}!");
                        continue;
                    }

                    _sTempSet.Add(section);
                    value = section.ChangeAttrValue(contextInfo.GetAttrType(), value);
                    _sTempSet.Remove(section);
                }
                return value;
            }
        }


        #endregion
    }
}
