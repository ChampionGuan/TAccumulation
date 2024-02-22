using System.Collections.Generic;
using PapeGames.X3;

namespace X3Battle
{
    public class DamageBoxGroup : IReset
    {
        public int ID { get; private set; }

        public List<DamageBox> damageBoxes { get; } = new List<DamageBox>(6);

        /// <summary> 角色命中次数信息, 当有新伤害盒进来时, 需要同步给新的DamageBox </summary>
        public Dictionary<Actor, int> hitActorTimesInfo { get; }= new Dictionary<Actor, int>(10);
        
        public void Init(int id)
        {
            this.ID = id;
            this.damageBoxes.Clear();
            this.hitActorTimesInfo.Clear();
        }
        
        public void Reset()
        {
            this.ID = 0;
            this.damageBoxes.Clear();
            this.hitActorTimesInfo.Clear();
        }

        // 当伤害盒被创建出来时，加入伤害组中
        public void AddBox(DamageBox damageBox)
        {
            if (damageBoxes.Contains(damageBox))
            {
                return;
            }

            damageBoxes.Add(damageBox);
            
            // DONE: 将DamageGroup组的命中信息同步至DamageBox.
            damageBox.InitHitTimes(hitActorTimesInfo);
            
        }

        public void RemoveBox(DamageBox damageBox)
        {
            damageBoxes.Remove(damageBox);
        }

        // 当组内一个盒子命中时，同步信息到其他盒子
        public void OnHitActorUpdateTimes(int damageBoxInsID, List<Actor> hitActors)
        {
            if (hitActors == null || hitActors.Count <= 0)
            {
                return;
            }
            
            if (damageBoxes == null || damageBoxes.Count <= 0)
            {
                return;
            }

            for (int i = 0; i < hitActors.Count; i++)
            {
                var hitActor = hitActors[i];
                
                // DONE: 将命中的信息记录下来.
                if (!hitActorTimesInfo.TryGetValue(hitActor, out int count))
                {
                    hitActorTimesInfo.Add(hitActor, 1);
                }
                else
                {
                    hitActorTimesInfo[hitActor] = count + 1;
                }
            }
            
            for (var i = 0; i < damageBoxes.Count; i++)
            {
                // DONE: 该伤害盒发起同步的所以不需要再同步.
                var damageBox = damageBoxes[i];
                if (damageBox.InsID == damageBoxInsID)
                {
                    continue;
                }

                _DebugLog("【打击盒组】同步前: ", damageBox, hitActors);
                damageBox.UpdateHitTimes(hitActors);
                _DebugLog("【打击盒组】同步后: ", damageBox, hitActors);
            }
        }


        private void _DebugLog(string str, DamageBox damageBox, List<Actor> hitActors)
        {
            for (var i = 0; i < hitActors.Count; i++)
            {
                var hitActor = hitActors[i];
                LogProxy.Log(str + "打击盒组ID: " + damageBox.GroupID + ", 打击盒InsID: " + damageBox.InsID +
                             ", 被命中者: " + hitActor.name + " 剩余命中次数: " + damageBox.GetCanHitTimes(hitActor) +
                             ", 最大命中次数: " + damageBox.GetLimitHitTimes());
            }
        }
    }
}