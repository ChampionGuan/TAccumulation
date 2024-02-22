using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    //获取Actor所属的格子 索引， 位置
    // 索引（例子：3*3）
    // 7 8 9
    // 4 5 6
    // 1 2 3
    [Category("X3Battle/关卡/Action")]
    [Description("获取Actor在区域内，所属的格子 索引， 位置")]
    [Name("获取Actor所属格子\nGetActorBelongCell")]
    public class GetActorBelongCell : FlowAction
    {
        [Name("矩形区域，左下角坐标")]
        public BBParameter<Vector3> areaCenterPos = new BBParameter<Vector3>();
        [Name("区域长度(x轴)")]
        public BBParameter<float> areaLen = new BBParameter<float>();
        [Name("区域宽度(z轴)")]
        public BBParameter<float> areaWidth = new BBParameter<float>();
        [Name("长(x轴),格子数量")]
        public BBParameter<int> lenCellNum = 50;
        [Name("宽(x轴),格子数量")]
        public BBParameter<int> widthCellNum = 50;

        private ValueInput<Actor> _target;
        private Vector3 _belonCellPos;
        private int _belonCellIndex;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _target = AddValueInput<Actor>("target");
            AddValueOutput("belongCellPos", () => _belonCellPos);
            AddValueOutput("belongCellIndex", () => _belonCellIndex);
        }
        
        protected override void _Invoke()
        {
            _belonCellIndex = 0;
            _belonCellPos = Vector3.zero;
            if (_target.value == null)
                return;
            Vector3 targetPos = _target.value.transform.position;
            // 转到区域坐标系下
            var areaPos = targetPos - areaCenterPos.value;
            
            // 计算格子的宽高
            if (widthCellNum.value == 0 || lenCellNum.value == 0)
                return;
            var cellWidth = areaWidth.value / widthCellNum.value;
            var cellLen = areaLen.value / lenCellNum.value;
            
            // 计算所在格子的索引
            if (cellWidth == 0 || cellLen == 0)
                return;
            int xIndex = Mathf.Max(Mathf.CeilToInt(areaPos.x / cellLen), 1);
            int zIndex = Mathf.Max(Mathf.CeilToInt(areaPos.z / cellWidth), 1);
            _belonCellIndex = xIndex + (zIndex - 1) * widthCellNum.value;
            
            // 计算所在格子中心位置
            _belonCellPos = targetPos;
            _belonCellPos.x = areaCenterPos.value.x + xIndex * cellLen - cellLen * 0.5f;
            _belonCellPos.z = areaCenterPos.value.z + zIndex * cellWidth - cellWidth * 0.5f;
        }
    }
}
