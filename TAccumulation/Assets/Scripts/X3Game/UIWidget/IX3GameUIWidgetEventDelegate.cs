using UnityEngine;
using UnityEngine.EventSystems;
using PapeGames.X3UI;

namespace X3Game
{
    public interface IX3GameUIWidgetEventDelegate
    {
        #region MilestoneSlider
        void MilestoneSlider_OnCellLoad(MilestoneSlider sender, int instanceID, GameObject childItem, int childIdx);
        void MilestoneSlider_OnMilestoneEnter(MilestoneSlider sender, int instanceID, GameObject childItem, int childIdx);
        #endregion

        #region X3Joystick
        void X3Joystick_OnJoystickDown(X3Joystick sender, int instanceID, PointerEventData eventData);
        void X3Joystick_OnJoystickUp(X3Joystick sender, int instanceID, PointerEventData eventData);
        void X3Joystick_OnJoystickDrag(X3Joystick sender, int instanceID, float dirX, float dirY);
        void X3Joystick_OnJoystickUpdate(X3Joystick sender, int instanceID, float dirX, float dirY);
        void X3Joystick_OnJoystickFixUpdate(X3Joystick sender, int instanceID, float dirX, float dirY);
        void X3Joystick_OnJoystickLateUpdate(X3Joystick sender, int instanceID, float dirX, float dirY);
        #endregion

        #region GIFImage

        void GIFImage_OnBegin(GIFImage sender, int instanceID);
        
        void GIFImage_OnComplete(GIFImage sender, int instanceID);
        
        void GIFImage_OnKeyFrame(GIFImage sender, int instanceID, int spriteIdx);

        #endregion
        
        #region OnDestroy
        void OnDestroy(Object sender, int senderInsID);
        #endregion
    }
}