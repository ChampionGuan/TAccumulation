using System.Collections.Generic;
using PapeGames.X3;
using Pathfinding;

namespace X3Battle
{
    /// <summary>
    /// 寻路网格惩罚管理器   
    /// </summary>
    public class BattleGridPenaltyMgr : BattleComponent
    {
        private Dictionary<int, GraphUpdatePenalty> _graphUpdatePentlies = new Dictionary<int, GraphUpdatePenalty>();
        private int _maxTag = -1; //当前最大的tag数 超过64会出问题 原则上不会

        public BattleGridPenaltyMgr() : base(BattleComponentType.GridPenaltyMgr)
        {
        }

        protected override void OnStart()
        {
            base.OnStart();
            battle.eventMgr.AddListener<EventUpdatePenalty>(EventType.OnUpdatePently, _OnUpdatePenalty, "BattleGridPenaltyMgr._OnUpdatePenalty");
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            battle.eventMgr.RemoveListener<EventUpdatePenalty>(EventType.OnUpdatePently, _OnUpdatePenalty);
            _graphUpdatePentlies.Clear();
        }

        public int GetCurrentTag()
        {
            var tag = ++_maxTag;
            if (tag > 64)
            {
                LogProxy.LogError("寻路：寻路标记大于64个 寻路可能出现问题");
            }

            return tag;
        }

        private void _OnUpdatePenalty(EventUpdatePenalty updatePenalty)
        {
            if (!_graphUpdatePentlies.ContainsKey(updatePenalty.insID))
            {
                return;
            }
            var findActor = battle.actorMgr.GetActor(updatePenalty.insID);
            if (findActor == null || findActor.isDead)
            {
                return;
            }
            LogProxy.Log("actor insid = " + updatePenalty.insID + " 开启寻路");

            int tag = _graphUpdatePentlies[updatePenalty.insID].pathTag;
            foreach (var info in _graphUpdatePentlies)
            {
                if (info.Value == null || info.Key == 0)
                {
                    continue;
                }

                info.Value.RevertPenlty(tag);

                var actor = battle.actorMgr.GetActor(info.Key);
                if (actor == null || actor.isDead)
                {
                    continue;
                }

                //忽略碰撞的物体不加入寻路惩罚半径
                if (actor.collider != null)
                {
                    if (actor.collider.GetColliderMono(ColliderType.IgnoreCollision) != null)
                    {
                        continue;
                    }
                }

                //法术场特殊处理 只有男主有可能规避法术场 其它不会规避法术场
                if (actor.type == ActorType.SkillAgent && actor.config.SubType == (int)SkillAgentType.MagicField)
                {
                    if (findActor.IsBoy() && info.Value.boyIsInclude)
                    {
                        if (info.Key != updatePenalty.insID)
                        {
                            LogProxy.Log("actor insid = " + updatePenalty.insID + " 更新惩罚物体 actor.name = " + actor.name + " 附加惩罚半径 = " + updatePenalty.radius);
                            info.Value.ApplyPenalty(updatePenalty.radius, tag);
                        }
                        continue;
                    }
                    else
                    {
                        continue;
                    }
                }
                
                if (info.Key != updatePenalty.insID)
                {
                    LogProxy.Log("actor insid = " + updatePenalty.insID + " 更新惩罚物体 actor.name = " + actor.name + " 附加惩罚半径 = " + updatePenalty.radius);
                    info.Value.ApplyPenalty(updatePenalty.radius, tag);
                }
            }
        }

        public void AddGraphUpdatePenalty(int insID, GraphUpdatePenalty graphUpdatePenalty)
        {
            if (null == graphUpdatePenalty) return;
            if (_graphUpdatePentlies.ContainsKey(insID))
            {
                LogProxy.LogError($"不允许添加相同实例ID：{insID}的惩罚脚本，请留意检查");
                return;
            }

            _graphUpdatePentlies.Add(insID, graphUpdatePenalty);
        }

        public void RemoveGraphUpdatePenalty(int insID)
        {
            if (_graphUpdatePentlies.ContainsKey(insID))
            {
                _graphUpdatePentlies.Remove(insID);
            }
        }
    }
}