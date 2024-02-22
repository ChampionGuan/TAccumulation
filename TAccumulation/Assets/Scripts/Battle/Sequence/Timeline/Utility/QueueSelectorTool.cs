#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEditor;
using Object = UnityEngine.Object;

/// <summary>
/// 编辑器下按照顺序点选的工具
/// 调用AddReadySelectObject添加对象，按照添加顺序点选
/// </summary>
public static class QueueSelectTool
{
    private static Queue<Action> _readyOperations;
    private static Action _curOperation;
    private static bool isInit = false;
    private static int timeStep = 0;
    private static int invervalFrame = 1;  // 间隔帧
    
    #region 外部接口

    // 添加一个待处理操作
    public static void AddOperation(Action operation)
    {
        Init();  
        _readyOperations.Enqueue(operation);
    }
    
    // 添加一个待select对象
    public static void AddReadySelectObject(Object obj)
    {
        Init();
        AddOperation(() =>
        {
            Selection.activeObject = obj;
        });
    }

    #endregion


    #region 内部实现

    private static void Init()
    {
        if (!isInit)
        {
            isInit = true;
            _readyOperations = new Queue<Action>();
            EditorApplication.update += Tick;
        }
    }

    private static void TrySelectionNext()
    {
        if (_readyOperations.Count > 0)
        {
            var op = _readyOperations.Dequeue();
            _curOperation = op;
            _curOperation.Invoke();
        }
    }

    private static void Tick()
    {
        if (_curOperation != null)
        {
            if (++timeStep >= invervalFrame)
            {
                _curOperation = null;
                timeStep = 0;
            }
        }
        else
        {
            TrySelectionNext();
        }
    }

    #endregion
}
#endif