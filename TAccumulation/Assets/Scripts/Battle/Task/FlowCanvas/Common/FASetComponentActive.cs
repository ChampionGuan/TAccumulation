using System;
using System.Collections.Generic;
using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("显隐UI组件\nShowUIModules")]
    public class FASetComponentActive : FlowAction
    {
        public bool isListConfig = false;

        public class UIActiveConfig
        {
            public UIComponentType type;
            public bool active;
            [ShowIf(nameof(type), (int)UIComponentType.EnemyHud)]
            [Name("SpawnID")]
            public int insId;
        }

        private bool isShowInsId => !isListConfig && type.value == UIComponentType.EnemyHud;
        [ShowIf(nameof(isListConfig), 0)]
        public BBParameter<UIComponentType> type = new BBParameter<UIComponentType>();
        [ShowIf(nameof(isListConfig), 0)]
        public BBParameter<bool> active = new BBParameter<bool>();
        [ShowIf(nameof(isShowInsId), 1)]
        [Name("SpawnID")]
        public BBParameter<int> insId = new BBParameter<int>();
        [ShowIf(nameof(isListConfig), 1)]
        public List<UIActiveConfig> list = new List<UIActiveConfig>();

        protected override void _Invoke()
        {
            if (!isListConfig)
            {
                BattleUtil.SetUINodeVisible(type.value, active.value, insId.value);
                LogProxy.LogFormat("【新手引导】【显隐UI组件】Graph:{0}, {1}.SetActive({2})", this._graphOwner.name, type.value, active.value);
            }
            else
            {
                for (int i = 0; i < list.Count; i++)
                {
                    var tuple = list[i];
                    BattleUtil.SetUINodeVisible(tuple.type, tuple.active, tuple.insId);
                    LogProxy.LogFormat("【新手引导】【显隐UI组件】Graph:{0}, {1}.SetActive({2})", this._graphOwner.name, tuple.type, tuple.active);
                }
            }
        }
    }
}
