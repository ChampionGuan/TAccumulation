﻿local Tree = {desc='否决出牌逻辑',tickInterval=0,tree={children={{children={{children={{task={hashID=531798016,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.CaculateCardPlayValue',vars={{key='playerSeat',type=1,value=1},{isShared=true,key='target',type=1,value={value=0}},{isShared=true,key='cardID',type=1,value={value=2203}},{isShared=true,key='cardValue',sharedKey='MaxScore',type=0,value={sharedKey='MaxScore',value=0}}}}},{children={{children={{task={hashID=850308096,path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison',vars={{key='operation',type=1,value=0},{isShared=true,key='integer1',sharedKey='emptySlotCount',type=1,value={sharedKey='emptySlotCount',value=0}},{isShared=true,key='integer2',type=1,value={value=3}}}}},{task={hashID=398535680,path='Runtime.Plugins.AIDesigner.Task.Condition.FloatComparison',vars={{key='operation',type=1,value=4},{isShared=true,key='float1',sharedKey='MaxScore',type=0,value={sharedKey='MaxScore',value=0}},{isShared=true,key='float2',type=0,value={value=0}}}}}},task={abortType=0,hashID=-883425280,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},{task={hashID=773467136,path='Runtime.Plugins.AIDesigner.Task.Condition.FloatComparison',vars={{key='operation',type=1,value=4},{isShared=true,key='float1',sharedKey='MaxScore',type=0,value={sharedKey='MaxScore',value=0}},{isShared=true,key='float2',type=0,value={value=3500}}}}}},task={abortType=0,hashID=841560064,path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'}},{task={hashID=93675520,path='Runtime.Plugins.AIDesigner.Task.Action.SetInt',vars={{isShared=true,key='sourceValue',type=1,value={value=2203}},{isShared=true,key='storeResult',sharedKey='ChooseCardID',type=1,value={sharedKey='ChooseCardID',value=2203}}}}},{task={hashID=-768817152,path='Runtime.Plugins.AIDesigner.Task.Action.SetBoolean',vars={{isShared=true,key='sourceValue',type=3,value={value=true}},{isShared=true,key='storeResult',sharedKey='CheckResult',type=3,value={sharedKey='CheckResult',value=true}}}}}},task={abortType=0,hashID=-165924864,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},{task={hashID=-1326449664,path='Runtime.Plugins.AIDesigner.Task.Action.SetBoolean',vars={{isShared=true,key='sourceValue',type=3,value={value=false}},{isShared=true,key='storeResult',sharedKey='CheckResult',type=3,value={sharedKey='CheckResult',value=true}}}}}},task={abortType=0,hashID=389787648,path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'}}},task={hashID=-213563392,path='Runtime.Plugins.AIDesigner.Task.Entry.Entry'}},vars={{key='CheckResult',type=3,value=false},{key='MaxScore',type=0,value=0},{key='ChooseCardID',type=1,value=0},{arrayType=0,key='Test',type=1,value={0,0,0,0,0}},{key='emptySlotCount',type=1,value=0}}} return Tree