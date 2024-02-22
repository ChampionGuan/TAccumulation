using UnityEngine;

namespace X3Game.AILab
{
    public interface IFaceValidationBridge
    {
        void InitFaceValidator(float threshold, float[][] refFaces);
        CheckFaceResult CheckFace(Texture2D inputImg, bool isCamera);
        void Release();
    }
}