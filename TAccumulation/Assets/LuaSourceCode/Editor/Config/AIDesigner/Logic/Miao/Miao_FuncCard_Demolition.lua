﻿local Tree = {tasks={[-1929800704]={offset={x=0.0,y=80.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-1310661632]={offset={x=53.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Action.ReturnSuccess'},[-1301913600]={offset={x=-80.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-448168960]={comment='出牌',offset={x=-5.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Action.SetBoolean'},[-213563392]={offset={x=0.0,y=0.0},path='Runtime.Plugins.AIDesigner.Task.Entry.Entry'},[-131767296]={comment='判断是否要出牌',offset={x=-10.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Action.TreeReference'},[366745600]={comment='下调计算的价值，防止去拆0分的格子',offset={x=-80.0,y=200.0},path='Runtime.Plugins.AIDesigner.Task.Action.FloatAddition'},[414323712]={comment='是否强制出牌（GM）',offset={x=-223.0,y=250.0},path='Runtime.Plugins.AIDesigner.Task.Condition.BooleanComparison'},[444700672]={comment='计算拆迁后能获得的最大分差，并返回此时拆迁的目标格子',offset={x=-140.0,y=200.0},path='PureLogic.AI.Task.Miao.Action.CaculateCardEffectInSlotsMaxScore'},[567913472]={comment='计算拆迁后能获得的最大分差，并返回此时拆迁的目标格子',offset={x=-300.0,y=260.0},path='PureLogic.AI.Task.Miao.Action.CaculateCardEffectInSlotsMaxScore'},[1268068352]={offset={x=53.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Action.ReturnFailure'},[1276816384]={offset={x=-490.0,y=90.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[1548110848]={offset={x=50.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Action.SetBoolean'}},trees={},variables={AIStatus={desc='当前AI策略'},AverageFuncScore={desc='功能卡平均强度（屯牌性格出功能牌标准）'},AverageNumScore={desc='数字卡平均得分（标准性格出功能牌标准）'},CheckResult={desc='检查能否使用的结果'},MaxScore={},TargetSlotIndex={desc='出牌作用的格子索引'},difficulty={desc='难度：0简单，1困难'},emptySlotCount={},isForcePlay={},manType={desc='男主类型'},playTimes={desc='总玩牌轮数'},recentWinTimes={desc='最近5轮胜利次数'}}} return Tree