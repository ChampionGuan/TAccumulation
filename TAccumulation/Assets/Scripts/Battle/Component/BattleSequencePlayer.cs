using System;
using System.Collections;
using System.Collections.Generic;
using PapeGames.Rendering;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class BattleSequencePlayer : BattleComponent
    {
        private BSMgr _bsMgr;
        private bool _isPlayingPerform = false;
        private Action _stopCall;
        private bool _isPreLoading;
        public bool isPreLoading => _isPreLoading;
        public bool isPlayingPerform => _isPlayingPerform;

        private BSActionContext _battleBattleActionContext;  // 战斗的context
        private Dictionary<int, BattleSequencer> _performs;  // 表演缓存
        private Dictionary<string, BattleSequencer> _sceneEffects;  // 场景特效缓存
        
        // 分帧逻辑Operation
        private  Queue<Action> _operations = new Queue<Action>();

        public BattleSequencePlayer() : base(BattleComponentType.SequencePlayer)
        {
            _bsMgr = new BSMgr();
            _performs = new Dictionary<int, BattleSequencer>();
            _sceneEffects = new Dictionary<string, BattleSequencer>();
            _battleBattleActionContext = new BSActionContext(battle);
        }
        
        public void PreloadBattleSequences()
        {
            _isPreLoading = true;
            // 判空
            var performIDs = BattleEnv.GetPerformIDs();
            if (performIDs == null || performIDs.Count == 0)
            {
                LogProxy.LogError("预加载数据没有performID信息，不会创建表演！如果是自定义模式请忽略这条报错！");
                return;
            }
            
            // 提前创建
            try
            {
                foreach (var performID in performIDs)
                {
                    LogProxy.LogFormat("尝试预加载表演ID={0}", performID);
                    var performCfg = TbUtil.GetCfg<PerformConfig>(performID);
                    if (performCfg != null)
                    {
                        LogProxy.LogFormat("开始创建表演ID={0}", performID);
                        // 预加载表演
                        var resPath = performCfg.RelativePath;
                        if (!string.IsNullOrEmpty(resPath))
                        {
                            var createData = new BSCreateData()
                            {
                                artResPath = resPath,
                                performCfg = performCfg,
                                bsActionContext = _battleBattleActionContext,
                            };
                            var timeline = _bsMgr.CreateBS(BSType.BattlePerform, createData);
                            // timeline.StopPlay();
                            _performs.Add(performID, timeline);
                        }
                    
                        // 预加载场景特效
                        var effectPath = performCfg.EndEffectPath;
                        if (!string.IsNullOrEmpty(effectPath))
                        {
                            var createData = new BSCreateData()
                            {
                                artResPath = effectPath,
                                bsActionContext = _battleBattleActionContext,
                            };
                            var timeline = _bsMgr.CreateBS(BSType.BattleSceneEffect, createData);
                            // timeline.StopPlay();
                            _sceneEffects.Add(effectPath, timeline);
                        }
                    }
                }
                
                // 把表演都播起来
                BattleClient.Instance.StartCoroutine(_PreplayPerform());
            }
            catch (Exception e)
            {
                LogProxy.LogError(e);
            }
        }

        private IEnumerator _PreplayPerform()
        {
            // 空出一帧后，再播放
            yield return null;
            // 非预加载阶段，return
            if(battle.isPreloading) yield break;
            foreach (var iter in _performs)
            {
                PlayPerform(iter.Key, isPreload:true);
            }
        }
            
        public void PreloadFinished()
        {
            // 停止perform预表演
            foreach (var iter in _performs)
            {
                var timeline = iter.Value;
                timeline.onStopCall = null;
                timeline.Stop();
                _PerformEndStep1(false, false);
                var performCom = timeline.GetComponent<BSCPerform>();
                performCom?.StopStep1();
                performCom?.StopStep2();
                _PerformEndStep2();
            }

            // 停止sceneEffect特效
            foreach (var iter in _sceneEffects)
            {
                var timeline = iter.Value;
                if (timeline.bsState == BSState.Playing)
                {
                    timeline.Stop();    
                }
            }
            
            _isPreLoading = false;
        }

        protected override void OnStart()
        {
            BattleClient.Instance.onPreUpdate.AddListener(_OnUpdate);
            BattleClient.Instance.onPrePhysicalJobRunning.AddListener(_OnLateUpdate);
        }
        
        /// <summary>
        /// 战斗直接放在场景中的特效timeline，不绑定任何人物，不触发任何事件
        /// </summary>
        /// <param name="relativePath"></param>
        public void PlaySceneEffect(string relativePath)
        {
            using (ProfilerDefine.BattleTimelinePlayerPlaySceneEffect.Auto())
            {
                _sceneEffects.TryGetValue(relativePath, out var timeline);
                if (timeline != null)
                {
                    timeline.Play();

                    // 策划的特殊需求：场景特效timeline需要基于女主位置
                    var timelineObj = timeline.GetComponent<BSCRes>()?.artObject;
                    var actor = battle.actorMgr.player;
                    var pos = actor?.transform.position;
                    if (timelineObj != null && pos != null)
                    {
                        timelineObj.transform.position = pos.Value;
                    }
                }
            }
        }

        /// <summary>
        /// 播放战斗表演
        /// </summary>
        /// <param name="performID">表演ID</param>
        public void PlayPerform(int performID, float speed = 1.0f, bool isPreload = false, bool isProtectPerform = false)
        {
            // battle过程中不能同时播两个，效果会坏掉，preload阶段可以
            if (_isPlayingPerform && !isPreload)
            {
                PapeGames.X3.LogProxy.LogWarningFormat("BattleTimelineMgr:PlayBattlePerform, 同一时刻只能播放一个表演。本次id={0} ，播放失败！", performID);
                return;
            }

            using (ProfilerDefine.BattleTimelinePlayerPlayPerformFrame1.Auto())
            {
                _performs.TryGetValue(performID, out var timeline);
                if (timeline != null)
                {
                    var isEvalActor = !isPreload && !isProtectPerform;  // 是否处理场景的actor (preload或者援护技表演不处理)
                    var isEvalUI = !isPreload;  // 是否处理UI显隐
                    var isEvalFloatUI = !isPreload && isProtectPerform;  // 非preload的援护表演需要处理飘字
                    var isFadeInOut = !isPreload && isProtectPerform;  // 非preload的援护表演需要处理UI过渡
                                                                       // 开始第1帧：暂停战斗，显示表演用男女主
                    _PerformStartStep1(isFadeInOut, () =>
                    {
                        var performCom = timeline.GetComponent<BSCPerform>();
                        performCom?.StartStep1(isEvalActor);
                        _operations.Enqueue(null);  // 当前帧后执行Update需要延一下
                        _operations.Enqueue(() =>
                        {
                            if (isFadeInOut)
                            {
                                var boy = Battle.Instance.actorMgr.boy;
                                boy?.model.BrokenShirt();
                                boy?.eventMgr.Dispatch(EventType.StartDelayAnim, null, syncToWorld: false);
                                battle.ui.CloseScreenFabe();
                            }
                            using (ProfilerDefine.BattleTimelinePlayerPlayPerformFrame2.Auto())
                            {
                                // 开始第2帧：隐藏UI，隐藏战斗场景，处理Battle男女主、处理爆发技男女主
                                _PerformStartStep2(isEvalUI, isEvalFloatUI);
                                performCom?.StartStep2();
                                _operations.Enqueue(() =>
                                {
                                    performCom?.StartStep3(isEvalActor);
                                });
                                timeline.SetTimeScale(speed);
                                timeline.Play(finishHold: isFadeInOut);
                                timeline.onStopCall = () =>
                                {
                                    if (isFadeInOut)
                                    {
                                        timeline.Stop();
                                        battle.ui.ScreenFabe(null, false);
                                    }
                                    using (ProfilerDefine.BattleTimelinePlayerStopPerformFrame1.Auto())
                                    {
                                        // 结束第一帧：timeline播放结束，回收自己逻辑
                                        _PerformEndStep1(isEvalUI, isEvalFloatUI);
                                        performCom?.StopStep1();
                                        performCom?.StopStep2();
                                        _operations.Enqueue(null);
                                        _operations.Enqueue(() =>
                                        {
                                            using (ProfilerDefine.BattleTimelinePlayerStopPerformFrame2.Auto())
                                            {
                                                // 结束第二帧：恢复场上actor，恢复战斗
                                                _PerformEndStep2();
                                            }
                                        });
                                    }
                                };
                            }
                        });
                    });
                }
                else
                {
                    LogProxy.LogErrorFormat("播放表演失败，预加载时没有提前创建，performID：{0}", performID);
                }
            }
        }

        // 阶段一：停止战斗逻辑
        private void _PerformStartStep1(bool isFaceInOut, Action onEnd)
        {
            using (ProfilerDefine.PerformStartStep1.Auto())
            {
                // 停止相机震屏
                Battle.Instance.cameraImpulse.ClearCameraShake();
                // 暂停战场逻辑
                using (ProfilerDefine.PerformStopBattle.Auto())
                {
                    battle.SetWorldEnable(false, BattleEnabledMask.Perform, EAudioPauseType.EBattleSfx, isForce: true);
                    // 战斗沟通在爆发技的时候不暂停
                    battle.dialogue.SetIgnoreBattlePaused(true);
                    _isPlayingPerform = true;
                    battle.actorMgr.EnableActorsMove(false);
                }
            }
            if (isFaceInOut)
            {
                // 有白屏过渡
                battle.ui.ScreenFabe(onEnd, true);
            }
            else
            {
                // 没有白屏过渡
                onEnd();
            }
        }

        // 阶段二：隐藏UI和场景
        private void _PerformStartStep2(bool evalUI, bool evalFloatUI)
        {
            using (ProfilerDefine.PerformStartStep2.Auto())
            {
                // loading阶段Preload时，不处理UI。正常播需要处理UI
                if (evalUI)
                {
                    using (ProfilerDefine.PerformHideUI.Auto())
                    {
                        BattleUtil.SetUIActive(false, false);
                    }
                    if (evalFloatUI)
                    {
                        Battle.Instance.floatWordMgr.Pause(true);
                    }
                }

                // 隐藏场景
                using (ProfilerDefine.PerformHideScene.Auto())
                {
                    battle.misc.SetSceneActive(false);
                }

                // 关闭策划ppv
                using (ProfilerDefine.PerformPPVDisable.Auto())
                {
                    battle.ppvMgr.SetEnable(false);
                }

                // 关闭角色战场灯
                using (ProfilerDefine.PerformClosePlayerSceneLight.Auto())
                {
                    battle.actorMgr.player.model.SwitchSceneLight(false);
                }

            }
        }

        // Step1：开启UI，打开场景
        private void _PerformEndStep1(bool isEvalUI, bool evalFloatUI)
        {
            // loading阶段Preload时，不处理UI。正常播需要处理UI
            if (isEvalUI)
            {
                using (ProfilerDefine.PerformStartUI.Auto())
                {
                    BattleUtil.SetUIActive(true, false);
                }
                if (evalFloatUI)
                {
                    Battle.Instance.floatWordMgr.Pause(false);
                }
            }
            // 打开场景
            using (ProfilerDefine.PerformShowScene.Auto())
            {
                battle.misc.SetSceneActive(true);
            }
            // 打开策划ppv
            using (ProfilerDefine.PerformPPVEnable.Auto())
            {
                battle.ppvMgr.SetEnable(true);
            }
            // 打开角色战场灯
            using (ProfilerDefine.PerformSwitchActorSceneLight.Auto())
            {
                battle.actorMgr.player.model.SwitchSceneLight(true);
            }
        }

        // Step2：启动战斗逻辑
        private void _PerformEndStep2()
        {
            using (ProfilerDefine.PerformEnd.Auto())
            {
                // 开启逻辑
                using (ProfilerDefine.PerformStartBattle.Auto())
                {
                    battle.SetWorldEnable(true, BattleEnabledMask.Perform, isForce: true);
                    battle.dialogue.SetIgnoreBattlePaused(false);
                    _isPlayingPerform = false;
                    _stopCall?.Invoke();
                    _stopCall = null;
                    battle.actorMgr.EnableActorsMove(true);
                }
            }
        }

        private void _OnUpdate()
        {
            var deltaTime = Time.deltaTime;
            _bsMgr.Update(deltaTime);
            if (Battle.Instance.isPreloading)
            {
                // preload阶段不分帧
                var count = _operations.Count;
                for (int i = 0; i < count; i++)
                {
                    var func = _operations.Dequeue();
                    func?.Invoke();   
                }
            }
            else
            {
                // 非preload阶段分帧
                if (_operations.Count > 0)
                {
                    var func = _operations.Dequeue();
                    func?.Invoke();
                }
            }
        }

        private void _OnLateUpdate()
        {
            _bsMgr.LateUpdate();
        }

        protected override void OnDestroy()
        {
            BattleClient.Instance.onPreUpdate.RemoveListener(_OnUpdate);
            BattleClient.Instance.onPrePhysicalJobRunning.RemoveListener(_OnLateUpdate);
            
            if (_bsMgr != null)
            {
                _bsMgr.Destroy();
                _bsMgr = null;
            }

            if (_operations != null)
            {
                _operations.Clear();
                _operations = null;
            }
            
            base.OnDestroy();
        }
    }
}