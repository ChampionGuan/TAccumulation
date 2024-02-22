using System.Collections.Generic;
using Cinemachine;
using PapeGames.Rendering;
using UnityEngine;

namespace PapeGames
{
    public static class VisiblePoolTool
    {
        // 记录gameobject上的数据
        public static VisiblePoolItem RecordPoolItem(GameObject obj)
        {
            if (obj == null)
            {
                return null;
            }
            
            var poolItem = obj.GetComponent<VisiblePoolItem>();
            if (poolItem == null)
            {
                poolItem = obj.AddComponent<VisiblePoolItem>();
            }
            poolItem.Record();
            if (Application.isPlaying)
            {
                // 运行时   
                return poolItem;
            }
            else
            {
                // 非运行时   
                if (poolItem.HasData())
                {
                    return poolItem;
                }
                else
                {
                    Object.DestroyImmediate(poolItem, true);
                    return null;
                }   
            }
        }
        
        // 生成需要关心的behaviour
        public static Behaviour[] GenerateDatas(GameObject obj)
        {
            var cameras = obj.GetComponentsInChildren<CinemachineVirtualCamera>(true);
            // TODO 水牛说这些先不用管，遇到一个技术中心修一个
            var atoms = obj.GetComponentsInChildren<AtmosphereSystem>(true);
            // var ppvs = obj.GetComponentsInChildren<PostProcessVolume>(true);
            var list = new List<Behaviour>();
            list.AddRange(cameras);
            list.AddRange(atoms);
            // list.AddRange(ppvs);
            if (list.Count > 0)
            {
                return list.ToArray();
            }
            return null;
        }

        // 设置poolBehaviours的enable()，通过GameObject 
        public static void EnablePoolItemBehaviours(GameObject obj, bool enable)
        {
            if (obj != null)
            {
                obj.SetVisible(enable);
                var extInfo = obj.GetComponent<VisiblePoolItem>();
                if (extInfo != null)
                {
                    if (enable)
                    {
                        extInfo.EnableBehaviours();
                    }
                    else
                    {
                        extInfo.DisableBehaviours();
                    }
                }
            }
        }

        // 设置设置poolBehaviours的enable，通过VisiblePoolItem组件
        public static void EnablePoolItemBehavioursByItem(VisiblePoolItem extInfo, bool enable)
        {
            if (extInfo != null)
            {
                extInfo.gameObject.SetVisible(enable);
                if (extInfo != null)
                {
                    if (enable)
                    {
                        extInfo.EnableBehaviours();
                    }
                    else
                    {
                        extInfo.DisableBehaviours();
                    }
                }
            }  
        }
    }
}