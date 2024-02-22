using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class ActionVisibility : BSAction
    {
        private bool _visible;
        private bool _rootBoneVisible;

        private GameObject _bindObj;
        
        private int _hashID;
        public ActionVisibility()
        {
            _hashID = GetHashCode();
        }

        protected override void _OnInit()
        {
            var clip = GetClipAsset<VisibilityClip>();
            _visible = clip.m_visible;
            _rootBoneVisible = clip.m_rootsVisible;
            _bindObj = GetTrackBindObj<GameObject>();
        }

        protected override void _OnEnter()
        {
            BattleUtil.AddCharacterVisibleClip(_hashID, _bindObj, _visible, _rootBoneVisible);
        }

        protected override void _OnExit()
        {
            BattleUtil.RemoveCharacterVisibleClip(_hashID, _bindObj);
        }
    }
}