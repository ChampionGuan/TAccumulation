﻿local Tree = {tasks={[-1677513728]={offset={x=330.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Decorator.Repeater'},[-485347328]={comment='主界面状态机',offset={x=-10.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Action.TreeReference'},[38723584]={comment='主界面交互树',offset={x=-17.0,y=150.0},path='Runtime.Plugins.AIDesigner.Task.Action.TreeReference'},[147308928]={comment='主界面入口初始化',offset={x=-1310.0,y=300.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.Logic.MainHomeEnter'},[271717376]={offset={x=480.0,y=100.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Parallel'},[1128995840]={comment='主界面主树',offset={x=0.0,y=0.0},path='Runtime.Plugins.AIDesigner.Task.Entry.Entry'},[1799873536]={comment='[EditorOnly]下显示action各列表详细信息',offset={x=-980.0,y=300.0},path='Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeActionForEditor'},[2093382656]={offset={x=-310.0,y=140.0},path='Runtime.Plugins.AIDesigner.Task.Decorator.Repeater'},[2126086144]={offset={x=0.0,y=120.0},path='Runtime.Plugins.AIDesigner.Task.Composite.Sequence'}},trees={},variables={actionCheckList={desc='[EditorOnly]当前可触发的action列表'},actionPendingTypeList={desc='[EditorOnly]待处理列表'},actionRunningTypeList={desc='[EditorOnly]当前正在执行的action列表'},actionTopBarTypeList={desc='[EditorOnly]控制当前topbar的action列表'},actionWaitingTypeList={desc='[EditorOnly]当前正在等待的action列表'},actorId={desc='看板娘id'},clearActionType={desc='清理action的类型\nALL=-1,  Focus=1,ExitInteract=2,\nViewMoving =3,Action = 4,\nState = 1101,Exit = 1102,   '},conversationName={desc='剧情的conversation'},dialogSpEvent={desc=' 剧情结束之后特殊事件'},dialogueId={desc='剧情id'},eventId={desc='事件id'},handlerTypeList={desc='[EditorOnly]当前在执行的操作列表'},isPause={desc='是否暂停'},isRunning={desc='是否有正在处理的逻辑'},lastLocalState={desc='上次状态'},lastViewType={desc='上次viewType'},localState={desc='本地状态：1:主界面主体状态，2：连麦状态'},mode={desc='当前主界面的模式：1：正常模式，2：互动模式'},runningType={desc='正在运行的逻辑类型'},sceneId={desc='当前场景id'},stateConfId={desc='MainUIActorState配置表id'},stateId={desc='板娘状态id'},viewType={desc='当前view类型：1：约会，2：主界面，3：行动，4:交护界面'}}} return Tree