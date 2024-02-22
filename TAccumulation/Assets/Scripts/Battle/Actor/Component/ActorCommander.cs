using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class ActorCommander : ActorComponent
    {
        /// <summary>
        /// 前台指令执行中
        /// </summary>
        private bool _executing;

        /// <summary>
        /// 后台运行指令列表
        /// </summary>
        private LinkedList<ActorCmd> _bgCmds = new LinkedList<ActorCmd>();

        /// <summary>·
        /// 等待执行指令列表
        /// </summary>
        private LinkedList<ActorCmd> _pendingCmds = new LinkedList<ActorCmd>();

        /// <summary>
        /// 指令结束回调
        /// </summary>
        private Action<ActorCmd> _actionOnCmdFinished;
        
        public ActorCmd currentCmd { get; private set; }

        public ActorCommander() : base(ActorComponentType.Commander)
        {
            _actionOnCmdFinished = _OnCmdFinished;
        }

        protected override void OnUpdate()
        {
            var node = _bgCmds.First;
            while (null != node)
            {
                node.Value.Update();
                node = node.Next;
            }

            currentCmd?.Update();
        }

        public bool TryExecute(ActorCmd cmd)
        {
            cmd?.SetActor(actor);
            // 执行前进行验证！
            if (null != cmd && !cmd.CanExecuted())
            {
                _RecycleCmd(cmd);
                return false;
            }

            using (ProfilerDefine.ActorCommanderTryExecutePMarker.Auto())
            {
                if (cmd != null && cmd.isBgCmd)
                {
                    _ExeBgCmd(cmd);
                }
                else
                {
                    _ExeCmd(cmd);
                }
            }

            return true;
        }

        public void ClearCmd()
        {
            TryExecute(null);
        }

        public void ClearMoveCmd()
        {
            if (currentCmd == null)
            {
                return;
            }

            if (!(currentCmd is ActorMovePosCmd || currentCmd is ActorMoveDirCmd))
            {
                return;
            }

            ClearCmd();
        }

        private void _ExeBgCmd(ActorCmd cmd)
        {
            if (_bgCmds.Contains(cmd))
            {
                LogProxy.LogError($"ActorCommander._ExeBgCmd() errorMsg:该指令{typeof(ActorCmd)}在已在运行队列中,不允许重复进入，请检查！");
                return;
            }

            _bgCmds.AddLast(_GetLinkedNode(cmd));
            cmd?.Start(_actionOnCmdFinished);
        }

        private void _ExeCmd(ActorCmd cmd)
        {
            _pendingCmds.AddLast(_GetLinkedNode(cmd));
            // 有指令正在执行中
            if (_pendingCmds.Count > 1)
            {
                return;
            }

            // 结束当前指令
            currentCmd?.Finish(_pendingCmds.First.Value);

            // 获取新的指令
            var last = _pendingCmds.Last;
            currentCmd = last.Value;
            _pendingCmds.RemoveLast();
            _RecycleLinkedNode(last);

            // 回收废弃指令
            var node = _pendingCmds.First;
            while (null != node)
            {
                var next = node.Next;
                _RecycleCmd(node);
                node = next;
            }

            _pendingCmds.Clear();

            // 执行当前指令
            currentCmd?.Start(_actionOnCmdFinished);
        }

        private void _RecycleCmd(ActorCmd cmd)
        {
            if (null == cmd || cmd.state == ActorCmdState.Initial)
            {
                return;
            }

            //回池
            ObjectPoolUtility.ReleaseActorCmd(cmd);
        }

        private void _RecycleCmd(LinkedListNode<ActorCmd> node)
        {
            _RecycleCmd(node?.Value);
            _RecycleLinkedNode(node);
        }

        private void _OnCmdFinished(ActorCmd cmd)
        {
            if (cmd == currentCmd)
            {
                currentCmd = null;
            }
            else
            {
                var node = _bgCmds.Find(cmd);
                if (null == node) return;
                _bgCmds.Remove(node);
                _RecycleLinkedNode(node);
            }

            _RecycleCmd(cmd);
        }

        private LinkedListNode<ActorCmd> _GetLinkedNode(ActorCmd cmd)
        {
            var node = ObjectPoolUtility.ActorCmdLinkNodePool.Get();
            node.Value = cmd;
            return node;
        }

        private void _RecycleLinkedNode(LinkedListNode<ActorCmd> node)
        {
            if (null == node) return;
            node.Value = null;
            ObjectPoolUtility.ActorCmdLinkNodePool.Release(node);
        }
    }
}