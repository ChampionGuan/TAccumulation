using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PapeGames.X3UI;

public class UIDrawBezierSpline : MonoBehaviour
{
    [SerializeField] private BezierCurve3D m_Curve3D;
    [SerializeField] private X3Game.X3SplineDrawerMesh m_X3Spline;
    [SerializeField] private Vector2 m_LineRotationParam = Vector2.zero;    // 仅做序列化数据使用，方便调整
    private List<BezierPoint3D> m_SourceBezierPoints;
    private List<Vector3> m_Points = new List<Vector3>();
    private List<Vector3> m_BackPoints;
    private List<Vector3> m_DrawLinesPostions = new List<Vector3>();
    private Coroutine m_Coroutine;
    private Coroutine m_Coroutine2;
    private void Start()
    {
        if (m_Curve3D != null)
        {
            m_SourceBezierPoints = m_Curve3D.KeyPoints;
            // SetDrawLinesPostions();
            // m_X3Spline.DrawSpline(GetDrawLinesPositions2(m_DrawLinesPostions));
            // m_Coroutine = StartCoroutine(HandleCheckBezierPoint());
            // m_Coroutine2 = StartCoroutine(WaitThenFunc(UpdataSplineAmplitudeAnim_BezierPoints, m_DefaultCheckTime));
            
            m_Points = m_Curve3D.GetCurvePoints_LocalPosition();
            m_BackPoints = m_Points;
            m_BackPoints.RemoveAt(0);
            m_X3Spline.DrawSpline(GetDrawLinesPositions2(m_BackPoints));
            m_Coroutine = StartCoroutine(HandleCheckBezierPoint());
            m_Coroutine2 = StartCoroutine(WaitThenFunc(UpdateSplineAnim_AllCalculatePoints, m_DefaultCheckTime));
            
        }
    }

    private void OnEnable()
    {
        m_Coroutine = StartCoroutine(HandleCheckBezierPoint());
        // m_Coroutine2 = StartCoroutine(WaitThenFunc(UpdataSplineAmplitudeAnim_BezierPoints, m_DefaultCheckTime));
        m_Coroutine2 = StartCoroutine(WaitThenFunc(UpdateSplineAnim_AllCalculatePoints, m_DefaultCheckTime));
        
    }

    public Vector2 LineParam1
    {
        set
        {
            m_LineRotationParam = value;
        }
        get
        {
            return m_LineRotationParam;
        }
    }
    
    #region 提供X3SplineDrawer绘制样条的节点Positions

    public bool SetDrawLinesPostions()
    {
        if (m_SourceBezierPoints.Count > 0)
        {
            for (int i = 0; i < m_SourceBezierPoints.Count; i++)
            {
                var node = m_SourceBezierPoints[i];
                if (i != 0) m_DrawLinesPostions.Add(node.LeftHandleLocalPosition + node.LocalPosition);
                m_DrawLinesPostions.Add(node.LocalPosition);
                if (i != m_SourceBezierPoints.Count - 1)
                    m_DrawLinesPostions.Add(node.RightHandleLocalPosition + node.LocalPosition);
            }
            return true;
        }
        return false;
    }
    
    private void UpdataSplineAmplitudeAnim_BezierPoints()
    {
        if (!m_IsOnPlayAnim) return;
        m_AnimProgress += Time.deltaTime * m_AnimScale;
        m_AnimProgress %= 1f;
        int offset = m_Curve3D.GetCurBezierPointIdxThisTime(m_AnimProgress);
        List<BezierPoint3D> newPoints = m_SourceBezierPoints;
        m_CurrentOffset = offset;
        
        List<Vector3> resultPostions = new List<Vector3>();
        for (int i = 0; i < newPoints.Count; i++)
        {
            BezierPoint3D node = newPoints[i];
            Vector3 tmpOriginPos = Vector3.zero;
            tmpOriginPos = (node.LocalPosition + (m_MoveDelta) * node.RawMoveVector);
            // tmpOriginPos = node.LocalPosition;
            if (i != 0)
                resultPostions.Add(node.LeftHandleLocalPosition + tmpOriginPos);
            resultPostions.Add(tmpOriginPos);
            if (i != newPoints.Count - 1)
                resultPostions.Add(node.RightHandleLocalPosition + tmpOriginPos);
        }

        for (int i = 0; i < resultPostions.Count; i++)
        {
            m_X3Spline.UpdateControlPoint(i, resultPostions[i]);
        }
    }
    
    public List<Vector2> GetDrawLinesPositions2(List<Vector3> vec3s)
    {
        List<Vector2> result = new List<Vector2>(vec3s.Count);
        for (int i = 0; i < vec3s.Count; i++)
        {
            result.Add(new Vector2(vec3s[i].x, vec3s[i].y));   
        }
        return result;
    }

    #endregion
    
    #region 测试单点的方向位移
    [Range(-1f, 1f)] [SerializeField] private float m_MoveDelta = 0f;

    public float SetWavePeak
    {
        set
        {
            float param = Mathf.Clamp(value, -1f, 1f);
            m_MoveDelta = param;
        }
    }

    [SerializeField] private bool m_SetSourceLocalPosition = false;
    public void SetKeyPointsMovePos()
    {
        if (!m_SetSourceLocalPosition)
        {
            if (m_SourceBezierPoints.Count > 0)
            {
                foreach (var point in m_SourceBezierPoints)
                {
                    float dis = point.RawMoveVector.magnitude;
                    point.LocalPosition = point.sourcePostion + new Vector3(
                        point.RawMoveVector.x * m_MoveDelta,
                        point.RawMoveVector.y * m_MoveDelta,
                        0f);
                }
            }
        }
    }

    #endregion
    
    #region 测试KeyPoint随时间的进动

    [SerializeField] private bool m_IsReverse = false;
    [SerializeField] private bool m_IsOnPlayAnim = false;
    [Range(0f, 1f)][SerializeField]  private float m_AnimProgress = 0f;
    [Range(0f, 1f)][SerializeField]  private float m_AnimScale = 0.1f;
    [SerializeField] private int m_CurrentOffset = 0;
    private void UpdateSplineAnim_AllCalculatePoints()
    {
        if (!m_IsOnPlayAnim) return;
        List<Vector3> remain = new List<Vector3>();
        List<Vector3> newPoints = new List<Vector3>();
        m_AnimProgress += Time.deltaTime * m_AnimScale;
        m_AnimProgress %= 1f;
        m_Points = m_Curve3D.GetCurvePoints_LocalPosition();
        int offset = m_Curve3D.GetCurPointIdxThisTime(m_AnimProgress);
        m_CurrentOffset = offset;
        Vector3 deltaV = m_Points[0] - m_Points[m_Points.Count - 1];
        if (m_IsReverse)
        {
            m_Points.Reverse();
            deltaV = m_Points[0] - m_Points[m_Points.Count - 1];
        }
        Vector3 deltaS = deltaV * m_AnimProgress;
        for (int i = 0; i < m_Points.Count; i++)
        {
            if (i <= offset)
            {
                remain.Add(m_Points[i] - (1f - m_AnimProgress) * deltaV);
            }
            else
            {
                newPoints.Add(m_Points[i] + deltaS);
            }
        }
        remain.RemoveAt(0);
        newPoints.AddRange(remain);
        for (int i = 0; i < newPoints.Count; i++)
        {
            m_X3Spline.UpdateControlPoint(i, new Vector2(newPoints[i].x, newPoints[i].y));
        }
        
    }
    #endregion

    #region 检查BezierPoint变换状态

    [Range(0.2f, 0.01f)] [SerializeField] private float m_DefaultCheckTime = 0.05f;

    private IEnumerator HandleCheckBezierPoint()
    {
        yield return new WaitForSeconds(m_DefaultCheckTime);
        SetKeyPointsMovePos(); // MoveVector 参数
        if (m_Coroutine != null)
        {
            StopCoroutine(m_Coroutine);
            m_Coroutine = null;
        }
        m_Coroutine = StartCoroutine(HandleCheckBezierPoint());
    }
    #endregion
    
    public IEnumerator WaitThenFunc(Action action, float seconds = 0.1f)
    {
        yield return new WaitForSeconds(seconds);
        action?.Invoke();
        if (m_Coroutine2 != null)
        {
            StopCoroutine(m_Coroutine2);
            m_Coroutine2 = null;
        }
        // m_Coroutine2 = StartCoroutine(WaitThenFunc(UpdataSplineAmplitudeAnim_BezierPoints, m_DefaultCheckTime));
        m_Coroutine2 = StartCoroutine(WaitThenFunc(UpdateSplineAnim_AllCalculatePoints, m_DefaultCheckTime));
    }
}