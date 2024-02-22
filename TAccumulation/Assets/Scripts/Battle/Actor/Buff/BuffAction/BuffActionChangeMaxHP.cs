using System;
using MessagePack;
using PapeGames.X3;
using XAssetsManager;

namespace X3Battle
{
    [BuffAction("生命上限调整")]
    [MessagePackObject]
    [Serializable]
    public class BuffActionChangeMaxHP : BuffActionBase
    {
        [BuffLable("修改百分比")] 
        [Key(1)] public float changePercent;
        [Key(2)] public string mathParam;

        [Key(3)] public bool noRecoverCurrentHp;

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionChangeMaxHPPool.Get();
            action.changePercent = this.changePercent;
            action.mathParam = this.mathParam;
            action.noRecoverCurrentHp = this.noRecoverCurrentHp;
            return action;
        }
        
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.ChangeMaxHP;
            if (!string.IsNullOrEmpty(mathParam))
            {
                var layerConfig = TbUtil.GetBuffLevelConfig(_owner);
                float[] temp = TbUtil.GetBuffMathParam(layerConfig, mathParam);
                if (temp == null || temp.Length <= 0)
                {
                    LogProxy.LogError($"{buff.ID} BuffActionChangeMaxHP,修改百分比配置错误，存在无法解析的字符串 {mathParam}");
                }
                else
                {
                    changePercent = temp[0];
                }
            }
        }

        
        public override void OnAdd(int layer)
        {
            _changeMaxHp(changePercent);

        }

        private void _changeMaxHp(float percent)
        {
            var maxHp = _actor.attributeOwner.GetAttr(AttrType.MaxHP);
            var currentHp = _actor.attributeOwner.GetAttr(AttrType.HP);
            if (maxHp == null || currentHp == null)
            {
                LogProxy.LogError("BuffActionChangeMaxHP ,AttrType.MaxHP or AttrType.HP is null!");
                return;
            }

            if (percent > 0)
            {
                var oldValue = maxHp.GetValue();
                maxHp.Add(0,percent);
                //回血
                if (!noRecoverCurrentHp)
                {
                    var changeValue = maxHp.GetValue() - oldValue;
                    currentHp.Add(changeValue,0);
                }
            }
            else
            {
                maxHp.Add(0,percent);
                //不变，（设为最大值）
                currentHp.Add(0,0);
            }
        }

        public override void OnDestroy()
        {
            
            base.OnDestroy();
            
            _changeMaxHp(-changePercent);

            ObjectPoolUtility.BuffActionChangeMaxHPPool.Release(this);
        }
    }
}