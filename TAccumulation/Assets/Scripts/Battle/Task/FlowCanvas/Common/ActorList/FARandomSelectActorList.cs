using System.Collections.Generic;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action/ActorList")]
    [Name("在ActorList内随机选择Actor\nRandomSelectActorList")]
    public class FARandomSelectActorList : FlowAction
    {
        public BBParameter<int> SelectNum = new BBParameter<int>(0);
        
        private ValueInput<ActorList> _viActorList;
        private ActorList _resultList = new ActorList(10);
        private Actor _oneActor = null;
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();

            _viActorList = AddValueInput<ActorList>("list");
            AddValueOutput("ActorList", () => _resultList);
            AddValueOutput("OneActor", () => _oneActor);
        }

        protected override void _Invoke()
        {
            _resultList.Clear();
            _oneActor = null;
            var list = _viActorList?.GetValue();
            if (list == null)
            {
                _LogError($"请联系策划【路浩/大头】, 节点【在ActorList内随机选择Actor FARandomSelectActorList】引脚参数配置错误, 【ActorList】引脚为null!");
                return;
            }

            _resultList.AddRange(list);
            // 1.先去重.
            BattleUtil.DistinctList(_resultList);
            // 2.再打乱.
            BattleUtil.ShuffleList(_resultList);
            // 3.保留x个.
            var selectNum = SelectNum.GetValue();
            while (_resultList.Count > selectNum)
            {
                _resultList.RemoveAt(_resultList.Count - 1);
            }
            //取一个
            if (_resultList.Count > 0)
            {
                _oneActor = _resultList[0];
            }

        }
    }
}
