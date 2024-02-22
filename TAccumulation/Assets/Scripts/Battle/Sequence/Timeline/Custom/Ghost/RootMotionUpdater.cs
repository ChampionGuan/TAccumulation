using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UnityEngine.Timeline
{
    [ExecuteInEditMode]
    public class RootMotionUpdater : MonoBehaviour
    {
        public Transform rmRecorder;
        public const string RMRecorderName = "RootMotionRecorder";

        void TryInit()
        {
            if(rmRecorder)
            {
                return;
            }

            rmRecorder = transform.Find(RMRecorderName);
            if (!rmRecorder)
            {
                GameObject go = new GameObject(RMRecorderName);
                go.transform.SetParent(transform, false);
            }
        }

        // Update is called once per frame
        void LateUpdate()
        {
            this.TryInit();

            if(!rmRecorder)
            {
                return;
            }

            transform.localPosition = rmRecorder.transform.localPosition;
            transform.localRotation = rmRecorder.transform.localRotation;
            transform.localScale = rmRecorder.transform.localScale;
        }
    }
}