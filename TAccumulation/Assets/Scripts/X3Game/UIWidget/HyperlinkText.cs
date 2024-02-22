using System;
using PapeGames.X3;
using PapeGames.X3UI;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;

namespace X3Game
{
    public class HyperlinkText : MonoBehaviour,IPointerClickHandler,IPointerDownHandler
    {
        TextMeshProUGUI m_Text;

        private void OnEnable()
        {
            if (m_Text == null)
            {
                m_Text = GetComponent<TextMeshProUGUI>();
            }
        }

        public void OnPointerDown(PointerEventData eventData)
        {
            
        }
        public void OnPointerClick(PointerEventData eventData)
        {
            Vector3 pos = new Vector3(eventData.position.x, eventData.position.y, 0);
            int linkIndex = TMP_TextUtilities.FindIntersectingLink(m_Text, pos, UIViewUtility.GetUICamera());
            if(linkIndex > -1)
            {
                TMP_LinkInfo linkInfo = m_Text.textInfo.linkInfo[linkIndex];
                OpenUrl(linkInfo.GetLinkID());
            }
        }

        void OpenUrl(string url)
        {
            X3Lua.X3LuaGameDelegate.OnOpenUrl(url, true);
        }
    }
}