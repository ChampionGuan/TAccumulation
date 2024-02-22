using PapeGames.X3;
using UnityEngine;
using UnityEditor;
using X3Game;
using PapeGames.X3Editor;

namespace X3GameEditor
{
    [CustomEditor(typeof(FractionImage))]
    public class FractionImageInspector : BaseInspector<FractionImage>
    {
        private SerializedProperty m_ImageProp;
        private SerializedProperty m_ThemeProp;

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            EditorGUILayout.Space();
            this.DrawPF(m_ImageProp, "显示图片");
            if (GUILayout.Button("随机生成所有主题的数据"))
            {
                m_Target.RandomGenAllDataEditor();
                EditorUtility.SetDirty(m_Target);
            }

            PapeGames.X3Editor.X3EditorGUILayout.HLine(1.0f, Color.gray);
            for (int i = 0; i < m_ThemeProp.arraySize; i++)
            {
                var themeItem = m_ThemeProp.GetArrayElementAtIndex(i);
                var themeProp = themeItem.FindPropertyRelative("Theme");
                this.DrawPF(themeProp);
                var themePathProp = themeItem.FindPropertyRelative("ThemePath");
                this.DrawPF(themePathProp);
                var foldoutProp = themeItem.FindPropertyRelative("IsFoldout");
                foldoutProp.boolValue = EditorGUILayout.Foldout(foldoutProp.boolValue, "数据", true);
                if (foldoutProp.boolValue)
                {
                    GUILayout.BeginVertical();
                    {
                        var imageDataProp = themeItem.FindPropertyRelative("ImageDatas");
                        for (int j = 0; j < imageDataProp.arraySize; j++)
                        {
                            var item = imageDataProp.GetArrayElementAtIndex(j);
                            GUILayout.BeginVertical();
                            {
                                var indexProp = item.FindPropertyRelative("Index");
                                indexProp.intValue =
                                    EditorGUILayout.IntField("Index", indexProp.intValue);
                                var fieldProp = item.FindPropertyRelative("Field");
                                fieldProp.vector4Value = EditorGUILayout.Vector4Field("Field", fieldProp.vector4Value);
                                GUILayout.FlexibleSpace();
                                GUILayout.BeginHorizontal();
                                {
                                    if (GUILayout.Button("预览"))
                                    {
                                        m_Target.SetIdxEditor(themeProp.intValue, indexProp.intValue);
                                    }

                                    if (GUILayout.Button("保存"))
                                    {
                                        var rectTransform = m_Target.GetComponent<RectTransform>();
                                        var size = m_Target.GetRectSize();
                                        var pos = rectTransform.anchoredPosition;
                                        fieldProp.vector4Value = new Vector4(pos.x, pos.y, size.x, size.y);
                                    }

                                    if (GUILayout.Button("删除"))
                                    {
                                        imageDataProp.DeleteArrayElementAtIndex(j);
                                        break;
                                    }

                                    if (GUILayout.Button("添加"))
                                    {
                                        imageDataProp.InsertArrayElementAtIndex(j);
                                        break;
                                    }
                                    
                                    if (GUILayout.Button("随机"))
                                    {
                                        m_Target.GenRandomImg(themeProp.intValue, indexProp.intValue);
                                        
                                        m_Target.SetIdxEditor(themeProp.intValue, indexProp.intValue);

                                        break;
                                    }
                                }
                                GUILayout.EndVertical();
                            }
                            GUILayout.EndHorizontal();
                        }
                        if (GUILayout.Button("添加数据"))
                        {
                            imageDataProp.InsertArrayElementAtIndex(imageDataProp.arraySize);
                            break;
                        }
                    }
                    GUILayout.EndVertical();
                }
                if (GUILayout.Button("删除主题"))
                {
                    m_ThemeProp.DeleteArrayElementAtIndex(i);
                    break;
                }
                PapeGames.X3Editor.X3EditorGUILayout.HLine(1.0f, Color.gray);
            }

            PapeGames.X3Editor.X3EditorGUILayout.HLine(1.0f, Color.gray);
            if (GUILayout.Button("添加主题"))
            {
                m_ThemeProp.InsertArrayElementAtIndex(m_ThemeProp.arraySize - 1);
            }

            serializedObject.ApplyModifiedProperties();
        }

        protected override void Init()
        {
            base.Init();
            m_ImageProp = this.GetSP("m_Image");
            m_ThemeProp = this.GetSP("m_ThemeDatas");
        }
    }
}