#define CLEAR_WAIT_AFT_HOLDONTIME //超过占位时长后，清除行为队列(早期设定不清行为队列,只清当前行为)

using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class AIActionQueue
    {
        private bool _actionClearing;
        private bool _actionGenerating;
        private int _genAndExeActionFrame = -1;

        protected IAIActionGoal _currAction;
        protected List<IAIActionGoal> _waitActions = new List<IAIActionGoal>();
        private List<IAIActionGoal> _tempActions = new List<IAIActionGoal>();
        
        /// <summary>
        /// 是否处于禁用状态
        /// </summary>
        public virtual bool disabled{ get; set; }

        /// <summary>
        /// 是否处于暂停状态
        /// </summary>
        public virtual bool paused{ get;  set; }

        public Actor actor => context?.actor;

        /// <summary>
        /// 上下文环境
        /// </summary>
        public IAIGoalContext context { get; protected set; }

        /// <summary>
        /// 是否有正在执行的行为
        /// </summary>
        public bool hasExecutingAction => null != _currAction;

        /// <summary>
        /// 是否有等待的行为
        /// </summary>
        public bool hasWaitAction => _waitActions.Count > 0;

        public AIActionQueue(IAIGoalContext context)
        {
            this.context = context;
        }

        /// <summary>
        /// 每帧轮巡驱动
        /// </summary>
        /// <param name="deltaTime"></param>
        public void Update(float deltaTime)
        {
            // 驱动行为
            using (ProfilerDefine.AITickActionPMarker.Auto())
            {
                _TickAction(deltaTime);
            }
            
            // 每帧轮巡，如果成功则执行行为
            using (ProfilerDefine.AIGenerateAndExecuteActionPMarker.Auto())
            {
                _GenerateAndExecuteAction(deltaTime);
            }
        }

        /// <summary>
        /// 添加行为
        /// </summary>
        /// <param name="action"></param>
        /// <param name="firstCheck">第一个行为是否做检查</param>
        public bool AddAction(IAIActionGoal action, bool firstCheck = true)
        {
            if (null == action)
            {
                return false;
            }

            _tempActions.Clear();
            // 是否为复合行为
            if (action is IAICompositeAction compositeAction)
            {
                action.Init(this);
                compositeAction.GenSubActions(_tempActions);
                action.Reset();
            }
            else
            {
                _tempActions.Add(action);
            }

            var result = true;
            foreach (var subAction in _tempActions)
            {
                //第一个行为执行前条件检查失败了
                if (!result)
                {
                    subAction.Reset();
                    continue;
                }
                // 初始化行为
                subAction.Init(this);
                // 第一个行为加入队列前，检测执行前条件，并将结果返回
                if (firstCheck && !hasWaitAction && !subAction.VerifyingConditions(AIConditionPhaseType.PreRun, out var breakType))
                {
                    subAction.Reset();
                    result = false;
                    continue;
                }

                _waitActions.Add(subAction);
            }

            return result;
        }

        /// <summary>
        /// 清除行为队列
        /// <param name="includeCurr">是否也需要清除正在执行的行为，默认清理</param>
        /// </summary>
        public void ClearAllActions(bool includeCurr = true)
        {
            _ClearWaitActions();
            _actionClearing = true;
            if (includeCurr) _currAction?.SetFinish(false);
            _actionClearing = false;
        }

        /// <summary>
        /// 当行为结束
        /// </summary>
        public void OnActionFinished(IAIActionGoal action, bool clearWaitActions)
        {
            // 从队列中移除
            if (!_RemoveAction(action))
            {
                LogProxy.LogError($"同一个行为【{action.GetType()}】对于AI.OnActionFinished()多次调用，请检查！");
                return;
            }

            // 在清除行为过程中，则返回
            if (_actionClearing)
            {
                return;
            }

            // 如果当前有正在执行的行为，则返回
            if (hasExecutingAction)
            {
                return;
            }

            if (clearWaitActions)
            {
                _ClearWaitActions();
                _GenerateAndExecuteAction();
            }
            else if (!hasWaitAction)
            {
                _GenerateAndExecuteAction();
            }
            else
            {
                // 执行队头行为
                _ExecuteAction();
            }
        }

        /// <summary>
        /// 产生行为队列
        /// <param name="deltaTime">驱动deltaTime</param>
        /// </summary>
        private bool _GenerateActions(float deltaTime = 0)
        {
            // tick过程中不允许再次触发！
            if (_actionGenerating)
            {
                return false;
            }

            // note:此处不要轻易更改，如果更改将会影响到之前已配置完成的AI树！！
            if (hasExecutingAction //当前有行为 
                || hasWaitAction) // 行为队列不为空
            {
                return false;
            }

            if (!_CanGenerateActions())
            {
                return false;
            }

            _actionGenerating = true;
            try
            {
                context.GenerateActions(deltaTime);
            }
            catch (Exception e)
            {
                LogProxy.LogError($"AI.GenerateActions()执行异常，请检查！！ ErrorMsg:{e}");
            }
            _actionGenerating = false;
            
            return hasWaitAction;
        }

        /// <summary>
        /// 产生行为队列并执行
        /// </summary>
        private void _GenerateAndExecuteAction(float deltaTime = 0)
        {
            //同一帧内只允许跑进来一次，避免空跑造成死循环！
            var frameCount = Time.frameCount;
            if (_genAndExeActionFrame == frameCount) return;
            _genAndExeActionFrame = frameCount;
            if (_GenerateActions(deltaTime)) _ExecuteAction();
        }

        /// <summary>
        /// 清除正在等待的行为
        /// </summary>
        private void _ClearWaitActions()
        {
            for (var index = _waitActions.Count - 1; index >= 0; index--) _waitActions[index].Reset();
            _waitActions.Clear();
        }

        /// <summary>
        /// 驱动行为
        /// </summary>
        private void _TickAction(float deltaTime)
        {
            // 当前行为每帧Tick
            _currAction?.Tick(deltaTime);

            // 是否有等待行为
            if (!hasWaitAction) return;

            // 队头行为
            var action = _waitActions[0];
#if CLEAR_WAIT_AFT_HOLDONTIME
            // 检测队头行为占位时长，超时长则清空行为队列
            if (action.VerifyingOverTime(deltaTime))
            {
                _ClearWaitActions();
                return;
            }
            // 检测队头等待条件，不满足则返回
            if (!action.VerifyingConditions(AIConditionPhaseType.Pending, out var _))
            {
                return;
            }

            // 队头行为满足执行条件，如果当前有行为则立马结束(正常结束)
            if (hasExecutingAction)
            {
                _currAction?.SetFinish();
            }
            else
            {
                using (ProfilerDefine.AIExecuteActionPMarker.Auto())
                {
                    _ExecuteAction();
                }
            }
#else
            // 检测队头行为占位时长
            if (action.VerifyingHoldTime(deltaTime))
            {
                // 占位时长已达到，则清除该行为
                _waitActions.Remove(action);
                action.SetFinish(false);
            }

            //无后续行为则返回
            if (!hasWaitAction) return;

            action = _waitActions[0];
            // 检测队头等待条件，不满足则返回
            if (!action.VerifyingConditions(AIConditionPhaseType.Pending, out var _)) return;

            // 如果当前有行为则结束，无则直接执行队头行为
            if (hasExecutingAction)
            {
                _currAction.SetFinish(false);
                return;
            }

            // 执行队头行为，不再做安全检查，因为上面已经检查通过！
            _ExecuteAction(false);
#endif
        }

        /// <summary>
        /// 移除行为
        /// </summary>
        /// <param name="action"></param>
        private bool _RemoveAction(IAIActionGoal action)
        {
            if (null == action)
            {
                return false;
            }

            if (_currAction == action)
            {
                // 转为局部变量，因为Action.SetFinished()的过程中，_currAction可能会是一个新的行为
                var temp = _currAction;
                _currAction = null;
                if (temp.isRunning)
                {
                    temp.SetFinish(false);
                }
                return true;
            }
            if (_waitActions.Contains(action))
            {
                _waitActions.Remove(action);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 执行行为
        /// </summary>
        private void _ExecuteAction()
        {
            if (hasExecutingAction || !hasWaitAction)
            {
                return;
            }

            var action = _waitActions[0];
            // 如果需要安全检查，需要在执行前检测等待条件是否满足！
            if (!action.VerifyingConditions(AIConditionPhaseType.Pending, out var _))
            {
                return;
            }

            _currAction = action;
            _waitActions.RemoveAt(0);
            _currAction.Tick(0);
        }

        /// <summary>
        /// 是否可产生行为队列
        /// </summary>
        /// <returns></returns>
        protected virtual bool _CanGenerateActions()
        {
            return true;
        }
    }
}