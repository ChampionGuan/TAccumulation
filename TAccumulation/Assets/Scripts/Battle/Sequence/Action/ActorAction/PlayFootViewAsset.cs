using PapeGames.X3;
using System;
using UnityEngine;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;
using X3Battle.Timeline.Preview;

namespace X3Battle
{
    public enum FootViewDirType
    {
        Model,
        Foot,
    }
    [PreviewActionCreator(typeof(PreviewFootView))]
    [TimelineMenu("角色运动/播放脚步表现")]
    [Serializable]
    public class PlayFootViewAsset : BSActionAsset<ActionPlayFootView>
    {
        public int GroupID = 1;
        public string DummyName = ActorDummyType.Model; // 挂点
        public Vector3 positionOffset = Vector3.zero;
        public Vector3 rotationOffset = Vector3.zero;
        public FootViewDirType dirType = FootViewDirType.Model;

        public float yOffset = 0.2f;

    }

    public class ActionPlayFootView : BSAction<PlayFootViewAsset>
    {
        private bool _isEnter = false;
        protected override void _OnInit()
        {
            var dummy = context.actor.GetDummy(clip.DummyName);
            dummy.GetOrAddComponent<AkGameObj>();
            needFrameCompensating = false;
            needLateUpdate = true;
        }

        protected override void _OnEnter()
        {
            _isEnter = true;
        }

        protected override void _OnLateUpdate()
        {
            if (!_isEnter)
                return;
            _isEnter = false;

            var dummy = context.actor.GetDummy(clip.DummyName);
            Vector3 startPos = dummy.position + clip.yOffset * Vector3.up;
            var mapHeight = BattleUtil.GetGroundHeight(startPos);
            if(Mathf.Abs(startPos.y - mapHeight) < 1f)
            {
                var hitPos = new Vector3(dummy.position.x, mapHeight, dummy.position.z);
                Quaternion rotOffset = Quaternion.Euler(clip.rotationOffset);

                Vector3 hitEulerAngle;
                Quaternion rotation;

                if (clip.dirType == FootViewDirType.Model)
                {
                    rotation = context.actor.transform.rotation;
                }
                else
                {
                    rotation = dummy.rotation;                  
                }
                hitEulerAngle = (rotation * rotOffset).eulerAngles;
                hitPos += rotation * clip.positionOffset;

                context.actor.locomotionView.PlayRunFx(clip.GroupID, hitPos, hitEulerAngle, dummy.gameObject);
            }
        }
    }
}