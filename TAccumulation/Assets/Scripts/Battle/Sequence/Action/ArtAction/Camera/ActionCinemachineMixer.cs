using Cinemachine;
using PapeGames;
using System.Collections.Generic;

namespace X3Battle
{
    public class ActionCinemachineMixer:BSAction
    {
        private CinemachineBrain mBrain;
        private int mBrainOverrideId = -1;
        private bool EnableBlending = true;
        private float lastCamWeightB = 1;
        private List<CameraShot> _cameraShots = new List<CameraShot>();

        protected override void _OnInit()
        {
            // 关闭track生成原生playable
            var track = GetTrackAsset<CameraMixingTrack>();

            _cameraShots.Clear();
            var timelineClips = track.GetClipsArray();
            foreach(var clip in timelineClips)
            {
                var cameraShot = new CameraShot();
                var shot = (clip.asset as CinemachineShot);
                
                var obj = GetExposedValue(shot.VirtualCamera);
                if (obj != null && obj is CinemachineVirtualCameraBase virtualCamera)
                {
                    cameraShot.VirtualCamera = virtualCamera;
                }

                cameraShot.pitchMin = shot.pitchMin;
                cameraShot.pitchMax = shot.pitchMax;
                cameraShot.yawMin = shot.yawMin;
                cameraShot.yawMax = shot.yawMax;

                cameraShot.start = clip.start;
                cameraShot.end = clip.end;

                _cameraShots.Add(cameraShot);

                _cameraShots.Sort((x, y) => { return x.start.CompareTo(y.start); }) ; // 按start时间升序排列
            }
        }

        protected override void _OnDestroy()
        {
            if (mBrain != null)
                mBrain.ReleaseCameraOverride(mBrainOverrideId); // clean up        
            mBrainOverrideId = -1;
        }
        protected override void _OnEnter()
        {
            base._OnEnter();
            _Reset();
            _OnUpdate();
        }

        protected override void _OnExit()
        {
            base._OnExit();
            mBrainOverrideId = mBrain.SetCameraOverride(mBrainOverrideId, null, null, 0, deltaTime);
            mBrain.ReleaseCameraOverride(mBrainOverrideId);
            mBrainOverrideId = -1;

        }

        protected override void _OnUpdate()
        {
            mBrain = GetTrackBindObj<CinemachineBrain>();
            if (mBrain == null)
                return;

            int activeInputs = 0;
            ClipInfo clipA = new ClipInfo();
            ClipInfo clipB = new ClipInfo();
            for(int i = 0; i < _cameraShots.Count; i ++)
            {
                float weight = GetInputWeight(i);

                var shot = _cameraShots[i];
                if(shot!=null && weight>0)
                {
                    clipA = clipB;
                    clipB.vcam = shot.VirtualCamera;
                    clipB.weight = weight;
                    clipB.localTime = curOffsetTime - shot.start;
                    clipB.duration = shot.end - shot.start;
                    clipB.pitchMin = shot.pitchMin;
                    clipB.pitchMax = shot.pitchMax;
                    clipB.yawMax = shot.yawMax;
                    clipB.yawMin = shot.yawMin;

                    if (++activeInputs == 2)
                        break;
                }
            }

            bool incomingIsB = clipB.weight >= 1 || clipB.localTime < clipB.duration / 2;
            if (activeInputs == 2)
            {
                if (clipB.localTime < clipA.localTime)
                    incomingIsB = true;
                else if (clipB.localTime > clipA.localTime)
                    incomingIsB = false;
                else
                    incomingIsB = clipB.duration >= clipA.duration;
            }

            // Override the Cinemachine brain with our results
            ICinemachineCamera camA = incomingIsB ? clipA.vcam : clipB.vcam;
            ICinemachineCamera camB = incomingIsB ? clipB.vcam : clipA.vcam;
            ClipInfo camAClip = incomingIsB ? clipA : clipB;

            float camWeightB = incomingIsB ? clipB.weight : 1 - clipB.weight;

            // 当美术virtualCamera被禁用时，不播放美术镜头
            // TODO：长空 后面支持禁用整条轨道
            if (camA != null)
                camA = (camA as CinemachineVirtualCameraBase).enabled ? camA : null;
            if (camB != null)
                camB = (camB as CinemachineVirtualCameraBase).enabled ? camB : null;
            //

            if (camA != null && camB != null && lastCamWeightB == 1 && camWeightB < 1)
            {
                // when the Timeline blending start
                var deltayawAB = camB.State.CorrectedOrientation.eulerAngles.y - camA.State.CorrectedOrientation.eulerAngles.y;

                if (deltayawAB > 180)
                    deltayawAB -= 360;
                else if (deltayawAB < -180)
                    deltayawAB += 360;

                var pitchA = camA.State.CorrectedOrientation.eulerAngles.x > 180 ? camA.State.CorrectedOrientation.eulerAngles.x - 360 : camA.State.CorrectedOrientation.eulerAngles.x;
                var pitchB = camB.State.CorrectedOrientation.eulerAngles.x > 180 ? camB.State.CorrectedOrientation.eulerAngles.x - 360 : camB.State.CorrectedOrientation.eulerAngles.x;

                if (camAClip.pitchMin == 0 && camAClip.pitchMax == 0 && camAClip.yawMin == 0 && camAClip.yawMax == 0)
                {
                    EnableBlending = true;
                }
                else if (pitchB - pitchA < camAClip.pitchMin || pitchB - pitchA > camAClip.pitchMax || deltayawAB < camAClip.yawMin || deltayawAB > camAClip.yawMax)
                {
                    EnableBlending = false;
                }
            }
            if (camWeightB >= 1 && EnableBlending == false)
            {
                // blending is over
                EnableBlending = true;
            }

            lastCamWeightB = camWeightB;

            if (EnableBlending)
                mBrainOverrideId = mBrain.SetCameraOverride(mBrainOverrideId, camA, camB, camWeightB, deltaTime);
            else
                mBrainOverrideId = mBrain.SetCameraOverride(mBrainOverrideId, camA, camB, 1, deltaTime);
        }

        private float GetInputWeight(int i)
        {
            if (_cameraShots[i].start > curOffsetTime || _cameraShots[i].end < curOffsetTime)
                return 0;

            if (i < _cameraShots.Count - 1 && _cameraShots[i + 1].start < curOffsetTime)
            {
                double blendTime = _cameraShots[i].end - _cameraShots[i + 1].start;
                float weight = (float)((curOffsetTime - _cameraShots[i + 1].start) / blendTime);
                return weight;
            }
            else if (i > 0 && _cameraShots[i - 1].end > curOffsetTime)
            {
                double blendTime = _cameraShots[i - 1].end - _cameraShots[i].start;
                float weight = (float)((curOffsetTime - _cameraShots[i].start) / blendTime);
                return weight;
            }
            else
            {
                return 1;
            }
        }

        private void _Reset()
        {
            EnableBlending = true;
            lastCamWeightB = 1;
        }

        struct ClipInfo
        {
            public ICinemachineCamera vcam;
            public float weight;
            public double localTime;
            public double duration;
            public float pitchMin;
            public float pitchMax;
            public float yawMin;
            public float yawMax;
        }
    }

    
}
