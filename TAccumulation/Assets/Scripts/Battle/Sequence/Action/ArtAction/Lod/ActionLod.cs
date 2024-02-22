using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Profiling;
using UnityEngine.Timeline;
using X3.Character;
using X3Battle;

namespace X3Battle
{
    public class ActionLod : BSAction
    {
        public float LOD { get; set; }

        private float _lastLOD;
        private X3Character _x3Character;
        
        // TODO  老艾 切LOD之后重设BattleCharacterEffect需要封装一下，因为战斗里面别处也会调用
        private BattleCharacterEffect _effect;
        protected override void _OnInit()
        {
            base._OnInit();
            var clipAsset = GetClipAsset<LODClip>();
            this.LOD = clipAsset.LOD;
        }
        protected override void _OnEnter()
        {
            base._OnEnter();
            using (ProfilerDefine.ActionLodOnEnterMarker.Auto())
            {
                var go = GetTrackBindObj<GameObject>();
                if (go == null)
                {
                    return;
                }
            
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
            }
        }

        protected override void _OnExit()
        {
            base._OnExit();
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