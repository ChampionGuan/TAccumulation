using UnityEngine.Playables;
using UnityEngine.Profiling;
using X3.Character;
using X3Battle;

namespace UnityEngine.Timeline
{
    public class LODBehavior : InterruptBehaviour
    {
        public float LOD { get; set; }

        private float _lastLOD;
        private X3Character _x3Character;
        
        // TODO  老艾 切LOD之后重设BattleCharacterEffect需要封装一下，因为战斗里面别处也会调用
        private BattleCharacterEffect _effect;
        
        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            using (ProfilerDefine.LODBehaviorOnStartMarker.Auto())
            {
                if (playerData is GameObject go)
                {
                    var x3Character = go.GetComponent<X3Character>();
                    if (x3Character != null)
                    {
                        _lastLOD = x3Character.LOD;
                        x3Character.LOD = BattleCharacterMgr.GetLOD(LOD);
                        _x3Character = x3Character;
                    
                        _effect = go.GetComponent<BattleCharacterEffect>();
                        if (_effect)
                        {
                            _effect.Initialize();   
                        }
                    
                    }
                
#if UNITY_EDITOR  //编辑器  给每个加了render的子物体加 MatTexAnimHelper 给动画系统K材质动画用
                    TimelineExtInfo.AllAddMatTexAnimHelper(go.transform);
#endif
                
                }
            }
        }

        protected override void OnStop()
        {
            if (_x3Character != null)
            {
                _x3Character.LOD = _lastLOD;
                
                if (_effect)
                {
                    _effect.Initialize();   
                } 
            }

            _x3Character = null;
            _lastLOD = 0f;
        }
    }
}