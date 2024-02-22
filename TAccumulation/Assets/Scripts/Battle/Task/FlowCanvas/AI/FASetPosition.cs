using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI/Action")]
    [Name("SetPosition(AI专用)")]
    public class FASetPosition : FlowAction
    {
        public BBParameter<Vector3> position = new BBParameter<Vector3>();
        protected override void _Invoke()
        {
            _actor.transform.SetPosition(position.value);
        }
    }
}
