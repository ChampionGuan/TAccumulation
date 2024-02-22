using System;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;
using X3Battle.Timeline.Preview;
using static X3Battle.PlayPPVAsset;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace X3Battle
{
    [PreviewActionCreator(typeof(PreviewPPV))]
    [TimelineMenu("角色动作/PPV")]
    [Serializable]
    public class PlayPPVAsset : BSActionAsset<ActionPlayPPV>
    {
        [LabelText("路径")]
        public string path;

        public enum StopType
        {
            EnterPlay,
            EnterStop,
            ClipDutaion,
            PeriodTime,
        }

        [LabelText("播放方式")]
        public StopType stopType = StopType.EnterPlay;

        [LabelText("立即停止并清除", "enum:stopType==1|2")]
        public bool isStopAndClear = false;
        [LabelText("播放时长", "enum:stopType==3")]
        public float time = 1f;
    }

    public class ActionPlayPPV : BSAction<PlayPPVAsset>
    {
        protected override void _OnEnter()
        {
            if (string.IsNullOrEmpty(clip.path))
                return;

            if (clip.stopType == StopType.EnterPlay ||
                clip.stopType == StopType.ClipDutaion)
                context.battle.ppvMgr.Play(clip.path);
            else if (clip.stopType == StopType.PeriodTime)
                context.battle.ppvMgr.Play(clip.path, clip.time);
            else if (clip.stopType == StopType.EnterStop)
                context.battle.ppvMgr.Stop(clip.path, clip.isStopAndClear);
        }

        protected override void _OnExit()
        {
            if (clip.stopType == StopType.ClipDutaion)
                context.battle.ppvMgr.Stop(clip.path, clip.isStopAndClear);
        }
    }
#if UNITY_EDITOR
    [CustomEditor(typeof(PlayPPVAsset))]
    public class PlayPPVAssetEditor : Editor
    {
        private PlayPPVAsset script = null;
        private void OnEnable() { script = target as PlayPPVAsset; }

        public override void OnInspectorGUI()
        {
            if (GUILayout.Button("选择Timeline"))
            {
                var newPath = EditorUtility.OpenFilePanel("选择路径", BattleResConfig.Config[BattleResType.Timeline].dir, "prefab");
                if (!string.IsNullOrEmpty(newPath))
                {
                    newPath = newPath.Replace(Application.dataPath + "/", "");
                    newPath = newPath.Replace(BattleResConfig.Config[BattleResType.Timeline].dir.Replace("Assets/", ""), "");
                    newPath = newPath.Replace(".prefab", "");
                    script.path = newPath;
                }
            }
            base.OnInspectorGUI();
        }
    }
#endif
}