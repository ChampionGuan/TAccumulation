using System;
using System.IO;
using PapeGames.X3;
using UnityEngine;

namespace X3Game.AILab
{
    public abstract class FaceValidationBridgeImpl_Base : IFaceValidationBridge
    {
        //当前运行的相机
        bool isplaying = false;
        private WebCamTexture webcamTexture;

        // 神经网络相关
        bool ischecking = false;
        float mfnThreshold = 0.7f;
        private int PLENGTH = 27936;
        private int RLENGTH = 402872;
        private int OLENGTH = 397896;
        private int MFNLENGTH = 3905928;
        protected string MFN_PATH = "mo.enc";
        private string m_fMfn, m_pv_root;
        private int CHECK_INTERVAL = 1;
        private int num_frame_saved = -1;
        private int SET_FRAME_NUMS = 30;
        private int m_max_face_num = 5;
        private int num_update_from_last_check = 0;
        private int add_face_error_count = 0;

        private int mtcnnNumThread = 2; //2
        private int validationNumThread = 1; //1
        private ulong m_pValidator;

        public void Release()
        {
            if (m_pValidator != 0)
            {
                ReleaseValidatorImpl(m_pValidator);
            }
        }
        public void InitFaceValidator(float threshold, float[][] refFaces)
        {
            if (refFaces == null)
            {
                X3Debug.LogError("FaceValidator:Input refFaces List is null");
                return;
            }
            
            m_pValidator = CreateValidatorImpl(threshold, mtcnnNumThread, validationNumThread);
            if (m_pValidator == 0)
            {
                X3Debug.LogFatal("FaceValidator Init Failed");
                return;
            }

            for (int i = 0; i < refFaces.Length; i++)
            {
                AddRefImpl(m_pValidator, i + 1, refFaces[i]);
            }
        }

        public CheckFaceResult CheckFace(Texture2D inputImg, bool isCamera)
        {
            if (inputImg == null)
            {
                X3Debug.LogError("FaceValidator:Input Texture is null");
                return CheckFaceResult.NoFace;
            }

            if (m_pValidator == 0)
            {
                X3Debug.LogFatal("FaceValidator:FaceValidator is not Init");
                return CheckFaceResult.NoFace;
            }

            Color32Array colorArray = new Color32Array();
            colorArray.colors = inputImg.GetPixels32();
            ResetTrackImpl(m_pValidator);

            var detectScale = Mathf.Min(1.0f, 1024.0f / Math.Min(inputImg.width, inputImg.height));
            var minFaceSize = Math.Max(1, (int)Math.Min(inputImg.width * detectScale, inputImg.height * detectScale) / 7);
            var resultNum = CheckFaceImpl(m_pValidator, colorArray.byteArray, inputImg.width, inputImg.height,
                m_max_face_num, 1.0f, detectScale, minFaceSize, isCamera,
                out int[] result);

            if (resultNum <= 0)
            {
                return CheckFaceResult.NoFace;
            }

            var detected = false;
            for (int i = 0; i < resultNum; i++)
            {
                if (result[i] > 0)
                {
                    detected = true;
                    X3Debug.LogWarning($"包含敏感脸{result[i]}");
                    break;
                }
            }

            return detected ? CheckFaceResult.Detected : CheckFaceResult.NotDetected;
        }

        protected abstract ulong CreateValidatorImpl(double threshold, int mtcnnNumThread, int validationNumThread);

        protected abstract ulong ReleaseValidatorImpl(ulong ptr);

        protected abstract void AddRefImpl(ulong ptr, int id, float[] newEmbedding);

        protected abstract int CheckFaceImpl(ulong ptr, byte[] data, int width, int height,
            int maxNumFace, float embeddingscale, float detectscale, int minfacesize, bool isCamera, out int[] existIds);

        protected abstract void ResetTrackImpl(ulong ptr);
    }
}