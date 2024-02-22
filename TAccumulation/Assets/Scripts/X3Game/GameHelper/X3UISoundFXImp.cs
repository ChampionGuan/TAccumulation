using PapeGames.X3UI;
using PapeGames.X3;

namespace X3Game
{
    public class X3UISoundFXImp : IUISoundFXDelegate
    {
        public void PlaySoundFX(string evtName)
        {
            if(!string.IsNullOrEmpty(evtName))
            {
                WwiseManager.Instance.LoadBankWithEventName(evtName);
                WwiseManager.Instance.PlaySound(evtName);
            }
        }

        public void Play3DSoundFX(string evtName, UnityEngine.GameObject obj)
        {
            if (!string.IsNullOrEmpty(evtName))
            {
                WwiseManager.Instance.LoadBankWithEventName(evtName);
                WwiseManager.Instance.PlaySound(evtName, obj);
            }
        }

        public void StopSoundFX(string evtName)
        {
            if (!string.IsNullOrEmpty(evtName))
            {
                WwiseManager.Instance.StopSound(evtName);
            }
        }

        public void Stop3DSoundFX(string evtName, UnityEngine.GameObject obj)
        {
            if (!string.IsNullOrEmpty(evtName))
            {
                WwiseManager.Instance.StopSound(evtName, obj);
            }
        }
    }
}