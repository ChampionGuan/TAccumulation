using UnityEngine;

namespace X3Battle
{
    // 目前只在编辑器下使用，让美术可以运行时编辑，也方便预览当前信息
    public class ShadowEditorController : MonoBehaviour
    {
        private ActorShadowPlayer _player;
        public ActorShadowPlayer player => _player;

        public void SetShadowPlayer(ActorShadowPlayer player)
        {
            _player = player;
        }
    }
}



















