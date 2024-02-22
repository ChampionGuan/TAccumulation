using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using PapeGames;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Profiling;
using UnityEngine.Serialization;
using UnityEngine.Timeline;
using Object = UnityEngine.Object;

#if UNITY_EDITOR
using Cinemachine;
using UnityEditor;
using X3Battle;
#endif

[Serializable]
public class EffectAuxiliaryInfo
{
    public string prefabName; //父节点
    public string DummyName; //Control Track
    public string[] AnimationPath; //AnimationName和DummyName不会同时存在。AnimationName--AnimationTrack
    public string effectName; //当前特效
    public Vector3 localPosition;
    public Vector3 localRotation;
    public Vector3 localScale;
    public string[] AnimationName;
    public string ParentTag;

    public EffectAuxiliaryInfo()
    {
        prefabName = "";
        DummyName = "";
        AnimationPath = new string[100];
        effectName = "";
        AnimationName = new string[100];
        ParentTag = "";
    }
}

[Serializable]
public class TimelineExtInfo : MonoBehaviour, INotificationReceiver
{
    [HideInInspector]
    [LabelText("是否跟随人物移动")]
    public bool isFollowActorForTimeline = false; // lua层有在用
    
    [LabelText("是否三段式")]
    public bool isThreeState;  // 是否三段式timeline
    [LabelText("    Loop段起始帧", showCondition = "isThreeState")]
    public int loopStartFrame;  // loop段起始帧号
    [LabelText("    Loop段结束帧", showCondition = "isThreeState")]
    public float loopEndFrame;  // loop段结束帧号

    [HideInInspector] public EffectAuxiliaryInfo[] datas;
    
    [HideInInspector] public TrackResRecorder resRecorder = new TrackResRecorder();

    //在当前特效中已经生成的人物
    public Dictionary<string, GameObject> heroPrefabDic = new Dictionary<string, GameObject>();
    private PlayableDirector curDirector;

    [HideInInspector] public bool showCircle = false;
    [HideInInspector] public float radius = 1f;

    public Dictionary<GameObject, string> prefabPathDic = new Dictionary<GameObject, string>(); //保存gameobject的路径
#if UNITY_EDITOR
    
    public Dictionary<GameObject, string> effectPrefabDict = new Dictionary<GameObject, string>();
#endif
    private const string RolePath = "/Build/Res/Battle/Actors/";

    private const string effectPath = @"/Build/Art/Timeline/Prefabs/";

    private const string Const_Girl = "(Girl)";
    private const string Const_Boy = "(Boy)";
    
    public System.Action<Marker> onMaker;

    private List<HookPositionRotation> _curHooks = null;

    private HashSet<GameObject> _childMarkForRemove = new HashSet<GameObject>();

    public void MarkHookPositionRotationSave()
    {
        if (_curHooks != null)
        {
            foreach (var item in _curHooks)
            {
                item.MarkSaveOnStop();    
            }    
        }
    }

    public void OnNotify(Playable origin, INotification notification, object context)
    {
        if (onMaker != null)
        {
        }
    }

#if UNITY_EDITOR
    
    // 判断一个轨道是否是公共前置轨道
    
    public static bool IsCommonPrefixPath(TrackAsset baseTrack, out TrackExtData extData)
    {
        extData = null;
        var controlTrack = baseTrack as ControlTrack;
        var animTrack = baseTrack as AnimationTrack;
        if (controlTrack != null && controlTrack.extData != null)
        {
            var trackType = controlTrack.extData.trackType;
            extData = controlTrack.extData;
            return trackType == TrackExtType.HookEffect || trackType == TrackExtType.IsolateEffect || trackType == TrackExtType.ChildHookEffect;
        }
        else if (animTrack != null && animTrack.extData != null)
        {
            var trackType = animTrack.extData.trackType;
            extData = animTrack.extData;
            return trackType == TrackExtType.IsolateEffectAnim;
        }
        return false;
    }

    // 获取公共前缀
    
    public static string GetCommonPrefixPath()
    {
        return "Assets/Build/Art/Fx/Prefab/";
    }
        
    // 替换成全路径
    
    public static string ConvertToFullPath(string relativePath)
    {
        if (string.IsNullOrEmpty(relativePath) || relativePath.Contains(GetCommonPrefixPath()))
        {
            return relativePath;
        }

        var path = GetCommonPrefixPath() + relativePath;
        path = path.Replace('\\', '/');
        return path;
    }
        
    // 把全路径转成相对路径
    public static string ConvertRelativePath(string fullPath)
    {
        if (string.IsNullOrEmpty(fullPath))
        {
            return fullPath;
        }

        var path = fullPath.Replace(GetCommonPrefixPath(), "");
        path = path.Replace('\\', '/');
        return path;
    }

    //镜头后处理， 获取相应父节点
    private void GetCameraTran(Transform parent, ref Transform targetTran)
    {
        if (targetTran != null)
        {
            return;
        }

        if (parent.GetComponent<Camera>() != null)
        {
            targetTran = parent;
            return;
        }

        for (int i = 0; i < parent.childCount; i++)
        {
            GetCameraTran(parent.GetChild(i), ref targetTran);
        }
    }
    
    void OnDrawGizmosSelected()
    {
        if (showCircle)
        {
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.position, radius);
        }
    }

    //删除所有生成的Gameobject
    
    public void DeleteInstantiateObj(bool deleteTimelineObj = true)
    {
        if (Application.isPlaying)
        {
            foreach (var VARIABLE in prefabPathDic)
            {
                GameObject.Destroy(VARIABLE.Key);
            }

            GameObject.Destroy(gameObject);
        }
        else
        {
            // TODO 有空优化一下VARIABLE
            foreach (var VARIABLE in prefabPathDic)
            {
                var obj = VARIABLE.Key;
                if (_IsActorOrMonster(obj))
                {
                    _DestroyActorOrMonster(obj);
                }
                else
                {
                    DestroyImmediate(VARIABLE.Key, true);
                }
            }
#if UNITY_EDITOR
            foreach (var VARIABLE in suitObjDict)
            {
                _DestroyActorOrMonster(VARIABLE.Value);
            }
#endif
            if (deleteTimelineObj)
            {
                GameObject.DestroyImmediate(gameObject, true);  
            }
        }
        prefabPathDic.Clear();
        suitObjDict.Clear();
        effectPrefabDict.Clear();
    }
    
    public void SetInstantiateObjActive(bool active)
    {
        if (Application.isPlaying)
        {
            foreach (var VARIABLE in prefabPathDic)
            {
                VARIABLE.Key.SetActive(active);
            }

            gameObject.SetActive(active);
        }
        else
        {
            // TODO 有空优化一下VARIABLE
            foreach (var VARIABLE in prefabPathDic)
            {
                var obj = VARIABLE.Key;
                if (_IsActorOrMonster(obj))
                {
                    _SetActorOrMonsterActive(obj, active);
                }
                else
                {
                    VARIABLE.Key.SetActive(active);
                }
            }
#if UNITY_EDITOR
            foreach (var VARIABLE in suitObjDict)
            {
                _SetActorOrMonsterActive(VARIABLE.Value, active);
            }
#endif
        }
    }
    
    private void _SetActorOrMonsterActive(GameObject obj, bool active)
    {
        if (obj == null)
        {
            return;
        }
        var parentTrans = obj.transform.parent;
        if (parentTrans == null)
        {
            obj.SetActive(active);
        }
        else
        {
            parentTrans.gameObject.SetActive(active);
        }
    }

    // 200014(Girl)
    //      Model 
    // 创建了Model和Root，删除的时候也要都删掉
    private void _DestroyActorOrMonster(GameObject obj)
    {
        if (obj == null)
        {
            return;
        }
        var parentTrans = obj.transform.parent;
        if (parentTrans == null)
        {
            DestroyImmediate(obj);
        }
        else
        {
            DestroyImmediate(parentTrans.gameObject);   
        }
    }
    
    private string GetTrimName(string name)
    {
        var match = Regex.Match(name, @"\([0-9]\)");
        if (match.Success)
        {
            return name.Substring(0, match.Index).TrimEnd().Replace("(Clone)", "");
        }

        return name.TrimEnd().Replace("(Clone)", "");
    }

    private List<GameObject> _initDataAssistReturnList = new List<GameObject>();
    public List<GameObject> initDataAssistReturnList => _initDataAssistReturnList;


    public List<GameObject> InitDataNew(Func<TrackAsset, bool> filter = null)
    {
        ControlPlayableAsset.SetMountPlayableCreator(_MountPlayableCreator);
        _initDataAssistReturnList.Clear();
        gameObject.name = GetTrimName(gameObject.name);
        curDirector = gameObject.GetComponent<PlayableDirector>();
        if (curDirector == null)
        {
            return _initDataAssistReturnList;
        }

        var playable = curDirector.playableAsset;
        if (playable == null)
        {
            return _initDataAssistReturnList;
        }

        var timelineAsset = (TimelineAsset)(playable);

        // 先处理武器和suit轨道
        var allTracks = timelineAsset.GetOutputTracks();
        for (int i = 0; i < allTracks.Length; i++)
        {
            var track = allTracks[i];
            if (filter != null && !filter(track))
            {
                continue;
            }
            var wTrack = track as ChangeWeaponTrack;
            if (wTrack != null)
            {
                InitGenerateTrack(curDirector, wTrack, wTrack.extData);
                _PreloadWeapon(curDirector, wTrack);
                continue;
            }
            
            var suitTrack = track as ChangeSuitTrack;
            if (suitTrack != null)
            {
                InitGenerateTrack(curDirector, suitTrack, suitTrack.extData);
                _PreloadSuit(curDirector, suitTrack);
                continue;
            }
        }
        
        // 再处理其余轨道
        ControlTrack lastControlTrack = null;
        for (int i = 0; i < allTracks.Length; i++)
        {
            var track = allTracks[i];
            if (filter != null && !filter(track))
            {
                continue;
            }
            AnimationTrack animTrack = track as AnimationTrack;
            if (animTrack != null)
            {
                InitAnimTrack(curDirector, track, animTrack.extData, lastControlTrack);
                continue;
            }

            ControlTrack contTrack = track as ControlTrack;
            if (contTrack != null)
            {
                InitCtrlTrack(curDirector, track, contTrack.extData);
                lastControlTrack = contTrack;
                continue;
            }

            ActivationTrack activeTrack = track as ActivationTrack;
            if (activeTrack != null)
            {
                InitActiveTrack(curDirector, track, activeTrack.extData);
                continue;
            }

            PhysicsWindTrack windTrack = track as PhysicsWindTrack;
            if (windTrack != null)
            {
                InitPhysicsWindTrack(curDirector, track, windTrack.extData);
                continue;
            }

            VisibilityTrack vTrack = track as VisibilityTrack;
            if (vTrack != null)
            {
                InitGenerateTrack(curDirector, vTrack, vTrack.extData);
                continue;
            }

            var ciTrack = track as CameraImpulseTrack;
            if (ciTrack != null)
            {
                InitGenerateTrack(curDirector, ciTrack, ciTrack.extData);
                continue;
            }

            var operationTrack = track as TransformOperationTrack;
            if (operationTrack != null)
            {
                InitGenerateTrack(curDirector, operationTrack, operationTrack.extData);
                continue;
            }

            var aoTrack = track as ActorOperationTrack;
            if (aoTrack != null)
            {
                InitGenerateTrack(curDirector, aoTrack, aoTrack.extData);
                continue;
            }

            var cTrack = track as CurveAnimTrack;
            if (cTrack != null)
            {
                InitGenerateTrack(curDirector, cTrack, cTrack.extData);
                var timelineCLips = cTrack.GetClipsArray();
                foreach (var timelineClip in timelineCLips)
                {
                    CurveAnimPlayableAsset curveAnimPlayableAsset = timelineClip.asset as CurveAnimPlayableAsset;
                }
                continue;
            }
            
            PapeGames.CameraMixingTrack cameraTrack = track as CameraMixingTrack;
            if (cameraTrack != null)
            {
                if (cameraTrack.bindBrain && Camera.main != null)
                {
                    var brain = Camera.main.GetComponent<CinemachineBrain>();
                    curDirector.SetGenericBinding(cameraTrack, brain);
                }
                continue;
            }

            SubSystemControlTrack sTrack = track as SubSystemControlTrack;
            if (sTrack != null)
            {
                InitGenerateTrack(curDirector, sTrack, sTrack.extData);
                continue;
            }

            LODTrack lodTrack = track as LODTrack;
            if (lodTrack != null)
            {
                InitGenerateTrack(curDirector, track, lodTrack.extData);
                continue;
            }
            
            AvatarTrack avatarTrack = track as AvatarTrack;
            if (avatarTrack != null)
            {
                InitGenerateTrack(curDirector, track, avatarTrack.extData);
                continue;
            }

            SimpleAudioTrack audioTrack = track as SimpleAudioTrack;
            if (audioTrack != null)
            {
                InitGenerateTrack(curDirector, track, audioTrack.extData);
                continue;
            }
        }

        return _initDataAssistReturnList;
    }

    // 首次Alt+Q打开时预加载一下武器
    private List<string> _outWeaponPartNames = new List<string>();
    private HashSet<string> _curWeaponPartNames = new HashSet<string>();
    private void _PreloadWeapon(PlayableDirector director, ChangeWeaponTrack track)
    {
        if (director == null || track == null)
        {
            return;
        }
        var bindObj = director.GetGenericBinding(track) as GameObject;
        if (bindObj == null)
        {
            return;
        }

        _outWeaponPartNames.Clear();
        _curWeaponPartNames.Clear();
        CharacterMgr.GetPartNamesWithPartType(bindObj, (int)PartType.Weapon, _outWeaponPartNames);
        foreach (var partName in _outWeaponPartNames)
        {
            _curWeaponPartNames.Add(partName);
        }
        
        var clipsArray = track.GetClipsArray();
        foreach (var clip in clipsArray)
        {
            if (clip.asset is ChangeWeaponClip weaponClip)
            {
                var targetPartName = weaponClip.weaponPartName;
                if (!_curWeaponPartNames.Contains(targetPartName))
                {
                    BattleCharacterMgr.AddPart(bindObj, targetPartName, false, autoSyncLod: false);
                    BattleCharacterMgr.HidePart(bindObj, targetPartName, true);
                }
            } 
        }
    }
    
    
    // 预加载套装切换轨道
    private void _PreloadSuit(PlayableDirector director, ChangeSuitTrack track)
    {
        if (director == null || track == null)
        {
            return;
        }
        
        var bindObj = director.GetGenericBinding(track) as GameObject;
        if (bindObj == null)
        {
            return;
        }

        ChangeSuitUtil.PreloadChangeSuit(bindObj, track);
    }
    
    
    public GameObject GetHeroPrefab(string prefabName)
    {
        GameObject prefab = null;
        var ret = heroPrefabDic.TryGetValue(prefabName, out prefab);
        if (false == ret || prefab == null)
        {
            //Camera的K帧(还是子节点)
            if (prefabName.StartsWith("Camera"))
            {
                foreach (var VARIABLE in heroPrefabDic)
                {
                    bool get = false;
                    for (int i = 0; i < VARIABLE.Value.transform.childCount; i++)
                    {
                        var child = VARIABLE.Value.transform.GetChild(i);
                        if (child.name.Equals(prefabName))
                        {
                            get = true;
                            prefab = child.gameObject;
                            if (prefab.GetComponent<Animator>() == null)
                            {
                                prefab.AddComponent<Animator>();
                            }

                            break;
                        }
                    }

                    if (get)
                    {
                        return prefab;
                    }
                }
            }

            if (gameObject.name.Equals(prefabName))
            {
                return gameObject;
            }

            string path = GetEntityAvatarPath(prefabName);
            if (string.IsNullOrEmpty(path))
            {
                return null;
            }

            var _selectObject = (GameObject) AssetDatabase.LoadAssetAtPath(path, typeof(GameObject));
            prefab = PrefabUtility.InstantiatePrefab(_selectObject) as GameObject;
            prefab.SetActive(true);
            heroPrefabDic[prefabName] = prefab;
            prefabPathDic[prefab] = path;
        }

        if (prefab.GetComponent<Animator>() == null)
        {
            prefab.AddComponent<Animator>();
        }

        return prefab;
    }
    
    
    public void PlayTimeline()
    {
        if (curDirector != null)
        {
            curDirector.Evaluate();
            curDirector.time = 0;
            curDirector.Play();
        }
    }
    
    
    public string GetEffectPath(string name)
    {
        string _prefabPath = Application.dataPath + effectPath;
        string path = GetUnifiedPath(name, _prefabPath, @"prefab");
        if (string.IsNullOrEmpty(path))
        {
            return "";
        }

        int index = path.IndexOf("/Assets/");
        return path.Substring(index + 1);
    }

    public Func<string, string, string, string> GetUnifiedPath;

    public string GetEntityAvatarPath(UnityEngine.Object obj)
    {
        string path = GetEntityAvatarPath(obj.name);
        if (string.IsNullOrEmpty(path))
        {
            path = PrefabUtility.GetPrefabAssetPathOfNearestInstanceRoot(obj);
        }

        return path;
    }

    
    public string GetEntityAvatarPath(string name)
    {
        string _resourcePath = Application.dataPath + RolePath;
        string path = GetUnifiedPath(name, _resourcePath, @"prefab");

        //还有可能是camera的prefab
        if (string.IsNullOrEmpty(path))
        {
            _resourcePath = Application.dataPath + "/Build/Res/SourceRes/CameraRes/Prefabs/";
            path = GetUnifiedPath(name, _resourcePath, @"prefab");
        }

        //有可能是Build下的特效(模型内带特效的那种)
        if (string.IsNullOrEmpty(path))
        {
            _resourcePath = Application.dataPath + effectPath.Replace("Battle/", "");
            path = GetUnifiedPath(name, _resourcePath, @"prefab");
        }

        if (string.IsNullOrEmpty(path))
        {
            _resourcePath = Application.dataPath + "/Build/Res/Battle/Actors/";
            path = GetUnifiedPath(name, _resourcePath, @"prefab");
        }

        int index = path.IndexOf("/Assets/");
        return path.Substring(index + 1);
    }

    
    public void ResetTrackData(TrackAsset trackAsset)
    {
        AnimationTrack animTrack = trackAsset as AnimationTrack;
        if (animTrack != null)
        {
            TrackExtData oldData = animTrack.extData;
            animTrack.extData = new TrackExtData();
            animTrack.extData.bindSuitID = oldData.bindSuitID;
            animTrack.extData.bindGirlSuit = oldData.bindGirlSuit;
            animTrack.extData.bindWeaponID = oldData.bindWeaponID;
            animTrack.extData.isStopByTime = oldData.isStopByTime;
            animTrack.extData.isStopByLogic = oldData.isStopByLogic;
            animTrack.extData.editorChangeSuit = oldData.editorChangeSuit;
            animTrack.extData.editorChangeWeapon = oldData.editorChangeWeapon;
            return;
        }

        ActivationTrack activeTrack = trackAsset as ActivationTrack;
        if (activeTrack != null)
        {
            activeTrack.extData = new TrackExtData();
            return;
        }

        PhysicsWindTrack windTrack = trackAsset as PhysicsWindTrack;
        if (windTrack != null)
        {
            windTrack.extData = new TrackExtData();
            return;
        }
        
        VisibilityTrack vTrack = trackAsset as VisibilityTrack;
        if (vTrack != null)
        {
            vTrack.extData = new TrackExtData();
            return;
        }

        var aoTrack = trackAsset as ActorOperationTrack;
        if (aoTrack != null)
        {
            aoTrack.extData = new TrackExtData();
            return;
        }

        var wTrack = trackAsset as ChangeWeaponTrack;
        if (wTrack != null)
        {
            wTrack.extData = new TrackExtData();
            return;
        }

        var suitTrack = trackAsset as ChangeSuitTrack;
        if (suitTrack != null)
        {
            suitTrack.extData = new TrackExtData();
            return;
        }

        var ciTrack = trackAsset as CameraImpulseTrack;
        if (ciTrack != null)
        {
            ciTrack.extData = new TrackExtData();
            return;
        }

        var operationTrack = trackAsset as TransformOperationTrack;
        if (operationTrack != null)
        {
            operationTrack.extData = new TrackExtData();
            return;
        }

        CurveAnimTrack cTrack = trackAsset as CurveAnimTrack;
        if (cTrack != null)
        {
            cTrack.extData = new TrackExtData();
            return;
        }
        
        SubSystemControlTrack sTrack = trackAsset as SubSystemControlTrack;
        if (sTrack != null)
        {
            sTrack.extData = new TrackExtData();
            return;
        }

        LODTrack lodTrack = trackAsset as LODTrack;
        if (lodTrack != null)
        {
            lodTrack.extData = new TrackExtData();
            return;
        }
        
        AvatarTrack avatarTrack = trackAsset as AvatarTrack;
        if (avatarTrack != null)
        {
            avatarTrack.extData = new TrackExtData();
            return;
        }
        
        SimpleAudioTrack audioTrack = trackAsset as SimpleAudioTrack;
        if (audioTrack != null)
        {
            audioTrack.extData = new TrackExtData();
            return;
        }

        ControlTrack controlTrack = trackAsset as ControlTrack;
        if (controlTrack != null)
        {
            TrackExtData oldData = controlTrack.extData;
            controlTrack.extData = new TrackExtData();
            controlTrack.extData.bindSuitID = oldData.bindSuitID;
            controlTrack.extData.bindGirlSuit = oldData.bindGirlSuit;
            controlTrack.extData.isFollowActor = oldData.isFollowActor;
            controlTrack.extData.isStopByTime = oldData.isStopByTime;
            controlTrack.extData.isStopByLogic = oldData.isStopByLogic;
            controlTrack.extData.isFollowReferencePos = oldData.isFollowReferencePos;
            controlTrack.extData.isFollowRotate = oldData.isFollowRotate;
            controlTrack.extData.detachTime = oldData.detachTime;
            controlTrack.extData.editorSaveEffectObj = oldData.editorSaveEffectObj;
            controlTrack.extData.editorChangeSuit = oldData.editorChangeSuit;
        }
    }

    private bool _IsFXGroupChild(TrackAsset track)
    {
        if (track == null)
        {
            return false;
        }
        
        if (track.parent != null)
        {
            if (track.parent.name.ToLower() == "fx group")
            {
                return true;
            }
            else
            {
                return _IsFXGroupChild(track.parent as TrackAsset);
            }
        }

        return false;
    }
    
    public void SaveEffectNew(bool onlyControlTrack = false, bool skipControl = true)
    {
        if (gameObject == null)
        {
            return;
        }

        var director = gameObject.GetComponent<PlayableDirector>();
        if (director == null)
        {
            return;
        }

        var playable = director.playableAsset;
        if (playable == null)
        {
            return;
        }

        var timelineAsset = (TimelineAsset) (playable);

        //将timelne重置到开始的位置，为了获取准备的相对坐标。 timeline播完Animation，position等会停留在最后的位置上
        director.time = 0;
        director.Stop();
        director.playOnAwake = false;
        // director.Evaluate();

        var allTracks = timelineAsset.GetOutputTracks();

        var shadowParent = transform.Find("shadow");
        if (shadowParent != null)
        {
            var targetTran = shadowParent.GetChild(0);

            for (int i = 0; i < targetTran.childCount; i++)
            {
                var child = targetTran.GetChild(i);
                var skinMeshRender = child.GetComponent<MeshRenderer>();
                if (skinMeshRender != null && skinMeshRender.sharedMaterial != null &&
                    skinMeshRender.sharedMaterial.name.Equals(@"shadow_runtime (Instance)"))
                {
                    skinMeshRender.sharedMaterial =
                        AssetDatabase.LoadAssetAtPath<Material>("Assets/Build/Art/Fx/Material/shadow_runtime.mat");
                }
            }
        }

        HashSet<Transform> usedChildStack = new HashSet<Transform>();

        ControlTrack lastControlTrack = null;
        // 生成Control轨道的绑定数据
        for (int i = 0; i < allTracks.Length; i++)
        {
            var track = allTracks[i];
            if (track.muted)
            {
                if (track is ControlTrack mutedControlTrack)
                {
                    lastControlTrack = mutedControlTrack;
                }
                continue;
            }

            if (skipControl && _IsFXGroupChild(track))
            {
                continue;    
            }

            // 生成controlTrack绑定信息
            ControlTrack contTrack = track as ControlTrack;
            if (contTrack != null)
            {
                var oldData = contTrack.extData; 
                ResetTrackData(contTrack);
                var result = ProcessCtrlTrack(director, track, contTrack.extData, ref usedChildStack);
                if (!result)
                {
                    // 绑定失败，还用之前的数据
                    contTrack.extData = oldData;
                }
                lastControlTrack = contTrack;
                // 后处理一下路径，去掉公共前缀
                TrackExtData extData = null;
                if (IsCommonPrefixPath(track, out extData))
                {
                    extData.bindPath = ConvertRelativePath(extData.bindPath);
                }
                continue;
            }

            // 只保存control情况下别的轨道不处理
            if (onlyControlTrack)
            {
                continue;   
            }

            // 生成animationTrack绑定信息
            AnimationTrack animTrack = track as AnimationTrack;
            if (animTrack != null) //K帧的track也需要保存主体
            {
                ResetTrackData(animTrack);
                ProcessAnimTrack(director, track, animTrack.extData, ref usedChildStack, lastControlTrack);
                // 后处理一下路径，去掉公共前缀
                TrackExtData extData = null;
                if (IsCommonPrefixPath(track, out extData))
                {
                    extData.bindPath = ConvertRelativePath(extData.bindPath);
                }
                continue;
            }

            // 生成ActivationTrack信息
            ActivationTrack activeTrack = track as ActivationTrack;
            if (activeTrack != null)
            {
                ResetTrackData(activeTrack);
                activeTrack.extData = ProcessActivationTrack(director, track, activeTrack.extData);
                continue;
            }

            // 生成PhysicsTrack信息
            PhysicsWindTrack windTrack = track as PhysicsWindTrack;
            if (windTrack != null)
            {
                ResetTrackData(windTrack);
                windTrack.extData = ProcessPhysicsWindTrack(director, track, windTrack.extData);
                continue;
            }
            
            // 生成Visibility信息
            VisibilityTrack vTrack = track as VisibilityTrack;
            if (vTrack != null)
            {
                ResetTrackData(vTrack);
                vTrack.extData = ProcessGenerateTrack(director, track, vTrack.extData);
                continue;
            }

            // 生成ActorOperationTrack信息
            var aoTrack = track as ActorOperationTrack;
            if (aoTrack != null)
            {
                ResetTrackData(aoTrack);
                aoTrack.extData = ProcessGenerateTrack(director, track, aoTrack.extData);
                continue;
            }

            // 生成ChangeWeaponTrack信息
            var wTrack = track as ChangeWeaponTrack;
            if (wTrack != null)
            {
                ResetTrackData(wTrack);
                wTrack.extData = ProcessGenerateTrack(director, track, wTrack.extData);
                continue;
            }

            // 生成ChangeSuitTrack信息
            var suitTrack = track as ChangeSuitTrack;
            if (suitTrack != null)
            {
                ResetTrackData(suitTrack);
                suitTrack.extData = ProcessGenerateTrack(director, track, suitTrack.extData);
                continue;
            }

            // 生成CameraImpulseTrack信息
            var ciTrack = track as CameraImpulseTrack;
            if (ciTrack != null)
            {
                ResetTrackData(ciTrack);
                ciTrack.extData = ProcessGenerateTrack(director, track, ciTrack.extData);
                continue;
            }

            // 生成TransformOperationTrack信息
            var operationTrack = track as TransformOperationTrack;
            if (operationTrack != null)
            {
                ResetTrackData(operationTrack);
                operationTrack.extData = ProcessGenerateTrack(director, track, operationTrack.extData);
                continue;
            }

            // 生成CurveAnimTrack信息
            CurveAnimTrack cTrack = track as CurveAnimTrack;
            if (cTrack != null)
            {
                ResetTrackData(cTrack);
                cTrack.extData = ProcessGenerateTrack(director, track, cTrack.extData);
                continue;
            }
            
            // 生成SubSystemControlTrack信息
            SubSystemControlTrack sTrack = track as SubSystemControlTrack;
            if (sTrack != null)
            {
                ResetTrackData(sTrack);
                sTrack.extData = ProcessGenerateTrack(director, track, sTrack.extData);
                continue;
            }

            LODTrack lodTrack = track as LODTrack;
            if (lodTrack != null)
            {
                ResetTrackData(lodTrack);
                lodTrack.extData = ProcessGenerateTrack(director, track, lodTrack.extData);
                continue;
            }
            
            AvatarTrack avatarTrack = track as AvatarTrack;
            if (avatarTrack != null)
            {
                ResetTrackData(avatarTrack);
                avatarTrack.extData = ProcessGenerateTrack(director, track, avatarTrack.extData);
                continue;
            }

            SimpleAudioTrack audioTrack = track as SimpleAudioTrack;
            if (audioTrack != null)
            {
                ResetTrackData(audioTrack);
                audioTrack.extData = ProcessGenerateTrack(director, track, audioTrack.extData);
                continue;
            }

            CameraMixingTrack cameraTrack = track as CameraMixingTrack;
            if (cameraTrack != null)
            {
                if(curDirector.GetGenericBinding(cameraTrack) != null)
                    cameraTrack.bindBrain = true;
                continue;
            }
        }

        if (onlyControlTrack)
        {
            // 只处理control轨道，保存一下资源直接返回
            EditorUtility.SetDirty(timelineAsset);
            AssetDatabase.SaveAssets();   
            return;
        }

        //没使用到的节点需要隐藏
        if (!skipControl)
        {
            for (int i = 0; i < transform.childCount; i++)
            {
                var child = transform.GetChild(i);
                var allChilds = getAllChild(child);
                bool get = false;
                foreach (var VARIABLE in allChilds)
                {
                    if (usedChildStack.Contains(VARIABLE) || VARIABLE.name.Equals("shadow"))
                    {
                        get = true;
                        break;
                    }
                }

                if (get)
                {
                    continue;
                }

                child.gameObject.SetVisible(false);
            }   
        }
        
        VisiblePoolTool.RecordPoolItem(gameObject);
        if (director != null)
        {
            director.playOnAwake = false;
        }

        ClearDirectorRedundancyBinding(director);
        EditorUtility.SetDirty(timelineAsset);

        // 加载出来的effect也保存到prefab中，每个特效保存时触发AssetDatabase.SaveAssets转圈0.5秒，太卡，取消此逻辑
        var isSaveEffectPrefab = EditorPrefs.GetBool(_saveEffectPrefabsKey, false);
        if (isSaveEffectPrefab)
        {
            foreach (var iter in effectPrefabDict)
            {
                if (iter.Key != null)
                {
                    PrefabUtility.ApplyPrefabInstance(iter.Key, InteractionMode.AutomatedAction);
                }
            }
        }

        // hooK子节点处理
        foreach (var iter in _childMarkForRemove)
        {
            prefabPathDic.Remove(iter);
            effectPrefabDict.Remove(iter);
            GameObject.DestroyImmediate(iter);
        }
        _childMarkForRemove.Clear();
        PrefabUtility.SaveAsPrefabAsset(gameObject, timelinePrefabPath);
        AssetDatabase.SaveAssets();

        InitDataNew((track) =>
        {
            if (track is AnimationTrack animTrack)
            {
                return animTrack.extData.trackType == TrackExtType.ChildHookEffectAnim;
            } 
            else if (track is ControlTrack ctrlTrack)
            {
                return ctrlTrack.extData.trackType == TrackExtType.ChildHookEffect;
            }
            return false;
        });
    }
    
    // 勾选项
    private const string _saveEffectPrefabsKey = "Battle/Timeline/同步保存特效prefab";
    [MenuItem(_saveEffectPrefabsKey, true)]
     public static bool CheckSaveEffectPrefabs()
    {
        var isSave = EditorPrefs.GetBool(_saveEffectPrefabsKey, false);
        Menu.SetChecked(_saveEffectPrefabsKey, isSave);
        return true;
    }
    
    [MenuItem(_saveEffectPrefabsKey)]
    public static void SetSaveEffectPrefabs()
    {
        var isSave = EditorPrefs.GetBool(_saveEffectPrefabsKey, false);
        EditorPrefs.SetBool(_saveEffectPrefabsKey, !isSave);
    }

    private static HashSet<Object> _tempTracks = new HashSet<Object>();
    // 清除PlayableDirector上冗余的绑定
    // 返回值，是否有修改
    public static bool ClearDirectorRedundancyBinding(PlayableDirector director)
    {
        if (director == null)
        {
            return false;
        }

        _tempTracks.Clear();
        var timelineAsset = director.playableAsset as TimelineAsset;
        if (timelineAsset != null)
        {
            foreach (var track in timelineAsset.GetOutputTracks())
            {
                _tempTracks.Add(track);
            }
        }

        var isChange = false;
        var dirSo = new SerializedObject(director);
        var sceneBindings = dirSo.FindProperty("m_SceneBindings");
        for (var i = sceneBindings.arraySize - 1; i >= 0; i--)
        {
            var binding = sceneBindings.GetArrayElementAtIndex(i);
            var key = binding.FindPropertyRelative("key");
            if (key.objectReferenceValue == null || !_tempTracks.Contains(key.objectReferenceValue))
            {
                sceneBindings.DeleteArrayElementAtIndex(i);
                isChange = true;
            }
        }

        if (isChange)
        {
            dirSo.ApplyModifiedProperties();
        }
        
        return isChange;
    }

    [NonSerialized]
    public string timelinePrefabPath = null;
    
    // 保存range数据
    public Func<Vector2> TryGetTimelineRangeTime;

    // 加载range资源
    public Action<Vector2> TrySetRangeTime;

    private Stack<Transform> getAllChild(Transform parent)
    {
        Stack<Transform> allStack = new Stack<Transform>();
        allStack.Push(parent);
        for (int i = 0; i < parent.childCount; i++)
        {
            RecursiveGetChild(parent.GetChild(i), ref allStack);
        }

        return allStack;
    }

    
    private void RecursiveGetChild(Transform parent, ref Stack<Transform> allStack)
    {
        allStack.Push(parent);
        for (int i = 0; i < parent.childCount; i++)
        {
            RecursiveGetChild(parent.GetChild(i), ref allStack);
        }
    }

    // 是否为动态加载Hook类型的特效(条件一：是Timeline子节点，条件二：有FxPlayer 条件三：是独立prefab)
    public Func<GameObject, bool> IsFxObjFunc;
    private bool IsChildHookEffect(Transform topParent, Transform effect)
    {
        if (topParent == this.transform && effect != null)
        {
            // var fxPlayer = effect.GetComponent<FxPlayer>();
            var isFxObj = IsFxObjFunc != null && IsFxObjFunc(effect.gameObject);
            if (isFxObj)
            {
                var isPartOfPrefab = PrefabUtility.IsPartOfPrefabInstance(effect);
                if (isPartOfPrefab && PrefabUtility.GetNearestPrefabInstanceRoot(effect) == effect.gameObject)
                {
                    // 如果特效是prefab子节点，并且特效prefab是自己则认为是ChildHookEffect
                    return true;
                }
            }
        }
        return false;
    }
    
    private bool ProcessCtrlTrack(PlayableDirector director, TrackAsset track,
        TrackExtData curData, ref HashSet<Transform> usedChildStack)
    {
        var isSuccess = false;
        GameObject bindObj = null;
        foreach (var clip in track.GetClips())
        {
            ControlPlayableAsset mouthClip = clip.asset as ControlPlayableAsset;
            if (mouthClip != null)
            {
                bool isValid = true;
                Object oldExposedValue = director.GetReferenceValue(mouthClip.sourceGameObject.exposedName, out isValid);
                if (isValid == false)
                {
                    continue;
                }

                GameObject effectObj = (GameObject) oldExposedValue;
                if (effectObj == null)
                {
                    continue;
                }

                if (bindObj == null)
                {
                    bindObj = effectObj;
                }
                else
                {
                    //重复的Track就不用重复处理了
                    if (bindObj != effectObj)
                    {
                        EditorUtility.DisplayDialog(@"Error", "一个Track上只能绑定相同的主体,建议拆成2个Track", @"返回");
                    }

                    continue;
                }

                usedChildStack.Add(bindObj.transform);

                var parentTran = GetTopParentObj(bindObj.transform);
                if (parentTran == transform) //指向自己的子节点
                {
                    if (IsChildHookEffect(parentTran, bindObj.transform))
                    {
                        curData.trackType = TrackExtType.ChildHookEffect;
                        BindTrackPathAndParentPath(curData, bindObj, parentTran);
                        curData.localPosition = bindObj.transform.localPosition;
                        curData.localRotation = bindObj.transform.localEulerAngles;
                        curData.localScale = bindObj.transform.localScale;
                        _childMarkForRemove.Add(bindObj);
                        isSuccess = true;
                    }
                    else
                    {
                        curData.trackType = TrackExtType.ChildEffect;
                        isSuccess = true;  
                    }
                } //camera下挂载的特效
                else if (bindObj.transform.parent != null &&
                         bindObj.transform.parent.GetComponent<Camera>() != null)
                {
                    curData.trackType = TrackExtType.CameraHookEffect;
                    BindTrackPathAndParentPath(curData, bindObj, parentTran);
                    curData.localPosition = bindObj.transform.localPosition;
                    curData.localRotation = bindObj.transform.localEulerAngles;
                    curData.localScale = bindObj.transform.localScale;
                    isSuccess = true;
                }
                else if (bindObj.transform.parent == null)
                {
                    curData.trackType = TrackExtType.IsolateEffect;
                    BindTrackPathAndParentPath(curData, bindObj, null);
                    curData.localPosition = bindObj.transform.position;
                    curData.localRotation = bindObj.transform.eulerAngles;
                    curData.localScale = bindObj.transform.localScale;
                    isSuccess = true;
                }
                else
                {
                    //指向人物的挂接点(新框架下改成人物的其他标识)
                    curData.trackType = TrackExtType.HookEffect;
                    curData.bindName = bindObj.name;
                    BindTrackPathAndParentPath(curData, bindObj, parentTran);
                    curData.localPosition = bindObj.transform.localPosition;
                    curData.localRotation = bindObj.transform.localEulerAngles;
                    curData.localScale = bindObj.transform.localScale;
                    isSuccess = true;
                }
            }
        }
        return isSuccess;
    }

    
    private void BindTrackPathAndParentPath(TrackExtData curData, GameObject bindObj, Transform parentTran)
    {
        string recorderChildKey = resRecorder.TryGetResKey(bindObj);
        if (recorderChildKey != null)
        {
            curData.bindRecorderKey = recorderChildKey;
        }
        else
        {  
            bool isSuit = bindObj.CompareTag("player");
            if (!isSuit)
            {
                curData.bindSuitID = 0;
                curData.bindName = bindObj.name;
                curData.bindPath = GetPrefabPath(bindObj);
            }
            else
            {
                var suitName = bindObj.name;
                if (bindObj.transform.parent != null)
                {
                    suitName = bindObj.transform.parent.name;
                }
                
                curData.bindName = suitName;
                string strSuitId = StripConstName(suitName);
                
                if (TryConvertSuitID(strSuitId, out int iSuitId))
                {
                    curData.bindSuitID = iSuitId;
                    curData.bindGirlSuit = BattleUtil.IsGirlSuit(iSuitId);
                }
            }
        }

        if (parentTran != null)
        {
            curData.TopParentName = parentTran.name;
            curData.HookName = GetRelativePath(parentTran, bindObj.transform.parent);
            string recorderKey = resRecorder.TryGetResKey(parentTran.gameObject);
            if (recorderKey != null)
            {
                curData.topParentRecorderKey = recorderKey;
            }
            else
            {
                bool isSuit = parentTran.CompareTag("player");
                if (isSuit)
                {
                    // curData.bindSuitName = parentTran.name;
                    var suitName = parentTran.name;
                    if (parentTran.parent != null)
                    {
                        suitName = parentTran.parent.name;
                    }
                    string strSuitId = StripConstName(suitName);
                    if (TryConvertSuitID(strSuitId, out int iSuitId))
                    {
                        curData.bindSuitID = iSuitId;
                        curData.bindGirlSuit = BattleUtil.IsGirlSuit(iSuitId);
                    }
                }
                else
                {
                    if (curData.trackType != TrackExtType.ChildHookEffect && curData.trackType != TrackExtType.ChildHookEffectAnim)
                    {
                        curData.TopParentPath = GetPrefabPath(parentTran.gameObject);
                    }
                }
            }
        }
    }
    private string GetRelativePath(Transform parent, Transform child)
    {
        if (parent == child)
        {
            return "";
        }
        
        StringBuilder sb = new StringBuilder();
        sb.Insert(0, child.name);

        while (child.parent != null &&
               parent != child.parent)
        {
            child = child.parent;
            sb.Insert(0, child.name + "/");
        }

        return sb.ToString();
    }

    // target是否为parent的子节点
    private bool _IsCurOrChildObj(Transform parent, Transform target)
    {
        if (parent == null || target == null)
        {
            return false;
        }

        Transform curTrans = target;
        while (curTrans != null)
        {
            if (curTrans == parent)
            {
                return true;
            }
            curTrans = curTrans.parent;
        }
        return false;
    }
    
    private void ProcessShadowTrack(PlayableDirector director, TrackAsset track,
        ref TrackExtData curData, ref HashSet<Transform> usedChildStack)
    {
        var prefab = director.GetGenericBinding(track);
        if (prefab == null)
        {
            return;
        }

        GameObject bindObj = null;
        if (prefab is GameObject)
        {
            bindObj = prefab as GameObject;
        }
        else if (prefab is Animator)
        {
            bindObj = (prefab as Animator).gameObject;
        }

        if (bindObj == null)
        {
            EditorUtility.DisplayDialog(@"Error",
                transform.name + "主体获取失败，请联系程序", @"返回");
            return;
        }

        if (bindObj == gameObject)
        {
            EditorUtility.DisplayDialog(@"Warning",
                transform.name + "Control Track的引用不能指向timeline的特效本身", @"返回");
            return;
        }

        curData.trackType = TrackExtType.ShadowAnim;
        curData.bindName = bindObj.name;
        curData.localPosition = bindObj.transform.position;
        curData.localRotation = bindObj.transform.eulerAngles;
        curData.localScale = bindObj.transform.localScale;
    }

    
    private TrackExtData ProcessPhysicsWindTrack(PlayableDirector director, TrackAsset track,
        TrackExtData curData)
    {
        return ProcessGenerateTrack(director, track, curData);
    }

    
    private TrackExtData ProcessFxPlayerTrack(PlayableDirector director, TrackAsset track,
        TrackExtData curData)
    {
        var data = ProcessGenerateTrack(director, track, curData, true);
        if (data != null)
        {
            data.trackType = TrackExtType.IsolateEffect;
        }
        return data;
    }

    
    private TrackExtData ProcessActivationTrack(PlayableDirector director, TrackAsset track,
        TrackExtData curData)
    {
        return ProcessGenerateTrack(director, track, curData);
    }

    
    private TrackExtData ProcessGenerateTrack(PlayableDirector director, TrackAsset track,
        TrackExtData curData, bool isRelative = false)
    {
        var bindObj = director.GetGenericBinding(track) as GameObject;
        // 只支持怪物和角色（场景根节点下物体）  
        if (bindObj == null || !_IsActorOrMonster(bindObj))
        {
            return null;
        }

        BindTrackPathAndParentPath(curData, bindObj, null);
        bool isSuit = bindObj.CompareTag("player");
        if (!isSuit)
        {
            if (!string.IsNullOrEmpty(curData.bindPath) && isRelative)
            {
                curData.bindPath = ConvertRelativePath(curData.bindPath);
            }
        }
        // bool isSuit = bindObj.CompareTag("player");
        // if (isSuit)
        // {
        //     curData.bindName = bindObj.name;
        //     curData.bindSuitName = bindObj.name;
        // }
        // else
        // {
        //     curData.bindName = bindObj.name;
        //     var bindPath = GetPrefabPath(bindObj);
        //     if (!string.IsNullOrEmpty(bindPath) && isRelative)
        //     {
        //         bindPath = ConvertRelativePath(bindPath);
        //     }
        //     curData.bindPath = bindPath;
        //     if (string.IsNullOrEmpty(curData.bindPath))
        //     {
        //         curData = null;
        //     }
        // }
        return curData;
    }

    
    private void ProcessAnimTrack(PlayableDirector director, TrackAsset track,
        TrackExtData curData, ref HashSet<Transform> usedChildStack, ControlTrack lastControlTrack)
    {
        var obj = director.GetGenericBinding(track);
        if (obj == null)
        {
            return;
        }

        GameObject bindObj = null;
        if (obj is GameObject)
        {
            bindObj = obj as GameObject;
        }
        else if (obj is Animator)
        {
            bindObj = (obj as Animator).gameObject;
        }

        if (bindObj == null)
        {
            EditorUtility.DisplayDialog(@"Error",
                transform.name + "主体获取失败，请联系程序", @"返回");
            return;
        }

        if (bindObj == gameObject)
        {
            EditorUtility.DisplayDialog(@"Warning",
                transform.name + "Control Track的引用不能指向timeline的特效本身", @"返回");
            return;
        }

        usedChildStack.Add(bindObj.transform);
        AnimationTrack info = track as AnimationTrack;
        var parentTran = GetTopParentObj(bindObj.transform);
        if (parentTran == transform) //指向自己的子节点
        {
            if (IsChildHookEffect(parentTran, bindObj.transform))
            {
                var invaild = true;
                if (lastControlTrack != null)
                {
                    var lastExtData = lastControlTrack.extData;
                    if (lastExtData != null && lastExtData.trackType == TrackExtType.ChildHookEffect)
                    {
                        GameObject lastBindObj = TryGetControlSourceObj(director, lastControlTrack);
                        if (lastBindObj == bindObj)
                        {
                            invaild = false;
                            curData.trackType = TrackExtType.ChildHookEffectAnim;
                        }
                    }
                }

                if (invaild)
                {
                    
                    EditorUtility.DisplayDialog(@"Warning",$"轨道{track.name}使用Timeline特效子节点{bindObj.name}，不能直接用动画轨K，必须先用一个Control轨控制显隐，然后再K动画！", @"返回"); 
                }
            }
            else
            {
                curData.trackType = TrackExtType.ChildAnim;
            }
        }
        //指向人物(新框架下改成人物的其他标识)
        else if (_IsActorOrMonster(bindObj))
        {
            //AnimationClip指向的是动作，infiniteClip指向的是K帧
            if (info.infiniteClip != null)
            {
                curData.trackType = TrackExtType.Creature_K_Anim;
                BindTrackPathAndParentPath(curData, bindObj, null);
                curData.localScale = Vector3.one;
            }
            else
            {
                curData.trackType = TrackExtType.CreatureAnim;
                BindTrackPathAndParentPath(curData, bindObj, null);
                curData.localScale = Vector3.one;
            }
        }
        else if (_IsActorOrMonsterParent(bindObj))
        {
            var childActor = bindObj.transform.Find("Model");
            curData.trackType = TrackExtType.Creature_Parent_Anim;
            BindTrackPathAndParentPath(curData, childActor.gameObject, null);
            curData.localScale = Vector3.one;
        }
        //指向camera的prefab,MainCamera和传统的Camera Anim不一样，需要强行区分
        else if (bindObj.GetComponentInChildren<Camera>() != null)
        {
            if (bindObj.name.Contains("MainCamera") || bindObj.name.Contains("Main Camera"))
            {
                curData.trackType = TrackExtType.MainCameraAnim;
                curData.bindName = bindObj.name;
                curData.bindPath = "";
                curData.localPosition = bindObj.transform.position;
                curData.localRotation = bindObj.transform.eulerAngles;
                curData.localScale = bindObj.transform.localScale;
            }
            else
            {
                curData.trackType = TrackExtType.CameraAnim;
                BindTrackPathAndParentPath(curData, bindObj, null);
                curData.localPosition = bindObj.transform.position;
                curData.localRotation = bindObj.transform.eulerAngles;
                curData.localScale = bindObj.transform.localScale;
            }
        }
        //camera下挂载的特效
        else if (bindObj.transform.parent != null &&
                 bindObj.transform.parent.GetComponentInChildren<Camera>() != null)
        {
            curData.trackType = TrackExtType.CameraHookEffectAnim;
            curData.HookName = bindObj.transform.parent.name;
            BindTrackPathAndParentPath(curData, bindObj, null);
            curData.localPosition = bindObj.transform.localPosition;
            curData.localRotation = bindObj.transform.localEulerAngles;
            curData.localScale = bindObj.transform.localScale;
        }
        else if (bindObj.transform.parent == null)
        {
            curData.trackType = TrackExtType.IsolateEffectAnim;
            BindTrackPathAndParentPath(curData, bindObj, null);
            curData.localPosition = bindObj.transform.position;
            curData.localRotation = bindObj.transform.eulerAngles;
            curData.localScale = bindObj.transform.localScale;
        }
        else
        {
            var invaild = true;
            if (lastControlTrack != null)
            {
                var lastExtData = lastControlTrack.extData;
                if (lastExtData != null && lastExtData.trackType == TrackExtType.HookEffect)
                {
                    GameObject lastBindObj = TryGetControlSourceObj(director, lastControlTrack);
                    if (lastBindObj != null && _IsCurOrChildObj(lastBindObj.transform, bindObj.transform))
                    {
                        invaild = false;
                        curData.trackType = TrackExtType.HookEffectAnim;
                        var hookPath = GetRelativePath(lastBindObj.transform, bindObj.transform);
                        curData.HookName = hookPath;
                    }
                }
            }

            if (invaild)
            {
                EditorUtility.DisplayDialog(@"Warning",
                    transform.name + $"{track.name} 用了不支持的Animation类型，请呼叫程序", @"返回"); 
            }
        }
    }

    
    private GameObject TryGetControlSourceObj(PlayableDirector director, TrackAsset track)
    {
        GameObject bindObj = null;
        var clips = track.GetClips();
        foreach (var clip in clips)
        {
            var asset = clip.asset as ControlPlayableAsset;
            if (asset != null)
            {
                bindObj= asset.sourceGameObject.Resolve(director);
                if (bindObj != null)
                {
                    break;
                }
            }
        }
        return bindObj;
    }

    
    private void InitPhysicsWindTrack(PlayableDirector director, TrackAsset track, TrackExtData curData)
    {
        InitGenerateTrack(director, track, curData);
    }

    
    private void InitFxPlayerTrack(PlayableDirector director, TrackAsset track, TrackExtData curData)
    {
        InitGenerateTrack(director, track, curData,true);
    }

    
    private void InitActiveTrack(PlayableDirector director, TrackAsset track, TrackExtData curData)
    {
        InitGenerateTrack(director, track, curData);
    }

    
    private void InitGenerateTrack(PlayableDirector director, TrackAsset track, TrackExtData curData, bool isRelativer = false)
    {
        if (curData == null)
        {
            return;
        }
        var bindObj = GetResRecorderObj(curData.bindRecorderKey);
        if (bindObj == null)
        {
            bindObj = GetBindSuitObj(curData.bindSuitID.ToString(), curData.isBrokenShirt);
        }
        if (bindObj == null)
        {
            var bindPath = isRelativer ? ConvertToFullPath(curData.bindPath) : curData.bindPath;
            bindObj = _GetBindMonsterObj(curData.bindName, bindPath, null, false, track);
        }

        if (bindObj != null)
        {
            director.SetGenericBinding(track, bindObj);
        }
    }

    
    private void BindControlTrack(PlayableDirector director, TrackAsset track, GameObject bindObj)
    {
        var trackExtData = (track as ControlTrack)?.extData;
        foreach (var clip in track.GetClips())
        {
            ControlPlayableAsset ctrlClip = clip.asset as ControlPlayableAsset;
            if (ctrlClip == null)
            {
                continue;
            }

            bool isValid = false;
            Object oldExposedValue =
                director.GetReferenceValue(ctrlClip.sourceGameObject.exposedName, out isValid);
            if (isValid == false)
            {
                director.ClearReferenceValue(ctrlClip.sourceGameObject.exposedName);
//                continue;
            }
            director.SetReferenceValue(ctrlClip.sourceGameObject.exposedName, bindObj);
        }
    }

    // 挂载playable生成器
    // TODO 长空 此处待优化, obj传到内部可以简洁代码
    private MountPlayableBehaviourBase _MountPlayableCreator(ControlPlayableAsset clipAsset, GameObject obj, float clipInTime)
    {
        var trackExtData = clipAsset.trackExtData;
        if (trackExtData == null || obj == null)
        {
            return null;
        }
          
        var multiplePlayable = new MultipleMountPlayableBehaviour();
        if (trackExtData.trackType == TrackExtType.HookEffect)
        {
            var effectMountPlayable = new HookPositionRotation(trackExtData, obj, clipInTime);
            if (_curHooks == null)
            {
                _curHooks = new List<HookPositionRotation>();    
            }
            _curHooks.Add(effectMountPlayable);
            multiplePlayable.AddPlayableBehaviour(effectMountPlayable);
        }
        var fxPlayable = new FxPlayerPlayable();
        clipAsset.isControlByFxPlayer = fxPlayable.PreInit(obj, clipAsset.clipDuration, clipAsset.clipInTime);
        multiplePlayable.AddPlayableBehaviour(fxPlayable);
        return multiplePlayable;
    }

    private void EditorSaveEffectObject(TrackAsset track)
    {
        var controlTrack = track as ControlTrack;
        if (controlTrack)
        {
            GameObject bindGameObject = null;
            var clips = controlTrack.GetClips();
            foreach (var clip in clips)
            {
                ControlPlayableAsset mouthClip = clip.asset as ControlPlayableAsset;
                if (mouthClip != null)
                {
                    bool isValid = true;
                    Object oldExposedValue = this.curDirector.GetReferenceValue(mouthClip.sourceGameObject.exposedName, out isValid);
                    if (isValid == false)
                    {
                        continue;
                    }

                    bindGameObject = (GameObject) oldExposedValue;
                    if (bindGameObject != null)
                    {
                        break;
                    }
                }
            }

            if (bindGameObject)
            {
                SaveOneEffectTrackObj(bindGameObject, track);
            }
        }
    }
    
    
    private void InitCtrlTrack(PlayableDirector director, TrackAsset track, TrackExtData curData)
    {
        GameObject bindObj = null;
        switch (curData.trackType)
        {
            case TrackExtType.ChildEffect:
                break;
            case TrackExtType.HookEffect:
                bindObj = GetBindObj(curData.bindName, curData.bindPath, curData.bindRecorderKey, true, track);
                if (bindObj == null)
                {
                    return;
                }

                var parentObj = getHookGameObject(
                    curData.TopParentName,
                    curData.TopParentPath,
                    curData.HookName,
                    curData.bindSuitID.ToString(),
                    curData.topParentRecorderKey,
                    curData.isBrokenShirt,
                    trackName: track.name
                );

                var ctrlTrack = track as ControlTrack;
                ctrlTrack.extData.editorChangeSuit = (oldSuitID, newSuitID, isSyncAllTrack) =>
                {
                    ChangeSuit(director, track, oldSuitID, isSyncAllTrack, curData.isBrokenShirt);
                };

                if (parentObj == null)
                {
                    return;
                }

                bindObj.transform.SetParent(parentObj.transform);
                bindObj.transform.localPosition = curData.localPosition;
                bindObj.transform.localRotation = Quaternion.Euler(curData.localRotation);
                bindObj.transform.localScale = curData.localScale;

                _EnsureAnimator(bindObj);
                BindControlTrack(director, track, bindObj);
                curData.editorSaveEffectObj = () =>
                {
                    EditorSaveEffectObject(track);
                };
                break;
            case TrackExtType.ChildHookEffect:
                bindObj = GetBindObj(curData.bindName, curData.bindPath, curData.bindRecorderKey, true, track);
                if (bindObj == null)
                {
                    return;
                }
                var parent = this.transform;
                if (!string.IsNullOrEmpty(curData.HookName))
                {
                    parent = this.transform.Find(curData.HookName);
                }

                if (parent == null)
                {
                    return;
                }
                
                bindObj.transform.SetParent(parent);
                bindObj.transform.localPosition = curData.localPosition;
                bindObj.transform.localRotation = Quaternion.Euler(curData.localRotation);
                bindObj.transform.localScale = curData.localScale;
                _EnsureAnimator(bindObj);
                BindControlTrack(director, track, bindObj);
                curData.editorSaveEffectObj = () =>
                {
                    EditorSaveEffectObject(track);
                };
                break;
            case TrackExtType.CameraHookEffect:
                bindObj = GetCameraChildEffect(curData);
                if (bindObj == null)
                {
                    return;
                }

                bindObj.transform.localPosition = curData.localPosition;
                bindObj.transform.localRotation = Quaternion.Euler(curData.localRotation);
                bindObj.transform.localScale = curData.localScale;

                _EnsureAnimator(bindObj);
                BindControlTrack(director, track, bindObj);
                curData.editorSaveEffectObj = () =>
                {
                    EditorSaveEffectObject(track);
                };
                break;
            case TrackExtType.IsolateEffect:
                bindObj = GetBindObj(curData.bindName, curData.bindPath, curData.bindRecorderKey, true, track);
                if (bindObj == null)
                {
                    return;
                }

                _initDataAssistReturnList.Add(bindObj);
                bindObj.transform.position = curData.localPosition;
                bindObj.transform.rotation = Quaternion.Euler(curData.localRotation);
                bindObj.transform.localScale = curData.localScale;

                _EnsureAnimator(bindObj);
                BindControlTrack(director, track, bindObj);
                curData.editorSaveEffectObj = () =>
                {
                    EditorSaveEffectObject(track);
                };
                break;
        }
    }

    
    // 单独保存某个轨道上的Obj，并替换场上所有Obj对象
    private void SaveOneEffectTrackObj(GameObject obj, TrackAsset track)
    {
        if (obj == null)
        {
            return;   
        }
        // 保存老特效
        var prefabPath = "";
        if (effectPrefabDict.ContainsKey(obj))
        {
            prefabPath = effectPrefabDict[obj];
        }
        else
        {
            prefabPath = PrefabUtility.GetPrefabAssetPathOfNearestInstanceRoot(obj);
        }
        
        if (string.IsNullOrEmpty(prefabPath))
        { 
          return;  
        }
        else
        {
            // PrefabUtility.SaveAsPrefabAsset(obj, prefabPath);
            PrefabUtility.ApplyPrefabInstance(obj, InteractionMode.AutomatedAction);
        }
        
        // 删除新特效
        List<GameObject> prefabDeleteKeys = new List<GameObject>();
        foreach (var iter in prefabPathDic)
        {
            if (iter.Value == prefabPath)
            {
                prefabDeleteKeys.Add(iter.Key);  
            }  
        }
        foreach (var key in prefabDeleteKeys)
        {
            prefabPathDic.Remove(key);
            GameObject.DestroyImmediate(key);
        }
        
        prefabDeleteKeys.Clear();  
        foreach (var iter in effectPrefabDict)
        {
            if (iter.Value == prefabPath)
            {
                prefabDeleteKeys.Add(iter.Key);  
            }  
        }
        foreach (var key in prefabDeleteKeys)
        {
            effectPrefabDict.Remove(key);
        }
        
        // 重新build特效轨
        var timelineAsset = curDirector.playableAsset as TimelineAsset;
        //只针对丢失的AnimationClip和其他特效的Control Track
        var allTracks = timelineAsset.GetOutputTracks();
        foreach (var baseTrack in allTracks)
        {
            ControlTrack controlTrack = baseTrack as ControlTrack;
            if (controlTrack != null && controlTrack.extData != null)
            {
                if (controlTrack.extData.bindPath == prefabPath || ConvertToFullPath(controlTrack.extData.bindPath) == prefabPath)
                {
                    InitCtrlTrack(curDirector, controlTrack, controlTrack.extData); 
                }
            }
        }
        
    }

    private GameObject _GetAnimTrackObj(PlayableDirector director, AnimationTrack animTrack)
    {
        GameObject gameObj = null;
        var obj = director.GetGenericBinding(animTrack);
        gameObj = obj as GameObject;
        if (gameObj == null && obj is Animator)
        {
            gameObj = (obj as Animator).gameObject;
        }
        return gameObj;
    }
    
    [NonSerialized]
    public GameObject recordAnimCreature; 
    
    private void InitAnimTrack(PlayableDirector director, TrackAsset track, TrackExtData curData, ControlTrack lastControlTrack = null)
    {
        curData.editorRepairAnimTrack = null;
        GameObject bindObj = null;
        switch (curData.trackType)
        {
            case TrackExtType.CreatureAnim:
            case TrackExtType.Creature_K_Anim:
            case TrackExtType.Creature_Parent_Anim:
                bindObj = GetResRecorderObj(curData.bindRecorderKey);
                if (bindObj == null)
                {
                    bindObj = GetBindSuitObj(curData.bindSuitID.ToString(), curData.isBrokenShirt);
                }
                if (bindObj == null)
                {
                    bindObj = _GetBindMonsterObj(curData.bindName, curData.bindPath, null, false, null);
                }
                var animTrack = track as AnimationTrack;
                if (animTrack != null)
                {
                    animTrack.extData.editorChangeSuit = (oldSuitID, newSuitID, isSyncAllTrack) =>
                    {
                        ChangeSuit(director, animTrack, oldSuitID, isSyncAllTrack, animTrack.extData.isBrokenShirt);
                    };
                    
                    animTrack.extData.editorChangeWeapon = (oldWeaponID, newWeaponID) =>
                    {
                        // 换武器.
                        var obj = _GetAnimTrackObj(director, animTrack);
                        ChangeWeapon(obj, oldWeaponID, newWeaponID);
                    };
                }
                
                if (bindObj == null)
                {
                    return;
                }

                // bindObj.AddComponent<EditorRootMotionUpdater>();
                recordAnimCreature = bindObj;
                var useObj = bindObj;
                if (curData.trackType == TrackExtType.Creature_Parent_Anim && useObj.transform.parent != null)
                {
                    useObj = bindObj.transform.parent.gameObject;
                }
                useObj.transform.position = curData.localPosition;
                useObj.transform.rotation = Quaternion.Euler(curData.localRotation);
                useObj.transform.localScale = curData.localScale;
                track.muted = false;
                curDirector.SetGenericBinding(track, useObj);
                break;
            case TrackExtType.CameraAnim:
                bindObj = GetBindObj(curData.bindName, curData.bindPath, curData.bindRecorderKey, false, null);
                if (bindObj == null)
                {
                    return;
                }

                _EnsureAnimator(bindObj);
                bindObj.transform.position = curData.localPosition;
                bindObj.transform.rotation = Quaternion.Euler(curData.localRotation);
                bindObj.transform.localScale = curData.localScale;
                track.muted = false;
                curDirector.SetGenericBinding(track, bindObj);
                break;
            case TrackExtType.MainCameraAnim:
                bindObj = GetCameraTarget();
                if (bindObj == null)
                {
                    return;
                }

                _EnsureAnimator(bindObj);
                bindObj.transform.position = curData.localPosition;
                bindObj.transform.rotation = Quaternion.Euler(curData.localRotation);
                bindObj.transform.localScale = curData.localScale;
                track.muted = false;
                curDirector.SetGenericBinding(track, bindObj);
                break;
            case TrackExtType.HookEffectAnim:
            case TrackExtType.ChildHookEffectAnim:
                if (lastControlTrack != null)
                {
                    var lastBindObj = TryGetControlSourceObj(director, lastControlTrack);
                    if (lastBindObj != null)
                    {
                        var targetObj = lastBindObj;
                        if (!string.IsNullOrEmpty(curData.HookName))
                        {
                            targetObj = lastBindObj.transform.Find(curData.HookName)?.gameObject;    
                        }
                        curDirector.SetGenericBinding(track, targetObj);
                        // 新处理，hook类型的特效动画如果美术K了根节点动画，就要强制设置Follow模式，然后相对位置由动画保证
                        if (targetObj == lastBindObj)
                        {
                            var lastControlExtData = lastControlTrack.extData;
                            if (!lastControlExtData.isFollowActor)
                            {
                                lastControlExtData.isFollowActor = true;
                            }
                            if (!lastControlExtData.isFollowRotate)
                            {
                                lastControlExtData.isFollowRotate = true;
                            }   
                        }
                    }
                }
                break;
            case TrackExtType.ChildAnim:
                break;
            case TrackExtType.CameraHookEffectAnim:
                bindObj = GetCameraChildEffect(curData);
                if (bindObj == null)
                {
                    return;
                }

                bindObj.transform.position = curData.localPosition;
                bindObj.transform.rotation = Quaternion.Euler(curData.localRotation);
                bindObj.transform.localScale = curData.localScale;
                _EnsureAnimator(bindObj);
                curDirector.SetGenericBinding(track, bindObj);
                break;
            case TrackExtType.IsolateEffectAnim:
                bindObj = GetBindObj(curData.bindName, curData.bindPath, curData.bindRecorderKey, false, track);
                if (bindObj == null)
                {
                    return;
                }

                bindObj.transform.position = curData.localPosition;
                bindObj.transform.rotation = Quaternion.Euler(curData.localRotation);
                bindObj.transform.localScale = curData.localScale;
                _EnsureAnimator(bindObj);
                curDirector.SetGenericBinding(track, bindObj);
                break;
            default:
                curData.editorRepairAnimTrack = () => { };  // 暂时不用这里修复，只是做个非null标记
                break;
        }
        
        if (bindObj != null && curData.bindWeaponID > 0)
        {
            // 初始化武器.
            AddWeapon(GetBindSuitObj(curData.bindSuitID.ToString(), curData.isBrokenShirt), curData.bindWeaponID);
        }
        
    }

    // 获取ResCorder上的资源
    private GameObject GetResRecorderObj(string key)
    {
        if (string.IsNullOrEmpty(key))
        {
            return null;
        }
        var obj = resRecorder.GetResObject(key);
        return obj;
    }
    
    private void _EnsureAnimator(GameObject bindObj)
    {
        if (bindObj.GetComponent<Animator>() == null)
        {
            bindObj.AddComponent<Animator>();
        }
    }

    //获取挂接点的父节点
    private GameObject getHookGameObject(string topParentName, string topParentPath, string HookName, string bindSuitName, string topRescorderKey, bool isBroken, string trackName = "")
    {
        GameObject prefab = null;
        prefab = GetResRecorderObj(topRescorderKey);
        if (prefab == null)
        { 
            prefab = GetBindSuitObj(bindSuitName, isBroken);
            if (prefab == null)
            {
                prefab = _GetBindMonsterObj(topParentName, topParentPath, null, false, null, trackName: trackName);
            }
        }

        var target = prefab;    
        if (prefab != null)
        {
            //var coreProxy = prefab.GetComponent<AvatarPrefabCoreProxy>();
            //if (coreProxy != null)
            //{
            //    foreach (var VARIABLE in coreProxy.DummyObjects)
            //    {
            //        if (VARIABLE.SerialObject.name.Equals(HookName))
            //        {
            //            return VARIABLE.SerialObject;
            //        }
            //    }
            //}

            var child = prefab.transform.Find(HookName)?.gameObject;
            if (child != null)
            {
                target = child;  // 没有child先挂到父节点上，clip运行时动态执行
            }
        }

        return target;
    }
    
    private GameObject GetCameraChildEffect(TrackExtData curData)
    {
        var parentObj = GetBindObj(curData.TopParentName, curData.TopParentPath, curData.bindRecorderKey, false, null);
        if (parentObj == null)
        {
            return null;
        }

        _EnsureAnimator(parentObj);

        var bindObj = GetBindObj(curData.bindName, curData.bindPath, curData.bindRecorderKey, false, null);
        if (bindObj == null)
        {
            return null;
        }

        Transform retTran = bindObj.transform;
        var camera = parentObj.transform.GetComponentInChildren<Camera>();
        if (camera != null)
        {
            retTran.SetParent(camera.transform);
        }
        else
        {
            EditorUtility.DisplayDialog(@"Warning",
                transform.name + "特效没有挂载在camera的prefab下", @"返回");
            return null;
        }

        _EnsureAnimator(bindObj);

        return retTran.gameObject;
    }

    
    private void GetChildByLoop(Transform parent, string childName, ref Transform retTran)
    {
        if (retTran != null)
        {
            return;
        }

        for (int i = 0; i < parent.childCount; i++)
        {
            if (childName.Equals(parent.GetChild(i)))
            {
                retTran = parent.GetChild(i);
                return;
            }

            GetChildByLoop(parent.GetChild(i), childName, ref retTran);
        }
    }

    Dictionary<string, GameObject> suitObjDict = new Dictionary<string, GameObject>();
    
    private GameObject GetBindSuitObj(string name, bool isBrokenShirt)
    {
        if (string.IsNullOrEmpty(name))
        {
            return null;
        }

        if (name == "0")
        {
            return null;
        }

        if (suitObjDict.ContainsKey(name))
        {
            if (suitObjDict[name] != null)
            {
                return suitObjDict[name];
            }
            else
            {
                suitObjDict.Remove(name);
            }
        }

        var _selectObject = LoadCharacterBuySuit(name, isBrokenShirt);
        if (_selectObject == null)
        {
            EditorUtility.DisplayDialog(@"Warning", name + "套装配置对应的游戏对象生成失败！", @"返回");
            return null;
        }
        
        // DONE: 套装重命名. 生成该样式的名字 -> 100010(Girl)
        string suitGoName = name;
        if (TryConvertSuitID(name, out int suitId))
        {
            if (BattleUtil.IsBoySuit(suitId))
            {
                suitGoName = $"{suitId}{Const_Boy}";
            }
            else if (BattleUtil.IsGirlSuit(suitId))
            {
                suitGoName = $"{suitId}{Const_Girl}";
            }
        }

        _selectObject.name = "Model";  // 需要和运行时统一这里必须设为Model
        _selectObject.tag = "player";
        var animator = _selectObject.GetComponent<Animator>();
        if (animator != null)
        {
            Object.DestroyImmediate(animator);
        }
        var com = _selectObject.AddComponent<Animator>();
        com.applyRootMotion = true;
        suitObjDict.Add(name, _selectObject);

        // 需要和运行时统一，此处创建一个父节点
        var parent = new GameObject(suitGoName);
        _EnsureAnimator(parent);
        _selectObject.transform.parent = parent.transform;
        
        return _selectObject;
    }

    
    private void DeleteBindSuitObj(GameObject obj)
    {
        if (obj == null)
        {
            return;
        }

        string name = null;
        foreach (var iter in suitObjDict)
        {
            if (iter.Value == obj)
            {
                name = iter.Key;
            }
        }

        if (!string.IsNullOrEmpty(name))
        {
            suitObjDict.Remove(name);
        }

        _DestroyActorOrMonster(obj);
    }

    private GameObject _GetBindMonsterObj(string name, string path, string bindRecordKey, bool isEffect, TrackAsset track, string trackName = "")
    {
        var monsterObj = GetBindObj(name, path, bindRecordKey, isEffect, track, trackName: trackName);
        if (monsterObj != null && monsterObj.transform.parent == null)
        {
            var parentName = monsterObj.name;
            monsterObj.name = "Model";
            // 需要和运行时统一，此处创建一个父节点
            var parent = new GameObject(parentName);
            _EnsureAnimator(parent);
            var animator = monsterObj.GetComponent<Animator>();
            if (animator)
            {
                animator.applyRootMotion = true;
            }
            monsterObj.transform.parent = parent.transform;
        }
        return monsterObj;
    }
    private GameObject GetBindObj(string name, string path, string bindRecordKey, bool isEffect, TrackAsset track, string trackName = "")
    {
        var bindRecorderObj = GetResRecorderObj(bindRecordKey);
        if (bindRecorderObj != null)
        {
            return bindRecorderObj;
        }
        
        if (track != null)
        {
            TrackExtData extData = null;
            if (IsCommonPrefixPath(track, out extData))
            {
                path = ConvertToFullPath(path);
            }
        }
        
        if (string.IsNullOrEmpty(name))
        {
            return null;
        }

        if (!isEffect) // 不是effect的唯一，是effect的可以重复创建
        {
            foreach (var VARIABLE in prefabPathDic)
            {
                if (VARIABLE.Value.Equals(path))
                {
                    return VARIABLE.Key;
                }
            }
        }
        
        var _selectObject = (GameObject) AssetDatabase.LoadAssetAtPath(path, typeof(GameObject));

        if (_selectObject == null)
        {
            //常规路径没找到，说明路径移动了，需要从文件夹里查找一下
            path = GetEntityAvatarPath(name);
            if (string.IsNullOrEmpty(path))
            {
                var trackStrs = trackName;
                if (string.IsNullOrEmpty(trackStrs))
                {
                    trackStrs = (track == null ? "" : track.name);
                }
                EditorUtility.DisplayDialog(@"Warning", name + "找不到绑定的主体，请呼叫程序, 轨道名字: " + trackStrs, @"返回");
                return null;
            }

            _selectObject = (GameObject) AssetDatabase.LoadAssetAtPath(path, typeof(GameObject));
        }


        var prefab =PrefabUtility.InstantiatePrefab(_selectObject) as GameObject;
        prefab.name = GetTrimName(prefab.name);
        prefab.SetActive(true);
        prefab.transform.parent = null;
        prefabPathDic[prefab] = path;
        if (isEffect)
        {
            effectPrefabDict[prefab] = path;
        }
        else
        {
            //var com = prefab.GetComponent<BattleMonsterEffect>();
            //if (com == null)
            //{
            //    prefab.AddComponent<BattleMonsterEffect>();
            //}
            
#if UNITY_EDITOR  //编辑器  给每个加了render的子物体加 MatTexAnimHelper 给动画系统K材质动画用
            AllAddMatTexAnimHelper(prefab.transform);
#endif
        }

        return prefab;
    }

    
    //给每个加了render的子物体加 MatTexAnimHelper 给动画系统K材质动画用
    public static void AllAddMatTexAnimHelper(Transform root)
    {
        Transform[] trfs = root.GetComponentsInChildren<Transform>(true);
        foreach (var tsf in trfs)
        {
            var render = tsf.GetComponent<SkinnedMeshRenderer>();
            if (render == null)
                continue;
            
            var matTex = tsf.GetComponent<X3Battle.MatTexAnimHelper>();
            if (matTex == null )
            {
                tsf.gameObject.AddComponent<X3Battle.MatTexAnimHelper>();
            }
        }
    }
    
    private void DeleteBindObj(GameObject obj)
    {
        if (obj == null)
        {
            return;
        }

        if (prefabPathDic.ContainsKey(obj))
        {
            prefabPathDic.Remove(obj);
        }

        if (effectPrefabDict.ContainsKey(obj))
        {
            effectPrefabDict.Remove(obj);
        }

        GameObject.DestroyImmediate(obj);
    }

    public Func<string, bool, GameObject> LoadCharacterBuySuit;


    private GameObject GetCameraTarget()
    {
        var obj = Transform.FindObjectsOfType<Camera>();
        if (obj == null || obj.Length == 0)
        {
            EditorUtility.DisplayDialog(@"Warning",
                "MainCamera丢失,请创建以后再尝试初始化", @"返回");
            return null;
        }

        GameObject prefab = null;
        foreach (var VARIABLE in obj)
        {
            if (VARIABLE.name.Contains("MainCamera") || VARIABLE.name.Contains("MainCamera"))
            {
                prefab = VARIABLE.gameObject;
                break;
            }
        }

        if (prefab == null)
        {
            return null;
        }

        prefab.SetActive(true);
        prefabPathDic[prefab] = timelinePrefabPath;
        return prefab;
    }

    
    public string GetPrefabPath(GameObject obj)
    {
        string path = null;
        if (prefabPathDic.TryGetValue(obj, out path))
        {
            if (string.IsNullOrEmpty(path))
            {
                path = GetEntityAvatarPath(obj);
            }
        }
        else
        {
            path = AssetDatabase.GetAssetPath(obj);
            if (string.IsNullOrEmpty(path))
            {
                path = GetEntityAvatarPath(obj);
            }
        }

        if (!string.IsNullOrEmpty(path))
        {
            path = path.Replace('\\', '/');
        }
        return path;
    }

    
    //获取最高的父节点
    public Transform GetTopParentObj(Transform cur)
    {
        if (cur == null)
        {
            return null;
        }
        return RecurseGetParentTran(cur);
    }

    
    public Transform RecurseGetParentTran(Transform cur)
    {
        if (cur.parent == null || _IsActorOrMonster(cur.gameObject))
        {
            return cur;
        }
        else
        {
            return RecurseGetParentTran(cur.parent);
        }
    }
    
    public void ChangeWeapon(GameObject bindObj, int oldWeaponId, int newWeaponId)
    {
        RemoveWeapon(bindObj, oldWeaponId);
        AddWeapon(bindObj, newWeaponId);
    }
    
    public void AddWeapon(GameObject bindObj, int weaponId)
    {
        if (bindObj == null)
            return;
        if (!bindObj.TryGetComponent<X3.Character.X3Character>(out _))
        {
            return;
        }

        var partNames = BattleUtil.GetWeaponParts(weaponId);
        if (partNames != null)
        {
            foreach (var partName in partNames)
            {
                BattleCharacterMgr.AddPart(bindObj, partName, autoSyncLod: false);
            }
        } 
        
        //todo 后面找个好地方加 临时解决
#if UNITY_EDITOR  //编辑器  给每个加了render的子物体加 MatTexAnimHelper 给动画系统K材质动画用
        TimelineExtInfo.AllAddMatTexAnimHelper(bindObj.transform);
#endif
    }
    
    public void RemoveWeapon(GameObject bindObj, int weaponId)
    {
        if (bindObj == null)
            return;
        if (!bindObj.TryGetComponent<X3.Character.X3Character>(out _))
        {
            return;
        }
        
        var partNames = BattleUtil.GetWeaponParts(weaponId);
        if (partNames != null)
        {
            foreach (var partName in partNames)
            {
                BattleCharacterMgr.RemovePart(bindObj, partName);
            }
        }
    }

    public void ChangeSuit(PlayableDirector director, TrackAsset track, int oldSuitID, bool isSyncAllTrack, bool isBorkenShirt)
    {
        if (track is ControlTrack controlTrack)
        {
            var clips = controlTrack.GetClips();
            foreach (var timelineClip in clips)
            {
                if (timelineClip.asset is ControlPlayableAsset controlAsset)
                {
                    var obj = director.GetReferenceValue(controlAsset.sourceGameObject.exposedName, out var isValid);
                    if (isValid)
                    {
                        DeleteBindObj(obj as GameObject);
                    }
                }
            }

            if (suitObjDict.ContainsKey(oldSuitID.ToString()))
            {
                var oldSuitObj = GetBindSuitObj(oldSuitID.ToString(), isBorkenShirt);
                DeleteBindSuitObj(oldSuitObj); 
            }

            if (!isSyncAllTrack)
            {
                // DONE: 仅同步自己这个轨道的变更.
                InitCtrlTrack(director, track, controlTrack.extData);
            }
            else
            {
                // DONE: 同步所有轨道的变更.
                _SyncTrackExtDataToAllTrack(oldSuitID, controlTrack.extData, director, track);  
            }
        }
        else if (track is AnimationTrack animTrack)
        {
            if (suitObjDict.ContainsKey(oldSuitID.ToString()))
            {
                var oldSuitObj = GetBindSuitObj(oldSuitID.ToString(), isBorkenShirt);
                DeleteBindSuitObj(oldSuitObj);   
            }

            animTrack.extData.bindName = animTrack.extData.bindSuitID.ToString();

            if (!isSyncAllTrack)
            {
                InitAnimTrack(director, track, animTrack.extData);
            }
            else
            {
                // DONE: 同步所有轨道的变更.
                _SyncTrackExtDataToAllTrack(oldSuitID, animTrack.extData, director, track);
            }
        }
    }

    
    private void _SyncTrackExtDataToAllTrack(int oldSuitID, TrackExtData newTrackExtData, PlayableDirector director, TrackAsset targetTrack)
    {
        var playable = director.playableAsset;
        if (playable == null)
        {
            return;
        }
        
        if (oldSuitID != 0)
        {
            var timelineAsset = (TimelineAsset)playable;
            var allTracks = timelineAsset.GetOutputTracks();
            foreach (var trackAsset in allTracks)
            {
                var trackType = trackAsset.GetType();
                var fieldInfo = trackType.GetField("extData");
                if (fieldInfo == null)
                {
                    continue;
                }
                var trackExtData = fieldInfo.GetValue(trackAsset) as TrackExtData;
                if (trackExtData == null)
                    continue;
                // DONE: 轨道上 bindSuitID = 0的不刷.
                if (trackExtData.bindSuitID == oldSuitID)
                {
                    trackExtData.bindSuitID = newTrackExtData.bindSuitID;
                    trackExtData.isBrokenShirt = newTrackExtData.isBrokenShirt;
                    trackExtData.bindGirlSuit = BattleUtil.IsGirlSuit(newTrackExtData.bindSuitID);
                }
            }
        }
        
        InitDataNew();
    }
    
    
    public static string StripConstName(string name)
    {
        if (name.Contains(Const_Boy))
        {
            name = name.Replace(Const_Boy, "");
        }
        else if(name.Contains(Const_Girl))
        {
            name = name.Replace(Const_Girl, "");
        }

        return name;
    }
#endif
    
    // 是否是Actor或者Monster的父节点
    private static bool _IsActorOrMonsterParent(GameObject cur)
    {
        if (cur == null)
        {
            return false;
        }
        
        var childTrans = cur.transform.Find("Model");
        if (childTrans == null)
        {
            return false;
        }

        var isActorOrMonster = _IsActorOrMonster(childTrans.gameObject);
        return isActorOrMonster;
    }
    
    public static bool IsGirlRoot(GameObject obj)
    {
        var isActor = _IsActorOrMonsterParent(obj);
        if (isActor)
        {
            var isGirl = obj.name.Contains(Const_Girl);
            return isGirl;
        }
        return false;
    }

    public static bool IsBoyRoot(GameObject obj)
    {
        var isActor = _IsActorOrMonsterParent(obj);
        if (isActor)
        {
            var isBoy = obj.name.Contains(Const_Boy);
            return isBoy;
        }
        return false;
    }
    
    // 是否是actor或者monster
    private static bool _IsActorOrMonster(GameObject cur)
    {
        if (cur == null)
        {
            return false;
        }
        if (cur.CompareTag("player") || cur.CompareTag("monster"))
        {
            return true;
        }
        return false;
    }
    
    /// <summary>
    /// 尝试转换成SuitId
    /// </summary>
    /// <param name="bindSuitId"></param>
    /// <returns></returns>
    public static bool TryConvertSuitID(string bindSuitId, out int suitId)
    {
        if (!int.TryParse(bindSuitId, out suitId))
        {
            return false;
        }
    
        return true;
    }
}