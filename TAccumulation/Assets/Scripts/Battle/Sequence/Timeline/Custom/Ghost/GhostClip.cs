using System;
using UnityEngine;
#if UNITY_EDITOR
    using UnityEditor;
#endif
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace X3Battle
{
    [Serializable]
    public class GhostClip :InterruptClip
    {
        private GameObject originObj;   // 残影的原生模型
        [LabelText("绑定动画", showCondition = "!ghostParam.isCloneBone")]
        public AnimationClip animationClip;
        private PlayableDirector director;
        
        [GradientUsage(true)]
        public Gradient colorCurve;
        
        [LabelText("淡出Scale曲线 (时间区间0~1)")]
        public AnimationCurve fadeScale = new AnimationCurve(new Keyframe(0,1), new Keyframe(1,1));
       
        [HideInInspector]
        public GhostShaderData ghostShaderData = new GhostShaderData();
        
        public GhostParam ghostParam = new GhostParam();
        
        [NonSerialized] 
        private GameObject referenceTarget;

        [NonSerialized] private GhostObjectPool _pool;

        public GhostObjectPool pool => _pool;

        public void SetInfo(GameObject target, PlayableDirector director, GameObject reference, GhostObjectPool pool)
        {
            _pool = pool;
            referenceTarget = reference;
            originObj = target;
            this.director = director;
        }

        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviour)
        {
            var playable = ScriptPlayable<GhostBehaviour>.Create(graph);
            GhostBehaviour behaviour = playable.GetBehaviour();
            interruptBehaviour = behaviour;
            if (originObj != null)
            {
                behaviour.SetTrackInfo(originObj, colorCurve, director, animationClip, ghostParam, referenceTarget, _pool);
                behaviour.SetGhostShaderData(ghostShaderData);
                behaviour.FindBoneSrc();
                behaviour.SetFadeScale(fadeScale);
            }
            return playable;
        }

        protected override ClipCaps OnGetClipCaps()
        {
            return ClipCaps.None;
        }
    }

    [Serializable]
    public class GhostParam
    {
        [LabelText("残影上限(-1无限制)")]
        public int maxGhostNum = 1;
        
        [LabelText("生成间隔")]
        public float spawnInterval = 0;
        
        [LabelText("持续时间 (-1随clip)")] 
        public float duration = 0;

        [LabelText("是否用骨骼定帧")]
        public bool isCloneBone;
        
        [LabelText("  绑定角色", showCondition = "isCloneBone")]
        public TrackBindRoleType bindRoleType;
        
        [LabelText("  动画是否定帧", showCondition = "!isCloneBone")]
        public bool isPauseAnim = true;

        [LabelText("  不跟随主体位置", referenceTrueValue = "useAnimSection" , showCondition = "!isCloneBone")]
        public bool isPausePosition;

        [LabelText("  动画和位移悬停时间", showCondition = "!isCloneBone")] 
        public float globalDelayPlayTime = 0;

        [LabelText("  截取动画Clip", showCondition = "!isCloneBone")]
        public bool useAnimSection;

        [LabelText("    起始结束帧", showCondition = "useAnimSection", showCondition2 = "!isCloneBone")] 
        public Vector2Int animSectionTime;

        [LabelText("  主体动画开始时间", showCondition = "!isCloneBone")] 
        public float actorAnimStartTime = 0f;

#if UNITY_EDITOR
        // 编辑器下用，克隆
        public GhostParam Clone(GhostParam outParam)
        {
            outParam.maxGhostNum = maxGhostNum;
            outParam.spawnInterval = spawnInterval;
            outParam.duration = duration;
            outParam.isCloneBone = isCloneBone;
            outParam.bindRoleType = bindRoleType;
            outParam.isPauseAnim = isPauseAnim;
            outParam.isPausePosition = isPausePosition;
            outParam.globalDelayPlayTime = globalDelayPlayTime;
            outParam.useAnimSection = useAnimSection;
            outParam.animSectionTime = animSectionTime;
            outParam.actorAnimStartTime = actorAnimStartTime;
            return outParam;
        }

        // 编辑器下用，判断是否相等
        public bool SameWith(GhostParam other)
        {
            return
                other.maxGhostNum == maxGhostNum
                && other.spawnInterval == spawnInterval
                && other.duration == duration
                && other.isCloneBone == isCloneBone
                && other.bindRoleType == bindRoleType
                && other.isPauseAnim == isPauseAnim
                && other.isPausePosition == isPausePosition
                && other.globalDelayPlayTime == globalDelayPlayTime
                && other.useAnimSection == useAnimSection
                && other.animSectionTime == animSectionTime
                && other.actorAnimStartTime == actorAnimStartTime;
        }
#endif
    }
}

