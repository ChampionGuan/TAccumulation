﻿local Tree = {tasks={[-1748776960]={comment='价值 < AFS',offset={x=40.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Condition.FloatComparison'},[-1215026176]={offset={x=0.0,y=80.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[-895032320]={comment='价值 <=0 不出',offset={x=40.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Condition.FloatComparison'},[-886284288]={comment='空格数 > 3',offset={x=-20.0,y=140.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[-230988800]={offset={x=-60.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[-213563392]={offset={x=360.0,y=-80.0},path='Runtime.Plugins.AIDesigner.Task.Entry.Entry'},[829953024]={offset={x=-110.0,y=190.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.CaculateCardPlayValue'},[1485248512]={offset={x=-50.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[1966550016]={comment='允许出牌',offset={x=55.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Action.SetBoolean'}},trees={},variables={AIStatus={desc='当前AI策略'},AverageFuncScore={desc='功能卡平均强度（屯牌性格出功能牌标准）'},AverageNumScore={desc='数字卡平均得分（标准性格出功能牌标准）'},CheckResult={desc='检查能否使用的结果'},ChooseCardID={},DrawNumScore={desc='抽数字牌平均分'},EmptySlotCount={},MaxScore={},TargetSlotIndex={desc='出牌作用的格子索引'},compareValue={},difficulty={desc='难度：0简单，1困难'},doubleAFS={},emptySlotCount={},funCardValue={},manType={desc='男主类型'},playTimes={desc='总玩牌轮数'},recentWinTimes={desc='最近5轮胜利次数'}}} return Tree