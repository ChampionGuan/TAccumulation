﻿local Tree = {tasks={[-1781071872]={comment='男主手牌不为空',offset={x=-100.0,y=150.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Condition.HandCardEmptyCondition'},[-1726310400]={comment='计算男出牌后的预期得分',offset={x=-60.0,y=200.0},path='Runtime.Plugins.AIDesigner.Task.Action.IntAddition'},[-1587682304]={comment='最大得分出牌',offset={x=170.0,y=90.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoPlayNumCard'},[-1508252672]={comment='出牌后的分 < 对方积分 + 平均预期得分',offset={x=-50.0,y=140.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[-1499504640]={comment='男主得分 + 平均得分期望',offset={x=0.0,y=140.0},path='Runtime.Plugins.AIDesigner.Task.Action.IntAddition'},[-1454330880]={comment='最大得分出牌',offset={x=900.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[-1323559936]={comment='计算女主手牌总数',offset={x=-130.0,y=190.0},path='Runtime.Plugins.AIDesigner.Task.Action.IntAddition'},[-1262741504]={comment='男主没有跳过Buff',offset={x=0.0,y=100.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Condition.PlayerHasBuffCondition'},[-1181398016]={comment='兴奋：出牌',offset={x=-590.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-1077662720]={comment='最大得分出牌',offset={x=20.0,y=90.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoPlayNumCard'},[-1077256192]={comment='计算最大得分出牌',offset={x=-210.0,y=200.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.CalculatePlayCardExpectScore'},[-918579200]={comment='下回合男主出牌会输：出牌',offset={x=130.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-863817728]={comment='出牌获胜：出牌',offset={x=-120.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-835381248]={comment='空格数为2',offset={x=-240.0,y=140.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[-670905344]={offset={x=-180.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-645760000]={offset={x=80.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-470327296]={offset={x=0.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-461067264]={comment='手牌多：出牌',offset={x=-260.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-325465088]={comment='摸牌',offset={x=180.0,y=90.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoDrawNumCard'},[-113017856]={offset={x=-17.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Action.TreeReference'},[-10073088]={comment='出牌后的分数大于男主',offset={x=-10.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[-1325056]={comment='空格数为1',offset={x=-210.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[125501440]={offset={x=60.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Action.TreeReference'},[233177088]={comment='2空',offset={x=640.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[253663232]={comment='数字牌 > =4',offset={x=-10.0,y=140.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[383417344]={offset={x=53.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Action.TreeReference'},[392677376]={offset={x=0.0,y=140.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[453495808]={comment='按最大得分出牌',offset={x=10.0,y=100.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoPlayNumCard'},[585582592]={offset={x=-120.0,y=90.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Condition.CanGrabOpponentSlot'},[630233088]={offset={x=-410.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[797658112]={offset={x=-40.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Parallel'},[861167616]={comment='1空',offset={x=140.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[890968064]={offset={x=0.0,y=70.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[1245910016]={offset={x=270.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[1253938176]={comment='按最大得分出牌',offset={x=50.0,y=100.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoPlayNumCard'},[1315988480]={offset={x=150.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[1422647296]={comment='最大得分出牌',offset={x=50.0,y=90.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoPlayNumCard'},[1501473792]={offset={x=0.0,y=0.0},path='Runtime.Plugins.AIDesigner.Task.Entry.Entry'},[1714912256]={comment='计算最大得分出牌的预期',offset={x=-150.0,y=100.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.CalculatePlayCardExpectScore'},[1742411776]={comment='女主出牌后的积分',offset={x=-50.0,y=190.0},path='Runtime.Plugins.AIDesigner.Task.Action.IntAddition'},[1853540352]={offset={x=10.0,y=90.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoDrawNumCard'},[1907824640]={offset={x=160.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[1932969984]={offset={x=50.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Action.ReturnFailure'},[1969900544]={comment='总牌数 > =9',offset={x=60.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[2043063296]={comment='有兴奋，最大得分出牌',offset={x=-90.0,y=140.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Condition.PlayerHasBuffCondition'},[2057677824]={comment='计算出牌能获得的最大得分',offset={x=-180.0,y=90.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.CalculatePlayCardExpectScore'},[2099654656]={offset={x=-90.0,y=90.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Condition.OpponentGrabSlot'}},trees={},variables={actionCardID={},actionSlotIndex={},actionType={desc='1 摸数字牌 2 出数字牌'},diffScore={},emptySlotCount={},expectScore={},p1ExpectCardID={},p1ExpectScore={},p1ExpectSlotIndex={},p1FuncCardCount={},p1HandCardCount={},p1NumCardCount={},p1Score={},p2ExpectScore={},p2FuncCardCount={},p2NumCardCount={},p2Score={}}} return Tree