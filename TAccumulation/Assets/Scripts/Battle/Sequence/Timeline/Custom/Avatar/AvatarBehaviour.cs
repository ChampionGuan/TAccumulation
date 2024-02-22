using PapeGames.X3;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Profiling;
using UnityEngine.Timeline;
using X3;
using X3.Character;
using X3Battle;
using ISubsystem = X3.Character.ISubsystem;

namespace PapeGames
{
    public class AvatarBehaviour : InterruptBehaviour
    {
        public int bindSuitId { get; set; }
        public Material bindMaterial { get; set; }

        private GameObject _referenceTarget;
        private GameObject _avatar;
        
        // 开始运行
        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            if (playerData != null && playerData is GameObject bindObj && bindSuitId > 0)
            {
                _referenceTarget = bindObj;
                using (ProfilerDefine.AvatarBehaviourOnStartMarker.Auto())
                {
                    // 首次执行会创建
                    if (_avatar == null)
                    {
                        _avatar = BattleCharacterMgr.GetInsBySuitID(bindSuitId);
                        if (_avatar != null)
                        {
                            _avatar.RemoveComponent<Animator>();
                            var com = _avatar.GetComponent<X3Character>();
                            if (com != null && bindMaterial != null)
                            {
                                com.SetToClone(bindMaterial); 
                            }

                            var physicsWind = com.GetSubsystem(ISubsystem.Type.PhysicsCloth);
                            if (physicsWind != null)
                            {
                                physicsWind.EnabledSelf = false;
                            }

                        }  
                    }

                    if (_avatar != null)
                    {
                        _avatar.SetVisible(true);
                        X3TimelineUtility.SyncTrans(_referenceTarget.transform, _avatar.transform);
                    }
                }
            }
        }

        // 结束时或者被打断时调用，如果没有OnStart肯定不会调用过来
        protected override void OnStop()
        {
            if (_avatar != null)
            {
                _avatar.SetVisible(false);
            }
        }

        protected override void OnGraphDestroyInEditor()
        {
            if (_avatar != null)
            {
                GameObject.DestroyImmediate(_avatar);
                _avatar = null;
            }
        }
    }
}