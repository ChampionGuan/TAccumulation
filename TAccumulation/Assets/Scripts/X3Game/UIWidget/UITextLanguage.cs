using PapeGames.X3UI;
using UnityEngine;

namespace X3Game
{
    [DisallowMultipleComponent]
    public partial class UITextLanguage : MonoBehaviour, IUIComponent, IUILocaleComponent
    {
        /// <summary>
        /// </summary>
        public int languageId;

        private bool m_IsExecuted;

        /// <summary>
        ///     设置是否有效
        ///     此方法用来在UITextLanguage之前设置Text文本，避免前面对文本的设置被重新覆盖
        /// </summary>
        public bool IsValid
        {
            set => m_IsExecuted = value;
        }

        /// <summary>
        /// </summary>
        // Use this for initialization
        private void OnEnable()
        {
            if (m_IsExecuted)
                return;
            UIUtility.SetText(transform, languageId);
            m_IsExecuted = true;
        }

        public void ResetStatus()
        {
            m_IsExecuted = false;
        }

        /// <summary>
        ///     切换语言刷新接口
        /// </summary>
        public void RefreshUIsForLangChanging()
        {
            UIUtility.SetText(transform, languageId);
        }
    }
}