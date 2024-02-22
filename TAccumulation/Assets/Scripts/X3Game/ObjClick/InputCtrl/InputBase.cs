using System;
using UnityEngine;
using GestrueType = X3Game.InputComponent.GestrueType;
using TouchType = X3Game.InputComponent.TouchEventType;
using PapeGames.X3UI;

namespace X3Game
{
    public class InputBase
    {
        public GestrueType CurGesture;
        public TouchType CurTouchType = TouchType.NONE;
        public InputHandler InputHandler;

        public virtual void OnTouchDown(Vector2 pos)
        {
        }

        public virtual void OnTouchUp(Vector2 pos)
        {
        }

        public virtual bool OnUpdate(Vector2 pos)
        {
            return true;
        }
        
        public virtual void OnExit(Vector2 pos)
        {
        }

        public virtual void OnTouchCountChanged(int newCount, int oldCount)
        {
            
        }

        public bool IsTouchTypeEnable(TouchType touchEventType)
        {
            return (CurTouchType & touchEventType) == touchEventType;
        }

        public virtual void Clear()
        {
            InputHandler = null;
            try
            {
                ClearState();
            }
            catch (Exception e)
            {
                
            }
            
        }

        public virtual void ClearState()
        {
        }

        public virtual bool AlwaysUpdate()
        {
            return false;
        }
    }
}