﻿local Tree = {tickInterval=0,tree={children={{children={{children={{children={{task={hashID=829953024,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.CaculateCardPlayValue',vars={{key='playerSeat',type=1,value=1},{isShared=true,key='target',sharedKey='TargetSlotIndex',type=1,value={sharedKey='TargetSlotIndex',value=0}},{isShared=true,key='cardID',type=1,value={value=2205}},{isShared=true,key='cardValue',sharedKey='funCardValue',type=0,value={sharedKey='funCardValue',value=0}}}}},{task={hashID=-886284288,path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison',vars={{key='operation',type=1,value=4},{isShared=true,key='integer1',sharedKey='emptySlotCount',type=1,value={sharedKey='emptySlotCount',value=0}},{isShared=true,key='integer2',type=1,value={value=3}}}}},{task={hashID=-1748776960,path='Runtime.Plugins.AIDesigner.Task.Condition.FloatComparison',vars={{key='operation',type=1,value=0},{isShared=true,key='float1',sharedKey='funCardValue',type=0,value={sharedKey='funCardValue',value=0}},{isShared=true,key='float2',sharedKey='AverageFuncScore',type=0,value={sharedKey='AverageFuncScore',value=0}}}}}},task={abortType=0,hashID=1485248512,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},{task={hashID=-895032320,path='Runtime.Plugins.AIDesigner.Task.Condition.FloatComparison',vars={{key='operation',type=1,value=1},{isShared=true,key='float1',sharedKey='funCardValue',type=0,value={sharedKey='funCardValue',value=0}},{isShared=true,key='float2',type=0,value={value=0}}}}}},task={abortType=0,hashID=-230988800,path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'}},{task={hashID=1966550016,path='Runtime.Plugins.AIDesigner.Task.Action.SetBoolean',vars={{isShared=true,key='sourceValue',type=3,value={value=true}},{isShared=true,key='storeResult',sharedKey='CheckResult',type=3,value={sharedKey='CheckResult',value=true}}}}}},task={abortType=0,hashID=-1215026176,path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'}}},task={hashID=-213563392,path='Runtime.Plugins.AIDesigner.Task.Entry.Entry'}},vars={{key='CheckResult',type=3,value=false},{key='TargetSlotIndex',type=1,value=0},{key='AIStatus',type=1,value=0},{key='EmptySlotCount',type=1,value=0},{key='AverageFuncScore',type=0,value=6500},{key='AverageNumScore',type=0,value=3500},{key='DrawNumScore',type=0,value=0},{key='funCardValue',type=0,value=0},{key='compareValue',type=0,value=0},{key='doubleAFS',type=0,value=0},{key='manType',type=1,value=0},{key='playTimes',type=1,value=0},{key='difficulty',type=1,value=1},{key='recentWinTimes',type=1,value=0},{key='MaxScore',type=0,value=0},{key='ChooseCardID',type=1,value=0},{key='emptySlotCount',type=1,value=0}}} return Tree