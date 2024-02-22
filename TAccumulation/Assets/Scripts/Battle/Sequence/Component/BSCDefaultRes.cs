using UnityEngine;

namespace X3Battle
{
    public class BSCDefaultRes : BSCBase, IReset
    {
        private bool _myLoadTimelineObj;
        private GameObject _resObj;

        public void Reset()
        {
            _myLoadTimelineObj = false;
            _resObj = null;
        }
        
        protected override void _OnInit()
        {
            this._myLoadTimelineObj = false; //  timelineObj由我加载出来
            // var timelineObj = _timeline.artObject;
            //  没有tiemlineObj就尝试使用路径加载
            // if (!timelineObj)
            {
                this._resObj = _context.LoadTimelineObject(_battleSequencer.bsCreateData.artResPath);
                // _timeline.artObject = _resObj;
                this._myLoadTimelineObj = true;
            }
        }

        protected override void _OnDestroy()
        {
            if (this._myLoadTimelineObj && this._resObj != null)
            {
                _context.UnloadGameObject(this._resObj);
            }
        }
    }
}