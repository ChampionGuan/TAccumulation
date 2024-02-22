using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class HaloOwner : ActorComponent
    {
        private List<Halo> _haloes;
        private static int _sHaloID;

        public HaloOwner() : base(ActorComponentType.Halo)
        {
            _haloes = new List<Halo>(5);
        }

        /// <summary>
        /// 添加光环
        /// </summary>
        /// <param name="master"> 光环的主人 </param>
        /// <param name="haloConfigId"> 光环的配置ID </param>
        /// <param name="shapeBoxInfo"> 覆盖逻辑 </param>
        /// <param name="lifeTime"> 覆盖逻辑 </param>
        /// <returns> 该光环的战斗全局唯一ID (小于0的为无效ID) </returns>
        public int AddHalo(int haloConfigId, int level, ShapeBoxInfo shapeBoxInfo = null, float? lifeTime = null, DamageExporter casterExporter = null)
        {
            using (ProfilerDefine.HaloOwnerAddHaloPMarker.Auto())
            {
                if (haloConfigId == 0)
                {
                    return -1;
                }

                // DONE: 去查表.
                var haloCfg = TbUtil.GetCfg<HaloCfg>(haloConfigId);
                if (haloCfg == null)
                {
                    PapeGames.X3.LogProxy.LogError($"请联系策划【楚门】解决, 配了不存在的光环配置ID:{haloConfigId}, 导致添加光环失败");
                    return -1;
                }

                int insId = ++_sHaloID;
                var halo = ObjectPoolUtility.HaloPool.Get();
                halo.Init(insId, this.actor, haloCfg, level, shapeBoxInfo, lifeTime, casterExporter);
                _haloes.Add(halo);
                PapeGames.X3.LogProxy.Log($"[光环组件] Actor.InsID={this.actor.insID} 添加光环 InsId={insId}");
                return insId;
            }
        }

        /// <summary>
        /// 移除光环
        /// </summary>
        /// <param name="insId"> 光环的战斗全局唯一ID, 添加光环时返回的值 </param>
        /// <returns> 移除是否成功 </returns>
        public bool RemoveHalo(int insId)
        {
            using (ProfilerDefine.HaloOwnerRemoveHaloPMarker.Auto())
            {
                for (int i = 0; i < _haloes.Count; i++)
                {
                    if (_haloes[i].insID == insId)
                    {
                        bool isRemove = _RemoveHaloAt(i);
                        return isRemove;
                    }
                }

                return false;
            }
        }

        public List<Halo> GetAllHalo()
        {
            return _haloes;
        }

        protected override void OnUpdate()
        {
            for (int i = 0; i < _haloes.Count; i++)
            {
                // DONE: 触发器死亡移除.
                if (_haloes[i].isDestroy)
                {
                    if (_RemoveHaloAt(i))
                    {
                        i--;
                    }

                    continue;
                }

                _haloes[i].Update(this.actor.deltaTime);
            }
        }

        private bool _RemoveHaloAt(int index)
        {
            if (index < 0 || index >= _haloes.Count)
            {
                return false;
            }

            PapeGames.X3.LogProxy.Log($"[光环组件] Actor.InsID={this.actor.insID} 移除光环 InsId={_haloes[index].insID}");

            var halo = _haloes[index];
            halo.Destroy();
            ObjectPoolUtility.HaloPool.Release(halo);
            _haloes.RemoveAt(index);
            return true;
        }

        public override void OnDead()
        {
            for (int i = 0; i < _haloes.Count; i++)
            {
                if (_RemoveHaloAt(i))
                {
                    i--;
                }
            }

            _haloes.Clear();
        }
    }
}