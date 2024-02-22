using System;
using System.Collections.Generic;
using FlowCanvas;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("魔女时间（单位时间缩放）\nWitchTime")]
    public class FAWitchTime : FlowAction
    {
        [Name("先清除所有单位的魔女时间")]
        public bool isRestoreActorsScale = true;
        
        [Name("是否使用默认缩放倍率")]
        [Tooltip("如果为true，值见BattleConst.ActorDefaultWitchScale")]
        public bool isUseDefaultScale = true;
        
        [Name("缩放倍率")]
        [SliderField(0f, 1f)]
        [ShowIf("isUseDefaultScale",0)]
        public float scale = 1;
        
        [Name("持续时间 (-1一直持续)")]
        public float scaleDuration = -1;

        [Name("下方所选单位是否为排除")]
        [Tooltip("勾选则为排除，表示不进入魔女时间")]
        public bool isExclusion = true;
        
        [Name("所选单位列表")] 
        public List<WitchTimeIncludeData> excludeDatas = new List<WitchTimeIncludeData>();

        private ValueInput<Actor> _viActor;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();

            _viActor = AddValueInput<Actor>(nameof(Actor));
        }

        protected override void _Invoke()
        {
            var actor = _viActor?.GetValue() ?? _actor;
            var scale = isUseDefaultScale ? TbUtil.battleConsts.ActorDefaultWitchScale : this.scale;
            _battle.SetActorsWitchTime(actor, isRestoreActorsScale, isExclusion, excludeDatas, scale, scaleDuration, false);
        }
    }
}
