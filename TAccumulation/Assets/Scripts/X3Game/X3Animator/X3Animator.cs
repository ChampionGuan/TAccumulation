using UnityEngine;
using System.Collections.Generic;
using Framework;
using PapeGames.CutScene;
using X3.Character;
using PapeGames.X3;

namespace X3Game
{
    /// <summary>
    /// 动画状态机，可以播放AnimationClip, ProceduralAnimationClip, CutScene
    /// </summary>
    [ExecuteInEditMode, DisallowMultipleComponent]
    public partial class X3Animator : MonoBehaviour
    {
        #region Attrs
        [SerializeField] private Animator m_Animator;
        [SerializeField] private Transform m_RootBone;
        [SerializeField] private List<State> m_EmbeddedStateList = new List<State>();
        [SerializeField] private string m_DefaultStateName;
        [SerializeField] private int m_AssetId;
        [SerializeField] private bool m_IsCharacter = false;
        private int LastUpdateFrameCount = 0;
        private static List<X3Animator> s_RunningAnimatorList = new List<X3Animator>();
        #endregion
        
        #region Mono Events

        private void Awake()
        {
            var controller = RuntimeStateController;
        }

        void Start()
        {
            if (RuntimeStateController.DefaultLayer.PlayedCount == 0)
                PlayDefault();
        }

        private void OnDestroy()
        {
            if (m_Controller != null)
            {
                ClearableObjectPool<X3Game.X3RuntimeStateController>.Release(m_Controller);
                m_Controller = null;
            }
            
            if (m_AnimationTree != null)
            {
                if (m_AnimationTree.ParentNode != null)
                    m_AnimationTree.ParentNode.RemoveSubNode(m_AnimationTree);
                m_AnimationTree.Dispose();
                s_AnimationTreePool.Release(m_AnimationTree);
                m_AnimationTree = null;
            }

            s_RunningAnimatorList.Remove(this);
        }

        X3RuntimeStateController RuntimeStateController
        {
            get
            {
                if (m_Controller == null && this != null)
                {
                    s_RunningAnimatorList.Remove(this);
                    s_RunningAnimatorList.Add(this);
                    m_Controller = ClearableObjectPool<X3Game.X3RuntimeStateController>.Get();
                    m_Controller.DefaultLayer.Tag = Tag;
                    m_Controller.DefaultLayer.EventReceiver = this;
                    IsCharacter = GetComponent<X3Character>() != null;
                    PlayableAnimationManager.Instance().AddAnimation(Animator, AnimationTree, EStaticSlot.Gameplay);
                    AddStatesFromEmbededList(m_EmbeddedStateList);
                    if (!string.IsNullOrEmpty(m_DefaultStateName))
                        SetDefaultState(m_DefaultStateName);
                    if (m_DefaultTransitionDuration > 0)
                        DefaultTransitionDuration = m_DefaultTransitionDuration;
                }
                return m_Controller;
            }
        }

        private void Update()
        {
            SequenceCheck();
            UpdateControlRig();
            if (LastUpdateFrameCount != Time.frameCount && AutoTick)
            {
                Evaluate(Time.deltaTime * Speed);
            }
        }

        #endregion

        #region CtsAndX3Animator...

        static Dictionary<int, X3Animator> s_CtsPlayIdDict;

        static Dictionary<int, X3Animator> CtsPlayIdDict
        {
            get
            {
                if (s_CtsPlayIdDict == null)
                    s_CtsPlayIdDict = new Dictionary<int, X3Animator>();

                return s_CtsPlayIdDict;
            }
        }

        public static void RegisterCtsPlayID(int playId, X3Animator x3Animator)
        {
            if (!CtsPlayIdDict.ContainsKey(playId))
                CtsPlayIdDict.Add(playId, x3Animator);
        }

        public static void UnregisterCtsPlayID(int playId)
        {
            if (CtsPlayIdDict.ContainsKey(playId))
                CtsPlayIdDict.Remove(playId);
        }

        public static X3Animator CtsPlayItemOwner(int playId)
        {
            if (CtsPlayIdDict.TryGetValue(playId, out var x3Animator))
                return x3Animator;
            return null;
        }

        #endregion

        #region Animator / Director / RootBone / AssetId / Tag
        
        public Animator Animator
        {
            get
            {
                if (m_Animator == null)
                {
                    m_Animator = GetComponentInChildren<Animator>();
                    if (!m_Animator)
                        m_Animator = gameObject.AddComponent<Animator>();
                    m_Animator.runtimeAnimatorController = null;
                }

                return m_Animator;
            }
        }

        public Transform RootBone
        {
            get
            {
                if (m_RootBone == null)
                {
                    m_RootBone = CommonUtility.FindChildRecursively(transform, "Roots");
                }

                return m_RootBone;
            }
        }

        public int AssetId
        {
            set { m_AssetId = value; }
            get
            {
                if (m_AssetId > 0)
                    return m_AssetId;
                var comp = GetComponent<PapeGames.CutScene.CutSceneParticipant>();
                if (comp != null)
                    return comp.AssetId;
                return 0;
            }
        }

        private int m_Tag = 0;

        public int Tag
        {
            set
            {
                m_Tag = value;
                if (m_AnimatorContext != null)
                    m_AnimatorContext.Tag = this.Tag;
            }
            get
            {
                if (m_Tag > 0)
                    return m_Tag;
                return this.GetInstanceID();
            }
        }

        /// <summary>
        /// 播放Cutscene时是否保持parent不变
        /// </summary>
        public bool KeepParent { get; set; } = false;

        [SerializeField] private bool m_InheritTransform = false;

        /// <summary>
        /// 播放Cts时是否同步位置信息
        /// </summary>
        public bool InheritTransform
        {
            set
            {
                m_InheritTransform = value;
                if (m_AnimatorContext != null)
                    m_AnimatorContext.InheritTransform = value;
            }
            get => m_InheritTransform;
        }

        /// <summary>
        /// 设置位置，有可能需要改CTS根节点位置
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="z"></param>
        public void SetPosition(float x, float y, float z)
        {
            var curState = RuntimeStateController.DefaultLayer.CurState;
            if (curState != null)
            {
                curState.SetPosition(x, y ,z);
            }
            else
            {
                transform.position = new Vector3(x, y, z);
            }
        }

        /// <summary>
        /// 设置旋转，有可能需要改CTS根节点旋转
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="z"></param>
        public void SetRotation(float x, float y, float z, float w)
        {
            var curState = RuntimeStateController.DefaultLayer.CurState;
            if (curState != null)
            {
                curState.SetRotation(x, y, z, w);
            }
            else
            {
                transform.rotation = new Quaternion(x, y, z, w);
            }
        }
        
        /// <summary>
        /// 设置旋转，有可能需要改CTS根节点旋转
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="z"></param>
        public void SetEulerAngles(float x, float y, float z)
        {
            var curState = RuntimeStateController.DefaultLayer.CurState;
            if (curState != null)
            {
                curState.SetEulerAngles(x, y, z);
            }
            else
            {
                transform.eulerAngles = new Vector3(x, y, z);
            }
        }
        #endregion

        #region Static Initialize / UnInitialize

        private static bool s_Inited = false;
        public static void Initialize(IX3AnimatorDataProvider dataProvider)
        {
            if (s_Inited)
                return;
            if (s_CutSceneAssetInsProvider == null)
                s_CutSceneAssetInsProvider = new CutSceneAssetInsProviderImplement();
            CutSceneAssetInsProvider.AddExternalCutSceneAssetInsProvider(s_CutSceneAssetInsProvider);
            if (dataProvider != null)
                s_DataProvider = dataProvider;
            s_Inited = true;
        }

        public static void UnInitialize()
        {
            s_DataProvider = null;
            if (s_CutSceneAssetInsProvider != null)
                CutSceneAssetInsProvider.RemoveExternalCutSceneAssetInsProvider(s_CutSceneAssetInsProvider);
            s_Inited = false;
        }

        public static List<X3Animator> RunningList
        {
            get => s_RunningAnimatorList;
        }
        #endregion
        
        #region X3AnimatorDataProvider

        private static IX3AnimatorDataProvider s_DataProvider;
        private static ExternalX3AnimatorStateData s_ExternalStateData;
        [SerializeField] private bool m_DataProviderEnabled = false;

        public static void SetDataProvider(IX3AnimatorDataProvider provider)
        {
            s_DataProvider = provider;
        }

        public bool DataProviderEnabled
        {
            set => m_DataProviderEnabled = value;
            get => m_DataProviderEnabled;
        }

        #endregion

        #region ICutSceneAssetInsProvider
        private class CutSceneAssetInsProviderImplement : ICutSceneAssetInsProvider
        {
            public GameObject OnGetCutSceneAssetIns(int ctsUID, int tag, int assetId)
            {
                if (s_RunningAnimatorList.Count == 0 || tag == 0 || assetId == 0)
                    return null;
                for (int i = s_RunningAnimatorList.Count - 1; i >= 0; i--)
                {
                    var comp = s_RunningAnimatorList[i];
                    if (comp == null || comp.gameObject == null)
                    {
                        s_RunningAnimatorList.Remove(comp);
                        continue;
                    }

                    if (comp.Tag == tag && comp.AssetId == assetId)
                        return comp.gameObject;
                }

                return null;
            }

            public bool OnReleaseCutSceneAssetIns(int ctsUID, int tag, int assetId, GameObject ins)
            {
                if (s_RunningAnimatorList.Count == 0 || tag == 0 || assetId == 0)
                    return false;
                for (int i = s_RunningAnimatorList.Count - 1; i >= 0; i--)
                {
                    var comp = s_RunningAnimatorList[i];
                    if (comp == null || comp.gameObject == null)
                    {
                        s_RunningAnimatorList.Remove(comp);
                        continue;
                    }

                    if (comp.Tag == tag && comp.AssetId == assetId && comp.gameObject == ins)
                        return true;
                }
                return false;
            }
        }
        private static CutSceneAssetInsProviderImplement s_CutSceneAssetInsProvider;
        #endregion

        #region Attrs
        
        public bool IsCharacter
        {
            get => m_IsCharacter;
            set => m_IsCharacter = value;
        }

        public float Speed { get; set; } = 1.0f;

        public bool AutoTick = true;

        #endregion
    }
}

