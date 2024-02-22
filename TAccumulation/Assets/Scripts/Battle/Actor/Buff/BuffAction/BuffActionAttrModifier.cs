using System;
using System.Collections.Generic;
using MessagePack;

namespace X3Battle
{
    [MessagePackObject]
    [Serializable]
    public class BuffActionAttrModifier : BuffActionBase,IAttrModifier
    {
        /// <summary>
        /// 添加及发生变化时生效的属性变化列表
        /// </summary>
        private List<float[]> _attrChangeList = new List<float[]>(3); 
        /// <summary>
        /// 动态实时生效的属性变化列表
        /// </summary>
        private List<float[]> _dynamicAttrParamList = new List<float[]>(3);

        /// <summary>
        /// 注册所有可能用到的属性，自动去重
        /// </summary>
        private HashSet<AttrType> _registerAttrTypes = new HashSet<AttrType>();
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.DynamicAttrModifier;
        }

        private void _UpdateAttrParams(List<AttrParam> paramsList)
        {
            //清除旧的
            foreach (var item in _attrChangeList)
            {
                // 根据策划定义 k[0]代表属性类型，k[1]代表增加比例， k[2]代表固定增加数值
                var attr = _actor.attributeOwner.GetAttr((AttrType) item[0]);
                if (attr == null)
                {
                    PapeGames.X3.LogProxy.LogError($"BuffLevelConfig表配置有误buffID{_owner.ID}，属性类型不存在，联系策划卡宝宝");
                    continue;
                }
                attr.Sub(item[2], item[1] / 1000f);
            }
            _attrChangeList.Clear();
            _dynamicAttrParamList.Clear();
            
            if (paramsList == null || paramsList.Count == 0)
            {
                return;
            }
            
            //更新
            foreach (var param in paramsList)
            {
                if (param.AttrF != null && param.AttrF.Length > 0)
                {
                    //新增动态属性变化配置
                    if (param.AttrF.Length == 5)
                    {
                        _dynamicAttrParamList.Add(param.AttrF);
                    }
                    else
                    {
                        //原有的单次生效的属性变化，参数3个
                        _attrChangeList.Add(param.AttrF);
                    }
                }
                else
                {
                    if (string.IsNullOrEmpty(param.AttrS))
                    {
                        PapeGames.X3.LogProxy.LogWarning($"buff层数属性配置有误，buffID{_owner.ID}，联系策划卡宝宝");
                        continue;
                    }
                    var layerConfig = TbUtil.GetBuffLevelConfig(_owner);
                    float[] temp = TbUtil.GetBuffMathParam(layerConfig, param.AttrS);
                    if (temp != null)
                    {
                        if (temp.Length == 5)
                        {
                            _dynamicAttrParamList.Add(temp);
                        }
                        else if (temp.Length == 3)
                        {
                            _attrChangeList.Add(temp);
                        }
                    }
                }
            }
            
            foreach (var item in _attrChangeList)
            {
                // 根据策划定义 k[0]代表属性类型，k[1]代表增加比例， k[2]代表固定增加数值
                var attr = _owner.actor.attributeOwner.GetAttr((AttrType) item[0]);
                if (attr == null)
                {
                    PapeGames.X3.LogProxy.LogError($"BuffLevelConfig表配置有误buffID{_owner.ID}，属性类型不存在，联系策划卡宝宝");
                    return;
                }

                attr.Add(item[2], item[1] / 1000f);
            }
        }
        
        /// <summary>
        /// 注册所有可能用到的属性
        /// </summary>
        private void _RegisterAllDynamicAttrParam()
        {
            foreach (var layersData in  _owner.config.LayersDatas)
            {
                if (layersData == null)
                {
                    continue;
                }
                foreach (var attrParam in layersData.AttrParamsList)
                {
                    if (attrParam.AttrF != null && attrParam.AttrF.Length > 0)
                    {
                        //新增动态属性变化配置
                        if (attrParam.AttrF.Length == 5)
                        {
                            _registerAttrTypes.Add((AttrType)attrParam.AttrF[0]);
                        }
                    }
                    else
                    {
                        if (string.IsNullOrEmpty(attrParam.AttrS))
                        {
                            PapeGames.X3.LogProxy.LogWarning($"buff层数属性配置有误，buffID{_owner.ID}，联系策划卡宝宝");
                            continue;
                        }
                        var layerConfig = TbUtil.GetBuffLevelConfig(_owner);
                        float[] temp = TbUtil.GetBuffMathParam(layerConfig, attrParam.AttrS);

                        if (temp != null && temp.Length == 5)
                        {
                            _registerAttrTypes.Add((AttrType)temp[0]);
                        }
                    }
                }
            }
            foreach (var attrType in _registerAttrTypes)
            {
                var attr = _owner.actor.attributeOwner.GetAttr(attrType);
                attr.AddModifier(this);
            }
        }
        
        /// <summary>
        /// 反注册所有可能用到的属性
        /// </summary>
        private void _UnRegisterAllDynamicAttrParam()
        {
            foreach (var attrType in _registerAttrTypes)
            {
                var attr = _owner.actor.attributeOwner.GetAttr(attrType);
                attr.RemoveModifier(this);
            }
            _registerAttrTypes.Clear();
        }

        public override void OnAdd(int layer)
        {
            if (layer == 0)
            {
                PapeGames.X3.LogProxy.LogError($"添加了0层buff！，buffID {_owner.ID}");
                return;
            }
            _RegisterAllDynamicAttrParam();
            var layerData = _owner.config.GetLayerData(layer).AttrParamsList;
            _UpdateAttrParams(layerData);
        }

        public override void OnDestroy()
        {
            _UpdateAttrParams(null);
            _UnRegisterAllDynamicAttrParam();
            ObjectPoolUtility.BuffActionAttrModifierPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionAttrModifierPool.Get();
            return action;
        }

        public float ChangeAttrValue(AttrType type, float value)
        {
            foreach (var paramList in _dynamicAttrParamList)
            {
                var mainAttrType = (AttrType) paramList[0];
                if (mainAttrType == type)
                {
                    //和策划讨论，动态修饰属性不能修饰在生命值上，出现的话就报错
                    if (mainAttrType == AttrType.HP)
                    {
                        PapeGames.X3.LogProxy.LogError($"动态修饰属性不能用在生命值上，联系策划改配置，buffID {_owner.ID}");
                        continue;
                    }
                    AttrChoseTarget target = (AttrChoseTarget)paramList[3];
                    var actor = _owner.actor;
                    if (target == AttrChoseTarget.Boy)
                    {
                        actor = Battle.Instance.actorMgr.boy;
                    }
                    else if(target == AttrChoseTarget.Girl)
                    {
                        actor = Battle.Instance.actorMgr.girl;
                    }
                    value += actor.attributeOwner.GetAttrValue((AttrType) paramList[4]) * paramList[1]*0.001f + paramList[2];
                }
            }
            return value;
        }
        
        public override void OnAddLayer(int num)
        {
            if (_owner.layer == 0)
            {
                _UpdateAttrParams(null);
                return;
            }
            var layerData = _owner.config.GetLayerData(_owner.layer).AttrParamsList;
            _UpdateAttrParams(layerData);
        }

        public override void OnRemoveLayer(int num)
        {
            if (_owner.layer == 0)
            {
                _UpdateAttrParams(null);
                //删除的情况，目前bufflayer的删除在buff之外
                return;
            }
            var layerData = _owner.config.GetLayerData(_owner.layer).AttrParamsList;
            _UpdateAttrParams(layerData);
        }
        
    }
}