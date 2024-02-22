using System;
using System.Collections.Generic;

namespace X3Battle
{
    public interface IFrameUpdate
    {
        bool requiredFrameUpdate { get;}
        bool canFrameUpdate { set; }
    }

    public class FrameUpdateMgr : BattleComponent
    {
        private Dictionary<Type, ObjFrame> _objFrames;
        private List<FrameData> _updatedDatas;
        
        public FrameUpdateMgr() : base(BattleComponentType.FrameUpdate)
        {
            _objFrames = new Dictionary<Type, ObjFrame>(2);
            _updatedDatas = new List<FrameData>(10);
        }
		
        protected override void OnUpdate()
        {
            foreach (FrameData frameData in _updatedDatas)
            {
                frameData.SetCanFrameUpdate(false);
            }
            _updatedDatas.Clear();
            
            foreach (var objFrameItem in _objFrames)
            {
                ObjFrame objFrame = objFrameItem.Value;
                int limit = objFrame.limit;
                int cachedCursor = -1;
                for (int i = objFrame.cursor; i < objFrame.frameDatas.Count; i++)
                {
                    if (_TrySetCanFrameUpdate(objFrame, i, ref limit, ref cachedCursor))
                    {
                        break;
                    }
                }

                if (cachedCursor < 0 && objFrame.cursor > 0)
                {
                    for (int i = 0; i < objFrame.cursor; i++)
                    {
                        if (_TrySetCanFrameUpdate(objFrame, i, ref limit, ref cachedCursor))
                        {
                            break;
                        }
                    }
                }

                if (cachedCursor < 0)
                {
                    cachedCursor = 0;
                }
                objFrame.cursor = cachedCursor;
            }
        }

        private bool _TrySetCanFrameUpdate(ObjFrame objFrame,  int index, ref int limit, ref int cachedCursor)
        {
            FrameData frameData = objFrame.frameDatas[index];
            if (!frameData.obj.requiredFrameUpdate)
            {
                return false;
            }
            frameData.SetCanFrameUpdate(true);
            _updatedDatas.Add(frameData);
            if (--limit <= 0)
            {
                cachedCursor = index + 1;
                if (cachedCursor >= objFrame.frameDatas.Count)
                {
                    cachedCursor = 0;
                }
                return true;
            }
            return false;
        }
        
        public void Add(IFrameUpdate obj, int limit = 1)
        {
            if (limit < 1)
            {
                limit = 1;
            }
            ObjFrame objFrame = _GetOrAdd(obj.GetType());
            if (objFrame.limit < limit)
            {
                objFrame.limit = limit;
            }
            FrameData frameData = ObjectPoolUtility.FrameData.Get();
            frameData.obj = obj;
            frameData.SetCanFrameUpdate(false);
            objFrame.frameDatas.Add(frameData);
        }
        
        public void Remove(IFrameUpdate obj)
        {
            ObjFrame objFrame = _GetOrAdd(obj.GetType());
            FrameData frameData = objFrame.Find(obj);
            if (frameData == null)
            {
                return;
            }
            int index = objFrame.frameDatas.IndexOf(frameData);
            if (index < objFrame.cursor)
            {
                objFrame.cursor--;
            }
            else if (objFrame.cursor >= objFrame.frameDatas.Count - 1)
            {
                objFrame.cursor = 0;
            }
            objFrame.frameDatas.RemoveAt(index);
            _updatedDatas.Remove(frameData);
            ObjectPoolUtility.FrameData.Release(frameData);
        }

        private ObjFrame _GetOrAdd(Type type)
        {
            _objFrames.TryGetValue(type, out var actorFrame);
            if (actorFrame == null)
            {
                actorFrame = ObjectPoolUtility.ActorFrame.Get();
                _objFrames.Add(type, actorFrame);
            }
            return actorFrame;
        }

        protected override void OnDestroy()
        {
            foreach (var actorFrameItem in _objFrames)
            {
                ObjectPoolUtility.ActorFrame.Release(actorFrameItem.Value);
            }
            _objFrames.Clear();
            _updatedDatas.Clear();
        }
        
        public class ObjFrame : IReset
        {
            public int limit = 1;
            public int cursor = 0;
            public List<FrameData> frameDatas = new List<FrameData>(5);

            public FrameData Find(object obj)
            {
                foreach (FrameData frameData in frameDatas)
                {
                    if (frameData.obj == obj)
                    {
                        return frameData;
                    }
                }
                return null;
            }
            
            public void Reset()
            {
                limit = 1;
                cursor = 0;
                foreach (FrameData frameData in frameDatas)
                {
                    ObjectPoolUtility.FrameData.Release(frameData);
                }
                frameDatas.Clear();
            }
        }
        
        public class FrameData : IReset
        {
            public IFrameUpdate obj;
            public bool canFrameUpdate { get; private set; }

            public void SetCanFrameUpdate(bool canFrameUpdate)
            {
                this.canFrameUpdate = canFrameUpdate;
                obj.canFrameUpdate = canFrameUpdate;
            }

            public void Reset()
            {
                obj = null;
                canFrameUpdate = false;
            }
        }
    }
}