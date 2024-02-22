using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    /// <summary>
    /// GameObject的多层显隐控制
    /// 允许多处对同一对象进行显隐控制，最终取或关系（如果有一处设置了false，最终输出结果即为隐藏）
    /// </summary>
    public static class GoVisibleExtension
    {
        /// <summary>
        /// 无效的实例id
        /// </summary>
        private const int INVALID_INS_ID = 0;

        /// <summary>
        /// 所有GameObject的隐身clips
        /// </summary>
        private static Dictionary<int, List<VisibleInfo>> _visibleClips = new Dictionary<int, List<VisibleInfo>>();

        /// <summary>
        /// 添加隐藏状态
        /// </summary>
        /// <param name="go"></param>
        /// <param name="visible"></param>
        /// <param name="debugTag">editor下用来调式的标记</param>
        /// <returns>唯一实例id（可作为移除依据）</returns>
        public static int AddVisible(this GameObject go, bool visible, string debugTag = null)
        {
            return _AddVisible(go, visible, null, false, debugTag);
        }

        /// <summary>
        /// 移除隐藏状态
        /// </summary>
        /// <param name="insID"></param>
        /// <param name="go"></param>
        public static void RemoveVisible(this GameObject go, int insID)
        {
            _RemoveVisible(go, insID: insID);
        }

        /// <summary>
        /// 添加隐藏状态
        /// </summary>
        /// <param name="go"></param>
        /// <param name="visible">释放隐藏</param>
        /// <param name="layer">添加层</param>
        /// <param name="layerMutex">设置是否层互斥，默认为true，如果为true则移除此层已存在的所有clips</param>
        /// <param name="debugTag">editor下用来调式的标记</param>
        /// <returns>唯一实例id（可作为移除依据）</returns>
        public static int AddVisibleWithLayer(this GameObject go, bool visible, int layer, bool layerMutex = true, string debugTag = null)
        {
            return _AddVisible(go, visible, layer, layerMutex, debugTag);
        }

        /// <summary>
        /// 移除隐藏状态
        /// </summary>
        /// <param name="go"></param>
        /// <param name="layer">所在层</param>
        public static void RemoveVisibleWithLayer(this GameObject go, int layer)
        {
            _RemoveVisible(go, layer: layer);
        }

        /// <summary>
        /// 清除所有隐藏状态
        /// </summary>
        /// <param name="go"></param>
        public static void ClearVisible(this GameObject go)
        {
            if (null == go || !_visibleClips.TryGetValue(go.GetInstanceID(), out var list) || list.Count < 1)
            {
                return;
            }

            if (_TryRemoveVisible(list, out var visible))
            {
                go.SetVisible(visible);
            }
        }

        /// <summary>
        /// 清除所有隐藏状态
        /// </summary>
        /// <param name="goInsID"></param>
        public static void ClearVisible(int goInsID)
        {
            if (!_visibleClips.TryGetValue(goInsID, out var list) || list.Count < 1)
            {
                return;
            }

            _TryRemoveVisible(list, out var _);
        }

        /// <summary>
        /// 清除所有隐藏数据
        /// </summary>
        public static void Reset()
        {
            foreach (var list in _visibleClips.Values)
            {
                foreach (var clip in list)
                {
                    VisibleInfo.Release(clip);
                }
            }

            _visibleClips.Clear();
        }

        private static int _AddVisible(this GameObject go, bool visible, int? layer, bool layerMutex, string debugTag = null)
        {
            if (null == go)
            {
                return INVALID_INS_ID;
            }

            using (ProfilerDefine.UtilGoVisibleExtensionPMarker.Auto())
            {
                var goInsID = go.GetInstanceID();
                if (!_visibleClips.TryGetValue(goInsID, out var list) || null == list)
                {
                    list = new List<VisibleInfo>();
                    _visibleClips.Add(goInsID, list);
                }
                // 移除此添加者已存在的clips
                else if (list.Count > 1)
                {
                    if (layerMutex && null != layer) _RemoveVisible(go, layer: layer);
                }

                // 记录默认状态的clip(gameObject.activeSelf)
                if (list.Count < 1)
                {
                    list.Add(VisibleInfo.Get(INVALID_INS_ID, null, go.visibleSelf));
                }

                // 添加新的clip
                var clip = VisibleInfo.Get(layer, visible, debugTag);
                list.Add(clip);

                // 获取显隐状态
                _TryGetVisibleValue(list, out visible);
                go.SetVisible(visible);

                return clip.insID;
            }
        }

        private static void _RemoveVisible(GameObject go, int? layer = null, int insID = INVALID_INS_ID)
        {
            if (null == go || !_visibleClips.TryGetValue(go.GetInstanceID(), out var list))
            {
                return;
            }

            if (insID == INVALID_INS_ID && null == layer)
            {
                return;
            }

            if (_TryRemoveVisible(list, out var visible, layer, insID))
            {
                go.SetVisible(visible);
            }
        }

        private static bool _TryRemoveVisible(List<VisibleInfo> list, out bool visible, int? layer = null, int insID = INVALID_INS_ID)
        {
            visible = false;
            if (null == list || list.Count < 1) return false;

            var result = false;
            var count = list.Count;
            for (var i = count - 1; i > 0; i--)
            {
                var clip = list[i];
                if (INVALID_INS_ID != insID && clip.insID != insID) continue;
                if (null != layer && clip.layer != layer) continue;
                list.RemoveAt(i);
                VisibleInfo.Release(clip);
                result = true;
            }

            count = list.Count;
            // 如果只剩下索引为0的数据，则取出GameObject默认值，并回池处理
            if (count == 1)
            {
                var clip = list[0];
                visible = clip.visible;
                list.RemoveAt(0);
                VisibleInfo.Release(clip);
                result = true;
            }
            else if (result)
            {
                _TryGetVisibleValue(list, out visible);
            }

            return result;
        }

        private static bool _TryGetVisibleValue(List<VisibleInfo> list, out bool visible)
        {
            visible = true;
            var count = list.Count;

            // 此处不检索索引为0的数据（索引0的数据，为GameObject的初始默认显隐值）
            if (count <= 1)
            {
                return false;
            }

            for (var index = count - 1; index > 0; index--)
            {
                var clip = list[index];
                if (clip.visible) continue;
                visible = false;
                return true;
            }

            return true;
        }

        public class VisibleInfo
        {
            private static int _uniqueID = INVALID_INS_ID;
            private static List<VisibleInfo> _cache = new List<VisibleInfo>();

            public int? layer { get; private set; }
            public bool visible { get; private set; }
            public int insID { get; private set; }

#if UNITY_EDITOR
            public string debugTag { get; private set; }
#endif

            public static void Preload(int count)
            {
                for (var i = _cache.Count; i < count; i++)
                {
                    Release(new VisibleInfo());
                }
            }

            public static VisibleInfo Get(int? layer, bool visible, string debugTag = null)
            {
                return Get(++_uniqueID, layer, visible, debugTag);
            }

            public static VisibleInfo Get(int insID, int? layer, bool visible, string debugTag = null)
            {
                VisibleInfo clip;
                var count = _cache.Count;
                if (count < 1)
                {
                    clip = new VisibleInfo();
                }
                else
                {
                    var index = count - 1;
                    clip = _cache[index];
                    _cache.RemoveAt(index);
                }

                clip.layer = layer;
                clip.visible = visible;
                clip.insID = insID;
#if UNITY_EDITOR
                clip.debugTag = debugTag;
#endif
                return clip;
            }

            public static void Release(VisibleInfo clip)
            {
                if (null == clip) return;
                clip.layer = null;
                clip.insID = INVALID_INS_ID;
#if UNITY_EDITOR
                clip.debugTag = null;
#endif
                _cache.Add(clip);
            }
        }
    }
}