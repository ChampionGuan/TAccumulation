using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public interface IBattleLuaClient
    {
        void Awake();
        void Start();
        void Update();
        void OnDestroy();
        void OnBattleBegin();
        void OnBattleEnd();
    }
    
    public interface IBattleServerProxy
    {
        void RollDoor(Action<List<RogueDoorData>> callback);

        void SelectDoor(int index, Action<int> callback);

        void SelectRogueEntry(int id, Action<int,int> callback);
    }
    
    public interface IBattleLuaBridge
    {
        /// <summary>
        /// lua端服务器代理
        /// </summary>
        IBattleServerProxy server { get; }

        /// <summary>
        /// 当游戏被重启
        /// </summary>
        void OnGameReboot();
        
        /// <summary>
        /// 创建lua端战斗
        /// </summary>
        IBattleLuaClient CreateBattle();
        
        /// <summary>
        /// 销毁Lua端战斗
        /// </summary>
        void DestroyBattle();
        
        /// <summary>
        /// 
        /// </summary>
        /// <param name="isWhite">是否是白屏</param>
        /// <param name="isIn">是否是淡入</param>
        /// <param name="onCompleteAction">完成回调</param>
        void ScreenFabe(bool isWhite, bool isIn, Action onCompleteAction);

        /// <summary>
        /// 清除UI层过渡效果
        /// </summary>
        void CloseScreenFabe();
        
        /// <summary>
        /// 获得多语言文字
        /// </summary>
        /// <param name="textID"></param>
        string GetUIText(int textID);

        /// <summary>
        /// 获得无效多语言
        /// </summary>
        /// <returns></returns>
        string GetInvalidText();
        
        /// <summary>
        /// 激活语音图鉴
        /// </summary>
        /// <param name="dialogueIds"></param>
        void ActiveScoreVoices(List<int> dialogueIds,int scoreID);

        /// <summary>
        /// 获取套装对应的裸模和部件列表
        /// </summary>
        void GetCharacterBaseKey2PartKeys(int scoreID, int suitID, bool brokenSuit, out string baseKey, out string[] partKeys);

        /// <summary>
        /// 根据lod和PartKey获取对应的AssetPath
        /// </summary>
        /// <param name="partKey"></param>
        /// <param name="lod"></param>
        /// <returns></returns>
        string GetCharacterPartAssetPath(string partKey, float lod);

        /// <summary>
        /// 获取裸模对应的AssetPath
        /// </summary>
        /// <returns></returns>
        string GetCharacterBaseAssetPath(string baseKey);

        /// <summary>
        /// 获取属性最小值
        /// </summary>
        /// <returns></returns>
        void GetAttrMin(out List<AttrType> types, out List<float> values);

        /// <summary>
        /// 获取武器部件
        /// </summary>
        /// <param name="weaponSkinID"></param>
        /// <returns></returns>
        string[] GetWeaponPartIDs(int weaponSkinID);

        /// <summary>
        /// 获取女主爆发技时的suitID
        /// </summary>
        /// <param name="girlSuitID"></param>
        /// <param name="boySuitID"></param>
        /// <param name="boyScoreID"></param>
        /// <returns></returns>
        int GetFemaleUltraSuitID(int girlSuitID, int boySuitID, int boyScoreID);
        
        void ShowTagTaskUI(Action closeAction);
        
        /// <summary>
        /// 显隐词缀提示
        /// </summary>
        /// <param name="visible"></param>
        /// <param name="id"></param>
        void SetAffixVisible(bool visible, int id);

        /// <summary>
        /// 显隐新手引导Tips
        /// </summary>
        /// <param name="id"></param>
        void SetUiTipVisible(bool visible, int id);
        
        /// <summary>
        /// 显示连战UI
        /// </summary>
        /// <param name="levelId"></param>
        void ShowMultiLevelUI(Action closeAction);

        void SetAffixTimeColor(int type);

        /// <summary>
        /// 更新槽位按钮状态
        /// </summary>
        void UpdateBtnState();
        
        /// <summary>
        /// 设置主UI显示模式
        /// </summary>
        /// <param name="wndMode"></param>
        void SetBattleWndMode(BattleWndMode wndMode);

        // /// <summary>
        // /// 显示拍脸战斗指引
        // /// </summary>
        // /// <param name="id"></param>
        // void ShowGuidePopup(int id);
        
        // /// <summary>
        // /// 隐藏拍脸战斗指引
        // /// </summary>
        // /// <param name="id"></param>
        // void HideGuidePopup(int id);
        
        /// <summary>
        /// 显示booss信息Tips
        /// </summary>
        /// <param name="BossId">怪物id</param>
        void ShowBossIntroductionUiTip(int bossId,float durationTime);

        /// <summary>
        /// 预加载UI列表
        /// </summary>
        void PreLoadUIs();
        
        /// <summary>
        /// 隐藏3D UI
        /// </summary>
        void HideAllMonsterHuds();
        
        /// <summary>
        /// 显示击破信息Tips
        /// </summary>
        /// <param name="durationTime">持续时间</param>
        void ShowBreakTipUI(float durationTime);
        
        /// <summary>
        /// 注册引导事件
        /// </summary>
        /// <param name="callback"></param>
        void TryRegisterGuideEvent(Action<string> callback);

        /// <summary>
        /// 移除引导事件
        /// </summary>
        void TryUnregisterGuideEvent();

        /// <summary>
        /// 发送引导事件
        /// </summary>
        /// <param name="eventName"></param>
        void SendGuideEvent(string eventName);

        /// <summary>
        /// 事件触发
        /// </summary>
        void FireEvent(EventType type, ECEventDataBase arg);
        
        /// <summary>
        /// 统一多次事件触发
        /// </summary>
        void FireEventList(List<EventType> typeList, List<ECEventDataBase> argList);
        
        /// <summary>
        /// 设置槽位按钮
        /// </summary>
        /// <param name="actor"></param>
        /// <param name="btnType"></param>
        /// <param name="skillSlot"></param>
        void SetSkillSlot(Actor actor, PlayerBtnType btnType, SkillSlot skillSlot);

        /// <summary>
        /// 显示结算UI
        /// </summary>
        void ShowStatisticsUI();


        /// 设置按钮状态
        void SetAtkBtnState(int state);
        void SetActiveBtnState(int state);
        void SetDodgeBtnState(int state);
        void SetCoopBtnState(int state);
        void SetPowerBtnState(int state);
        void SetBoyActiveBtnState(int state);

        

        /// <summary>
        /// 获取场景Scene路径
        /// </summary>
        /// <param name="sceneName"></param>
        /// <returns></returns>
        string GetScenePath(string sceneName);
        
        /// <summary>
        /// 获得精灵对应的精灵全路径或者图集名
        /// </summary>
        /// <param name="spriteName"></param>
        /// <returns></returns>
        object[] GetSpriteAndAtlasName(string spriteName);
        
        /// <summary>
        /// 获得套装角色的头像资源
        /// </summary>
        /// <param name="suitId"></param>
        /// <returns></returns>
        string GetSuitHeadIconName(int suitId);
        
        /// <summary>
        /// 获得套装角色的半身像资源
        /// </summary>
        /// <param name="suitId"></param>
        /// <returns></returns>
        string GetSuitBodyIconName(int suitId);

        /// <summary>
        /// 应用捏脸数据
        /// </summary>
        /// <param name="suitId"></param>
        /// <param name="character"></param>
        /// <returns></returns>
        void ApplyFaceData(int suitId, GameObject character);

        /// <summary>
        /// 获取Music对应的EventName
        /// </summary>
        /// <param name="musicName"></param>
        /// <returns></returns>
        string GetMusicEventName(string musicName);

        /// <summary>
        /// 获取正式的战斗关卡列表
        /// </summary>
        /// <param name="levelIDs"></param>
        void GetLevelIDFromCommonStageTab(out List<int> levelIDs);
        
        /// <summary>
        /// 获取系统入口关卡列表
        /// </summary>
        /// <param name="levelIDs"></param>
        List<int> GetCommonStageIDs(int levelId);

        /// <summary>
        /// 获取设备等级
        /// 1，2，3，4数字越大设备越好（小米9等级为2）
        /// </summary>
        /// <returns>设备等级</returns>
        int GetRecommendGQLevel();

        void UnloadAsset(string levelID, string fullPath);

        void DestroyFxTest(string path, string levelID, ResLoadArg arg);
        
        //获取关卡是否通关
        bool GetStageIsWin(int stageId);
        
        //获取服务器区ID
        int GetZoneID();

        //获取玩家UID
        string GePlayerID();
        
        //上传OSS文件
        void UpOssFile(string channelId, string filePath, string ext, string category, string fileName);
        
        //获取是否联网
        bool GetIsConnect();
        
        //判断GroupID
        bool ConditionGroupId(int groupID);
        
        //获取GameStateMgr的当前状态
        //测试代码使用
        string GetGameStateMgrState();
        
        //关闭关卡tag界面
        //测试代码使用
        void CloseLevelPopUI();

        void PlayVirabrate(int amplitude, float frequency, int times);
        
        //设置音频状态
        void SetSoundMgrMode(bool state);
        
        /// <summary>
        /// Suit是否开放由系统表 Formation 表确定
        /// 在系统表中判断一个SuitID是否可用
        /// </summary>
        /// <param name="suitID"></param>
        /// <returns></returns>
        bool IsSuitIDCanUse(int suitID);
        
        /// <summary>
        /// weapon是否开放由系统表 MyWeapon表中的MyWeaponSkin子表确定 
        /// 所以在系统表中判断一个WeaponSkinID是否可用
        /// </summary>
        bool IsWeaponSkinIDCanUse(int weaponSkinID);

        /// <summary>
        /// 当前关卡是否通关， 离线战斗返回true
        /// </summary>
        /// <param name="levelID"></param>
        /// <returns></returns>
        bool StageIsUnLockById(int levelID);
        
        /// <summary>
        /// 手动踢回登陆界面
        /// </summary>
        void DoDisconnection();
		
		void GenOfflineHeroBornCfg(RoleBornCfg bornCfg, RoleType roleType);

        /// <summary>
        /// 开始结算流程
        /// </summary>
        void StartSettlementProcess(EventBattleEnd data, Action onServerAck);

        /// <summary>
        /// 获取暴击伤害
        /// </summary>
        float GetCritHurtAdd(int boyCfgId);

        /// <summary>
        /// 增加弹药
        /// </summary>
        /// <param name="count"></param>
        void AddAmmunition(int count);

        S2Int[] GetCardSetPassiveSkillConfigs(int propertyID, RoleType roleType);

        /// <summary>
        /// 显示战斗结束UI
        /// </summary>
        /// <param name="isWin"> 是否胜利 </param>
        /// <param name="closeAction"> 关闭BattleEndUI的回调 </param>
        void ShowBattleEndUI(bool isWin, Action closeAction);
        
        /// <summary>
        /// 显示rogue词条选取UI
        /// </summary>
        /// <param name="closeAction"> 关闭UI的回调 </param>
        void ShowRoguePickEntriesUI(Action closeAction);
        
        /// <summary>
        /// 打开interActor交互物UI
        /// </summary>
        /// <param name="closeAction"> 关闭UI的回调 </param>
        void ShowBattleInterActorPopup(string desc, List<int> btnDescList, Action<int> closeAction);
        
        /// <summary>
        /// 关闭interActor交互物UI
        /// </summary>
        void CloseBattleInterActorPopup();
    }
}
