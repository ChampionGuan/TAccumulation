using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class CameraBase
    {
        public CameraBase()
        {

        }

        virtual public void OnAwake()
        { }

        virtual public Coroutine StartCoroutine(IEnumerator func)
        {
            return PapeGames.X3.CoroutineProxy.StartCoroutine(func);

        }

        virtual public void StopCoroutine(Coroutine co)
        {
            if (co == null)
            {
                return;
            }
            PapeGames.X3.CoroutineProxy.StopCoroutine(co);
        }
    }

    public class CameraModeBase: CameraBase
    {
        public VirtualCamera virtualCamera;
        public CameraModeBase(VirtualCamera virCam): base()
        {
            virtualCamera = virCam;
        }

        virtual public void OnEnter()
        { }

        virtual public void OnExit()
        { }
    }
}
