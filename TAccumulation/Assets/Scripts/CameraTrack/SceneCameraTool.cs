using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SceneCameraTool : MonoBehaviour
{
#if UNITY_EDITOR
    // Start is called before the first frame update

    [HideInInspector]
    public CameraTrace m_cameraCtrl;

    public Transform m_followTgt;
    public Transform m_lookAtTgt;

    private Transform m_mainCameraT;
    private Transform m_mainCameraP;

    [ContextMenu("执行")]
    public void Execute()
    {
        Finish();

        if (null != Camera.main)
        {
            m_mainCameraT = Camera.main.transform;
            m_mainCameraP = m_mainCameraT.parent;
        }
        else
        {
            m_mainCameraT = null;
        }

        if (null == m_cameraCtrl)
        {
            CameraTrace[] traces = Resources.FindObjectsOfTypeAll<CameraTrace>();
            foreach (var trace in traces)
            {
                if (trace.gameObject.scene.name == UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene().name)
                {
                    if (null == m_cameraCtrl)
                    {
                        m_cameraCtrl = trace;
                    }
                    else
                    {
                        GameObject.DestroyImmediate(trace.gameObject);
                    }
                }
            }

            if (null == m_cameraCtrl)
            {
                GameObject go = null; // PapeGames.X3.Res.LoadGameObject("Assets/ResourcesWorkspace/Battle/Misc/CameraTrace.prefab");
                if (null != go)
                {
                    m_cameraCtrl = go.GetComponent<CameraTrace>();
                    m_cameraCtrl.Init();
                }
            }

            if (null != m_cameraCtrl)
            {
                m_cameraCtrl.Enter();
                m_cameraCtrl.transform.parent = transform;
            }
        }
        UnityEditor.EditorApplication.update += Tick;
    }

    [ContextMenu("停止/结束")]
    public void Finish()
    {
        UnityEditor.EditorApplication.update -= Tick;
        if (null != m_mainCameraT)
        {
            m_mainCameraT.transform.parent = m_mainCameraP;
        }
        if (null != m_cameraCtrl)
        {
            GameObject.DestroyImmediate(m_cameraCtrl.gameObject);
        }
        m_cameraCtrl = null;
    }

    private void Tick()
    {
        if (Application.isPlaying)
        {
            return;
        }
        
        if (null == m_cameraCtrl)
        {
            return;
        }
        if (m_followTgt != m_cameraCtrl.FollowTgt)
        {
            m_cameraCtrl.SetFollowTgt(new CameraTrace.CTarget.CTgtArg(m_followTgt, m_followTgt, Vector2.zero), null, false);
        }
        if (m_lookAtTgt != m_cameraCtrl.LookAtTgt)
        {
            m_cameraCtrl.SetLookAtTgt(new CameraTrace.CTarget.CTgtArg(m_lookAtTgt, m_lookAtTgt, Vector2.zero), null, false, CameraTrace.ECamMode.Trace);
        }
        m_cameraCtrl.Tick();
    }
#endif
}
