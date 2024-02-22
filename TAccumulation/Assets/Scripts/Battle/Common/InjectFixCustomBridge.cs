using System;
using System.Collections.Generic;
using EasyCharacterMovement;
using UnityEngine.Timeline;
using X3.CustomEvent;
using X3Battle.Timeline.Extension;

namespace X3Battle
{
    [IFix.CustomBridge]
    public static class AdditionalBridge
    {
        static List<Type> bridge = new List<Type>()
        {
            //delegate
            typeof(EventOnLoadRes),
            typeof(EventOnUnLoadRes),
            typeof(ColliderFilterCallback),
            typeof(CollisionBehaviorCallback),
            typeof(FoundGroundEventHandler),
            typeof(FinallySetWorldPosEventHandler),
            typeof(RMGridAgent.DelegateSeachPathBefore),
            
            //interface
            typeof(ILocomotionContext),
            typeof(IAICompositeAction),
            typeof(IAIGoalContext),
            typeof(IAIGoalParams),
            typeof(IAIActionGoal),
            typeof(IAIConditionGoal),
            typeof(IAttrModifier),
            typeof(IActorComponent),
            typeof(ActorMainState.IArg),
            typeof(ActorStateMatrix.IArg),
            typeof(IBattleClientBridge),
            typeof(IBattleLuaClient),
            typeof(IBattleLuaBridge),
            typeof(IDeltaTime),
            typeof(IUnscaledDeltaTime),
            typeof(IReset),
            typeof(IBattleComponent),
            typeof(IFrameUpdate),
            typeof(IBattleContext),
            typeof(IActorContext),
            typeof(IGraphCreater),
            typeof(IGraphLevel),
            typeof(IECComponent),
            typeof(IECEntity),
            typeof(IEventListener),
            typeof(IECObject),
            typeof(IRMAgent),
            typeof(IAnalyzeWithLevel),
            typeof(IAnalyzeWithGirl),
            typeof(IAnalyzeWithWeapon),
            typeof(IAnalyzeWithBoy),
            typeof(IAnalyzeWithWeaponBoy),
            typeof(IResLoader),
            typeof(IGetFxPlayer),
            typeof(IInterruptTrack),
            typeof(IPlayableInsInterface),
            typeof(IAction)
        };
    }
}