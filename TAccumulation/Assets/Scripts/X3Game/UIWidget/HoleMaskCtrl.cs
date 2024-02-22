using System;
using System.Collections.Generic;
using System.Configuration;
using DG.Tweening;
using DG.Tweening.Core;
using PapeGames.X3;
using UnityEngine;

namespace PapeGames.X3UI
{
    [XLua.LuaCallCSharp]
    [DisallowMultipleComponent]
    [RequireComponent(typeof(X3Image))]
    public class HoleMaskCtrl : MonoBehaviour
    {
        public float ScaleFactor = 2;
        public Ease CurveType = Ease.Linear;
        public float AnimTime = 0.3f;
        
        private Material m_holeMat = null;
        private Sequence m_tweener1 = null;
        private Sequence m_tweener2 = null;
        private Sequence m_tweener3 = null;
        private Sequence m_tweener4 = null;
        
        static int s_MaskRect1Id = Shader.PropertyToID("_MaskRect0");
        static int s_MaskRect2Id = Shader.PropertyToID("_MaskRect1");
        static int s_MaskRect3Id = Shader.PropertyToID("_MaskRect2");
        static int s_MaskRect4Id = Shader.PropertyToID("_MaskRect3");
        static int s_MaskRadiusId = Shader.PropertyToID("_MaskRadius");
        

        private void Awake()
        {
            var holeImage = GetComponent<X3Image>();
            if (holeImage)
            {
                m_holeMat = holeImage.material;
            }
        }

        public void ShowHole1(float corner, float posX, float posY, float width, float height, bool withAnim = false, float time = 1f)
        {
            if (m_holeMat == null)
            {
                return;
            }
            if (m_tweener1 != null && m_tweener1.IsPlaying())
            {
                m_tweener1.Kill();
            }
            m_holeMat.SetVector(s_MaskRect1Id, new Vector4(0, 0, 0, 0));
            if (withAnim)
            {
                var startVector = new Vector4(posX, posY, width * ScaleFactor, height * ScaleFactor);
                m_tweener1 = DOTween.Sequence()
                    .Join(DOTween.To(() => startVector, setValue =>
                    {
                        if (m_holeMat != null)
                        {
                            m_holeMat.SetVector(s_MaskRect1Id, setValue);
                        }
                    }, new Vector4(posX, posY, width, height), time))
                    .Join(DOTween.To(() => corner * ScaleFactor,
                    val =>
                    {
                        var oldVector = m_holeMat.GetVector(s_MaskRadiusId);
                        m_holeMat.SetVector(s_MaskRadiusId, new Vector4(val, oldVector.y, oldVector.z, oldVector.w));
                    }, corner, time))
                    .SetEase(CurveType)
                    .SetAutoKill(true);
            }
            else
            {
                m_holeMat.SetVector(s_MaskRect1Id, new Vector4(posX, posY, width, height));
                var oldVector = m_holeMat.GetVector(s_MaskRadiusId);
                m_holeMat.SetVector(s_MaskRadiusId, new Vector4(corner, oldVector.y, oldVector.z, oldVector.w));
            }
        }

        public void ResetHole1()
        {
            if (m_holeMat == null)
            {
                return;
            }
            m_holeMat.SetVector(s_MaskRect1Id, new Vector4(0, 0, 0, 0));
            if (m_tweener1 != null && m_tweener1.IsPlaying())
            {
                m_tweener1.Kill();
                m_tweener1 = null;
            }
        }
        
        public void ShowHole2(float corner, float posX, float posY, float width, float height, bool withAnim = false, float time = 1f)
        {
            if (m_holeMat == null)
            {
                return;
            }
            if (m_tweener2 != null && m_tweener2.IsPlaying())
            {
                m_tweener2.Kill();
            }
            m_holeMat.SetVector(s_MaskRect2Id, new Vector4(0, 0, 0, 0));
            if (withAnim)
            {
                var startVector = new Vector4(posX, posY, width * ScaleFactor, height * ScaleFactor);
                m_tweener2 = DOTween.Sequence()
                    .Join(DOTween.To(() => startVector, setValue =>
                    {
                        if (m_holeMat != null)
                        {
                            m_holeMat.SetVector(s_MaskRect2Id, setValue);
                        }
                    }, new Vector4(posX, posY, width, height), time))
                    .Join(DOTween.To(() => corner * ScaleFactor,
                        val =>
                        {
                            var oldVector = m_holeMat.GetVector(s_MaskRadiusId);
                            m_holeMat.SetVector(s_MaskRadiusId, new Vector4(oldVector.x, val, oldVector.z, oldVector.w));
                        }, corner, time))
                    .SetEase(CurveType)
                    .SetAutoKill(true);
            }
            else
            {
                m_holeMat.SetVector(s_MaskRect2Id, new Vector4(posX, posY, width, height));
                var oldVector = m_holeMat.GetVector(s_MaskRadiusId);
                m_holeMat.SetVector(s_MaskRadiusId, new Vector4(oldVector.x, corner, oldVector.z, oldVector.w));
            }
        }
        
        public void ResetHole2()
        {
            if (m_holeMat == null)
            {
                return;
            }
            m_holeMat.SetVector(s_MaskRect2Id, new Vector4(0, 0, 0, 0));
            if (m_tweener2 != null && m_tweener2.IsPlaying())
            {
                m_tweener2.Kill();
                m_tweener2 = null;
            }
        }
        
        public void ShowHole3(float corner, float posX, float posY, float width, float height, bool withAnim = false, float time = 1f)
        {
            if (m_holeMat == null)
            {
                return;
            }
            if (m_tweener3 != null && m_tweener3.IsPlaying())
            {
                m_tweener3.Kill();
            }
            m_holeMat.SetVector(s_MaskRect3Id, new Vector4(0, 0, 0, 0));
            if (withAnim)
            {
                var startVector = new Vector4(posX, posY, width * ScaleFactor, height * ScaleFactor);
                m_tweener3 = DOTween.Sequence()
                    .Join(DOTween.To(() => startVector, setValue =>
                    {
                        if (m_holeMat != null)
                        {
                            m_holeMat.SetVector(s_MaskRect3Id, setValue);
                        }
                    }, new Vector4(posX, posY, width, height), time))
                    .Join(DOTween.To(() => corner * ScaleFactor,
                        val =>
                        {
                            var oldVector = m_holeMat.GetVector(s_MaskRadiusId);
                            m_holeMat.SetVector(s_MaskRadiusId, new Vector4(oldVector.x, oldVector.y, val, oldVector.w));
                        }, corner, time))
                    .SetEase(CurveType)
                    .SetAutoKill(true);
            }
            else
            {
                m_holeMat.SetVector(s_MaskRect3Id, new Vector4(posX, posY, width, height));
                var oldVector = m_holeMat.GetVector(s_MaskRadiusId);
                m_holeMat.SetVector(s_MaskRadiusId, new Vector4(oldVector.x, oldVector.y, corner, oldVector.w));
            }
        }
        
        public void ResetHole3()
        {
            if (m_holeMat == null)
            {
                return;
            }
            m_holeMat.SetVector(s_MaskRect3Id, new Vector4(0, 0, 0, 0));
            if (m_tweener3 != null && m_tweener3.IsPlaying())
            {
                m_tweener3.Kill();
                m_tweener3 = null;
            }
        }
        
        public void ShowHole4(float corner, float posX, float posY, float width, float height, bool withAnim = false, float time = 1f)
        {
            if (m_holeMat == null)
            {
                return;
            }
            if (m_tweener4 != null && m_tweener4.IsPlaying())
            {
                m_tweener4.Kill();
            }
            m_holeMat.SetVector(s_MaskRect4Id, new Vector4(0, 0, 0, 0));
            if (withAnim)
            {
                
                var startVector = new Vector4(posX, posY, width * ScaleFactor, height * ScaleFactor);
                m_tweener4 = DOTween.Sequence()
                    .Join(DOTween.To(() => startVector, setValue =>
                    {
                        if (m_holeMat != null)
                        {
                            m_holeMat.SetVector(s_MaskRect4Id, setValue);
                        }
                    }, new Vector4(posX, posY, width, height), time))
                    .Join(DOTween.To(() => corner * ScaleFactor,
                        val =>
                        {
                            var oldVector = m_holeMat.GetVector(s_MaskRadiusId);
                            m_holeMat.SetVector(s_MaskRadiusId, new Vector4(oldVector.x, oldVector.y, oldVector.z, val));
                        }, corner, time))
                    .SetEase(CurveType)
                    .SetAutoKill(true);
            }
            else
            {
                m_holeMat.SetVector(s_MaskRect4Id, new Vector4(posX, posY, width, height));
                var oldVector = m_holeMat.GetVector(s_MaskRadiusId);
                m_holeMat.SetVector(s_MaskRadiusId, new Vector4(oldVector.x, oldVector.y, oldVector.z, corner));
            }
        }
        
        public void ResetHole4()
        {
            if (m_holeMat == null)
            {
                return;
            }
            m_holeMat.SetVector(s_MaskRect4Id, new Vector4(0, 0, 0, 0));
            if (m_tweener4 != null && m_tweener4.IsPlaying())
            {
                m_tweener4.Kill();
                m_tweener4 = null;
            }
        }

        public void ResetAllHole()
        {
            ResetHole1();
            ResetHole2();
            ResetHole3();
            ResetHole4();
        }

        /// <summary>
        /// 根据子节点位置挖洞
        /// </summary>
        /// <param name="index">挖洞位置</param>
        /// <param name="childTransform"></param>
        /// <param name="isCircle">是否圆形，true圆， false方</param>
        public void ShowHole(int index, RectTransform childTransform, bool isCircle, bool withAnim)
        {
            if (index < 1 || index > 4 || null == childTransform)
            {
                return;
            }

            var localPos = RTUtility.ToLocalPoint(childTransform, transform as RectTransform);
            float zOffset = 0f, wOffset = 0f, ratio = 0.5f;
            var rect = childTransform.rect;
            var rectWidth = rect.width;
            var rectHeight = rect.height;
            if (isCircle)
            {
                ratio = 0.4f;
            }
            else
            {
                zOffset = Mathf.Min(10, rectWidth * 0.1f);
                wOffset = Mathf.Min(10, rectHeight * 0.1f);
            }

            var zValue = (ratio * rectWidth - zOffset); // 宽
            var wValue = (ratio * rectHeight - wOffset); // 高
            
            // 设置挖洞区域的边缘角度
            var corner = 0f;
            if (isCircle)
            {
                corner = zValue;
            }
            else
            {
                corner = Mathf.Min(4, wValue * 0.8f);
            }

            if (index == 1)
            {
                ShowHole1(corner, localPos.x, localPos.y, zValue, wValue, withAnim, AnimTime);
            }
            else if (index == 2)
            {
                ShowHole2(corner, localPos.x, localPos.y, zValue, wValue, withAnim, AnimTime);
            }
            else if (index == 3)
            {
                ShowHole3(corner, localPos.x, localPos.y, zValue, wValue, withAnim, AnimTime);
            }
            else if (index == 4)
            {
                ShowHole4(corner, localPos.x, localPos.y, zValue, wValue, withAnim, AnimTime);
            }
        }

        private void OnDestroy()
        {
            if (m_tweener1 != null && m_tweener1.IsPlaying())
            {
                m_tweener1.Kill();
                m_tweener1 = null;
            }
            if (m_tweener2 != null && m_tweener2.IsPlaying())
            {
                m_tweener2.Kill();
                m_tweener2 = null;
            }
            if (m_tweener3 != null && m_tweener3.IsPlaying())
            {
                m_tweener3.Kill();
                m_tweener3 = null;
            }
            if (m_tweener4 != null && m_tweener4.IsPlaying())
            {
                m_tweener4.Kill();
                m_tweener4 = null;
            }
        }
    }
}