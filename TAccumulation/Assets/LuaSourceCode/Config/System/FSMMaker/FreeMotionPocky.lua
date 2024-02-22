local FreeMotionPocky = 
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
					name	=	'Eat',
					transitions	=
					{
						{
							eventName	=	'STATE_FINISHED',
							stateName	=	'End',
						},
					},
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	2,
						actionType	=	2,
						id	=	-1483624416,
						actions	=
						{
							{
								name	=	'PockyEatAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.PockyEatAction',
								id	=	587560327,
								params	=
								{
									{
										name	=	'ShowType',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'StartTime',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'EndTime',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'PlayPercent',
										value	=	0.1,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'Character',
										refName	=	'character',
										varType	=	FSMConst.FSMVarType.UObject,
										shareType	=	1,
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
						id	=	1577649577,
						actions	=
						{
							{
								name	=	'FSMFinishedAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FSM.FSMFinishedAction',
								id	=	-1525777093,
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
							stateName	=	'Eat',
						},
					},
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	1659088685,
						actions	=
						{
							{
								name	=	'OpenUIAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.UI.OpenUIAction',
								id	=	-1431295191,
								params	=
								{
									{
										name	=	'ViewTag',
										value	=	'FreeMotionPockyWnd',
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
						},
					},

				},
			},
		},
	},
}
return FreeMotionPocky
