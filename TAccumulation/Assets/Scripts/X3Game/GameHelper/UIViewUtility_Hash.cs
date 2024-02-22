using PapeGames.X3UI;

namespace X3Game
{
    public static partial class UIViewUtility
    {
        #region Open & Close Hash

        public static void Open(uint viewTagHash, bool withAnim, params object[] data)
        {
            Init();
            var viewTag = UISystemHelper.HashToString(viewTagHash);
            var viewInfo = GetViewInfo(viewTag);
            Open(viewTag, viewInfo, withAnim, data);
        }

        public static void Open(uint viewTagHash, bool withAnim)
        {
            Init();
            var viewTag = UISystemHelper.HashToString(viewTagHash);
            var viewInfo = GetViewInfo(viewTag);
            Open(viewTag, viewInfo, withAnim);
        }

        public static void OpenAs_Hash(uint viewTagHash, UIViewType viewType, int panelOrder,
            AutoCloseMode autoCloseMode,
            bool maskVisible, bool fullScreen, bool focusable, UIBlurType blurType, bool withAnim)
        {
            Init();
            var viewTag = UISystemHelper.HashToString(viewTagHash);
            OpenAs(viewTag, viewType, panelOrder, autoCloseMode, maskVisible, fullScreen, focusable, blurType,
                withAnim);
        }

        public static void Close_Hash(uint viewTagHash, bool withAnim = true)
        {
            Init();
            var viewTag = UISystemHelper.HashToString(viewTagHash);
            UIMgr.Instance.Close(viewTag, withAnim);
        }

        #endregion

        #region QueryHash

        public static bool IsOpened_Hash(uint viewTagHash)
        {
            Init();
            var viewTag = UISystemHelper.HashToString(viewTagHash);
            return UIMgr.Instance.IsOpened(viewTag);
        }

        public static bool IsOpened_Hash(uint viewTagHash, bool includeToOpen = true)
        {
            Init();
            var viewTag = UISystemHelper.HashToString(viewTagHash);
            return UIMgr.Instance.IsOpened(viewTag,includeToOpen);
        }

        public static bool IsInHistory(uint viewTagHash)
        {
            Init();
            var viewTag = UISystemHelper.HashToString(viewTagHash);
            return UIMgr.Instance.IsInHistory(viewTag);
        }

        public static bool IsFocused(uint viewTagHash)
        {
            Init();
            var viewTag = UISystemHelper.HashToString(viewTagHash);
            return UIMgr.Instance.IsFocused(viewTag);
        }

        public static bool IsVisible(uint viewTagHash)
        {
            Init();
            var viewTag = UISystemHelper.HashToString(viewTagHash);
            return UIMgr.Instance.IsVisible(viewTag);
        }

        public static bool IsOnTop(uint viewTagHash)
        {
            Init();
            var viewTag = UISystemHelper.HashToString(viewTagHash);
            return UIMgr.Instance.IsOnTop(viewTag);
        }

        #endregion
    }
}