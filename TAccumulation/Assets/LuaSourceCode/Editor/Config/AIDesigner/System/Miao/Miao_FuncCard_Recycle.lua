﻿local Tree = {tasks={[-2026924032]={comment='允许出牌',offset={x=110.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Action.SetBoolean'},[-1497300992]={comment='出牌价值大于 0',offset={x=10.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Condition.FloatComparison'},[-1488552960]={offset={x=-60.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-634808320]={offset={x=-70.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-310686720]={comment='不出牌',offset={x=40.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Action.SetBoolean'},[-213563392]={offset={x=-10.0,y=-100.0},path='Runtime.Plugins.AIDesigner.Task.Entry.Entry'},[227684352]={comment='计算出牌价值',offset={x=-210.0,y=100.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.CaculateCardPlayValue'},[1081428992]={comment='空格数小于3',offset={x=-50.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[1090177024]={offset={x=0.0,y=80.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[1414298624]={comment='得分 大于 平均数',offset={x=40.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Condition.FloatComparison'},[1943921664]={offset={x=20.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'}},trees={},variables={AIStatus={desc='当前AI策略'},AverageFuncScore={desc='功能卡平均强度（屯牌性格出功能牌标准）'},AverageNumScore={desc='数字卡平均得分（标准性格出功能牌标准）'},CheckResult={desc='检查能否使用的结果'},ChooseCardID={},DrawNumScore={desc='抽数字牌平均分'},EmptySlotCount={},MaxScore={},PlayCardValue={},TargetSlotIndex={desc='出牌作用的格子索引'},difficulty={desc='难度：0简单，1困难'},emptySlotCount={},funCardValue={},manType={desc='男主类型'},playTimes={desc='总玩牌轮数'},randValue={},recentWinTimes={desc='最近5轮胜利次数'}}} return Tree