using UnityEngine;

namespace X3Game
{
    [XLua.CSharpCallLua]
    public interface InputMultiDelegate : InputBaseDelegate
    {
        void OnBeginDoubleTouchMove(float delta, Vector2 pos1, Vector2 pos2);
        void OnDoubleTouchMove(float delta, Vector2 pos1, Vector2 pos2);
        void OnEndDoubleTouchMove(float delta, Vector2 pos1, Vector2 pos2);
        void OnBeginDoubleTouchScale(float delta, float scale);
        void OnDoubleTouchScale(float delta, float scale);
        void OnEndDoubleTouchScale(float delta, float scale);
        void OnBeginDoubleTouchRotate(float delta, float angle);
        void OnDoubleTouchRotate(float delta, float angle);
        void OnEndDoubleTouchRotate(float delta, float angle);
    }
}