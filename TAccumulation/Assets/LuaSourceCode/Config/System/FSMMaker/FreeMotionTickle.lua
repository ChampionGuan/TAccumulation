local FreeMotionTickle = 
{
	variables	=
	{
		{
			name	=	'CutSceneEventType',
			value	=	'Click',
			varType	=	FSMConst.FSMVarType.String,
			readonly	=	true,
			shareType	=	1,
		},
		{
			name	=	'CutsceneStateName',
			value	=	'CutScene_ST_AnimCard_FreeMotion_ST_D_0003_01_prefab',
			varType	=	FSMConst.FSMVarType.String,
			readonly	=	true,
			shareType	=	1,
		},
		{
			name	=	'animator',
			varType	=	FSMConst.FSMVarType.UObject,
			shareType	=	1,
		},
		{
			name	=	'character',
			varType	=	FSMConst.FSMVarType.UObject,
			shareType	=	1,
		},
		{
			name	=	'clickCollider',
			varType	=	FSMConst.FSMVarType.UObject,
			shareType	=	1,
		},
		{
			name	=	'clickPartId',
			value	=	0,
			varType	=	FSMConst.FSMVarType.Int,
			shareType	=	1,
		},
		{
			name	=	'clickPos',
			value	=	Vector2(0,0),
			varType	=	FSMConst.FSMVarType.Vector2,
			shareType	=	1,
		},
		{
			name	=	'dialogueCtrl',
			varType	=	FSMConst.FSMVarType.LuaObject,
			shareType	=	1,
		},
		{
			name	=	'dialogueId',
			value	=	0,
			varType	=	FSMConst.FSMVarType.Int,
			shareType	=	1,
		},
		{
			name	=	'effector_hand_l',
			varType	=	FSMConst.FSMVarType.LuaObject,
			shareType	=	1,
		},
		{
			name	=	'isCrazy',
			varType	=	FSMConst.FSMVarType.LuaObject,
			shareType	=	1,
		},
		{
			name	=	'isHit',
			varType	=	FSMConst.FSMVarType.LuaObject,
			shareType	=	1,
		},
		{
			name	=	'isProgressFinish',
			value	=	false,
			varType	=	FSMConst.FSMVarType.Bool,
			shareType	=	1,
		},
		{
			name	=	'nodeId',
			value	=	0,
			varType	=	FSMConst.FSMVarType.Int,
			shareType	=	1,
		},
		{
			name	=	'stateId',
			varType	=	FSMConst.FSMVarType.LuaObject,
			shareType	=	1,
		},
	},
	layers	=
	{
		{
			name	=	'Layer1',
			defaultState	=	'Init',
			transitions	=
			{
				{
					eventName	=	'START',
					stateName	=	'Init',
				},
			},
			states	=
			{
				{
					name	=	'CameraAndClick',
					transitions	=
					{
						{
							eventName	=	'CUTSCENE_FINISH',
							stateName	=	'End',
						},
					},
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	2,
						actionType	=	2,
						id	=	-1604405120,
						actions	=
						{
							{
								name	=	'CharacterFollowCameraAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.CharacterFollowCameraAction',
								id	=	102029290,
								params	=
								{
									{
										name	=	'Character',
										refName	=	'character',
										varType	=	FSMConst.FSMVarType.UObject,
										shareType	=	1,
									},
									{
										name	=	'CameraPath',
										value	=	'Assets/Build/Res/GameObjectRes/Camera/CharacterInteractionCamera.prefab',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'TargetBones',
										value	=	{'Head_M','Chest_M'},
										varType	=	FSMConst.FSMVarType.Array,
										subVarType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'OpenUIAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.UI.OpenUIAction',
								id	=	592207161,
								params	=
								{
									{
										name	=	'ViewTag',
										value	=	'FreeMotionInteractionWnd',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'UseCustomSettings',
										value	=	false,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'PanelType',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'PanelOrder',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'AutoCloseMode',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'IsFullScreen',
										value	=	false,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'IsFocusable',
										value	=	false,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'MaskVisible',
										value	=	false,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'BlurType',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'WithAnim',
										value	=	true,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'CharacterClickAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.CharacterClickAction',
								id	=	84226243,
								params	=
								{
									{
										name	=	'Character',
										refName	=	'character',
										varType	=	FSMConst.FSMVarType.UObject,
										shareType	=	1,
									},
									{
										name	=	'BodyGroup',
										value	=	300,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'IsColliderMode',
										value	=	true,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'ClickEvent',
										value	=	'CHARACTER_CLICK',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'ClickPartId',
										refName	=	'clickPartId',
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	1,
									},
									{
										name	=	'ClickCollider',
										refName	=	'clickCollider',
										varType	=	FSMConst.FSMVarType.UObject,
										shareType	=	1,
									},
									{
										name	=	'ClickPos',
										refName	=	'clickPos',
										varType	=	FSMConst.FSMVarType.Vector2,
										shareType	=	1,
									},
									{
										name	=	'CustomMoveThresholdDis',
										value	=	true,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'MoveThresholdDis',
										value	=	200,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'CustomClickEffect',
										value	=	true,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'ClickEffect',
										value	=	'OCX_MainHomeClickActor',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'DragEffect',
										value	=	'OCX_MainHomeDragActor',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'LongPressEffect',
										value	=	'OCX_MainHomeLongPress',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'CutSceneWaitEventAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Animation.CutSceneWaitEventAction',
								id	=	1901273883,
								params	=
								{
									{
										name	=	'EventType',
										value	=	4,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'SendEvent',
										value	=	true,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'EventName',
										value	=	'CUTSCENE_FINISH',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'ScreenTransitionAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Common.ScreenTransitionAction',
								id	=	-86745457,
								params	=
								{
									{
										name	=	'OperationType',
										value	=	1,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'TransitionType',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'SceneTransition',
										value	=	false,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'Duration',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
								},
							},
						},
					},

				},
				{
					name	=	'End',
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-280900617,
						actions	=
						{
							{
								name	=	'ScreenTransitionAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Common.ScreenTransitionAction',
								id	=	1626147367,
								params	=
								{
									{
										name	=	'OperationType',
										value	=	1,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'TransitionType',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'SceneTransition',
										value	=	false,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'Duration',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'FSMFinishedAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FSM.FSMFinishedAction',
								id	=	-1117570738,
							},
						},
					},

				},
				{
					name	=	'Init',
					transitions	=
					{
						{
							eventName	=	'STATE_FINISHED',
							stateName	=	'CameraAndClick',
						},
					},
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-765553008,
						actions	=
						{
							{
								name	=	'ScreenTransitionAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Common.ScreenTransitionAction',
								id	=	1979993109,
								params	=
								{
									{
										name	=	'OperationType',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'TransitionType',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'SceneTransition',
										value	=	false,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'Duration',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'TickleInitAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.TickleInitAction',
								id	=	-1545156370,
								params	=
								{
									{
										name	=	'Character',
										refName	=	'character',
										varType	=	FSMConst.FSMVarType.UObject,
										shareType	=	1,
									},
									{
										name	=	'Animator',
										refName	=	'animator',
										varType	=	FSMConst.FSMVarType.UObject,
										shareType	=	1,
									},
									{
										name	=	'DialogueCtrl',
										refName	=	'dialogueCtrl',
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	1,
									},
									{
										name	=	'DialogueId',
										refName	=	'dialogueId',
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	1,
									},
								},
							},
							{
								name	=	'X3AnimatorAddStateAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Animation.X3AnimatorAddStateAction',
								id	=	-143335494,
								params	=
								{
									{
										name	=	'Animator',
										refName	=	'animator',
										varType	=	FSMConst.FSMVarType.UObject,
										shareType	=	1,
									},
									{
										name	=	'StateName',
										refName	=	'CutsceneStateName',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	1,
									},
									{
										name	=	'CtsName',
										value	=	'CutScene_ST_AnimCard_FreeMotion_ST_D_0003_01_prefab',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'WrapMode',
										value	=	2,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'TransitionDuration',
										value	=	-1,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'InheritTransform',
										value	=	true,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'FSMActionGroup',
								executionType	=	2,
								actionType	=	2,
								id	=	-1473581340,
								actions	=
								{
									{
										name	=	'CutSceneWaitEventAction',
										path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Animation.CutSceneWaitEventAction',
										id	=	1422610806,
										params	=
										{
											{
												name	=	'EventType',
												value	=	5,
												varType	=	FSMConst.FSMVarType.Int,
												shareType	=	0,
											},
											{
												name	=	'SendEvent',
												value	=	false,
												varType	=	FSMConst.FSMVarType.Bool,
												shareType	=	0,
											},
											{
												name	=	'EventName',
												varType	=	FSMConst.FSMVarType.String,
												shareType	=	0,
											},
										},
									},
									{
										name	=	'X3AnimatorPlayAction',
										path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Animation.X3AnimatorPlayAction',
										id	=	-547847651,
										params	=
										{
											{
												name	=	'Animator',
												refName	=	'animator',
												varType	=	FSMConst.FSMVarType.UObject,
												shareType	=	1,
											},
											{
												name	=	'StateName',
												refName	=	'CutsceneStateName',
												varType	=	FSMConst.FSMVarType.String,
												shareType	=	1,
											},
											{
												name	=	'CrossFade',
												value	=	true,
												varType	=	FSMConst.FSMVarType.Bool,
												shareType	=	0,
											},
											{
												name	=	'CustomPlaySetting',
												value	=	false,
												varType	=	FSMConst.FSMVarType.Bool,
												shareType	=	0,
											},
											{
												name	=	'WrapMode',
												value	=	0,
												varType	=	FSMConst.FSMVarType.Int,
												shareType	=	0,
											},
											{
												name	=	'TransitionDuration',
												value	=	0,
												varType	=	FSMConst.FSMVarType.Float,
												shareType	=	0,
											},
											{
												name	=	'InitialTime',
												value	=	0,
												varType	=	FSMConst.FSMVarType.Float,
												shareType	=	0,
											},
										},
									},
								},
							},
						},
					},

				},
			},
		},
		{
			name	=	'ExecuteLayer',
			defaultState	=	'Waiting',
			transitions	=
			{
				{
					eventName	=	'START',
					stateName	=	'Waiting',
				},
			},
			states	=
			{
				{
					name	=	'Execute',
					transitions	=
					{
						{
							eventName	=	'IN_CLICK_CD',
							stateName	=	'Waiting',
						},
						{
							eventName	=	'PROGRESS_FINISH',
							stateName	=	'WaitForExit',
						},
						{
							eventName	=	'STATE_FINISHED',
							stateName	=	'Waiting',
						},
					},
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	1559193194,
						actions	=
						{
							{
								name	=	'TickleAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.TickleAction',
								id	=	-214929534,
								params	=
								{
									{
										name	=	'ClickSetting',
										value	=	'{"1":{"NormalState":[0,1],"CrazyState":[0],"NormalNode":[25],"CrazyNode":[33],"Score":[5,5]},"2":{"NormalState":[2,3],"CrazyState":[5],"NormalNode":[26],"CrazyNode":[34],"Score":[5,5]},"3":{"NormalState":[4],"CrazyState":[6],"NormalNode":[27],"CrazyNode":[35],"Score":[5,5]},"4":{"NormalState":[6],"CrazyState":[8],"NormalNode":[28],"CrazyNode":[36],"Score":[5,5]},"5":{"NormalState":[8],"CrazyState":[10],"NormalNode":[29],"CrazyNode":[37],"Score":[5,5]},"6":{"NormalState":[10],"CrazyState":[12],"NormalNode":[30],"CrazyNode":[38],"Score":[5,5]},"7":{"NormalState":[12],"CrazyState":[14,15],"NormalNode":[31],"CrazyNode":[39],"Score":[5,5]},"8":{"NormalState":[14],"CrazyState":[16,17],"NormalNode":[32],"CrazyNode":[40],"Score":[5,5]}}',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'ProgressReductionRate',
										value	=	0.4,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'CDTime',
										value	=	0.3,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'CrazyHitThresholdTime',
										value	=	0.8,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'WaitingTime',
										value	=	0.5,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'GameObject',
										refName	=	'character',
										varType	=	FSMConst.FSMVarType.UObject,
										shareType	=	1,
									},
									{
										name	=	'ClickPartId',
										refName	=	'clickPartId',
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	1,
									},
									{
										name	=	'ClickCollider',
										refName	=	'clickCollider',
										varType	=	FSMConst.FSMVarType.UObject,
										shareType	=	1,
									},
									{
										name	=	'ClickPos',
										refName	=	'clickPos',
										varType	=	FSMConst.FSMVarType.Vector2,
										shareType	=	1,
									},
									{
										name	=	'NodeId',
										refName	=	'nodeId',
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	1,
									},
									{
										name	=	'Effector_Hand_L',
										refName	=	'effector_hand_l',
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	1,
									},
									{
										name	=	'StateId',
										refName	=	'stateId',
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	1,
									},
									{
										name	=	'IsCrazyHit',
										refName	=	'isCrazy',
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	1,
									},
									{
										name	=	'IsHit',
										refName	=	'isHit',
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	1,
									},
								},
							},
							{
								name	=	'FireEvent',
								path	=	'Runtime.Plugins.FSMMaker.Actions.FSMEvent',
								id	=	1899772496,
								tickable	=	true,
								params	=
								{
									{
										name	=	'eventName',
										value	=	'PLAY_DIALOGUE',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'isGlobal',
										value	=	false,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'isGame',
										value	=	false,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'CutSceneSendEventAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Animation.CutSceneSendEventAction',
								id	=	1913648734,
								params	=
								{
									{
										name	=	'EventType',
										refName	=	'CutSceneEventType',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	1,
									},
									{
										name	=	'WithParam',
										value	=	true,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'Param',
										value	=	'Effector_Hand_L',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'Value',
										refName	=	'effector_hand_l',
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	1,
									},
								},
							},
							{
								name	=	'CutSceneSendEventAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Animation.CutSceneSendEventAction',
								id	=	259810613,
								params	=
								{
									{
										name	=	'EventType',
										refName	=	'CutSceneEventType',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	1,
									},
									{
										name	=	'WithParam',
										value	=	true,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'Param',
										value	=	'StateId',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'Value',
										refName	=	'stateId',
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	1,
									},
								},
							},
							{
								name	=	'CutSceneSendEventAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Animation.CutSceneSendEventAction',
								id	=	-2124267331,
								params	=
								{
									{
										name	=	'EventType',
										refName	=	'CutSceneEventType',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	1,
									},
									{
										name	=	'WithParam',
										value	=	true,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'Param',
										value	=	'IsCrazyHit',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'Value',
										refName	=	'isCrazy',
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	1,
									},
								},
							},
							{
								name	=	'CutSceneSendEventAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Animation.CutSceneSendEventAction',
								id	=	227900129,
								params	=
								{
									{
										name	=	'EventType',
										refName	=	'CutSceneEventType',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	1,
									},
									{
										name	=	'WithParam',
										value	=	true,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'Param',
										value	=	'IsHit',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'Value',
										refName	=	'isHit',
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	1,
									},
								},
							},
						},
					},

				},
				{
					name	=	'WaitForExit',
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	547970189,
					},

				},
				{
					name	=	'Waiting',
					transitions	=
					{
						{
							eventName	=	'CHARACTER_CLICK',
							stateName	=	'Execute',
						},
						{
							eventName	=	'PROGRESS_FINISH',
							stateName	=	'WaitForExit',
						},
					},
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-1733813249,
						actions	=
						{
							{
								name	=	'TickleWaitAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.TickleWaitAction',
								id	=	1776495236,
								tickable	=	true,
								params	=
								{
									{
										name	=	'IsCrazyHit',
										refName	=	'isCrazy',
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	1,
									},
									{
										name	=	'CoolTime',
										value	=	0.5,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
								},
							},
						},
					},

				},
			},
		},
		{
			name	=	'DialogueLayer',
			defaultState	=	'WaitingForPlay',
			transitions	=
			{
				{
					eventName	=	'START',
					stateName	=	'WaitingForPlay',
				},
			},
			states	=
			{
				{
					name	=	'Dialogue',
					transitions	=
					{
						{
							eventName	=	'PROGRESS_FINISH',
							stateName	=	'WaitForEnd',
						},
						{
							eventName	=	'STATE_FINISHED',
							stateName	=	'WaitingForPlay',
						},
					},
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-955786784,
						actions	=
						{
							{
								name	=	'DialogueStartByIdAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Dialogue.DialogueStartByIdAction',
								id	=	-899889475,
								params	=
								{
									{
										name	=	'Ctrl',
										refName	=	'dialogueCtrl',
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	1,
									},
									{
										name	=	'DialogueId',
										refName	=	'dialogueId',
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	1,
									},
									{
										name	=	'ConversationId',
										value	=	6,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'NodeId',
										refName	=	'nodeId',
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	1,
									},
									{
										name	=	'PipelineKey',
										value	=	'CharacterInteraction',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
								},
							},
						},
					},

				},
				{
					name	=	'WaitForEnd',
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-995458294,
					},

				},
				{
					name	=	'WaitingForPlay',
					transitions	=
					{
						{
							eventName	=	'PLAY_DIALOGUE',
							stateName	=	'Dialogue',
						},
						{
							eventName	=	'PROGRESS_FINISH',
							stateName	=	'WaitForEnd',
						},
					},
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-1372845101,
					},

				},
			},
		},
	},
}
return FreeMotionTickle
