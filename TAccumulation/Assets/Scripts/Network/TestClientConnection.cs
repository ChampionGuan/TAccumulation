using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace LCG
{
    public class TestClientConnection : MonoBehaviour
    {
        private ClientConnection clientHandle = new ClientConnection();


        // Update is called once per frame
        void Update()
        {
            byte[] msg = clientHandle.GetRecvMsg();
            if (null != msg)
            {
                Debug.Log("客户端接受到消息：" + System.Text.Encoding.Default.GetString(msg));
            }

            if (Input.GetKeyDown(KeyCode.J))
            {
                clientHandle.Send(System.Text.Encoding.Default.GetBytes("来自客户端的消息"));
            }
            if (Input.GetKeyDown(KeyCode.A))
            {
                clientHandle.Connect("192.168.1.110", 60000, null);
            }
        }
    }
}