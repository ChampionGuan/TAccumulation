using UnityEngine;
using System;
using System.IO;
using UnityEditor;
using UnityEditor.Callbacks;

namespace AIDesigner
{
    public class AIDesignerWindow : EditorWindow
    {
        public static AIDesignerWindow Instance { get; private set; }

        [SerializeField] public EditorGUISplitView InspectorSplitView =
            new EditorGUISplitView(EditorGUISplitView.Direction.Horizontal, 0.22f, 300f + 15f, displaySplitter: false,
                createRealArea: true);

        public float ScreenSizeWidth { get; private set; }
        public float ScreenSizeHeight { get; private set; }
        public bool ScreenSizeChange { get; private set; }

        public event EventHandler LateUpdate;

        [MenuItem("X3Tool/AIDesigner/Editor  &F3", false)]
        public static void Open()
        {
            if (null == Define.CustomSettings)
            {
                return;
            }

            Instance?.Close();
            Instance = EditorWindow.GetWindow<AIDesignerWindow>(false, "AIDesigner");
            Instance.wantsMouseMove = true;
            Instance.minSize = new Vector2(700f, 100f);
            Instance.ScreenSizeWidth = -1;
            Instance.ScreenSizeHeight = -1;

            AIDesignerLuaEnv.Instance.Init();
        }

        public static void Open(string fullName)
        {
            Instance?.Close();
            StoragePrefs.SetPref(PrefsType.TreeName, fullName);
            Open();
        }

        public static void Open(UsedForType type)
        {
            Instance?.Close();
            StoragePrefs.SetPref(PrefsType.UsedForType, type.ToString());
            Open();
        }

        public static void Open(UsedForType type, string fullName)
        {
            Instance?.Close();
            StoragePrefs.SetPref(PrefsType.UsedForType, type.ToString());
            Open(fullName);
        }

        public static bool OpenWithPath(string assetPath)
        {
            if (string.IsNullOrEmpty(assetPath) || !assetPath.EndsWith(".lua"))
            {
                return false;
            }

            if (assetPath.StartsWith("Assets/"))
            {
                assetPath = assetPath.Substring(7);
            }

            foreach (var it in Define.CustomSettings.Setting)
            {
                if (assetPath.Contains(it.ConfigPath) || assetPath.Contains(it.EditorPath))
                {
                    var fullName = assetPath.Replace(it.ConfigFullPath, "").Replace(it.EditorConfigFullPath, "");
                    if (fullName.Contains("/"))
                    {
                        fullName = $"{Path.GetDirectoryName(fullName)}/{Path.GetFileNameWithoutExtension(fullName)}"
                            .Replace("\\", "/");
                    }
                    else
                    {
                        fullName = Path.GetFileNameWithoutExtension(fullName);
                    }

                    Open(it.UsedForType, fullName);
                    return true;
                }
            }

            return false;
        }

        public void OnDestroy()
        {
            GraphTree.Dispose();
            GraphHelp.Dispose();
            GraphDebug.Dispose();
            GraphTopBar.Dispose();
            GraphCreate.Dispose();
            GraphQuickSearch.Dispose();
            GraphPreferences.Dispose();
            TreeDebug.Dispose();
            TreeChart.Dispose();
            Define.Dispose();
            AIDesignerLuaEnv.Dispose();
        }

        public void OnEnable()
        {
        }

        public void OnFocus()
        {
        }

        public void Update()
        {
            if (!EditorApplication.isPlaying || null == Instance || null == TreeChart.Instance.CurrTree ||
                null == TreeChart.Instance.CurrTree.RuntimeTree)
            {
                return;
            }

            Repaint();
        }

        public void OnGUI()
        {
            if (null == Instance)
            {
                Open();
            }

            var width = position.width;
            var height = position.height + 22f;
            if (ScreenSizeWidth != width || ScreenSizeHeight != height)
            {
                ScreenSizeWidth = width;
                ScreenSizeHeight = height;
                ScreenSizeChange = true;
            }
            else if (InspectorSplitView.Resizing)
            {
                ScreenSizeChange = true;
            }
            else
            {
                ScreenSizeChange = false;
            }

            GraphTree.Instance.OnGUI(); // inspector+graph
            GraphHelp.Instance.OnGUI(); // 弹窗
            GraphDebug.Instance.OnGUI(); // graph底栏播放
            GraphTopBar.Instance.OnGUI(); // 全局顶栏
            GraphCreate.Instance.OnGUI(); // 未知
            GraphQuickSearch.Instance.OnGUI(); // 弹窗
            GraphPreferences.Instance.OnGUI(); // 弹窗

            // GraphChart拖拽宽度支持
            InspectorSplitView.BeginSplitView();
            InspectorSplitView.Split();
            InspectorSplitView.EndSplitView();

            GraphTree.Instance.OnEvent(); // inspector+graph事件处理

            LateUpdate?.Invoke(null, null);
            LateUpdate = null;
        }

        [OnOpenAsset(1)]
        private static bool OpenToEdit(int insID, int line)
        {
            var obj = EditorUtility.InstanceIDToObject(insID);
            if (null == obj)
            {
                return false;
            }

            var path = AssetDatabase.GetAssetPath(obj);
            if (string.IsNullOrEmpty(path))
            {
                return false;
            }

            return OpenWithPath(path);
        }
    }
}