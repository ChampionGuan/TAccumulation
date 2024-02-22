using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Game
{
    /// <summary>
    /// 娃娃机特效绑定数据，使用Key绑定一组特效控制开关
    /// </summary>
    public class UFOCatcherEffect : MonoBehaviour
    {
        /// <summary>
        /// 使用Key绑定一组特效
        /// </summary>
        [SerializeField]
        public List<UFOCatcherEffectData> effectDic;

        /// <summary>
        /// 根据Key获得绑定的特效组
        /// </summary>
        /// <param name="type"></param>
        /// <param name="effectObjs"></param>
        /// <returns></returns>
        public bool TryGetEffectObjsWithType(string type, out List<GameObject> effectObjs)
        {
            
            var effectData = effectDic.Find((a) => a.effectType == type);

            if (effectData != null)
            {
                effectObjs = effectData.effectObjList;
                return true;
            }
            else
            {
                effectObjs = null;
                return false;
            }
        }
    }

    [Serializable]
    public class UFOCatcherEffectData
    {
        /// <summary>
        /// 主Key
        /// </summary>
        [SerializeField]
        public string effectType;

        /// <summary>
        /// 特效组
        /// </summary>
        [SerializeField]
        public List<GameObject> effectObjList;
    }
}