#if UNITY_ANDROID
using System.IO;
using System.Runtime.InteropServices;
using UnityEngine;

namespace X3Game.AILab
{
    public class FaceValidationBridgeImpl_Andriod:FaceValidationBridgeImpl_Base
    {
        protected override ulong CreateValidatorImpl(double threshold, int mtcnnNumThread, int validationNumThread)
        {
            var pv_root = Path.Combine(AILabHelper.RootPath, AILabHelper.FolderPath, AILabHelper.ModelPath);
            var fMfn = Path.Combine(AILabHelper.RootPath, AILabHelper.FolderPath, AILabHelper.ModelPath, MFN_PATH);

            return createValidator(pv_root, fMfn, threshold,mtcnnNumThread, validationNumThread);
        }

        protected override ulong ReleaseValidatorImpl(ulong ptr)
        {
            return releaseValidator(ptr);
        }

        protected override void AddRefImpl(ulong ptr, int id, float[] newEmbedding)
        {
            addRefFace(ptr, id, newEmbedding);
        }

        protected override int CheckFaceImpl(ulong ptr, byte[] data, int width, int height,
            int maxNumFace, float embeddingscale, float detectscale, int minfacesize, bool isCamera, out int[] existIds)
        {
            existIds = new int[maxNumFace];
            int rotate, flip;
            if (!isCamera)
            {
                rotate = 0;
                flip = 0;
            }
            else
            {
                rotate = -1;
                flip = -2;
            }
            return checkFace(ptr, data, width, height, 
                maxNumFace, embeddingscale, detectscale, minfacesize, 
                rotate,flip, existIds);
        }

        protected override void ResetTrackImpl(ulong ptr)
        {
            ResetTrack(ptr);
        }
        
        [DllImport("ailab")]
        private static extern ulong createValidator(string pv_root, string mfn_filename, double threshold,int mtcnnNumThread,int validationNumThread);
        [DllImport("ailab")]
        private static extern ulong releaseValidator(ulong ptr);
        [DllImport("ailab")]
        private static extern void addRefFace(ulong ptr, int id, float[] newEmbedding);
        [DllImport("ailab")]
        private static extern int checkFace(ulong ptr, byte[] data, int width, int height, 
            int maxNumFace, float embeddingscale, float detectscale, int minfacesize, 
            int rotateIndex,int flipindex, 
            int[] existIds);
        [DllImport("ailab")]
        private static extern void ResetTrack(ulong ptr);
    }
}
#endif