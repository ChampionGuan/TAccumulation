using UnityEngine;

public class TransformSync : MonoBehaviour
{
    public Transform m_referTo;
    private bool m_isAutoPositionSync = false;
    private bool m_isAutoRotationSync = false;
    private bool m_isAutoLocalScaleSync = false;

    public void SetAutoSyncPosition(bool param)
    {
        m_isAutoPositionSync = param;
        this.Update();
    }

    public void SetAutoSyncRotation(bool param)
    {
        m_isAutoRotationSync = param;
        this.Update();
    }

    public void SetAutoSyncLocalScale(bool param)
    {
        m_isAutoLocalScaleSync = param;
        this.Update();
    }

    public void SetReferTransform(Transform param)
    {
        m_referTo = param;
        this.Update();
    }

    public void SyncPosition()
    {
        if (m_referTo)
        {
            transform.position = m_referTo.position;
        }
    }

    public void SyncRotation()
    {
        if (m_referTo)
        {
            transform.rotation = m_referTo.rotation;
        }
    }

    public void SyncLocalScale()
    {
        if (m_referTo)
        {
            transform.localScale = m_referTo.localScale;
        }
    }

    private void Update()
    {
        if (m_isAutoPositionSync)
        {
            SyncPosition();
        }

        if (m_isAutoRotationSync)
        {
            SyncRotation();
        }

        if (m_isAutoLocalScaleSync)
        {
            SyncLocalScale();
        }
    }
}