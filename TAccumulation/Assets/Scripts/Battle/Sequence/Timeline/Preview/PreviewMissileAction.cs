using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using X3Battle.Timeline.Extension;

#if UNITY_EDITOR
    using UnityEditor;
#endif

namespace X3Battle.Timeline.Preview
{
    public class PreviewMissileAction : PreviewActionBase
    {
#if UNITY_EDITOR
        private const string _dummyPath = "Assets/Build/Art/Timeline/Editor/Missile/MissileDummy.prefab";
        private List<GameObject> _dummys = new List<GameObject>();
        private List<PreviewFxPlayer> _missiles = new List<PreviewFxPlayer>();
        protected override void OnEnter()
        {
            //从end进入不创建子弹
            if (GetStartTime() > GetDuration() / 2.0f)
                return;
            
            var model = TimelinePreviewTool.instance.GetActorModel();
            var damageBoxAction = GetRunTimeAction<CreateMissileAsset>();
            var dummyPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(_dummyPath);
            if (damageBoxAction != null && model != null && dummyPrefab != null)
            {
                foreach (var missileParam in damageBoxAction.missiles)
                {
                    var startPos = missileParam.StartPos.GetCoordinatePointEditor(model);
                    var startForward = missileParam.StartForward.GetCoordinateForwardEditor(model);
                    var dummy = GameObject.Instantiate(dummyPrefab);

                    var missileCfg = TbUtil.GetCfg<MissileCfg>(missileParam.missileID);
                    if (missileCfg == null)
                    {
                        LogProxy.LogErrorFormat("[ActorMgr.CreateMissile()]创建子弹失败，技能子弹配置不存在, 请检查, missileID:{0}!", missileParam.missileID);
                        continue;
                    }
                    
                    var targetPos = Vector3.one;
                    var targetDir = Vector3.one;
                    if (missileCfg.MotionData.MotionType == MissileMotionType.Line)
                    {
                        //目标在子弹反向 并且固定在20米外
                        targetPos = startPos + startForward * CoorHelper.EditorTargetDistance;
                        targetDir = startForward;
                    }
                    else
                    {
                        //目标在人物反向 并且固定在20米外
                        targetPos = startPos + model.transform.forward * CoorHelper.EditorTargetDistance;
                        targetDir = model.transform.forward;
                    }

                    _missiles.Add(PreviewMissileFxMgr.Instance.PlayBattleFx(missileParam.missileID, model.transform, missileCfg, targetPos, targetDir, startPos, startForward, missileParam.SuspendTime));
          
                    dummy.transform.position = targetPos;
                    dummy.transform.forward = targetDir;
                    _dummys.Add(dummy);
                }
            }
        }

        protected override void OnExit()
        {
            foreach (var dummy in _dummys)
            {
                GameObject.DestroyImmediate(dummy);
            }
            _dummys.Clear();
            
            foreach (var missile in _missiles)
            {
                missile.Destroy();
            }
            _missiles.Clear();
        }

        protected override void OnUpdate(float deltaTime)
        {
            base.OnUpdate(deltaTime);
            foreach (var missile in _missiles)
            {
                if (missile != null)
                {
                    missile.SetMotionCurTime(GetCurTime());
                    missile.OnUpdate(deltaTime);
                }
            }
        }
#endif
    }
}