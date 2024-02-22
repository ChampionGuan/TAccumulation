using UnityEngine;
using UnityEditor;

namespace AIDesigner
{
    public static class Define
    {
        public const int MeshSize = 10;
        public const float TaskWidth = 70;
        public const float TaskWithVariableWidth = 200;
        public const float TaskHeight = 50;
        public const float TaskCommentMaxWidth = 150;
        public const string RefTreeTaskName = "TreeReference";

        public static string[] TaskPath
        {
            get => CustomSettings.TaskPath;
        }

        public static string ConfigFullPath
        {
            get => CustomSettings.AISetting.ConfigFullPath;
        }

        public static string EditorConfigFullPath
        {
            get => CustomSettings.AISetting.EditorConfigFullPath;
        }

        public static string AITreeCenterPath
        {
            get => CustomSettings.AISetting.AITreeCenterPath;
        }

        private static CustomSettings _CustomSettings;

        public static CustomSettings CustomSettings
        {
            get
            {
                if (null == _CustomSettings)
                {
                    _CustomSettings =
                        AssetDatabase.LoadAssetAtPath<CustomSettings>(
                            "Assets/Editor/AIDesigner/AICustomSettings.asset");
                }

                if (null == _CustomSettings)
                {
                    Debug.LogError($"[AIDesigner][严重错误][用户自定义设置加载失败，请检查！！]");
                }

                _CustomSettings.UsedForType = AIDesignerLogicUtility.UsedForType;

                return _CustomSettings;
            }
        }

        public static void Dispose()
        {
            _CustomSettings = null;
        }
    }

    public enum ArrayType
    {
        None = -1,
        Regular = 0,
        Shared = 1,
    }

    public enum TaskType
    {
        None = -1,
        Entry = 0,
        Action = 1,
        Composite = 2,
        Condition = 3,
        Decorator = 4,
    }

    public enum TaskStateType
    {
        None = -1,
        BlockingUp = 0,
        Failure = 1,
        Success = 2,
        Running = 3,
    }

    public enum AbortType
    {
        None = 0,
        Self = 1,
        LowerPriority = 2,
        Both = 3,
    }

    public enum TaskInType
    {
        No = 0,
        Yes = 1,
    }

    public enum TaskOutType
    {
        No = 0,
        One = 1,
        Mulit = 2
    }

    public enum VarType
    {
        None = -1,
        Float = 0,
        Fix = 0,
        Int = 1,
        String = 2,
        Boolean = 3,
        Object = 4,
        Vector2 = 5,
        Vector2Int = 6,
        Vector3 = 7,
        Vector3Int = 8,
        Vector4 = 9,

        MaxCount = 10,
    }

    public enum UsedForType
    {
        System = 0,
        Logic,
    }

    public enum PrefsType
    {
        None = 0,

        TreeName = 1,
        AutoSave = 2,
        TreeMenuIndex = 3,
        TreeScrollPos = 4,
        TreeScrollZoom = 5,
        TreeScrollOffset = 6,
        ConfigPath = 7,
        EditorConfigPath = 8,
        QuickSearchTaskPanelShortcut = 9,
        TaskVariableDebug = 10,
        UsedForType = 11,
        TreeDirectory = 12,
        TaskDebugHighlighting = 13,
        TaskDebugStopAtTheLastFrame = 14,
        QuickLocateToTreeShortcut = 15,
        SaveAsJson = 16,
        ShowVariableOnTask = 17,

        MaxCount = 18
    }
}