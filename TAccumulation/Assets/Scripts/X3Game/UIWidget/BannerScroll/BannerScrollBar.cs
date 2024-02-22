using System;
using System.Collections.Generic;
using UnityEngine.EventSystems;
using UnityEngine;
using UnityEngine.UI;

public class BannerScrollBar : MonoBehaviour
{
    // 是否为横向
    public bool m_horizontal = true;

    public RectTransform m_itemTemplate;
    public Vector2 m_defaultItemSize;

    private bool m_initialized;

    private List<Toggle> m_using = new List<Toggle>();
    private List<Toggle> m_idles = new List<Toggle>();

    private float m_lineMin;
    private float m_itemSize;

    private int m_count;
    public int Count
    {
        get
        {
            return m_count;
        }
        set
        {
            if (!m_initialized)
            {
                m_initialized = true;
                m_itemSize = m_horizontal ? m_defaultItemSize.x : m_defaultItemSize.y;
                for (int i = 0; i < transform.childCount; i++)
                {
                    Transform _t = transform.GetChild(i);
                    _t.gameObject.SetActive(false);
                    m_idles.Add(_t.GetComponent<Toggle>());
                }
            }
            foreach (var v in m_using)
            {
                v.gameObject.SetActive(false);
                m_idles.Add(v);
            }
            m_using.Clear();
            for (int i = m_idles.Count; i < value; i++)
            {
                RectTransform _t = GameObject.Instantiate(m_itemTemplate) as RectTransform;
                _t.parent = transform;
                _t.localPosition = Vector3.zero;
                _t.localScale = Vector3.one;
                _t.localRotation = Quaternion.identity;
                _t.gameObject.SetActive(false);
                m_idles.Add(_t.GetComponent<Toggle>());
            }
            m_lineMin = m_horizontal ? -m_itemSize : m_itemSize * (value - 1) * 0.5f;
            for (int i = 0; i < value; i++)
            {
                Toggle _t = m_idles[0];
                _t.transform.localPosition = m_horizontal ? new Vector3(m_lineMin + i * m_itemSize, 0, 0) : new Vector3(0, m_lineMin - i * m_itemSize, 0);
                _t.gameObject.SetActive(true);
                _t.isOn = false;
                m_idles.RemoveAt(0);
                m_using.Add(_t);
            }
            m_count = value;
        }
    }

    private int m_index;
    public int Index
    {
        get
        {
            return m_index;
        }
        set
        {
            m_using[value].isOn = true;
            m_index = value;
        }
    }
}
