local FreeMotionColoring = 
{
	layers	=
	{
		{
			name	=	'Layer1',
			defaultState	=	'BeginPaint',
			transitions	=
			{
				{
					eventName	=	'START',
					stateName	=	'BeginPaint',
				},
			},
			states	=
			{
				{
					name	=	'BeginPaint',
					transitions	=
					{
						{
							eventName	=	'FAILED',
							stateName	=	'Failed',
						},
						{
							eventName	=	'SUCCESS',
							stateName	=	'Success',
						},
					},
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-542302026,
						actions	=
						{
							{
								name	=	'PaintingAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.PaintingAction',
								id	=	313607945,
								params	=
								{
									{
										name	=	'filledRateThreshold',
										value	=	0.95,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'distanceThreshold',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'image',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'imageWorldPosition',
										value	=	Vector3(0,0,0),
										varType	=	FSMConst.FSMVarType.Vector3,
										shareType	=	0,
									},
									{
										name	=	'viewTag',
										value	=	'FreeMotionColoringWnd',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'sdf',
										value	=	'FreeMotionPaint_Coloring_SDF',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'validateRegion',
										varType	=	FSMConst.FSMVarType.Array,
										subVarType	=	FSMConst.FSMVarType.Rect,
										shareType	=	0,
									},
									{
										name	=	'paintingMat',
										value	=	'Assets/Build/Res/GameObjectRes/Entity/FreeMotion/PaintAsset/FreeMotionPaint_Coloring_Mat.mat',
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
						id	=	-1032065529,
					},

				},
				{
					name	=	'Success',
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-455251782,
					},

				},
			},
		},
	},
}
return FreeMotionColoring
