using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    public partial class InputEffectMgr
    {
        private static Vector2 s_TouchDownPos;
        private static InputType s_CurTouchType;
        private static Vector2 s_OnClickPos;
        private static Vector2 s_OnDragPos;
        private static Vector2 s_OnLongPressPos;
        private static bool s_IsTouchDownObj = false;
        private static InputComponent s_InputComponent;

        public void OnBeginDrag(Vector2 pos)
        {
        }

        public void OnEndDrag(Vector2 pos)
        {
        }

        public void OnTouchClickObj(GameObject obj)
        {
        }

        public void OnTouchClick(Vector2 pos)
        {
            s_OnClickPos = pos;
        }

        public void OnTouchDownObj(GameObject obj)
        {
        }

        public void OnTouchDown(Vector2 pos)
        {
            s_TouchDownPos = pos;
            s_CurTouchType = InputType.TouchDown;
            ShowEffect(EffectType.Click, string.Empty, -1);
        }

        public void OnDrag(Vector2 pos, Vector2 deltaPos, InputComponent.GestrueType gesture)
        {
            s_CurTouchType = InputType.Drag;
            s_OnDragPos = pos;
            ShowEffect(EffectType.Drag, string.Empty, -1);
        }

        public void OnLongPress(Vector2 pos)
        {
            s_OnLongPressPos = pos;
            s_CurTouchType = InputType.LongPress;
        }

        public void OnLongPressObj(GameObject obj)
        {
        }

        public void OnTouchUp(Vector2 pos)
        {
            s_CurTouchType = InputType.TouchUp;
        }


        public void OnTouchDownNoCheckObj(GameObject obj)
        {
            s_IsTouchDownObj = obj != null;
        }

        public void OnTouchClickCol(Collider col)
        {
            
        }
        public void OnGesture(InputComponent.GestrueType gesture)
        {
        }

        public void OnDestroy(GameObject obj)
        {
        }

        void ClearInput()
        {
            s_IsTouchDownObj = false;
        }


        void InitInput()
        {
            var input = gameObject.GetOrAddComponent<InputComponent>();
            input.SetCtrlType(InputComponent.CtrlType.CLICK | InputComponent.CtrlType.DRAG);
            input.SetClickType(InputComponent.ClickType.POS | InputComponent.ClickType.TARGET |
                               InputComponent.ClickType.LONG_PRESS);
            input.AddRaycastCamera(CameraUtility.MainCamera);
            input.AddRaycastCamera(UIViewUtility.GetUICamera());
            input.SetDelegate(this);
            input.SetDefaultMoveThresholdDis();
            s_InputComponent = input;
        }
    }
}