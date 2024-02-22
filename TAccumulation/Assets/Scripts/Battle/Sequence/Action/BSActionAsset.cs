using System;
using X3Battle;
using X3Battle.Timeline.Extension;

namespace X3Battle
{
    public abstract class BSActionAsset : PreviewActionAsset
    {
        // 获取当前的 context
        protected new BSActionContext context
        {
            get
            {
                var curBattleContext = base.previewActionIContext as BSActionContext;
                return curBattleContext;
            }
        }
        public virtual BSAction CreatePlayable()
        {
            return null;
        }
    }

    public abstract class BSActionAsset<T> : BSActionAsset where T : BSAction, new()
    {
        public override BSAction CreatePlayable()
        {
            var playable = new T();
            return playable;
        }
    }
}