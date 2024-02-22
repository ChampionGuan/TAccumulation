using System;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Serializable]
    public class BBGetLevelInsIDPos
    {
        public BBParameter<int> id = new BBParameter<int>();
        public BBParameter<Vector3> storedPos = new BBParameter<Vector3>();

        public void UpdatePos()
        {
            StageConfig stageConfig = Battle.Instance.actorMgr.stageConfig;
            foreach (PointConfig pointConfig in stageConfig.Points)
            {
                if (pointConfig.ID == id.value)
                {
                    storedPos.value = pointConfig.Position;
                    return;
                }
            }

            foreach (SpawnPointConfig spawnPointConfig in stageConfig.SpawnPoints)
            {
                if (spawnPointConfig.ID == id.value)
                {
                    storedPos.value = spawnPointConfig.Position;
                    return;
                }
            }
        }
    }
}
