using UnityEngine;
using UnityEditor;
using UnityEditorInternal;

[CustomEditor(typeof(GachaEffectData))]
public class GachaRotateInspector : Editor
{
    SerializedProperty m_RotateParam;
    ReorderableList m_paramList;
    private bool isExpend = true;
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        EditorGUILayout.Space();
        isExpend = EditorGUILayout.Foldout(isExpend, "RingList", true);
        if (isExpend) m_paramList.DoLayoutList();

        serializedObject.ApplyModifiedProperties();
    }

    private void OnEnable()
    {
        Init();
    }

    private void Init()
    {
        m_RotateParam = this.serializedObject.FindProperty("RotateParam");
        Debug.Log(m_RotateParam.arraySize);
        m_paramList = new ReorderableList(serializedObject, m_RotateParam, true, true, true, true);
        m_paramList.drawHeaderCallback = OnHeaderCallback;
        m_paramList.drawElementCallback = OnItemCallback;
        m_paramList.onAddCallback = OnAddCallback;
    }

    private GUIStyle mHeaderGUIStyle;
    private GUIStyle headerGUIStyle
    {
        get
        {
            if (mHeaderGUIStyle == null)
            {
                mHeaderGUIStyle = new GUIStyle(EditorStyles.label);
                mHeaderGUIStyle.alignment = TextAnchor.MiddleCenter;
            }
            return mHeaderGUIStyle;
        }
    }

    private GUIStyle mNameGUIStyle;
    private GUIStyle nameGUIStyle
    {
        get
        {
            if (mNameGUIStyle == null)
            {
                mNameGUIStyle = new GUIStyle(EditorStyles.textField);
                mNameGUIStyle.alignment = TextAnchor.MiddleLeft;
            }
            return mNameGUIStyle;
        }
    }
    private void OnHeaderCallback(Rect rect)
    {
        float avgWidth = (rect.width - 8) / 4;
        EditorGUI.LabelField(new Rect(rect.x, rect.y, avgWidth, rect.height), "Target", headerGUIStyle);
        EditorGUI.LabelField(new Rect(rect.x + avgWidth + 20, rect.y, avgWidth, rect.height), "XSpeed", headerGUIStyle);
        EditorGUI.LabelField(new Rect(rect.x + avgWidth * 2 + 20, rect.y, avgWidth, rect.height), "YSpeed", headerGUIStyle);
        EditorGUI.LabelField(new Rect(rect.x + avgWidth * 3 + 20, rect.y, avgWidth, rect.height), "ZSpeed", headerGUIStyle);
    }

    private void OnItemCallback(Rect rect, int index, bool selected, bool focused)
    {
        float w1 = (rect.width - 20) * 0.3f;
        float w2 = (rect.width - 20) * 0.2f;
        float w3 = (rect.width - 20) * 0.2f;
        float w4 = (rect.width - 20) * 0.2f;
        SerializedProperty item = m_RotateParam.GetArrayElementAtIndex(index);
        SerializedProperty propType = item.FindPropertyRelative("Target");
        Rect typeRect = new Rect(rect.x, rect.y + 3, w1, rect.height - 4);
        EditorGUI.PropertyField(typeRect, propType, GUIContent.none);

        SerializedProperty xspeed = item.FindPropertyRelative("XSpeed");
        Rect nameRect = new Rect(rect.x + w1 + 10, rect.y + 2, w2, rect.height - 4);
        xspeed.floatValue = float.Parse(EditorGUI.TextField(nameRect, xspeed.floatValue.ToString(), nameGUIStyle));

        SerializedProperty yspeed = item.FindPropertyRelative("YSpeed");
        nameRect = new Rect(rect.x + w1 + w2 + 30, rect.y + 2, w3, rect.height - 4);
        yspeed.floatValue = float.Parse(EditorGUI.TextField(nameRect, yspeed.floatValue.ToString(), nameGUIStyle));

        SerializedProperty zspeed = item.FindPropertyRelative("ZSpeed");
        nameRect = new Rect(rect.x + w1 + w2 + w3 + 50, rect.y + 2, w4, rect.height - 4);
        zspeed.floatValue = float.Parse(EditorGUI.TextField(nameRect, zspeed.floatValue.ToString(), nameGUIStyle));
    }

    private void OnAddCallback(ReorderableList list)
    {
        ReorderableList.defaultBehaviours.DoAddButton(list);
        SerializedProperty property = list.serializedProperty.GetArrayElementAtIndex(list.serializedProperty.arraySize - 1);
        property.FindPropertyRelative("Target").objectReferenceValue = null;
        property.FindPropertyRelative("XSpeed").floatValue = 0;
        property.FindPropertyRelative("YSpeed").floatValue = 0;
        property.FindPropertyRelative("ZSpeed").floatValue = 0;
    }
}