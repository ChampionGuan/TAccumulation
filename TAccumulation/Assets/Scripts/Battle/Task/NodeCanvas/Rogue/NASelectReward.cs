using System;
using System.Collections.Generic;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Rogue")]
    public class NASelectReward : BattleAction
    {
        private Action _closeCallback;
        private List<RogueTrophyData> _rogueTrophyDatas = new List<RogueTrophyData>();

        public NASelectReward()
        {
            _closeCallback = _OnCloseCallback;
        }

        protected override void OnExecute()
        {
            // DONE: 询问当前层的战利品奖励是否已经领取过了.
            _battle.rogue.GetTrophyDataCount(_battle.rogue.arg.CurrentLayerData.LayerID, 0, null, null, outList: _rogueTrophyDatas);
            var extraTrophyData = _rogueTrophyDatas.Count > 0 ? _rogueTrophyDatas[0] : null;
            switch ((RogueRewardType)_battle.rogue.levelConfig.RewardType)
            {
                // DONE: 本身该关卡就没有额外奖励需要领取.
                case RogueRewardType.None:
                    _TriggerNextNode();
                    break;
                case RogueRewardType.Entry:
                    if (extraTrophyData != null)
                    {
                        if (extraTrophyData.Type == RogueRewardType.Entry)
                        {
                            if (_battle.rogue.GetExtraRollEntriesTime() <= 0)
                            {
                                _TriggerNextNode();
                                return;
                            }
                            else
                            {
                                _battle.rogue.RollEntriesForExtraTimes(_closeCallback);
                                return;
                            }
                        }
                    }
                    _battle.rogue.RollEntries(_closeCallback);
                    break;
                case RogueRewardType.Prop:
                    LogProxy.LogError($"【战斗】【Rogue】尚未额外奖励道具类型的功能需求, 直接跳过该流程！");
                    _TriggerNextNode();
                    break;
            }
        }

        private void _OnCloseCallback()
        {
            if (_battle.rogue.GetExtraRollEntriesTime() <= 0)
            {
                _TriggerNextNode();
                return;
            }
            
            // DONE: 还有额外词条奖励领取次数, 则再次弹出词条界面进行选取.
            _battle.rogue.RollEntriesForExtraTimes(_closeCallback);
        }

        private void _TriggerNextNode()
        {
            EndAction(true);
            ForceTick();
        }
    }
}