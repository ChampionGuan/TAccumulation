using System.Collections.Generic;
using PapeGames.X3;
using Pathfinding;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class PlayerInput : BattleComponent
    {
        private struct SCastSkill
        {
            public PlayerBtnType btnType;
            public int casterID;
            public bool isUI;

            public SCastSkill(PlayerBtnType btn, int casterId,bool isUi)
            {
                this.btnType = btn;
                this.casterID = casterId;
                this.isUI = isUi;
            }
        }

        public List<PlayerBtnType> _btnSort = new List<PlayerBtnType>()
        {
            PlayerBtnType.Ultra, // 爆发技能
            PlayerBtnType.Coop,
            PlayerBtnType.Dodge,
            PlayerBtnType.Active,
            PlayerBtnType.Attack,
        };

        public Vector3 inputDir => _currDir;

        protected ActorCommander _commander;
        protected Transform _cameraTransform;

        protected bool _isAxisDrag;
        protected Vector3 _axisPosCache;
        protected float _axisAngleYCache;

        protected Vector3 _currAxis = Vector3.zero;
        protected Vector3 _currDir = Vector3.zero;
        protected Vector3 _lastDir = Vector3.zero;
        private int _preVertKeyCode = 0;
        private int _preHoriKeyCode = 0;
        //缓存指令 现在指令需要排序后执行
        private List<SCastSkill> _cashCastSkillCmd = new List<SCastSkill>(4);
        private List<SCastSkill> _cashSortSkillCmd = new List<SCastSkill>(4);
        private int _cashMoveCmdNum = 0;

        public PlayerInput() : base(BattleComponentType.PlayerInput)
        {
            requiredLateUpdate = true;
        }
        protected override void OnLateUpdate()
        {
            base.OnLateUpdate();
#if UNITY_EDITOR
            if (CameraTest())
                return;
#endif
        }

        public void ClearPlayerCache()
        {
            _cashCastSkillCmd.Clear();
            _cashSortSkillCmd.Clear();
        }
        
        public override void OnActorBorn(Actor actor)
        {
            base.OnActorBorn(actor);
            if (battle.player == actor)
            {
                _commander = battle.player.commander;
                _cameraTransform = Battle.Instance.cameraTrace.GetCameraTransform();
                if (_cameraTransform == null)
                    LogProxy.LogError("PlayInput获取Camera失败");
            }
        }

        public override void OnActorRecycle(Actor actor)
        {
            base.OnActorRecycle(actor);
            if (battle.player == null)
            {
                _commander = null;
            }
        }


        public void BeginAxisDrag()
        {
            _isAxisDrag = true;
        }

        public void EndAxisDrag()
        {
            _isAxisDrag = false;
            _currAxis = Vector3.zero;
            UpdateMove();
        }

        public void SetAxis(float x, float y, float z)
        {
            BeginAxisDrag();
            _currAxis = new Vector3(x, y, z);
            UpdateMove();
        }

        
        protected void UpdateMove()
        {
            _cashMoveCmdNum++;
        }

        protected void _UpdateInputDir()
        {
            if (_commander == null)
                return;
            
            _currDir = _GetAxisDir(_currAxis); 
        }

        protected void _UpdateMoveCmd()
        {
            using (ProfilerDefine.InputUpdateMovePMarker.Auto())
            {
                if (_currDir != Vector3.zero)
                {
                    if (_currDir != _lastDir || _commander.currentCmd == null)
                    {
                        _currDir.Normalize();

                        //指令从池取
                        using (ProfilerDefine.InputGetCmd1PMarker.Auto())
                        {
                            var cmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                            cmd.Init(_currDir);
                            _commander.TryExecute(cmd);
                        }
                    }
                }
                else
                {
                    if (_currDir != _lastDir)
                    {
                        //指令从池取
                        using (ProfilerDefine.InputGetCmd2PMarker.Auto())
                        {
                            var cmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                            cmd.Init(_currDir);
                            _commander.TryExecute(cmd);
                        }
                    }
                }
                _lastDir = _currDir;
            }
        }
        protected Vector3 _GetAxisDir(Vector3 Axis)
        {
            if (_cameraTransform == null)
            {
                return Axis;
            }

            if (_axisPosCache != _cameraTransform.position || _axisAngleYCache != _cameraTransform.localEulerAngles.y)
            {
                var rotatedAxis = Quaternion.Euler(0, _cameraTransform.localEulerAngles.y, 0) * Axis;
                rotatedAxis.Normalize();
                _axisPosCache = rotatedAxis;
            }

            return _axisPosCache;
        }

        private void _SetLockMode(TargetLockModeType lockModeType)
        {
            var cmd = ObjectPoolUtility.GetActorCmd<ActorLockModeCommand>();
            cmd?.Init(lockModeType);
            _commander.TryExecute(cmd);
            battle.setting.SetLockModeType(lockModeType);
        }

        /// <summary> 手动模式下切换目标 </summary>
        public void ManualSwitchTarget()
        {
            using (ProfilerDefine.InputManualSwitchTargetPMarker.Auto())
            {
                var _cmd = ObjectPoolUtility.GetActorCmd<ActorSwitchTargetCmd>();
                _commander.TryExecute(_cmd);
            }
        }

        /// <summary> 手动模式下清空缓存列表 </summary>
        public void CancelManual()
        {
            using (ProfilerDefine.InputCancelManualPMarker.Auto())
            {
                _commander.TryExecute(new ActorCancelLockCacheCmd());
            }
        }

        /// <summary>
        /// 切换自动模式和手动模式，目前锁定模式只有AI和Smart
        /// </summary>
        /// <param name="ai"></param>
        public void TrySwitchAuto(bool ai)
        {
            var actor = battle.player;
            if (actor == null)
            {
                return;
            }

            using (ProfilerDefine.InputTrySwitchAutoPMarker.Auto())
            {
                _SetLockMode(ai ? TargetLockModeType.AI : TargetLockModeType.Smart);
                //TODO,移到某个指令中
                actor.aiOwner?.DisableAI(!ai, AISwitchType.Player);
                actor.commander.ClearCmd();
                // 清除输入缓存
                actor.input?.ClearCache();
            }
        }
        

        protected override void OnUpdate()
        {
            base.OnUpdate();
            //先更新input方向 技能需要获取
            _UpdateInputDir();
#if UNITY_EDITOR
            //Editor键盘操作
            MoveTest();
            SkillTest();
            BattleTest();
#endif
            //更新actor.input数据 按钮来的数据要在最开始更新 所以把actor.input的数据放在这里更新
            battle.actorMgr.girl?.input?.SetBtnState();
            battle.actorMgr.boy?.input?.SetBtnState();
            
            //先对同帧指令进行排序
            _SortSkillCmd();
#if UNITY_EDITOR
            if (_cashSortSkillCmd.Count + _cashMoveCmdNum > 0)
            {
                int index = 0;
                foreach (var sCastSkill in _cashSortSkillCmd)
                {
                    LogProxy.LogFormat("当前帧 = " + battle.frameCount + "当前指令 = " + sCastSkill.btnType + " index = " + index);
                    index++;
                }

                if (_cashMoveCmdNum > 0)
                {
                    LogProxy.LogFormat("当前帧 = " + battle.frameCount + "移动指令数量 = " + _cashMoveCmdNum);
                }
            }
#endif
            //再执行技能指令
            foreach (var castSkill in _cashSortSkillCmd)
            {
                LogProxy.Log("技能指令：执行指令 技能类型 = " + castSkill.btnType + " frame = " + battle.frameCount);
                _TryCastSkill(castSkill.btnType, castSkill.casterID, castSkill.isUI);
            }
            _cashSortSkillCmd.Clear();
            _cashCastSkillCmd.Clear();
            //再执行移动指令
            for (int i = 0; i < _cashMoveCmdNum; i++)
            {
                _UpdateMoveCmd();   
            }

            _cashMoveCmdNum = 0;
        }
        /// <summary>
        /// 手机测试使用
        /// </summary>
        /// <param name="lockModeType"></param>
        public void SetLockMode(TargetLockModeType lockModeType)
        {
            var cmd = ObjectPoolUtility.GetActorCmd<ActorLockModeCommand>();
            cmd?.Init(lockModeType);
            _commander.TryExecute(cmd);
            battle.setting.SetLockModeType(lockModeType);
        }

#if UNITY_EDITOR        
        bool CameraTest()
        {
            if (Input.GetAxis("Mouse ScrollWheel") < 0)
            {
                battle.cameraTrace.MoveBack();
                if (Input.GetMouseButton(1))
                    battle.cameraTrace.PullOnt();
            }

            if (Input.GetAxis("Mouse ScrollWheel") > 0)
            {
                battle.cameraTrace.MoveForward();
                if (Input.GetMouseButton(1))
                    battle.cameraTrace.PullIn();
            }

            if (battle.cameraTrace.currMode == CameraModeType.FreeLook && Input.GetMouseButton(1))
            {
                // 自由相机模式下，如果按住右键，那么方向键只会控制镜头移动，人物不会移动
                bool arrowBtnDown = false; // 方向键是否被按下
                if (Input.GetKey(KeyCode.UpArrow))
                {
                    battle.cameraTrace.MoveForward();
                    arrowBtnDown = true;
                }

                if (Input.GetKey(KeyCode.DownArrow))
                {
                    battle.cameraTrace.MoveBack();
                    arrowBtnDown = true;
                }

                if (Input.GetKey(KeyCode.LeftArrow))
                {
                    battle.cameraTrace.MoveLeft();
                    arrowBtnDown = true;
                }

                if (Input.GetKey(KeyCode.RightArrow))
                {
                    battle.cameraTrace.MoveRight();
                    arrowBtnDown = true;
                }

                if (arrowBtnDown)
                    return true;
            }

            return false;
        }

        void MoveTest()
        {
            if (Input.GetKeyDown(KeyCode.Keypad8))
            {
                LogProxy.Log("战斗 - 发起移动指令Cmd: 朝着原点徘徊, 向前, 5秒");
                var _dirCmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                _dirCmd.Init(battle.actorMgr.player.transform.forward, MoveType.Wander, MoveWanderAnimName.Forward, 5);
                battle.actorMgr.player.commander?.TryExecute(_dirCmd);
            }

            if (Input.GetKeyDown(KeyCode.Keypad2))
            {
                LogProxy.Log("战斗 - 发起移动指令Cmd: 朝着原点徘徊, 向后, 5秒");
                var _dirCmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                _dirCmd.Init(battle.actorMgr.player.transform.forward, MoveType.Wander, MoveWanderAnimName.Back, 5);
                battle.actorMgr.player.commander?.TryExecute(_dirCmd);
            }

            if (Input.GetKeyDown(KeyCode.Keypad4))
            {
                LogProxy.Log("战斗 - 发起移动指令Cmd: 朝着原点徘徊, 向左, 5秒");
                var _dirCmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                _dirCmd.Init(battle.actorMgr.player.transform.forward, MoveType.Wander, MoveWanderAnimName.Left, 5);
                battle.actorMgr.player.commander?.TryExecute(_dirCmd);
            }

            if (Input.GetKeyDown(KeyCode.Keypad6))
            {
                LogProxy.Log("战斗 - 发起移动指令Cmd: 朝着原点徘徊, 向右, 5秒");
                var _dirCmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                _dirCmd.Init(battle.actorMgr.player.transform.forward, MoveType.Wander, MoveWanderAnimName.Right, 5);
                battle.actorMgr.player.commander?.TryExecute(_dirCmd);
            }

            if (Input.GetKeyDown(KeyCode.Keypad5))
            {
                LogProxy.Log("战斗 - 发起移动指令Cmd: 取消移动");
                battle.actorMgr.player.commander?.TryExecute(null);
            }

            if (Input.GetKeyDown(KeyCode.Keypad7))
            {
                var angle = Random.Range(TbUtil.battleConsts.SpotTurnMinAngle, 180);
                LogProxy.Log($"战斗 - 发起移动指令Cmd: 原地左转{angle}");
                var destDir = Quaternion.Euler(0, -angle, 0) * battle.actorMgr.player.transform.forward;
                var _dirCmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                _dirCmd.Init(destDir, MoveType.Turn, MoveTurnAnimName.TurnLeft);
                battle.actorMgr.player.commander?.TryExecute(_dirCmd);
            }

            if (Input.GetKeyDown(KeyCode.Keypad9))
            {
                var angle = Random.Range(TbUtil.battleConsts.SpotTurnMinAngle, 180);
                LogProxy.Log($"战斗 - 发起移动指令Cmd: 原地右转{angle}");
                var destDir = Quaternion.Euler(0, angle, 0) * battle.actorMgr.player.transform.forward;
                var _dirCmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                _dirCmd.Init(destDir, MoveType.Turn, MoveTurnAnimName.TurnRight);
                battle.actorMgr.player.commander?.TryExecute(_dirCmd);
            }

            if (Input.GetKeyDown(KeyCode.Keypad0))
            {
                var monster = battle.actorMgr.GetFirstMonster();
                var player = battle.actorMgr.player;
                if (monster != null && player != null)
                {
                    LogProxy.Log($"战斗 - 模拟怪物指令 原地旋转到角色方向");
                    var _moveCmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                    _moveCmd.Init(player.insID, MoveType.Turn);
                    monster.commander?.TryExecute(_moveCmd);
                }
                else
                {
                    LogProxy.Log($"战斗 - 模拟怪物指令失败, 没有找到怪物或player");
                }
            }

            if (Input.GetKeyDown(KeyCode.KeypadPeriod))
            {
                var destPos = new Vector3(Random.Range(-15, 15), 0, Random.Range(-15, 15));
                var radius = 1f;
                var runThreshold = TbUtil.battleConsts.StrategyRunThreshold;
                var firstMonsterID = battle.actorMgr.GetFirstMonster() != null ? battle.actorMgr.GetFirstMonster().insID : 0;
                LogProxy.Log($"战斗 - 发起移动Cmd,移动到随机点:{destPos} 范围:{radius},走跑阈值:{runThreshold},看向首个怪物:{firstMonsterID},");
                var _posCmd = ObjectPoolUtility.GetActorCmd<ActorMovePosCmd>();
                _posCmd.InitByThreshold(destPos, radius, threshold: runThreshold, lookAtTargetID: firstMonsterID);
                battle.actorMgr.player.commander?.TryExecute(_posCmd);
            }
        }

        void SkillTest()
        {
            //Girl
            if (Input.GetKeyDown(KeyCode.J))
            {
                BattleEnv.LuaBridge.SetAtkBtnState(1);
            }

            if (Input.GetKeyUp(KeyCode.J))
            {
                BattleEnv.LuaBridge.SetAtkBtnState(0);
            }

            if (Input.GetKeyDown(KeyCode.K))
            {
                BattleEnv.LuaBridge.SetActiveBtnState(1);
            }

            if (Input.GetKeyUp(KeyCode.K))
            {
                BattleEnv.LuaBridge.SetActiveBtnState(0);
            }

            if (Input.GetKeyDown(KeyCode.L))
            {
                BattleEnv.LuaBridge.SetCoopBtnState(1);
            }

            if (Input.GetKeyUp(KeyCode.L))
            {
                BattleEnv.LuaBridge.SetCoopBtnState(0);
            }

            if (Input.GetKeyDown(KeyCode.U))
            {
                BattleEnv.LuaBridge.SetPowerBtnState(1);
            }

            if (Input.GetKeyUp(KeyCode.U))
            {
                BattleEnv.LuaBridge.SetPowerBtnState(0);
            }

            if (Input.GetKeyDown(KeyCode.Space))
            {
                LogProxy.Log("技能指令：空格按下  frame = " + battle.frameCount);
                BattleEnv.LuaBridge.SetDodgeBtnState(1);
            }

            if (Input.GetKeyUp(KeyCode.Space))
            {
                BattleEnv.LuaBridge.SetDodgeBtnState(0);
            }

            if (Input.GetKeyDown(KeyCode.I))
            {
                BattleEnv.LuaBridge.SetBoyActiveBtnState(1);
            }

            if (Input.GetKeyUp(KeyCode.I))
            {
                BattleEnv.LuaBridge.SetBoyActiveBtnState(0);
            }

            //Boy
            if (Input.GetKeyDown(KeyCode.R))
            {
                battle.actorMgr.boy.skillOwner.TryCastSkillBySlot(BattleUtil.GetSlotID(SkillSlotType.Attack, 0));
            }
        }

        bool aiActive;
        bool testShoot;
        private bool testWndMode;
        void BattleTest()
        {
            if (Input.GetMouseButtonDown(0) && testShoot)
            {
                ShootBtn(Input.mousePosition.x, Input.mousePosition.y);
            }
            
            if (Input.GetKeyDown(KeyCode.H))
            {
                testWndMode = !testWndMode;
                BattleEnv.LuaBridge.SetBattleWndMode(testWndMode ? BattleWndMode.Fps : BattleWndMode.Normal);
            }

            if (Input.GetKeyDown(KeyCode.F2))
            {
                LogProxy.Log($"战斗 - 调试: 显示隐藏轨迹");
                var trail = battle.actorMgr.player.animator.gameObject.GetComponent<TrailRenderer>();
                if (trail == null)
                {
                    trail = battle.actorMgr.player.animator.gameObject.AddComponent<TrailRenderer>();
                    trail.startWidth = trail.endWidth = 0.2f;
                    trail.material = UnityEditor.AssetDatabase.LoadAssetAtPath<Material>("Assets/Editor/Battle/TrailMaterial.mat");
                }
                else
                {
                    trail.enabled = !trail.enabled;
                }
            }

            if (Input.GetKeyDown(KeyCode.F3))
            {
                testShoot = !testShoot;
                Debug.LogErrorFormat($"战斗 - 调试: 射击玩法测试:{0}", testShoot.ToString());
            }

            if (Input.GetKeyDown(KeyCode.F4))
            {
                aiActive = !aiActive;
                LogProxy.Log($"战斗 - 调试: 开关AI");
                foreach (var actor in battle.actorMgr.actors)
                    actor.aiOwner?.DisableAI(aiActive, AISwitchType.Debug);
            }

            if (Input.GetKeyDown(KeyCode.F5))
            {
                LogProxy.Log($"战斗 - 调试: Player清除CD");
                BattleUtil.ClearFriendSkillsCdForEditor();
            }

            if (Input.GetKeyDown(KeyCode.F6))
            {
                LogProxy.Log($"战斗 - 调试 : 播放材质动画 Default");
                var matAnim = BattleResMgr.Instance.Load<BattleCurveAnimator.CurveAnimAsset>("Default", BattleResType.MatCurveAsset);
                battle.actorMgr.player.model.curveAnimator.Play(matAnim);
            }

            if (Input.GetKeyDown(KeyCode.F7))
            {
                LogProxy.Log($"战斗 - 调试: 模拟震屏 DefaultImpulse");
                battle.cameraImpulse.AddWorldImpulse("DefaultImpulse", new BattleImpulseParameter());
            }

            if (Input.GetKeyDown(KeyCode.F8))
            {
                var obj = GameObject.CreatePrimitive(PrimitiveType.Capsule);
                obj.transform.position = new Vector3(2.25f, 0.0f, -29.019f);
                var cap = obj.AddComponent<CapsuleCollider>();
                cap.center = new Vector3(0.0f, 0.95f, 0.0f);
                cap.radius = 0.51f;
                cap.height = 1.9f;
                obj.layer = 11;

                var rmn = obj.AddComponent<RMNavMeshAgent>();
                rmn.radius = 0.51f;
                rmn.height = 1.9f;
                rmn.m_moveSpeed = 1;
                rmn.acceleration = 90;
                rmn.rotationSpeed = 360;
                rmn.m_rvoSensitivity = 3;
                rmn.m_endReachedDistance = 0.01f;
                rmn.m_funnelSimplification = true;
                if (rmn.m_autoRepath == null)
                    rmn.m_autoRepath = new AutoRepathPolicy();
                rmn.m_autoRepath.mode = AutoRepathPolicy.Mode.Dynamic;
                rmn.m_autoRepath.interval = 0.5f;
                rmn.m_autoRepath.sensitivity = 10f;
                rmn.m_autoRepath.maximumInterval = 2;
                rmn.m_autoRepath.visualizeSensitivity = false;
            }

            if (Input.GetKeyDown(KeyCode.F9))
            {
                var destPos = new Vector3(1.75F, 0, -23.65F);
                LogProxy.Log($"战斗 - 发起移动指令Cmd: 移动到随机点:{destPos}");
                var _posCmd = ObjectPoolUtility.GetActorCmd<ActorMovePosCmd>();
                _posCmd.Init(destPos, 1);
                battle.actorMgr.player.commander?.TryExecute(_posCmd);
            }

            if (Input.GetKeyDown(KeyCode.F11))
            {
                if (Application.targetFrameRate > 15)
                {
                    LogProxy.Log($"战斗 - 调试: 锁10帧");
                    Application.targetFrameRate = 10;
                }
                else
                {
                    LogProxy.Log($"战斗 - 调试: 锁60帧");
                    Application.targetFrameRate = 60;
                }
            }

            if (Input.GetKeyDown(KeyCode.F12))
            {
                LogProxy.Log($"战斗 - 调试: 关闭背景音乐");
                WwiseManager.Instance.StopMusic();
            }

            if (Input.GetKeyDown(KeyCode.KeypadPlus))
            {
                var timeScale = Mathf.Min(battle.timeScale * 1.2f, 5f);
                LogProxy.Log($"战斗 - 调试: TimeScale 增加至{timeScale}");
                battle.SetTimeScale(timeScale); //BattleClient.Instance.SetUnityTimescale(timeScale);
            }

            if (Input.GetKeyDown(KeyCode.KeypadMultiply))
            {
                LogProxy.Log($"战斗 - 调试: TimeScale 恢复为1");
                battle.SetTimeScale(1); //BattleClient.Instance.SetUnityTimescale(1);
            }

            if (Input.GetKeyDown(KeyCode.KeypadMinus))
            {
                var timeScale = Mathf.Max(battle.timeScale * 0.8f, 0f);
                LogProxy.Log($"战斗 - 调试: TimeScale 减少至{timeScale}");
                battle.SetTimeScale(timeScale); //BattleClient.Instance.SetUnityTimescale(timeScale);
            }

            if (Input.GetKeyDown(KeyCode.T))
            {
                battle.actorMgr.boy.Recycle();
            }

            if (Input.GetKeyDown(KeyCode.C))
            {
                battle.cameraTrace.UseBoyCameraAdjust(battle.actorMgr.GetFirstMonster());
            }

            if (Input.GetKey(KeyCode.Q))
            {
                battle.cameraTrace.Rotate(-battle.cameraTrace.DragScale * battle.deltaTime, 0, true);
            }

            if (Input.GetKey(KeyCode.E))
            {
                battle.cameraTrace.Rotate(battle.cameraTrace.DragScale * battle.deltaTime, 0, true);
            }
        }
#endif

        /// <summary>
        /// 按钮按下或者抬起时调用一下（不需要重复调用，按下调用一次就可以）
        /// </summary>
        /// <param name="type">按钮类型</param>
        /// <param name="isDown">按下传true，抬起传false</param>
        public void PlayerBtnStateChange(PlayerBtnType type, bool isDown, int casterId)
        {
            using (ProfilerDefine.InputPlayerBtnStateChangePMarker.Auto())
            {
                LogProxy.LogFormat("记录技能按钮：{0} {1} {2}", type, isDown ? "Down" : "up", Battle.Instance.frameCount);
                var _cmd = ObjectPoolUtility.GetActorCmd<ActorBtnStateCommand>();
                _cmd.Init(type, isDown);
                var caster = battle.actorMgr?.GetActor(casterId);
                caster?.commander?.TryExecute(_cmd);
            }
        }

        /// <summary>
        /// 通过BtnType释放技能
        /// </summary>
        /// <param name="btnType">按钮type</param>
        /// <param name="casterID"> 默认为nil，让主控者释放技能</param>
        /// <param name="isUI">UI调用过来需要设为true</param>
        public void TryCastSkill(PlayerBtnType btnType, int casterID, bool isUI = false)
        {
            _cashCastSkillCmd.Add(new SCastSkill(btnType, casterID, isUI));
        }

        private void _TryCastSkill(PlayerBtnType btnType, int casterID, bool isUI = false)
        {
            using (ProfilerDefine.InputPlayerBtnStateChangePMarker.Auto())
            {
                LogProxy.LogFormat("按钮点击释放技能： {0}", btnType);
                if (BattleEnv.NoCdForPlayerSkills)
                {
                    Battle.Instance.ClearSkillsCd(battle.player.insID);
                }

                var slotID = GetSlotIDByBtn(btnType);
                var cmd = ObjectPoolUtility.GetActorCmd<ActorSkillCommand>();
                cmd?.Init(slotID, BattleConst.InvalidActorID, casterID, isUI, btnType, _currDir);
                _commander.TryExecute(cmd);
            }
        }

        // TODO: PlayerBtnType是SkillSlotType的子集
        public int GetSlotIDByBtn(PlayerBtnType btnType)
        {
            SkillSlotType type = (SkillSlotType)btnType;
            var slotId = BattleUtil.GetSlotID(type, 0);
            return slotId;
        }

        /// <summary>
        /// 获取静态的btnType-> slot映射，静态就是初始绑定的
        /// </summary>
        /// <param name="btnType">按钮类型</param>
        /// <param name="casterID">actor，不填为主控</param>
        /// <returns></returns>
        public SkillSlot GetStaticSkillSlot(PlayerBtnType btnType, int casterID = BattleConst.InvalidActorID)
        {
            var slotID = GetSlotIDByBtn(btnType);
            var actor = battle.player;
            if (actor == null)
            {
                return null;
            }

            if (casterID != BattleConst.InvalidActorID)
            {
                actor = battle.actorMgr.GetActor(casterID);
                if (actor == null)
                {
                    return null;
                }
            }

            var slot = actor.skillOwner.GetSkillSlot(slotID);
            return slot;
        }

        public void ShootBtn(float x, float y)
        {
            if (battle == null || battle.cameraTrace == null || Camera.main == null)
            {
                LogProxy.Log("[PlayerInput] Shoot no battle or camera");
                return;
            }

            //射击:射线寻找最近的HitInfo
            var sight = new Vector3(x, y, 0);
            Ray ray = Camera.main.ScreenPointToRay(sight);
            Debug.DrawRay(ray.origin, ray.direction * 999, Color.red, 1f);
            var resultCount = X3Physics.RayCast(ray.origin, ray.direction, out var results, -1);
            var minDistance = float.MaxValue;
            var minIndex = -1;
            for (int i = 0; i < resultCount; i++)
            {
                var hitInfo = results[i] as CollisionDetectionHitInfo;
                if (hitInfo == null) continue;

                if (hitInfo.hitInfo.distance < minDistance)
                {
                    minDistance = hitInfo.hitInfo.distance;
                    minIndex = i;
                }
            }
            if (minIndex != -1)
            {
                var hitInfo = (results[minIndex] as CollisionDetectionHitInfo).hitInfo;
                LogProxy.Log($"[PlayerInput] ShootCount:{resultCount} Index:{minIndex} Name:{results[minIndex].hitActor.name} hurtBox:{TbUtil.battleConsts.ShootDamageBoxID}");
                var damgageBoxCfg = TbUtil.GetCfg<DamageBoxCfg>(TbUtil.battleConsts.ShootDamageBoxID);
                Vector3 dir = (Vector3)hitInfo.point - (battle.actorMgr.player.transform.position + damgageBoxCfg.ShapeBoxInfo.OffsetPos);
                battle.actorMgr.player.transform.SetForward(dir);
                Quaternion rotation = Quaternion.LookRotation(dir);
                Vector3 eulerAngle = new Vector3(rotation.eulerAngles.x, 0, 0) + damgageBoxCfg.ShapeBoxInfo.OffsetEuler;
                battle.actorMgr.player.buffOwner.AddDamageBuff(battle.actorMgr.player, TbUtil.battleConsts.ShootDamageBoxID, 0.1f, eulerAngle);
            }
            else
            {
                LogProxy.Log($"[PlayerInput] ShootCount:{resultCount} but not mob");
            }
        }

        /// <summary>
        /// 结束战斗
        /// </summary>
        /// <param name="isWin"></param>
        public void EndBattle(bool isWin = false)
        {
            if (battle.isEnd)
            {
                return;
            }

            using (ProfilerDefine.InputEndBattlePMarker.Auto())
            {
                if (_commander == null)
                {
                    battle.End(isWin);
                    return;
                }
            	//结束战斗指令不允许被清除，为避免被误清，需先清空指令列表
            	_commander.ClearCmd();
                _commander.TryExecute(new ActorEndBattleCommand(isWin));
            }
        }

        /// <summary>
        /// 对同帧输入指令进行排序
        /// </summary>
        private void _SortSkillCmd()
        {
            _cashSortSkillCmd.Clear();
            foreach (var sort in _btnSort)
            {
                foreach (var _sCastSkill in _cashCastSkillCmd)
                {
                    if (_sCastSkill.btnType == sort)
                    {
                        _cashSortSkillCmd.Add(_sCastSkill);
                    }
                }
            }
        }
    }
}