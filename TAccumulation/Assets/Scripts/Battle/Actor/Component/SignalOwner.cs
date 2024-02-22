using System.Collections.Generic;

namespace X3Battle
{
    public class SignalOwner : ActorComponent
    {
        private Dictionary<string, string> _signalDic;

        public SignalOwner() : base(ActorComponentType.Signal)
        {
            _signalDic = new Dictionary<string, string>(30);
        }

        public string Read(string signalKey)
        {
            string result = null;
            this._signalDic.TryGetValue(signalKey, out result);
            return result;
        }

        public void Write(string signalKey, string signalValue, Actor writer)
        {
            if (!_signalDic.ContainsKey(signalKey))
            {
                _signalDic.Add(signalKey, signalValue);
            }

            _signalDic[signalKey] = signalValue;

            // DONE: 发事件
            var eventData = actor.eventMgr.GetEvent<EventReceiveSignal>();
            eventData.Init(this.actor, writer, signalKey, signalValue);
            actor.eventMgr.Dispatch(EventType.OnReceiveSignal, eventData);
        }

        public bool Remove(string signalKey)
        {
            if (!_signalDic.ContainsKey(signalKey))
            {
                return false;
            }

            _signalDic.Remove(signalKey);
            return true;
        }

        public bool HasSignal(string signalKey)
        {
            return _signalDic.ContainsKey(signalKey);
        }
    }
}