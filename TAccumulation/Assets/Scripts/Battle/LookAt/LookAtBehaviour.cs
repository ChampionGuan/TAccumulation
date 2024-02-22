using System.Collections.Generic;
using Framework;
using PapeAnimation;
using PapeGames.BlendSpaceX3;
using PapeGames.X3;
using X3.Character;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Playables;
using System.Linq;
using System;

namespace X3Battle
{
    public class LookAtBehaviour : MonoBehaviour
    {
        public LookAtState state = LookAtState.Ignored;

        private readonly string NATURE_CLIP_NAME = "Nature";
        private readonly string UP_CLIP_NAME = "Up";
        private readonly string DOWN_CLIP_NAME = "Down";
        private readonly string LEFT_CLIP_NAME = "Left";
        private readonly string LEFT_DOWN_CLIP_NAME = "Left_Down";
        private readonly string LEFT_UP_CLIP_NAME = "Left_Up";
        private readonly string RIGHT_CLIP_NAME = "Right";
        private readonly string RIGHT_DOWN_CLIP_NAME = "Right_Down";
        private readonly string RIGHT_UP_CLIP_NAME = "Right_Up";

        public static readonly string MONSTER_CONFIG_PATH = "MonsterLookAtSettings";        

        public BlendSpaceAsset blendSpaceAsset;
        public string blendSpacePath;

        [Range(0, 1000)]
        public float headRotateTime;

        private float modelHeight = 1.0f;
        private float modelLength = 1.0f;

        [Range(0, 180)]
        public float horizontalAngle = 90.0f;
        [Range(0, 180)]
        public float verticalAngle = 90.0f;

        private float endFadeTime => headRotateTime;           // the speed for head back to normal

        public Transform Target;

        /// <summary>
        /// The weight to control LookAt system 
        /// </summary>
        [HideInInspector]
        public float Weight 
        {
            get { return _weight; }
            set 
            {
                if (value != _weight)
                {
                    _weight = value;
                    _weightChanged = true;
                }
            }
        }

        [SerializeField]
        private float _weight = 1.0f;

#if UNITY_EDITOR
        private float _lastWeight = 1.0f;
        public bool enableGizmos = true;
#endif
        float smoothDampSpeedX = 0.0f;
        float smoothDampSpeedY = 0.0f;

        private bool _initialized = false;

        private List<string> _leftBoneChain;
        private List<string> _rightBoneChain;
        private string _headName;

        // 美术资产支持的最大头部转角
        public float maxHoriArtAngle = 75.0f;
        public float maxVertArtAngle = 75.0f;

        public Vector3 targetOffset = Vector3.zero;

        private bool _following = false;

        private Dictionary<AnimationClip, float> playableWeightsDic = new Dictionary<AnimationClip, float>();
        private Dictionary<AnimationClip, string> clipNamesDic = new Dictionary<AnimationClip, string>();

        private bool _weightChanged = false;

        #region Subsystem接口

#if UNITY_EDITOR
        public void OnDrawGizmos()
        {
            if (!enableGizmos)
                return;

            // 绘制实时看向的信息
            if (Target == null)
                return;

            Vector3 eyesCenterPos = EyesCenterPosition;
            Vector3 dir = (Target.position + targetOffset - eyesCenterPos).normalized;
            Vector3 forward = _root.forward;

            // Not look in the back
            if (Vector3.Dot(forward, dir) < 0)
                return;

            // 计算水平范围的夹角
            Vector3 dirOnXZ = Vector3.ProjectOnPlane(dir, _root.up);
            float angleH = Vector3.SignedAngle(_root.forward, dirOnXZ, _root.up);

            // 计算竖直范围的夹角
            Vector3 dirOnXY = Vector3.ProjectOnPlane(dir, _root.right);
            float angleV = -Vector3.SignedAngle(_root.forward, dirOnXY, _root.right);

            //LogProxy.Log("Angle H: " + angleH);
            //LogProxy.Log("Angle V: " + angleV);

            Gizmos.color = Color.red;
            Gizmos.DrawRay(eyesCenterPos, Target.position + targetOffset - eyesCenterPos);

            return;
        }
#endif

        public void Start()
        {
            if (!_initialized)
            {
                _initialized = true;

                animator = GetComponent<Animator>();

                _InitParams();
                _InitBones();
                _InitClip();
            }
        }

        public void _InitClip()
        {
            if (!_initialized)
                return;

            if (blendSpaceAsset == null)
            {
                _initialized = false;
                this.enabled = false;
                return;
            }

            if (!_CheckBlendSpacesValid())
                return;

            clipNamesDic.Clear();
            for (int i = 0; i < blendSpaceAsset.Samples.Count; i++)
                clipNamesDic.Add(blendSpaceAsset.Samples[i].Sequence, blendSpaceAsset.Samples[i].Sequence.name);

            if (_bodyNode == null)
            {
                //_recorderNode = new LookAtHandRecorderAnimationNode("Bip001 L Finger0Nub", "Bip001 R Finger0Nub");
                //_recorderNode = new LookAtHandRecorderAnimationNode("Bip001 L Hand", "Bip001 R Hand");
                _recorderNode = new LookAtHandRecorderAnimationNode(_leftBoneChain[0], _rightBoneChain[0]);
                PlayableAnimationManager.Instance().AddDynamicNode(animator, _recorderNode, MixerType.Script);

                _bodyNode = new LookAtBodyAnimationNode(blendSpaceAsset);
                PlayableAnimationManager.Instance().AddDynamicNode(animator, _bodyNode, MixerType.LayerMixer);

                _IKNode = new LookAtHandIKAnimationNode(_recorderNode);
                //_IKNode.SetIKChainName(new List<string> { "Bip001 L Finger0Nub", "Bip001 L Finger0", "Bip001 L Hand" }, new List<string> { "Bip001 R Finger0Nub", "Bip001 R Finger0", "Bip001 R Hand" });
                _IKNode.SetIKChainName(_leftBoneChain, _rightBoneChain);
                //_IKNode.SetIKChainName(new List<string> { "Bip001 L Hand", "Bip001 L Forearm", "Bip001 L UpperArm" }, new List<string> { "Bip001 R Hand", "Bip001 R Forearm", "Bip001 R UpperArm" });
                PlayableAnimationManager.Instance().AddDynamicNode(animator, _IKNode, MixerType.Script);

                _bodyNode.SetWeight(1.0f);

                int id = _bodyNode.ParentIndex;

                if (id != -1)
                {
                    _bodyNode.ParentNode.GetMixer().SetLayerAdditive((uint)id, true);

                    //if (blendSpaceAsset.mask != null)
                    //    _bodyNode.ParentNode.GetMixer().SetLayerMaskFromAvatarMask((uint)id, blendSpaceAsset.mask);
                    //else
                    //{
                    //    LogProxy.LogError("blendSpaceAsset资源里没有引用到对应的LookAtAvatarMask文件");
                    //}
                }
            }

            _dummyClipNames = new string[9];
            // 这里的顺序来自美术资源, 从0到8分别是：
            // nature, down, up, left, left up, left down, right, right down, right up
            _dummyClipNames[0] = NATURE_CLIP_NAME;
            _dummyClipNames[1] = DOWN_CLIP_NAME;
            _dummyClipNames[2] = UP_CLIP_NAME;
            _dummyClipNames[3] = LEFT_CLIP_NAME;
            _dummyClipNames[4] = LEFT_UP_CLIP_NAME;
            _dummyClipNames[5] = LEFT_DOWN_CLIP_NAME;
            _dummyClipNames[6] = RIGHT_CLIP_NAME;
            _dummyClipNames[7] = RIGHT_DOWN_CLIP_NAME;
            _dummyClipNames[8] = RIGHT_UP_CLIP_NAME;
        }

        public void OnDisable()
        {
            if (!_initialized)
                return;

            if (_bodyNode != null)
            {
                PlayableAnimationManager.Instance().RemoveDynamicNode(_bodyNode, true);
                _bodyNode = null;

                PlayableAnimationManager.Instance().RemoveDynamicNode(_recorderNode, true);
                _recorderNode = null;

                PlayableAnimationManager.Instance().RemoveDynamicNode(_IKNode, true);
                _IKNode = null;
            }
            Target = null;

            _dummyClipNames = null;
        }

        public void OnDestroy()
        {
            if (blendSpaceAsset != null)
                BattleResMgr.Instance.Unload(blendSpaceAsset);

            Target = null;

            _root = null;
            blendSpaceAsset = null;
            _initialized = false;
        }

        public void Update()
        {
            if (!_initialized)
                return;

            if (_head != null && _root != null)
            {
                if (Target == null)
                {
                    var curHeight = _head.position.y - _root.position.y;
                    modelHeight = curHeight;
                }
            }

            _UpdateBlendSpacePlayableWeights();
        }

        public void LateUpdate()
        {
            if (!_initialized)
                return;

            float angleH = 0, angleV = 0;

            if (Target != null)
            {
                Vector3 eyesCenterPos = EyesCenterPosition;

                Vector3 dir = (Target.position + targetOffset - eyesCenterPos).normalized;

                // 计算水平范围的夹角, 把方向投影到XZ平面上计算
                Vector3 dirOnXZ = Vector3.ProjectOnPlane(dir, _root.up).normalized;
                angleH = Vector3.SignedAngle(_root.forward, dirOnXZ, _root.up);

                // 计算竖直范围的夹角, 直接计算dirOnXZ与原本方向的夹角即可
                angleV = Mathf.Acos(Vector3.Dot(dirOnXZ, dir)) * Mathf.Rad2Deg;
                if (float.IsNaN(angleV) || float.IsInfinity(angleV))
                    angleV = 0;

                bool up = Vector3.Dot(dir, _root.up) > 0 ? true : false;
                if (!up)
                    angleV = -angleV;

                if (angleV > -maxVertArtAngle && angleV < maxVertArtAngle && angleH > -maxHoriArtAngle
                    && angleH < maxHoriArtAngle)
                {
                    _following = true;
                }
                else
                {
                    if (angleH > maxHoriArtAngle && angleH <= horizontalAngle)
                        angleH = maxHoriArtAngle;
                    else if (angleH < -maxHoriArtAngle && angleH >= -horizontalAngle)
                        angleH = -maxHoriArtAngle;
                    else if (angleV > maxVertArtAngle && angleV <= verticalAngle)
                        angleV = maxVertArtAngle;
                    else if (angleV < -maxVertArtAngle && angleV >= -verticalAngle)
                        angleV = -maxVertArtAngle;
                    else
                        _following = false;
                }
                //LogProxy.Log("Angle H: " + angleH);
                //LogProxy.Log("Angle V: " + angleV);
            }


            bool targetInRange = false;

            if (Target != null)
            {
                bool outRange = angleH < -horizontalAngle || angleH > horizontalAngle ||
                    angleV < -verticalAngle || angleV > verticalAngle;
                targetInRange = !outRange;
            }

            if (targetInRange)
            {
                state = LookAtState.Target;

                float x = math.remap(-maxHoriArtAngle, maxHoriArtAngle, -1, 1, angleH);
                float y = math.remap(-maxVertArtAngle, maxVertArtAngle, -1, 1, angleV);

                if (math.abs(maxHoriArtAngle) < math.EPSILON)
                    x = 0;
                
                if (math.abs(maxVertArtAngle) < math.EPSILON)
                    y = 0;

                _blendSpaceInput.x = Mathf.SmoothDamp(_blendSpaceInput.x, x, ref smoothDampSpeedX, headRotateTime);
                _blendSpaceInput.y = Mathf.SmoothDamp(_blendSpaceInput.y, y, ref smoothDampSpeedY, headRotateTime);
            }
            else
            {
                state = LookAtState.Fading;
            }

            if (state == LookAtState.Fading)
            {
                _blendSpaceInput.x = Mathf.SmoothDamp(_blendSpaceInput.x, 0, ref smoothDampSpeedX, endFadeTime);
                _blendSpaceInput.y = Mathf.SmoothDamp(_blendSpaceInput.y, 0, ref smoothDampSpeedY, endFadeTime);

                if (Mathf.Abs(_blendSpaceInput.x) < 0.001 && Mathf.Abs(_blendSpaceInput.y) < 0.001)
                {
                    state = LookAtState.Ignored;
                    _blendSpaceInput = Vector2.zero;
                }
            }
        }
        #endregion


        #region 对外函数
        public bool LookAtTarget(Transform t, Vector3 offset = new Vector3())
        {
            if (!_initialized || _bodyNode == null)
                return false;

            targetOffset = offset;

            if (t == Target)
                return true;

            Target = t;

            if (Target == null)
            {
                state = LookAtState.Fading;
                var curHeight = _head.position.y - _root.position.y;
                modelHeight = curHeight;
            }

            return true;
        }

        public LookAtState GetCurrentState()
        {
            return state;
        }
        #endregion

        #region Private Utilities

        void _InitBones()
        {
            _root = gameObject.transform.parent;

            if (_root == null)
            {
                _initialized = false;
                this.enabled = false;
                return;
            }

            _head = _FindDeepChild(gameObject.transform, _headName);

            if (_head == null)
            {
                //LogProxy.LogError(string.Format( "Can't find {0} in {1}'s hierarchy", _headName, gameObject.transform.parent.name));
                this.enabled = false;
                _initialized = false;
                return;
            }

            modelHeight = _head.position.y - _root.position.y;
            modelLength = Vector3.Distance(new Vector3(_head.position.x, 0, _head.position.z), new Vector3(_root.position.x, 0, _root.position.z));
        }

        void _InitParams()
        {
            var config = Battle.Instance.misc.lookAtCfg;
            if (config == null)
            {

                this.enabled = false;
                return;
            }
            if (blendSpaceAsset == null)
            {
                if (BattleResMgr.Instance.IsExists(blendSpacePath, BattleResType.BlendSpaceAsset))
                {
                    blendSpaceAsset = BattleResMgr.Instance.Load<BlendSpaceAsset>(blendSpacePath, BattleResType.BlendSpaceAsset);
                }
                if (blendSpaceAsset == null)
                {
                    this.enabled = false;
                    return;
                }

                LookAtConfig.MonsterMapppingData data = null;
                for (int i = 0; i < config.monsterData.Count; i++)
                {
                    var name = config.monsterData[i].name.Replace(" ", "");
                    var subStrs = name.Split(';');
                    foreach (var item in subStrs)
                    {
                        if (item == blendSpacePath)
                        {
                            data = config.monsterData[i];
                            i = config.monsterData.Count;
                            break;
                        }
                    }
                }

                if (data != null)
                {
                    _leftBoneChain = data.leftFootChain;
                    _rightBoneChain = data.rightFootChain;
                    _headName = data.headName;

                    horizontalAngle = data.horizontalAngle;
                    verticalAngle = data.verticalAngle;

                    maxHoriArtAngle = data.maxArtHorizontalAngle;
                    maxVertArtAngle = data.maxArtVerticalAngle;
            
                    headRotateTime = data.headRotateTime;

                    if (headRotateTime == 0)
                        headRotateTime = 0.01f;

                    Weight = 1.0f;
                }
            }
        }

        //Breadth-first search
        private Transform _FindDeepChild(Transform aParent, string aName)
        {
            Queue<Transform> queue = new Queue<Transform>();
            queue.Enqueue(aParent);
            while (queue.Count > 0)
            {
                var c = queue.Dequeue();
                if (c.name == aName)
                    return c;
                foreach (Transform t in c)
                    queue.Enqueue(t);
            }
            return null;
        }

        private void _UpdateBlendSpacePlayableWeights()
        {
#if UNITY_EDITOR
            // 为了方便直接在Inspector里改变Weight又能即使生效, 在Editor下每帧判断weight是否改变
            if (_lastWeight != _weight)
            {
                _weightChanged = true;
                _lastWeight = _weight;
            }
#endif

            if (_weightChanged)
            {
                _weight = Mathf.Clamp(_weight, 0.0f, 1.0f);
                _bodyNode?.SetWeight(Weight);
                _weightChanged = false;
            }
            else if (_lastBlendSpaceInput == _blendSpaceInput)
                return;

            _lastBlendSpaceInput = _blendSpaceInput;

            var input = _blendSpaceInput;
            input.x = input.x > 1 ? 1 : input.x;
            input.y = input.y > 1 ? 1 : input.y;

         
            // 利用这里的dummy blendspace asset算出各个Clip的权重
            bool valid = BlendSpaceManager.CalculateClipWeights(blendSpaceAsset, input, playableWeightsDic);
            if (!valid)
            {
                _initialized = false;
                this.enabled = false;
                return;
            }

            var bodyMixer = _bodyNode.GetMixerPlayable();
            // 这里的顺序来自美术资源, 从0到8分别是：
            // nature, down, up, left, left up, left down, right, right down, right up
            for (int i = 0; i < bodyMixer.GetInputCount(); i++)
            {
                // 根据i, 找到对应的Clip的名字, 再在BlendSpace里查询该Clip对应的权重
                string dummyName = _dummyClipNames[i];

                AnimationClip target = null;
                foreach (var item in playableWeightsDic)
                {
                    if (clipNamesDic.ContainsKey(item.Key))
                    {
                        string n = clipNamesDic[item.Key];
                        if (n.Length == dummyName.Length && string.Compare(n, dummyName, StringComparison.Ordinal) == 0)
                        {
                            target = item.Key;
                            break;
                        }
                    }
                }

                if (target != null && playableWeightsDic.ContainsKey(target))
                    bodyMixer.SetInputWeight(i, playableWeightsDic[target]);
                else
                    bodyMixer.SetInputWeight(i, 0.0f);
            }
        }

        private bool _CheckBlendSpacesValid()
        {
            if (blendSpaceAsset == null)
            {
                //LogProxy.LogError("Null BlendSpaceAsset when using LookAt Subsystem!");
                _initialized = false;
                this.enabled = false;
                return false;
            }

            if (blendSpaceAsset.Samples == null || blendSpaceAsset.Samples.Count == 0 ||
                blendSpaceAsset.Elements == null || blendSpaceAsset.Elements.Count == 0)
            {
                //LogProxy.LogError("BlendSpaceAsset Data Error when using LookAt Subsystem!");
                this.enabled = false;
                _initialized = false;
                return false;
            }

            return true;
        }

        Vector3 EyesCenterPosition => _root.position + new Vector3(0, modelHeight, 0) + _root.forward * modelLength;

        //public bool EnabledSelf { get; private set; }
        #endregion

        #region Private Data

        public enum LookAtState
        {
            Target,
            Fading,
            Ignored
        }


        Vector2 _blendSpaceInput;
        Vector2 _lastBlendSpaceInput;

        Transform _root;
        Transform _head;

        X3.Character.LookAtBodyAnimationNode _bodyNode;
        LookAtHandIKAnimationNode _IKNode;
        LookAtHandRecorderAnimationNode _recorderNode;
        internal Animator animator;
        string[] _dummyClipNames;
        #endregion
    }
}
