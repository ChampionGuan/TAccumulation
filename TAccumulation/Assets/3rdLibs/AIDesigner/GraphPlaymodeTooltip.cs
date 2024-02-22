using UnityEditor;
using UnityEngine;

namespace AIDesigner
{
    public class GraphPlaymodeTooltip : Singleton<GraphPlaymodeTooltip>
    {
        private Rect m_graphRect = Rect.zero;
        private float m_tooltipMaxWidth = 300;

        public void OnGUI()
        {
            if (!string.IsNullOrEmpty(GUI.tooltip) && EditorApplication.isPlaying)
            {
                var infoSize = AIDesignerUIUtility.GraphDebugInfoGUIStyle.CalcSize(new GUIContent(GUI.tooltip));
                if (infoSize.x > m_tooltipMaxWidth)
                {
                    infoSize.x = m_tooltipMaxWidth;
                    infoSize.y = AIDesignerUIUtility.GraphDebugInfoGUIStyle.CalcHeight(new GUIContent(GUI.tooltip),
                        m_tooltipMaxWidth);
                }

                m_graphRect.position = Event.current.mousePosition + new Vector2(10, 10);
                m_graphRect.size = infoSize;
                GUI.Label(m_graphRect, GUI.tooltip, AIDesignerUIUtility.GraphDebugInfoGUIStyle);
            }
        }
    }
}