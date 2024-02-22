using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class BSContext 
    {
        public EStaticSlot GetEStaticSlot()
        {
            return EStaticSlot.Battle;
        }
        
        public bool IsAvoidFXLoad()
        {
            return false;
        }

        public GameObject LoadTimelineObject(string resPath)
        {
            var obj = BattleResMgr.Instance.Load<GameObject>(resPath, BattleResType.Timeline);
            return obj;
        }

        public GameObject LoadTimelineFxObject(string resPath)
        {
            if (IsAvoidFXLoad())
            {
                return null;
            }

            var obj = BattleResMgr.Instance.Load<GameObject>(resPath, BattleResType.TimelineFx);
            return obj;
        }

        public TimelineAsset LoadTimelineAsset(string resPath)
        {
            var asset = BattleResMgr.Instance.Load<TimelineAsset>(resPath, BattleResType.TimelineAsset);
            return asset;
        }

        public void UnloadTimelineAsset(TimelineAsset asset)
        {
            if (asset != null)
            {
                BattleResMgr.Instance.Unload(asset);
            }
        }

        // TODO 后续应该做个套装对象池和预加载，目前还没有
        public GameObject LoadSuitObject(string suitKey)
        {
            if (string.IsNullOrEmpty(suitKey))
            {
                return null;
            }

            if (!TimelineExtInfo.TryConvertSuitID(suitKey, out int suitId))
            {
                return null;
            }
            // var ins = BattleCharacterMgr.GetInsWithSuitKeySync(suitKey);
            var ins = BattleCharacterMgr.GetInsBySuitID(suitId);
            return ins;
        }

        public void UnloadGameObject(GameObject obj)
        {
            BattleResMgr.Instance.Unload(obj);
        }

        // TODO 后续应该做个套装对象池和预加载，目前还没有
        public void UnLoadSuitObject(GameObject obj)
        {
            if (obj != null)
            {
                GameObject.Destroy(obj);
            }
        }

        public Transform GetRootTransform()
        {
            return Battle.Instance.timelineRootTrans;
        }
    }
}