using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    [ExecuteAlways]
    public class SyncCameraFor3DUI : MonoBehaviour
    {
        Camera c = null;

        // Start is called before the first frame update
        void Start()
        {
            c = GetComponent<Camera>();
        }

        // Update is called once per frame
        void LateUpdate()
        {
            CameraUtility.CopyCameraProperties(c);
        }
    }
}