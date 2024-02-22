using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace X3Game
{
    [LuaCallCSharp]
    public class StageMoveParam : MonoBehaviour
    {

        public float Distance = 500;

        public float MoveTime1 = 2;

        public float MoveTime2 = 1;

        public float MinSpeed = 200;
    }
}
