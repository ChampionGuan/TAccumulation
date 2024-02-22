using System.Collections.Generic;
using UnityEngine.Profiling;

namespace X3Battle
{
    public partial class BuffOwner
    {
        /// <summary>
        /// 为目标添加buffs
        /// </summary>
        /// <param name="level"></param>
        /// <param name="target"></param>
        /// <param name="buffAddParams"></param>
        /// <param name="caster"></param>
        /// <param name="skillType"></param>
        public void CreateBuffs(int level, List<BuffAddParam> buffAddParams, Actor caster = null, DamageExporter damageExporter = null)
        {
            using (ProfilerDefine.BuffCreatePMarker.Auto())
            {
                if (buffAddParams != null && buffAddParams.Count > 0)
                {
                    for (int i = 0; i < buffAddParams.Count; i++)
                    {
                        var param = buffAddParams[i];
                        float? _duration = null;
                        int? _stack = null;
                        if (param.isOverrideDuration)
                        {
                            _duration = param.duration;
                        }

                        if (param.interrupted)
                        {
                            // 若关联时长，则把时长设为无限
                            _duration = -1;
                        }

                        if (param.isOverrideStack)
                        {
                            _stack = param.stackCount;
                        }

                        if (param.isOverrideLevel)
                        {
                            level = param.level;
                        }

                        this.Add(param.bufId, _stack, _duration, level, caster, damageExporter);
                    }
                }
            }
        }
        
        /// <summary>
        /// 为目标添加buffs
        /// </summary>
        /// <param name="level"></param>
        /// <param name="target"></param>
        /// <param name="buffAddParams"></param>
        /// <param name="caster"></param>
        /// <param name="skillType"></param>
        public void CreateBuffs(int level, List<NewBuffAddParam> buffAddParams, Actor caster = null, DamageExporter damageExporter = null)
        {
            using (ProfilerDefine.BuffCreatePMarker.Auto())
            {
                if (buffAddParams != null && buffAddParams.Count > 0)
                {
                    for (int i = 0; i < buffAddParams.Count; i++)
                    {
                        var param = buffAddParams[i];
                        float? _duration = null;
                        int? _stack = null;
                        if (param.isOverrideDuration.GetValue())
                        {
                            _duration = param.duration.GetValue();
                        }

                        if (param.interrupted.GetValue())
                        {
                            // 若关联时长，则把时长设为无限
                            _duration = -1;
                        }

                        if (param.isOverrideStack.GetValue())
                        {
                            _stack = param.stackCount.GetValue();
                        }

                        if (param.isOverrideLevel.GetValue())
                        {
                            level = param.level.GetValue();
                        }

                        this.Add(param.buffId.GetValue(), _stack, _duration, level, caster, damageExporter);
                    }
                }
            }
        }

        /// <summary>
        /// 移除目标身上的buffs
        /// </summary>
        /// <param name="target"></param>
        /// <param name="buffRemoveParams"></param>
        public void RemoveBuffs(List<NewBuffRemoveParam> buffRemoveParams)
        {
            using (ProfilerDefine.BuffRemovePMarker.Auto())
            {
                if (buffRemoveParams != null && buffRemoveParams.Count > 0)
                {
                    for (int i = 0; i < buffRemoveParams.Count; i++)
                    {
                        var param = buffRemoveParams[i];
                        if (!param.removeLayer.GetValue())
                        {
                            this.Remove(param.buffID.GetValue());
                        }
                        else
                        {
                            //TODO,策划着急的需求，后续用工具刷
                            this.ReduceStack(param.buffID.GetValue(), param.layer.GetValue());
                        }
                    }
                }
            }
        }
        
    }
}