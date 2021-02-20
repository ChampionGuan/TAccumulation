using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "CameraFreeAsset", menuName = "ScriptableObjects/Camera/FreeAsset", order = 1)]
public class CameraFreeAsset : ScriptableObject
{
    public CameraTrace.CFreeSetup m_data;
}
