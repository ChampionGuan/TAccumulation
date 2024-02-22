#if DEBUG_GM || UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle.Debugger
{
    public class DebugBuff
    {
        public int id;
        public string name;
        public int levelIndex;
        public List<int> levels;
        public string[] levelStrs;
    }

    public class DebugAttr
    {
        public AttrType type;
        public Attribute attr;
        public string name;
        public float value;
    }

    public interface IDebugger
    {
        string name { get; }
        void OnEnter();
        void OnExit();
        void OnGUI();
    }

    public class StoragePrefs
    {
        /// <summary>
        /// 所需的key，以及key所对应的默认值
        /// </summary>
        public Dictionary<string, object> dict { get; }

        public StoragePrefs(Dictionary<string, object> dict)
        {
            this.dict = dict;
        }

        public object GetDefault(string key)
        {
            if (null == dict) return null;
            return dict.TryGetValue(key, out var value) ? value : null;
        }

        public Type GetType(string key)
        {
            if (null == dict) return null;
            return dict.TryGetValue(key, out var value) ? value.GetType() : null;
        }

        public bool Has(string key)
        {
            if (null == dict) return false;
            return dict.ContainsKey(key) && PlayerPrefs.HasKey(key);
        }

        public void Restore()
        {
            if (null == dict) return;
            foreach (var dict in dict)
            {
                Set(dict.Key, dict.Value);
            }
        }

        public void Restore(string key)
        {
            if (Has(key))
            {
                Set(key, GetDefault(key));
            }
        }

        public void Delete(string key)
        {
            if (Has(key))
            {
                PlayerPrefs.DeleteKey(key);
            }
        }

        public void DeleteAll()
        {
            if (null == dict) return;
            foreach (var dict in dict)
            {
                Delete(dict.Key);
            }
        }

        public object Get(string key)
        {
            if (!Has(key))
            {
                return GetDefault(key);
            }

            var type = GetType(key);
            if (typeof(int) == type)
            {
                return PlayerPrefs.GetInt(key);
            }

            if (typeof(float) == type)
            {
                return PlayerPrefs.GetFloat(key);
            }

            if (typeof(string) == type)
            {
                return PlayerPrefs.GetString(key);
            }

            if (typeof(bool) == type)
            {
                return 1 == PlayerPrefs.GetInt(key);
            }

            if (typeof(Vector2) == type)
            {
                var v2 = PlayerPrefs.GetString(key).Split('=');
                return new Vector2(float.Parse(v2[0]), float.Parse(v2[1]));
            }

            if (typeof(Vector3) == type)
            {
                var v3 = PlayerPrefs.GetString(key).Split('=');
                return new Vector3(float.Parse(v3[0]), float.Parse(v3[1]), float.Parse(v3[2]));
            }

            return null;
        }

        public void Set(string key, object value)
        {
            var type = GetType(key);
            if (null == type) return;
            if (typeof(int) == type)
            {
                PlayerPrefs.SetInt(key, (int)value);
            }
            else if (typeof(float) == type)
            {
                PlayerPrefs.SetFloat(key, (float)value);
            }
            else if (typeof(string) == type)
            {
                PlayerPrefs.SetString(key, (string)value);
            }
            else if (typeof(bool) == type)
            {
                PlayerPrefs.SetInt(key, (bool)value ? 1 : 0);
            }
            else if (typeof(Vector2) == type)
            {
                var v2 = (Vector2)value;
                PlayerPrefs.SetString(key, $"{v2.x}={v2.y}");
            }
            else if (typeof(Vector3) == type)
            {
                var v3 = (Vector3)value;
                PlayerPrefs.SetString(key, $"{v3.x}={v3.y}={v3.z}");
            }
        }
    }

    public class ZoomAreaScope : IDisposable
    {
        private readonly Matrix4x4 _prevGuiMatrix;

        public ZoomAreaScope(Rect screenCoordsArea, float zoomScale)
        {
            var val = screenCoordsArea.ScaleSizeBy(1f / zoomScale, screenCoordsArea.TopLeft());
            val.y += 21f;
            GUI.BeginGroup(val);
            _prevGuiMatrix = GUI.matrix;
            var val2 = Matrix4x4.TRS(val.TopLeft(), Quaternion.identity, Vector3.one);
            var one = Vector3.one;
            one.x = one.y = zoomScale;
            var val3 = Matrix4x4.Scale(one);
            GUI.matrix = val2 * val3 * val2.inverse * GUI.matrix;
        }

        public void Dispose()
        {
            GUI.matrix = _prevGuiMatrix;
            GUI.EndGroup();
        }
    }

    public static class RectExtension
    {
        public static Vector2 TopLeft(this Rect rect)
        {
            return new Vector2(rect.xMin, rect.yMin);
        }

        public static Rect ScaleSizeBy(this Rect rect, float scale)
        {
            return rect.ScaleSizeBy(scale, rect.center);
        }

        public static Rect ScaleSizeBy(this Rect rect, float scale, Vector2 pivotPoint)
        {
            var result = rect;
            result.x -= pivotPoint.x;
            result.y -= pivotPoint.y;
            result.xMin *= scale;
            result.xMax *= scale;
            result.yMin *= scale;
            result.yMax *= scale;
            result.x += pivotPoint.x;
            result.y += pivotPoint.y;
            return result;
        }
    }
}
#endif