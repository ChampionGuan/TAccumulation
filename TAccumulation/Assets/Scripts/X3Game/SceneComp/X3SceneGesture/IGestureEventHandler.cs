using UnityEngine;

namespace X3Game.SceneGesture
{
    public interface IDragEventHandler
    {
        void OnDragBegin(Vector2 touchPos);
        void OnDragUpdate(Vector2 dragDelta, Vector2 touchPos);
        void OnDragEnd(Vector2 touchPos);
    }

    public interface IPinchEventHandler
    {
        void OnPinchBegin();
        void OnPinchUpdate(float pinchDelta);
        void OnPinchEnd(float pinchDelta);
    }
}