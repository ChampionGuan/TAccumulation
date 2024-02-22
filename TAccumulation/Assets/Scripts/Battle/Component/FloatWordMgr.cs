using System.Collections.Generic;
using PapeGames.X3UI;
using TMPro;
using UnityEngine;
using UnityEngine.Profiling;
using UnityEngine.UI;

namespace X3Battle
{
    public class FloatWordMgr : BattleComponent
    {
        private float _minCameraDistance;
        private float _maxCameraDistance;
        private float _minScale;
        private float _maxScale;
        private List<FloatWord> _words;
        private Transform _parent;
        private bool _paused;

        // 不显示飘字
        public bool dontShowFloatWord;

        public FloatWordMgr() : base(BattleComponentType.FloatWordMgr)
        {
            requiredPhysicalJobRunning = true;
        }
        
        protected override void OnStart()
        {
            _words = new List<FloatWord>();
            _paused = false;
            _minCameraDistance = TbUtil.battleConsts.FloatWordMinCameraDistance;
            _maxCameraDistance = TbUtil.battleConsts.FloatWordMaxCameraDistance;
            _minScale = TbUtil.battleConsts.FloatWordMinScale;
            _maxScale = TbUtil.battleConsts.FloatWordMaxScale;
            foreach (var resName in FloatWordDatas.resNames)
            {
                for (int i = 0; i < resName.Value; i++)
                {
                    FloatWord floatWord = _CreateWord(resName.Key);
                    _words.Add(floatWord);
                }
            }
            battle.eventMgr.AddListener<EventDamageInvalid>(EventType.OnDamageInvalid, _OnDamageInvalid, "FloatWordMgr._OnDamageInvalid");
            battle.eventMgr.AddListener<EventExportDamage>(EventType.ExportDamage, _OnDamage, "FloatWordMgr._OnDamage");
        }

        protected override void OnPhysicalJobRunning()
        {
            if (_paused)
            {
                return;
            }
            foreach (FloatWord floatWord in _words)
            {
                if (!floatWord.isUsed)
                {
                    continue;
                }
                if (floatWord.textChange)
                {
                    using (ProfilerDefine.FWorldSetFloatPMarker.Auto())
                    {
                        BattleUtil.SetFloatWordText(floatWord, floatWord.value, floatWord.isCure);
                    }

                    floatWord.textChange = false;
                }

                if (floatWord.isPlay)
                {
                    _PlayWord(floatWord);
                    floatWord.isPlay = false;
                }
                floatWord.elapsedTime -= battle.unscaledDeltaTime;
                if (floatWord.elapsedTime < 0)
                {
                    battle.ui.SetNodeVisible(floatWord.trans, false);
                    battle.ui.Stop(floatWord.montionInfo);
                    floatWord.isUsed = false;
                    continue;
                }
                if (BattleUtil.GetPositionIsInViewByPosition(floatWord.actorPos))
                {
                    BattleUtil.CalculateUIPosition(floatWord,_minCameraDistance, _maxCameraDistance,_minScale, _maxScale);
                }
                else
                {
                    battle.ui.SetNodeVisible(floatWord.trans, false);
                }
            }
        }

        public void SetParent(Transform parent)
        {
            _parent = parent;
            if (_words == null)
            {
                return;
            }
            foreach (FloatWord floatWord in _words)
            {
                floatWord.trans.SetParent(_parent, false);
            }
        }

        public void Pause(bool paused)
        {
            if (_paused == paused)
            {
                return;
            }

            _paused = paused;
            foreach (FloatWord floatWord in _words)
            {
                if (!floatWord.isUsed)
                {
                    continue;
                }

                if (_paused)
                {
                    battle.ui.Pause(floatWord.montionInfo);
                }
                else
                {
                    battle.ui.Resume(floatWord.montionInfo);
                }
            }
        }

        private FloatWord _GetWord(string resName)
        {
            foreach (FloatWord floatWord in _words)
            {
                if (floatWord.isUsed || floatWord.resName != resName)
                {
                    continue;
                }
                return floatWord;
            }
            FloatWord newFloatWord = _CreateWord(resName);
            _words.Add(newFloatWord);
            PapeGames.X3.LogProxy.Log($"战斗过程中新增飘字资源:{resName}");
            return newFloatWord;
        }

        private FloatWord _CreateWord(string resName)
        {
            GameObject go = BattleResMgr.Instance.Load<GameObject>(resName, BattleResType.DynamicUI);
            FloatWord floatWord = new FloatWord();
            floatWord.trans = go.GetComponent<RectTransform>();
            floatWord.trans.SetParent(_parent, false);
            Transform textTrans = floatWord.trans.Find("text_current");
            floatWord.textPro = textTrans.GetComponent<TextMeshProUGUI>();
            floatWord.text = textTrans.GetComponent<Text>();
            floatWord.richText = textTrans.GetComponent<RichText>();
            floatWord.resName = resName;
            if (resName == FloatWordDatas.Weak)
            {
                floatWord.horizontalRandom = TbUtil.battleConsts.FloatWordWeakHorizontalRandom;
                floatWord.verticalRandom = TbUtil.battleConsts.FloatWordWeakVerticalRandom;
            }
            else
            {
                floatWord.horizontalRandom = TbUtil.battleConsts.FloatWordHorizontalRandom;
                floatWord.verticalRandom = TbUtil.battleConsts.FloatWordVerticalRandom;
            }
            floatWord.value = 0;
            floatWord.isCure = resName == FloatWordDatas.Cure;
            floatWord.motionHandler = floatWord.trans.GetComponent<MotionHandler>();
            if (floatWord.motionHandler.GetItemWithIndex(0, out MotionHandler.MotionInfo motionInfo))
            {
                floatWord.length = motionInfo.Clip.length;
                floatWord.montionInfo = motionInfo;
            }
            else
            {
                floatWord.length = 0;
            }
            BattleUtil.SetFloatWordText(floatWord, 999999, false);
            battle.ui.SetNodeVisible(floatWord.trans, false);
            return floatWord;
        }

        private void _OnDamageInvalid(EventDamageInvalid eventDamageInvalid)
        {
            if (eventDamageInvalid.damageInvalidType == DamageInvalidType.DamageImmunity)
            {
                using (ProfilerDefine.FWorldDamageInvalidPMarker.Auto())
                {
                    bool result;
                    Vector3 hitPos;
                    Transform hitTrans;
                    using (ProfilerDefine.FWorldDamageInvalidCheckPMarker.Auto())
                    {
                        _CheckDamage(eventDamageInvalid.hitInfo, out result, out hitPos, out hitTrans);
                    }

                    if (!result)
                    {
                        return;
                    }

                    bool isExist = false;
                    string resName = FloatWordDatas.Text;
                    using (ProfilerDefine.FWorldDamageInvalidIsExistPMarker.Auto())
                    {
                        foreach (FloatWord word in _words)
                        {
                            if (!word.isUsed || word.resName != resName || word.actor != eventDamageInvalid.hitInfo.damageTarget)
                            {
                                continue;
                            }

                            isExist = true;
                            break;
                        }
                    }

                    if (!isExist)
                    {
                        FloatWord floatWord = _GetWord(resName);

                        floatWord.textChange = true;
                        floatWord.value = 0;

                        using (ProfilerDefine.FWorldDamageInvalidShowPMarker.Auto())
                        {
                            _ShowWord(floatWord, hitPos, hitTrans, eventDamageInvalid.hitInfo.damageTarget);
                        }
                    }
                }
            }
        }

        private void _CheckDamage(HitInfo hitInfo, out bool result, out Vector3 hitPos, out Transform hitTrans)
        {
            Actor hurtActor = hitInfo.damageTarget;
            if (!hitInfo.damageBoxCfg.IsShowFloatWord || hurtActor != null && hitInfo.damageTarget.transform != null && !hitInfo.damageTarget.transform.visibleSelf)
            {
                hitPos = default;
                result = false;
                hitTrans = null;
                return;
            }
            using (ProfilerDefine.FWorldDamageCheckGetActorDummyPMarker.Auto())
            {
                hitTrans = BattleUtil.GetActorDummy(hurtActor, DummyType.RenderPointPivot);
            }

            if (hitInfo.hitPoint.HasValue)
            {
                hitPos = hitInfo.hitPoint.Value;
            }
            else
            {
                hitPos = hitTrans.position;
            }
            result = true;
            //result = BattleUtil.GetPositionIsInViewByPosition(hitPos);
        }

        private void _OnDamage(EventExportDamage exportDamage)
        {
            if (dontShowFloatWord)
            {
                return;
            }

            using (ProfilerDefine.FWorldDamagePMarker.Auto())
            {
                bool result;
                Vector3 hitPos;
                Transform hitTrans;
                using (ProfilerDefine.FWorldDamageCheckPMarker.Auto())
                {
                    _CheckDamage(exportDamage.hitInfo, out result, out hitPos, out hitTrans);
                }

                if (!result)
                {
                    return;
                }

                string resName;
                float floatValue;
                using (ProfilerDefine.FWorldDamageResNamePMarker.Auto())
                {
                    FactionType playerFactionType = battle.player.factionType;
                    DamageType damageType = exportDamage.damageType;
                    if (damageType == DamageType.Sub && exportDamage.hurtFactionType == playerFactionType)
                    {
                        floatValue = -exportDamage.hurtDamage;
                    }
                    else
                    {
                        floatValue = exportDamage.hurtDamage;
                    }

                    if (damageType == DamageType.Add)
                    {
                        resName = FloatWordDatas.Cure;
                    }
                    else
                    {
                        if (!BattleUtil.IsEnemyOfPlayer(exportDamage.hitInfo.damageTarget))
                        {
                            resName = FloatWordDatas.Hurt;
                        }
                        else
                        {
                            if (exportDamage.hitInfo.damageTarget.actorWeak != null && exportDamage.hitInfo.damageTarget.actorWeak.weak)
                            {
                                resName = FloatWordDatas.Weak;
                            }
                            else if (exportDamage.hurtIsGirl)
                            {
                                if (exportDamage.hurtCritical)
                                {
                                    resName = FloatWordDatas.CriticalDamagePL;
                                }
                                else
                                {
                                    resName = FloatWordDatas.DamagePL;
                                }
                            }
                            else
                            {
                                resName = FloatWordDatas.DamageST;
                            }
                        }
                    }
                }

                int intValue = Mathf.RoundToInt(floatValue);
                if (intValue == 0)
                {
                    resName = FloatWordDatas.Text;
                }

                FloatWord floatWord = _GetWord(resName);
                floatWord.textChange = intValue == 0 || floatWord.value != intValue;
                floatWord.value = intValue;

                _ShowWord(floatWord, hitPos, hitTrans, exportDamage.hitInfo.damageTarget);
            }
        }

        private void _ShowWord(FloatWord floatWord, Vector3 hitPos, Transform hitTrans, Actor actor)
        {
            using (ProfilerDefine.FWorldShowPMarker.Auto())
            {
                float offsetX = floatWord.horizontalRandom * Random.Range(-1, 1f);
                float offsetZ = floatWord.horizontalRandom * Random.Range(-1, 1f);
                float offsetY = floatWord.verticalRandom * Random.Range(-1, 1f);
                Vector3 actorPos = hitTrans.position;
                Vector3 offset = hitPos - actorPos;
                floatWord.actor = actor;
                floatWord.actorPos = actorPos;
                floatWord.offsetX = offsetX + offset.x;
                floatWord.offsetY = offsetY + offset.y;
                floatWord.offsetZ = offsetZ + offset.z;
                floatWord.elapsedTime = floatWord.length;
                floatWord.isUsed = true;
                floatWord.isPlay = true;
            }
        }

        private void _PlayWord(FloatWord floatWord)
        {
            using (ProfilerDefine.FWorldPlayPMarker.Auto())
            {
                battle.ui.SetNodeVisible(floatWord.trans, true);
                battle.ui.Play(floatWord.montionInfo, floatWord.motionHandler.Animator, null, floatWord.trans.gameObject);
            }
        }

        public void UnloadUnusedRes()
        {
			foreach (FloatWord floatWord in _words)
            {
                if (floatWord.trans == null)
                {
                    continue;
                }
                BattleResMgr.Instance.Unload(floatWord.trans.gameObject);
            }
            _words.Clear();
        }
        
        protected override void OnDestroy()
        {
            battle.eventMgr.RemoveListener<EventDamageInvalid>(EventType.OnDamageInvalid, _OnDamageInvalid);
            battle.eventMgr.RemoveListener<EventExportDamage>(EventType.ExportDamage, _OnDamage);
            UnloadUnusedRes();
            _words = null;
            _parent = null;
        }
    }
}