using PapeGames.X3;
using UnityEditor;
using UnityEngine;

namespace X3Game
{
    [ExecuteInEditMode]
    [XLua.CSharpCallLua]
    public class GMCommandManager : MonoBehaviour
    {
        private static GMCommandManager m_Instance;
        private Vector3 oldPosition1;
        private Vector3 oldPosition2;
        private Vector3 oldPosition3;
        private Vector3 oldPosition4;
        private float cd = 0f;

        public static float SkillDamageZoomFactorValue = 1.0f;

        private static float lastClickTime = -1;
        private static int clickTimes = 0;

        private bool hasTriggered = false;

        public static void Init()
        {
#if DEBUG_GM
            if (m_Instance == null)
            {
                GameObject goInput = new GameObject();
                goInput.name = "GMCommandManager";
                m_Instance = goInput.AddComponent<GMCommandManager>();
#if UNITY_EDITOR
                if (EditorApplication.isPlaying)
                    DontDestroyOnLoad(goInput);
#else
            DontDestroyOnLoad(goInput);
#endif
            }
#endif
        }
        
        private void Update()
        {
#if !DEBUG_GM
                return;
#endif


            if (Input.GetKeyUp(KeyCode.Return))
            {
                if (UIViewUtility.IsOpened("GMEntranceTopWnd"))
                {
                    CloseGmWnd();
                }
                else if (UIViewUtility.IsOpened("GMWnd") == false)
                {
                    OpenGmWnd();
                }
            }

            if (Input.GetKeyDown(KeyCode.UpArrow))
            {
                EventMgr.Dispatch("GMCommandShowPre", null);
            }

            if (Input.GetKeyDown(KeyCode.DownArrow))
            {
                EventMgr.Dispatch("GMCommandShowNext", null);
            }

            if (Input.GetMouseButtonDown(0))
            {
                hasTriggered = false;
            }

            if (Input.GetMouseButtonUp(0))
            {
                if (CheckClickArea(Input.mousePosition))
                {
                    float curtime = Time.unscaledDeltaTime;
                    if (curtime - lastClickTime < 0.4)
                    {
                        clickTimes++;
                    }
                    else
                    {
                        clickTimes = 0;
                    }

                    lastClickTime = curtime;

                    if (clickTimes >= 5)
                    {
                        clickTimes = 0;
                        if (UIViewUtility.IsOpened("GMEntranceTopWnd"))
                        {
                            CloseGmWnd();
                        }
                        else if (UIViewUtility.IsOpened("GMWnd") == false)
                        {
                            OpenGmWnd();
                        }
                    }
                }
            }

            if (Input.touchCount == 4)
            {
                Touch t1 = Input.GetTouch(0);
                Touch t2 = Input.GetTouch(1);
                Touch t3 = Input.GetTouch(2);
                Touch t4 = Input.GetTouch(3);

                if (t1.phase == TouchPhase.Began || t2.phase == TouchPhase.Began || t3.phase == TouchPhase.Began ||
                    t4.phase == TouchPhase.Began)
                {
                    oldPosition1 = t1.position;
                    oldPosition2 = t2.position;
                    oldPosition3 = t3.position;
                    oldPosition4 = t4.position;
                }

                if (t1.phase == TouchPhase.Moved || t2.phase == TouchPhase.Moved || t3.phase == TouchPhase.Moved ||
                    t4.phase == TouchPhase.Moved)
                {
                    var tempPosition1 = t1.position;
                    var tempPosition2 = t2.position;
                    var tempPosition3 = t3.position;
                    var tempPosition4 = t4.position;
                    float yOne = tempPosition1.y - oldPosition1.y;
                    float yTwo = tempPosition2.y - oldPosition2.y;
                    float yThree = tempPosition3.y - oldPosition3.y;
                    float yFour = tempPosition4.y - oldPosition4.y;
                    if (yOne > 0 || yTwo > 0 || yThree > 0 || yFour > 0)
                    {
                        if (UIViewUtility.IsOpened("GMEntranceTopWnd") == false &&
                            UIViewUtility.IsOpened("GMWnd") == false)
                        {
                            OpenGmWnd();
                        }
                    }
                    else if (yOne < 0 || yTwo < 0 || yThree < 0 || yFour < 0)
                    {
                        if (UIViewUtility.IsOpened("GMEntranceTopWnd"))
                        {
                            CloseGmWnd();
                        }
                    }
                }
                else if (t1.phase == TouchPhase.Stationary || t2.phase == TouchPhase.Stationary ||
                         t3.phase == TouchPhase.Stationary || t4.phase == TouchPhase.Stationary)
                {
                    cd += Time.deltaTime;
                    if (cd > 3f)
                    {
                        if (UIViewUtility.IsOpened("GMEntranceTopWnd"))
                        {
                            CloseGmWnd();
                        }
                        else if (!UIViewUtility.IsOpened("GMWnd"))
                        {
                            OpenGmWnd();
                        }
                    }
                }
                else if (t1.phase == TouchPhase.Ended || t2.phase == TouchPhase.Ended || t3.phase == TouchPhase.Ended ||
                         t4.phase == TouchPhase.Ended)
                {
                    cd = 0f;
                }
            }

#if DEBUG_GM
            //战斗调试信息 Tab
            if (Input.GetKeyUp(KeyCode.Tab))
            {
                X3Battle.Debugger.BattleDebugger.Instance.enabled = !X3Battle.Debugger.BattleDebugger.Instance.enabled;
            }
#endif
            CheckLongPress();
        }

        public static float CheckRemoteDebugDt = 2f;
        private float curDtRemote = 0;
        private float curDtGM = 0;
        private Rect touchRectRemote = new Rect(0, 0, 0, 0);
        private Rect touchRectGM = new Rect(0, 0, 0, 0);

        void CheckLongPress()
        {
            if (Input.GetMouseButton(0))
            {
                var width = Screen.width;
                var height = Screen.height;
                if (touchRectRemote.x <= 0)
                {
                    touchRectRemote.width = width;
                    touchRectRemote.height = height;
                }

                touchRectRemote.x = width * 0.7f;
                touchRectRemote.y = height * 0.85f;
                if (touchRectRemote.Contains(Input.mousePosition))
                {
                    curDtRemote += Time.unscaledDeltaTime;
                    if (curDtRemote >= CheckRemoteDebugDt)
                    {
                        curDtRemote = 0;
                        if (X3Lua.IsInited)
                            X3Lua.DoString("BllMgr.Get('RemoteDebugBLL'):CheckRemoteDebugView()");
                    }
                }

                // if (touchRectGM.width <= 0)
                // {
                //     touchRectGM.width = width * 0.3f;
                //     touchRectGM.height = height * 0.15f;
                // }

                // if (touchRectGM.Contains(Input.mousePosition))
                // {
                //     curDtGM += Time.deltaTime;
                //     if (curDtGM >= CheckRemoteDebugDt && !hasTriggered)
                //     {
                //         curDtGM = 0;
                //         hasTriggered = true;
                //         if (UIViewUtility.IsOpened("GMEntranceTopWnd"))
                //         {
                //             CloseGmWnd();
                //         }
                //         else if (!UIViewUtility.IsOpened("GMWnd"))
                //         {
                //             OpenGmWnd();
                //         }
                //     }
                // }
            }
            else
            {
                curDtRemote = 0;
                curDtGM = 0;
            }
        }

        private bool CheckClickArea(Vector3 screenPos)
        {
            return screenPos.x > Screen.width * 0.8 & screenPos.x <= Screen.width & screenPos.y > Screen.height * 0.9 &
                   screenPos.y <= Screen.height;
        }

        public static void CloseGmWnd()
        {
            UIViewUtility.Close("GMEntranceTopWnd", false);
        }

        public static void OpenGmWnd()
        {
            UIViewUtility.Open("GMEntranceTopWnd", false);
        }
    }
}