using System;
using System.Collections;
using System.Collections.Generic;
using ParadoxNotion;
using ParadoxNotion.Design;
using ParadoxNotion.Serialization.FullSerializer;
using UnityEngine;

namespace X3Battle
{
    [Serializable]
    [fsObject(Converter = typeof(fsActorListConverter))]
    public class ActorList : List<Actor>
    {
        private bool _isRegister;
        private Action<EventActorBase> _actionEventActorDead;

        public ActorList()
        {
            _actionEventActorDead = _OnActorEvent;
        }

        public ActorList(int capacity) : base(capacity)
        {
            _actionEventActorDead = _OnActorEvent;
        }

        public new void Add(Actor actor)
        {
            base.Add(actor);
            _RegisterEvent();
        }

        public new void AddRange(IEnumerable<Actor> collection)
        {
            base.AddRange(collection);
            _RegisterEvent();
        }

        public new void Remove(Actor actor)
        {
            base.Remove(actor);
            _UnregisterEvent();
        }

        public new void Clear()
        {
            base.Clear();
            _UnregisterEvent();
        }

        private void _RegisterEvent()
        {
            if (this.Count <= 0)
            {
                return;
            }

            if (_isRegister)
            {
                return;
            }

            _isRegister = true;
            
            Battle.Instance.eventMgr.AddListener(EventType.ActorDead, _actionEventActorDead, "ActorList._OnActorEvent");
        }

        private void _UnregisterEvent()
        {
            if (this.Count > 0)
            {
                return;
            }
            
            if (!_isRegister)
            {
                return;
            }
            _isRegister = false;

            Battle.Instance.eventMgr.RemoveListener(EventType.ActorDead, _actionEventActorDead);
        }

        private void _OnActorEvent(EventActorBase args)
        {
            if (args?.actor == null)
            {
                return;
            }

            this.Remove(args.actor);
        }
    }

    public class fsActorListConverter : fsConverter
    {
        public override bool CanProcess(Type type)
        {
            return false;
        }

        public override object CreateInstance(fsData data, Type storageType)
        {
            return new ActorList();
        }

        public override fsResult TrySerialize(object instance_, out fsData serialized, Type storageType)
        {
            var instance = (IList)instance_;
            var result = fsResult.Success;

            var elementType = typeof(Actor);
            serialized = fsData.CreateList(instance.Count);
            var serializedList = serialized.AsList;

            for ( var i = 0; i < instance.Count; i++ ) {
                var item = instance[i];
                fsData itemData;

                // auto instance?
                if ( item == null && elementType.RTIsDefined<fsAutoInstance>(true) ) {
                    item = fsMetaType.Get(elementType).CreateInstance();
                    instance[i] = item;
                }

                var itemResult = Serializer.TrySerialize(elementType, item, out itemData);
                result.AddMessages(itemResult);
                if ( itemResult.Failed ) continue;
                serializedList.Add(itemData);
            }
            return result;
        }

        public override fsResult TryDeserialize(fsData data, ref object instance_, Type storageType)
        {
            var instance = (IList)instance_;
            var result = fsResult.Success;

            if ( ( result += CheckType(data, fsDataType.Array) ).Failed ) {
                return result;
            }

            if ( data.AsList.Count == 0 ) {
                return fsResult.Success;
            }

            var elementType = typeof(Actor);
            //if we have the exact same count, deserialize overwrite
            if ( instance.Count == data.AsList.Count && fsMetaType.Get(elementType).DeserializeOverwriteRequest ) {
                for ( var i = 0; i < data.AsList.Count; i++ ) {
                    object item = instance[i];
                    var itemResult = Serializer.TryDeserialize(data.AsList[i], elementType, ref item);
                    if ( itemResult.Failed ) continue;
                    instance[i] = item;
                }
                return fsResult.Success;
            }

            //otherwise clear and start anew
            instance.Clear();
            var capacityProperty = instance.GetType().RTGetProperty("Capacity");
            capacityProperty.SetValue(instance, data.AsList.Count);
            for ( var i = 0; i < data.AsList.Count; i++ ) {
                object item = null;
                var itemResult = Serializer.TryDeserialize(data.AsList[i], elementType, ref item);
                if ( itemResult.Failed ) continue;
                instance.Add(item);
            }
            return fsResult.Success;
        }
    }


#if UNITY_EDITOR
    public class ActorListDrawer : ObjectDrawer<ActorList>
    {
        private List<Actor> _useShowList = new List<Actor>();
        public override ActorList OnGUI(GUIContent content, ActorList instance)
        {
            if (instance == null)
            {
                return EditorUtils.DrawEditorFieldDirect(content, instance, typeof(ActorList), info) as ActorList;
            }

            _useShowList.Clear();
            _useShowList.AddRange(instance);
            EditorUtils.DrawEditorFieldDirect(content, _useShowList, typeof(List<Actor>), info);
            return instance;
        }
    }
#endif
}