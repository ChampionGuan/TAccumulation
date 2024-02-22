using PapeGames.X3;

namespace X3Battle
{
    public static class StateUtil
    {
        /// <summary>
        /// 非技能状态处理输入缓存 释放技能
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        public static bool CommonSateUseCacheInput(Actor actor)
        {
            if (actor.input == null || actor.skillOwner == null)
            {
                return false;
            }
            var sortDatas = actor.input.sortDatas;
            if (sortDatas.Count < 0)
            {
                return false;
            }
            //处理非技能状态的输入缓存处理逻辑 按照输入优先级进行处理
            foreach (var inputData in sortDatas)
            {
                if (!actor.input.commonUseBtns.Contains(inputData.Key))
                {
                    continue;
                }
                
                //只处理down
                var canConsumeCache = actor.input.CanConsumeCache(inputData.Key, PlayerBtnStateType.Down,
                    TbUtil.battleConsts.CommonStateInputTime);
                if (!canConsumeCache)
                {
                    continue;
                }
                
                var curSlotID = actor.skillOwner.TryGetCurSlotID(inputData.Key, PlayerBtnStateType.Down);
                if (curSlotID == null)
                {
                    continue;
                }
                
                // 尝试释放技能
                var result = actor.skillOwner.TryCastSkillBySlot(curSlotID.Value, null, stateType: PlayerBtnStateType.Down);
                if (result)
                {
                    LogProxy.Log("技能打断连招控制器： 使用缓存成功释放技能" + " inputData.Key = " + inputData.Key + " frame = " + Battle.Instance.frameCount);
                    // 此处技能释放成功，就消耗掉Down缓存
                    actor.input.TryConsumeCache(inputData.Key, PlayerBtnStateType.Down);
                    return true;
                }
            }

            return false;
        }
    }
}