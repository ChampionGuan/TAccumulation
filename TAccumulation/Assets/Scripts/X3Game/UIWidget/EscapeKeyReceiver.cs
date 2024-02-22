using PapeGames.X3UI;
using UnityEngine;
using UnityEngine.EventSystems;

namespace X3Game
{
    /// <summary>
    /// 标记需要相应返回键的ClickHandler
    /// </summary>
    [AddComponentMenu("X3UI/Comp/EscapeKeyReceiver")]
    [RequireComponent(typeof(ClickHandler))]
    public class EscapeKeyReceiver : MonoBehaviour
    {
        private ClickHandler m_Handler;
        private Canvas m_Canvas;
        private BaseRaycaster m_Caster;

        private Canvas Canvas
        {
            get
            {
                if (m_Canvas == null)
                {
                    m_Canvas = GetComponentInParent<Canvas>();
                }

                return m_Canvas;
            }
        }


        private ClickHandler Handler
        {
            get
            {
                if (m_Handler == null)
                {
                    m_Handler = GetComponent<ClickHandler>();
                }

                return m_Handler;
            }
        }

        public int SortingOrder => Canvas.sortingOrder;
        public int SortingLayer => Canvas.sortingLayerID;


        public BaseRaycaster Caster
        {
            get
            {
                if (m_Caster == null)
                {
                    m_Caster = GetComponentInParent<BaseRaycaster>();
                }

                return m_Caster;
            }
        }

        public void InvokeClick(PointerEventData eventData)
        {
            ExecuteEvents.Execute(this.gameObject, eventData, ExecuteEvents.pointerClickHandler);
        }

        public bool IsVaild()
        {
            var isVaild = !(!this.gameObject.visibleInHierarchy || !Handler.isActiveAndEnabled);
            return isVaild;
        }
    }
}