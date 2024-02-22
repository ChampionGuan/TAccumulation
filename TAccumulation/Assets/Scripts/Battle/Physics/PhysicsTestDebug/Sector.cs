using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer), typeof(MeshFilter))]
public class Sector : MonoBehaviour
{
    public float Radius = 6; //外半径  
    public float angleDegree = 360; //扇形或扇面的角度
    public int Segments = 2; //分割数  
    private MeshFilter meshFilter;

    void OnEnable()
    {
        UpdateShape();
    }

    public void SetAngle(float value)
    {
        angleDegree = value;
        UpdateShape();
    }
    
    public void SetRadius(float value)
    {
        Radius = value;
        UpdateShape();
    }
    void UpdateShape()
    {
        meshFilter = GetComponent<MeshFilter>();
        meshFilter.mesh = CreateMesh(Radius, angleDegree, Segments);
    }

    Mesh CreateMesh(float radius, float angledegree, int segments)
    {
        //vertices(顶点):
        int vertices_count = segments + 2; //因为vertices(顶点)的个数与triangles（索引三角形顶点数）必须匹配
        Vector3[] vertices = new Vector3[vertices_count];
        float angleRad = Mathf.Deg2Rad * angledegree;
        float angleStart = -angleRad / 2; // 扇形开始角度
        float endStart = angleRad / 2; // 扇形结束角度
        float angleCur = endStart;
        float angledelta = angleRad / segments;

        vertices[0] = Vector3.zero;
        for (int i = 1; i < vertices_count; i++)
        {
            float cosA = Mathf.Cos(angleCur);
            float sinA = Mathf.Sin(angleCur);
            vertices[i] = new Vector3(radius * cosA, 0, radius * sinA);
            angleCur -= angledelta; // 顺时针绘制
        }

        //triangles:
        int triangle_count = segments * 3;
        int[] triangles = new int[triangle_count];
        int verticalIndex = 1;
        for (int i = 0; i < triangle_count; i += 3)
        {
            triangles[i] = 0;
            triangles[i + 1] = verticalIndex;
            triangles[i + 2] = verticalIndex + 1;
            verticalIndex++;
        }

        //uv:
        Vector2[] uvs = new Vector2[vertices_count];
        for (int i = 0; i < vertices_count; i++)
        {
            uvs[i] = new Vector2(vertices[i].x / radius / 2 + 0.5f, vertices[i].z / radius / 2 + 0.5f);
        }

        //负载属性与mesh
        Mesh mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uvs;
        return mesh;
    }
}