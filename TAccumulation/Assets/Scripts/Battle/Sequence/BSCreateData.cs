using UnityEngine;

namespace X3Battle
{
    public class BSCreateData
    {
        public string artResPath = null;
        public string logicAssetPath = null;
        public string blackboardData = null;
        public float? defaultDuration;  // 如果没配logic，并且这个default有值，就用default作为逻辑时长

        public Actor creatorActor = null;
        public GameObject creatorModel = null;
        public float timesScale = 1.0f;
        public BSActionContext bsActionContext = null;
        public bool isManual = false;

        public PerformConfig performCfg = null;

        public bool notBindCreator = false;
    }
}