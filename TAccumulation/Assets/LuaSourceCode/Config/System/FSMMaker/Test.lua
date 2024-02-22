local Test = 
{
	layers	=
	{
		{
			name	=	'Layer1',
			defaultState	=	'State1',
			transitions	=
			{
				{
					eventName	=	'START',
					stateName	=	'State1',
				},
			},
			states	=
			{
				{
					name	=	'State1',
					actionGroup	=
					{

						name	=	'FSMActionGroup',
						executionType	=	1,
						actionType	=	2,
						actions	=
						{
							{
								name	=	'TestArrayAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Test.TestArrayAction',
								params	=
								{
									{
										name	=	'testArrayInt',
										varType	=	FSMConst.FSMVarType.Array,
										subVarType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'testArrayBoolean',
										varType	=	FSMConst.FSMVarType.Array,
										subVarType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
									{
										name	=	'testArrayString',
										varType	=	FSMConst.FSMVarType.Array,
										subVarType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'testArrayFloat',
										varType	=	FSMConst.FSMVarType.Array,
										subVarType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'testVector2',
										value	=	Vector2(0,0),
										varType	=	FSMConst.FSMVarType.Vector2,
										shareType	=	0,
									},
									{
										name	=	'testVector3',
										value	=	Vector3(0,0,0),
										varType	=	FSMConst.FSMVarType.Vector3,
										shareType	=	0,
									},
									{
										name	=	'testVector4',
										value	=	Vector4(0,0,0,0),
										varType	=	FSMConst.FSMVarType.Vector4,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'TestBasicAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Test.TestBasicAction',
								params	=
								{
									{
										name	=	'testInt',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Int,
										shareType	=	0,
									},
									{
										name	=	'testString',
										varType	=	FSMConst.FSMVarType.String,
										shareType	=	0,
									},
									{
										name	=	'testFloat',
										value	=	0,
										varType	=	FSMConst.FSMVarType.Float,
										shareType	=	0,
									},
									{
										name	=	'testBool',
										value	=	false,
										varType	=	FSMConst.FSMVarType.Bool,
										shareType	=	0,
									},
								},
							},
							{
								name	=	'TestLifecycleAction',
								path	=	'Runtime.System.X3Game.Modules.FSMMaker.Actions.Test.TestLifecycleAction',
								tickable	=	true,
							},
						},
					},

				},
			},
		},
	},
}
return Test
