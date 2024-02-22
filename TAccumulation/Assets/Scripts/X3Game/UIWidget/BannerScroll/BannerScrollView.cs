using System;
using UnityEngine.EventSystems;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class BannerScrollView : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
{
    // 是否为横向
    public bool m_horizontal = true;

    public RectTransform m_itemTemplate;
    public RectTransform m_content;
    public BannerScrollBar m_scrollBar;
    public Vector2 m_defaultItemSize;
    public float m_sensitivity = 10;
    public float m_autoScrollInterval = 10;
    public float m_adjustSpeed = 20;

    private bool m_initialized;
    private bool m_isDraging;
    private bool m_isRightDir;
    private float m_itemSize;
    private int m_indexMax = 2;
    private int m_count;
    private float m_lineMin;
    private float m_lineMax;
    private float m_lineOnThird;
    private Vector3 m_dragPos;

    private ItemNode[] m_itemNodes = new ItemNode[2];
    private Action<int, Transform> m_onItemRender;

    private float m_tickV;
    private float m_floatV;
    private int m_indexV;
    private int m_barV;
    private Vector3 m_posV;

    void LateUpdate()
    {
        if (m_isDraging || m_count < m_indexMax)
        {
            return;
        }
        m_tickV += Time.deltaTime;
        if (m_autoScrollInterval > 0 && m_tickV > m_autoScrollInterval)
        {
            m_tickV = 0;
            m_dragPos = m_content.localPosition;
            if (m_horizontal)
                m_dragPos.x = (Mathf.RoundToInt(m_dragPos.x / m_itemSize) - 1) * m_itemSize;
            else
                m_dragPos.y = (Mathf.RoundToInt(m_dragPos.y / m_itemSize) + 1) * m_itemSize;
            StopAllCoroutines();
            StartCoroutine(Adjust(m_dragPos));
        }
    }
    void OnEnable()
    {
        if (!m_initialized)
        {
            return;
        }
        EndDrag(Vector3.zero);
    }
    public int Count
    {
        set
        {
            if (!m_initialized) Initialize();
            if (null != m_scrollBar) m_scrollBar.Count = value;
            m_count = value;
            StopAllCoroutines();
            m_content.localPosition = Vector3.zero;
            for (int i = 0; i < m_indexMax; i++) m_itemNodes[i].OnRender(i, i == 0 ? Vector3.zero : m_horizontal ? new Vector3(m_itemSize, 0, 0) : new Vector3(0, -m_itemSize, 0));
            m_barV = -1;
            OnBar(0);
        }
    }
    public Action<int, Transform> OnItemRender
    {
        set
        {
            if (!m_initialized) Initialize();
            m_onItemRender = value;
            for (int i = 0; i < m_indexMax; i++)
            {
                m_itemNodes[i].SetOnRenderCB(value);
            }
        }
    }
    public void StartScroll(int _count, Action<int, Transform> _onItemRender)
    {
        OnItemRender = _onItemRender;
        Count = _count;
    }
    public void OnBeginDrag(PointerEventData _eventData)
    {
        if (m_count < m_indexMax)
        {
            return;
        }
        StopAllCoroutines();
        m_isDraging = true;
        m_tickV = 0;
    }
    public void OnDrag(PointerEventData _eventData)
    {
        Drag(_eventData.delta);
    }
    public void OnEndDrag(PointerEventData _eventData)
    {
        EndDrag(_eventData.delta);
    }
    private void Drag(Vector3 _deltaPos)
    {
        if (m_count < m_indexMax)
        {
            return;
        }
        m_dragPos = m_content.localPosition;
        if (m_horizontal)
            m_dragPos.x += _deltaPos.x;
        else
            m_dragPos.y += _deltaPos.y;
        m_content.localPosition = m_dragPos;
        OnScroll();
    }
    private void EndDrag(Vector3 _deltaPos)
    {
        if (m_count < m_indexMax)
        {
            return;
        }
        m_dragPos = m_content.localPosition;
        m_floatV = m_horizontal ? m_dragPos.x / m_itemSize : m_dragPos.y / m_itemSize;
        m_indexV = Mathf.RoundToInt(m_floatV);
        if (m_horizontal)
        {
            if (_deltaPos.x > m_sensitivity && m_floatV > m_indexV)
            {
                m_dragPos.x = (m_indexV + 1) * m_itemSize;
            }
            else if (_deltaPos.x < -m_sensitivity && m_floatV < m_indexV)
            {
                m_dragPos.x = (m_indexV - 1) * m_itemSize;
            }
            else
            {
                m_dragPos.x = m_indexV * m_itemSize;
            }
        }
        else
        {
            if (_deltaPos.y > m_sensitivity && m_floatV > m_indexV)
            {
                m_dragPos.y = (m_indexV + 1) * m_itemSize;
            }
            else if (_deltaPos.y < -m_sensitivity && m_floatV < m_indexV)
            {
                m_dragPos.y = (m_indexV - 1) * m_itemSize;
            }
            else
            {
                m_dragPos.y = m_indexV * m_itemSize;
            }
        }
        StartCoroutine(Adjust(m_dragPos));
    }
    private IEnumerator Adjust(Vector3 t)
    {
        while (Vector3.Distance(t, m_content.localPosition) > 0.05f)
        {
            m_content.localPosition = Vector3.Lerp(m_content.localPosition, t, Time.smoothDeltaTime * m_adjustSpeed);
            OnScroll();
            yield return null;
        }

        m_isDraging = false;
    }
    private void Initialize()
    {
        m_itemSize = m_horizontal ? m_defaultItemSize.x : m_defaultItemSize.y;

        List<RectTransform> childs = new List<RectTransform>();
        for (int i = 0; i < m_content.childCount; i++)
        {
            childs.Add(m_content.GetChild(i) as RectTransform);
        }
        for (int i = m_indexMax; i < childs.Count; i++)
        {
            GameObject.Destroy(childs[i]);
        }
        for (int i = childs.Count; i < m_indexMax; i++)
        {
            RectTransform _t = GameObject.Instantiate(m_itemTemplate) as RectTransform;
            _t.parent = m_content;
            _t.localPosition = Vector3.zero;
            _t.localScale = Vector3.one;
            _t.localRotation = Quaternion.identity;
            childs.Add(_t);
        }
        for (int i = 0; i < childs.Count; i++)
        {
            m_itemNodes[i] = new ItemNode(i, childs[i], m_onItemRender);
        }
        childs.Clear();

        if (m_horizontal)
        {
            m_content.localPosition = new Vector3(-m_itemSize, 0, 0);
            m_lineMin = m_content.position.x;
            m_content.localPosition = new Vector3(+m_itemSize, 0, 0);
            m_lineMax = m_content.position.x;
            m_lineOnThird = (m_lineMax - m_lineMin) / 3f;
        }
        else
        {
            m_content.localPosition = new Vector3(0, m_itemSize, 0);
            m_lineMin = m_content.position.y;
            m_content.localPosition = new Vector3(0, -m_itemSize, 0);
            m_lineMax = m_content.position.y;
            m_lineOnThird = (m_lineMin - m_lineMax) / 3f;
        }
        if (m_lineOnThird > 0)
        {
            m_isRightDir = true;
        }
        else
        {
            m_isRightDir = false;
            m_lineOnThird *= -1;
        }
        m_content.localPosition = Vector3.zero;

        m_initialized = true;
    }

    private void OnScroll()
    {
        foreach (var v in m_itemNodes)
        {
            if (m_horizontal)
            {
                if (m_isRightDir)
                {
                    if (v.Item.position.x < m_lineMin)
                    {
                        m_indexV = v.Index + m_indexMax;
                        m_indexV = m_indexV > m_count - 1 ? m_indexV - m_count : m_indexV;
                        m_posV = v.Item.localPosition;
                        m_posV.x += m_itemSize * m_indexMax;
                        v.OnRender(m_indexV, m_posV);
                    }
                    else if (v.Item.position.x > m_lineMax)
                    {
                        m_indexV = v.Index - m_indexMax;
                        m_indexV = m_indexV < 0 ? m_count + m_indexV : m_indexV;
                        m_posV = v.Item.localPosition;
                        m_posV.x -= m_itemSize * m_indexMax;
                        v.OnRender(m_indexV, m_posV);
                    }
                    else if (v.Item.position.x > m_lineMin + m_lineOnThird && v.Item.position.x < m_lineMax - m_lineOnThird)
                    {
                        OnBar(v.Index);
                    }
                }
                else
                {
                    if (v.Item.position.x > m_lineMin)
                    {
                        m_indexV = v.Index + m_indexMax;
                        m_indexV = m_indexV > m_count - 1 ? m_indexV - m_count : m_indexV;
                        m_posV = v.Item.localPosition;
                        m_posV.x += m_itemSize * m_indexMax;
                        v.OnRender(m_indexV, m_posV);
                    }
                    else if (v.Item.position.x < m_lineMax)
                    {
                        m_indexV = v.Index - m_indexMax;
                        m_indexV = m_indexV < 0 ? m_count + m_indexV : m_indexV;
                        m_posV = v.Item.localPosition;
                        m_posV.x -= m_itemSize * m_indexMax;
                        v.OnRender(m_indexV, m_posV);
                    }
                    else if (v.Item.position.x > m_lineMax + m_lineOnThird && v.Item.position.x < m_lineMin - m_lineOnThird)
                    {
                        OnBar(v.Index);
                    }
                }
            }
            else
            {
                if (m_isRightDir)
                {
                    if (v.Item.position.y > m_lineMin)
                    {
                        m_indexV = v.Index + m_indexMax;
                        m_indexV = m_indexV > m_count - 1 ? m_indexV - m_count : m_indexV;
                        m_posV = v.Item.localPosition;
                        m_posV.y -= m_itemSize * m_indexMax;
                        v.OnRender(m_indexV, m_posV);
                    }
                    else if (v.Item.position.y < m_lineMax)
                    {
                        m_indexV = v.Index - m_indexMax;
                        m_indexV = m_indexV < 0 ? m_count + m_indexV : m_indexV;
                        m_posV = v.Item.localPosition;
                        m_posV.y += m_itemSize * m_indexMax;
                        v.OnRender(m_indexV, m_posV);
                    }
                    else if (v.Item.position.y < m_lineMin - m_lineOnThird && v.Item.position.y > m_lineMax + m_lineOnThird)
                    {
                        OnBar(v.Index);
                    }
                }
                else
                {
                    if (v.Item.position.y < m_lineMin)
                    {
                        m_indexV = v.Index + m_indexMax;
                        m_indexV = m_indexV > m_count - 1 ? m_indexV - m_count : m_indexV;
                        m_posV = v.Item.localPosition;
                        m_posV.y -= m_itemSize * m_indexMax;
                        v.OnRender(m_indexV, m_posV);
                    }
                    else if (v.Item.position.y > m_lineMax)
                    {
                        m_indexV = v.Index - m_indexMax;
                        m_indexV = m_indexV < 0 ? m_count + m_indexV : m_indexV;
                        m_posV = v.Item.localPosition;
                        m_posV.y += m_itemSize * m_indexMax;
                        v.OnRender(m_indexV, m_posV);
                    }
                    else if (v.Item.position.y < m_lineMax - m_lineOnThird && v.Item.position.y > m_lineMin + m_lineOnThird)
                    {
                        OnBar(v.Index);
                    }
                }
            }
        }
    }
    private void OnBar(int index)
    {
        if (m_barV == index)
        {
            return;
        }
        m_barV = index;
        if (null != m_scrollBar) m_scrollBar.Index = m_barV;
    }
    public class ItemNode
    {
        public int Index { get; private set; }
        public Transform Item { get; private set; }
        public Action<int, Transform> OnItemRender { get; private set; }

        public ItemNode(int _index, Transform _item, Action<int, Transform> _onItemRender)
        {
            Index = _index;
            Item = _item;
            OnItemRender = _onItemRender;
        }
        public void OnRender(int _index, Vector3 _localPos)
        {
            Index = _index;
            Item.localPosition = _localPos;
            if (null != OnItemRender) OnItemRender.Invoke(Index, Item);
        }
        public void SetOnRenderCB(Action<int, Transform> _onItemRender)
        {
            OnItemRender = _onItemRender;
        }
        public void SetLocalPos(Vector3 _localPos)
        {
            Item.localPosition = _localPos;
        }
    }
}
