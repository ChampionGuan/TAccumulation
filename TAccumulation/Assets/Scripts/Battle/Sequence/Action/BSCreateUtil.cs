using System;
using System.Collections.Generic;
using PapeGames;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using X3Sequence;
using X3Sequence.Timeline;

namespace X3Battle
{
    public static class BSCreateUtil
    {
        private static SequenceCreator _creator = new SequenceCreator(new Dictionary<Type, CreatorItemBase[]>()
        {
            // Animation轨道
            {
                typeof(AnimationTrack), new []
                {
                    new MixerActionCreatorItem<ActionAnimMixer>(true),
                }
            },
            
            // SubsystemControl轨道
            {
                typeof(SubSystemControlTrack), new CreatorItemBase[]
                {
                    new ClipActionCreatorItem<SubSystemControlClip, ActionSubSystemControl>(true),
                    new ClipActionCreatorItem<AnimDBMixClip, ActionAnimDBMix>(true),
                    new ClipActionCreatorItem<PhysicsVelocityThresholdClip, ActionPhysicsVelocityThreshold>(true),
                    new ClipActionCreatorItem<DBFreezeClip, ActionDBFreeze>(true),
                }
            },
            // ActorOperationTrack
            {
                typeof(ActorOperationTrack), new []
                {
                    new ClipActionCreatorItem<ActorSetStencilClip, ActionActorSetStencil>(true),
                }
            },
            //SimpleAudioTrack
            {
                typeof(SimpleAudioTrack), new []
                {
                    new ClipActionCreatorItem<SimpleAudioPlayableClip, ActionSimpleAudio>(false),
                }
            },
            // VisibilityTrack
            {
                typeof(VisibilityTrack), new []
                {
                    new ClipActionCreatorItem<VisibilityClip, ActionVisibility>(true),
                }
            },
            // TransformOperationTrack
            {
                typeof(TransformOperationTrack), new []
                {
                    new ClipActionCreatorItem<TransformOperationClip, ActionTransformOperation>(false),
                }
            },
            // PhysicsWindTrack
            {
                typeof(PhysicsWindTrack), new CreatorItemBase[]
                {
                    new ClipActionCreatorItem<PhysicsWindPlayableAsset, ActionStaticWind>(true),
                    new ClipActionCreatorItem<PhysicsWindDynamicClip, ActionDynamicWind>(true),
                }
            },
            // ControlTrack
            {
                typeof(ControlTrack), new CreatorItemBase[]
                {
                    new ClipActionCreatorItem<ControlPlayableAsset, ActionFxVisible>(false),
                    new ClipActionCreatorItem<ControlPlayableAsset, ActionFxDetach>(false),
                    new ClipActionCreatorItem<ControlPlayableAsset, ActionFxPlayer>(false),
                    new ClipActionCreatorItem<ControlPlayableAsset, ActionFxFollowPos>(false),
                }
            },
            {
                typeof(CameraMixingTrack), new[]
                {
                    new MixerActionCreatorItem<ActionCinemachineMixer>(true),
                }
            },
            //AvatarTrack 
            {
                typeof(AvatarTrack), new[]
                {
                    new ClipActionCreatorItem<AvatarClip, ActionAvatar>(true),
                }
            },
            //GhostTrack 
            {
                typeof(GhostTrack), new[]
                {
                    new ClipActionCreatorItem<GhostClip, ActionGhost>(true),
                }
            },
            //ChangeSuitTrack 
             {
                 typeof(ChangeSuitTrack), new[]
                 {
                     new ClipActionCreatorItem<ChangeSuitClip, ActionChangeSuit>(true),
                 }
             },
            //changeWeaponTrack
             {
                 typeof(ChangeWeaponTrack), new[]
                 {
                     new ClipActionCreatorItem<ChangeWeaponClip, ActionChangeWeapon>(true),
                 }
             },
            //lodTrack
             {
                 typeof(LODTrack), new[]
                 {
                     new ClipActionCreatorItem<LODClip, ActionLod>(true),
                 }
             },
            //curveAnimTrack
             {
                 typeof(CurveAnimTrack), new[]
                 {
                     new ClipActionCreatorItem<CurveAnimPlayableAsset, ActionCurveAnim>(false),
                 }
             },
        });

        // 对外接口，解析timelineAsset，创建一些Action到Sequencer上
        public static void TryBuildTrackActions(Sequencer sequencer, PlayableDirector director,
            TimelineAsset timelineAsset, BSActionContext bsActionContext, BattleSequencer battleSequencer)
        {
            _creator.TryBuildTrackActions(sequencer, director, timelineAsset, (action, trackAsset, clipAsset, trackBindObj) =>
            {
                if (action is BSAction battleAction)
                {
                    battleAction.SetBattleData(null, bsActionContext, battleSequencer);
                    battleAction.SetArtData(timelineAsset, trackAsset, clipAsset, trackBindObj);
                }
            });
        }
    }
}