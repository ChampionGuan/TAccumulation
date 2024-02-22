using UnityEngine;
using UnityEngine.Serialization;
using X3Battle;

/// <summary>
/// 绘制 扇形，环形，扇环
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer), typeof(MeshFilter))]
public class AnnularSector : MonoBehaviour
{
    public float OuterRadius = 6; //外半径  
    public float InnerRadius = 3; //外半径  
    public float Height = 3; //高度  
    public float angleDegree = 360; //扇形或扇面的角度
    public int Segments = 2; //分割数  
    private MeshFilter meshFilter;

    void OnEnable()
    {
        UpdateShape();
    }
    
    public void SetShape(BoundingShape shape)
    {
        angleDegree = shape.Angle;
        Height = shape.Height;
        OuterRadius = shape.Radius;
        InnerRadius = shape.Length;
        UpdateShape();
    }
    void UpdateShape()
    {
        meshFilter = GetComponent<MeshFilter>();
        meshFilter.mesh = CreateMesh(OuterRadius, InnerRadius, angleDegree, Segments);
    }

    Mesh CreateMesh(float outerRadius, float innerRadius, float angledegree, int segments)
    {
        float angleRad = Mathf.Deg2Rad * angledegree;
        float angleStart = -angleRad / 2; // 扇形开始角度
        float endStart = angleRad / 2; // 扇形结束角度
        float angledelta = angleRad / segments;

        //扇环两条弧上, 一条弧上顶点的数量
        int vertexCount = segments + 1; 
        
        // 四条弧总共的顶点数量
        Vector3[] vertex = new Vector3[vertexCount * 2 * 2];
        // 上表面两条弧的顶点
        // 大扇形弧上的顶点
        float angleCur = angleStart;
        for (int i = 0; i < vertexCount; i++)
        {
            float cosA = Mathf.Cos(angleCur);
            float sinA = Mathf.Sin(angleCur);
            vertex[i] = new Vector3(outerRadius * cosA, 0, outerRadius * sinA);
            angleCur += angledelta; // 从左到右
        }
        // 小扇形弧上的顶点
        angleCur = angleStart;
        for (int i = vertexCount; i < vertexCount * 2; i++)
        {
            float cosA = Mathf.Cos(angleCur);
            float sinA = Mathf.Sin(angleCur);
            vertex[i] = new Vector3(innerRadius * cosA, 0, innerRadius * sinA);
            angleCur += angledelta; // 从左到右
        }
        // 下表面两条弧的顶点
        for (int i = vertexCount * 2; i < vertexCount * 4 ; i++)
        {
            vertex[i] = vertex[i - vertexCount * 2] - Vector3.up * Height;
        }
        
        // 上，左，前，表面三角形数量
        int topTriangleCount = segments * 2; 
        int leftTriangleCount = 2;
        int frontTriangleCount = segments * 2;
        
        // 全部数量
        int triangleCount = (topTriangleCount + leftTriangleCount + frontTriangleCount) * 2;
        // 全部三角形顶点索引
        int[] triangles = new int[triangleCount * 3]; // 三角形顶点

        // 上， 下表面三角形，顶点索引
        int verticeIndex = 0;
        int startTriangleIndex = 0;
        for (int i = startTriangleIndex; i < topTriangleCount * 2 * 3 ; i += 12)
        {
            //上表面
            int startIndex = verticeIndex;
            // 逆时针， 第一个三角形
            triangles[i] = startIndex;
            triangles[i + 1] = vertexCount + startIndex + 1;
            triangles[i + 2] = startIndex + 1;
            // 逆时针， 第二个三角形
            triangles[i + 3] = startIndex;
            triangles[i + 4] = vertexCount + startIndex;
            triangles[i + 5] = vertexCount + startIndex + 1;
            
            // 下表面
            startIndex = verticeIndex + vertexCount * 2;
            // 顺时针， 第一个三角形
            triangles[i + 6] = startIndex;
            triangles[i + 7] = startIndex + 1;
            triangles[i + 8] = vertexCount + startIndex + 1; 
            // 顺时针， 第二个三角形
            triangles[i + 9] = startIndex;
            triangles[i + 10] = vertexCount + startIndex + 1;
            triangles[i + 11] = vertexCount + startIndex; 
            verticeIndex++;
        }
        startTriangleIndex = topTriangleCount * 2 * 3;

        // 前，后表面三角形，顶点索引
        verticeIndex = 0;
        for (int i = startTriangleIndex; i < startTriangleIndex + frontTriangleCount * 2 * 3 ; i += 12)
        {
            //前表面 ，第一条弧和第三条弧组成的面
            int startIndex = verticeIndex;
            int startVertexCount = vertexCount * 2; 
            // 顺时针， 第一个三角形
            triangles[i] = startIndex;
            triangles[i + 1] = startIndex + 1;
            triangles[i + 2] = startVertexCount + startIndex + 1; 
            // 顺时针， 第二个三角形
            triangles[i + 3] = startIndex;
            triangles[i + 4] = startVertexCount + startIndex + 1;
            triangles[i + 5] = startVertexCount + startIndex; 
            
            // 后表面， 第二条弧和第四条弧组成的面
            startIndex = verticeIndex + vertexCount;
            // 逆时针， 第一个三角形
            triangles[i + 6] = startIndex;
            triangles[i + 7] = startVertexCount + startIndex + 1; 
            triangles[i + 8] = startIndex + 1; 
            // 逆时针， 第二个三角形
            triangles[i + 9] = startIndex;
            triangles[i + 10] = startVertexCount + startIndex; 
            triangles[i + 11] = startVertexCount + startIndex + 1; 
            verticeIndex++;
        }
        startTriangleIndex += frontTriangleCount * 2 * 3;
        
        // 左，右 表面三角形，顶点索引
        verticeIndex = 0;
        for (int i = startTriangleIndex; i < startTriangleIndex + leftTriangleCount * 2 * 3 ; i += 12)
        {
            //左表面 ，四条弧的左端点组成的面
            int startIndex = verticeIndex;
            // 逆时针， 第一个三角形
            triangles[i] = startIndex;
            triangles[i + 1] = vertexCount * 3;  
            triangles[i + 2] = vertexCount;
            // 逆时针， 第二个三角形
            triangles[i + 3] = startIndex;
            triangles[i + 4] = vertexCount * 2; 
            triangles[i + 5] = vertexCount * 3; 
            
            // 右表面， 四条弧的右端点组成的面
            // 顺时针， 第一个三角形
            triangles[i + 6] = vertexCount - 1;
            triangles[i + 7] = vertexCount * 2 - 1; 
            triangles[i + 8] = vertexCount * 4 - 1;   
            // 顺时针， 第二个三角形
            triangles[i + 9] = vertexCount - 1;
            triangles[i + 10] = vertexCount * 4 - 1;  
            triangles[i + 11] = vertexCount * 3 - 1; 
            verticeIndex++;
        }

        //uv:
        // Vector2[] uvs = new Vector2[vertexCount * 2];
        // for (int i = 0; i < vertexCount; i++)
        // {
        //     uvs[i] = new Vector2(vertex[i].x / outerRadius / 2 + 0.5f, vertex[i].z / outerRadius / 2 + 0.5f);
        // }
        // for (int i = vertexCount; i < vertexCount * 2; i++)
        // {
        //     uvs[i] = new Vector2(vertex[i].x / innerRadius / 2 + 0.5f, vertex[i].z / innerRadius / 2 + 0.5f);
        // }

        //负载属性与mesh
        Mesh mesh = new Mesh();
        mesh.vertices = vertex;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();
        // mesh.uv = uvs;
        return mesh;
    }
}