using System;
using System.Collections.Generic;
using PapeGames.X3;
using Unity.Mathematics;

namespace X3Battle
{
    public class BuffLayers
    {
        private int _layer;
        private X3Buff _buff;
        public int Layer => _layer;

        /// <summary>
        /// 特效是否每次只存在当前层的，不叠加低层的特效
        /// </summary>
        private bool _fxOnlyOne;
        public X3Vector3 DamageBoxAngle;

        #region 临时辅助结构

        private List<int> _fxPlayedCache = new List<int>(3);
        private HashSet<int> _fxExpect = new HashSet<int>(); //自动去重
        private List<int> _fxTempList = new List<int>(3);

        #endregion
        public void Init(X3Buff buff, int layer, bool fxOnlyOne)
        {
            _buff = buff;
            _fxOnlyOne = fxOnlyOne;
            _layer = 1;//默认是1
            //初始化时因为damnageBox可能依赖buffaction，layerchange方法不一样，先初始化layer，再初始化action，再执行damage
            if ( layer <= 0 )
            {
                LogProxy.LogError($"初始化层数错误，layer = {layer}");
                return;
            }
            _layer = Math.Max(Math.Min(layer,_buff.config.MaxStack),1);
        }

        //在action初始化之后
        public void InitLayerDamage()
        {
            var layerData = _buff.config.GetLayerData(_layer);
            if (layerData.DamageBoxID != 0)
            {
                _buff.ClearDamageBoxes();
                _buff.CastDamageBox(null, layerData.DamageBoxID, _buff.level, out _, DamageBoxAngle, null,
                    duration: -1f);
            }

            //特效多层数组叠加计算逻辑
            _RefreshFx(_CalculateExpectFx(_layer));
        }
        
        public void Destroy()
        {
            _ClearCurrentFxs();
            _buff.ClearDamageBoxes();
            _buff = null;
            _fxExpect.Clear();
            _fxPlayedCache.Clear();
            _fxTempList.Clear();
            _layer = 0;
        }

        private void _ClearCurrentFxs()
        {
            foreach (var fxID in _fxPlayedCache)
            {
                _buff.owner.FxEnd(fxID,_buff);
            }

            _fxPlayedCache.Clear();
        }
        
        /// <summary>
        /// 改变层数
        /// </summary>
        /// <param name="newLayer">新层数</param>
        /// <returns>逻辑层数是否发生改变</returns>
        public bool LayerChange(int newLayer)
        {
            if (newLayer < 0)
            {
                LogProxy.LogError($"buff层数出现负数！{newLayer}");
                return false;
            }
            if (newLayer == 0)
            {
                //删除目前在外部，TODO，优化
                _layer = 0;
                return true;
            }

            newLayer = Math.Max(Math.Min(newLayer,_buff.config.MaxStack),1);
            if (_layer == newLayer )
            {
                //和当前层数一样（到达上限了），不更新逻辑
                return false;
            }
            _ChangeLayer(newLayer);
            return true;
        }

        private void _ChangeLayer(int newLayer)
        {
            var layerData = _buff.config.GetLayerData(newLayer);
            // _SetAttrParams(layerData.AttrParamsList);
            int oldDamageBoxID = _layer > 0 ? _buff.config.GetLayerData(_layer).DamageBoxID : 0;
            if (layerData.DamageBoxID != 0 && layerData.DamageBoxID != oldDamageBoxID)
            {
                _buff.ClearDamageBoxes();
                _buff.CastDamageBox(null, layerData.DamageBoxID, _buff.level, out _, null, null,
                    duration: -1f);
            }

            //特效多层数组叠加计算逻辑
            _RefreshFx(_CalculateExpectFx(newLayer));
            _layer = newLayer;
        }

        private HashSet<int> _CalculateExpectFx(int targetLayer)
        {
            _fxExpect.Clear();
            if (_fxOnlyOne)
            {
                var layerData = _buff.config.GetLayerData(targetLayer);
                foreach (var fxID in layerData.FxIDList)
                {
                    if (fxID != 0)
                    {
                        _fxExpect.Add(fxID);
                    }
                }
            }
            else
            {
                for (int i = 0; i < targetLayer; i++)
                {
                    var layerData = _buff.config.GetLayerData(i+1);
                    foreach (var fxID in layerData.FxIDList)
                    {
                        if (fxID != 0)
                        {
                            _fxExpect.Add(fxID);
                        }
                    }
                }
            }

            return _fxExpect;
        }

        private void _RefreshFx(HashSet<int> expectFxSet)
        {
            foreach (var fxID in _fxPlayedCache)
            {
                if (!expectFxSet.Contains(fxID))
                {
                    _fxTempList.Add(fxID);
                }
            }

            foreach (var fxID in _fxTempList)
            {
                _buff.owner.FxEnd(fxID,_buff);
                _fxPlayedCache.Remove(fxID);
            }

            _fxTempList.Clear();

            foreach (var fxID in expectFxSet)
            {
                if (!_fxPlayedCache.Contains(fxID))
                {
                    _buff.owner.FxBegin(fxID, _buff.caster);
                    _fxPlayedCache.Add(fxID);
                }
            }
        }
        
        
    }
}