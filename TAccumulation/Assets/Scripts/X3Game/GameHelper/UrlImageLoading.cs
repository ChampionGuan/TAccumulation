using System;
using PapeGames.X3;
using PapeGames.X3UI;
using UnityEngine;
using Object = UnityEngine.Object;

namespace X3Game.GameHelper
{
    [RequireComponent(typeof(X3Image))]
    public class UrlImageLoading : MonoBehaviour
    {

        void Start()
        {
            UIUtility.SetRaycastTarget(this, false);
        }

        public void RestoreParentImage()
        {
            UIUtility.SetImageEnable(this.transform.parent.gameObject, true);
        }

        public void SetParent(Object o, string imageName)
        {
            GameObject go = o as GameObject;
            if (go != null)
            {
                this.transform.SetParent(go.transform);
                gameObject.SetActive(true);
                UIUtility.SetLocalScale(this, Vector3.one);
                RectTransform parentRectTs = go.transform as RectTransform;
                if (parentRectTs != null && parentRectTs.pivot.y != 0.5f)
                {
                    float parentHeight = parentRectTs.rect.height;
                    UIUtility.SetLocalPosition(this, new Vector3(0,  parentHeight * (1 - parentRectTs.pivot.y)  + (-parentHeight / 2)));

                }
                else
                {
                    UIUtility.SetLocalPosition(this, Vector3.zero);
                }
                
                UIUtility.SetImage(this,  UISystem.LocaleDelegate?.OnGetSprite(imageName, gameObject), true);
                UIUtility.SetImageEnable(this.transform.parent.gameObject, false);
            }

        }

        public void ReadyRecycle(bool restore = true)
        {
            if (restore && transform.parent)
                RestoreParentImage();
            
            UrlImageUtil.ReadyRecycle(this, this.transform.parent);
            gameObject.SetActive(false);
        }

        
        private void OnEnable()
        {
            // UIUtility.SetImageEnable(this.transform.parent.gameObject, false);
        }

        private void OnDisable()
        {
            //存在界面隐藏再展示的情况
            // ReadyRecycle();
        }
    }
}