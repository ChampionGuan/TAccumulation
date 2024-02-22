using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using X3Game;

namespace X3Game
{
    //审核包强制隐藏节点
    public class AuditHideCtrl : MonoBehaviour
    {
        private void OnEnable()
        {
            if (AppInfoMgr.Instance.AppInfo.IsAudit)
                gameObject.SetActive(false);
        }
    }
}