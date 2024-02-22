#if DEBUG_GM || UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Unity.Profiling;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle.Debugger
{
    [DisallowMultipleComponent]
    public class BattleDebugger : MonoBehaviour
    {
        public static BattleDebugger Instance
        {
            get
            {
                if (null != _instance) return _instance;
                var go = Battle.Instance?.root.gameObject ?? new GameObject("__BattleDebugger");
                _instance = go.GetComponent<BattleDebugger>();
                if (null == _instance) _instance = go.AddComponent<BattleDebugger>();
                _instance.enabled = false;
                return _instance;
            }
        }

        static BattleDebugger()
        {
            var types = (from type in Assembly.GetExecutingAssembly().GetTypes() where !type.IsAbstract && null != type.GetInterface("IDebugger") select type).ToList();
            _topBar = new string[types.Count];
            _debuggers = new Dictionary<Type, IDebugger>();
            for (var i = 0; i < types.Count; i++)
            {
                var type = types[i];
                var debugger = (IDebugger)Activator.CreateInstance(type);
                _debuggers.Add(type, debugger);
                _topBar[i] = debugger.name;
            }
        }

        public static string GUISize = "__BattleDebugger___Size";
        public static string TopbarSelectedType = "__BattleDebugger___TopbarSelectedType";
        public static string ScreenScrollPos = "__BattleDebugger___ScreenScrollPos";

        public static StoragePrefs Prefs = new StoragePrefs(new Dictionary<string, object>
        {
            { GUISize, 1f },
            { TopbarSelectedType, "" },
            { ScreenScrollPos, Vector2.zero },
        });

        private static ProfilerMarker OnGUIPMarker = new ProfilerMarker("BattleDebugger.OnGUI()");

        private static BattleDebugger _instance;
        private static Dictionary<Type, IDebugger> _debuggers;
        private static string[] _topBar;

        private IDebugger _currDebugger;
        private float _size = 1;
        private Vector2 _screenScrollPosition;
        private string _selectedTypeName;
        private int _selectedIndex;
        private float _screenScrollWidth => Screen.width * 3;
        private float _screenScrollHeight => Screen.height * 3;

        private void Awake()
        {
            if (null != _instance) return;
            _instance = this;
            _size = (float)Prefs.Get(GUISize);
            _selectedTypeName = (string)Prefs.Get(TopbarSelectedType);
            _screenScrollPosition = (Vector2)Prefs.Get(ScreenScrollPos);

            if (!string.IsNullOrEmpty(_selectedTypeName))
            {
                Display(Type.GetType(_selectedTypeName));
            }
            else
            {
                Display(0);
            }
        }

        private void OnEnable()
        {
            _currDebugger?.OnEnter();
        }

        private void OnDisable()
        {
            _currDebugger?.OnExit();
        }

        private void OnDestroy()
        {
            if (_instance != this) return;
            _instance = null;
            Prefs.Set(GUISize, _size);
            Prefs.Set(TopbarSelectedType, _selectedTypeName);
            Prefs.Set(ScreenScrollPos, _screenScrollPosition);
            StopAllCoroutines();
        }

        private void OnGUI()
        {
            using (OnGUIPMarker.Auto())
            {
                using (var scope = new GUI.ScrollViewScope(new Rect(0, 0, Screen.width, Screen.height), _screenScrollPosition, new Rect(0f, 0f, _screenScrollWidth, _screenScrollHeight), true, true))
                {
                    _screenScrollPosition = scope.scrollPosition;
                    using (new ZoomAreaScope(new Rect(0, 0, _screenScrollWidth, _screenScrollHeight), _size))
                    {
                        using (new GUILayout.AreaScope(new Rect(40, 40, Screen.width - 80, 40)))
                        {
                            using (new GUILayout.HorizontalScope())
                            {
                                _selectedIndex = GUILayout.Toolbar(_selectedIndex, _topBar);
                                if (GUI.changed)
                                {
                                    Display(_selectedIndex);
                                }

                                GUILayout.Space(80);
                                if (GUILayout.Button("关闭", GUILayout.Width(40)))
                                {
                                    enabled = false;
                                }
                            }
                        }

                        if (enabled)
                        {
                            using (new GUILayout.AreaScope(new Rect(40, 80, Screen.width - 80, Screen.height - 100)))
                            {
                                _currDebugger?.OnGUI();
                            }
                        }
                    }
                }

                using (new GUILayout.AreaScope(new Rect(40, Screen.height - 80, Screen.width - 80, 50)))
                {
                    GUILayout.Label("尺寸调整");
                    _size = GUILayout.HorizontalSlider(_size, 1, 3);
                }
            }
        }

        public void Display<T>() where T : IDebugger
        {
            Display(typeof(T));
        }

        public void Display(Type type)
        {
            if (!_debuggers.TryGetValue(type, out _))
            {
                return;
            }

            Display(_debuggers.Keys.ToList().IndexOf(type));
        }

        public void Display(int index)
        {
            if (index < 0 || index > _debuggers.Count - 1)
            {
                return;
            }

            _currDebugger?.OnExit();
            _currDebugger = null;
            enabled = true;
            _currDebugger = _debuggers.Values.ToList()[index];
            _selectedIndex = index;
            _selectedTypeName = _currDebugger.GetType().FullName;
            _currDebugger.OnEnter();
        }
    }
}
#endif