using PapeGames;
using UnityEngine;
using X3.Character;
using ISubsystem = UnityEngine.ISubsystem;

namespace X3Battle
{
    public class ActionAvatar : BSAction
    {
        private TransformSyncTask _syncTask;
        private GameObject _avatar;
        private bool _isLateEntered;

        protected override void _OnInit()
        {
            needLateUpdate = false;
            _isLateEntered = false;
            
            var track = GetTrackAsset<AvatarTrack>();
            var trackBind = battleSequencer.GetComponent<BSCTrackBind>();
            GameObject gameObject = null;
            var avatar = trackBind.CreateGhostHD(track, out gameObject);

            if (gameObject != null && avatar != null)
            {
                needLateUpdate = true;
                _isLateEntered = true;
                _avatar = avatar;
                var srcTrans = gameObject.transform;
                if (gameObject.name == "Model")
                {
                    srcTrans = srcTrans.parent;
                }
                _syncTask = new TransformSyncTask(srcTrans, avatar.transform);
                _syncTask.Execute();  // preload模式先走一下，后面消耗小   
            }
        }

        // 位置同步要在动画之后，LateUpdate中做
        protected override void _OnLateUpdate()
        {
            if (_isLateEntered)
            {
                return;
            }
            _isLateEntered = true;
            
            _avatar?.SetVisible(true);
            _syncTask?.Execute();
        }
        
        protected override void _OnExit()
        {
            _isLateEntered = false;
            _avatar?.SetVisible(false);
        }

        protected override void _OnDestroy()
        {
            if (_syncTask != null)
            {
                _syncTask.Destroy();
                _syncTask = null;
            }
        }
    }
}