using System.Collections.Generic;
using UnityEngine.Timeline;

namespace X3Battle
{
    // BSType BS类型
    public enum BSType
    {
        Mainline, //  主线
        BattleActor, //  战斗人物释放
        BattlePerform, //  战斗Client释放表演
        BattleSceneEffect, //  战斗直接放在场景中的BS（不绑定任何人物）
        BattleAnimator, //  Animator中的State绑定的BS
        BattleBornPerformCamera, // 战斗出生表演含镜头.
        BattleSkill,  // 战斗技能
        BattlePPV,
    }

    // BSState tiemline生命周期状态
    public enum BSState
    {
        Created, //  创建后Build之前
        Builded, //  build后播放前
        Playing, //  播放中
        FinishHold,  // 播放完hold状态（大部分BS不需要hold）
        Stop,  // 结束中
        Destroy, //  已销毁
    }

    // BSFeatureType BSFeature类型
    public enum BSComponentType
    {
        BattleRes, //  战斗资源加载
        MainlineRes, //  主线资源加载
        Perform, //  战斗表演特殊逻辑
        // MaterialAnim, //  材质动画逻辑（从BSBuild材质节点，挂到人物树上）
        TrackBind, //  动态绑定轨道对象处理
        ActorAnim, //  处理主Animation轨道转调ActorAniamtor.playAnim逻辑
        ControlCamera, // 战斗控制镜头显示隐藏
        Clock,  // 时间feature 
        Skill,  // 技能feature
        SceneEffect, // 战斗表演结束的场景特效表演
        BattleActor, // 处理战斗相关环境feature
    }

    public static class BSTypeUtil
    {
        // BSType2Features BS类型对应的feature列表。不同类型的BS会挂载不同Feature
        public static readonly Dictionary<BSType, BSComponentType[]> BSType2Features =
            new Dictionary<BSType, BSComponentType[]>()
            {
                {
                    BSType.Mainline, new[]
                    {
                        BSComponentType.MainlineRes,
                        BSComponentType.Clock,
                        BSComponentType.TrackBind,
                        // BSComType.MaterialAnim,
                    }
                },
                {
                    BSType.BattleActor, new[]
                    {
                        BSComponentType.BattleActor,  // 这个feature放到最上面
                        BSComponentType.BattleRes,
                        BSComponentType.Clock,
                        BSComponentType.TrackBind,
                        // BSComType.MaterialAnim,
                        BSComponentType.ActorAnim,
                    }
                },
                {
                    BSType.BattlePerform, new[]
                    {
                        BSComponentType.BattleRes,
                        BSComponentType.Clock,
                        BSComponentType.Perform,
                        BSComponentType.TrackBind,
                    }
                },
                {
                    BSType.BattleSceneEffect, new[]
                    {
                        BSComponentType.BattleRes,
                        BSComponentType.Clock,
                        BSComponentType.SceneEffect,
                        BSComponentType.TrackBind,
                    }
                },
                {
                    BSType.BattleAnimator, new[]
                    {
                        BSComponentType.BattleRes,
                        BSComponentType.Clock,
                        BSComponentType.TrackBind,
                    }
                },
                {
                    BSType.BattleBornPerformCamera, new[]
                    {
                        BSComponentType.BattleRes,
                        BSComponentType.Clock,
                        BSComponentType.TrackBind,
                        // BSComType.MaterialAnim,
                        BSComponentType.ActorAnim,
                        BSComponentType.ControlCamera,
                    }
                },
                {
                    BSType.BattleSkill, new[]
                    {
                        BSComponentType.Skill,  // 这个feature放到最上面
                        BSComponentType.BattleRes,
                        BSComponentType.Clock,
                        BSComponentType.TrackBind,
                        // BSComType.MaterialAnim,
                        BSComponentType.ActorAnim,
                        BSComponentType.ControlCamera,
                    }
                },
                {
                    BSType.BattlePPV, new[]
                    {
                        BSComponentType.BattleRes,
                        BSComponentType.Clock,
                        BSComponentType.TrackBind,  // TODO 长空 考虑把相机移到Camera中，这样可以去掉TrackBind
                    }
                }
            };

        // 创建BSFeature
        public static BSCBase CreateFeature(BSComponentType type)
        {
            BSCBase feature = null;
            if (type == BSComponentType.Clock)
            {
                feature = ObjectPoolUtility.ClockCom.Get();
            }
            else if (type == BSComponentType.BattleRes)
            {
                feature = ObjectPoolUtility.BattleResCom.Get();
            }
            else if (type == BSComponentType.MainlineRes)
            {
                feature = ObjectPoolUtility.MainlineResCom.Get();
            }
            else if (type == BSComponentType.Perform)
            {
                feature = ObjectPoolUtility.BattlePerformCom.Get();
            }
            // else if (type == BSComType.MaterialAnim)
            // {
            //     feature = ObjectPoolUtility.MaterialAnimCom.Get();
            // }
            else if (type == BSComponentType.TrackBind)
            {
                feature = ObjectPoolUtility.TrackBindCom.Get();
            }
            else if (type == BSComponentType.ActorAnim)
            {
                feature = ObjectPoolUtility.BattleActorAnimCom.Get();
            }
            else if (type == BSComponentType.ControlCamera)
            {
                feature = ObjectPoolUtility.BattleControlCameraCom.Get();
            }
            else if (type == BSComponentType.Skill)
            {
                feature = ObjectPoolUtility.BattleSkillCom.Get();
            }
            else if (type == BSComponentType.SceneEffect)
            {
                feature = ObjectPoolUtility.BattleSceneEffectCom.Get();
            }
            else if (type == BSComponentType.BattleActor)
            {
                feature = ObjectPoolUtility.BattleActorCom.Get();
            }
            else
            {
                feature = new BSCBase();
            }
            return feature;
        }

        // TODO ifElse 太多了，后面考虑优化一下
        // 销毁feature
        public static void DestroyFeature(BSCBase feature)
        {
            feature.Destroy();
            if (feature is BSCClock clock)
            {
                ObjectPoolUtility.ClockCom.Release(clock);         
            }
            else if (feature is BSCRes battleRes)
            {
                ObjectPoolUtility.BattleResCom.Release(battleRes);            
            }
            else if (feature is BSCDefaultRes mainlineRes)
            {
                ObjectPoolUtility.MainlineResCom.Release(mainlineRes);      
            }
            else if (feature is BSCPerform battlePerform)
            {
                ObjectPoolUtility.BattlePerformCom.Release(battlePerform);
            }
            // else if (feature is MaterialAnimCom materialAnim)
            // {
            //     ObjectPoolUtility.MaterialAnimCom.Release(materialAnim);   
            // }
            else if (feature is BSCTrackBind trackBind)
            {
                ObjectPoolUtility.TrackBindCom.Release(trackBind);
            }
            else if (feature is BSCActorAnim battleActor)
            {
                ObjectPoolUtility.BattleActorAnimCom.Release(battleActor);
            }
            else if (feature is BSCControlCamera battleControl)
            {
                ObjectPoolUtility.BattleControlCameraCom.Release(battleControl);
            }
            else if (feature is BSCSkill battleSkillFeature)
            {
                ObjectPoolUtility.BattleSkillCom.Release(battleSkillFeature);
            }
            else if (feature is BSCSceneEffect battleSceneEffectFeature)
            {
                ObjectPoolUtility.BattleSceneEffectCom.Release(battleSceneEffectFeature);
            }
            else if (feature is BSCActor bindBattleCom)
            {
                ObjectPoolUtility.BattleActorCom.Release(bindBattleCom);
            }
        }

        // 通过绑定信息获取人物类型(特效轨道)
        public static TrackBindRoleType GetBindRoleTypeByTrackExtData(TrackExtData trackExtData)
        {
            if (trackExtData.trackType != TrackExtType.Default && trackExtData.trackType != TrackExtType.HookEffect &&
                trackExtData.trackType != TrackExtType.CreatureAnim)
            {
                return TrackBindRoleType.None;
            }
            
            if (!BattleUtil.IsSuit(trackExtData.bindSuitID))
            {
                if ((trackExtData.trackType == TrackExtType.Default || trackExtData.trackType == TrackExtType.CreatureAnim) && !string.IsNullOrEmpty(trackExtData.bindPath))
                {
                    return TrackBindRoleType.Monster;
                }
                else if (trackExtData.trackType == TrackExtType.HookEffect && !string.IsNullOrEmpty(trackExtData.TopParentPath))
                {
                    return TrackBindRoleType.Monster;
                }
            }
            
            if (BattleUtil.IsGirlSuit(trackExtData.bindSuitID))
            {
                return TrackBindRoleType.Female;
            }

            return TrackBindRoleType.Male;
        }
    }


    public enum TrackBindRoleType
    {
        None = 0,
        Female = 1, //  女主
        Male = 2, //  男主
        Monster = 3, //  怪物
    }
}