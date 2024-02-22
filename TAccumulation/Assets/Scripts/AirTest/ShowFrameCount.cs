using UnityEngine;

public class ShowFrameCount
{
    public static bool showFrameCount = false;
    public static string frameCountStr = EditableStringExtender.AllocateString(8);
    public static TextMesh frameCountText = null;

    public static void Show()
    {
        if (frameCountText == null)
        {
            var go = new GameObject("ShowFrameCount");
            go.transform.position = new Vector3(999, 999, 999);
            var text = go.AddComponent<TextMesh>();
            text.text = frameCountStr;
            frameCountText = text;

            var camGo = new GameObject("ShowFrameCountCam");
            camGo.transform.parent = go.transform;
            var cam = camGo.AddComponent<Camera>();
            cam.farClipPlane = 1000F;
            cam.nearClipPlane = 998F;
            cam.clearFlags = CameraClearFlags.Depth;
            cam.cullingMask = 1 << LayerMask.NameToLayer("Default");
            cam.orthographic = true;
            cam.rect = new Rect(-0.8F, 0, 1, 0.04F);
            cam.depth = 100;
            cam.orthographicSize = 1;
            cam.transform.localPosition = new Vector3(2, -1, -999);

            Object.DontDestroyOnLoad(go);
        }

        frameCountStr.UnsafeClear();
        frameCountStr.UnsafeAppend(Time.frameCount);
        frameCountText.text = frameCountStr;
    }
} 
