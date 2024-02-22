
using UnityEngine;
using System;
using System.IO;
using System.Collections.Generic;
using System.Threading.Tasks;
namespace X3Game.DailyConfide
{
    /// <summary>
    /// 连麦辅助计算用的
    /// </summary>
    //[XLua.LuaCallCSharp]
    public static class DailyConfideHelper
    {
        static List<DailyPhoneStaticVectorCfgListItem> m_StaticVectorCfg = null;
        static List<float> m_DynamicVector = null;
#if UNITY_EDITOR
        static string m_RootPath = Path.Combine(Application.dataPath, "../DailyPhone");
#else       
        static string m_RootPath = Application.persistentDataPath;
#endif

        static int matchID = -1;
        static float tempResult = 0;
    
        static Action<int> evalItem = i =>
        {
            float result = 0;
            for (int j = 0; j < m_DynamicVector.Count; j++)
            {
                result += m_DynamicVector[j] * m_StaticVectorCfg[i].Sentence[j];
            }
            float threshold = m_StaticVectorCfg[i].Threshold / 10000;
            if (result > tempResult && result >= threshold)
            {
                tempResult = result;
                matchID = m_StaticVectorCfg[i].ID;
            }
        };
        [Serializable]
        class DailyPhoneStaticVectorCfg
        {
            public List<DailyPhoneStaticVectorCfgListItem> Data;
        }
        [Serializable]
        class DailyPhoneStaticVectorCfgListItem
        {
            public int ID;
            public List<float> Sentence;
            public float Threshold;
        }
        [Serializable]
        class DailyPhoneDynamicVectorCfg
        {
            public string model_name;
            public int model_version;
            public List<DailyPhoneDynamicParametersCfg> parameters;
            public List<DailyPhoneDynamicOutputsCfg> outputs;
        }
        [Serializable]
        class DailyPhoneDynamicParametersCfg
        {
            public int sequence_id;
            public bool sequence_start;
            public bool sequence_end;
        }
        [Serializable]
        class DailyPhoneDynamicOutputsCfg
        {
            public string name;
            public string datatype;
            public List<int> shape;
            public List<float> data;
        }
        static void initCalData()
        {
            matchID = -1;
            tempResult = 0;
        }
        public static void CleanData()
        {
            initCalData();
            m_StaticVectorCfg = null;
            m_DynamicVector = null;
        }
        public static bool InitStaticVector(int roleID)
        {

            string path = Path.Combine(m_RootPath, $"DynamicVectorCfg-{roleID}.json");
            if (!File.Exists(path))
            {
                Debug.LogWarning("DailyPhoneDynamicVecotr Not Exists, Path: " + path);
                path = Path.Combine(m_RootPath, $"DynamicVectorCfg-{1}.json");
            }

            if (!File.Exists(path))
            {
                Debug.LogError("DailyPhoneDynamicVecotr Not Exists, Path: " + path);
                return false;
            }
            m_StaticVectorCfg = JsonUtility.FromJson<DailyPhoneStaticVectorCfg>(File.ReadAllText(path)).Data;
            return true;
        }
        public static int Match(string json)
        {
            initCalData();
            if (m_StaticVectorCfg == null)
                return matchID;
            var dynamicCfg = JsonUtility.FromJson<DailyPhoneDynamicVectorCfg>(json);
            m_DynamicVector = dynamicCfg.outputs[0].data;
            Parallel.For(0, m_StaticVectorCfg.Count, evalItem);
            return matchID;
        }
        public static int MatchVector(List<float> vector)
        {
            initCalData();
            if (m_StaticVectorCfg == null)
                return matchID;
            m_DynamicVector = vector;
            Parallel.For(0, m_StaticVectorCfg.Count, evalItem);
            return matchID;
        }
        public static float GetValue()
        {
            return tempResult;
        }
    }

}

