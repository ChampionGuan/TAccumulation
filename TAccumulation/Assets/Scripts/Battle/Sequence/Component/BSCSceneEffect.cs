using Cinemachine;
using PapeGames;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using X3;

namespace X3Battle
{
    public class BSCSceneEffect : BSCBase, IReset
    {
        // 场景特效的怪物目标 是爆发技拉的那只怪.
        private Actor _monsterActor;
        private Vector3? _hookPos;  // 局部位置
        private Vector3? _hookEuler;  // 局部旋转
        
        protected override bool _OnBuild()
        {
            var resCom = _battleSequencer.GetComponent<BSCRes>();
            var artAsset = resCom.artAsset;
            if (artAsset != null)
            {
                foreach (var trackAsset in artAsset.GetOutputTracks())
                {
                    if (trackAsset is TransformOperationTrack transOperationTrack)
                    {
                        var parent = trackAsset.parent;
                        if (parent != null && parent.name == "Loop Fx Group")
                        {
                            var clips = transOperationTrack.GetClipsArray();
                            if (clips.Length > 0)
                            {
                                var clip = clips[0];
                                if (clip.asset is TransformOperationClip operationClip)
                                {
                                    _hookPos = operationClip.operationData.position;
                                    _hookEuler = operationClip.operationData.rotation;
                                    break;
                                }
                            }
                        }
                    }
                }
                
                // SceneEffect直接强行禁掉virtual所在GameObject
                var artDirector = resCom.artDirector;
                if (artDirector != null)
                {
                    var cinemachineVirtualCameras = artDirector.GetComponentsInChildren<CinemachineVirtualCamera>();
                    for (var i = 0; i < cinemachineVirtualCameras.Length; i++)
                    {
                        cinemachineVirtualCameras[i].gameObject.SetActive(false);
                    }
                }
            }

            return true;
        }

        public void Replay()
        {
            _FindMonster();

            // 策划的特殊需求：场景特效timeline需要基于女主位置
            var resCom = _battleSequencer.GetComponent<BSCRes>();
            var timelineObj = resCom.artObject;
            var actor = Battle.Instance.actorMgr.player;
            var pos = actor?.transform.position;
            if (timelineObj != null && pos != null)
            {
                timelineObj.transform.position += pos.Value;
            }
            
            var tracks = resCom.artAsset?.GetOutputTracks();
            if (tracks != null)
            {
                foreach (var track in tracks)
                {
                    if (track is ControlTrack controlTrack)
                    {
                        var roleType = BSTypeUtil.GetBindRoleTypeByTrackExtData(controlTrack.extData);
                        if (roleType == TrackBindRoleType.Monster)
                        {
                            var clips = track.GetClipsArray();
                            foreach (var timelineClip in clips)
                            {
                                if (timelineClip.asset is ControlPlayableAsset controlAsset)
                                {
                                    var obj = resCom.artDirector.GetReferenceValue(controlAsset.sourceGameObject.exposedName, out var _) as GameObject;
                                    if (obj != null)
                                    {
                                        var extData = controlTrack.extData;
                                        // 目前这样能绑定到Model上，满足当前需求，后续根据需要开启LateUpdate才能保证分离正确
                                        if (_monsterActor != null)
                                        {
                                            var monsterModel = _monsterActor.GetDummy(ActorDummyType.Model);
                                            obj.transform.parent = monsterModel;
                                            obj.transform.localPosition = extData.localPosition;
                                            obj.transform.localEulerAngles = extData.localRotation;
                                            obj.transform.localScale = extData.localScale;
                                        }
                                        else
                                        {
                                            if (_hookPos != null)
                                            {
                                                // 有hookPos走动态计算逻辑
                                                obj.transform.parent = null;
                                                obj.transform.localScale = controlTrack.extData.localScale;
                                                _CalculateLocalTransWithoutMonster(_hookPos.Value, _hookEuler.Value, extData.localPosition, extData.localRotation, out var worldPos, out var worldRotation);
                                                obj.transform.localPosition = worldPos;
                                                obj.transform.localRotation = worldRotation;
                                            }
                                            else
                                            {
                                                // 没有HookPos直接放到天上 (performRootTrans在天上500处)
                                                obj.transform.parent = Battle.Instance.performRootTrans;
                                                obj.transform.localPosition = Vector3.zero;
                                                obj.transform.localEulerAngles = extData.localRotation;
                                                obj.transform.localScale = extData.localScale;  
                                            }
                                        }
                                    }
                                }   
                            }   
                        }
                    }
                }
            }
        }

        private void _CalculateLocalTransWithoutMonster(Vector3 monsterPos, Vector3 monsterEuler, Vector3 fxLocalPos, Vector3 fxLocalEuler, out Vector3 worldPos, out Quaternion worldRotation)
        {
            var girl = Battle.Instance.actorMgr.player;
            var girlTrans = girl.GetDummy();
            // 怪物坐标系原点在世界中表示
            var originalPos = girlTrans.TransformPoint(monsterPos);
            //  怪物坐标系forward在世界中表示
            var forward = girlTrans.TransformDirection(Quaternion.Euler(monsterEuler) * Vector3.forward);
            // 怪物坐标系right在世界中表示
            var right = Vector3.Cross(Vector3.up, forward);

            worldPos = originalPos + fxLocalPos.x * right + fxLocalPos.y * Vector3.up + fxLocalPos.z * forward;
            worldRotation = girlTrans.rotation * Quaternion.Euler(monsterEuler) * Quaternion.Euler(fxLocalEuler);
        }

        protected override void _OnInit()
        {
            var bindCom = _battleSequencer.GetComponent<BSCTrackBind>();
            bindCom.notBindCreator = true;
        }

        public void Reset()
        {
            _monsterActor = null;
            _hookPos = null;
            _hookEuler = null;
        }
        
        private void _FindMonster()
        {
            _monsterActor = null;
            var girl = Battle.Instance.actorMgr.player;
            var actor = girl?.GetTarget(TargetType.Skill);
            if (actor != null)
            {
                _monsterActor = actor;
            }
        }
    }
}