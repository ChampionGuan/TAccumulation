﻿local Tree = {tasks={[-2050577408]={comment='抽指定范围的牌 [1,2]',offset={x=-70.0,y=150.0},path='PureLogic.AI.Task.Miao.Action.GetDesignatedCard'},[-1982734336]={offset={x=0.0,y=70.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[-1736174592]={comment='抽1或2',offset={x=160.0,y=110.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-1664137216]={comment='特殊抽牌',offset={x=30.0,y=110.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-1615916032]={comment='回合数>0',offset={x=-320.0,y=300.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[-1196832768]={comment='初始化手牌',offset={x=-600.0,y=110.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-1128989696]={comment='抽指定范围的牌 [4,6]',offset={x=10.0,y=90.0},path='PureLogic.AI.Task.Miao.Action.GetDesignatedCard'},[-873681920]={comment='抽指定范围的牌,[5,6]',offset={x=-80.0,y=150.0},path='PureLogic.AI.Task.Miao.Action.GetDesignatedCard'},[-810392576]={comment='检查是否抽到了好牌',offset={x=280.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[-801644544]={comment='设置结果参数',offset={x=130.0,y=100.0},path='PureLogic.AI.Task.Miao.Action.SetGetNumCardResult'},[-334340096]={comment='设置结果参数',offset={x=20.0,y=100.0},path='PureLogic.AI.Task.Miao.Action.SetGetNumCardResult'},[-50941952]={comment='回合数>6',offset={x=-200.0,y=250.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[43352064]={comment='百分之50概率抽出好牌',offset={x=-140.0,y=200.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[52100096]={comment='计算随机数，根据结果判断是否可以特殊抽牌',offset={x=-140.0,y=150.0},path='PureLogic.AI.Task.Miao.Action.GenerateRandomValue'},[158210048]={comment='男主得分<玩家得分+4',offset={x=-200.0,y=200.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[425222144]={comment='抽指定范围的牌 [1,2]',offset={x=7.0,y=90.0},path='PureLogic.AI.Task.Miao.Action.GetDesignatedCard'},[519404544]={comment='如果回合数回为 0',offset={x=-450.0,y=290.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[595995648]={offset={x=0.0,y=0.0},path='Runtime.Plugins.AIDesigner.Task.Entry.Entry'},[842555392]={comment='设置结果参数',offset={x=0.0,y=100.0},path='PureLogic.AI.Task.Miao.Action.SetGetNumCardResult'},[905844736]={comment='抽5或6',offset={x=-100.0,y=110.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[987004928]={offset={x=-10.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[1020702720]={offset={x=-260.0,y=250.0},path='Runtime.Plugins.AIDesigner.Task.Action.IntAddition'},[1278966784]={comment='手牌=1',offset={x=-40.0,y=140.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[1381897216]={comment='设置结果参数，普通抽牌',offset={x=160.0,y=110.0},path='PureLogic.AI.Task.Miao.Action.SetGetNumCardResult'},[1448469504]={offset={x=-290.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[1449740288]={comment='如果手牌为空',offset={x=-100.0,y=140.0},path='PureLogic.AI.Task.Miao.Condition.HandCardEmptyCondition'},[1768337408]={comment='百分之50概率进入特殊抽牌',offset={x=50.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'}},trees={},variables={RandomValue={desc='运算产生的随机数的值'},ResultGetBigger={desc='无指定牌时，返回随机抽牌，取最大值：true,或最小值：false'},ResultRandomMax={desc='无指定牌时，返回随机抽牌数Max'},ResultRandomMin={desc='无指定牌时，返回随机抽牌数Min'},ResultTargetIndex={desc='抽指定牌在牌堆中的索引，无指定牌返回0'},difficulty={desc='0：简单 1：困难'},p1BuffList={desc='女主拥有的buff数组'},p1CompareScore={},p1FuncCardCount={desc='女主功能牌手牌数'},p1NumCardCount={desc='女主数字牌手牌数'},p1Score={desc='当前女主的分数'},p2BuffList={desc='男主拥有的buff数组'},p2ExpectCardID={desc='最大得分出牌预期的卡牌ID'},p2ExpectScore={desc='男主预期最大得分出牌后的分数'},p2ExpectScoreAfterPlayCard={desc='男主预期出牌后的得分'},p2ExpectSlotIndex={desc='最大得分出牌预期的插槽索引'},p2FuncCardCount={desc='男主功能牌手牌数'},p2NumCardCount={desc='男主数字牌手牌数'},p2Score={desc='当前男主的分数'},roundCount={desc='当前回合数'}}} return Tree