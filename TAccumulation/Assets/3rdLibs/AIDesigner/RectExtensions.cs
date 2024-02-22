using System.Linq;
using UnityEngine;

namespace AIDesigner
{
    public static class RectExtensions
    {
        public static Vector2 TopLeft(this Rect rect)
        {
            return new Vector2(rect.xMin, rect.yMin);
        }

        public static Vector2 TopCenter(this Rect rect)
        {
            return new Vector2(rect.center.x, rect.y);
        }

        public static Rect ScaleSizeBy(this Rect rect, float scale)
        {
            return rect.ScaleSizeBy(scale, rect.center);
        }

        public static Rect ScaleSizeBy(this Rect rect, float scale, Vector2 pivotPoint)
        {
            var result = rect;
            result.x = result.x - pivotPoint.x;
            result.y = result.y - pivotPoint.y;
            result.xMin = result.xMin * scale;
            result.xMax = result.xMax * scale;
            result.yMin = result.yMin * scale;
            result.yMax = result.yMax * scale;
            result.x = result.x + pivotPoint.x;
            result.y = result.y + pivotPoint.y;
            return result;
        }


        /// <summary>
        /// 得到所有Rect的最小外接矩形
        /// </summary>
        /// <param name="rects"></param>
        /// <returns></returns>
        public static Rect GetBoundingRect(params Rect[] rects)
        {
            var xMin = Mathf.Min(rects.Select(r => r.xMin).ToArray());
            var xMax = Mathf.Max(rects.Select(r => r.xMax).ToArray());
            var yMin = Mathf.Min(rects.Select(r => r.yMin).ToArray());
            var yMax = Mathf.Max(rects.Select(r => r.yMax).ToArray());
            return Rect.MinMaxRect(xMin, yMin, xMax, yMax);
        }
    }
}