using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;

/// <summary>
/// 这是设置字体移动的核心类
/// 执行多重行移动的核心算法是：将多重行分开依次进行处理，每一行的处理都是前面对单行处理的子操作
/// 但是由vh是记录一个文本中所有的字的顶点，所以说需要分清楚每行开始，每行结束，以及行的字个数，
/// 如此需要创建一个行的数据结构，以保存这些信息
/// </summary>
[AddComponentMenu("UI/Effects/TextSpacing")]
public class TextSpacing : BaseMeshEffect
{
    public float spacing = 0;
    public override void ModifyMesh(VertexHelper vh)
    {
        Text text = GetComponent<Text>();
        string[] ls = text.text.Split('\n');
        int length = ls.Length;
        bool isNewLine = false;
        Line[] line;
        if (string.IsNullOrEmpty(ls[ls.Length - 1]) == true)
        {
            line = new Line[length - 1];
            isNewLine = true;
        }
        else
        {
            line = new Line[length];

        }
        //Debug.Log("ls长度" + ls.Length);
        for (int i = 0; i < line.Length; i++)
        {
            if (i == 0 && line.Length == 1 && isNewLine == false)//解决单行时没有换行符的情况
            {
                line[i] = new Line(0, ls[i].Length * 6);
                break;
            }
            if (i == 0 && line.Length >= 1)//解决单行时有换行符的情况，以及多行时i为0的情况
            {
                line[i] = new Line(0, (ls[i].Length + 1) * 6);
            }
            else
            {
                if (i < line.Length - 1)
                {
                    line[i] = new Line(line[i - 1].EndVertexIndex + 1, (ls[i].Length + 1) * 6);
                }
                else
                {
                    if (isNewLine == true)//解决多行时，最后一行末尾有换行符的情况
                    {
                        line[i] = new Line(line[i - 1].EndVertexIndex + 1, (ls[i].Length + 1) * 6);
                    }
                    else
                    {
                        line[i] = new Line(line[i - 1].EndVertexIndex + 1, ls[i].Length * 6);
                    }
                }
            }
        }


        List<UIVertex> vertexs = new List<UIVertex>();
        vh.GetUIVertexStream(vertexs);
        int countVertexIndex = vertexs.Count;
        //Debug.Log("顶点总量" + vertexs.Count);
        for (int i = 0; i < line.Length; i++)
        {
            if (line[i].CountVertexIndex == 6) { continue; }
            for (int k = line[i].StartVertexIndex + 6; k <= line[i].EndVertexIndex; k++)
            {
                UIVertex vertex = vertexs[k];
                vertex.position += new Vector3(spacing * ((k - line[i].StartVertexIndex) / 6), 0, 0);
                //Debug.Log("执行");
                vertexs[k] = vertex;
                if (k % 6 <= 2)
                {
                    vh.SetUIVertex(vertex, (k / 6) * 4 + k % 6);
                }
                if (k % 6 == 4)
                {
                    vh.SetUIVertex(vertex, (k / 6) * 4 + k % 6 - 1);
                }
            }

        }


    }
}

internal class Line
{
    //每行开始顶点索引
    private int startVertexIndex;
    public int StartVertexIndex
    {
        get
        {
            return startVertexIndex;
        }
    }

    //每行结束顶点索引
    private int endVertexIndex;
    public int EndVertexIndex
    {
        get
        {
            return endVertexIndex;
        }
    }

    //每行顶点总量
    private int countVertexIndex;
    public int CountVertexIndex
    {
        get
        {
            return countVertexIndex;
        }
    }

    public Line(int startVertexIndex, int countVertexIndex)
    {
        this.startVertexIndex = startVertexIndex;
        this.countVertexIndex = countVertexIndex;
        this.endVertexIndex = this.startVertexIndex + countVertexIndex - 1;

    }
}