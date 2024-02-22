using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI/Action")]
    [Description("男主镜头内选点")]
    [Name("男主镜头内选点(AI专用)")]
    public class NABoyViewSelectPoint : BattleAction
    {
        public BBParameter<float> minViewX = new BBParameter<float>();
        public BBParameter<float> maxViewX = new BBParameter<float>();
        public BBParameter<float> minViewY = new BBParameter<float>();
        public BBParameter<float> maxViewY = new BBParameter<float>();
        public BBParameter<float> minSkillDistance = new BBParameter<float>();
        public BBParameter<float> maxSkillDistance = new BBParameter<float>();
        public BBParameter<bool> storedResult = new BBParameter<bool>();
        public BBParameter<bool> storedFind = new BBParameter<bool>();
        public BBParameter<Actor> storedTarget = new BBParameter<Actor>();
        public BBParameter<Vector3> storedPoint = new BBParameter<Vector3>();
        private bool result;
        private bool find;
        private Actor target;
        private Vector3 point;
        
        protected override void OnExecute()
        {
            if (minViewX.isNoneOrNull || maxViewX.isNoneOrNull || minViewY.isNoneOrNull || maxViewY.isNoneOrNull || minSkillDistance.isNoneOrNull || maxSkillDistance.isNoneOrNull)
            {
                EndAction(false);
                return;
            }
            if (!(_actor?.actorHate is FriendHate))
            {
                EndAction(false);
                return;
            }
            FriendHate friendHate = _actor.actorHate as FriendHate;
            friendHate.CalculateAidPoint(minViewX.value, maxViewX.value, minViewY.value, maxViewY.value, minSkillDistance.value, maxSkillDistance.value, out result, out find, out target, out point);
            storedResult.value = result;
            storedFind.value = find;
            storedTarget.value = target;
            storedPoint.value = point;
            EndAction(true);
        }
    }
}
