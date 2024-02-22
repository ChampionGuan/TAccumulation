using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using PapeGames.X3;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Playables;
using X3Game;

namespace X3Battle
{
    /// <summary>
    /// 战斗特效测试器
    /// </summary>
    [XLua.LuaCallCSharp]
    public class BattleFxTester : PapeGames.Rendering.Singleton<BattleFxTester>
    {
        private int m_startActorIndex;

        public void RegisterTestOnBattleBegin(int startActorIndex = 0)
        {
            // lod测试和fx性能测试公用同一个入口...
            switch (startActorIndex)
            {
                // lod质量测试
                case -1:
                    FxSetting.SetEffectQuality(FxSetting.LodType.high);
                    return;
                case -2:
                    FxSetting.SetEffectQuality(FxSetting.LodType.mid);
                    return;
                case -3:
                    FxSetting.SetEffectQuality(FxSetting.LodType.low);
                    return;
            }

            m_startActorIndex = startActorIndex;
            BattleClient.OnStartupFinished.AddListener(BeginTestAll);
        }

        public void RemoveTestOnBattleBegin()
        {
            BattleClient.OnStartupFinished.RemoveListener(BeginTestAll);
        }

        public void BeginTestAll()
        {
            BeginTestAll(m_startActorIndex);
            RemoveTestOnBattleBegin();
        }

        /// <summary>
        /// 战斗特效测试入口
        /// </summary>
        public void BeginTestAll(int startActorIndex = 0)
        {
            // 带逻辑
            CoroutineProxy.StartCoroutine(PlayAllSkillsCoroutine(startActorIndex));

            // 纯播片
            // BattleFxUtilTimelineTester a = new BattleFxUtilTimelineTester();
            // CoroutineProxy.StartCoroutine(a.PlayAllSkillFxCoroutine());
        }

        /// <summary>
        /// 以施放技能为方式测试
        /// </summary>
        /// <returns></returns>
        IEnumerator PlayAllSkillsCoroutine(int startActorIndex)
        {
            LogProxy.Log($"战斗特效性能测试-开始。 起始index: {startActorIndex}");

            var controlActor = BattleFxUtil.GetControlActor();

            //  隐藏掉控制角色、怪物、场景
            BattleFxUtil.HideEnv();

            // 记录已经播放的技能——不重复播放
            HashSet<int> m_playedSkillIds = new HashSet<int>();

            for (CurActorIdx = startActorIndex; CurActorIdx < BattleFxUtil.Instance.actors.Count; CurActorIdx++)
            {
                var curFxActor = BattleFxUtil.Instance.actors[CurActorIdx];
                // 跳过无技能角色
                if (curFxActor.skillIds == null || curFxActor.skillIds.Count <= 0)
                {
                    continue;
                }

                // 跳过特定会卡死的角色
                // if (s_invalidActorIDs.Contains(curFxActor.id))
                // {
                //     continue;
                // }

                int curActorId = 0;
                Actor createdActor = null;
                try
                {
                    curActorId = curFxActor.id;
                    createdActor = BattleFxUtil.Instance.CreateRole(curActorId, Vector3.zero, false,
                        FactionType.Hero,
                        curActorId + 100);
                }
                catch (Exception e)
                {
                    LogProxy.LogError(
                        $"战斗特效性能测试-创建人物失败 id: {curActorId}, index: {CurActorIdx}, message: {e.Message} stack: {e.StackTrace}");
                    BattleFxUtil.Instance.Destroy(curActorId);
                    continue;
                }

                if (createdActor != null)
                {
                    LogProxy.Log(
                        $"战斗特效性能测试-创建人物成功 id: {curActorId}, index: {CurActorIdx}, 位置{createdActor.transform.position}");

                    // 将相机注视到当前释放技能人物
                    Battle.Instance.cameraTrace.SetFollowTgt(false, createdActor);
                }

                yield return new WaitForSeconds(0.1f);

                // 等到born结束 - born结束会回池所有的出生创建对象
                while (createdActor != null && createdActor.mainState?.mainStateType == ActorMainStateType.Born)
                {
                    yield return null;
                }

                // 播放技能
                foreach (var skillId in curFxActor.skillIds)
                {
                    if (m_playedSkillIds.Contains(skillId))
                    {
                        continue;
                    }

                    m_playedSkillIds.Add(skillId);

                    if (createdActor != null)
                    {
                        // 还原角色位置
                        createdActor.transform.SetPosition(controlActor.transform.position, true);
                        // 还原角色朝向
                        createdActor.transform.SetRotation(quaternion.LookRotation(
                            Battle.Instance.cameraTrace.GetCameraTransform().forward +
                            Battle.Instance.cameraTrace.GetCameraTransform().right,
                            Battle.Instance.cameraTrace.GetCameraTransform().up));
                    }

                    // 播放技能
                    float lastSkillTime = 0;
                    var logLabel = $"Fx测试-角色 id: {curActorId}.技能 id: {skillId}";
                    GameMgr.BeginPerformanceLog(logLabel);
                    try
                    {
                        lastSkillTime = Time.time;
                        if (!BattleFxUtil.Instance.PlaySkill(curActorId, skillId))
                        {
                            GameMgr.EndPerformanceLog(logLabel);
                            continue;
                        }
                    }
                    catch (Exception)
                    {
                        GameMgr.EndPerformanceLog(logLabel);
                        continue;
                    }

                    while (curFxActor.actor.skillOwner.IsSkillRunning() && (Time.time - lastSkillTime) < 10f)
                    {
                        yield return null;
                    }

                    GameMgr.EndPerformanceLog(logLabel);

                    BattleFxUtil.Instance.CleanUp();

                    yield return new WaitForSeconds(0.1f); // 留一些时间等待结束
                }

                // 移除角色
                try
                {
                    // 移除之前把镜头放在控制角色身上，防止镜头跟随到死亡角色池导致绘制峰值
                    Battle.Instance.cameraTrace.SetFollowTgt(false, controlActor);
                    BattleFxUtil.Instance.RemoveRole(curActorId);
                }
                catch (Exception)
                {
                    LogProxy.LogError($"战斗特效性能测试-移除人物失败 id:{curActorId}, index:{CurActorIdx}");
                }

                LogProxy.Log($"战斗特效性能测试-移除人物成功 id:{curActorId}, index:{CurActorIdx}");

                yield return new WaitForSeconds(0.1f);

                // 卸载相关资产 - 防止内存不停上涨
                BattleFxUtil.Instance.BattleResTryUninit();
                yield return new WaitForSeconds(0.1f);
            }

            LogProxy.Log("战斗特效性能测试-结束");

            yield return new WaitForSeconds(1);

            BattleClient.Instance.End(false);
            BattleClient.Instance.Shutdown();

            // 弹出UI，表明测试结束 - 暂用GM UI
            GMCommandManager.OpenGmWnd();
        }

        /// <summary>
        /// 以纯粹播放Fx为方式测试
        /// </summary>
        IEnumerator PlayAllSkillFxCoroutine()
        {
            float lastStartTime;
            foreach (var skillKey in TbUtil.skillCfgs.Keys)
            {
                var directors =
                    BattleTimelineFxUtil.Instance.CreateTimeline(skillKey, out var timelineObj, out var timelineFxObjs);

                if (directors == null || directors.Count <= 0)
                {
                    continue;
                }

                // 移动到当前角色所在位置
                foreach (var timelineFxObj in timelineFxObjs)
                {
                    var actor = Battle.Instance.actorMgr.GetFirstActor(ActorType.Hero, includeSummoner: false);
                    if(null != actor) timelineFxObj.transform.position = actor.transform.position;
                }

                BattleTimelineFxUtil.Instance.PlaySkill(directors);
                lastStartTime = Time.time;

                var allFinished = true;
                foreach (var director in directors)
                {
                    if (director.state != PlayState.Playing)
                    {
                        allFinished = false;
                    }
                }

                while (Time.time - lastStartTime < 2f)
                {
                    yield return null;
                }

                BattleTimelineFxUtil.Instance.DestorySkill(
                    timelineObj.Select(o => o.GetComponent<PlayableDirector>()).ToList(), timelineObj,
                    timelineFxObjs);
                yield return new WaitForSeconds(1);
            }
        }

        public int CurActorIdx { get; set; }

        public static readonly int[] s_invalidActorIDs = { 210001, 220501, 35555, 21031, 40310, 65012, 51020, 51030 };
    }
}