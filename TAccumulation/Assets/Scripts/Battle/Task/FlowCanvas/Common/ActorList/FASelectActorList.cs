using System;
using System.Collections.Generic;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion;
using ParadoxNotion.Design;
using UnityEngine;
using Random = UnityEngine.Random;

namespace X3Battle
{
    [Category("X3Battle/通用/Action/ActorList")]
    [Name("按条件选择actor或actorList\nSelectActorList")]
    [Description("只包含Hero,item和Monster类型,范围内距离选择的时候，不包含sourceActor")]
    public class FASelectActorList : FlowAction
    {
        public enum SelectActorSourceType
        {
            All,
            ActorList,
        }

        public enum SelectActorTargetType
        {
            Random, //随机
            Nearest, //最近
            Farthest, //最远
        }

        public enum ShowTagSelectType
        {
            IncludeAll,
            IncludeAny,
            ExcludeAll,
            ExcludeAny,
        }

        public enum ActorSelectType
        {
            All,
            Boy,
            Girl,
            BoyAndGirl,
            Monster,
            Stage,
            Item,
        }
        
        [Name("选择源"),GatherPortsCallback] public SelectActorSourceType SelectType = SelectActorSourceType.All;
        [Name("单个Actor选择逻辑")]
        public SelectActorTargetType SelectTargetType = SelectActorTargetType.Random;
        
        [ParadoxNotion.Design.Header("关卡条件")]
        public BBParameter<int> GroupID = new BBParameter<int>(-1);
        [Name("MonsterTemplateID")] public BBParameter<int> TemplateID = new BBParameter<int>(-1);
        [Name("SpawnID")]public BBParameter<int> InsID = new BBParameter<int>(-1);

        [ParadoxNotion.Design.Header("actor条件")]
        [Name("是否要求可锁定")] public bool IsLegal = false;
        public BBParameter<FactionFlag> SelectFactionTags = new BBParameter<FactionFlag>((FactionFlag)(-1));
        [Name("所选Tag逻辑")] public ShowTagSelectType ShowTagType = ShowTagSelectType.IncludeAll;
        public BBParameter<List<int>> ShowTags = new BBParameter<List<int>>();
        
        [ParadoxNotion.Design.Header("summon条件")]
        public IncludeSummonType SummonSelect = IncludeSummonType.AnyType;
        public ActorSelectType MasterActorSelectType = ActorSelectType.All;
        
        [ParadoxNotion.Design.Header("范围条件")]
        public float Radius = -1f;

        private ValueInput<Actor> _sourceActor;
        private ValueInput<ActorList> _viActorList;
        private ActorList _resultList = new ActorList(10);
        private Actor _resultActor;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();

            if (SelectType == SelectActorSourceType.ActorList)
            {
                _viActorList = AddValueInput<ActorList>("SourceList");
            }

            _sourceActor = AddValueInput<Actor>("SourceActor");

            AddValueOutput("ActorList", () => _resultList);
            AddValueOutput("ResultActor", () => _resultActor);
        }

        protected override void _Invoke()
        {
            _resultList.Clear();
            _resultActor = null;
            List<Actor> sourceList = null;
            switch (SelectType)
            {
                case SelectActorSourceType.All:
                    sourceList = _battle.actorMgr.actors;
                    break;
                case SelectActorSourceType.ActorList:
                    sourceList = _viActorList?.GetValue();
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            if (sourceList == null)
            {
                if (SelectType == SelectActorSourceType.ActorList)
                {
                    _LogError($"节点【按条件批量生成ActorList FASelectActor】引脚参数错误, 当SelectType == ActorList时，引脚需要正确赋值");
                }

                return;
            }

            var groupId = GroupID.GetValue();
            var templateId = TemplateID.GetValue();
            var spawnID = InsID.GetValue();
            var showTags = ShowTags.GetValue();

            for (int i = 0; i < sourceList.Count; i++)
            {
                var actor = sourceList[i];
                if (actor.isDead)
                {
                    continue;
                }

                if (!actor.IsItem() && actor.type != ActorType.Hero && !actor.IsMonster())
                {
                    continue;
                }

                if (groupId > 0 && groupId != actor.groupId)
                {
                    continue;
                }

                if (templateId > 0 && templateId != actor.bornCfg.CfgID)
                {
                    continue;
                }

                if (spawnID > 0 && spawnID != actor.spawnID)
                {
                    continue;
                }
                
                //阵营筛选
                if (!BattleUtil.ContainFactionType(SelectFactionTags.GetValue(), actor.factionType))
                {
                    continue;
                }

                
                if (showTags != null && showTags.Count > 0)
                {
                    bool include = true;
                    switch (ShowTagType)
                    {
                        case ShowTagSelectType.IncludeAll:
                        {
                            include = actor.ContainsAllShowTags(showTags);
                        }
                            break;
                        case ShowTagSelectType.IncludeAny:
                        {
                            include = false;
                            foreach (var showtag in showTags)
                            {
                                if (actor.ContainsShowTag(showtag))
                                {
                                    include = true;
                                    break;
                                }
                            }
                        }
                            break;
                        case ShowTagSelectType.ExcludeAll:
                        {
                            include = !actor.ContainsAllShowTags(showTags);
                        }
                            break;
                        case ShowTagSelectType.ExcludeAny:
                        {
                            foreach (var tag in showTags)
                            {
                                if (actor.ContainsShowTag(tag))
                                {
                                    include = false;
                                    break;
                                }
                            }
                        }
                            break;
                        default:
                            _LogError("ShowTagSelectType选择类型错误！");
                            break;
                    }

                    if (!include) continue;
                }

                float dist = _sourceActor.value == null ? actor.transform.position.magnitude : BattleUtil.GetActorDistance(actor, _sourceActor.value);

                if (Radius > 0 && Radius < dist)
                {
                    continue;
                }

                if (IsLegal && actor.stateTag != null && actor.stateTag.IsActive(ActorStateTagType.LockIgnore))
                {
                    continue;
                }
                
                //判断召唤物类型
                if (actor.IsSummoner())
                {
                    if (SummonSelect == IncludeSummonType.NoSummon)
                    {
                        continue;
                    }
                    switch (MasterActorSelectType)
                    {
                        case ActorSelectType.All:
                            break;
                        case ActorSelectType.Boy:
                        {
                            if (!actor.master.IsBoy())
                            {
                                continue;
                            }
                        }
                            break;
                        case ActorSelectType.Girl:
                        {
                            if (!actor.master.IsGirl())
                            {
                                continue;
                            }
                        }
                            break;
                        case ActorSelectType.BoyAndGirl:
                        {
                            if (actor.master.type != ActorType.Hero)
                            {
                                continue;
                            }
                        }
                            break;
                        case ActorSelectType.Monster:
                        {
                            if (actor.master.type != ActorType.Monster)
                            {
                                continue;
                            }
                        }
                            break;
                        case ActorSelectType.Stage:
                        {
                            if (actor.master.type != ActorType.Stage)
                            {
                                continue;
                            }
                        }
                            break;
                        case ActorSelectType.Item:
                        {
                            if (actor.master.type != ActorType.Item)
                            {
                                continue;
                            }
                        }
                            break;
                        default:
                            _LogError("MasterActorSelectType 错误");
                            break;
                    }
                }
                else
                {
                    if (SummonSelect == IncludeSummonType.OnlySummon)
                    {
                        continue;
                    }
                }

                _resultList.Add(actor);
            }

            if (_resultList.Count > 0)
            {
                float maxDist = float.MinValue;
                float minDist = float.MaxValue;
                switch (SelectTargetType)
                {
                    case SelectActorTargetType.Random:
                    {
                        _resultActor = _resultList[Random.Range(0, _resultList.Count)];
                    }
                        break;
                    case SelectActorTargetType.Nearest:
                    {
                        foreach (var targetActor in _resultList)
                        {
                            //不包含自己
                            if (targetActor == _sourceActor.value)
                            {
                                continue;
                            }
                            float dist = _sourceActor.value == null ? targetActor.transform.position.magnitude : BattleUtil.GetActorDistance(targetActor, _sourceActor.value);
                            if (dist < minDist)
                            {
                                minDist = dist;
                                _resultActor = targetActor;
                            }
                        }
                    }
                        break;
                    case SelectActorTargetType.Farthest:
                    {
                        foreach (var targetActor in _resultList)
                        {
                            //不包含自己
                            if (targetActor == _sourceActor.value)
                            {
                                continue;
                            }
                            float dist = _sourceActor.value == null ? targetActor.transform.position.magnitude : BattleUtil.GetActorDistance(targetActor, _sourceActor.value);
                            if (dist > maxDist)
                            {
                                maxDist = dist;
                                _resultActor = targetActor;
                            }
                        }
                    }
                        break;
                    default:
                        _LogError("SelectActorTargetType枚举选择错误");
                        break;
                }
            }
        }


#if UNITY_EDITOR

        protected override void OnNodeInspectorGUI()
        {
            if (this.GetType().RTIsDefined<HasRefreshButtonAttribute>(true))
            {
                if (GUILayout.Button("Refresh"))
                {
                    GatherPorts();
                }

                EditorUtils.Separator();
            }

            var objectDrawer = PropertyDrawerFactory.GetObjectDrawer(this.GetType());
            var content = EditorUtils.GetTempContent(name.SplitCamelCase());
            objectDrawer.DrawGUI(content, this, new InspectedFieldInfo());

            EditorUtils.Separator();
            DrawValueInputsGUI();
        }

#endif
    }
}
