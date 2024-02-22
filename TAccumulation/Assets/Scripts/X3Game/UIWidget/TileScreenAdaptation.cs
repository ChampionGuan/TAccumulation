using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace X3Game
{
    public class TileScreenAdaptation : MonoBehaviour
    {
        [SerializeField] protected RectOffset m_Padding = new RectOffset();
        [SerializeField] protected GridLayoutGroup.Axis m_StartAxis = GridLayoutGroup.Axis.Horizontal;
        [SerializeField] protected GridLayoutGroup.Constraint m_Constraint = GridLayoutGroup.Constraint.Flexible;

        private Vector3 start;
        private float space;
        private int childCount;

        void Start()
        {
            Adaptation();
        }

        public void Adaptation()
        {
            Canvas canvas = null;

#if UNITY_EDITOR
            if (!UnityEditor.EditorApplication.isPlaying)
            {
                Transform parent = transform;
                while (null == canvas && null != parent)
                {
                    canvas = parent.GetComponent<Canvas>();
                    if (null != canvas && !canvas.isRootCanvas) canvas = null;
                    parent = parent.parent;
                }
            }
#endif
            if (null == canvas && null != PapeGames.X3UI.UIMgr.Instance)
            {
                canvas = PapeGames.X3UI.UIMgr.Instance.UIRoot.GetComponent<Canvas>();
            }

            if (null == canvas)
            {
                return;
            }

            Vector2 size = canvas.GetComponent<RectTransform>().sizeDelta;
            float width = size.x;
            float height = size.y;

            space = 0;
            start = Vector3.zero;
            childCount = transform.childCount;
            if (childCount > 0)
            {
                if (childCount > 1)
                {
                    switch (m_StartAxis)
                    {
                        case GridLayoutGroup.Axis.Horizontal:
                            start.x += (-0.5f * width + m_Padding.left);
                            space = (width - m_Padding.left - m_Padding.right) / (childCount - 1);
                            break;
                        case GridLayoutGroup.Axis.Vertical:
                            start.y -= (-0.5f * height + m_Padding.top);
                            space = (height - m_Padding.top - m_Padding.bottom) / (childCount - 1);
                            break;
                    }
                }

                RectTransform child = null;
                for (int i = 0; i < childCount; i++)
                {
                    child = transform.GetChild(i) as RectTransform;
                    child.pivot = new Vector2(0.5f, 0.5f);
                    child.localPosition =
                        new Vector3((m_StartAxis == GridLayoutGroup.Axis.Horizontal ? start.x + space * i : start.x),
                            m_StartAxis == GridLayoutGroup.Axis.Horizontal ? start.y : start.y - space * i, 0);
                }
            }
        }
    }
}