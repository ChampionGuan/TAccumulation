using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "CameraTakeAnimAsset", menuName = "ScriptableObjects/Camera/TakeAnimAsset", order = 1)]
public class CameraTakeAnimAsset : ScriptableObject
{
    public CameraTrace.CTakeAimTraceSetup m_data;
}
