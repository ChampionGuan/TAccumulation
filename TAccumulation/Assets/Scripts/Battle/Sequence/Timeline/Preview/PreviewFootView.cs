using PapeGames.X3UI;
using UnityEngine;
using X3Battle.Timeline.Extension;

namespace X3Battle.Timeline.Preview
{
    // 预览步尘
    public class PreviewFootView : PreviewActionBase
    {
#if UNITY_EDITOR
        protected override void OnInit()
        {
            TbUtil.Init();
        }

        protected override void OnEnter()
        {
            var footViewAction = GetRunTimeAction<PlayFootViewAsset>();
            var dummy = TimelinePreviewTool.instance.GetDummy(footViewAction.DummyName);
            Vector3 startPos = dummy.position + footViewAction.yOffset * Vector3.up;
            int mask = LayerMask.GetMask("Ground");
            if (Physics.Raycast(startPos, Vector3.down, out RaycastHit infos, 100f, mask))
            {
                // 如果射线打到了地面
                var hitPos = infos.point;
                Quaternion rotOffset = Quaternion.Euler(footViewAction.rotationOffset);

                Vector3 hitEulerAngle;
                Quaternion rotation;
                Transform tgt = TimelinePreviewTool.instance.GetDummy("");

                if (footViewAction.dirType == FootViewDirType.Model)
                {
                    rotation = tgt.rotation;
                }
                else
                {
                    var forwardProj = Vector3.ProjectOnPlane(dummy.forward, infos.normal);
                    rotation = Quaternion.LookRotation(forwardProj);
                }
                hitEulerAngle = (rotation * rotOffset).eulerAngles;
                hitPos += rotation * footViewAction.positionOffset;

                var relativePath = BattleUtil.GetSceneMapRelativePath(1);
                DrawSoundsMap.s_SoundsMapAssets  = BattleResMgr.Instance.Load<SoundsMapAssets>(relativePath, BattleResType.SceneMapData);

                if (DrawSoundsMap.s_SoundsMapAssets == null)
                    return;

                var soundIndex = DrawSoundsMap.GetSoundIndex(tgt.position);
                if (soundIndex < 0)
                    return;
                var moveFxCfg = TbUtil.GetCfg<GroundMoveFx>(footViewAction.GroupID, soundIndex);
                if (moveFxCfg == null)
                    return;

                var mgr = TimelinePreviewTool.instance.GetFxMgr();
                if (mgr == null)
                    return;
                mgr.PlayBattleFx(moveFxCfg.FxID, offsetPos: hitPos, angle: hitEulerAngle, isWorldParent: true);
            }
        }
#endif
    }
}
