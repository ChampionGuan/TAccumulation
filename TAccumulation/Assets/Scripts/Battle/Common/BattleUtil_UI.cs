using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using UnityEngine;
using Framework;
using PapeGames.X3;
using PapeGames.X3UI;
using UnityEngine.Profiling;

namespace X3Battle
{
    public static partial class BattleUtil
    {
        class GuideData
        {
            public bool state;
            public bool result;

            public bool CalculateResult(Vector3 a, Vector3 b, Vector3 forward)
            {
                if (!state)
                {
                    result = Vector3.Dot(Vector3.Cross(a, b), forward) > 0;
                    state = true;
                }
                return result;
            }
        }
        
        private static Camera _uiCamera;
        private static Camera _mainCamera;
        private static RectTransform _uiRoot;

        private static GuideData[] _guideDatas =
        {
            new GuideData {state = false, result = false},
            new GuideData {state = false, result = false},
            new GuideData {state = false, result = false},
            new GuideData {state = false, result = false}
        };

        public static float ScreenWidth => UIRoot.rect.size.x;
        public static float ScreenHeight => UIRoot.rect.size.y;
        public static Camera UICamera => _uiCamera ?? (_uiCamera = BattleEnv.ClientBridge?.GetUICamera());
        public static Camera MainCamera => _mainCamera ?? (_mainCamera = BattleEnv.ClientBridge?.GetMainCamera());
        public static RectTransform UIRoot => _uiRoot ?? (_uiRoot = BattleEnv.ClientBridge?.GetUIRoot());

        public static int GetGuideActorSuitId(int actorType)
        {
            Actor actor = actorType == (int) ActorIDType.Girl ? Battle.Instance.player : Battle.Instance.actorMgr.boy;
            if (actor == null)
            {
                return 0;
            }

            return actor.suitID;
        }
        
        public static bool IsSendEventToUI(EventType type, ECEventDataBase arg)
        {
            if (Battle.Instance.status == BattleRunStatus.Ready)
            {
                if (type == EventType.Actor && arg is EventActor)
                {
                    EventActor eventActor = arg as EventActor;
                    if (eventActor.actor.type == ActorType.Hero)
                    {
                        return eventActor.state == ActorLifeStateType.Born;
                    }
                }
                return false;
            }
            // DONE: 处于该列表内的事件类型才能发往Lua层.
            if (!EventDefine.LuaUseEvents.Contains(type))
            {
                return false;
            }

            if (type == EventType.Actor && arg is EventActor)
            {
                Actor actor = (arg as EventActor).actor;
                return actor.type == ActorType.Hero || actor.type == ActorType.Monster || actor.type == ActorType.Item && actor.bornCfg.IsShowArrowIcon;
            }

            if (type == EventType.ActorFrozen && arg is EventActorFrozen info)
            {
                return info.actor == info.actor.battle.player;
            }

            return true;
        }

        public static void SetMissionTipsVisible(ShowMissionTipsType missionTipsType, int id, int slot = 0, Arithmetic operation = 0, float value = 0)
        {
            var guideConfig = TbUtil.GetCfg<BattleGuide>(id);
            if (guideConfig == null || guideConfig.Type != (int)TipType.RightLevelTarget && guideConfig.Type != (int)TipType.RightLevelTarget2 && guideConfig.Type != (int)TipType.CenterTip)
            {
                return;
            }
            var eventData = Battle.Instance.eventMgr.GetEvent<EventShowMissionTips>();
            eventData.Init(id, missionTipsType,slot,operation,value);
            Battle.Instance.eventMgr.Dispatch(EventType.ShowMissionTips, eventData);
        }
        
        public static SkillSlot GetSkillSlot(Actor actor, PlayerBtnType btnType)
        {
            var slotId = actor.skillOwner.TryGetCurSlotID(btnType, PlayerBtnStateType.Down);
            if (slotId == null)
            {
                return null;
            }
            SkillSlot slot = actor.skillOwner.GetSkillSlot(slotId.Value);
            return slot;
        }

        public static string GetSkillLevelDetailDesc(int skillId)
        {
            SkillLevelCfg levelCfg = TbUtil.GetSkillLevelCfg(skillId, 1);
            if (levelCfg == null)
            {
                return default;
            }
            string detailDesc = BattleEnv.LuaBridge.GetUIText(levelCfg.DetailDesc);
            if (levelCfg.DetaulDescParam == null || levelCfg.DetaulDescParam.Length == 0)
            {
                return detailDesc;
            }

            try
            {
                if (Battle.Instance != null)
                {
                    //战斗内专用
                    using (zstring.Block())
                    {
                        detailDesc = zstring.Format(detailDesc, levelCfg.DetaulDescParam);
                    }

                    return detailDesc;
                }

                return string.Format(detailDesc, levelCfg.DetaulDescParam);
            }
            catch (FormatException e)
            {
                LogProxy.LogError("技能描述配置，参数个数错误！");
                return "error! FormatException";
            }
        }
        
        //战斗内为了不传递字符串到lua
        public static void SetSkillLevelDetailDesc(Transform textTransform, int skillId)
        {
            SkillLevelCfg levelCfg = TbUtil.GetSkillLevelCfg(skillId, 1);
            if (levelCfg == null)
            {
                return;
            }
            string detailDesc = BattleEnv.ClientBridge.GetUIText(levelCfg.DetailDesc);
            if (levelCfg.DetaulDescParam != null && levelCfg.DetaulDescParam.Length > 0)
            {
                using (zstring.Block())
                {
                    detailDesc = zstring.Format(detailDesc, levelCfg.DetaulDescParam);
                }
            }
            UICompUtility.SetText(textTransform, detailDesc);
        }

        public static void SetBossHudNumText(TMPro.TextMeshProUGUI timerText, float value)
        {
            if (timerText == null)
            {
                return;
            }

            using (zstring.Block())
            {
                zstring strs = (zstring) (int) value;
                timerText.text = strs.Intern();
            }
        }

        /// <summary>
        /// 设置文本
        /// </summary>
        /// <param name="timerText"></param> UI组件
        /// <param name="value"></param> 设置值
        /// <param name="rounding"></param> 是否取整
        public static void SetTextByFloat(TMPro.TextMeshProUGUI timerText, float value, bool rounding = false)
        {
            if (timerText == null)
            {
                return;
            }

            using (zstring.Block())
            {
                zstring strs;
                if (value >= 1 || rounding)
                {
                    strs = (int) value;
                }
                else
                {
                    strs = zstring.FloatToZstring(value, 1);
                }

                timerText.text = strs.Intern();
            }
        }

        public static void SetTimerText(TMPro.TextMeshProUGUI timerText, float seconds)
        {
            if (timerText == null)
            {
                return;
            }

            using (zstring.Block())
            {
                int secondsInt = Mathf.RoundToInt(seconds);
                int second = secondsInt % 60;
                int minute = secondsInt / 60;
                zstring strs;
                if (second >= 10 && minute < 10)
                {
                    strs = zstring.Format("0{0}:{1}", minute, second);
                }
                else if (second < 10 && minute < 10)
                {
                    strs = zstring.Format("0{0}:0{1}", minute, second);
                }
                else if (second >= 10 && minute >= 10)
                {
                    strs = zstring.Format("{0}:{1}", minute, second);
                }
                else
                {
                    strs = zstring.Format("{0}:0{1}", minute, second);
                }

                timerText.text = strs.Intern();
            }
        }

        public static void SetCountDownText(TMPro.TextMeshProUGUI countdown, float time)
        {
            if (countdown == null)
            {
                return;
            }

            using (zstring.Block())
            {
                zstring strs = Mathf.RoundToInt(time);
                countdown.text = strs.Intern();
            }
        }

        // TODO 沧澜，建议改成RewritingString，不会有池扩容问题，性能更好
        public static void SetFloatWordText(FloatWord floatWord, int damageValue, bool isCure)
        {
            if (floatWord == null)
            {
                return;
            }

            using (zstring.Block())
            {
                zstring strs;
                if (damageValue == 0)
                {
                    strs = BattleEnv.invalidText;
                }
                else
                {
                    if (isCure)
                    {
                        strs = (zstring)"+" + damageValue;
                    }
                    else
                    {
                        strs = damageValue;
                    }
                }
                
                string text = strs.Intern();
                if (floatWord.richText != null)
                {
                    floatWord.richText.text = text;
                }
                else if (floatWord.textPro != null)
                {
                    floatWord.textPro.text = text;
                }
                else if (floatWord.text != null)
                {
                    floatWord.text.text = text;
                }
            }
        }

        /// <summary>
        /// 取怪物图标
        /// </summary>
        /// <returns></returns>
        public static string GetActorBossIcon()
        {
            var cfgs = Battle.Instance.actorMgr.stageConfig.SpawnPoints;
            foreach (var cfg in cfgs)
            {
                if (!TbUtil.TryGetCfg(cfg.ConfigID, out ActorCfg actorCfg))
                {
                    continue;
                }

                if (actorCfg.Type == ActorType.Monster && actorCfg.SubType == (int) MonsterType.Boss)
                {
                    return actorCfg.IconName;
                }
            }

            return default;
        }

        /// <summary>
        /// 获取HUD所需个数
        /// </summary>
        /// <returns></returns>
        public static int GetHeadHudCount()
        {
            var count = 0;
            var cfgs = Battle.Instance.actorMgr.stageConfig.SpawnPoints;
            foreach (var cfg in cfgs)
            {
                if (!TbUtil.TryGetCfg(cfg.ConfigID, out ActorCfg actorCfg) || actorCfg.Type != ActorType.Monster)
                {
                    continue;
                }

                if (cfg.HudControl)
                {
                    if (cfg.HudIsHead)
                    {
                        count++;
                    }
                }
                else if (!(actorCfg.SubType == (int) MonsterType.Boss || actorCfg.SubType == (int) MonsterType.Elite))
                {
                    count++;
                }
            }

            if (count > Battle.Instance.ui.monsterCoexistNumLimit)
            {
                count = Battle.Instance.ui.monsterCoexistNumLimit;
            }

            return count;
        }

        /// <summary>
        /// 设置Transform的Scale值
        /// </summary>
        public static void SetScale(Transform trans, float scale)
        {
            if (trans == null)
                return;
            trans.localScale = new Vector3(scale, scale, scale);
        }

        /// <summary>
        /// 设置Transform的localPositionX值
        /// </summary>
        public static void SetLocalPosX(Transform trans, float x)
        {
            if (trans == null)
                return;
            Vector3 pos = trans.localPosition;
            pos.x = x;
            trans.localPosition = pos;
        }

        /// <summary>
        /// 设置Transform的localPositionY值
        /// </summary>
        public static void SetLocalPosY(Transform trans, float y)
        {
            if (trans == null)
                return;
            Vector3 pos = trans.localPosition;
            pos.y = y;
            trans.localPosition = pos;
        }

        /// <summary>
        /// 设置Transform的localPositionZ值
        /// </summary>
        public static void SetLocalPosZ(Transform trans, float z)
        {
            if (trans == null)
                return;
            Vector3 pos = trans.localPosition;
            pos.z = z;
            trans.localPosition = pos;
        }

        public static void SetSizeDeltaX(RectTransform trans, float x)
        {
            Vector2 size = trans.sizeDelta;
            size.x = x;
            trans.sizeDelta = size;
        }

        /// <summary>
        /// 设置所有战斗UI和飘字 显隐性
        /// </summary>
        /// <param name="active"></param>
        public static void SetUIActive(bool active, bool evalSelectFX = true)
        {
            if (Battle.Instance == null)
            {
                return;
            }

            SetLevelBeforeUIActive(active, evalSelectFX);
        }

        /// <summary>
        /// 关卡前流程专用接口
        /// </summary>
        /// <param name="active"></param>
        /// <param name="evalSelectFX"></param>
        /// <param name="setTouchEnable"></param>
        public static void SetLevelBeforeUIActive(bool active, bool evalSelectFX = true)
        {
            if (evalSelectFX)
            {
                using (ProfilerDefine.UtilBattleUIActive1PMarker.Auto())
                {
                    Battle.Instance.playerSelectFx.SetFxActive(active);
                }
            }

            using (ProfilerDefine.UtilBattleUIActive2PMarker.Auto())
            {
                Battle.Instance.ui.SetAllWindowsVisible(active);
            }
        }

        /// <summary>
        /// 计算UI位置
        /// </summary>
        /// <param name="floatWord"></param>
        /// <param name="minCameraDistance"></param>
        /// <param name="maxCameraDistance"></param>
        /// <param name="minScale"></param>
        /// <param name="maxScale"></param>
        public static void CalculateUIPosition(FloatWord floatWord, float minCameraDistance, float maxCameraDistance, float minScale, float maxScale)
        {
            if (floatWord.trans == null)
            {
                return;
            }

            Vector3 worldPosition = floatWord.actorPos +  new Vector3(floatWord.offsetX, floatWord.offsetY, floatWord.offsetZ);
            Vector2 viewPos =  _GetViewPos(worldPosition, 0, null, out bool isBack);

            // 计算大小
            float distance = Vector3.Distance(worldPosition, MainCamera.transform.position);
            float currentScale;
            if (distance <= minCameraDistance)
            {
                currentScale = maxScale;
            }
            else if (distance >= maxCameraDistance)
            {
                currentScale = minScale;
            }
            else
            {
                currentScale = Mathf.Lerp(maxScale, minScale, (distance - minCameraDistance) / (maxCameraDistance - minCameraDistance));
            }

            floatWord.trans.localScale = Vector3.one * currentScale;
            floatWord.trans.localPosition = viewPos;
        }

        private static Vector2 _GetViewPos(Vector3 worldPosition, float height, RectTransform uiParent, out bool isBack)
        {
            worldPosition.y += height;
            if (uiParent == null)
            {
                uiParent = UIRoot;
            }
            Vector3 screenPos = MainCamera.WorldToScreenPoint(worldPosition);
            isBack = screenPos.z < 0;
            if (isBack) // 物体在相机背面
            {
                screenPos.x = Screen.width - screenPos.x;
                screenPos.y = Screen.height - screenPos.y;
            }
            RectTransformUtility.ScreenPointToLocalPointInRectangle(uiParent, screenPos, RTUtility.GetCachedUICamera(uiParent), out Vector2 retPos);
            return retPos;
        }

        /// <summary>
        /// 更新UI气泡
        /// </summary>
        /// <param name="messageTrans"></param>
        /// <param name="bubbleTrans"></param>
        /// <param name="hudWidth"></param>
        /// <param name="trans"></param>
        /// <param name="heightTrans"></param>
        /// <param name="uiParent"></param>
        /// <param name="scaleMin"></param>
        /// <param name="scaleMax"></param>
        public static void UpdateBubble(RectTransform messageTrans, RectTransform bubbleTrans, float hudWidth, Transform trans, Transform heightTrans, RectTransform uiParent, float scaleMin, float scaleMax)
        {
            if (messageTrans == null || bubbleTrans == null)
            {
                return;
            }

            float width = ScreenWidth - 80;
            float minX = -0.5f * width;
            float maxX = 0.5f * width;
            Vector2 viewPos = _GetViewPos(trans, heightTrans.position.y, uiParent, out bool isBack);
            if (viewPos.x < minX)
            {
                viewPos.x = minX;
            }
            else if (viewPos.x > maxX)
            {
                viewPos.x = maxX;
            }

            messageTrans.localPosition = viewPos;

            Vector3 bubbleLocalPosition = bubbleTrans.localPosition;
            float bubbleX;

            float hudHalfWidth = 0.5f * (hudWidth - 80);
            if (viewPos.x - minX < hudHalfWidth)
            {
                bubbleX = hudHalfWidth - (viewPos.x - minX);
            }
            else if (maxX - viewPos.x < hudHalfWidth)
            {
                bubbleX = (maxX - viewPos.x) - hudHalfWidth;
            }
            else
            {
                bubbleX = 0;
            }

            bubbleLocalPosition.x = bubbleX;
            bubbleTrans.localPosition = bubbleLocalPosition;
            _GetUIScale(trans, scaleMin, scaleMax, out float scale);
            SetScale(messageTrans, scale);
        }

        private static Vector2 _GetViewPos(Transform trans, float height, RectTransform uiParent, out bool isBack)
        {
            Vector3 worldPosition = trans.position;
            return _GetViewPos(worldPosition, height, uiParent, out isBack);
        }

        private static void _GetUIScale(Transform trans, float min, float max, out float scale)
        {
            Vector3 cameraPosition = MainCamera.transform.position;
            float distance = Vector3.Distance(trans.position, cameraPosition);
            float ratio = 1 - (distance - 10) / 7;
            if (ratio < min)
            {
                ratio = min;
            }
            else if (ratio > max)
            {
                ratio = max;
            }

            scale = ratio;
        }

        public static bool GetPositionIsInView(Transform trans)
        {
            if (trans == null)
                return false;
            return GetPositionIsInViewByPosition(trans.position);
        }

        public static bool GetPositionIsInViewByPosition(Vector3 position, float minX = 0, float maxX = 1, float minY = 0, float maxY = 1)
        {
            Transform camTransform = MainCamera.transform;
            Vector3 dir = position - camTransform.position;
            float dot = Vector3.Dot(camTransform.forward, dir);
            if (dot > 0)
            {
                Vector3 viewPosition = MainCamera.WorldToViewportPoint(position);
                if (viewPosition.x >= minX && viewPosition.x <= maxX && viewPosition.y >= minY && viewPosition.y <= maxY)
                {
                    return true;
                }
            }
            return false;
        }

        private static void _ResetGuideDatas()
        {
            for (int i = 0; i < _guideDatas.Length; i++)
            {
                GuideData guideData = _guideDatas[i];
                guideData.state = false;
                guideData.result = false;
            }
        }

        private static bool _CalculateResult(int index, Vector3 a, Vector3 b, Vector3 forward)
        {
            return _guideDatas[index].CalculateResult(a, b, forward);
        }

        public static void UpdateGuide(RectTransform guide, RectTransform arrow, RectTransform uiRoot, Actor targetActor, Transform heightTrans, float screenWidth, float screenHeight)
        {
            if (Battle.Instance == null)
            {
                return;
            }
            Actor sourceActor = Battle.Instance.player;
            if (guide == null || arrow == null || uiRoot == null || sourceActor == null || targetActor == null || sourceActor.isDead || targetActor.isDead || heightTrans == null)
            {
                Battle.Instance.ui.SetNodeVisible(guide, false);
                return;
            }
            float height = heightTrans.position.y;
            Vector2 sourceViewPos = _GetViewPos(sourceActor.transform.position, height, uiRoot, out bool isSourceBack);
            if (sourceViewPos == Vector2.zero)
            {
                Battle.Instance.ui.SetNodeVisible(guide, false);
                return;
            }
            Vector2 targetViewPos = _GetViewPos(targetActor.transform.position, height, uiRoot, out bool isTargetBack);
            if (targetViewPos == Vector2.zero)
            {
                Battle.Instance.ui.SetNodeVisible(guide, false);
                return;
            }

            float halfWidth1 = 0.5f * Screen.width;
            float halfWidth2 = -0.5f *  Screen.width;
            float halfHeight1 = 0.5f * Screen.height;
            float halfHeight2 = -0.5f * Screen.height;
            
            float sourceViewPosX = sourceViewPos.x;
            float sourceViewPosY = sourceViewPos.y;
            float targetViewPosX = targetViewPos.x;
            float targetViewPosY = targetViewPos.y;
            if (sourceViewPosX <= halfWidth2 || sourceViewPosX >= halfWidth1 ||
                sourceViewPosY <= halfHeight2 || sourceViewPosY >= halfHeight1 || isSourceBack ||
                targetViewPosX >= halfWidth2 && targetViewPosX <= halfWidth1 &&
                targetViewPosY >= halfHeight2 && targetViewPosY <= halfHeight1 && !isTargetBack)
            {
                Battle.Instance.ui.SetNodeVisible(guide, false);
                return;
            }
            
            float x1 = 0.5f * screenWidth;
            float x2 = -0.5f * screenWidth;
            float y1 = 0.5f * screenHeight;
            float y2 = -0.5f * screenHeight;

            //x2y1------- x1y1
            //|            |
            //|            |
            //x2y2-------x1y2
            Vector2 x1y1 = new Vector2(x1, y1);
            Vector2 x2y1 = new Vector2(x2, y1);
            Vector2 x2y2 = new Vector2(x2, y2);
            Vector2 x1y2 = new Vector2(x1, y2);

            Vector2 dir = (targetViewPos - sourceViewPos).normalized;
            Vector2 a = x1y1 - sourceViewPos;
            Vector2 b = x2y1 - sourceViewPos;
            Vector2 c = x2y2 - sourceViewPos;
            Vector2 d = x1y2 - sourceViewPos;

            Vector3 forward = Vector3.forward;
            float distance;
            float angle = Vector3.Angle(-Vector3.up, dir);
            if (Vector3.Dot(Vector3.right, dir) < 0)
            {
                angle = 360 - angle;
            }
            _ResetGuideDatas();
            //向量与左边相交
            if (_CalculateResult(1, b, dir, forward) && !_CalculateResult(2, c, dir, forward))
            {
                distance = (x2 - sourceViewPos.x) / dir.x;
            }
            //向量与右边相交
            else if (_CalculateResult(3, d, dir, forward) && !_CalculateResult(0, a, dir, forward))
            {
                distance = (x1 - sourceViewPos.x) / dir.x;
            }
            //向量与下边相交
            else if (_CalculateResult(2, c, dir, forward) && !_CalculateResult(3, d, dir, forward))
            {
                distance = (y2 - sourceViewPos.y) / dir.y;
            }
            //向量与上边相交
            else// if (_CalculateResult(0, a, dir, forward) && !_CalculateResult(1, b, dir, forward))
            {
                distance = (y1 - sourceViewPos.y) / dir.y;
            }

            Vector3 hitViewPos = sourceViewPos + dir * distance;
            Vector3 targetPoint;
            if (hitViewPos.x == 0 || hitViewPos.y == 0)
            {
                targetPoint = hitViewPos;
            }
            else
            {
                targetPoint = MathUtility.GetEllipticalLineIntersect(screenWidth * 0.5f, screenHeight * 0.5f, hitViewPos.y / hitViewPos.x, hitViewPos.x);
            }
            guide.localPosition = targetPoint;
            arrow.localEulerAngles = new Vector3(0, 0, angle);
            Battle.Instance.ui.SetNodeVisible(guide, true);
        }

        public static void SetUINodeVisible(UIComponentType uiComponentType, bool visible, int insId = 0)
        {
            if (uiComponentType == UIComponentType.EnemyHud && insId > 0)
            {
                Actor actor = Battle.Instance.actorMgr.GetActor(insId);
                if (actor == null || !actor.IsMonster())
                {
                    LogProxy.LogError($"SetUINodeVisible,配置的怪物实例ID：{insId}不存在，请找策划一只喵！");
                    return;
                }
            }
            var eventData = Battle.Instance.eventMgr.GetEvent<EventComponentActive>();
            eventData.Init(uiComponentType, visible, insId);
            Battle.Instance.eventMgr.Dispatch(EventType.UIComponentActive, eventData);
        }
        // 战斗用UI动画播放   
        public static void BattleUIMotionPlayHash(UnityEngine.Object obj, uint key, System.Action onComplete)
        {
            var comp = MotionHandler.Get(obj);
            if (comp == null)
            {
                onComplete?.Invoke();
                return;
            }
            if (comp.GetItemWithKeyHash(key, out MotionHandler.MotionInfo info))
            {
                GameObject gameObject = comp.gameObject;
                Battle.Instance.ui.Play(info,gameObject.GetOrAddComponent<Animator>(),onComplete,gameObject);
            }
            else
                onComplete?.Invoke();
        }
        
        public static void BattleUIMotionPlayIndex(UnityEngine.Object obj, int idx, System.Action onComplete)
        {
            var comp = MotionHandler.Get(obj);
            if (comp == null)
            {
                onComplete?.Invoke();
                return;
            }

            if (comp.GetItemWithIndex(idx, out MotionHandler.MotionInfo info))
            {
                GameObject gameObject = comp.gameObject;
                Battle.Instance.ui.Play(info, gameObject.GetOrAddComponent<Animator>(),onComplete,gameObject);
            }
            else
                onComplete?.Invoke();
        }
        
        public static void BattleUIStopAllMotion(UnityEngine.Object obj)
        {
            var comp = MotionHandler.Get(obj);
            foreach (var info in comp.ItemList)
            {
                Battle.Instance.ui.Stop(info);
            }
        }

        public static void SetAnchoredPosition(RectTransform transform, float x, float y)
        {
            transform.anchoredPosition = new Vector2(x, y);
        }
        
        public static void SetBuffIcon(Transform transform, int buffID)
        {
            Battle.Instance.ui.SetBuffIcon(transform.GetComponent<X3Image>(),buffID);
        }
        public static void ShowUITipsContent(Transform  uiTipsTransform, int tipsContent)
        {
            string tempContent = BattleEnv.LuaBridge.GetUIText(tipsContent);
            using (zstring.Block())
            {
                var strs = ((zstring)tempContent).Replace(@"@", "");
                UICompUtility.SetText(uiTipsTransform, strs);
            }
        }
        
        public static int GetStageCondition2UItextID(int spawnID)
        {
            foreach (var data in TbUtil.battleConsts.StageCondition2UItextID)
            {
                if (data.ID == spawnID)
                {
                    return data.Num;
                }
            }

            return 0;
        }
        
    }
}
