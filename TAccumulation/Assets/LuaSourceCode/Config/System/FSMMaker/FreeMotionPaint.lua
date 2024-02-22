local FreeMotionPaint = 
{
	variables	=
	{
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
	},
	layers	=
	{
		{
			name	=	'Layer1',
			defaultState	=	'BeginPainting',
			transitions	=
			{
				{
					eventName	=	'START',
					stateName	=	'BeginPainting',
				},
			},
			states	=
			{
				{
					name	=	'BeginPainting',
					transitions	=
					{
						{
							eventName	=	'PAINTING_FAILED',
							stateName	=	'Failed',
						},
						{
							eventName	=	'PAINTING_SUCCESS',
							stateName	=	'Success',
						},
					},
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-1910810249,
						actions	=
						{
							{
								name	=	'TickleInitAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.TickleInitAction',
								id	=	914144939,
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
								name	=	'PaintingAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.PaintingAction',
								id	=	-975251314,
								params	=
								{
									{
										name	=	'filledRateThreshold',
										value	=	0.75,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'distanceThreshold',
										value	=	15.5,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'image',
										value	=	'x3_freemotion_paint_bunnyear',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'imageWorldPosition',
										value	=	Vector3(110,385,0),
										varType	=	FSMConst.FSMVarType.Vector3,
										shareType	=	0,
									},
									{
										name	=	'viewTag',
										value	=	'FreeMotionPaintWnd',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'sdf',
										value	=	'FreeMotionPaint_BunnyEar_SDF',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'validateRegion',
										value	=	{CS.UnityEngine.Rect(0,0,0.4,0.5),CS.UnityEngine.Rect(0.6,0,0.4,0.5)},
										varType	=	FSMConst.FSMVarType.Array,
										subVarType	=	FSMConst.FSMVarType.Rect,
										shareType	=	0,
									},
									{
										name	=	'paintingMat',
										value	=	'Assets/Build/Res/GameObjectRes/Entity/FreeMotion/PaintAsset/FreeMotionPaint_BunnyEar_Mat.mat',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
								},
							},
						},
					},

				},
				{
					name	=	'Failed',
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-1993164858,
						actions	=
						{
							{
								name	=	'DialogueChangeVariableAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Dialogue.DialogueChangeVariableAction',
								id	=	-1295396973,
								params	=
								{
									{
										name	=	'Ctrl',
										refName	=	'dialogueCtrl',
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	1,
									},
									{
										name	=	'VariableKey',
										value	=	1,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'VariableValue',
										value	=	1,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'FSMFinishedAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FSM.FSMFinishedAction',
								id	=	1823307279,
							},
						},
					},

				},
				{
					name	=	'Success',
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	324588411,
						actions	=
						{
							{
								name	=	'DialogueChangeVariableAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Dialogue.DialogueChangeVariableAction',
								id	=	-234020968,
								params	=
								{
									{
										name	=	'Ctrl',
										refName	=	'dialogueCtrl',
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	1,
									},
									{
										name	=	'VariableKey',
										value	=	1,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'VariableValue',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'FSMFinishedAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FSM.FSMFinishedAction',
								id	=	1692129534,
							},
						},
					},

				},
			},
		},
	},
}
return FreeMotionPaint
