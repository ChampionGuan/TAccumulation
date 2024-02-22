using System.Collections.Generic;
using PapeGames;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using X3;
using X3Battle.Timeline;
using X3Battle.Timeline.Extension;

namespace X3Battle
{
    public class TimelineResAnalyzer : ResAnalyzer
    {
        private string _timelinePath;
        private BattleResType _type;
        private BattleResTag _moduleTags; // 是否是属于爆衣timeline
        private BattleResTag _selfTags; // timeline自身Tag
        private bool _isPerform;  // 是否为表演
        
        public override int ResID { get; }
        
        public TimelineResAnalyzer(ResModule parent, string timelinePath, BattleResType type, bool isPerform, BattleResTag moduleTags = BattleResTag.Default, BattleResTag timelineTags = BattleResTag.Default) : base(parent)
        {
            _timelinePath = timelinePath;
            _type = type;
            _moduleTags = moduleTags;
            _selfTags = timelineTags;
            _isPerform = isPerform;
        }


        protected override void DirectAnalyze()
        {
            // 标记出，该模块统计出的资源属于爆衣前，需要卸载的资源
            resModule.AddTag(_moduleTags);
            
            resModule.moduleName = _timelinePath;
            
            resModule.AddResultByPath(_timelinePath, _type, tag: _selfTags);
            if (_type == BattleResType.Timeline)
            {
                AnalyzeFromLoadedRes<GameObject>(_timelinePath, _type, _AnalyzeTimelineObject, resModule);
            }
            else if (_type == BattleResType.TimelineAsset)
            {
                AnalyzeFromLoadedRes<TimelineAsset>(_timelinePath, _type, _AnalyzeTimelineAsset, resModule);
            }
        }
        
        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is TimelineResAnalyzer analyzer)
            {
                return analyzer._timelinePath == _timelinePath && analyzer._type == _type;
            }
            return false;
        }
        
        // timeline加载出来之后解析
        private void _AnalyzeTimelineObject(GameObject go, ResModule resModule)
        {
            if (go == null)
            {
                return;
            }

#if !UNITY_EDITOR
            // 字符串冗余处理 
            zstring.Init();
            go.name = zstring.Intern(go.name);
#endif
            
            // 解析timeline特效
            List<string> results = X3TimelineUtility.GetTimelineFxPaths(go, true);
            for (int i = 0; i < results.Count; i++)
            {
                resModule.AddResultByPath(results[i], BattleResType.TimelineFx);
            }

            // 解析timeline音频
            List<string> audioEvents = X3TimelineUtility.GetTimelineAudioEvents(go);
            if (audioEvents != null)
            {
                for (int i = 0; i < audioEvents.Count; i++)
                {
                    resModule.AddResultByPath(audioEvents[i], BattleResType.TimelineAudio);
                }
            }

            // 检测资源部是否有错误
            PlayableDirector director = go.GetComponent<PlayableDirector>();
            if (director == null || director.playOnAwake)
            {
                PapeGames.X3.LogProxy.LogError(string.Format("timeline资源有错误！{0} 保存时没有更到最新代码，请相关同学更到最新代码重新点击【保存特效】！",
                    go.name));
                return;
            }

            // 解析动作模组
            _AnalyzeTimelineAsset(director.playableAsset as TimelineAsset, resModule);
        }

        // timeline解析加载出来的Asset
        private void _AnalyzeTimelineAsset(TimelineAsset asset, ResModule resModule)
        {
            if (asset == null)
            {
                return;
            }
            
#if !UNITY_EDITOR
            // 处理冗余字符串
            zstring.Init();
            asset.name = zstring.Intern(asset.name);
            var tracks = asset.GetOutputTracks();
            foreach (var track in tracks)
            {
                // 处理Track本身数据
                track.name = zstring.Intern(track.name);
                
                // 处理Track上的ExtData数据
                var trackType = track.GetType();
                var fieldInfo = trackType.GetField("extData");
                if (fieldInfo != null)
                {
                    var extData = fieldInfo.GetValue(track);
                    if (extData != null && extData is TrackExtData trackExtData)
                    {
                        trackExtData.bindRecorderKey = zstring.Intern(trackExtData.bindRecorderKey);
                        trackExtData.topParentRecorderKey = zstring.Intern(trackExtData.topParentRecorderKey);
                        trackExtData.bindName = zstring.Intern(trackExtData.bindName);
                        trackExtData.bindPath = zstring.Intern(trackExtData.bindPath);
                        trackExtData.HookName = zstring.Intern(trackExtData.HookName);
                        trackExtData.TopParentName = zstring.Intern(trackExtData.TopParentName);
                        trackExtData.TopParentPath = zstring.Intern(trackExtData.TopParentPath);
                    }
                }

                // 处理clips数据
                var timelineClips = track.GetClipsArray();
                foreach (var timelineClip in timelineClips)
                {
                    timelineClip.displayName = zstring.Intern(timelineClip.displayName);
                    if (timelineClip.asset != null)
                    {
                        timelineClip.asset.name = zstring.Intern(timelineClip.asset.name);
                        
                        // 处理simpleAudioClip上配的eventName
                        if (timelineClip.asset is SimpleAudioPlayableClip simpleAudioPlayableClip)
                        {
                            simpleAudioPlayableClip.StopEventName = zstring.Intern(simpleAudioPlayableClip.StopEventName);
                        }
                    }
                }
            }
#endif
            
            // 解析动作模组
            _AnalyzerTimelineAction(resModule, asset);
        }
        
        // 解析动作模组
        private void _AnalyzerTimelineAction(ResModule resModule, TimelineAsset timelineAsset)
        {
            if (timelineAsset == null)
            {
                return;
            }

            var tracks = timelineAsset.GetOutputTracks();
            foreach (var track in tracks)
            {
                if (track is ActionTrack actionTrack)
                {
                    var timelineClips = actionTrack.GetClipsArray();
                    foreach (var timelineClip in timelineClips)
                    {
                        var clip = timelineClip.asset;
                        if (clip is CreateMissileAsset createMissile)
                        {
                            var missiles = createMissile.missiles;
                            // 解析创建子弹
                            foreach (var missile in missiles)
                            {
                                var missileAnalyze = new MissileAnalyzer(resModule, missile.missileID, true);
                                missileAnalyze.Analyze();
                            }
                        }
                        else if (clip is PlayPerformAsset playPerform)
                        {
                            // 解析爆发技播放表演 
                            _AnalyzePerform(resModule, playPerform.performID);
                        }
                        else if (clip is PlayProtectPerformAsset protectPerform)
                        {
                            // 解析升格表演 
                            _AnalyzePerform(resModule, protectPerform.performID);
                        }
                        else if (clip is CastBuffAsset castBuff)
                        {
                            // 这里解析释放Buff
                            if (castBuff.buffs != null)
                            {
                                foreach (var buff in castBuff.buffs)
                                {
                                    ResAnalyzeUtil.AnalyzeBuff(resModule, buff.bufId);
                                }
                            }
                        }
                        else if (clip is CreateItemAsset createItem)
                        {
                            ResAnalyzeUtil.AnalyzeItem(resModule, createItem.itemId);
                        }
                        else if (clip is SummonCreatureAsset summonCreature)
                        {
                            // 解析召唤物
                            var summonAnalyze = new SummonMonsterAnalyzer(resModule, summonCreature.summonId);
                            summonAnalyze.Analyze();
                        }
                        else if (clip is CreateMagicFieldAsset createMagicField)
                        {
                            // 解析创建法术场
                            var magicFieldAnalyze = new MagicFieldAnalyzer(resModule, createMagicField.magicFieldID);
                            magicFieldAnalyze.Analyze();
                        }
                        else if (clip is MagicFieldHitAsset magicFieldHit)
                        {
                            // 解析法术场hit
                            var haloAnalyzer = new HaloAnalyzer(resModule, magicFieldHit.haloID);
                            haloAnalyzer.Analyze();
                            ResAnalyzeUtil.AnalyzeDamageBox(resModule, magicFieldHit.damageBoxID);
                        }
                        else if (clip is CreateTriggerAsset createTrigger)
                        {
                            // 解析创建Trigger
                            var triggerAnalyzer = new TriggerAnalyzer(resModule, createTrigger.triggerID);
                            triggerAnalyzer.Analyze();
                        }
                        else if (clip is CastDamageBoxAsset castDamageBox)
                        {
                            // 解析创建伤害包围盒
                            var damageBoxAnalyze = new DamageBoxAnalyzer(resModule, castDamageBox.boxId);
                            damageBoxAnalyze.Analyze();
                        }
                        else if (clip is PlayWarnFxAsset playWarnFx)
                        {
                            // 解析预警特效
                            if (playWarnFx.warnEffectData != null)
                            {
                                resModule.AddResultByFxId(playWarnFx.warnEffectData.fxID);
                            }
                        }
                        else if (clip is DialogueAsset actionDialogue)
                        {
                            ResAnalyzeUtil.AnalyzeDialogSound(resModule, actionDialogue.keys);
                        }
                        else if (clip is PlayPPVAsset asset)
                        {
                            if (!string.IsNullOrEmpty(asset.path))
                            {
                                var analyzer = new TimelineResAnalyzer(resModule, asset.path, BattleResType.Timeline, false, timelineTags: BattleResTag.PPVTimeline);
                                analyzer.Analyze();
                            }
                        }
                        else if (clip is PlayStopFxAsset playFxSound)
                        {
                            // 解析特效音效
                            resModule.AddResultByFxId(playFxSound.fxCfgID);
                            resModule.AddResultByPath(playFxSound.soundEventName, BattleResType.ActorAudio);
                        }
                        else if (clip is CustomHideWeaponAsset customHideWeapon)
                        {
                            // 解析武器定制化隐藏特效音频
                            if (customHideWeapon.FadeOutFxs != null && customHideWeapon.FadeOutFxs.Length > 0)
                            {
                                foreach (var fxID in customHideWeapon.FadeOutFxs)
                                {
                                    resModule.AddResultByFxId(fxID);
                                }
                            }

                            if (!string.IsNullOrEmpty(customHideWeapon.FadeOutSound))
                            {
                                resModule.AddResultByPath(customHideWeapon.FadeOutSound, BattleResType.ActorAudio);
                            }

                            if (!string.IsNullOrEmpty(customHideWeapon.FadeOutMatAnim))
                            {
                                resModule.AddResultByPath(customHideWeapon.FadeOutMatAnim, BattleResType.MatCurveAsset);
                            }
                        }
                        else if (clip is PlayFootViewAsset footView)
                        {
                            // 运行时只分析需要的烟尘特效
                            var condition = new FootMoveFxAnalyze(footView.GroupID);
                            resModule.AddConditionAnalyze(condition);
                        }
                        else if (clip is BornTipUIAsset tipUI)
                        {
                            resModule.AddResultByPath("UIView_BattleMonsterInf", BattleResType.UI, 1);
                        }
                        else if (clip is ShadowActiveAsset shadowActive)
                        {
                            // 影子数据预加载
                            var path = shadowActive.shadowDataPath;
                            if (!string.IsNullOrEmpty(path))
                            {
                                resModule.AddResultByPath(path, BattleResType.ShadowData);
                            }
                        }
                        else if (clip is MagicFieldFxAsset magicFieldFx)
                        {
                            resModule.AddResultByFxId(magicFieldFx.fxID);
                        }
                        else if (clip is BornTimeScaleAsset bornTimeScale)
                        {
                            // 分析born的音频
                            resModule.AddResultByPath(bornTimeScale.eventName, BattleResType.TimelineAudio);
                        }
                        else if (clip is PlayFxAsset playFxAsset)
                        {
                            resModule.AddResultByFxId(playFxAsset.FxID);
                        }
                        else if (clip is PositionAndRotationAsset positionAndRotationAsset)
                        {
                            resModule.AddResultByFxId(positionAndRotationAsset.PreTransportFX);
                            resModule.AddResultByFxId(positionAndRotationAsset.PostTransportFX);
                        }
                    }
                }
                else if (track is ChangeWeaponTrack changeWeaponTrack)
                {
                    var timelineClips = changeWeaponTrack.GetClipsArray();
                    var extData = changeWeaponTrack.extData;
                    if (extData != null && timelineClips != null && timelineClips.Length > 0)
                    {
                        var isGirlSuit = BattleUtil.IsGirlSuit(extData.bindSuitID);
                        foreach (var timelineClip in timelineClips)
                        {
                            if (timelineClip.asset is ChangeWeaponClip changeWeaponClip)
                            {
                                string partName = changeWeaponClip.weaponPartName;
                                var analyze = new SkillWeaponPartsAnalyze(partName, isGirlSuit, _isPerform);
                                resModule.AddConditionAnalyze(analyze);
                            }
                        }
                    }
                }
                else if (track is ChangeSuitTrack changeSuitTrack)
                {
                    var extData = changeSuitTrack.extData;
                    if (extData != null)
                    {
                        var timelineClips = changeSuitTrack.GetClipsArray();
                        foreach (var timelineClip in timelineClips)
                        {
                            if (timelineClip.asset is ChangeSuitClip suitClip)
                            {
                                if (!suitClip.useOriginal)
                                {
                                    // TODO for 长空、付强 需要预分析
                                    // TODO for 老艾 预加载爆发技女主前需要用到该数据.
                                    // 不使用原始女主才需要分析
                                    // var targetSuitID = ChangeSuitUtil.GetUsingSuitID(suitClip.useOriginal, suitClip.targetSuitID, extData.bindSuitID);
                                    // var suitAnalyzer = new SuitResAnalyzer(targetSuitID, resModule);
                                    // suitAnalyzer.Analyze();   
                                    
                                }
                            }
                        }
                    }
                }
                else if (track is PhysicsWindTrack physicsWindTrack)
                {
                    var extData = physicsWindTrack.extData;
                    if (extData != null)
                    {
                        var timelineClips = physicsWindTrack.GetClipsArray();
                        foreach (var timelineClip in timelineClips)
                        {
                            if (timelineClip.asset is PhysicsWindDynamicClip physicsWindDynamicClip)
                            {
                                resModule.AddConditionAnalyze(new PhysicWindAnalyze(physicsWindDynamicClip.ID));
                            }
                        }
                    }
                }
                else if (track is LODTrack lodTrack)
                {
                    var extData = lodTrack.extData;
                    if (extData != null)
                    {
                        var timelineClips = lodTrack.GetClipsArray();
                        foreach (var timelineClip in timelineClips)
                        {
                            if (timelineClip.asset is LODClip lodClip)
                            {
                                bool isGirlSuit = BattleUtil.IsGirlSuit(extData.bindSuitID);
                                var lodUseType = LODUseType.HD;
                                int targetLOD = (int)BattleCharacterMgr.GetLOD(lodClip.LOD);
                                if (targetLOD == BattleCharacterMgr.LOD_LD)
                                {
                                    lodUseType = LODUseType.LDHD;
                                }

                                resModule.AddConditionAnalyze(new PerformLODAnalyze(isGirlSuit, lodUseType));
                            }
                        }
                    }
                }
                else if (track is AvatarTrack avatarTrack)
                {
                    var clipsCount = avatarTrack.GetClipsArray();
                    if (clipsCount != null && clipsCount.Length > 0)
                    {
                        var extData = avatarTrack.extData;
                        if (extData != null)
                        {
                            // 美术短期和中期设定：只有男主才会有分身，所以这里需要处理男主的分身预加载预分析
                            var bindType = BSTypeUtil.GetBindRoleTypeByTrackExtData(extData);
                            if (bindType == TrackBindRoleType.Male)
                            {
                                resModule.AddConditionAnalyze(new GhostHDAnalyze(false));
                            }
                        }
                    }
                }
            }
        }
        
        // 解析爆发技表演
        private static void _AnalyzePerform(ResModule resModule, int performID)
        {
            var performCfg = TbUtil.GetCfg<PerformConfig>(performID);
            if (performCfg != null)
            {
                // BattleUtil.AddPerformID(performID);
                var analyze = new PerformAnalyze(performID);
                resModule.AddConditionAnalyze(analyze);
                
                string performPath = performCfg.RelativePath;
                if (!string.IsNullOrEmpty(performPath))
                {
                    var analyzer = new TimelineResAnalyzer(resModule, performPath, BattleResType.Timeline, true);
                    analyzer.Analyze();
                }

                // 结束附加一个Timeline
                if (!string.IsNullOrEmpty(performCfg.EndEffectPath))
                {
                    var analyzer = new TimelineResAnalyzer(resModule, performCfg.EndEffectPath, BattleResType.Timeline, false);
                    analyzer.Analyze();
                }
            }
        }
    }
}