﻿local Tree = {pauseWhenComplete=true,tickInterval=0,tree={children={{children={{children={{children={{task={hashID=1606135808,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Date.Common.Condition.CheckIsPaused'}}},task={hashID=-110101504,path='Runtime.Plugins.AIDesigner.Task.Decorator.Inverter'}},{children={{children={{task={hashID=-1835086848,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Date.UFOCatcher.Action.MoveClaw',vars={{key='distanceRangeX',type=5,value={x=80,y=150}},{key='distanceRangeZ',type=5,value={x=80,y=150}}}}},{task={hashID=-118849536,path='Runtime.Plugins.AIDesigner.Task.Action.Wait',vars={{isShared=true,key='waitTime',type=0,value={value=1000}},{isShared=true,key='randomWait',type=3,value={value=true}},{isShared=true,key='randomWaitMin',type=0,value={value=500}},{isShared=true,key='randomWaitMax',type=0,value={value=1000}}}}},{task={hashID=-1487380480,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Date.UFOCatcher.Condition.CheckNearDoll',vars={{key='distance',type=0,value=100},{key='checkDistance',type=0,value=10}}}}},task={abortType=0,hashID=743643136,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}}},task={hashID=-972594176,path='Runtime.Plugins.AIDesigner.Task.Decorator.UntilSuccess'}},{children={{children={{task={hashID=-1185331200,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Date.UFOCatcher.Action.MoveClaw',vars={{key='distanceRangeX',type=5,value={x=10,y=20}},{key='distanceRangeZ',type=5,value={x=10,y=20}}}}},{task={hashID=530906112,path='Runtime.Plugins.AIDesigner.Task.Action.Wait',vars={{isShared=true,key='waitTime',type=0,value={value=1000}},{isShared=true,key='randomWait',type=3,value={value=true}},{isShared=true,key='randomWaitMin',type=0,value={value=500}},{isShared=true,key='randomWaitMax',type=0,value={value=1000}}}}},{task={hashID=-2047823872,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Date.UFOCatcher.Condition.CheckNearDoll',vars={{key='distance',type=0,value=30},{key='checkDistance',type=0,value=10}}}}},task={abortType=0,hashID=1393398784,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}}},task={hashID=1945094144,path='Runtime.Plugins.AIDesigner.Task.Decorator.UntilSuccess'}},{task={hashID=-331586560,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Date.Common.Action.ChangeState'}}},task={abortType=0,hashID=-1826338816,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},{children={{children={{task={hashID=522158080,path='Runtime.Plugins.AIDesigner.Task.Condition.HasReceivedEvent',vars={{key='eventName',type=2,value='AIResume'}}}}},task={hashID=-1194079232,path='Runtime.Plugins.AIDesigner.Task.Decorator.UntilSuccess'}},{children={{children={{task={hashID=280728576,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Date.UFOCatcher.Condition.CheckHasCommand'}}},task={hashID=-1435508736,path='Runtime.Plugins.AIDesigner.Task.Decorator.Inverter'}},{task={hashID=-581764096,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Date.UFOCatcher.Action.ExecutePlayerCommand',vars={{key='duration',type=0,value=100},{key='durationVar',type=0,value=200}}}}},task={abortType=0,hashID=1143221248,path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'}},{children={{children={{task={hashID=271980544,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Date.UFOCatcher.Condition.CheckHasCheerBuff'}}},task={hashID=-1444256768,path='Runtime.Plugins.AIDesigner.Task.Decorator.Inverter'}},{task={hashID=1988217856,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Date.UFOCatcher.Action.UFOCheerMove'}}},task={abortType=0,hashID=1134473216,path='Runtime.Plugins.AIDesigner.Task.Composite.Selector'}},{task={hashID=-590512128,path='Runtime.Plugins.AIDesigner.Task.Action.Wait',vars={{isShared=true,key='waitTime',type=0,value={value=500}},{isShared=true,key='randomWait',type=3,value={value=true}},{isShared=true,key='randomWaitMin',type=0,value={value=500}},{isShared=true,key='randomWaitMax',type=0,value={value=1000}}}}},{task={hashID=-1953013760,path='Runtime.System.X3Game.Modules.AIDesigner.Task.Date.UFOCatcher.Action.UFOCatcherCatch'}}},task={abortType=0,hashID=1384650752,path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}}},task={abortType=0,hashID=752391168,path='Runtime.Plugins.AIDesigner.Task.Composite.Parallel'}}},task={hashID=1479460864,path='Runtime.Plugins.AIDesigner.Task.Entry.Entry'}},vars={{key='catchTarget',type=4},{key='UFOCatcher',type=4},{key='clawBody',type=4}}} return Tree