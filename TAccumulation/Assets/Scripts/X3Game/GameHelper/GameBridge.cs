namespace PapeGames.X3
{
    public static class GameBridge
    {
        public static void PlaySoundFX(string evtName)
        {
            if(!string.IsNullOrEmpty(evtName))
            {
                WwiseManager.Instance.LoadBankWithEventName(evtName);
                WwiseManager.Instance.PlaySound(evtName);
            }
        }

        public static void Play3DSoundFX(string evtName, UnityEngine.GameObject obj)
        {
            if (!string.IsNullOrEmpty(evtName))
            {
                WwiseManager.Instance.LoadBankWithEventName(evtName);
                WwiseManager.Instance.PlaySound(evtName, obj);
            }
        }

        public static void StopSoundFX(string evtName)
        {
            if (!string.IsNullOrEmpty(evtName))
            {
                WwiseManager.Instance.StopSound(evtName);
            }
        }

        public static void Stop3DSoundFX(string evtName, UnityEngine.GameObject obj)
        {
            if (!string.IsNullOrEmpty(evtName))
            {
                WwiseManager.Instance.StopSound(evtName, obj);
            }
        }
    }
}
