
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("获取获得的词条里某个tag的词条数量\nFAGetRogueEntriesNum")]
    public class FAGetRogueEntriesNum : FlowAction
    {
        public BBParameter<int> Tag = new BBParameter<int>();

        protected override void _OnRegisterPorts()
        {
            AddValueOutput<int>("result", () =>
            {
                var rogue = _battle.rogue;
                if (rogue == null)
                {
                    _LogError("当前不是Rogue模式，没有词条");
                    return 0;
                }

                int count = 0;
                var obtainRogueList = rogue.rogueEntriesLibrary.CurrentObtainEntriesList;
                foreach (var rogueEntry in obtainRogueList)
                {
                    if (rogueEntry.HasTag(Tag.value))
                    {
                        count++;
                    }
                }

                return count;
            });
        }
    }
}