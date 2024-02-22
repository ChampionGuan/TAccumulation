using System.Linq;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{ 
    /// <summary>
    /// 语音沟通的节点
    /// </summary>
    public class DialogueNode
    {
        public DialogueConfig config { get; private set; }
        public DialogueKeyConfig keyConfig { get; private set; }
        private float _beginTime = 0;
        private EDialogueNode _action = EDialogueNode.End;
        private Battle _battle => Battle.Instance;
        private float _pauseBeginTime;
        private GameObject _firstObj;
        private GameObject _twoObj;
        private GameObject _threeObj;
        private GameObject _fourObj;
        private ActorDialogue _dialogue;
        public EDialogueNode action
        {
            get { return _action; }
            set { _action = value; }
        }

        public enum EDialogueNode
        {
            EBegin = 0,
            EPlayOne = 1,
            EPlayTwo,
            EPlayThree,
            EPlayFour,
            End,
        }

        /// <summary>
        /// 是否在保护时间
        /// </summary>
        /// <returns></returns>
        public bool IsProtectTime()
        {
            var useTime = Time.realtimeSinceStartup - _beginTime;
            if (useTime < keyConfig.ProtectTime)
            {
                return true;
            }

            return false;
        }

        public void Init(DialogueConfig cfg, DialogueKeyConfig keyCfg, ActorDialogue dialogue)
        {
            config = cfg;
            keyConfig = keyCfg;
            _beginTime = Time.realtimeSinceStartup;
            _action = EDialogueNode.EBegin;
            _dialogue = dialogue;
        }
        
        public void Update()
        {
            if (!_dialogue.ignoreBattlePaused && !_battle.enabled)
            {
                if (_pauseBeginTime <= 0)
                {
                    _pauseBeginTime = Time.realtimeSinceStartup;
                }
                return;
            }
            if (_pauseBeginTime > 0)
            {
                float pauseTime = Time.realtimeSinceStartup - _pauseBeginTime;
                LogProxy.Log("战斗沟通：暂停的时间是 =" + pauseTime + " Time.realtimeSinceStartup = " +Time.realtimeSinceStartup + " _pauseBeginTime = " + _pauseBeginTime);
                _beginTime += pauseTime;
                _pauseBeginTime = 0;
            }
            float useTime = Time.realtimeSinceStartup - _beginTime;
            
            switch (_action)
            {
                case EDialogueNode.EBegin:
                {
                    PlaySound(1);
                    _action = EDialogueNode.EPlayOne;
                } 
                    break;
                case EDialogueNode.EPlayOne:
                {
                    if (useTime > GetShowTime(config.Sound1) + GetRespondDelay())
                    {
                        PlaySound(2);
                        _action = EDialogueNode.EPlayTwo;
                    }
                }
                    break;
                case EDialogueNode.EPlayTwo:
                {
                    if (useTime > GetShowTime(config.Sound1) + GetShowTime(config.Sound2) + GetRespondDelay() * 2.0f)
                    {
                        PlaySound(3);
                        _action = EDialogueNode.EPlayThree;
                    }
                }
                    break;
                case EDialogueNode.EPlayThree:
                {
                    if (useTime > GetShowTime(config.Sound1) + GetShowTime(config.Sound2) + GetShowTime(config.Sound3) + GetRespondDelay() * 3.0f)
                    {
                        PlaySound(4);
                        _action = EDialogueNode.EPlayFour;
                    }
                }
                    break;
                case EDialogueNode.EPlayFour:
                {
                    if (useTime > GetShowTime(config.Sound1) + GetShowTime(config.Sound2) + GetShowTime(config.Sound3) + GetShowTime(config.Sound4) + GetRespondDelay() * 3.0f)
                    {
                        _action = EDialogueNode.End;
                    }
                }
                    break;
            }
        }

        public void Destroy()
        {
            config = null;
            keyConfig = null;
            _beginTime = 0;
            ObjectPoolUtility.DialogueNodePool.Release(this);
            _action = EDialogueNode.EBegin;
            _pauseBeginTime = 0;
            _firstObj = null;
            _twoObj = null;
            _threeObj = null;
            _fourObj = null;
        }

        public void PlaySound(int index)
        {
            Actor actor = null;
            float showTime = 0.0f;
            int textStyle = 0;
            int soundText = 0;
            string sound = "";
            GameObject tempObj = null;
            switch (index)
            {
                case 1:
                {
                    actor = BattleUtil.GeDialogueActor(config.ActorType1);
                    showTime = GetShowTime(config.Sound1);
                    textStyle = config.TextStyle1;
                    soundText = config.SoundText1;
                    sound = config.Sound1;
                    _firstObj = tempObj = actor?.GetDummy().gameObject;

                }
                    break;
                case 2:
                {
                    actor = BattleUtil.GeDialogueActor(config.ActorType2);
                    showTime = GetShowTime(config.Sound2);
                    textStyle = config.TextStyle2;
                    soundText = config.SoundText2;
                    sound = config.Sound2;
                    _twoObj = tempObj = actor?.GetDummy().gameObject;
                }
                    break;
                case 3:
                {
                    actor = BattleUtil.GeDialogueActor(config.ActorType3);
                    showTime = GetShowTime(config.Sound3);
                    textStyle = config.TextStyle3;
                    soundText = config.SoundText3;
                    sound = config.Sound3;
                    _threeObj = tempObj = actor?.GetDummy().gameObject;
                }
                    break;
                case 4:
                {
                    actor = BattleUtil.GeDialogueActor(config.ActorType4);
                    showTime = GetShowTime(config.Sound4);
                    textStyle = config.TextStyle4;
                    soundText = config.SoundText4;
                    sound = config.Sound4;
                    _fourObj = tempObj = actor?.GetDummy().gameObject;
                }
                    break;
            }

            if (actor == null || sound == "")
            {
                return;
            }
            
            WwiseManager.Instance.PlaySound(sound, tempObj);
            if (showTime > 0 && !keyConfig.HideWord)
            {
                if (textStyle == 1 || textStyle == 3)
                {
                    var eventData = _battle.eventMgr.GetEvent<EventDialogueBubble>();
                    eventData.Init(actor, showTime, soundText);
                    _battle.eventMgr.Dispatch(EventType.DialogueBubble, eventData);
                }
                if(textStyle == 2 || textStyle == 3)
                {
                    var eventData = _battle.eventMgr.GetEvent<EventDialogueText>();
                    int tempName = BattleUtil.GetActorName(actor.config.ID);
#if UNITY_EDITOR
                    if (actor.IsGirl() && !BattleEnv.LuaBridge.GetIsConnect())
                    {
                        tempName = 0;
                    }    
#endif
                    eventData.Init(tempName, soundText, showTime);
                    _battle.eventMgr.Dispatch(EventType.DialogueText, eventData);
                }
                        
            }
        }

        public void StopSound()
        {
            switch (_action)
            {
                case EDialogueNode.EPlayOne:
                    {
                        WwiseManager.Instance.StopSound(config.Sound1, _firstObj);
                    }
                    break;
                case EDialogueNode.EPlayTwo:
                    {
                        WwiseManager.Instance.StopSound(config.Sound2, _twoObj);
                    }
                    break;
                case EDialogueNode.EPlayThree:
                {
                    WwiseManager.Instance.StopSound(config.Sound3, _threeObj);
                }
                    break;
                case EDialogueNode.EPlayFour:
                {
                    WwiseManager.Instance.StopSound(config.Sound4, _fourObj);
                }
                    break;
            }
        }
        
        /// <summary>
        /// 获取显示时间
        /// </summary>
        /// <param name="sound"></param>
        /// <returns></returns>
        public float GetShowTime(string sound)
        {
            float time = WwiseManager.Instance.GetLength(sound);
            if (time <= 0)
            {
                return 0;
            }
            time += TbUtil.battleConsts.GlobalDialogueAdjustParam * 0.001f;
            time = Mathf.Min(TbUtil.battleConsts.DiaPlayWaitTimeMax * 0.001f, time);
            time = Mathf.Max(TbUtil.battleConsts.DiaTextDisplayTimeMin * 0.001f, time);
            return time;
        }

        /// <summary>
        /// 获取语音沟通间隔应答时间
        /// </summary>
        /// <returns></returns>
        public float GetRespondDelay()
        {
            return TbUtil.battleConsts.RespondDelay * 0.001f;
        }

        /// <summary>
        /// 获取整个Node的长度
        /// </summary>
        /// <returns></returns>
        public float GetAllTime()
        {
            float time = GetShowTime(config.Sound1);
            if (GetShowTime(config.Sound2) > 0)
            {
                time += GetShowTime(config.Sound2) + GetRespondDelay();
            }
            if (GetShowTime(config.Sound3) > 0)
            {
                time += GetShowTime(config.Sound3) + GetRespondDelay();
            }
            if (GetShowTime(config.Sound4) > 0)
            {
                time += GetShowTime(config.Sound4) + GetRespondDelay();
            }
            return time;
        }
    }
}
