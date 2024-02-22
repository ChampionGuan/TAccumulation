using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [HasRefreshButton]
    [Category("X3Battle/通用/Function/GetPointDistance")]
    [Name("获得距离\nGetPointDistance")]
    public class FAGetPointDistance : FlowAction
    {
        public CoorPoint pointData1 = new CoorPoint();
        public CoorPoint pointData2 = new CoorPoint();
        
        protected override void _OnRegisterPorts()
        {
            this.DrawFlowNodePoint(pointData1);
            this.DrawFlowNodePoint(pointData2,true);
            AddValueOutput("Distance", () =>
            {
                var pos1 = pointData1.GetCoordinatePoint(null, false);
                var pos2 = pointData2.GetCoordinatePoint(null, false);

                return (pos1 - pos2).magnitude;
            });
        }
    }
}
