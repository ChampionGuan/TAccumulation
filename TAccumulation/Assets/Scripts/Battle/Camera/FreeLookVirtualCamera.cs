using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using X3Battle;

public class FreeLookVirtualCamera : VirtualCamera
{
    public X3FreeVirtualCamera x3FreeVirtualCamera;
    public FreeLookVirtualCamera(string name, CameraPriorityType priority) : base(name, priority)
    {
        x3FreeVirtualCamera = _rootG.GetComponent<X3FreeVirtualCamera>();
    }

    public void EnableFreeCamera(Vector3 pos, Quaternion rot, float fov)
    {
        if(!IsLiving())
        {
            SetEnable();
        }
        x3FreeVirtualCamera.SetPosAndRot(pos, rot);
        x3FreeVirtualCamera.SetFov(fov);
    }

    public void DisableFreeCamera()
    {
        SetDisable();
    }
}
