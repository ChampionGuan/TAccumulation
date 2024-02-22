using System.Collections.Generic;

namespace X3Battle
{
    public enum NotionGraphEventType
    {
        /// <summary>
        /// 开始过滤Actor事件
        /// </summary>
        FilterActorStart,
    }

    public class NotionEventFilterActorStart : NotionGraphEventDataBase
    {
        /// <summary> 待筛选列表 </summary>
        public List<Actor> beFilteredList { get; private set; }

        public void Init(List<Actor> list)
        {
            this.beFilteredList = list;
        }

        public override void OnRecycle()
        {
            beFilteredList = null;
        }
    }
}