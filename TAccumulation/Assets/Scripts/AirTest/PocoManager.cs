#if AIRTEST
using Poco;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using System.Net.Sockets;
using TcpServer;
using UnityEngine;
using Debug = UnityEngine.Debug;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using TMPro;
using UnityEngine.Events;
using System.Reflection;
using PapeGames.X3UI;
using System.Collections;
using UnityEngine.EventSystems;
using System.IO;
using PapeGames.X3;
using UnityEngine.UI;
using XLua;
using FlowAutoTest;
using X3Game;

public class PocoManager : MonoBehaviour
{
    public const int versionCode = 6;
    public int port = 5001;
    private bool mRunning;
    public AsyncTcpServer server = null;
    private RPCParser rpc = null;
    private SimpleProtocolFilter prot = null;
    private UnityDumper dumper = new UnityDumper();
    private Dictionary<string, TcpClientState> inbox = new Dictionary<string, TcpClientState>();
    private VRSupport vr_support = new VRSupport();
    private string _tempBattleName = "";
    private Dictionary<string, long> debugProfilingData = new Dictionary<string, long>() {
        { "dump", 0 },
        { "screenshot", 0 },
        { "handleRpcRequest", 0 },
        { "packRpcResponse", 0 },
        { "sendRpcResponse", 0 },
    };

    class RPC : Attribute
    {
    }

    void Awake()
    {
        Application.runInBackground = true;
        DontDestroyOnLoad(this);
        prot = new SimpleProtocolFilter();
        rpc = new RPCParser();
        rpc.addRpcMethod("isVRSupported", vr_support.isVRSupported);
        rpc.addRpcMethod("hasMovementFinished", vr_support.IsQueueEmpty);
        rpc.addRpcMethod("RotateObject", vr_support.RotateObject);
        rpc.addRpcMethod("ObjectLookAt", vr_support.ObjectLookAt);
        rpc.addRpcMethod("Screenshot", Screenshot);
        rpc.addRpcMethod("GetScreenSize", GetScreenSize);
        rpc.addRpcMethod("Dump", Dump);
        rpc.addRpcMethod("GetDebugProfilingData", GetDebugProfilingData);
        rpc.addRpcMethod("SetText", SetText);
        rpc.addRpcMethod("GetSDKVersion", GetSDKVersion);

        rpc.addRpcMethod("SetMainGameViewSize", SetMainGameViewSize);
        rpc.addRpcMethod("Click", Click);
        rpc.addRpcMethod("ClickScreenPos", ClickScreenPos);
        rpc.addRpcMethod("UIExists", UIExists);
        rpc.addRpcMethod("Login", Login);
        rpc.addRpcMethod("Guide1", Guide1);
        rpc.addRpcMethod("Battle", Battle);
        rpc.addRpcMethod("Guide2", Guide2);
        rpc.addRpcMethod("CheckTestFinished", CheckTestFinished);
        rpc.addRpcMethod("RunFlow", RunFlow);
        rpc.addRpcMethod("RunFlowByJson", RunFlowByJson);
        rpc.addRpcMethod("GMOpenGuide", GMOpenGuide);
        rpc.addRpcMethod("GMCommand", GMCommand);
        rpc.addRpcMethod("TestStartBattle", TestStartBattle);
        rpc.addRpcMethod("CallCSharp", CallCSharp);
        rpc.addRpcMethod("CallLua", CallLua);
        rpc.addRpcMethod("MemorySnapshot", MemorySnapshot);
        rpc.addRpcMethod("CheckBattleFinished", CheckBattleFinished);
        rpc.addRpcMethod("GMGuideOpen", GMGuideOpen);
        rpc.addRpcMethod("GMGuideAutoGuideOpen", GMGuideAutoGuideOpen);
        rpc.addRpcMethod("GMGuideManualGuideOpen", GMGuideManualGuideOpen);
        //rpc.addRpcMethod("Record", Record);
        //rpc.addRpcMethod("StopRecord", StopRecord);
        rpc.addRpcMethod("test", test);
        rpc.addRpcMethod("CheckAllWwiseBnkIsAvailable", CheckAllWwiseBnkIsAvailable);
        rpc.addRpcMethod("CheckModelInBattle", CheckModelInBattle);
        rpc.addRpcMethod("LogOut", LogOut);
        
        mRunning = true;

        for (int i = 0; i < 5; i++)
        {
            this.server = new AsyncTcpServer(port + i);
            this.server.Encoding = Encoding.UTF8;
            this.server.ClientConnected +=
                new EventHandler<TcpClientConnectedEventArgs>(server_ClientConnected);
            this.server.ClientDisconnected +=
                new EventHandler<TcpClientDisconnectedEventArgs>(server_ClientDisconnected);
            this.server.DatagramReceived +=
                new EventHandler<TcpDatagramReceivedEventArgs<byte[]>>(server_Received);
            try
            {
                this.server.Start();
                Debug.Log(string.Format("Tcp server started and listening at {0}", server.Port));
                break;
            }
            catch (SocketException e)
            {
                Debug.Log(string.Format("Tcp server bind to port {0} Failed!", server.Port));
                Debug.Log("--- Failed Trace Begin ---");
                Debug.LogError(e);
                Debug.Log("--- Failed Trace End ---");
                // try next available port
                this.server = null;
            }
        }
        if (this.server == null)
        {
            Debug.LogError(string.Format("Unable to find an unused port from {0} to {1}", port, port + 5));
        }
        vr_support.ClearCommands();
    }

    static void server_ClientConnected(object sender, TcpClientConnectedEventArgs e)
    {
        Debug.Log(string.Format("TCP client {0} has connected.",
            e.TcpClient.Client.RemoteEndPoint.ToString()));
    }

    static void server_ClientDisconnected(object sender, TcpClientDisconnectedEventArgs e)
    {
        Debug.Log(string.Format("TCP client {0} has disconnected.",
           e.TcpClient.Client.RemoteEndPoint.ToString()));
    }

    private void server_Received(object sender, TcpDatagramReceivedEventArgs<byte[]> e)
    {
        Debug.Log(string.Format("Client : {0} --> {1}",
            e.Client.TcpClient.Client.RemoteEndPoint.ToString(), e.Datagram.Length));
        TcpClientState internalClient = e.Client;
        string tcpClientKey = internalClient.TcpClient.Client.RemoteEndPoint.ToString();
        inbox[tcpClientKey] = internalClient;
    }

    [RPC]
    private object Dump(List<object> param)
    {
        var onlyVisibleNode = true;
        if (param.Count > 0)
        {
            onlyVisibleNode = (bool)param[0];
        }
        var sw = new Stopwatch();
        sw.Start();
        var h = dumper.dumpHierarchy(onlyVisibleNode);
        debugProfilingData["dump"] = sw.ElapsedMilliseconds;

        return h;
    }

    [RPC]
    private object Screenshot(List<object> param)
    {
        var sw = new Stopwatch();
        sw.Start();

        var tex = new Texture2D(Screen.width, Screen.height, TextureFormat.RGB24, false);
        tex.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);
        tex.Apply(false);
        byte[] fileBytes = tex.EncodeToJPG(80);
        var b64img = Convert.ToBase64String(fileBytes);
        debugProfilingData["screenshot"] = sw.ElapsedMilliseconds;
        return new object[] { b64img, "jpg" };
    }

    [RPC]
    private object GetScreenSize(List<object> param)
    {
        return new float[] { Screen.width, Screen.height };
    }

    public void stopListening()
    {
        mRunning = false;
        server?.Stop();
    }

    [RPC]
    private object GetDebugProfilingData(List<object> param)
    {
        return debugProfilingData;
    }

    [RPC]
    private object SetText(List<object> param)
    {
        var instanceId = Convert.ToInt32(param[0]);
        var textVal = param[1] as string;
        foreach (var go in GameObject.FindObjectsOfType<GameObject>())
        {
            if (go.GetInstanceID() == instanceId)
            {
                return UnityNode.SetText(go, textVal);
            }
        }
        return false;
    }

    [RPC]
    private object GetSDKVersion(List<object> param)
    {
        return versionCode;
    }

    private List<string> needRemoveKeys = new List<string>();
    void Update()
    {
        foreach (TcpClientState client in inbox.Values)
        {
            List<string> msgs = client.Prot.swap_msgs();
            msgs.ForEach(delegate (string msg)
            {
                //var sw = new Stopwatch();
                //sw.Start();
                //var t0 = sw.ElapsedMilliseconds;
                string response = rpc.HandleMessage(msg);
                //var t1 = sw.ElapsedMilliseconds;
                byte[] bytes = prot.pack(response);
                //var t2 = sw.ElapsedMilliseconds;
                server.Send(client.TcpClient, bytes);
                //var t3 = sw.ElapsedMilliseconds;
                //debugProfilingData["handleRpcRequest"] = t1 - t0;
                //debugProfilingData["packRpcResponse"] = t2 - t1;
                string tcpClientKey = client.TcpClient.Client.RemoteEndPoint.ToString();
                needRemoveKeys.Add(tcpClientKey);
            });
        }
        for (int i = needRemoveKeys.Count - 1; i >= 0; --i)
        {
            inbox.Remove(needRemoveKeys[i]);
            needRemoveKeys.RemoveAt(i);
        }

        vr_support.PeekCommand();

//#if ProfilerEnable && UNITY_IOS
//        if (isGestureDone())
//        {
//            Debug.Log($"[Automated Test] gpu frame capture {Time.frameCount}");
//		    GraphicPerformance.GpuFrameCapture.Capture(Time.frameCount.ToString());
//        }
//#endif
    }

#if ProfilerEnable && UNITY_IOS
	List<Vector2> gestureDetector = new List<Vector2>();
	Vector2 gestureSum = Vector2.zero;
	float gestureLength = 0;
	int gestureCount = 0;
    int numOfCircleToShow = 1;
    bool isGestureDone()
    {
        if (Application.platform == RuntimePlatform.Android ||
            Application.platform == RuntimePlatform.IPhonePlayer)
        {
            if (Input.touches.Length != 1)
            {
                gestureDetector.Clear();
                gestureCount = 0;
            }
            else
            {
                if (Input.touches[0].phase == TouchPhase.Canceled || Input.touches[0].phase == TouchPhase.Ended)
                    gestureDetector.Clear();
                else if (Input.touches[0].phase == TouchPhase.Moved)
                {
                    Vector2 p = Input.touches[0].position;
                    if (gestureDetector.Count == 0 || (p - gestureDetector[gestureDetector.Count - 1]).magnitude > 10)
                        gestureDetector.Add(p);
                }
            }
        }
        else
        {
            if (Input.GetMouseButtonUp(0))
            {
                gestureDetector.Clear();
                gestureCount = 0;
            }
            else
            {
                if (Input.GetMouseButton(0))
                {
                    Vector2 p = new Vector2(Input.mousePosition.x, Input.mousePosition.y);
                    if (gestureDetector.Count == 0 || (p - gestureDetector[gestureDetector.Count - 1]).magnitude > 10)
                        gestureDetector.Add(p);
                }
            }
        }

        if (gestureDetector.Count < 10)
            return false;

        gestureSum = Vector2.zero;
        gestureLength = 0;
        Vector2 prevDelta = Vector2.zero;
        for (int i = 0; i < gestureDetector.Count - 2; i++)
        {

            Vector2 delta = gestureDetector[i + 1] - gestureDetector[i];
            float deltaLength = delta.magnitude;
            gestureSum += delta;
            gestureLength += deltaLength;

            float dot = Vector2.Dot(delta, prevDelta);
            if (dot < 0f)
            {
                gestureDetector.Clear();
                gestureCount = 0;
                return false;
            }

            prevDelta = delta;
        }

        int gestureBase = (Screen.width + Screen.height) / 8;

        if (gestureLength > gestureBase && gestureSum.magnitude < gestureBase / 2)
        {
            gestureDetector.Clear();
            gestureCount++;
            if (gestureCount >= numOfCircleToShow)
                return true;
        }

        return false;
    }
#endif

	void OnApplicationQuit()
    {
        // stop listening thread
        stopListening();
    }

    void OnDestroy()
    {
        // stop listening thread
        stopListening();
    }

    enum TestStatus
    {
        None = 0,
        Running = 1,
        Success = 2,
        Failure = 3,
    }
    private List<string> clickedBtns = new List<string>();
    private Dictionary<string, TestStatus> testStatus = new Dictionary<string, TestStatus>();
    //private string recordOutputPath;
    //private bool record = true;

	[RPC]
    private object SetMainGameViewSize(List<object> param)
    {
#if UNITY_EDITOR
        var kWindowToolbarHeight = 21F;
        var size = new Vector2(443, 960);
        if (param != null && param.Count > 0 && (string)param[0] == "horizontal")
        {
            size = new Vector2(960, 443);
        }
        size.y += kWindowToolbarHeight;

        var gameViewType = Type.GetType("UnityEditor.GameView,UnityEditor");
        var w = UnityEditor.EditorWindow.GetWindow(gameViewType);
        var position = w.position;
        var center = w.position.center;
        position.size = size;
        Debug.Log("===================================================");
        Debug.Log($"position before:{w.position.ToString()}");
        w.position = position;

        position.center = center;
        w.position = position;
        Debug.Log($"position after:{w.position.ToString()}");
        Debug.Log("===============================================================================");

        //var bindingAttr = BindingFlags.NonPublic | BindingFlags.Static;


        //var windowLayoutType = Type.GetType("UnityEditor.WindowLayout,UnityEditor");
        //var m = windowLayoutType.GetMethod("FindEditorWindowOfType", bindingAttr);
        //var gameView = m.Invoke(null, new object[] { gameViewType });

        //// GameView像素大小
        //var positionP = gameViewType.GetProperty("position");
        //var position = (Rect)positionP.GetValue(gameView, null);
        //Debug.Log(position.ToString());

        //// GameView减去工具栏的像素大小
        //var gameViewRect = position;
        //gameViewRect.height -= kWindowToolbarHeight;

        //// 游戏分辨率
        //var targetSizeP = gameViewType.GetProperty("targetSize", BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
        //var targetSize = (Vector2)targetSizeP.GetValue(gameView);
        //Debug.Log(targetSize.ToString());

        //// 默认缩放
        //var defaultScaleF = gameViewType.GetField("m_defaultScale", BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
        //var defaultScale = (float)defaultScaleF.GetValue(gameView);
        //Debug.Log(defaultScale.ToString());

        //// 实际游戏画面像素大小
        ////var targetInViewP = gameViewType.GetProperty("targetInView", BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
        ////var targetInView = (Rect)targetInViewP.GetValue(gameView);
        ////Debug.Log(targetInView.ToString());

        ////position.width = targetInView.width;
        ////position.height = targetInView.height;

        ////position.width = targetSize.x * defaultScale;
        ////position.height = targetSize.y * defaultScale + kWindowToolbarHeight;
        //position.width = size.x;
        //position.height = size.y;

        //positionP.SetValue(gameView, position);
        //Debug.Log(position.ToString());
#endif
        return null;
    }
    [RPC]
    private object ClickScreenPos(List<object> param)
    {
        if (param == null)
        {
            return false;
        }
        return ClickScreenPos(new Vector2((float)param[0], (float)param[1]));
    }
    public bool ClickScreenPos(Vector2 screenPos)
    {
        Log($"[Automated Test]click screen pos {screenPos}");
        if (EventSystem.current != null)
        {
            var eventData = new PointerEventData(EventSystem.current);
            eventData.position = screenPos;
            List<RaycastResult> list = new List<RaycastResult>();
            EventSystem.current.RaycastAll(eventData, list);
            if (list.Count > 0)
            {
                var finalObject = ExecuteEvents.GetEventHandler<IEventSystemHandler>(list[0].gameObject);
                if (finalObject == null)
                {
                    Log($"[Automated Test]click failed {screenPos}");
                }
                else
                {
                    //Log($"[Automated Test]click success {screenPos} at gameobject {finalObject.name}");
                    ExecuteEvents.Execute(finalObject, eventData, ExecuteEvents.pointerDownHandler);
                    ExecuteEvents.Execute(finalObject, eventData, ExecuteEvents.pointerClickHandler);
                    ExecuteEvents.Execute(finalObject, eventData, ExecuteEvents.pointerUpHandler);

                    return true;
                }
            }
        }
        return false;
    }

    [RPC]
    private object Click(List<object> param)
    {
        if (param == null)
        {
            return false;
        }
        return Click((string)param[0]);
    }

    private bool Click(string uiName)
    {
        var uiObj = GameObject.Find(uiName);
        if (uiObj == null)
        {
            return false;
        }
        return Click(uiObj);
    }

    private bool Click(GameObject go)
    { 
        SendPointClickEvent(go);
        return true;
    }

    [RPC]
    private object UIExists(List<object> param)
    {
        if (param == null)
        {
            return false;
        }
        var parNum = param.Count;
        if (parNum <= 0)
        {
            return false;
        }
        if (!(param[0] is string))
        {
            return false;
        }
        return UIExists((string)(param[0]));
    }
    private bool UIExists(string uiName)
    { 
        var ui_obj = GameObject.Find(uiName);
        return ui_obj != null && ui_obj.activeInHierarchy;
    }
    [RPC]
    private object Login(List<object> param)
    {
        StartCoroutine(YieldLogin((string)param[0]));
        return null;
    }
    public IEnumerator YieldLogin(string tag, string serverName = "", string account = "", string password = "")
    {
        Log("[Automated Test]login start " + tag);

        testStatus[tag] = TestStatus.Running;

        var wfs1 = new WaitForSeconds(1);
        var account_btn = "OCX_AccountBtn";
        var ok_btn = "OCX_text_ok";
		var agree_btn = "OCX_Enter";
		while (UIExists(account_btn) == false)
        {
            if (UIExists(ok_btn))
            {
                Click(ok_btn);
            }
            yield return wfs1;
        }

        Click(account_btn);
        yield return new WaitForSeconds(1);
		if (UIExists(agree_btn))
		{
			Click(agree_btn);
		}

		if (string.IsNullOrEmpty(account))
        {
            var TabMenu = "OCX_TabMenu";
            while (!UIExists(TabMenu))
            {
                yield return wfs1;
            }
            var TabMenuGO = GameObject.Find(TabMenu);
            for (var i = 0; i < TabMenuGO.transform.childCount; ++i)
            {
                var child = TabMenuGO.transform.GetChild(i);
                if (child.name == "Layout")
                {
                    Click(child.transform.GetChild(1).gameObject);
                    break;
                }
            }
            yield return new WaitForSeconds(1);

            account = GenAccount();
        }
        if (string.IsNullOrEmpty(password))
        {
            password = "123456";
        }
		var AccountIptGO = GameObject.Find("AccountIpt").transform.GetChild(0);
		var accountIpu = AccountIptGO.GetComponent<InputField>();
		accountIpu.text = account;

		var PasswordIptGO = GameObject.Find("PasswordIpt").transform.GetChild(0);
		var passwordIpt = PasswordIptGO.GetComponent<InputField>();
		passwordIpt.text = password;

        yield return YieldClick("OCX_LoginOrRegisterBtn");

        if (!string.IsNullOrEmpty(serverName))
        {
			yield return YieldClick("OCX_RoleServerInfoBtn");
			var srvListGo = GameObject.Find("OCX_ServerListGV/Viewport/Content");
			var needBreak = false;
            for (int i = 0; i < srvListGo.transform.childCount; ++i)
            {
                var child = srvListGo.transform.GetChild(i);
                var texts = child.GetComponentsInChildren<TextMeshProUGUI>();
                foreach (var text in texts)
                {
                    if (text.text.Contains(serverName))
                    {
                        Click(child.gameObject);
                        needBreak = true;
                        break;
                    }
                }
                if (needBreak)
                {
                    break;
                }
            }
        }
        yield return YieldClick("OCX_EnterGameBtn");

        testStatus[tag] = TestStatus.Success;
        Log("[Automated Test]login finish " + tag);
    }

    public IEnumerator YieldRegister(string tag, string account = "", string password = "", bool needLogin = true)
    {
        Log("[Automated Test]register start " + tag);

        testStatus[tag] = TestStatus.Running;

        var wfs1 = new WaitForSeconds(1);
        var account_btn = "OCX_AccountBtn";
        var ok_btn = "OCX_text_ok";
        var agree_btn = "OCX_Enter";
        while (UIExists(account_btn) == false)
        {
            if (UIExists(ok_btn))
            {
                Click(ok_btn);
            }
            yield return wfs1;
        }

        Click(account_btn);
        yield return new WaitForSeconds(1);
        if (UIExists(agree_btn))
        {
            Click(agree_btn);
        }

        if (string.IsNullOrEmpty(account))
        {
            account = GenAccount();
        }
        if (string.IsNullOrEmpty(password))
        {
            password = "123456";
        }

        var TabMenu = "OCX_TabMenu";
        while (!UIExists(TabMenu))
        {
            yield return wfs1;
        }
        var TabMenuGO = GameObject.Find(TabMenu);
        for (var i = 0; i < TabMenuGO.transform.childCount; ++i)
        {
            var child = TabMenuGO.transform.GetChild(i);
            if (child.name == "Layout")
            {
                Click(child.transform.GetChild(1).gameObject);
                break;
            }
        }
        yield return new WaitForSeconds(1);

        var AccountIptGO = GameObject.Find("AccountIpt").transform.GetChild(0);
        var accountIpu = AccountIptGO.GetComponent<InputField>();
        accountIpu.text = account;

        var PasswordIptGO = GameObject.Find("PasswordIpt").transform.GetChild(0);
        var passwordIpt = PasswordIptGO.GetComponent<InputField>();
        passwordIpt.text = password;

        yield return YieldClick("OCX_LoginOrRegisterBtn");

        yield return new WaitForSeconds(1);

        if (needLogin)
        {
            yield return YieldClick("OCX_EnterGameBtn");
        }

        testStatus[tag] = TestStatus.Success;
        Log("[Automated Test]register finish " + tag);
    }

    private string GenAccount()
    {
        var account = DateTime.Now.ToString("MMddHHmmssfff");
        var ascii = ((new System.Random()).Next(0, 26) + 97).ToString();
        byte[] array = new byte[1];
        array[0] = (byte)(Convert.ToInt32(ascii));
        string c = Convert.ToString(Encoding.ASCII.GetString(array));
        account = c + account;

        return account;
    }

    [RPC]
    private object Guide1(List<object> param)
    {
        StartCoroutine(YieldGuide1((string)param[0]));
        return null;
    }

    [RPC]
    public object GMOpenGuide(List<object> param = null)
    {
        GMOpenGuide(param == null || (bool)param[0]);
        return null;
    }
    public void GMOpenGuide(bool open)
    {
		XLua.LuaTable table = PapeGames.X3.X3Lua.DoRequire("Runtime.System.X3Game.Modules.ChapterStageManager")[0] as XLua.LuaTable;
		var f_SetIsOpenProStage = table.Get<XLua.LuaFunction>("SetIsOpenProStage");
		f_SetIsOpenProStage?.Call(open);
    }

    [RPC]
    public object GMCommand(List<object> param=null)
    {
        var cmd = (string)param[0];
		Debug.Log($"run gm {cmd}");
		var tb = (X3Lua.DoRequire("Runtime.DebugGM.AutoTest.AutoTestUtil")[0]) as LuaTable;
		Action<string> gm = tb.Get<Action<string>>("RunGM");
		gm?.Invoke(cmd);
        return null;
	}

    [RPC]
    public object GMGuideOpen(List<object> param = null)
    {
        GMGuideOpen(param != null && (bool)param[0]);
        return null;
    }

    public void GMGuideOpen(bool open)
    { 
        LuaTable l_PlayerPrefs = X3Lua.DoRequire("Runtime.System.Framework.Engine.PlayerPrefs")[0] as XLua.LuaTable;
        var f_SetInt = l_PlayerPrefs.Get<LuaFunction>("SetInt");
        f_SetInt?.Call("GuideOpen", open ? 1 : 0);
    }

    [RPC]
    public object GMGuideAutoGuideOpen(List<object> param = null)
    {
        GMGuideAutoGuideOpen(param != null && (bool)param[0]);
        return null;
    }
    public void GMGuideAutoGuideOpen(bool open)
	{
		LuaTable l_PlayerPrefs = X3Lua.DoRequire("Runtime.System.Framework.Engine.PlayerPrefs")[0] as XLua.LuaTable;
		var f_SetInt = l_PlayerPrefs.Get<LuaFunction>("SetInt");
        f_SetInt?.Call("GuideAutoGuideOpen", open ? 1 : 0);
    }

    [RPC]
    public object GMGuideManualGuideOpen(List<object> param = null)
    {
        GMGuideManualGuideOpen(param != null && (bool)param[0]);
        return null;
    }
    public void GMGuideManualGuideOpen(bool open)
    { 
        LuaTable l_PlayerPrefs = X3Lua.DoRequire("Runtime.System.Framework.Engine.PlayerPrefs")[0] as XLua.LuaTable;
        var f_SetInt = l_PlayerPrefs.Get<LuaFunction>("SetInt");
        f_SetInt?.Call("GuideManualGuideOpen", open ? 1 : 0);
    }

    [RPC]
    public object TestStartBattle(List<object> param = null)
    {
		X3Battle.BattleClient.OnStartupFinished.AddListener(OnBattleStart);
		X3Battle.BattleClient.OnStartupFinished.AddListener(OnBattleStart);
        //在战斗开始前采集内存快照
        string fileName = "BattleBeginBefore_";
        string time = "_Time=" + Time.time;
        string battle = "_levelID=" + (string) param[0] + "_girlSuitID=" + (string) param[1] + "_boySuitID=" +
                        (string) param[3] + "_boyID=" + (string) param[4] + "_girlWeaponID=" + (string) param[5];
        fileName += time;
        fileName += battle;
        _tempBattleName = battle;
#if ProfilerEnable
        Paper.U3dProfiler.MemoryProfiler.TakeMemorySnapShot(fileName);
#endif
        testStatus["TestStartBattle"] = TestStatus.Running;
        X3Battle.Debugger.Utils.TestStartBattle(int.Parse((string)param[0]), int.Parse((string)param[1]), int.Parse((string)param[2]), int.Parse((string)param[3]), int.Parse((string)param[4]), int.Parse((string)param[5]));

        return null;
    }

    private void OnBattleStart()
    {
        StartCoroutine(CoroutineFunc());
        X3Battle.Battle.Instance.eventMgr.AddListener<X3Battle.EventBattleEnd>(X3Battle.EventType.OnBattleEnd, OnBattleEnd, "PocoManager:OnBattleStart");
        X3Battle.Battle.Instance.eventMgr.AddListener<X3Battle.ECEventDataBase>(X3Battle.EventType.OnLevelStart, OnLevelStart, "PocoManager:OnBattleStart");
	}

    private void OnLevelStart(X3Battle.ECEventDataBase arg)
    {
        //在战斗开始后采集内存快照
        var battleArg = X3Battle.Battle.Instance.arg;
        string fileName = "BattleBeginAfter_";
        string time = "Time=" + Time.time;
        string battle = "_levelID=" + battleArg.levelID + "_girlSuitID=" + battleArg.girlSuitID + "_boySuitID=" +
                        battleArg.boySuitID + "_boyID=" + battleArg.boyID + "_girlWeaponID=" + battleArg.girlWeaponID;
        fileName += time;
        fileName += battle;
#if ProfilerEnable
        Paper.U3dProfiler.MemoryProfiler.TakeMemorySnapShot(fileName);
#endif
    }

    IEnumerator CoroutineFunc()
    {
        yield return new WaitForSeconds(5.0f);
        X3Battle.BattleEnv.LuaBridge.CloseLevelPopUI();
    }
    
    private void OnBattleEnd(X3Battle.EventBattleEnd arg)
    {
        //在战斗结束前采集内存快照
        var battleArg = X3Battle.Battle.Instance.arg;
        string fileName = "BattleEndBefore_";
        string time = "Time=" + Time.time;
        string battle = "_levelID=" + battleArg.levelID + "_girlSuitID=" + battleArg.girlSuitID + "_boySuitID=" +
                        battleArg.boySuitID + "_boyID=" + battleArg.boyID + "_girlWeaponID=" + battleArg.girlWeaponID;
        fileName += time;
        fileName += battle;
#if ProfilerEnable
        Paper.U3dProfiler.MemoryProfiler.TakeMemorySnapShot(fileName);
#endif
    }

    [RPC]
    private object CheckBattleFinished(List<object> param = null)
    {
        if (X3Battle.BattleEnv.LuaBridge.GetGameStateMgrState() == "Login")
        {
            //在战斗结束后采集内存快照
            string fileName = "BattleEndAfter_";
            string time = "Time=" + Time.time;
            fileName += time;
            fileName += _tempBattleName;
#if ProfilerEnable
        Paper.U3dProfiler.MemoryProfiler.TakeMemorySnapShot(fileName);
#endif
            testStatus["TestStartBattle"] = TestStatus.Success;
        }
        return testStatus["TestStartBattle"];
    }

    [RPC]
    public object CallCSharp(List<object> param = null)
    {
        var moduleName = (string)param[0];
        var className = (string)param[1];
        var methodName = (string)param[2];
        var isStatic = (bool)param[3];
        var isPublic = (bool)param[4];
        var pars = new List<string>();
        for (int i = 5; i < param.Count; ++i)
        {
            pars.Add((string)param[i]);
		}
        return AutoTestCallCS.CallCSharp(moduleName, className, methodName, isStatic, isPublic, pars);
    }

    [RPC]
    public object CallLua(List<object> param = null)
    {
        var moduleName = (string)param[0];
		var methodName = (string)param[1];
		var pars = new List<string>();
		for (int i = 2; i < param.Count; ++i)
        {
            pars.Add((string)param[i]);
		}
		return AutoTestCallLua.CallLua(moduleName, methodName, pars);
    }

    [RPC]
    public object MemorySnapshot(List<object> param = null)
    {
        string fileName = null;
        if (param != null)
        {
            if (param.Count > 0)
            {
				fileName = (string)param[0];
			}
		}
#if ProfilerEnable
        Paper.U3dProfiler.MemoryProfiler.TakeMemorySnapShot(fileName);
#endif
		return null;
    }

    public IEnumerator YieldUpdate(string tag)
    {
        Log("[Automated Test]start " + tag);
        testStatus[tag] = TestStatus.Running;
        var wfs1 = new WaitForSeconds(1);
        var agree_btn = "OCX_Enter";
        var account_btn = "OCX_AccountBtn";
        var ok_btn = "OCX_text_ok";
        while (UIExists(account_btn) == false)
        {
            if (UIExists(ok_btn))
            {
                Click(ok_btn);
            }
            if (UIExists(agree_btn))
            {
                Click(agree_btn);
            }
            yield return wfs1;
        }
    }

	public IEnumerator YieldGuide1(string tag)
    {
        Log("[Automated Test]start " + tag);
        testStatus[tag] = TestStatus.Running;
        var wfs1 = new WaitForSeconds(1);
        var agree_btn = "OCX_Enter";
        var account_btn = "OCX_AccountBtn";
        var ok_btn = "OCX_text_ok";
        while (UIExists(account_btn) == false)
        {
            if (UIExists(ok_btn))
            {
                Click(ok_btn);
            }
            if (UIExists(agree_btn))
            {
                Click(agree_btn);
            }
            yield return wfs1;
        }

        Click(account_btn);
        yield return new WaitForSeconds(1);
		if (UIExists(agree_btn))
		{
			Click(agree_btn);
		}
		var TabMenu = "OCX_TabMenu";
        while (!UIExists(TabMenu))
        {
            yield return wfs1;
        }
        var TabMenuGO = GameObject.Find(TabMenu);
        for (var i = 0; i < TabMenuGO.transform.childCount; ++i)
        {
            var child = TabMenuGO.transform.GetChild(i);
			if (child.name == "Layout")
            {
				Click(child.transform.GetChild(1).gameObject);
				break;
			}
        }
        yield return new WaitForSeconds(1);

        var AccountIptGO = GameObject.Find("AccountIpt").transform.GetChild(0);
        var accountIpu = AccountIptGO.GetComponent<InputField>();
        var account = DateTime.Now.ToString("yyyyMMddHHmmss");
        accountIpu.text = account;

        var PasswordIptGO = GameObject.Find("PasswordIpt").transform.GetChild(0);
        var passwordIpt = PasswordIptGO.GetComponent<InputField>();
        var pwd = "123456";
        passwordIpt.text = pwd;

        GMOpenGuide();

        yield return YieldClick("OCX_LoginOrRegisterBtn");
        yield return YieldClick("OCX_EnterGameBtn");
        yield return new WaitForSeconds(5);
        yield return YieldClick("OCX_Btn_Confirm");
		yield return YieldClick("OCX_StyleNextBtn");
		yield return YieldClick("OCX_StyleNextBtn");
		yield return YieldClick("OCX_btn_ok");
		yield return YieldClick("OCX_SavingBtn");
		yield return YieldClick("OCX_sure3ApplyBtn");
        //yield return YieldSpeed();
        TimeScale(2);
        yield return YieldClick("OCX_btn_QTE");
        yield return YieldClick("OCX_btn_QTE");
        yield return YieldClick("OCX_btn_QTE");
        yield return YieldLongTouch("OCX_Mask", 10F);
        yield return YieldClick("OCX_btnRand");
        yield return YieldClick("OCX_btnConfirm");
        yield return YieldClick("OCX_btn_ok");
        yield return YieldClick("OCX_btn_Click");
        yield return YieldClick("OCX_btn_QTE");
        yield return YieldSleep(10F);
        //yield return YieldSpeed();
        TimeScale(2);
        yield return YieldClick("OCX_btn_Confirm");
        yield return YieldClick("OCX_btn_QTE");
        yield return YieldClick("OCX_btn_Confirm");
        yield return YieldClick("OCX_btn_ToFight");
        TimeScale(1);
        //StopRecord(null);
        yield return YieldWaitUIAppeare("LoadingWnd(UITips-20)");

        testStatus[tag] = TestStatus.Success;
        Log("[Automated Test]finish " + tag);
    }

    [RPC]
    private object Battle(List<object> param)
    {
        StartCoroutine(YieldBattle((string)param[0]));
        return null;
    }

    public IEnumerator YieldBattle(string tag)
    {
        Log("[Automated Test]start " + tag);
        testStatus[tag] = TestStatus.Running;
        yield return YieldWaitUIDisappeare("LoadingWnd(UITips-20)");
        yield return YieldSleep(3F);

        //while (!UIExists("BattleMonsterInf(UIPopup-10)"))
        var startTime = Time.time;
        while (Time.time - startTime < 5F)
        {
            UpdateJoystick(JoystickDir.Up);
            yield return null;
        }

        var attackSkillObj = GameObject.Find("OCX_AttackSkill");
        //var attackSkillBtn = attackSkillObj.GetComponent<X3Button>();
        //var attackSkillPos = cam.WorldToScreenPoint(attackSkillObj.transform.position);

        //var positiveSkillObj = GameObject.Find("OCX_PositiveSkill");
        //var positiveSkillBtn = positiveSkillObj.GetComponent<X3Button>();
        //var positiveSkillPos = cam.WorldToScreenPoint(positiveSkillObj.transform.position);

        //var coopSkillObj = GameObject.Find("OCX_CoopSkill");
        //var coopSkillBtn = coopSkillObj.GetComponent<X3Button>();
        //var coopSkillPos = cam.WorldToScreenPoint(coopSkillObj.transform.position);

        //var powerSkillObj = GameObject.Find("OCX_PowerSkill");
        //var powerSkillBtn = powerSkillObj.GetComponent<X3Button>();
        //var powerSkillPos = cam.WorldToScreenPoint(powerSkillObj.transform.position);

        var wfs5 = new WaitForSeconds(5);
        var wfs03 = new WaitForSeconds(0.3F);
        while (true)
        {
            if (UIExists("OCX_Tips(Clone)"))
            {
                var tipsParent = GameObject.Find("OCX_Tips(Clone)");
                var tmp = tipsParent.GetComponentInChildren<TextMeshProUGUI>();
                if (tmp.text.Contains("共鸣"))
                {
                    SendGuideClickEvent("NoviceGuideWnd(UITips-30)/Root/OCX_Guide_Click/click_area");
                    yield return wfs5;
                    continue;
                }
                else if(tmp.text.Contains("誓约"))
                {
                    SendGuideClickEvent("NoviceGuideWnd(UITips-30)/Root/OCX_Guide_Click/click_area");
                    yield return wfs5;
                    continue;
                }
            }

            for (int i = 0; i < 6; ++i)
            {
                SendPointClickEvent(attackSkillObj);
                yield return wfs03;
            }
            var levelUpWnd = GameObject.Find("LevelUpWnd(UIPopup-0)");
            if (levelUpWnd != null)
            {
                break;
            }
            var battleResultWnd = GameObject.Find("BattleResultWnd(UIPopup-0)");
            if (battleResultWnd != null)
            {
                break;
            }
        }
        yield return YieldClick("OCX_img_Close");
        //StopRecord(null);
        yield return YieldWaitUIAppeare("LoadingWnd(UITips-20)");
        testStatus[tag] = TestStatus.Success;
        Log("[Automated Test]finish " + tag);
    }

    [RPC]
    private object Guide2(List<object> param)
    {
        StartCoroutine(YieldGuide2((string)param[0]));
        return null;
    }

    public IEnumerator YieldGuide2(string tag)
    {
        Log("[Automated Test]start " + tag);
        testStatus[tag] = TestStatus.Running;
        yield return YieldWaitUIDisappeare("LoadingWnd(UITips-20)");
        var wfs = new WaitForSeconds(1);
        while (true)
        {
            TimeScale(2);
            //yield return YieldSpeed(true);
            if (UIExists("ComRewardTips(UIPopup-0)"))
            {
                break;
            }
            yield return wfs;
        }
        TimeScale(1);
        yield return YieldClick("PanelTransparentMask");
        yield return YieldClick("PanelTransparentMask");
        yield return YieldClick("OCX_btnBack");
        //StopRecord(null);
        testStatus[tag] = TestStatus.Success;
        Log("[Automated Test]finish " + tag);
    }

    [RPC]
    private object CheckTestFinished(List<object> param)
    {
        testStatus.TryGetValue((string)param[0], out TestStatus ret);
        return (int)ret;
    }

    [RPC]
    private object RunFlow(List<object> param)
    {
        var flowName = (string)param[0];
        Log($"RunFlow {flowName}");

        testStatus.Clear();
        testStatus[flowName] = TestStatus.Running;

        FlowAutoTestMgr.Instance.StartFlowScript(flowName);
        FlowAutoTestMgr.Instance.RegisterStopEvent((bool success) =>
        {
            if (success)
            {
                testStatus[flowName] = TestStatus.Success;
            }
            else
            {
                testStatus[flowName] = TestStatus.Failure;
            }
        });
        return null;
    }

    [RPC]
    public object RunFlowByJson(List<object> param)
    {
        var url = (string)param[0];
        Log($"RunFlowByJson {url}");

        testStatus.Clear();
        testStatus[url] = TestStatus.Running;

        FlowAutoTestMgr.Instance.StartFlowScriptJsonUrl(url);
        FlowAutoTestMgr.Instance.RegisterStopEvent((bool success) =>
        {
            if (success)
            {
                testStatus[url] = TestStatus.Success;
            }
            else
            {
                testStatus[url] = TestStatus.Failure;
            }
        });
        return null;
    }

    //[RPC]
    //public object Record(List<object> param)
    //{
    //    var width = int.Parse((string)param[1]);
    //    var height = int.Parse((string)param[2]);
    //    StartCoroutine(YieldRecord((string)param[0], width, height));
    //    return null;
    //}

    //private IEnumerator YieldRecord(string outputPath, int width, int height)
    //{
    //    Log("[Automated Test]start record " + outputPath);
    //    recordOutputPath = outputPath;
    //    var controllerSettings = ScriptableObject.CreateInstance<RecorderControllerSettings>();
    //    var TestRecorderController = new RecorderController(controllerSettings);

    //    var videoRecorder = ScriptableObject.CreateInstance<MovieRecorderSettings>();
    //    videoRecorder.name = "Automated Test Recorder";
    //    videoRecorder.Enabled = true;
    //    videoRecorder.VideoBitRateMode = UnityEditor.VideoBitrateMode.High;

    //    videoRecorder.RecordMode = RecordMode.Manual;
    //    videoRecorder.ImageInputSettings = new UnityEditor.Recorder.Input.GameViewInputSettings
    //    {
    //        OutputHeight = height,
    //        OutputWidth = width,
    //    };

    //    videoRecorder.AudioInputSettings.PreserveAudio = true;
    //    videoRecorder.OutputFile = outputPath; // no extension

    //    controllerSettings.AddRecorderSettings(videoRecorder);
    //    //controllerSettings.SetRecordModeToFrameInterval(0, 59); // 2s @ 30 FPS
    //    controllerSettings.FrameRate = 30;

    //    RecorderOptions.VerboseMode = false;
    //    TestRecorderController.PrepareRecording();
    //    TestRecorderController.StartRecording();
    //    record = true;
    //    while (record)
    //    {
    //        yield return null;
    //    }
    //    TestRecorderController.StopRecording();
    //    Log("[Automated Test]finish record " + outputPath);
    //}

    //[RPC]
    //public object StopRecord(List<object> param)
    //{
    //    record = false;
    //    return null;
    //}
    [RPC]
    private object test(List<object> param)
    {
        StartCoroutine(YieldTest());
        return null;
    }
    
    [RPC]
    //用于检查加载错误bnk会导致崩溃的问题//进入登录界面调用即可
    private object CheckAllWwiseBnkIsAvailable(List<object> param)
    {
        //0为失败，1为成功
        int result = 0;

        bool res = WwiseManager.Instance.CheckAllBnkAvailable();
        result = res ? 1 : 0;
        return result;
    }

    [RPC]
    private object CheckModelInBattle(List<object> param)
    {
        Log("[Automated Test]CheckModelInBattle");
        return AirAutoTest.Instance.CheckModel();
    }

    [RPC]
    private object LogOut(List<object> param)
    {
        Log("[Automated Test]LogOut");
        AirAutoTest.Instance.DoDisconnection();
        return null;
    }


    IEnumerator YieldTest()
    {
        //yield return YieldClick("EnterGameBtn");
        //yield return YieldClick("OCX_btn_ToFight");
        //yield return YieldWaitUIAppeare("LoadingWnd(UITips-20)");
        //yield return YieldWaitUIDisappeare("LoadingWnd(UITips-20)");
        //yield return YieldSleep(3F));
        yield return YieldGuide1("Guide1");
        yield return YieldBattle("Battle");
        yield return YieldGuide2("Guide2");
    }

    private IEnumerator SendPointLongTouchEvent(X3Button handler, float time)
    {
        Log("[Automated Test]long click " + handler.transform.name);

        var ped = new PointerEventData(EventSystem.current);
        handler.OnPointerDown(ped);
        yield return new WaitForSeconds(time);
        handler.OnPointerUp(ped);
        Log("[Automated Test]long click end " + handler.transform.name);
    }

    private void SendPointClickEvent(GameObject targetObject)
    {
        if (targetObject == null)
        {
            Log("[Automated Test]click obj null");
            return;
        }
        var finalObject = ExecuteEvents.GetEventHandler<IEventSystemHandler>(targetObject); //找到真实引用
        //if (finalObject.GetComponentsInChildren<FxClickHandler>(true).Length > 0)
        //    finalObject.GetComponentsInChildren<FxClickHandler>(true)[0].IgnoreTimelimit = true;
        PointerEventData data = new PointerEventData(EventSystem.current);
        data.position = PapeGames.X3.RTUtility.GetCachedUICamera().WorldToScreenPoint(targetObject.transform.position);
        ExecuteEvents.Execute(finalObject, data, ExecuteEvents.pointerDownHandler);
        ExecuteEvents.Execute(finalObject, data, ExecuteEvents.pointerUpHandler);
        ExecuteEvents.Execute(finalObject, data, ExecuteEvents.pointerClickHandler);
        //if (finalObject.GetComponentsInChildren<FxClickHandler>(true).Length > 0)
        //    finalObject.GetComponentsInChildren<FxClickHandler>(true)[0].IgnoreTimelimit = false;
        Log("[Automated Test]click " + targetObject.name);
    }

    private void SendGuideClickEvent(string btnName)
    {
        var btnGo = GameObject.Find(btnName);
        if (btnGo == null)
        {
            Log("[Automated Test]click guide null");
            return;
        }
        var instance = EventSystem.current.currentInputModule;
        var t = Type.GetType("UnityEngine.EventSystems.X3InputModule,Assembly-CSharp");
        var m = t.GetMethod("ReleaseMouse", BindingFlags.NonPublic | BindingFlags.Instance);
        var pointerEvent = new PointerEventData(EventSystem.current);
        pointerEvent.pointerPress = btnGo;
        pointerEvent.eligibleForClick = true;
        m.Invoke(instance, new object[] { pointerEvent, btnGo });
        Log($"[Automated Test]click guide {btnName}");
    }

    enum JoystickDir
    {
        Left,
        Right,
        Up,
        Down
    }
    private Vector2 m_DragKeyBoardVector;
    private bool m_IsPressKeyCode = false;
    private int m_PreVertKeyCode = 0;
    private int m_PreHoriKeyCode = 0;

    private void UpdateJoystick(JoystickDir jd)
    {
        Log("[Automated Test]UpdateJoystick");

        m_DragKeyBoardVector = Vector2.zero;
        var prevIsPress = m_IsPressKeyCode;
        m_IsPressKeyCode = false;

        var isUpPress = jd == JoystickDir.Up;
        var isDownPress = jd == JoystickDir.Down;
        var isLeftPress = jd == JoystickDir.Left;
        var isRightPress = jd == JoystickDir.Right;

        //如果同时按下，保持之前的按键不变
        if (isUpPress && isDownPress)
        {
            m_IsPressKeyCode = true;
            m_DragKeyBoardVector = new Vector2(m_DragKeyBoardVector.x,
                m_PreVertKeyCode == (int)KeyCode.UpArrow ? -1 : 1);
        }
        else if (isUpPress)
        {
            m_IsPressKeyCode = true;
            m_DragKeyBoardVector = new Vector2(m_DragKeyBoardVector.x, 1);
            m_PreVertKeyCode = (int)KeyCode.UpArrow;
        }
        else if (isDownPress)
        {
            m_IsPressKeyCode = true;
            m_DragKeyBoardVector = new Vector2(m_DragKeyBoardVector.x, -1);
            m_PreVertKeyCode = (int)KeyCode.DownArrow;
        }

        //如果同时按下，保持之前的按键不变
        if (isLeftPress && isRightPress)
        {
            m_IsPressKeyCode = true;
            m_DragKeyBoardVector = new Vector2(m_PreHoriKeyCode == (int)KeyCode.RightArrow ? -1 : 1,
                m_DragKeyBoardVector.y);
        }
        else if (isLeftPress)
        {
            m_IsPressKeyCode = true;
            m_DragKeyBoardVector = new Vector2(-1, m_DragKeyBoardVector.y);
            m_PreHoriKeyCode = (int)KeyCode.LeftArrow;
        }
        else if (isRightPress)
        {
            m_IsPressKeyCode = true;
            m_DragKeyBoardVector = new Vector2(1, m_DragKeyBoardVector.y);
            m_PreHoriKeyCode = (int)KeyCode.RightArrow;
        }

        var btnName = "OCX_Joystick";
        var go = GameObject.Find(btnName);
        if (go == null)
        {
            Log("[Automated Test]UpdateJoystick go null");
            return;
        }
        var joystick = go.GetComponent("X3Joystick");
        if (joystick == null)
        {
            Log("[Automated Test]UpdateJoystick joystick null");
            return;
        }
        var joystickType = Type.GetType("PapeGames.X3UI.X3Joystick,Assembly-CSharp");

        var OnJoystickDown = (UnityAction<PointerEventData>)joystickType.GetField("OnJoystickDown", BindingFlags.Instance | BindingFlags.Public).GetValue(joystick);
        var OnJoystickUp = (UnityAction<PointerEventData>)joystickType.GetField("OnJoystickUp", BindingFlags.Instance | BindingFlags.Public).GetValue(joystick);
        var OnJoystickUpdate = (UnityAction<Vector2>)joystickType.GetField("OnJoystickUpdate", BindingFlags.Instance | BindingFlags.Public).GetValue(joystick);
        var OnJoystickXYUpdate= (UnityAction<float, float>)joystickType.GetField("OnJoystickXYUpdate", BindingFlags.Instance | BindingFlags.Public).GetValue(joystick);

        if (!prevIsPress && m_IsPressKeyCode)
        {
            if (OnJoystickDown != null)
            {
                OnJoystickDown(null);
            }
        }


        if (prevIsPress && !m_IsPressKeyCode)
        {
            if (OnJoystickUp != null)
            {
                OnJoystickUp(null);
            }
        }

        if (m_IsPressKeyCode)
        {
            if (OnJoystickUpdate != null)
            {
                OnJoystickUpdate(m_DragKeyBoardVector.normalized);
            }

            if (OnJoystickXYUpdate != null)
            {
                var dir = m_DragKeyBoardVector.normalized;
                OnJoystickXYUpdate(dir.x, dir.y);
            }
        }
    }
    public IEnumerator YieldClick(string btnName)
    {
        var wfs = new WaitForSeconds(1);
        while(!UIExists(btnName))
        { 
            yield return wfs;
        }
        Click(btnName);
        clickedBtns.Add(btnName);
        yield return wfs;
    }
    private IEnumerator YieldLongTouch(string btnName, float time)
    {
        var wfs = new WaitForSeconds(1);
        while(!UIExists(btnName))
        { 
            yield return wfs;
        }
        yield return new WaitForSeconds(2);
        var btnObj = GameObject.Find(btnName);
        var btn = btnObj.GetComponent<X3Button>();
        yield return SendPointLongTouchEvent(btn, time);
        clickedBtns.Add(btnName);
    }
    private IEnumerator YieldDrag(string btnName, Vector2 dir, float time)
    {
        var go = GameObject.Find(btnName);

        var idown = go.GetComponent<IPointerDownHandler>();
        var pedDown = new PointerEventData(EventSystem.current);
        idown.OnPointerDown(pedDown);
        yield return new WaitForSeconds(0.1F);

        var pedDown1 = new PointerEventData(EventSystem.current);

        var cam = GameObject.Find("UICamera").GetComponent<Camera>();
        var goPos = (Vector2)cam.WorldToScreenPoint(go.transform.position);
        pedDown1.position = goPos + dir;
        Log($"[Automated Test]drag {goPos.ToString()}: {pedDown1.position} : {dir}");
        idown.OnPointerDown(pedDown1);
        yield return new WaitForSeconds(time);

        var iup = go.GetComponent<IPointerUpHandler>();
        var pedUp = new PointerEventData(EventSystem.current);
        iup.OnPointerUp(pedUp); 
    }
    private IEnumerator YieldWaitUIAppeare(string uiName)
    {
        Log($"[Automated Test]{uiName} appeare begin");
        while (!UIExists(uiName))
        {
            yield return null;
        }
        Log($"[Automated Test]{uiName} appeare end");
    }
    private IEnumerator YieldWaitUIDisappeare(string uiName)
    {
        Log($"[Automated Test]{uiName} disappeare begin");
        while (UIExists(uiName))
        {
            yield return null;
        }
        Log($"[Automated Test]{uiName} disappeare end");
    }
    private IEnumerator YieldSleep(float time)
    {
        Log($"[Automated Test]sleep {time}s");
        yield return new WaitForSeconds(time);
        Log($"[Automated Test]sleep {time}s end");
    }

    private void TimeScale(float time)
    {
        Log($"[Automated Test]TimeScale before {Time.timeScale}");
        if (Mathf.Abs(Time.timeScale - time) < 0.01F)
        {
            Log($"TimeScale after {Time.timeScale}");
            return;
        }
        Time.timeScale = time;
        Log($"[Automated Test]TimeScale after {Time.timeScale}");
    }

    private IEnumerator YieldSpeed(bool needBreak=false)
    {
        var btnName = "OCX_btn_speed";
        if (needBreak && !UIExists(btnName))
        {
            yield break;
        }
        while (!UIExists(btnName))
        {
            yield return null;
        }
        var btnGo = GameObject.Find(btnName);
        var ie = btnGo.GetComponent<ImageEnum>();
        while (ie.Current.name != "x3_story_btn_speed_03")
        {
            if (!btnGo.activeInHierarchy)
            {
                break;
            }
            SendPointClickEvent(btnGo);
            yield return null;
        }
    }
    public void EditorTest()
    {
        //StartCoroutine(YieldLogin(""));
        RunFlow(new List<object> { "Smoke/Login" });
    }

    private static void Log(string s)
    {
        var t = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");
        Debug.Log($"{t} {s}");
    }
}


public class RPCParser
{
    public delegate object RpcMethod(List<object> param);

    protected Dictionary<string, RpcMethod> RPCHandler = new Dictionary<string, RpcMethod>();
    private JsonSerializerSettings settings = new JsonSerializerSettings()
    {
        StringEscapeHandling = StringEscapeHandling.EscapeNonAscii
    };

    public string HandleMessage(string json)
    {
        Debug.Log($"[RPCParser]HandleMessage {json}");
        Dictionary<string, object> data = JsonConvert.DeserializeObject<Dictionary<string, object>>(json, settings);
        if (data.ContainsKey("method"))
        {
            string method = data["method"].ToString();
            List<object> param = null;
            if (data.ContainsKey("params"))
            {
                param = ((JArray)(data["params"])).ToObject<List<object>>();
            }

            object idAction = null;
            if (data.ContainsKey("id"))
            {
                // if it have id, it is a request
                idAction = data["id"];
            }

            string response = null;
            object result = null;
            try
            {
                var str_params = "";
                foreach(var p  in param)
                {
                    str_params += p.ToString();
                    str_params += ",";
                }
                char[] charsToTrim = { ','};
                str_params = str_params.TrimEnd(charsToTrim);

                Debug.Log($"{DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff")} [Automated Test]Handle rpc {method}({str_params})");

                result = RPCHandler[method](param);
            }
            catch (Exception e)
            {
                // return error response
                Debug.Log(e);
                response = formatResponseError(idAction, null, e);
                return response;
            }

            // return result response
            response = formatResponse(idAction, result);
            return response;

        }
        else
        {
            // do not handle response
            Debug.Log("ignore message without method");
            return null;
        }
    }

    // Call a method in the server
    public string formatRequest(string method, object idAction, List<object> param = null)
    {
        Dictionary<string, object> data = new Dictionary<string, object>();
        data["jsonrpc"] = "2.0";
        data["method"] = method;
        if (param != null)
        {
            data["params"] = JsonConvert.SerializeObject(param, settings);
        }
        // if idAction is null, it is a notification
        if (idAction != null)
        {
            data["id"] = idAction;
        }
        return JsonConvert.SerializeObject(data, settings);
    }

    // Send a response from a request the server made to this client
    public string formatResponse(object idAction, object result)
    {
        Dictionary<string, object> rpc = new Dictionary<string, object>();
        rpc["jsonrpc"] = "2.0";
        rpc["id"] = idAction;
        rpc["result"] = result;
        return JsonConvert.SerializeObject(rpc, settings);
    }

    // Send a error to the server from a request it made to this client
    public string formatResponseError(object idAction, IDictionary<string, object> data, Exception e)
    {
        Dictionary<string, object> rpc = new Dictionary<string, object>();
        rpc["jsonrpc"] = "2.0";
        rpc["id"] = idAction;

        Dictionary<string, object> errorDefinition = new Dictionary<string, object>();
        errorDefinition["code"] = 1;
        errorDefinition["message"] = e.ToString();

        if (data != null)
        {
            errorDefinition["data"] = data;
        }

        rpc["error"] = errorDefinition;
        return JsonConvert.SerializeObject(rpc, settings);
    }

    public void addRpcMethod(string name, RpcMethod method)
    {
        RPCHandler[name] = method;
    }
}
#endif
