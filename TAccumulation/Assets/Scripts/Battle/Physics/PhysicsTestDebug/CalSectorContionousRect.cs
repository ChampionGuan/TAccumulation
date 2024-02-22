using UnityEngine;

[ExecuteInEditMode]
public class CalSectorContionousRect : MonoBehaviour
{

    public Transform PreFrameSector;
    public Transform CurrentFrameSector;
    private Sector m_Sector;
    public Vector3 CurWorldPos;
    
    private void Update()
    {
        if (!PreFrameSector || !CurrentFrameSector)
        {
            return;
        }

        if (!m_Sector)
        {
            m_Sector = transform.root.GetComponentInChildren<Sector>();
            if (!m_Sector)
            {
                return;
            }
        }

        float radius = m_Sector.Radius;
        float angle = m_Sector.angleDegree;
        
        Vector3 moveVec = CurrentFrameSector.position - PreFrameSector.position;
        float moveDis = moveVec.magnitude;
        float dis = radius * Mathf.Cos(angle * 0.5f * Mathf.Deg2Rad) + moveDis * 0.5f;
        CurWorldPos = PreFrameSector.position + dis * moveVec.normalized;
        CurWorldPos.y = 0.5f;
        // x 轴
        float rectWidth = radius * Mathf.Sin(angle * 0.5f* Mathf.Deg2Rad) * 2;
        // z 轴
        float rectLen = moveDis;
        transform.position = CurWorldPos;
        transform.localScale = new Vector3(rectWidth, 1, rectLen);
    }
}
