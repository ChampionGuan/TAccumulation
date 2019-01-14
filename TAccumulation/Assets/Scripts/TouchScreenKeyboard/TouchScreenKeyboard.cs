using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace LPCFramework
{
    public class TouchScreenKeyboard : FairyGUI.IKeyboard
    {
        UnityEngine.TouchScreenKeyboard _keyboard;
        System.Action _doneAction;

        public bool done
        {
            get { return _keyboard == null || _keyboard.done; }
        }

        public bool supportsCaret
        {
            get { return false; }
        }

        public string text
        {
            set
            {
                if (null != _keyboard)
                {
                    _keyboard.text = value;
                }
            }
        }

        public TouchScreenKeyboard(System.Action done)
        {
            _doneAction = done;
        }
        public string GetInput()
        {
            if (_keyboard != null)
            {
                string s = _keyboard.text;

                // if (_keyboard.done)
                //     _keyboard = null;

                return s;
            }
            else
                return null;
        }

        public void Open(string text, bool autocorrection, bool multiline, bool secure, bool alert, string textPlaceholder, int keyboardType, bool hideInput)
        {
            if (_keyboard != null)
            {
                _keyboard.text = text;
                return;
            }
            multiline = false;
            UnityEngine.TouchScreenKeyboard.hideInput = hideInput;
            _keyboard = UnityEngine.TouchScreenKeyboard.Open(text, (TouchScreenKeyboardType)keyboardType, autocorrection, multiline, secure, alert, textPlaceholder);
        }

        public void Close()
        {
            if (_keyboard != null)
            {
                if (null != _doneAction && _keyboard.status == UnityEngine.TouchScreenKeyboard.Status.Done)
                {
                    _doneAction();
                }

                _keyboard.active = false;
                _keyboard = null;
            }
        }
        public void Destroy()
        {
            _doneAction = null;
            _keyboard = null;
        }
    }
}

