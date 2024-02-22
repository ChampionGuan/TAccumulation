using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GestrueType = X3Game.InputComponent.GestrueType;

namespace X3Game
{
    [XLua.CSharpCallLua]
    public interface InputDelegate : InputClickDelegate, InputDragDelegate, InputScrollDelegate, InputMultiDelegate
    {
        
    }
}