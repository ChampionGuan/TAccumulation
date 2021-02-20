using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "CameraDoubleLookAtAsset", menuName = "ScriptableObjects/Camera/DoubleLookAtAsset", order = 1)]
public class CameraDoubleLookAtAsset : ScriptableObject
{
    public CameraTrace.CDoubleLookatTraceSetup m_data;
}
