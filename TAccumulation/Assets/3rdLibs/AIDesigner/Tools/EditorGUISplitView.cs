using System;
using UnityEngine;
using UnityEditor;

[Serializable]
public class EditorGUISplitView
{
    public enum Direction
    {
        Horizontal,
        Vertical
    }

    Direction splitDirection;
    [SerializeField] float splitNormalizedPosition;
    bool userResize;
    bool windowResize;
    public bool Resizing => userResize || windowResize;

    public Vector2 scrollPosition;
    [SerializeField] Rect availableRect;
    [SerializeField] private float firstMinLength;
    [SerializeField] private float firstMaxLength;
    [SerializeField] private bool displaySplitter;
    [SerializeField] private bool createRealArea;

    [SerializeField] private Rect lastRect = Rect.zero;

    public float AvailableLength
    {
        get
        {
            if (splitDirection == Direction.Horizontal)
            {
                return availableRect.width;
            }
            else
            {
                return availableRect.height;
            }
        }
    }

    public float SplitFirstPartWidth => AvailableLength * splitNormalizedPosition;
    public float SplitSecondPartWidth => AvailableLength * (1 - splitNormalizedPosition);

    /// <summary>
    /// 
    /// </summary>
    /// <param name="splitDirection">划分方向</param>
    /// <param name="beginPosition">起始的划分比例</param>
    /// <param name="firstMinLength">最小划分比例</param>
    /// <param name="firstMaxLength">最大划分比例</param>
    /// <param name="displaySplitter">是否显示分割线</param>
    /// <param name="createRealArea">是否真正创建左右GUILayout区域（关闭后仅是一个类似scrollbar的东西，用于内嵌到已有界面）</param>
    public EditorGUISplitView(Direction splitDirection, float beginPosition = 0.5f, float firstMinLength = 0,
        float firstMaxLength = float.MaxValue,
        bool displaySplitter = true, bool createRealArea = true)
    {
        splitNormalizedPosition = Mathf.Clamp(beginPosition, 0, 1);
        this.firstMinLength = firstMinLength;
        this.firstMaxLength = firstMaxLength;
        this.displaySplitter = displaySplitter;
        this.createRealArea = createRealArea;
        this.splitDirection = splitDirection;
    }

    public void BeginSplitView()
    {
        // 通过Horizontal拿到availableRect
        Rect tempRect;

        if (splitDirection == Direction.Horizontal)
            tempRect = EditorGUILayout.BeginHorizontal(GUILayout.ExpandWidth(true));
        else
            tempRect = EditorGUILayout.BeginVertical(GUILayout.ExpandHeight(true));

        if (tempRect.width > 0.0f)
        {
            availableRect = tempRect;
        }

        if (!createRealArea)
        {
            return;
        }

        // 创建左侧scrollView
        if (splitDirection == Direction.Horizontal)
            scrollPosition = GUILayout.BeginScrollView(scrollPosition,
                GUILayout.Width(availableRect.width * splitNormalizedPosition));
        else
            scrollPosition = GUILayout.BeginScrollView(scrollPosition,
                GUILayout.Height(availableRect.height * splitNormalizedPosition));
    }

    public void Split()
    {
        if (createRealArea)
        {
            // 结束创建左侧scrollView
            GUILayout.EndScrollView();
        }

        ResizeSplitFirstView();
        KeepSplitLengthWhenWindowResize();
    }

    public void EndSplitView()
    {
        // 结束通过Horizontal拿到availableRect
        if (splitDirection == Direction.Horizontal)
            EditorGUILayout.EndHorizontal();
        else
            EditorGUILayout.EndVertical();
    }

    private void ResizeSplitFirstView()
    {
        /*
         * 使用controlID结合Event.current.GetTypeForControl()可以处理MouseUp发生在窗口外从而EventType==ignore的情况
         * 当然检查Event.current.rawType也可以，但是rawType看起来好像有一点点tricky
         */
        var controlID = GUIUtility.GetControlID(FocusType.Passive);

        // Debug.Log(Event.current.type + " " + Event.current.rawType);

        // 绘制resizeHandle
        Rect resizeHandleRect;

        if (splitDirection == Direction.Horizontal)
            resizeHandleRect = new Rect(availableRect.width * splitNormalizedPosition, availableRect.y, 2f,
                availableRect.height);
        else
            resizeHandleRect = new Rect(availableRect.x, availableRect.height * splitNormalizedPosition,
                availableRect.width, 2f);

        if (displaySplitter)
        {
            GUI.DrawTexture(resizeHandleRect, EditorGUIUtility.whiteTexture);
        }

        if (splitDirection == Direction.Horizontal)
            EditorGUIUtility.AddCursorRect(resizeHandleRect, MouseCursor.ResizeHorizontal);
        else
            EditorGUIUtility.AddCursorRect(resizeHandleRect, MouseCursor.ResizeVertical);

        // 处理resizeHandle事件
        if (!userResize && Event.current.GetTypeForControl(controlID) == EventType.MouseDown &&
            resizeHandleRect.Contains(Event.current.mousePosition))
        {
            userResize = true;
            GUIUtility.hotControl = controlID;
            Event.current.Use();
        }

        if (userResize && Event.current.GetTypeForControl(controlID) == EventType.MouseDrag)
        {
            Event.current.Use();
        }

        if (userResize)
        {
            if (splitDirection == Direction.Horizontal)
                splitNormalizedPosition = Event.current.mousePosition.x / availableRect.width;
            else
                splitNormalizedPosition = Event.current.mousePosition.y / availableRect.height;

            splitNormalizedPosition = Mathf.Clamp(splitNormalizedPosition, firstMinLength / AvailableLength,
                Mathf.Min(firstMaxLength / AvailableLength, 1));
        }

        if (userResize && Event.current.GetTypeForControl(controlID) == EventType.MouseUp)
        {
            userResize = false;
            if (GUIUtility.hotControl == controlID)
            {
                GUIUtility.hotControl = 0;
            }

            Event.current.Use();
        }
    }

    /// <summary>
    /// 当窗口大小变化时，保持分割区域长度
    /// </summary>
    private void KeepSplitLengthWhenWindowResize()
    {
        if (lastRect != availableRect)
        {
            windowResize = true;

            if (lastRect == Rect.zero)
            {
                lastRect = availableRect;
                splitNormalizedPosition = Mathf.Clamp(splitNormalizedPosition,
                    Mathf.Min(1, firstMinLength / AvailableLength),
                    Mathf.Min(firstMaxLength / AvailableLength, 1));
                return;
            }

            // 用未更新的splitNormalized和上次的rect进行计算，保持分割长度
            float lastFirstPartLength;
            if (splitDirection == Direction.Horizontal)
            {
                lastFirstPartLength = splitNormalizedPosition * lastRect.width;
            }
            else
            {
                lastFirstPartLength = splitNormalizedPosition * lastRect.height;
            }

            var curNormalizedPos = lastFirstPartLength / AvailableLength;
            splitNormalizedPosition = Mathf.Clamp(curNormalizedPos, Mathf.Min(1, firstMinLength / AvailableLength),
                Mathf.Min(firstMaxLength / AvailableLength, 1));
            lastRect = availableRect;
        }
        else
        {
            windowResize = false;
        }
    }
}