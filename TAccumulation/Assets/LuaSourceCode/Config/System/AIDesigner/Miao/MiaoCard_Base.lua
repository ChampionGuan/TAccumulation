﻿local Tree = {tickInterval=0,tree={children={{children={{children={{children={{task={hashID=-1077256192,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.CalculatePlayCardExpectScore',vars={{key='playerSeat',type=1,value=1},{isShared=true,key='onlyDoubleSlot',type=3,value={value=false}},{isShared=true,key='expectScore',sharedKey='expectScore',type=1,value={sharedKey='expectScore',value=0}},{isShared=true,key='expectCardID',sharedKey='actionCardID',type=1,value={sharedKey='actionCardID',value=0}},{isShared=true,key='expectSlotIndex',sharedKey='actionSlotIndex',type=1,value={sharedKey='actionSlotIndex',value=0}}}}},{task={hashID=2043063296,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Condition.PlayerHasBuffCondition',vars={{key='playerSeat',type=1,value=1},{key='buffID',type=1,value=3},{key='negate',type=3,value=false}}}},{task={hashID=-1077662720,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoPlayNumCard',vars={{isShared=true,key='expectCardID',type=1,value={value=0}},{isShared=true,key='expectSlotIndex',type=1,value={value=0}},{key='byMaxScore',type=3,value=true}}}}},task={abortType=0,hashID=-1181398016,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},{children={{task={hashID=-1323559936,path='Runtime.Plugins.AIDesigner.Task.Action.IntAddition',vars={{isShared=true,key='intValue',sharedKey='p1NumCardCount',type=1,value={sharedKey='p1NumCardCount',value=0}},{isShared=true,key='addValue',sharedKey='p1FuncCardCount',type=1,value={sharedKey='p1FuncCardCount',value=0}},{isShared=true,key='storeResult',sharedKey='p1HandCardCount',type=1,value={sharedKey='p1HandCardCount',value=0}}}}},{children={{task={hashID=253663232,path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison',vars={{key='operation',type=1,value=4},{isShared=true,key='integer1',sharedKey='p1NumCardCount',type=1,value={sharedKey='p1NumCardCount',value=0}},{isShared=true,key='integer2',type=1,value={value=4}}}}},{task={hashID=1969900544,path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison',vars={{key='operation',type=1,value=4},{isShared=true,key='integer1',sharedKey='p1HandCardCount',type=1,value={sharedKey='p1HandCardCount',value=0}},{isShared=true,key='integer2',type=1,value={value=9}}}}}},task={abortType=0,hashID=392677376,path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'}},{task={hashID=1422647296,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoPlayNumCard',vars={{isShared=true,key='expectCardID',type=1,value={value=0}},{isShared=true,key='expectSlotIndex',type=1,value={value=0}},{key='byMaxScore',type=3,value=true}}}}},task={abortType=0,hashID=-461067264,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},{children={{task={hashID=-1325056,path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison',vars={{key='operation',type=1,value=2},{isShared=true,key='integer1',sharedKey='emptySlotCount',type=1,value={sharedKey='emptySlotCount',value=0}},{isShared=true,key='integer2',type=1,value={value=1}}}}},{task={hashID=1714912256,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.CalculatePlayCardExpectScore',vars={{key='playerSeat',type=1,value=1},{isShared=true,key='onlyDoubleSlot',type=3,value={value=false}},{isShared=true,key='expectScore',sharedKey='p1ExpectScore',type=1,value={sharedKey='p1ExpectScore',value=0}},{isShared=true,key='expectCardID',sharedKey='p1ExpectCardID',type=1,value={sharedKey='p1ExpectCardID',value=0}},{isShared=true,key='expectSlotIndex',sharedKey='p1ExpectSlotIndex',type=1,value={sharedKey='p1ExpectSlotIndex',value=0}}}}},{children={{children={{task={hashID=-1726310400,path='Runtime.Plugins.AIDesigner.Task.Action.IntAddition',vars={{isShared=true,key='intValue',sharedKey='p1Score',type=1,value={sharedKey='p1Score',value=0}},{isShared=true,key='addValue',sharedKey='p1ExpectScore',type=1,value={sharedKey='p1ExpectScore',value=0}},{isShared=true,key='storeResult',sharedKey='p1ExpectScore',type=1,value={sharedKey='p1ExpectScore',value=0}}}}},{task={hashID=-10073088,path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison',vars={{key='operation',type=1,value=5},{isShared=true,key='integer1',sharedKey='p1ExpectScore',type=1,value={sharedKey='p1ExpectScore',value=0}},{isShared=true,key='integer2',sharedKey='p2Score',type=1,value={sharedKey='p2Score',value=0}}}}},{task={hashID=1253938176,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoPlayNumCard',vars={{isShared=true,key='expectCardID',type=1,value={value=0}},{isShared=true,key='expectSlotIndex',type=1,value={value=0}},{key='byMaxScore',type=3,value=true}}}}},task={abortType=0,hashID=-863817728,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},{children={{children={{task={hashID=-1781071872,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Condition.HandCardEmptyCondition',vars={{key='handSubClass',type=1,value=1},{key='playerSeat',type=1,value=2}}}},{task={hashID=-1262741504,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Condition.PlayerHasBuffCondition',vars={{key='playerSeat',type=1,value=2},{key='buffID',type=1,value=1},{key='negate',type=3,value=true}}}}},task={abortType=0,hashID=797658112,path='Runtime.Plugins.AIDesigner.Task.Composite.Parallel'}},{task={hashID=453495808,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoPlayNumCard',vars={{isShared=true,key='expectCardID',type=1,value={value=0}},{isShared=true,key='expectSlotIndex',type=1,value={value=0}},{key='byMaxScore',type=3,value=true}}}}},task={abortType=0,hashID=-918579200,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},{task={hashID=-325465088,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoDrawNumCard'}}},task={abortType=0,hashID=1315988480,path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'}}},task={abortType=0,hashID=861167616,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}}},task={abortType=0,hashID=630233088,path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'}},{children={{task={hashID=585582592,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Condition.CanGrabOpponentSlot',vars={{key='playerSeat',type=1,value=1},{isShared=true,key='emptySlotCount',sharedKey='emptySlotCount',type=1,value={sharedKey='emptySlotCount',value=0}}}}},{task={hashID=125501440,path='Runtime.Plugins.AIDesigner.Task.Action.TreeReference',refTask=true,vars={{key='treeName',type=2,value='Miao.MiaoCard_Sub_DoRobSlot'}}}}},task={abortType=0,hashID=-470327296,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},{children={{task={hashID=2099654656,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Condition.OpponentGrabSlot',vars={{key='Seat',type=1,value=1},{key='opponentSeat',type=1,value=2},{isShared=true,key='emptySlot',sharedKey='emptySlotCount',type=1,value={sharedKey='emptySlotCount',value=0}}}}},{task={hashID=383417344,path='Runtime.Plugins.AIDesigner.Task.Action.TreeReference',refTask=true,vars={{key='treeName',type=2,value='Miao.MiaoCard_Sub_DoRobSlot'}}}}},task={abortType=0,hashID=1245910016,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},{children={{task={hashID=-835381248,path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison',vars={{key='operation',type=1,value=2},{isShared=true,key='integer1',sharedKey='emptySlotCount',type=1,value={sharedKey='emptySlotCount',value=0}},{isShared=true,key='integer2',type=1,value={value=2}}}}},{task={hashID=2057677824,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.CalculatePlayCardExpectScore',vars={{key='playerSeat',type=1,value=1},{isShared=true,key='onlyDoubleSlot',type=3,value={value=false}},{isShared=true,key='expectScore',sharedKey='p1ExpectScore',type=1,value={sharedKey='p1ExpectScore',value=0}},{isShared=true,key='expectCardID',sharedKey='p1ExpectCardID',type=1,value={sharedKey='p1ExpectCardID',value=0}},{isShared=true,key='expectSlotIndex',sharedKey='p1ExpectSlotIndex',type=1,value={sharedKey='p1ExpectSlotIndex',value=0}}}}},{children={{children={{task={hashID=1742411776,path='Runtime.Plugins.AIDesigner.Task.Action.IntAddition',vars={{isShared=true,key='intValue',sharedKey='p1Score',type=1,value={sharedKey='p1Score',value=0}},{isShared=true,key='addValue',sharedKey='p1ExpectScore',type=1,value={sharedKey='p1ExpectScore',value=0}},{isShared=true,key='storeResult',sharedKey='p1ExpectScore',type=1,value={sharedKey='p1ExpectScore',value=0}}}}},{task={hashID=-1499504640,path='Runtime.Plugins.AIDesigner.Task.Action.IntAddition',vars={{isShared=true,key='intValue',sharedKey='p2Score',type=1,value={sharedKey='p2Score',value=0}},{isShared=true,key='addValue',type=1,value={value=4}},{isShared=true,key='storeResult',sharedKey='p2ExpectScore',type=1,value={sharedKey='p2ExpectScore',value=0}}}}},{task={hashID=1932969984,path='Runtime.Plugins.AIDesigner.Task.Action.ReturnFailure'}}},task={abortType=0,hashID=-670905344,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},{children={{task={hashID=-1508252672,path='Runtime.Plugins.AIDesigner.Task.Condition.IntComparison',vars={{key='operation',type=1,value=0},{isShared=true,key='integer1',sharedKey='p1ExpectScore',type=1,value={sharedKey='p1ExpectScore',value=0}},{isShared=true,key='integer2',sharedKey='p2ExpectScore',type=1,value={sharedKey='p2ExpectScore',value=2}}}}},{task={hashID=1853540352,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoDrawNumCard'}}},task={abortType=0,hashID=-645760000,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},{task={hashID=-1587682304,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Miao.Action.MiaoPlayNumCard',vars={{isShared=true,key='expectCardID',type=1,value={value=0}},{isShared=true,key='expectSlotIndex',type=1,value={value=0}},{key='byMaxScore',type=3,value=true}}}}},task={abortType=0,hashID=1907824640,path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'}}},task={abortType=0,hashID=233177088,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},{children={{task={hashID=-113017856,path='Runtime.Plugins.AIDesigner.Task.Action.TreeReference',refTask=true,vars={{key='treeName',type=2,value='Miao.MiaoCard_Sub_DoExpectScore'}}}}},task={abortType=0,hashID=-1454330880,path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'}}},task={abortType=0,hashID=890968064,path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'}}},task={hashID=1501473792,path='Runtime.Plugins.AIDesigner.Task.Entry.Entry'}},vars={{key='actionType',type=1,value=1},{key='actionCardID',type=1,value=0},{key='actionSlotIndex',type=1,value=0},{key='expectScore',type=1,value=0},{key='p1NumCardCount',type=1,value=0},{key='p2NumCardCount',type=1,value=0},{key='p1FuncCardCount',type=1,value=0},{key='p2FuncCardCount',type=1,value=0},{key='p1Score',type=1,value=0},{key='p2Score',type=1,value=0},{key='diffScore',type=1,value=0},{key='emptySlotCount',type=1,value=0},{key='p1HandCardCount',type=1,value=0},{key='p1ExpectScore',type=1,value=0},{key='p1ExpectCardID',type=1,value=0},{key='p1ExpectSlotIndex',type=1,value=0},{key='p2ExpectScore',type=1,value=0}}} return Tree