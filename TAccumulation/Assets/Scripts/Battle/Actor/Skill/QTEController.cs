using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;
using X3Battle.TargetSelect;
using Random = UnityEngine.Random;

namespace X3Battle
{
    public class QTEController
    {
        private float _girlOffsetAngle = 22.5f;  // 策划设定女主选点时Z轴偏移22.5°
        private Actor _actor;
        
        private int? _defaultSlotID;  // 常规技能
        public int? qteSlotID { get; private set; } // QTE技能
        public bool isActive { get; private set; }  // QTE是否处于激活状态 （UI会使用）
        public float activeRemainTime { get; private set; } // 激活状态剩余时长（UI会使用）
        public float cdRemainTime { get; private set; } //  cd状态剩余时长（UI会使用）
        public float CD { get; private set; }  // 配置时长
        public float  Duration { get; private set; }  // 配置持续时长

        public QTEController(Actor actor)
        {
            _actor = actor;
            // 获取常规active技能和，qteactive技能，策划设定为0和1
            _defaultSlotID = actor.skillOwner.GetSlotID(SkillSlotType.Active, 0);
            CD = actor.boyCfg.QTETriggerCD;
            Duration = actor.boyCfg.QTEDuration;
        }
        
        
        // 对外接口，尝试激活QTE
        public bool TryActiveQTE(int skillID)
        {
            // 非QTE状态，并且不在CD中
            if (!isActive && cdRemainTime <= 0)
            {
                qteSlotID = _actor.skillOwner.GetSlotIDBySkillID(skillID);
                if (qteSlotID != null)
                {
                    _OnActive();
                    return true;
                }
            }
            return false;
        }

        private void _OnActive()
        {
            activeRemainTime = Duration;
            isActive = true;

            var defaultSlot = _actor.skillOwner.GetSkillSlot(_defaultSlotID.Value);
            defaultSlot.SetRemainCD(0);
            var qteSlot = _actor.skillOwner.GetSkillSlot(qteSlotID.Value);
            qteSlot.SetRemainCD(0);
            
            LogProxy.LogFormat("【QTE】：男主进入QTE状态！");

            var eventData = _actor.battle.eventMgr.GetEvent<EventSetQTEActive>();
            eventData.Init(true);
            _actor.battle.eventMgr.Dispatch(EventType.SetQTEActive, eventData);
        }

        private void _OnInactive()
        {
            activeRemainTime = 0;
            isActive = false;
            
            LogProxy.LogFormat("【QTE】：男主退出QTE状态！");
            
            var eventData = _actor.battle.eventMgr.GetEvent<EventSetQTEActive>();
            eventData.Init(false);
            _actor.battle.eventMgr.Dispatch(EventType.SetQTEActive, eventData);
        }

        public void Update()
        {
            var deltaTime = _actor.deltaTime;
            if (isActive)  // qte激活态
            {
                activeRemainTime -= deltaTime;
                if (activeRemainTime <= 0)
                {
                    _OnInactive();
                }
            }
            else if (cdRemainTime > 0)  // qteCd态
            {
                cdRemainTime -= deltaTime;
                if (cdRemainTime <= 0)
                {
                    cdRemainTime = 0;
                    LogProxy.LogFormat("【QTE】：男主QTE冷却结束，可被触发！");
                }  
            }
        }

        public void ClearCD()
        {
            cdRemainTime = 0;
        }
        
        public void OnCastSkill(SkillActive skill)
        {
            var type = skill.config.Type;
            if (type != SkillType.MaleActive && type != SkillType.EXMaleActive)
            {
                return;
            }
            
            // 设置角色位置
            using (ProfilerDefine.SetQTEPositionPMarker.Auto())
            {
                _TrySetQtePosition(skill.config);
            }

            // 如果释放的是QTE技能，并且在QTE状态, 则离开QTE状态, 并且开始CD
            if (qteSlotID != null && qteSlotID.Value == skill.slotID && isActive)
            {
                qteSlotID = null;
                _OnInactive();
                cdRemainTime = CD;
                LogProxy.LogFormat("【QTE】：男主QTE进入冷却，不可被触发！");
            }
        }

        // 刷新锁定目标
        public void RefreshLockTarget(SkillCfg cfg)
        {
            // 判断是男主的主动技，并且锁定模式是Lock
            if ((cfg.Type == SkillType.MaleActive || cfg.Type == SkillType.EXMaleActive) && cfg.TargetSelectType == TargetSelectType.Lock)
            {
                var girl = _actor.battle.actorMgr.girl;
                if (girl != null)
                {
                    // 先尝试取女主的锁定系统目标，取不到就用算法算一个
                    var target = girl.GetTarget();
                    if (target == null)
                    {
                        target = TargetSelectUtil.CommonSkillSelect(girl.targetSelector, true, out var _);
                    }
                    if (target != null)
                    {
                        // 让目标给男主添加一个嘲讽buff
                        var buffID = TbUtil.battleConsts.BoyActiveSkillTauntBuffID;
                        LogProxy.LogFormat("【目标】：男主释放主动技时让{0} 给自己挂一个通用嘲讽buff {1}", target.name, buffID);
                        _actor.buffOwner.Add(TbUtil.battleConsts.BoyActiveSkillTauntBuffID, null, null, 1, target);
                    }
                }
            }
        }
        
        // 尝试设置QTE男主位置
        private void _TrySetQtePosition(SkillCfg cfg)
        {
            if (!cfg.ActiveSkillTransport)
            {
                LogProxy.LogFormat("【QTE】：男主技能不需要搜寻设置位置！");
                return;
            }
            
            if (cfg.TransportTargetType == BoyTransportTargetType.Enemy && _actor.GetTarget() == null)
            {                
                LogProxy.LogFormat("【QTE】：男主技能位置以怪为目标，但是没有锁定对象，跳出！");
                return;
            }

            // 选取目标点
            Vector3? targetPos = null;
            if (cfg.TransportTargetType == BoyTransportTargetType.Girl)
            {
                targetPos = _GetPosByGirl(cfg);
            }
            else if (cfg.TransportTargetType == BoyTransportTargetType.Enemy)
            {
                targetPos = _GetPosByMonster(cfg);
            }

            // 位移并播特效
            if (targetPos != null)
            {
                if (cfg.PreTransportFX > 0)
                {
                    _actor.effectPlayer.PlayFx(cfg.PreTransportFX);
                }

                _actor.transform.SetPosition(targetPos.Value, true, true, checkAirWall:true);
                
                if (cfg.PostTransportFX > 0)
                {
                    _actor.effectPlayer.PlayFx(cfg.PostTransportFX);
                }
            }
        }

        private static List<QTEPointInfo> _points = new List<QTEPointInfo>(16);

        private void _ClearPoints()
        {
            for (int i = 0; i < _points.Count; i++)
            {
                ObjectPoolUtility.QTEPointInfo.Release(_points[i]);
            }
            _points.Clear();
        }
        
        // 以女主为目标选点
        private Vector3? _GetPosByGirl(SkillCfg cfg)
        {
            // 获取Z轴，相机forward在XZ平面的投影为Z轴
            var cameraForward = CameraTrace.GetMainCamera().transform.forward;
            cameraForward.y = 0;
            var axisZ = cameraForward.normalized;
            // 获取X轴
            var axisX = Vector3.Cross(Vector3.up, axisZ);
            // 坐标系原点
            var originalPos = _actor.battle.actorMgr.girl.transform.position;
            // 候选点
            _ClearPoints();
            
            var transportAngle = cfg.TransportAngle > 0 ? cfg.TransportAngle : 0;
            // 左剔除方向线
            var cullLine1 = Quaternion.AngleAxis(0.5f * transportAngle, Vector3.up) * -axisZ;
            // 右剔除方向线
            var cullLine2 = Quaternion.AngleAxis(-0.5f * transportAngle, Vector3.up) * -axisZ;
            
            // 获取点的Z轴和X轴，相机forward在XZ平面的投影为Z轴
            var pointAxisZ = Quaternion.AngleAxis(_girlOffsetAngle, Vector3.up) * axisZ;
            var pointAxisX = Vector3.Cross(Vector3.up, pointAxisZ);
            
            var directions = MathConst.clockwiseDirections8;
            for (int i = 0; i < directions.Length; i++)
            {
                var localDirect = directions[i]; // 局部方向
                var worldPointDirect = localDirect.x * pointAxisX + localDirect.z * pointAxisZ; // 世界方向
                
                // 是否在不在culling范围内
                var areaType = AreaType.Culling;
                var cross1 = Vector3.Cross(cullLine1, worldPointDirect);
                var cross2 = Vector3.Cross(worldPointDirect, cullLine2);
                if (cross1.y > 0 && cross2.y > 0)
                {
                    areaType = AreaType.Optimized;
                }

                // 判断是不是优先方向
                var directionType = (QTEDirection)i;
                var isPriorityDirection = BattleUtil.ContainQTEDirection(cfg.QTEPriorityDirections, directionType);

                var bigPoint = originalPos + worldPointDirect * cfg.TransportMaxRadius; // 大圆点
                if (BattleUtil.IsRightPoint(bigPoint, _actor.transform.position))
                {
                    var isInSight = Battle.Instance.cameraTrace.IsInSight(bigPoint, 0, 0, 0);
                    var score = QTEPointInfo.CalculateTargetGirlScore(areaType, isInSight, true, isPriorityDirection);
                    var pointInfo = ObjectPoolUtility.QTEPointInfo.Get();
                    pointInfo.Init(bigPoint, score);
                    QTEPointInfo.InsertAndSort(_points, pointInfo);
                }
                
                var smallPoint = originalPos + worldPointDirect * cfg.TransportMinRadius; // 小圆点
                if (BattleUtil.IsRightPoint(smallPoint, _actor.transform.position))
                {
                    var isInSight = Battle.Instance.cameraTrace.IsInSight(smallPoint, 0, 0, 0);
                    var score = QTEPointInfo.CalculateTargetGirlScore(areaType, isInSight, false, isPriorityDirection);
                    var pointInfo = ObjectPoolUtility.QTEPointInfo.Get();
                    pointInfo.Init(smallPoint, score);
                    QTEPointInfo.InsertAndSort(_points, pointInfo);
                }
            }

            if (_points.Count > 0)
            {
                var pointInfo = _points[0];
                // Debug绘制
                // var trans = GameObject.CreatePrimitive(PrimitiveType.Sphere).transform;
                // trans.position = pointInfo.pos;
                // trans.localScale = Vector3.one * 0.5f;
                
                return pointInfo.pos;
            }
            return null;
        }

        // 以怪物为目标选点
        private Vector3? _GetPosByMonster(SkillCfg cfg)
        {
            var lockTarget = _actor.GetTarget();
            // 获取剔除线Z轴, 世界空间中相机和目标连线的XZ方向
            var cameraTrans = CameraTrace.GetMainCamera().transform;
            var cameraTargetDir = lockTarget.transform.position - cameraTrans.position;
            cameraTargetDir.y = 0;
            var axisZ = cameraTargetDir.normalized;
            // 获取X轴
            var axisX = Vector3.Cross(Vector3.up, axisZ);
            // 坐标系原点
            var originalPos = lockTarget.transform.position;
            // 候选点
            _ClearPoints();
            
            var transportAngle = cfg.TransportAngle > 0 ? cfg.TransportAngle : 0;
            // 左剔除方向线
            var cullLine1 = Quaternion.AngleAxis(-0.5f * transportAngle, Vector3.up) * axisZ;
            // 右剔除方向线
            var cullLine2 = Quaternion.AngleAxis(0.5f * transportAngle, Vector3.up) * axisZ;
            // 下剔除方向线, 相机forward在XZ平面的投影的反向
            var cameraForward = cameraTrans.forward;
            cameraForward.y = 0;
            var cullLine3 = - cameraForward.normalized;
            // 判断右边区域是最优，还是左边区域最优
            // isRight为True，证明-cullLine3在axisZ顺时针方向，即目标在屏幕左边，右边是最优区
            var isRight = Vector3.Cross(axisZ, -cullLine3).y > 0;
            var bigRadius = cfg.TransportMaxRadius + lockTarget.radius;
            var smallRadius = cfg.TransportMinRadius + lockTarget.radius;
            
            // 获取八方向, 右边最优区顺时针，左边最优区逆时针
            Vector3[] directions = null;
            if (isRight)
            {
                directions = MathConst.clockwiseDirections8;
            }
            else
            {
                directions = MathConst.anticlockwiseDirections8;
            }

            // 获取点的Z轴和X轴，相机forward在XZ平面的投影为Z轴
            var pointAxisZ = -cullLine3;
            var pointAxisX = Vector3.Cross(Vector3.up, pointAxisZ);
            
            for (int i = 0; i < directions.Length; i++)
            {
                var localDirect = directions[i]; // 局部方向
                var worldPointDirect = localDirect.x * pointAxisX + localDirect.z * pointAxisZ; // 世界方向
                // 计算区域
                var areaType = AreaType.Normal;
                var cross1 = Vector3.Cross(cullLine1, worldPointDirect);
                var cross2 = Vector3.Cross(cullLine2, worldPointDirect);
                if (cross1.y > 0 && cross2.y < 0)
                {
                    areaType = AreaType.Culling;
                }
                else
                {
                    var cross3 = Vector3.Cross(cullLine3, worldPointDirect);
                    if (isRight)
                    {
                        // 右侧区域最优
                        if (cross2.y >= 0 && cross3.y <= 0)
                        {
                            areaType = AreaType.Optimized;
                        }
                    }
                    else
                    {
                        // 左侧区域最优
                        if (cross1.y<= 0 && cross3.y >=0)
                        {
                            areaType = AreaType.Optimized;
                        }   
                    }
                }
                
                // 判断是不是优先方向
                var directionType = (QTEDirection)i;
                var isPriorityDirection = BattleUtil.ContainQTEDirection(cfg.QTEPriorityDirections, directionType);
                
                var bigPoint = originalPos + worldPointDirect * bigRadius; // 大圆点
                if (BattleUtil.IsRightPoint(bigPoint, _actor.transform.position))
                {
                    var isInSight = Battle.Instance.cameraTrace.IsInSight(bigPoint, 0, 0, 0);
                    var score = QTEPointInfo.CalculateTargetGirlScore(areaType, isInSight, true, isPriorityDirection);
                    var pointInfo = ObjectPoolUtility.QTEPointInfo.Get();
                    pointInfo.Init(bigPoint, score);
                    QTEPointInfo.InsertAndSort(_points, pointInfo);
                }
                
                var smallPoint = originalPos + worldPointDirect * smallRadius; // 小圆点
                if (BattleUtil.IsRightPoint(smallPoint, _actor.transform.position))
                {
                    var isInSight = Battle.Instance.cameraTrace.IsInSight(smallPoint, 0, 0, 0);
                    var score = QTEPointInfo.CalculateTargetGirlScore(areaType, isInSight, false, isPriorityDirection);
                    var pointInfo = ObjectPoolUtility.QTEPointInfo.Get();
                    pointInfo.Init(smallPoint, score);
                    QTEPointInfo.InsertAndSort(_points, pointInfo);
                }
            }

            if (_points.Count > 0)
            {
                var pointInfo = _points[0];
                // Debug绘制
                // var trans = GameObject.CreatePrimitive(PrimitiveType.Sphere).transform;
                // trans.position = pointInfo.pos;
                // trans.localScale = Vector3.one * 0.25f;
                
                return pointInfo.pos;
            }
            return null;
        }

        public class QTEPointInfo: IReset
        {
            public Vector3 pos { get; private set; }
            public int score { get; private set; }  // 分数

            public void Reset()
            {
                pos = Vector3.zero;
                score = 0;
            }
            
            public void Init(Vector3 _pos, int _score)
            {
                pos = _pos;
                score = _score;
                // // Debug绘制
                // if (score >= 100)
                // {
                //     var trans = GameObject.CreatePrimitive(PrimitiveType.Sphere).transform;
                //     trans.position = _pos;
                //     trans.localScale = Vector3.one * 0.25f;  
                // }
            }
            
            public static int CalculateTargetGirlScore(AreaType areaType, bool _isInSight, bool isBigPos, bool isPriorityDirection)
            {
                // 新增需求排序优先级：①视野内 ②配置选中点 ③最优区 ④大圈点
                // 优先取视野内点，其次取最优区点，其次大圈点
                // 1.视野内，最优区，大圈点
                // 2.视野内，最优区, 小圈点
                // 3.视野内，普通区，大圈点（以怪物为目标有普通区，以女主为目标没有）
                // 4.视野内，普通区，小圈点（以怪物为目标有普通区，以女主为目标没有）
                // 5.视野内，剔除区，大圈点
                // 6.视野内，剔除区，小圈点
                // 7.视野外，随机取点（按排序取）
                return (_isInSight ? 10000 : 0) + (isPriorityDirection ? 1000 : 0) + ((int)areaType * 100) + (isBigPos ? 10 : 0) + Random.Range(0, 9);
            }

            // 插入并排序
            public static void InsertAndSort(List<QTEPointInfo> list, QTEPointInfo qtePointInfo)
            {
                for (int i = 0; i < list.Count; i++)
                {
                    if (qtePointInfo.score > list[i].score)
                    {
                        list.Insert(i, qtePointInfo);
                        return;
                    }
                }
                list.Add(qtePointInfo);
            }
        }

        public enum AreaType
        {
            Culling = 0,
            Normal = 1,
            Optimized = 2,
        }
    }
}