using System.Diagnostics;
using PapeGames.X3;
using FlowCanvas;
using NodeCanvas.Framework;

namespace X3Battle
{
    public abstract class BattleFlowNode : FlowNode
    {
        protected GraphOwner _graphOwner { get; private set; }
        protected GraphContext _context { get; private set; }

        protected Battle _battle => (_context is IBattleContext battleContext) ? battleContext.battle : null;

        /// <summary> 节点的拥有者 </summary>
        protected Actor _actor => (_context is IActorContext actorContext) ? actorContext.actor : null;

        protected object _source => (_context is IGraphCreater triggerSource) ? triggerSource.creater : null;

        protected int _level => (_context is IGraphLevel triggerLevel) ? triggerLevel.level : 1;

        protected NotionGraphEventMgr _eventMgr => _context?.eventMgr;

        public float graphElapsedTime => this.graph.elapsedTime;

        protected sealed override void RegisterPorts()
        {
            this._OnRegisterPorts();
        }

        public sealed override void OnPostGraphStarted()
        {
            this._OnPostGraphStarted();
        }

        public sealed override void OnGraphStart()
        {
            base.OnGraphStart();
            this._graphOwner = this.graphAgent as GraphOwner;
            _context = this._GetVariable<GraphContext>(BattleConst.ContextVariableName).GetValue();
            _OnGraphStart();
        }

        public sealed override void OnGraphStop()
        {
            _OnGraphStop();
        }

        public sealed override void OnPostGraphStoped()
        {
            this._OnPostGraphStoped();
        }

        protected virtual void _OnRegisterPorts()
        {
        }

        protected virtual void _OnPostGraphStarted()
        {
        }

        protected virtual void _OnGraphStart()
        {
        }

        protected virtual void _OnGraphStop()
        {
            
        }

        protected virtual void _OnPostGraphStoped()
        {
        }

        protected Variable<T> _GetVariable<T>(string varName)
        {
            return this._graphOwner.blackboard?.GetVariable<T>(varName);
        }

        protected void _SetVariableValue<T>(string varName, T _value)
        {
            if (this._graphOwner.blackboard == null)
                return;
            this._graphOwner.blackboard.SetVariableValue<T>(varName, _value);
        }
        
        [Conditional(LogProxy.DEBUG_LOG)]
        protected virtual void _LogError(string error)
        {
            LogProxy.LogError($"错误图【{this._graphOwner.name}】, {error}");
        }
    }
}
