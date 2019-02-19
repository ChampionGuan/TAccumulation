using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace LCG
{
    public class TestServerConnection : MonoBehaviour
    {
        private ServerConnection serverHandle = new ServerConnection();

        void Start()
        {
            serverHandle.Accept("192.168.1.110", 60000);
        }

        // Update is called once per frame
        void Update()
        {
            foreach (var v in serverHandle.Connections)
            {
                byte[] msg = v.GetRecvMsg();
                if (null != msg)
                {
                    Debug.Log("服务器接受到消息：" + System.Text.Encoding.Default.GetString(msg));
                }
            }

            if (Input.GetKeyDown(KeyCode.K))
            {
                serverHandle.Send(System.Text.Encoding.Default.GetBytes("来自服务器的消息"));
            }
        }
    }
}