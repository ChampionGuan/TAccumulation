using System;
using System.Collections.Generic;
using X3.Character;

namespace UnityEngine.Timeline
{
    [CreateAssetMenu(fileName = "PhysicsWindParamAsset", menuName = "PhysicsWindParamAsset", order = 0)]
    public class PhysicsWindParamAsset : ScriptableObject
    {
        [SerializeField]
        public PhysicsWindParam physicsWindParam;

        [HideInInspector]
        [SerializeField] 
        public bool isLerp = false;
        
        [HideInInspector]
        [SerializeField] 
        public PhysicsWindParam physicsWindParam2 = null;
    }

    /// <summary>
    /// 风场所需参数
    /// </summary>
    [Serializable]
    public class PhysicsWindParam
    {
        // 空气场参数
        [SerializeField] public X3PhysicsWindAirParam airParam;

        // 体积场参数
        [SerializeField] public List<X3PhysicsWindVolumeParam> volumeParams;
    
        // 使用的对象（辅助Scene中绘制用）
        [NonSerialized] public GameObject attachObject;

        //跟随物体的路径
        public string followChildPath = "Roots/Root_M";
        
        // attach到对象上之后，才能根据local绘制辅助线
        public void AttachGameObject(GameObject gameObject)
        {
            attachObject = gameObject;
        }

        public PhysicsWindParam Clone()
        {
            var newData = new PhysicsWindParam();
            newData.airParam = this.airParam.Clone();
            if (this.volumeParams != null)
            {
                newData.volumeParams = new List<X3PhysicsWindVolumeParam>(this.volumeParams.Count);
                for (int i = 0; i < this.volumeParams.Count; i++)
                {
                    newData.volumeParams.Add(this.volumeParams[i].Clone());
                }
            }
            
            newData.followChildPath = followChildPath;
            
            return newData;
        }

        public void Lerp2Self(PhysicsWindParam param1, PhysicsWindParam param2, float process)
        {
            var airStren1 = param1.airParam.physicsData.strength;
            var airStren2 = param2.airParam.physicsData.strength;
            this.airParam.physicsData.strength = airStren1 + (airStren2 - airStren1) * process;
            
            // 外部已经进行过安全性处理，这里不处理
            if (this.volumeParams != null)
            {
                for (int i = 0; i < volumeParams.Count; i++)
                {
                    var volStren1 = param1.volumeParams[i].physicsData.strength;
                    var volStren2 = param2.volumeParams[i].physicsData.strength;
                    volumeParams[i].physicsData.strength = volStren1 + (volStren2 - volStren1) * process;
                } 
            }
        }
        
        
    }
}
