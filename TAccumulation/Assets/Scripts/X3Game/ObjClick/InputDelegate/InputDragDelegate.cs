using UnityEngine;

namespace X3Game
{
    [XLua.CSharpCallLua]
    public interface InputDragDelegate : InputBaseDelegate
    {
        void OnBeginDrag(Vector2 pos);
        void OnDrag(Vector2 pos, Vector2 deltaPos, InputComponent.GestrueType gesture);
        void OnEndDrag(Vector2 pos);
    }
}