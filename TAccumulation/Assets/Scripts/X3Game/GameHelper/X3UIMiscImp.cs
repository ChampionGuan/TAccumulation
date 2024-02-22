using PapeGames.X3UI;
using System.Collections.Generic;
using System.Linq;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.EventSystems;

namespace X3Game
{
    public class X3UIMiscImp : IUIMiscDelegate
    {
        private IUIMiscDelegate _iuiMiscDelegateImplementation;

        private List<IGlobalInputEventDelegate> m_GlobalInputEventDelegateList = new List<IGlobalInputEventDelegate>();

        public void OnShowBasePlate(UIView view, GameObject basePlateRoot)
        {
            //todo:不应该将X3Animator逻辑放在这里
            {
                List<X3Animator> list = ListPool<X3Animator>.Get();
                basePlateRoot.GetComponentsInChildren<X3Animator>(true, list);
                foreach (var comp in list)
                {
                    Object.Destroy(comp);
                }

                ListPool<X3Animator>.Release(list);
            }
        }

        public string EmojiTagToFileName(string emojiTag)
        {
            return X3RichTextEntry.GetEmojiFileName(emojiTag);
        }

        public uint StringToHash(string str)
        {
            var hashCode = CommonUtility.StringToHash(str);
            return hashCode;
        }

        public string HashToString(uint hashCode)
        {
            var str = CommonUtility.HashToString(hashCode);
            return str;
        }

        public bool SetImage(UnityEngine.Object obj, string spriteName, string atlasName = null,
            bool useNativeSize = false)
        {
            return UIUtility.SetImage(obj, spriteName, atlasName, useNativeSize);
        }

        /// <summary>
        /// 注册点击穿透委托
        /// </summary>
        /// <param name="delegate"></param>
        public void RegisterGlobalInputEventDelegate(IGlobalInputEventDelegate @delegate)
        {
            m_GlobalInputEventDelegateList.Add(@delegate);
        }

        /// <summary>
        /// 移除点击穿透事件转发委托
        /// </summary>
        /// <param name="delegate"></param>
        public void UnregisterGlobalInputEventDelegate(IGlobalInputEventDelegate @delegate)
        {
            m_GlobalInputEventDelegateList.Remove(@delegate);
        }

        public void ExeGlobalInputEvent(PointerEventData eventData, GameObject targetObj, EventTriggerType type)
        {
            for (int i = 0; i < m_GlobalInputEventDelegateList.Count; i++)
            {
                var globalInput = m_GlobalInputEventDelegateList[i];
                globalInput.OnGlobalInputEvent(eventData,targetObj,type);
            }
        }
    }
}