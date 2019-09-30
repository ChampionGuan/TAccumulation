using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraTrack : MonoBehaviour
{
    private static CameraTrack _instance;
    public static CameraTrack Instance
    {
        get
        {
            if (null == _instance)
            {
                GameObject _r = GameObject.Instantiate(Resources.Load("Prefab/[CameraTrack]")) as GameObject;
                _r.name = "[CameraTrack]";
                _r.SetActive(true);
                _instance = _r.GetComponent<CameraTrack>();

                UnityEngine.Object.DontDestroyOnLoad(_r);
            }
            return _instance;
        }
    }

    #region Lerp
    private GameObject m_rootO;
    private Transform m_rootT;
    private Transform m_follower;
    private Transform m_lookAt;
    private Transform m_dock;
    private Transform m_shake;
    private Transform m_cameraT;
    private Camera m_cameraC;

    private Transform m_followerTarget;
    private Transform m_lookAtTarget;

    private Vector3 m_followerLerp;
    private Vector3 m_dockLerp;
    private Vector3 m_lookAtLerp;
    private float m_lookAtDisLerp;

    private Vector3 m_cameraPosOffset;
    public float m_cameraPosOffsetY = 5;
    public float m_cameraPosOffsetZ = -5;

    public Camera MainCamera { get { return m_cameraC; } }
    public Vector3 CameraPosition { get { if (null != m_dock) return m_dock.position; else return Vector3.zero; } }

    private bool m_smoothLerp;
    private float m_smoothLerpV = 0;
    public float m_smoothLerpVMin = 5;
    public float m_smoothLerpVMax = 20;
    private Vector3 m_cameraNormalize;
    private Vector3 m_lookAtNormalize;

    void Awake()
    {
        m_rootO = gameObject;
        m_rootT = transform;
        m_follower = m_rootT.Find("Follow");
        m_lookAt = m_follower.Find("LookAt");
        m_dock = m_follower.Find("Dock");
        m_shake = m_dock.Find("Shake");
        m_cameraT = m_shake.Find("Camera");
        m_cameraC = m_cameraT.GetComponent<Camera>();
        m_cameraPosOffsetY = Mathf.Abs(m_cameraPosOffsetY) > 1 ? m_cameraPosOffsetY : 5;
        m_cameraPosOffsetZ = Mathf.Abs(m_cameraPosOffsetZ) > 1 ? m_cameraPosOffsetZ : -5;
        m_smoothLerpVMin = Mathf.Abs(m_smoothLerpVMin) > 5 ? m_smoothLerpVMin : 5;
        m_smoothLerpVMax = Mathf.Abs(m_smoothLerpVMax) > 5 ? m_smoothLerpVMax : 5;
        m_smoothLerpV = m_smoothLerpVMax;
    }
#if UNITY_EDITOR
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.PageUp))
        {
        }
        else if (Input.GetKeyDown(KeyCode.PageDown))
        {
        }
    }
#endif
    void LateUpdate()
    {
        if (null == m_lookAtTarget)
        {
            m_lookAtTarget = m_followerTarget;
        }

        if (m_smoothLerp)
        {
            m_smoothLerpV = m_smoothLerpVMin;
            m_smoothLerp = false;
        }
        m_smoothLerpV += 0.1f;
        m_smoothLerpV = m_smoothLerpV > m_smoothLerpVMax ? m_smoothLerpVMax : m_smoothLerpV;

        if (null != m_followerTarget)
        {
            m_follower.position = m_followerLerp = Vector3.Lerp(m_follower.position, m_followerTarget.position, Time.deltaTime * 20);

            // dock
            m_lookAtLerp = m_lookAtTarget.position;
            m_lookAtLerp.y = 0;
            m_dockLerp.y = 0;
            m_followerLerp.y = 0;
            m_cameraPosOffset.x = 0;
            if (m_followerTarget != m_lookAtTarget)
            {
                m_cameraNormalize = (m_lookAtLerp - m_followerLerp).normalized;
                m_cameraPosOffset = m_cameraNormalize * m_cameraPosOffsetZ;
            }
            else
            {
                m_cameraNormalize = (m_followerLerp - m_dockLerp).normalized;
                m_cameraPosOffset.z = m_cameraPosOffsetZ;
            }
            m_cameraPosOffset.y = m_cameraPosOffsetY;
            m_dock.position = m_dockLerp = Vector3.Lerp(m_dock.position, m_follower.position + m_cameraPosOffset, Time.deltaTime * m_smoothLerpV);

            // lookat
            m_dockLerp.y = 0;
            m_lookAtNormalize = (m_followerLerp - m_dockLerp).normalized;
            m_lookAt.position = m_follower.position + m_lookAtNormalize * Mathf.Lerp(Vector3.Distance(m_lookAt.position, m_follower.position), Vector3.Distance(m_lookAtTarget.position, m_follower.position), Time.deltaTime * m_smoothLerpV);
            m_dock.LookAt(m_lookAt);
        }
    }
    public void SetFollower(Transform _f, bool _lerp = true)
    {
        m_followerTarget = _f;
        m_smoothLerp = _lerp;
        if (null != _f && !_lerp)
        {
            m_dockLerp = _f.position;
            m_followerLerp = _f.position;
        }
    }
    public void SetLookAt(Transform _t, bool _lerp = true)
    {
        if (null == _t)
        {
            _t = m_followerTarget;
        }
        m_lookAtTarget = _t;
        m_smoothLerp = _lerp;
        if (null != _t && !_lerp)
        {
            m_lookAtLerp = _t.position;
        }
    }
    public void Enter()
    {
        if (null != m_rootO)
        {
            m_rootO.SetActive(true);
        }
    }
    public void Exit()
    {
        if (null != m_rootO)
        {
            m_rootO.SetActive(false);
        }
    }

    #endregion
}
