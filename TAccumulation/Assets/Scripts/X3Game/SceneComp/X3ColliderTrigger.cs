using PapeGames.X3;
using UnityEngine;
using XLua;

[LuaCallCSharp]
[Hotfix]
public class X3ColliderTrigger : MonoBehaviour
{
    private static readonly string Input_OnTriggerEnter = "Input_OnTriggerEnter";
    private static readonly string Input_OnTriggerStay = "Input_OnTriggerStay";
    private static readonly string Input_OnTriggerExit = "Input_OnTriggerExit";

    private static readonly string Input_OnCollisionEnter = "Input_OnCollisionEnter";
    private static readonly string Input_OnCollisionStay = "Input_OnCollisionStay";
    private static readonly string Input_OnCollisionExit = "Input_OnCollisionExit";

    private void OnTriggerEnter(Collider other)
    {
        EventMgr.Dispatch(Input_OnTriggerEnter, other);
    }

    private void OnTriggerStay(Collider other)
    {
        EventMgr.Dispatch(Input_OnTriggerStay, other);
    }

    private void OnTriggerExit(Collider other)
    {
        EventMgr.Dispatch(Input_OnTriggerExit, other);
    }

    private void OnCollisionEnter(Collision collision)
    {
        EventMgr.Dispatch(Input_OnCollisionEnter, collision);
    }

    private void OnCollisionStay(Collision collision)
    {
        EventMgr.Dispatch(Input_OnCollisionStay, collision);
    }

    private void OnCollisionExit(Collision collision)
    {
        EventMgr.Dispatch(Input_OnCollisionExit, collision);
    }
}
