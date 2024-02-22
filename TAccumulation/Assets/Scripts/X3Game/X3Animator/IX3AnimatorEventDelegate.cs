using UnityEngine.Playables;

namespace X3Game
{
    public interface IX3AnimatorEventDelegate
    {
        void OnPlay(X3Animator animator, string stateName, float initialTime, float transitionDuration, int wrapMode);
        void OnPause(X3Animator animator);
        void OnResume(X3Animator animator);
        void OnStop(X3Animator animator, bool autoComplete);

    }
}