using UnityEngine;

namespace X3Game
{
    [XLua.CSharpCallLua]
    public interface InputClickDelegate : InputBaseDelegate
    {
        void OnLongPress(Vector2 pos);
        void OnTouchClick(Vector2 pos);
        void OnTouchDownObj(GameObject obj);
        void OnLongPressObj(GameObject obj);
        void OnTouchClickObj(GameObject obj);
        void OnTouchDownNoCheckObj(GameObject obj);
        
        void OnTouchClickCol(Collider col);
    }
}