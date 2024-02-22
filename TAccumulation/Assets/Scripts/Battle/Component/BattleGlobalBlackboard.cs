using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    public class BattleGlobalBlackboard : BattleComponent
    {
        private GlobalBlackboard _globalBlackboard;
        
        public BattleGlobalBlackboard() : base(BattleComponentType.BattleGlobalBlackboard)
        {
            
        }

        protected override void OnAwake()
        {
            var gameObject = BattleResMgr.Instance.Load<GameObject>(BattleConst.BattleGlobalBlackboard, BattleResType.GlobalBlackboard);
            if (gameObject == null)
            {
                return;
            }

            var globalBlackboard = gameObject.GetComponent<GlobalBlackboard>();
            if (globalBlackboard == null)
            {
                return;
            }
            
            globalBlackboard.transform.SetParent(Battle.Instance.root);
            globalBlackboard.transform.localPosition = Vector3.zero;

            _globalBlackboard = globalBlackboard;
        }

        protected override void OnDestroy()
        {
            if (_globalBlackboard == null)
            {
                return;
            }

            BattleResMgr.Instance.Unload(_globalBlackboard.gameObject);
            _globalBlackboard = null;
        }

        public GlobalBlackboard GetGlobalBlackboard()
        {
            return _globalBlackboard;
        }
        
        public void SetVariableValue<T>(string varName, T value)
        {
            if (_globalBlackboard == null)
            {
                return;
            }

            _globalBlackboard.SetVariableValue(varName, value);
        }

        public void PreloadFinished()
        {
            _globalBlackboard?.Reset();
        }
    }
}