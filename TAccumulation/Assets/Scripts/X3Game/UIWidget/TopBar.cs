using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace X3Game
{
    [LuaCallCSharp]
    [DisallowMultipleComponent]
    [ExecuteInEditMode]
    [AddComponentMenu("X3UI/Comp/TopBar")]
    [HelpURL("https://papergames.feishu.cn/docx/YaYOdiz7PoKihqxKsZAcU2Apn7b")]
    public class TopBar : MonoBehaviour
    {
        public enum StyleType
        {
            Style_1 = 0,
            Style_2 = 1,
            Style_3 = 2,
            Style_4 = 3,
        }
        
        [SerializeField]
        private StyleType m_styleType = StyleType.Style_1;

        public int styleIdx
        {
            get => (int)m_styleType;
        }
    }
}
