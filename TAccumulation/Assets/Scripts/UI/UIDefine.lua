-- UI定义
UIDefine = {
    -- 长按间隔(秒)
    LongPressInterval = 0.05,
    -- 发送协议长按间隔
    LongSendInterval = 0.8,
    -- 长按触发时间(秒)
    LongPressTrigger = 1,
    -- 弹窗类型
    PopupStyle = {
        Content = 1,
        ContentConfirm = 2,
        ContentYesNo = 3,
        ContentSubContentConfirm = 4,
        ContentSubContentYesNo = 5,
        TitleListConfirm = 6,
        TitleListYesNo = 7,
        TitleInputYesNo = 8,
        ContentCostYesNo = 9
    },
    -- 弹窗按钮类型
    PopupButtonType = {
        CancelAndConfirm = 0, --[取消] [确认]
        Confirm = 1, -- [确认]
        ConfirmAndCancel = 2, -- [确认][取消]
        None = 3 -- 无按钮
    },
    -- ctrl类型
    CtrlType = {
        -- 全屏
        FullScreen = 1,
        -- 镂空
        HollowOut = 2,
        -- 弹框
        PopupBox = 3
    },
    -- 资源类型
    ResourcesType = {
        None = 0,
        Ticket = 1, -- 点券
        Contribution = 2, --贡献
        Jade = 3, -- 玉璧
        Stone = 4, -- 石料
        Gold = 5, -- 铜币
        Soldier = 6, --士兵
        Equip = 7, -- 装备
        QiXingSha = 8, -- 七星砂
        NanHaiQiJing = 9, -- 南海奇精
        LordExp = 10, -- 君主经验
        CaptainExp = 11, -- 武将经验
        Bill = 12, -- 强化符
        Gem = 13, -- 宝石
        CaptainSoul_1 = 14, -- 将魂(推图)
        CaptainSoul_2 = 15, -- 将魂(钓鱼)
        JiangHunTianShu = 16, -- 将魂天书
        TuFeiLing = 17, -- 突飞令
        QianChengLing = 18, -- 迁城令
        YuanBao = 19, -- 元宝
        SpeedProp = 20, -- 加速道具
        GrowthGet = 21, -- 武将成长
        CaptainSoul_3 = 22, -- 将魂(霸王之路)
        GongXun = 23, -- 功勋
        GongXunLinPai = 24, -- 功勋令牌
        CloneSelf = 25, -- 分身道具
        Jade_HeShi = 26, -- 和氏璧
        Jade_XueFeng = 27, -- 雪凤璧
        Jade_HuWen = 28, -- 虎纹璧 
        MiYue = 29, -- 芈月
        YuEr = 30, -- 鱼饵
        Tael = 31, -- 银两
        Tribute = 38, -- 贡品
    },
    -- ui的渲染分层
    SortingOrder = {
        -- 主城npc对话
        MainCityDialog = 0,
        -- 聊天缩略框
        ChatBrief = 100,
        -- 场景加载
        SceneLoading = 150,
        -- 信息同步
        MsgSync = 200,
        -- 新手引导(248~250)
        NoviceGuide = 250,
        -- 新功能开启
        NewFunctionOpen = 260,
        -- 剧情层级
        ScenarioDialog = 300,
        -- 城池升级
        CityUpgrade = 350,
        -- 城池流亡
        CityExiled = 400,
        -- 全屏展示
        FullScreenShow = 450,
        -- 网络信号
        NetSignal = 500,
        -- 网络弹框
        NetError = 550,
        -- 系统广播
        SystemMsg = 600,
        -- 消息提示
        MsgTips = 650,
        -- 点击特效
        ClickEffect = 700,
        -- 服务器时间
        ServerTime = 1000,
        -- gm指令
        GmOrder = 1001,
        -- 退出app
        QuitApp = 2000,
    },

    -- 野外世界小地图的功能
    RegionMinimapType = 
    {
        None = 0,
        Minimap = 1,            -- 小地图的功能
        CityBuild = 2,          -- 名城营建的功能
        CityRecommend = 3,     -- 名城推荐的功能
    },

    RegionTreasureUIType = 
    {
        None = 0,
        Search = 1, -- 搜索
        Invoke = 2, -- 召唤
    }
}
