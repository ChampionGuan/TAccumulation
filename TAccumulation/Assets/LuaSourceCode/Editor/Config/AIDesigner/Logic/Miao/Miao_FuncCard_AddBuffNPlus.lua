﻿local Tree = {tasks={[-2108760064]={comment='出牌价值<ANS',offset={x=20.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Condition.FloatComparison'},[-2058420224]={offset={x=-1140.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-2023085056]={offset={x=0.0,y=0.0},path='Runtime.Plugins.AIDesigner.Task.Entry.Entry'},[-2017473536]={comment='出牌',offset={x=1400.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Action.SetBoolean'},[-1991174144]={offset={x=100.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Action.FloatMultiplication'},[-1890910208]={comment='数字牌数量<2 or 空格数<2 不出',offset={x=-470.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-1859859456]={comment='女主数字牌数量>0',offset={x=50.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[-1802594304]={comment='空格数=2',offset={x=-60.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[-1434576896]={comment='是否强制出牌（GM）',offset={x=-73.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Condition.BooleanComparison'},[-1283057664]={comment='最大得分<剩余分差',offset={x=0.0,y=100.0},path='PureLogic.AI.Task.Miao.Condition.MiaoCompareIntAndFloat'},[-1178088448]={offset={x=0.0,y=80.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[-1018935296]={comment='有buff跳过',offset={x=-110.0,y=150.0},path='PureLogic.AI.Task.Miao.Condition.PlayerHasBuffCondition'},[-988618752]={comment='空格数=3',offset={x=-110.0,y=250.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[-837440512]={comment='女主没有buff跳过',offset={x=110.0,y=100.0},path='PureLogic.AI.Task.Miao.Condition.PlayerHasBuffCondition'},[-821613568]={comment='获得男女主积分',offset={x=-170.0,y=310.0},path='PureLogic.AI.Task.Miao.Action.CaculatorPlayerScore'},[-755933184]={comment='数字牌或空格数小于2,不出',offset={x=110.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[-740754432]={comment='剩余分差=当前分差+兴奋价值',offset={x=40.0,y=200.0},path='Runtime.Plugins.AIDesigner.Task.Action.FloatAddition'},[-392522752]={comment='屯牌状态,出牌价值较低时不出',offset={x=1180.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-367318016]={comment='获得手牌数量',offset={x=-210.0,y=160.0},path='PureLogic.AI.Task.Miao.Action.GetPlayersHandCardCount'},[-300711936]={comment='返回false,让树往后走',offset={x=190.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Action.ReturnFailure'},[-157176832]={comment='如果有跳过或兴奋Buff，不出',offset={x=-840.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[-86356992]={comment='获得下次出数字牌最大可得分',offset={x=-80.0,y=260.0},path='PureLogic.AI.Task.Miao.Action.CalculatePlayCardExpectScore'},[75417600]={comment='出牌',offset={x=15.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Action.SetBoolean'},[469969920]={comment='最大得分<剩余分差',offset={x=-50.0,y=200.0},path='PureLogic.AI.Task.Miao.Condition.MiaoCompareIntAndFloat'},[697302016]={comment='有buff兴奋',offset={x=-10.0,y=100.0},path='PureLogic.AI.Task.Miao.Condition.PlayerHasBuffCondition'},[800082944]={comment='空格数=2 and 出2牌后积分落后',offset={x=450.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[960304128]={comment='空格数<2',offset={x=30.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[1295672320]={comment='屯牌状态',offset={x=-50.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[1304420352]={comment='数值计算',offset={x=20.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[1559060480]={comment='获得空格数量',offset={x=-100.0,y=100.0},path='PureLogic.AI.Task.Miao.Action.CalculateEmptySlot'},[1559794688]={comment='价值计算:出两张牌可获胜,则价值=99;否则价值=第二张牌得分',offset={x=-260.0,y=360.0},path='PureLogic.AI.Task.Miao.Action.CaculateCardPlayValue'},[1590111232]={comment='空格数=3且出2张牌后积分落后且对方有数字手牌且对方没有被跳过',offset={x=790.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[1822796800]={comment='数字牌<2',offset={x=-50.0,y=140.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'}},trees={},variables={AIStatus={desc='当前AI策略,0:普通,1:放水,2:屯牌'},AverageFuncScore={desc='功能卡平均强度（屯牌性格出功能牌标准）'},AverageNumScore={desc='数字卡平均得分（标准性格出功能牌标准）'},CheckResult={desc='检查能否使用的结果'},DrawNumScore={desc='抽数字牌平均分'},TargetSlotIndex={desc='出牌作用的格子索引'},diffScore={desc='分差,男主分-女主分'},difficulty={desc='难度：0简单，1困难'},emptySlotCount={},funCardValue={},isForcePlay={},manType={desc='男主类型'},p1FuncCardCount={},p1NumCardCount={},p1Score={desc='玩家得分'},p2ExceptScore={desc='男主出牌预期得分'},p2FuncCardCount={},p2NumCardCount={},p2Score={desc='男主得分'},playTimes={desc='总玩牌轮数'},recentWinTimes={desc='最近5轮胜利次数'}}} return Tree