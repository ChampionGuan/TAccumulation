using UnityEngine;

namespace X3Game
{
    [XLua.CSharpCallLua]
    public interface InputBaseDelegate
    {
        void OnTouchDown(Vector2 pos);
        void OnTouchUp(Vector2 pos);
        void OnGesture(InputComponent.GestrueType gesture);
        void OnDestroy(GameObject obj);
    }
}