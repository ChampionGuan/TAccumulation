using PapeGames.X3;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using PapeGames.X3Editor;
using X3Game;
using PapeGames.X3Editor;

namespace X3GameEditor
{
    /// <summary>
    /// GIF动图组件的自定义检视器面板
    /// </summary>
    [CustomEditor(typeof(GIFImage))]
    public class GIFImageInspector : BaseInspector<GIFImage>
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            using (new EditorGUILayout.HorizontalScope())
            {
                GUI.enabled = m_Target.CanPlay();
                if (GUILayout.Button("播放"))
                {
                    if (!X3Lua.IsInited)
                        X3Lua.Initialize();
                    if (!X3Lua.IsGameInited)
                    {
                        X3Lua.InitForGame(false);
                        
                    }
                        
                    m_Target.Play();
                }

                GUI.enabled = m_Target.CanStop();
                if (GUILayout.Button("停止"))
                {
                    m_Target.Stop();
                }

                GUI.enabled = m_Target.CanPause();
                if (GUILayout.Button("暂停"))
                {
                    m_Target.Pause();
                }

                GUI.enabled = m_Target.CanResume();
                if (GUILayout.Button("恢复"))
                {
                    m_Target.Resume();
                }

                GUI.enabled = true;
            }
        }
    }
}

