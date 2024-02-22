using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace PapeGames
{
    //运行时使用ActionFxPlayer.cs(Sequence) 这个仅Editor使用
    public class FxPlayerPlayable : MountPlayableBehaviourBase
    {
        protected FxPlayer fx;
        protected float totalDuration;
        protected float lastTime;

        public bool PreInit(GameObject go, float duration, float clipIn)
        {
            if (go == null)
                return false;

            fx = go.GetComponent<FxPlayer>();
            if (fx == null)
                return false;

            totalDuration = duration + clipIn;
            fx.SetDuration(totalDuration);
            return true;
        }

        protected override void OnBehaviourPlay(PlayableBehaviour behaviour, Playable playable, FrameData info)
        {
            if (fx == null)
                return;

            fx.Init();//Editor随时修改
            fx.RePlay();
        }

        protected override void OnProcessFrame(PlayableBehaviour behaviour, Playable playable, FrameData info, object userData)
        {
            if (fx == null)
                return;

            fx.ApplyLOD();//Editor随时预览不同的LOD

            var playTime = (float)playable.GetTime();
            LoopEnd(fx, playTime);
            fx.SetPlayTime(playTime);
        }
        protected void LoopEnd(FxPlayer fx, float playTime)
        {
            if (!fx.isLoop)
                return;
            //Editor可能会倒着拉 处理一下//
            if (lastTime > playTime)
            {
                fx.RePlay();
                fx.SetPlayTime(playTime);
            }
            lastTime = playTime;
            //Editor可能会倒着拉 处理一下//
            if (fx.IsEndState || fx.IsDestroy)
                return;
            if (totalDuration - playTime < fx.endTime)
            {
                fx.Stop();
            }
        }

        protected override void OnBehaviourPause(PlayableBehaviour behaviour, Playable playable, FrameData info)
        {
            if (fx == null)
                return;

            fx.Stop(true);
        }
    }
}