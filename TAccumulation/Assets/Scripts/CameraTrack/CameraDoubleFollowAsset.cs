using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "CameraDoubleFollowAsset", menuName = "ScriptableObjects/Camera/DoubleFollowAsset", order = 1)]
public class CameraDoubleFollowAsset : ScriptableObject
{
    public CameraTrace.CDoubleCtrlTraceSetup m_data;
}
