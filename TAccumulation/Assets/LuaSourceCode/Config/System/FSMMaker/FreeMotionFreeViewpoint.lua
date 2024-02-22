local FreeMotionFreeViewpoint = 
{
	variables	=
	{
		{
			name	=	'animator',
			varType	=	FSMConst.FSMVarType.UObject,
			shareType	=	1,
		},
		{
			name	=	'CutSceneName',
			varType	=	FSMConst.FSMVarType.String,
			shareType	=	1,
		},
		{
			name	=	'Down',
			value	=	2,
			varType	=	FSMConst.FSMVarType.Int,
			shareType	=	1,
		},
		{
			name	=	'Left',
			value	=	3,
			varType	=	FSMConst.FSMVarType.Int,
			shareType	=	1,
		},
		{
			name	=	'Right',
			value	=	4,
			varType	=	FSMConst.FSMVarType.Int,
			shareType	=	1,
		},
		{
			name	=	'Up',
			value	=	1,
			varType	=	FSMConst.FSMVarType.Int,
			shareType	=	1,
		},
	},
	layers	=
	{
		{
			name	=	'Layer1',
			defaultState	=	'Start',
			transitions	=
			{
				{
					eventName	=	'START',
					stateName	=	'Start',
				},
			},
			states	=
			{
				{
					name	=	'Finish',
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-1013681057,
						actions	=
						{
							{
								name	=	'FSMFinishedAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FSM.FSMFinishedAction',
								id	=	-1933898224,
							},
						},
					},

				},
				{
					name	=	'Start',
					transitions	=
					{
						{
							eventName	=	'FREE_VIEWPOINT_FINISH',
							stateName	=	'Finish',
						},
					},
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	1360440165,
						actions	=
						{
							{
								name	=	'FreeViewpointAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.FreeViewpointAction',
								id	=	45758186,
								params	=
								{
									{
										name	=	'Camera',
										value	=	'Assets/Build/Art/Drama/Performance/AnimCard/ST/ST_D_0012/VirtualCamera/ST_D_0012_CC03_CM_MixingCamera.prefab',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'CacheCamera',
										value	=	true,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'TipsTextID',
										value	=	1050902,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'AccRateX',
										value	=	0.1,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'AccRateY',
										value	=	0.1,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'FinishType',
										refName	=	'Down',
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	1,
									},
									{
										name	=	'FinishWeight',
										value	=	0.9,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'FinishTime',
										value	=	1,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'MaxBD',
										value	=	1,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'MaxSpeed',
										value	=	0.3,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'DecBD',
										value	=	0.7,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'DecRate',
										value	=	0.3,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'MoveThresholdDis',
										value	=	30,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'UseAcc',
										value	=	false,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'NeedLerp',
										value	=	true,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'LerpRate',
										value	=	2,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'X3AnimatorAddStateAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Animation.X3AnimatorAddStateAction',
								id	=	-1142498444,
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
										refName	=	'CutSceneName',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	1,
									},
									{
										name	=	'StateType',
										value	=	2,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'AnimClip',
										varType	=	FSMConst.FSMVarType.UObject,
										shareType	=	0,
									},
									{
										name	=	'ProceduralAnimClip',
										varType	=	FSMConst.FSMVarType.UObject,
										shareType	=	0,
									},
									{
										name	=	'CtsName',
										refName	=	'CutSceneName',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	1,
									},
									{
										name	=	'WrapMode',
										value	=	1,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'ExitTime',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Float,
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
								name	=	'X3AnimatorPlayAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Animation.X3AnimatorPlayAction',
								id	=	-915074172,
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
										refName	=	'CutSceneName',
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
}
return FreeMotionFreeViewpoint
