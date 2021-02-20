using UnityEngine;
using System.Collections;
using System;

namespace PapeGames.X3
{
    /// <summary>
    /// Singleton
    /// Creator: Tungway
    /// Create Date: 2019
    /// Updater: Tungway
    /// Last Update: 2019
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class Singleton<T> where T : class, new()
    {
        private static T s_Instance;
        private static object s_LockObj = new object();

        protected Singleton()
        {
        }

        protected static void CreateInstance()
        {
            if (s_Instance != null) return;
            lock (s_LockObj)
            {
                s_Instance = new T();
            }
            (s_Instance as Singleton<T>).Init();
        }

        public static void DestroyInstance()
        {
            if (s_Instance != null)
            {
                (s_Instance as Singleton<T>).UnInit();
                s_Instance = null;
            }
        }

        public static T Instance
        {
            get
            {
                if (s_Instance != null)
                    return s_Instance;

                CreateInstance();

                return s_Instance;
            }
        }

        protected virtual void Init()
        {

        }

        protected virtual void UnInit()
        {

        }
    }
}