using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraShot
{
    public CinemachineVirtualCameraBase VirtualCamera;
    public float pitchMin;
    public float pitchMax;
    public float yawMin;
    public float yawMax;

    public double start;
    public double end;

    public bool IsValid { get { return VirtualCamera != null; } }
}
