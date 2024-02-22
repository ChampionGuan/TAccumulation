using UnityEngine;

namespace X3Battle
{
    public static class StrategyUtil
    {
        /// <summary>
        /// 通过朝向计算角度
        /// </summary>
        /// <param name="dir"></param>
        /// <returns></returns>
        public static float CalculateAngleByDir(Vector3 dir)
        {
            float dot = Vector3.Dot(Vector3.right, dir);
            float angle = Vector3.Angle(Vector3.forward, dir);
            //角度落在了X轴的反方向区域
            if (dot < 0)
            {
                angle = 360 - angle;
            }
            return angle;
        }

        private static bool _IsDirInSector(Vector3 sectorDir1, Vector3 sectorDir2, Vector3 dir)
        {
            return Vector3.Dot(Vector3.Cross(sectorDir1, dir), Vector3.Cross(dir, sectorDir2)) > 0;
        }
        
        /// <summary>
        /// 相对于轴方向，两个方向是否同在轴的左区域或者右区域
        /// </summary>
        /// <param name="axisForward"></param>
        /// <param name="lastDir"></param>
        /// <param name="dir"></param>
        /// <param name="angle">小于90度</param>
        /// <returns></returns>
        public static bool IsTwoDirInSameArea(Vector3 axisForward, Vector3 lastDir, Vector3 dir, float angle)
        {
            if (Vector3.Dot(axisForward, lastDir) > 0 && Vector3.Dot(axisForward, dir) > 0)
            {
                Vector3 rightDir = Quaternion.AngleAxis(angle, Vector3.up) * axisForward;
                Vector3 leftDir = Quaternion.AngleAxis(-angle, Vector3.up) * axisForward;
                return _IsDirInSector(axisForward, rightDir, lastDir) && _IsDirInSector(axisForward, rightDir, dir) ||
                       _IsDirInSector(axisForward, leftDir, lastDir) && _IsDirInSector(axisForward, leftDir, dir);
            }
            return false;
        }

        public static bool CheckAngle(float downAngle, float upAngle, Vector3 center, float distance)
        {
            float angle = 0.5f * (downAngle + upAngle);
            Vector3 dir = Quaternion.AngleAxis(angle, Vector3.up) * Vector3.forward;
            Vector3 pos = center + distance * dir;
            return BattleUtil.IsInNavMesh(pos) && !BattleUtil.IsFindAirWall(center, dir, distance);
        }
        
        /// <summary>
        /// 相对于轴方向，两个方向是否同在轴的左区域或者右区域
        /// </summary>
        /// <param name="axisForward"></param>
        /// <param name="lastDir"></param>
        /// <param name="dir"></param>
        /// <param name="angle">小于90度</param>
        /// <returns></returns>
        public static bool IsTwoDirInSameArea2(Vector3 axisForward, Vector3 lastDir, Vector3 dir, float angle)
        {
            float axisAngle = CalculateAngleByDir(axisForward);
            float leftAngle = axisAngle - angle;
            float rightAngle = axisAngle + angle;
            float lastDirAngle = CalculateAngleByDir(lastDir);
            float dirAngle = CalculateAngleByDir(dir);
            if (leftAngle < 0)
            {
                leftAngle += 360;
                    
                if (lastDirAngle >= axisAngle && lastDirAngle < rightAngle && dirAngle >= axisAngle && dirAngle < rightAngle //两个方向在右边区域内
                    || (lastDirAngle < axisAngle && lastDirAngle >= 0 || lastDirAngle > leftAngle && lastDirAngle < 360) && (dirAngle < axisAngle && dirAngle >= 0 || dirAngle > leftAngle && dirAngle < 360))//两个方向在左边区域内
                {
                    return true;
                }
            }
            else if (rightAngle > 360)
            {
                rightAngle -= 360;
                if ((lastDirAngle >= axisAngle && lastDirAngle <= 360 || lastDirAngle > 0 && lastDirAngle < rightAngle) && (dirAngle >= axisAngle && dirAngle <= 360 || dirAngle > 0 && dirAngle < rightAngle)//两个方向在右边区域内
                    || lastDirAngle < axisAngle && lastDirAngle > leftAngle && dirAngle < axisAngle && dirAngle > leftAngle)//两个方向在左边区域内
                {
                    return true;
                }
            }
            else
            {
                if (lastDirAngle >= axisAngle && lastDirAngle < rightAngle && dirAngle >= axisAngle && dirAngle < rightAngle//两个方向在右边区域内
                    || lastDirAngle < axisAngle && lastDirAngle > leftAngle && dirAngle < axisAngle && dirAngle > leftAngle)//两个方向在左边区域内
                {
                    return true;
                }
            }
            return false;
        }
    }
}