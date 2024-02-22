using SRF;
using System.Collections;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using XLua;

[LuaCallCSharp]
public class LuaBehaviour : MonoBehaviour
{
    // Start is called before the first frame update
    static readonly string LUA_BEHAVIOUR_CALL = @"LUA_BEHAVIOUR_CALL";
    static readonly string ENABLE = @"OnEnable";
    static readonly string UPDATE = @"Update";
    static readonly string LATE_UPDATE = @"LateUpdate";
    public class LuaEventData
    {
        public GameObject obj;
        public string function_name;
    }

    static LuaEventData eventData = new LuaEventData();

    private void OnEnable()
    {
        CallLua(ENABLE);
    }

    // Update is called once per frame
    private void Update()
    {
        CallLua(UPDATE);
    }

    private void LateUpdate()
    {
        CallLua(LATE_UPDATE);
    }

    void CallLua(string func_name)
    {
        eventData.obj = gameObject;
        eventData.function_name = func_name;
        EventMgr.Dispatch(LUA_BEHAVIOUR_CALL, eventData);
    }
}
