using System.Diagnostics.Eventing.Reader;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.UI;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    public class X3RectCrop : MonoBehaviour
    {
        /// <summary>
        /// 背景RECTTRANS
        /// </summary>
        public RectTransform BackgroundRectTrans;

        /// <summary>
        /// 裁剪区RECTTRANS
        /// </summary>
        public RectTransform CropRectTrans;

        /// <summary>
        /// 裁剪框的RECT
        /// </summary>
        private Rect CropRect;

        /// <summary>
        /// 背景的RECT
        /// </summary>
        private Rect BackgroundRect;

        /// <summary>
        /// 背景可以移动的范围
        /// </summary>
        private Rect BackgroundLimitRect = new Rect();


        /// <summary>
        /// 背景RECT最大缩放倍数
        /// </summary>
        public float BackgroundRectMaxScale = 10f;

        /// <summary>
        /// 背景RECT最小缩放系数
        /// </summary>
        public float BackgroundRectMinScale = 0.5f;

        //用于部分操作的预设轴点
        private Vector2 m_BasePivot = new Vector2(0.5f, 0.5f);

        /// <summary>
        /// 裁剪区域中心在背景坐标系下的偏移
        /// </summary>
        private Vector2 m_CropRectOffset = Vector2.zero;

        /// <summary>
        /// 是否使用边缘来限制
        /// </summary>
        private bool m_BoderLimit = false;
        
        //是否使用圆形来限制
        private bool m_CircleLimit = false;


        #region 拓展所需，当前版本不需要

        /*
        /// <summary>
        /// 裁剪区域最大尺寸
        /// </summary>
        public Vector2 CropRectMaxSize;

        private Vector2 m_cropRectSize;
        private Vector2 m_backgroundSize = Vector2.one;
        /// <summary>
        /// 裁剪区域最小边框大小
        /// </summary>
        public int CropRectMinBounds = 0;
                 /// <summary>
        /// 最小缩放时的偏移（用于保证尺寸大于裁剪区域）
        /// </summary>
        public float MinBackgroundOffset = 0f;
        private Vector2 m_HalfBackgroundSize = Vector2.one;
        //背景缩放尺寸
        private Vector3 m_BackgroundScale = Vector3.one;
        /// <summary>
        /// 背景自动scale的等待时间
        /// </summary>
        // private float m_curWaitScaleTime = -1;
        //
        // private bool m_readyScale = false;

        // private float m_autoScaleValue;
        // private Vector2 m_autoScalePivot;
        // private Vector3 m_autoScalePos;
        //
        // private const float WAIT_SCALE_TIME = 1;
        private enum Corner
        {
            BottomLeft = 0,
            BottomRight = 1,
            TopLeft = 2,
            TopRight = 3
        }
        */

        #endregion

        /// <summary>
        /// 传入裁剪区域中心在背景坐标系下的偏移
        /// </summary>
        /// <param name="cropRectOffset"></param>
        public void Init(Vector2 cropRectOffset, bool boderLimit = true, bool circleLimit = false)
        {
            m_CropRectOffset = cropRectOffset;
            m_BoderLimit = boderLimit;
            m_CircleLimit = circleLimit;
            // s.sprite.texture
            // Texture2D test = null;
            // test.width = 100;
            // Debug.LogError($"m_CropRectOffset {m_CropRectOffset}");
        }
        
        /// <summary>
        /// 设置背景位置
        /// </summary>
        /// <param name="pos"></param>
        /// <param name="isDelta"></param>
        public void SetBackgroundRectPos(Vector2 pos, bool isDelta = true)
        {
            pos = !isDelta ? pos : pos + (Vector2)BackgroundRectTrans.localPosition;
            if (BackgroundRectTrans.pivot != m_BasePivot)
            {
                SetBackgroundRectPivot(m_BasePivot);
            }

            if (m_CircleLimit)
            {
                //判断是否在圆内
                if (Vector2.Distance(pos, BackgroundLimitRect.center) > BackgroundLimitRect.width / 2)
                {
                    Vector2 dir = pos - m_CropRectOffset;
                    dir = dir.normalized * BackgroundLimitRect.width / 2;
                    pos = BackgroundLimitRect.center + dir;
                }
            }
            else
            {
                if (pos.x > BackgroundLimitRect.xMax || pos.x < BackgroundLimitRect.xMin)
                {
                    pos.x = pos.x > BackgroundLimitRect.xMax ? BackgroundLimitRect.xMax : BackgroundLimitRect.xMin;
                }

                if (pos.y > BackgroundLimitRect.yMax || pos.y < BackgroundLimitRect.yMin)
                {
                    pos.y = pos.y > BackgroundLimitRect.yMax ? BackgroundLimitRect.yMax : BackgroundLimitRect.yMin;
                }
                
            }
            // Debug.LogError($"pos {pos}");
            BackgroundRectTrans.localPosition = pos;
        }

        public void SetBackgroundRectPosWithCenter(Vector3 pos, bool isDelta = true)
        {
            
        }

        /// <summary>
        ///  给定屏幕坐标进行背景缩放
        /// </summary>
        /// <param name="scale"></param>
        /// <param name="screenPos"></param>
        /// <param name="isDelta"></param>
        public void SetBackgroundRectScale(float scale, Vector2 screenPos, bool isDelta = false)
        {
            SetBackgroundRectScaleNew(scale, GetPivot(BackgroundRectTrans, screenPos), isDelta);
        }
 
        /// <summary>
        /// 给定轴点进行缩放
        /// </summary>
        /// <param name="scale"></param>
        /// <param name="pivot"></param>
        /// <param name="isDelta"></param>
        public void SetBackgroundRectScaleNew(float scale, Vector2 pivot, bool isDelta = false)
        {
            if (BackgroundRectTrans)
            {
                if (isDelta)
                    scale = BackgroundRectTrans.localScale.x + scale;
                scale = math.clamp(scale, BackgroundRectMinScale, BackgroundRectMaxScale);
                SetBackgroundRectPivot(pivot);
                BackgroundRectTrans.localScale = new Vector3(scale, scale, 1);
                ResetBackgroundLimitRect();
                //缩放后，按照基础pivot矫正位置
                Vector3 curPos = GetTransPosWithPivot(BackgroundRectTrans, m_BasePivot, true);
                SetBackgroundRectPos(curPos, false);
            }
        }

        //裁剪区域变化时
        public void OnCropRectSizeChange()
        {
            CropRect = CropRectTrans.rect;
            BackgroundRect = BackgroundRectTrans.rect;
            ResetBackgroundLimitRect();
        }

        /// <summary>
        /// 获取裁剪框基于背景的的RECT（Normalized）
        /// </summary>
        /// <returns></returns>
        public Rect GetCroppedRect()
        {
            if (BackgroundRectTrans.pivot != m_BasePivot)
            {
                SetBackgroundRectPivot(m_BasePivot);
            }

            Vector3 backgroundPos = BackgroundRectTrans.localPosition;
            Vector3 backgroundScale = BackgroundRectTrans.localScale;
            Rect backgroundRect = new Rect();
            backgroundRect.size = BackgroundRect.size * backgroundScale.x;
            backgroundRect.center = backgroundPos;
            
            Vector2 minPos = Rect.PointToNormalized(backgroundRect, CropRect.min + m_CropRectOffset);
            // Vector2Int minPosInt = new Vector2Int((int)minPos.x, (int)minPos.y);
            Vector2 size = CropRect.size / backgroundRect.size;
            // Vector2Int sizeInt = new Vector2Int((int)size.x, (int)size.y);
            // Debug.LogError($"test {minPos} minPosInt {minPosInt} size {size}");
            return new Rect(minPos, size);
        }

        public void SetRectPivot(RectTransform rectTrans, Vector2 pivot, bool needScale = false)
        {
            if (rectTrans.pivot != pivot)
            {
                Vector3 tempPos = GetTransPosWithPivot(rectTrans, pivot, needScale);
                // Debug.LogWarning("tempPos " + tempPos);
                rectTrans.localPosition = tempPos;
                rectTrans.pivot = pivot;
            }
        }
        
        private void Start()
        {
            CropRect = CropRectTrans.rect;
            BackgroundRect = BackgroundRectTrans.rect;
            ResetBackgroundLimitRect();

            // Debug.LogError($"CropRectTrans {CropRectTrans} {CropRect}");
            // CropRectMaxSize = CropRect.size;
            // Debug.LogError($"CropRectTrans {CropRectTrans.pivot} {CropRect.center} {CropRect}");
            // m_backgroundSize = BackgroundRectTrans.sizeDelta;
            // m_HalfBackgroundSize = m_backgroundSize / 2;
            // ResetRect();
        }
        
        /// <summary>
        /// 设置背景板轴点
        /// </summary>
        /// <param name="pivot"></param>
        private void SetBackgroundRectPivot(Vector2 pivot)
        {
            SetRectPivot(BackgroundRectTrans, pivot, true);
        }

        /// <summary>
        /// 屏幕坐标转pivot
        /// </summary>
        /// <param name="rectTrans"></param>
        /// <param name="screenPos"></param>
        /// <returns></returns>
        private Vector2 GetPivot(RectTransform rectTrans, Vector2 screenPos)
        {
            Vector2 inTransPos;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTrans, screenPos, UIViewUtility.GetUICamera(), out inTransPos);
            // Debug.LogError($"GetPivot {screenPos} inTransPos {inTransPos}");
            //计算点在RECTTRANS上的pivot
            Vector2 sizeDelta = rectTrans.sizeDelta * rectTrans.localScale.x;
            Vector2 basePos = -sizeDelta / 2;
            float pivotX = math.clamp((inTransPos.x - basePos.x) / sizeDelta.x, 0, 1);
            float pivotY = math.clamp((inTransPos.y - basePos.y) / sizeDelta.y, 0, 1);
            inTransPos.x = pivotX;
            inTransPos.y = pivotY;
            // Debug.LogError($"pivot {new Vector2(pivotX, pivotY)} basePos {basePos} inTransPos {inTransPos} sizeDelta {sizeDelta}");
            return inTransPos;
        }
        
        /// <summary>
        /// 填重设背景移动限制区域
        /// </summary>
        private void ResetBackgroundLimitRect()
        {
            Vector3 backgroundScale = BackgroundRectTrans.localScale;
            float realHeight = BackgroundRect.height * backgroundScale.y;
            float realWidth = BackgroundRect.width * backgroundScale.x;

            if (m_BoderLimit)
            {
                //高度限制
                if (realHeight > CropRect.height)
                {
                    BackgroundLimitRect.height = realHeight - CropRect.height;
                }
                else
                {
                    BackgroundLimitRect.height = 0;
                }

                //宽度限制
                if (realWidth > CropRect.width)
                {
                    BackgroundLimitRect.width = realWidth - CropRect.width;
                }
                else
                {
                    BackgroundLimitRect.width = 0;
                }
            }
            else
            {
                
                //高度限制
                if (realHeight > CropRect.height)
                {
                    BackgroundLimitRect.height = realHeight;
                }
                else
                {
                    BackgroundLimitRect.height = CropRect.height;
                }
                if (realWidth > CropRect.width)
                {
                    BackgroundLimitRect.width = realWidth;
                }
                else
                {
                    BackgroundLimitRect.width = CropRect.width;
                }
            }



            // var screenPoint = canvas.worldCamera.WorldToScreenpoint(obj.transform.position)

            BackgroundLimitRect.center = CropRect.center + m_CropRectOffset;

            // Debug.LogError($"BackgroundRect {BackgroundLimitRect} CropRect.height {CropRect.height} realHeight{realHeight} BackgroundRect.height {BackgroundRect.height}");
        }

        /// <summary>
        /// 给予指定的pivot获取Trans位置
        /// </summary>
        /// <param name="rectTrans"></param>
        /// <param name="pivot"></param>
        /// <param name="needScale"></param>
        /// <returns></returns>
        private Vector3 GetTransPosWithPivot(RectTransform rectTrans, Vector2 pivot, bool needScale = false)
        {
            //new的有点多，看看怎么优化
            Vector2 sizeDelta = needScale ? rectTrans.sizeDelta * rectTrans.localScale.x : rectTrans.sizeDelta;
            Vector2 baseOffset = (-sizeDelta / 2) + (rectTrans.pivot * sizeDelta);
            Vector3 basePos = rectTrans.localPosition - new Vector3(baseOffset.x, baseOffset.y);
            Vector2 offset = (-sizeDelta / 2) + (pivot * sizeDelta);
            Vector3 posOffset = new Vector3(offset.x, offset.y, 0);
            return (basePos + posOffset);
        }

        #region 拓展功能，当前版本不需要

        /* public void SetBackgroundRectScale(float scale)
        {
           if (BackgroundRectTrans)
           {
               
               BackgroundRectTrans.localScale = CheckBackgroundScale(scale);
               ResetBackgroundLimitRect();
           }
           ResetAutoArg();
        }



        // public void SetBackgroundRectPos(Vector3 pos)
        // {
        //     BackgroundRectTrans.localPosition = pos;
        //     ResetAutoArg();
        // }

        public void SetCropRectSize(Vector2 sizeDelta)
        {
           if (CropRectTrans)
           {
               Vector2 resultSize = sizeDelta;

               if (resultSize.x < CropRectMinBounds || resultSize.x > CropRectMaxSize.x)
               {
                   resultSize.x = resultSize.x < CropRectMinBounds ? CropRectMinBounds : CropRectMaxSize.x;
               }
               if (resultSize.y < CropRectMinBounds || resultSize.y > CropRectMaxSize.y)
               {
                   resultSize.y = resultSize.y < CropRectMinBounds ? CropRectMinBounds : CropRectMaxSize.y;
               }
               CropRectTrans.sizeDelta = resultSize;
           }
        }

        public void SetCropRectPivot(Vector2 pivot)
        {
           SetRectPivot(CropRectTrans, pivot);
        }



        public void CheckBackgroundRect()
        {
           // CheckRectContains(CropRectTrans, BackgroundRectTrans);
        }

        //矩形相交检测 + 点检测
        // private void CheckRectContains(RectTransform container, RectTransform item)
        // {
        //     Vector2 containerCenter = container.anchoredPosition;
        //     Vector2 itemCenter = item.anchoredPosition;
        //
        //     Rect containerRect = RectTransformToScreen(container);
        //     Rect itemRect = RectTransformToScreen(item);
        //     // UnityEngine.Debug.LogError($"相交 {containerRect.Overlaps(itemRect)} {containerRect.x} {itemRect.x}");
        //     
        //     // //先判断是否相交,不相交先按四个角对齐 //to do 边对齐
        //     // UnityEngine.Debug.LogError($"相交 {containerRect.Overlaps(itemRect)} {containerRect.x} {itemRect.x}");
        //     if (!containerRect.Overlaps(itemRect))
        //     {
        //         if (itemCenter.x > containerCenter.x)
        //         {
        //             if (itemCenter.y > containerCenter.y)
        //             {
        //                 ResetBackgroundWithConer(Corner.BottomLeft, container);
        //             }else if(itemCenter.y <= containerCenter.y)
        //             {
        //                 ResetBackgroundWithConer(Corner.TopLeft, container);
        //             }
        //         }else if(itemCenter.x <= containerCenter.x)
        //         {
        //             if (itemCenter.y > containerCenter.y)
        //             {
        //                 ResetBackgroundWithConer(Corner.BottomRight, container);
        //             }else if(itemCenter.y <= containerCenter.y)
        //             {
        //                 ResetBackgroundWithConer(Corner.TopRight, container);
        //             }
        //         }
        //         Debug.LogWarning("不相交，开始重设");
        //     }
        //     //点在矩形内时
        //     else
        //     {
        //         //左下
        //         Vector2 checkPoint = new Vector2(itemRect.xMin, itemRect.yMin);
        //         if (containerRect.Contains(checkPoint))
        //         {
        //             ResetBackgroundWithConer(Corner.BottomLeft, container);
        //             return;
        //         }
        //         //右下
        //         checkPoint.x = itemRect.xMax;
        //         checkPoint.y = itemRect.yMin;
        //         if (containerRect.Contains(checkPoint))
        //         {
        //             ResetBackgroundWithConer(Corner.BottomRight, container);
        //             return;
        //         }
        //         //左上
        //         checkPoint.x = itemRect.xMin;
        //         checkPoint.y = itemRect.yMax;
        //         if (containerRect.Contains(checkPoint))
        //         {
        //             ResetBackgroundWithConer(Corner.TopLeft, container);
        //             return;
        //         }
        //         //右上
        //         checkPoint.x = itemRect.xMax;
        //         checkPoint.y = itemRect.yMax;
        //         if (containerRect.Contains(checkPoint))
        //         {
        //             ResetBackgroundWithConer(Corner.TopRight, container);
        //             return;
        //         }
        //     }
        // }

        //这里性能可以再优化
        public Rect RectTransformToScreen(RectTransform rt)
        {
           Vector3[] corners = new Vector3[4];
           corners = new Vector3[4];
           rt.GetWorldCorners(corners);
           Vector2 v0 = RectTransformUtility.WorldToScreenPoint(null, corners[0]);
           Vector2 v1 = RectTransformUtility.WorldToScreenPoint(null, corners[2]);
           Rect rect = new Rect(v0, v1 - v0);
           return rect;
        }

        // //检查矩形包含点情况。拖动结束后调用即可
        // private void CheckRectContainsPoint(RectTransform container, RectTransform item)
        // {
        //     //性能考虑，不要一次性都判断
        //     // Vector2 containerCenter = container.localPosition;
        //     Rect containerRect = container.rect;
        //     Vector2 containerCenter = container.anchoredPosition;
        //     Rect itemRect = item.rect;
        //     Vector2 itemCenter = item.anchoredPosition;
        //     
        //     float itemScale = item.transform.localScale.x;
        //     float itemHalfWidth = (itemRect.width * itemScale) / 2;
        //     float itemHalfHeight = (itemRect.height * itemScale) / 2;
        //     //默认缩放是同比例
        //     float itemBottomLeftX = itemCenter.x - itemHalfWidth;
        //     float itemBottomLeftY = itemCenter.y - itemHalfHeight;
        //     //后续更改其值，避免new
        //     Vector2 checkPoint = new Vector2(itemBottomLeftX, itemBottomLeftY);
        //     if (containerRect.Contains(checkPoint))
        //     {
        //         ResetBackgroundWithConer(Corner.BottomLeft, container);
        //     }
        //
        //
        //
        // }

        // private void ResetBackgroundWithConer(Corner cornerEnum, RectTransform container)
        // {
        //     m_curWaitScaleTime = 0;
        //     m_readyScale = true;
        //     Rect containerRect = container.rect;
        //     // Debug.LogWarning($"containerRect {containerRect} --{containerRect.x} {cornerEnum}");
        //     switch (cornerEnum)
        //     {
        //         case Corner.BottomLeft:
        //             m_autoScalePivot.x = 0;
        //             m_autoScalePivot.y = 0;
        //             m_autoScalePos.x = containerRect.xMin;
        //             m_autoScalePos.y = containerRect.yMin;
        //             break;
        //         case Corner.BottomRight:
        //             m_autoScalePivot.x = 1;
        //             m_autoScalePivot.y = 0;
        //             m_autoScalePos.x = containerRect.xMax;
        //             m_autoScalePos.y = containerRect.yMin;
        //             break;
        //         case Corner.TopLeft:
        //             m_autoScalePivot.x = 0;
        //             m_autoScalePivot.y = 1;
        //             m_autoScalePos.x = containerRect.xMin;
        //             m_autoScalePos.y = containerRect.yMax;
        //             break;
        //         case Corner.TopRight:
        //             m_autoScalePivot.x = 1;
        //             m_autoScalePivot.y = 1;
        //             m_autoScalePos.x = containerRect.xMax;
        //             m_autoScalePos.y = containerRect.yMax;
        //             break;
        //     }
        //     
        //     //缩小时要恢复大小 --临时值
        //     m_autoScaleValue = BackgroundRect.localScale.x;
        // }

        //检查背景大小
        private Vector3 CheckBackgroundScale(float scaleValue)
        {
           if (CropRectTrans)
           {
               Vector2 backgroundSize = BackgroundRectTrans.sizeDelta;
               Vector2 baseSize = CropRectTrans.sizeDelta;
               float minXBounds = (baseSize.x + MinBackgroundOffset);
               float minYBounds = (baseSize.y + MinBackgroundOffset);

               if (backgroundSize.x * scaleValue <= minXBounds)
               {
                   scaleValue = minXBounds / backgroundSize.x;
               }
               if(backgroundSize.y * scaleValue <= minYBounds)
               {
                   scaleValue = minYBounds / backgroundSize.y;
               }

               scaleValue = scaleValue > BackgroundRectMaxScale ? BackgroundRectMaxScale : scaleValue;
               m_BackgroundScale.x = scaleValue;
               m_BackgroundScale.y = scaleValue;
           }
           return m_BackgroundScale;
        }

        public void ResetRect()
        {
           if (BackgroundRectTrans)
           {
               BackgroundRectTrans.anchorMax = m_BasePivot;
               BackgroundRectTrans.anchorMin = m_BasePivot;
               BackgroundRectTrans.pivot = m_BasePivot;
               BackgroundRectTrans.localPosition = Vector3.zero;
               ;
           }
           if (CropRectTrans)
           {
               CropRectTrans.anchorMax = m_BasePivot;
               CropRectTrans.anchorMin = m_BasePivot;
               CropRectTrans.pivot = m_BasePivot;
               CropRectTrans.localPosition = Vector3.zero;
               ;
           }
        }

        private void AutoScaleBackground()
        {
           
        }

        private void ResetAutoArg()
        {
           // m_readyScale = false;
           // m_curWaitScaleTime = 0;
        }
        // */

        #endregion


        private void Update()
        {
            //暂时不清楚计时类，先简单使用帧数代替
            // if (m_readyScale)
            //     m_curWaitScaleTime += 1;
            //
            // if (m_curWaitScaleTime >= 60)
            // {
            //     ResetAutoArg();
            //     BackgroundRect.pivot = m_autoScalePivot;
            //     BackgroundRect.localPosition = m_autoScalePos;
            //     //这里等待优化，没必要new
            //     BackgroundRect.localScale = new Vector3(m_autoScaleValue, m_autoScaleValue, 1);
            // }
        }
    }
}