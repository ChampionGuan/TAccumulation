using UnityEngine;
using System.Collections.Generic;
using ProceduralAnimation;

namespace X3Game
{
    [CreateAssetMenu(fileName = "X3AnimatorAsset", menuName = "X3/X3AnimatorAsset", order = 8)]
    public class X3AnimatorAsset : ScriptableObject
    {
        public string RootBoneName;
        public int AssetId = 0;
        public string DefaultStateName;
        //public bool StrictMode = false;
        public float DefaultTransitionDuration = 0.2f;
        public List<X3Animator.State> EmbeddedStateList = new List<X3Animator.State>();
        //public List<X3Animator.Transition> EmbeddedTransitionList = new List<X3Animator.Transition>();
        public ControlRigGraph ControlRigAsset;
        public string ControlRigTargetBoneName;
    }
}
