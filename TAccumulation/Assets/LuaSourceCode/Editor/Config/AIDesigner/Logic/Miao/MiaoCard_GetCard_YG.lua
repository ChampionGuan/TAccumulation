﻿local Tree = {tasks={[-2059325440]={comment='标准摸牌',offset={x=80.0,y=130.0},path='PureLogic.AI.Task.Miao.Action.SetGetNumCardResult'},[-2050577408]={offset={x=0.0,y=80.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'},[-1501856768]={comment='50%概率摸和空翻倍格同色的牌',offset={x=-160.0,y=220.0},path='PureLogic.AI.Task.Miao.Action.GetSameColorCardWithDoubleSlot'},[-1250919424]={comment='第四回合开始，50%概率摸和空翻倍格同色的牌',offset={x=-180.0,y=130.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[-334340096]={comment='50%概率摸空翻倍格同色的牌',offset={x=90.0,y=130.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'},[465317888]={comment='第四回合开始',offset={x=-90.0,y=130.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[513068032]={offset={x=0.0,y=0.0},path='Runtime.Plugins.AIDesigner.Task.Entry.Entry'},[519404544]={comment='找到了目标卡',offset={x=-10.0,y=170.0},path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison'},[595995648]={comment='设置结果参数',offset={x=50.0,y=120.0},path='PureLogic.AI.Task.Miao.Action.SetGetNumCardResult'}},trees={},variables={RandomValue={desc='运算产生的随机数的值'},ResultGetBigger={desc='无指定牌时，返回随机抽牌，取最大值：true,或最小值：false'},ResultRandomMax={desc='无指定牌时，返回随机抽牌数Max'},ResultRandomMin={desc='无指定牌时，返回随机抽牌数Min'},ResultTargetIndex={desc='抽指定牌在牌堆中的索引，无指定牌返回0'},p1BuffList={desc='女主拥有的buff数组'},p1FuncCardCount={desc='女主功能牌手牌数'},p1NumCardCount={desc='女主数字牌手牌数'},p1Score={desc='当前女主的分数'},p2BuffList={desc='男主拥有的buff数组'},p2ExpectCardID={desc='最大得分出牌预期的卡牌ID'},p2ExpectScore={desc='男主预期最大得分出牌后的分数'},p2ExpectScoreAfterPlayCard={desc='男主预期出牌后的得分'},p2ExpectSlotIndex={desc='最大得分出牌预期的插槽索引'},p2FuncCardCount={desc='男主功能牌手牌数'},p2NumCardCount={desc='男主数字牌手牌数'},p2Score={desc='当前男主的分数'},roundCount={desc='当前回合数'}}} return Tree