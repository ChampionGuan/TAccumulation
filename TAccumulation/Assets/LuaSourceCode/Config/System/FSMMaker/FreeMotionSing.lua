local FreeMotionSing = 
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
			varType	=	FSMConst.FSMVarType.UObject,
			shareType	=	1,
		},
		{
			name	=	'dialogueId',
			varType	=	FSMConst.FSMVarType.UObject,
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
						id	=	-1191098599,
						actions	=
						{
							{
								name	=	'FSMFinishedAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FSM.FSMFinishedAction',
								id	=	-1059721846,
							},
						},
					},

				},
				{
					name	=	'PlayMuteCallback',
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-2103585553,
					},

				},
				{
					name	=	'Start',
					transitions	=
					{
						{
							eventName	=	'STATE_FINISHED',
							stateName	=	'Finish',
						},
					},
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						id	=	-621019173,
						actions	=
						{
							{
								name	=	'SingInitAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.SingInitAction',
								id	=	-2127160944,
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
										varType	=	FSMConst.FSMVarType.LuaObject,
										shareType	=	0,
									},
									{
										name	=	'DialogueId',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'SingAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.FreeMotion.SingAction',
								id	=	862767396,
								params	=
								{
									{
										name	=	'MicVoiceCheckTime',
										value	=	1,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'SuccessJumpConversationId',
										value	=	6,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'MicSilenceDuration',
										value	=	10,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'FailJumpConversationId',
										value	=	5,
										varType	=	FSMConst.FSMVarType.Int,
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
return FreeMotionSing
