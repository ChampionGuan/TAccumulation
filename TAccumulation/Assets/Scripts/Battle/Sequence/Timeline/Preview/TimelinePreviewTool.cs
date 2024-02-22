using PapeGames.X3;
using UnityEngine;

namespace X3Battle.Timeline.Preview
{
    /// <summary>
    ///  非运行时预览工具类
    /// </summary>
    public class TimelinePreviewTool
    {
        private static TimelinePreviewTool _instance;
        public static TimelinePreviewTool instance {
            get
            {
                if (_instance == null)
                {
                    _instance = new TimelinePreviewTool();
                }
                return _instance;
            }
        }
        private TimelinePreviewTool() {}
        
        // 获取当前的actor对象
        private GameObject _curActor;
        private DummiesMono _dummies;
        private FxMgrMono _fxMgr;

        public GameObject GetActorModel()
        {
            return _curActor;
        }
        
        /// <summary>
        /// 从场上重新寻找actorModel
        /// </summary>
        public void RefreshActorModel(GameObject curActor)
        {
            if (curActor)
            {
                _curActor = curActor;
            }
            else
            {
                _curActor = GameObject.FindWithTag("player");
                if (_curActor == null)
                {
                    _curActor = GameObject.FindWithTag("monster");   
                }
            }

            _ClearDummy();
        }

        public FxMgr GetFxMgr()
        {
            if (_fxMgr == null)
            {
                var obj = GameObject.Find("FxMgr");
                if (obj == null)
                {
                    obj = new GameObject("FxMgr");
                    _fxMgr = obj.AddComponent<FxMgrMono>();
                }
                else
                {
                    _fxMgr = obj.GetComponent<FxMgrMono>();
                }
            }
            return _fxMgr.fxMgr;
        }
        
        // 获取当前的挂点配置
        public Transform GetDummy(string name)
        {
            if (!string.IsNullOrEmpty(name) && !string.IsNullOrWhiteSpace(name))
            {
                if (_dummies != null)
                {
                    var trans = _dummies.GetDummyTrans(name);
                    if (trans != null)
                    {
                        return trans;   
                    }
                }
            }

            return _curActor?.transform;
        }

        public Dummies GetDummies()
        {
            return _dummies?.dummies;
        }

        // 通过ArtTimelinePath初始化挂点信息 
        public void InitDummyByArtTimePath(string timelinePath, ActionModuleCfg moduleCfg)
        {
            if (moduleCfg != null)
            {
                // 当场上有多个player时，根据动作模组1开头优先选女主，否则优先选男主
                var objs = GameObject.FindGameObjectsWithTag("player");
                if (objs != null && objs.Length >= 2)
                {
                    var id = moduleCfg.ID;
                    var preferGirl = id.ToString().StartsWith("1");
                    foreach (var obj in objs)
                    {
                        var parent = obj.transform.parent;
                        if (preferGirl && parent != null && parent.name.Contains("Girl"))
                        {
                            RefreshActorModel(obj);
                            break;
                        }
                        else if(!preferGirl && parent != null && parent.name.Contains("Boy"))
                        {
                            RefreshActorModel(obj);
                            break;
                        }
                    }
                }
            }
            
            _ClearDummy();
            if (string.IsNullOrEmpty(timelinePath))
            {
                return;    
            } 
            BattleEditorConfig editorCfg = null;
            TbUtil.Init();

            if (null == TbUtil.editorRoleCfgs)
            {
                return;
            }
            foreach (var iter in TbUtil.editorRoleCfgs)
            {
                var cfg = iter.Value;
                if (CheckMatch(timelinePath, cfg.TimelinePath))
                {
                    editorCfg = cfg;
                    break;
                }  
            }

            if (editorCfg != null)
            {
                _InitDummy(editorCfg.ModelInfo);
            }
        }

        // 检测是否可以
        public bool CheckMatch(string path1, string path2)
        {
            if (!string.IsNullOrEmpty(path2) && path1.StartsWith(path2))
            {
                if (path1.Length == path2.Length)
                {
                    return true;
                }

                var strs = path1.Substring(path2.Length, 1);
                if (strs[0] == '/')
                {
                    return true;  
                }
            }
            return false;
        }
       
        private void _ClearDummy()
        {
            if (_curActor != null)
            {
                _curActor.RemoveComponent<DummiesMono>();  
            }
            _dummies = null; 
        }
        
        private void _InitDummy(string key)
        {
            if (string.IsNullOrEmpty(key))
            {
                return;   
            }
            if (_curActor == null)
            {
                return;    
            }
            ModelInfo modelCfg = TbUtil.GetCfg<ModelInfo>(key);
            if (modelCfg != null)
            {
                _dummies = _curActor.AddComponent<DummiesMono>();
                _dummies.Init(modelCfg.dummys, _curActor.transform);
            }
        }
    }
}