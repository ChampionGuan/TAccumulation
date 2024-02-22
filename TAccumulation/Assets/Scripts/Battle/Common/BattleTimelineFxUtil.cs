using System;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using System.Reflection;
using PapeGames.X3;
using System.ComponentModel;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using X3Battle.Timeline;
using Debug = System.Diagnostics.Debug;

namespace X3Battle
{
    public class BattleTimelineFxUtil : Singleton<BattleTimelineFxUtil>
    {
        public BattleTimelineFxUtil()
        {
            // DONE: 初始化配置.
            TbUtil.Init();
        }
        
        //创建特定的timeline
        public List<PlayableDirector> CreateTimeline(int skillId, out List<GameObject> timelineObjects, out List<GameObject> timelineFxObjs)
        {
            timelineObjects = new List<GameObject>();
            timelineFxObjs = new List<GameObject>();
            List<PlayableDirector> directors = new List<PlayableDirector>();
            
            var skillCfg =  TbUtil.GetCfg<SkillCfg>(skillId);
            foreach (var actionModuleID in skillCfg.ActionModuleIDs)
            {
                var actionCfg = TbUtil.GetCfg<ActionModuleCfg>(actionModuleID);
                if (actionCfg == null)
                {
                    continue;
                }
                //加载timeline
                var obj = BattleResMgr.Instance.Load<GameObject>(actionCfg.ArtTimeline, BattleResType.Timeline);
                timelineObjects.Add(obj);

                var director = obj.GetComponent<PlayableDirector>();
                if (director.playableAsset != null)
                {
                    var timelineAsset = director.playableAsset as TimelineAsset;
                    var tracks = timelineAsset.GetOutputTracks();
                    foreach (var track in tracks)
                    {
                        if(track.isEmpty)
                            continue;

                        // if (!(track is ControlTrack))
                        // {
                        //     track.muted = true;
                        //     continue;
                        // }

                        var control = track as ControlTrack;
                        if (control == null)
                        {
                            continue;
                        }
                        
                        //加载特效 timelineFx
                        var objFx = BattleResMgr.Instance.Load<GameObject>(control.extData.bindPath, BattleResType.TimelineFx);
                        //重置fxplay
                        if (objFx == null)
                        {
                            continue;
                        }
                        var fxPlays = objFx.GetComponents<FxPlayer>();
                        foreach (var fxPlay in fxPlays)
                        {
                            fxPlay.Reinit();     
                        }
                        timelineFxObjs.Add(objFx);
                    }
                }
                
                directors.Add(director);
            }

            return directors;
        }

        public void PlaySkill(List<PlayableDirector> directors)
        {
            if (directors == null)
                return;
            
            foreach (var director in directors)
            {
                director.time = 0;
                director.timeUpdateMode = DirectorUpdateMode.GameTime;
                director.Stop();
                director.Play();
            }
        }

        public void DestorySkill(List<PlayableDirector> dirs, List<GameObject> timelineObjects, List<GameObject> timelineFxObjs,
            bool isDestroy = false)
        {
            if (timelineObjects == null || timelineFxObjs == null || dirs == null)
                return;

            foreach (var dir in dirs)
            {
                dir.Stop();
            }

            foreach (var fxObj in timelineFxObjs)
            {
                //重置fxplay
                var fxPlays = fxObj.GetComponents<FxPlayer>();
                foreach (var fxPlay in fxPlays)
                {
                    fxPlay.Stop();
                }
            }
            
            for (int i = 0; i < timelineObjects.Count; i++)
            {
                if (isDestroy)
                    BattleUtil.DestroyObj(timelineObjects[i]);
                else
                    BattleResMgr.Instance.Unload<GameObject>(timelineObjects[i]);
            }
            for (int i = 0; i < timelineFxObjs.Count; i++)
            {
                if (isDestroy)
                    BattleUtil.DestroyObj(timelineFxObjs[i]);
                else
                    BattleResMgr.Instance.Unload<GameObject>(timelineFxObjs[i]);
            }
        }
    }
}