using System.Collections;
using System.Collections.Generic;
using PapeGames.X3UI;
using UnityEngine;
using XLua;


namespace X3Game.GameHelper
{
    [LuaCallCSharp]
    public static class SoundFXHandlerUtil
    {
        public static void Play(Object obj, int idx, System.Action onComplete = null)
        {
            SoundFXHandler.Play(obj, idx, onComplete);
        }

        public static void Play(Object obj, string key, System.Action onComplete = null)
        {
            SoundFXHandler.Play(obj, key, onComplete);
        }


        public static void PlayHash(Object obj, uint haskKey, System.Action onComplete = null)
        {
            var comp = SoundFXHandler.Get(obj);
            if (comp == null)
            {
                onComplete?.Invoke();
                return;
            }
            comp.InternalPlayHash(haskKey, onComplete);
        }

        public static void Stop(Object obj, int idx)
        {
            SoundFXHandler.Stop(obj, idx);
        }

        public static void Stop(Object obj, string key)
        {
            SoundFXHandler.Stop(obj, key);
        }

        public static void StopHash(Object obj, uint hash)
        {
            SoundFXHandler.StopHash(obj, hash);
        }
    }
}