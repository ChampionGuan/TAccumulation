using UnityEngine;

namespace X3Game.AILab
{
    public enum CheckFaceResult
    {
        NoFace,
        Detected,
        NotDetected
    }
    
    [XLua.LuaCallCSharp]
    [XLua.CSharpCallLua]
    public static class FaceValidationUtility
    {
        public static void InitFaceValidator(float threshold, float[][] refFaces)
        {
            GetInstance().InitFaceValidator(threshold, refFaces);
        }

        public static CheckFaceResult CheckFace(Texture2D inputImg, bool isCamera)
        {
            return GetInstance().CheckFace(inputImg, isCamera);
        }

        public static void Release()
        {
            m_ins.Release();
            m_ins = null;
        }

        static IFaceValidationBridge GetInstance()
        {
            if (m_ins != null)
            {
                return m_ins;
            }

#if UNITY_IOS
            m_ins = new FaceValidationBridgeImpl_iOS();
#elif UNITY_ANDROID
            m_ins = new FaceValidationBridgeImpl_Andriod();
#else
            m_ins = new FaceValidationBridgeImpl_Windows();
#endif

            return m_ins;
        }

        private static IFaceValidationBridge m_ins;
    }
}