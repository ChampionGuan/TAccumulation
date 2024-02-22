local FreeMotionWrestle = 
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
			defaultState	=	'角力互动',
			transitions	=
			{
				{
					eventName	=	'START',
					stateName	=	'角力互动',
				},
			},
			states	=
			{
				{
					name	=	'Failed',
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	198283395,
						actions	=
						{
							{
								name	=	'DialogueChangeVariableAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Dialogue.DialogueChangeVariableAction',
								id	=	-666966232,
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
								id	=	-819592563,
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
						id	=	-478136085,
						actions	=
						{
							{
								name	=	'DialogueChangeVariableAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Dialogue.DialogueChangeVariableAction',
								id	=	-505634903,
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
								id	=	974965227,
							},
						},
					},

				},
				{
					name	=	'角力互动',
					transitions	=
					{
						{
							eventName	=	'WrestleFaild',
							stateName	=	'Failed',
						},
						{
							eventName	=	'WrestleSuccess',
							stateName	=	'Success',
						},
					},
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-1168912981,
						actions	=
						{
							{
								name	=	'TickleInitAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.TickleInitAction',
								id	=	-619683108,
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
								name	=	'WrestleAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.WrestleAction',
								id	=	-1800832790,
								tickable	=	true,
								params	=
								{
									{
										name	=	'InitPower',
										value	=	0.5,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'PowerSubNumMin',
										value	=	0.2,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'PowerSubNumMax',
										value	=	0.3,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'PowerAddNumMax',
										value	=	0.1,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'PowerAddNumMin',
										value	=	0.05,
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
return FreeMotionWrestle
