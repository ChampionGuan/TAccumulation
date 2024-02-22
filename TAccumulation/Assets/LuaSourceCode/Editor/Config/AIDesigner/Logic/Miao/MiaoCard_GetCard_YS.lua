﻿local Tree = {tasks={[-2059325440]={comment='标准摸牌',offset={x=650.0,y=100.0},path='PureLogic.AI.Task.Miao.Action.SetGetNumCardResult'},[-2050577408]={offset={x=0.0,y=80.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[-1721527296]={comment='初始化手牌',offset={x=140.0,y=180.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[-1060241408]={comment='回合数为0，初始化手牌阶段',offset={x=-260.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-665702400]={comment='简单：前2张牌摸1~3',offset={x=400.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-656954368]={comment='计算手牌数量',offset={x=-400.0,y=140.0},path='PureLogic.AI.Task.Miao.Action.GetPlayersHandCardCount'},[-582242304]={comment='计数难度',offset={x=-100.0,y=140.0},path='Runtime.Plugins.AIDesigner.Task.Action.TreeReference'},[-561042432]={comment='如果回合数回为 0',offset={x=-740.0,y=140.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[188042240]={offset={x=0.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[196790272]={comment='数字牌=0',offset={x=0.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[280250368]={offset={x=-230.0,y=100.0},path='PureLogic.AI.Task.Miao.Condition.CheckMiaoDifficulty'},[513068032]={offset={x=0.0,y=0.0},path='Runtime.Plugins.AIDesigner.Task.Entry.Entry'},[519404544]={comment='找到了目标卡',offset={x=380.0,y=120.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[595995648]={comment='设置结果参数',offset={x=660.0,y=120.0},path='PureLogic.AI.Task.Miao.Action.SetGetNumCardResult'},[1059282944]={comment='困难：首张牌1~3',offset={x=-350.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[1656781824]={offset={x=-220.0,y=100.0},path='PureLogic.AI.Task.Miao.Condition.CheckMiaoDifficulty'},[1904279552]={offset={x=230.0,y=100.0},path='PureLogic.AI.Task.Miao.Action.GetDesignatedCard'},[1913027584]={offset={x=280.0,y=100.0},path='PureLogic.AI.Task.Miao.Action.GetDesignatedCard'}},trees={},variables={RandomValue={desc='运算产生的随机数的值'},ResultGetBigger={desc='无指定牌时，返回随机抽牌，取最大值：true,或最小值：false'},ResultRandomMax={desc='无指定牌时，返回随机抽牌数Max'},ResultRandomMin={desc='无指定牌时，返回随机抽牌数Min'},ResultTargetIndex={desc='抽指定牌在牌堆中的索引，无指定牌返回0'},difficulty={},p1BuffList={desc='女主拥有的buff数组'},p1FuncCardCount={desc='女主功能牌手牌数'},p1NumCardCount={desc='女主数字牌手牌数'},p1Score={desc='当前女主的分数'},p2BuffList={desc='男主拥有的buff数组'},p2ExpectCardID={desc='最大得分出牌预期的卡牌ID'},p2ExpectScore={desc='男主预期最大得分出牌后的分数'},p2ExpectScoreAfterPlayCard={desc='男主预期出牌后的得分'},p2ExpectSlotIndex={desc='最大得分出牌预期的插槽索引'},p2FuncCardCount={desc='男主功能牌手牌数'},p2NumCardCount={desc='男主数字牌手牌数'},p2Score={desc='当前男主的分数'},recentWinTimes={},roundCount={desc='当前回合数'}}} return Tree