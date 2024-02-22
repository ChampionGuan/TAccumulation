---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: 峻峻
-- Date: 2020-09-04 20:23:44
---------------------------------------------------------------------

---@class DialogueEnum
local DialogueEnum = class("DialogueEnum")

---剧情选项类型
---@class DialogueEnum.ChoiceType
DialogueEnum.ChoiceType = {
    --默认
    Default = 0,
    --娃娃机选娃娃选项
    ChooseDoll = 1
}

---剧情节点类型
---@class DialogueEnum.DialogueConditionType
DialogueEnum.DialogueConditionType = {
    --对话
    Dialogue = 0,
    --选项
    Choice = 1,
    --条件分支
    ConditionBranch = 2,
    --随机
    Random = 3,
    --QTE
    QTE = 4,
    --关卡
    CommonStage = 5,
    --循环次数
    LoopCount = 20,
    --循环时间
    LoopTime = 21,
    --并行节点
    Parallel = 22,
    --快播节点
    QuickSequence = 999,
}

---剧情位置配置类型
---@class DialogueEnum.DialoguePositionType
DialogueEnum.DialoguePositionType = {
    --默认位置
    Default = 0,
    --固定位置配置
    Position = 1,
    --绑定目标
    Target = 2,
}

---剧情类型
---@class DialogueEnum.DialogueType
DialogueEnum.DialogueType = {
    --默认
    Default = 0,
    --字幕
    Subtitles = 1,
    --气泡
    Bubble = 2,
    --模板
    Template = 3,
    --AVG气泡
    Avg = 4,
}

---节点开始和结束条件的等待类型
---@class DialogueEnum.NodeWaitType
DialogueEnum.NodeWaitType = {
    --无
    None = 0,
    --等待CTS事件帧
    CTSEvent = 1,
    --等待固定时长
    Time = 2
}

---节点Player状态
---@class DialogueEnum.NodePlayerState
DialogueEnum.NodePlayerState = {
    --默认
    None = 0,
    --由于Tick顺序导致UI当帧没有打开发事件收不到
    WaitToRunning = 1,
    --运行
    Running = 2,
    --等待（用于主堆栈等待）
    Waiting = 3,
    --完成
    Complete = 4,
    --Update锁帧，当帧不要Tick
    FrameLock = 99,
}

---Wwise类型
---@class DialogueEnum.WwiseSoundType
DialogueEnum.WwiseSoundType = {
    --音效
    Sound = 0,
    --背景音
    Background = 1,
    --环境音
    Ambient = 2
}

---Wwise类型
---@class DialogueEnum.WwiseVoiceType
DialogueEnum.WwiseVoiceType = {
    --语音
    Voice = 2,
    --语音组
    VoiceGroup = 3,
}

---QTE位置类型
---@class DialogueEnum.QTEPositionType
DialogueEnum.QTEPositionType = {
    --固定位置
    Position = 0,
    --绑定目标
    Target = 1,
}

---绑定目标类型
---@class DialogueEnum.DynamicTargetType
DialogueEnum.DynamicTargetType = {
    --角色
    Actor = 0,
    --角色Tag
    ActorTag = 1,
    --临时物件
    TempObject = 2,
    --剧情UI
    UI = 3,
    --世界坐标
    World = 999,
}

---选项样式
---@class DialogueEnum.ChoiceStyle
DialogueEnum.ChoiceStyle = {
    --默认
    Default = 0,
    --动态Prefab替换，对应DialogueChoice表
    ChoicePrefab = 1,
    --模板
    Template = 99,
}

---对应DialogueChoice表的ChoiceType字段
---@class DialogueEnum.DialogueChoiceType
DialogueEnum.DialogueChoiceType = {
    ---列表形式
    GridView = 1,
    ---自定义
    Customize = 2,
}

---对应DialogueBubble表的BubbleType字段
---@class DialogueEnum.DialogueBubbleType
DialogueEnum.DialogueBubbleType = {
    ---默认
    Default = 1,
    ---多文本
    MultiText = 2,
    ---ListView形式的气泡
    ListView = 3,
}

---QTE点击类型
---@class DialogueEnum.QTEClickType
DialogueEnum.QTEClickType = {
    --默认
    Click = 0,
    --定点滑动
    SliderPosition = 1,
    --定向滑动
    SliderDirection = 2,
    --长按
    LongPress = 4,
    --吹气
    Blow = 5,
    --连续点击
    ContinuousClick = 6,
    --抚摸
    Touch = 7,
    ---语音识别
    SpeechRecognition = 8,
    --自选样式
    DIY = 99
}

---@class DialogueEnum.QTESlideType
DialogueEnum.QTESlideType = {
    --四方向
    Direction = 1,
    --贝塞尔
    Bezier = 2,
    --直线
    Line = 3,
    ---手指，有一个起点滑到重点的表现效果
    Finger = 4
}

---选项样式
---@class DialogueEnum.QTEStyle
DialogueEnum.QTEStyle = {
    --默认
    Default = 0,
    --动态Prefab替换，对应DialogueQTE表
    QTEPrefab = 1,
    --自选样式
    DIY = 49,
    --模板
    Template = 99,
}

---人物模型类型配置
---@class DialogueEnum.ActorType
DialogueEnum.ActorType = {
    --套装，对应RoleClothSuit表
    RoleClothSuit = 1,
    --模型资产，对应ModelAsset表
    ModelAsset = 2,
    --裸模+部件
    RoleBaseModel = 3
}

---文本点击状态
---@class DialogueEnum.TextClickState
DialogueEnum.TextClickState = {
    --无
    None = 0,
    --显示全部文字
    WaitForClickToEndDialogue = 1,
    --文本结束
    WaitForClickToResume = 2
}

---UI文本状态
---@class DialogueEnum.UIKey
DialogueEnum.UIKey = {
    --对话文本
    Dialogue = 1,
    --气泡文本
    Bubble = 2,
    --选项文本
    Choice = 3,
    --QTE文本
    QTE = 4,
}

--region Action
---剧情行为类型
---@class DialogueEnum.DialogueActionType
DialogueEnum.DialogueActionType = {
    ---mute的行为，只需要保留关联关系，其他都不需要
    Muted = -1,
    --CTS结束相关
    CTSEnd = 2,
    --变量相关
    Variable = 3,
    --角色换装
    ActorChangeSuit = 4,
    --场景Fantasy开关
    SwitchFantansy = 5,
    --场景切换
    ChangeScene = 6,
    --Wwise音频
    Wwise = 7,
    --地点信息
    Location = 8,
    --事件相关
    Event = 11,
    --CTS表演
    CTSPlay = 12,
    --动作
    Anim = 13,
    --摄像机
    Camera = 14,
    --移动目标对象
    Move = 15,
    --黑白屏渐入渐出
    PostProcessing = 16,
    --实例化对象
    InstantiateGameObject = 18,
    --销毁对象
    DestroyGameObject = 19,
    --显隐对象
    Active = 20,
    --清除指定对象动画状态
    AnimationStateClear = 21,
    --动态截图关闭动画
    CaptureWndMotion = 22,
    --手机震动效果
    Vibration = 23,
    --剧情UI显隐
    UIActive = 24,
    --等待
    Wait = 25,
    --切换当前场景2D图
    Scene2DChange = 26,
    --切换角色灯光方案
    ChangeCharacterLight = 27,
    --跟随相机激活
    LookAtCameraActive = 28,
    ---跟随相机关闭
    LookAtCameraDeactive = 29,
    ---视频行为
    VideoPlay = 30,
    ---脸红行为
    Blush = 31,
    ---CTS命令
    CTSCommand = 32,
    ---Cinemachine呼吸动画
    CinemachineNoise = 33,
    ---截图行为
    CaptureScreen = 34,
    ---修改灯光方案绑定
    ChangeLightBinding = 35,
    ---2D黑白屏渐入渐出
    Screen2DTransition = 36,
    ---SceneFx
    SceneFx = 37,
    ---关闭场景效果
    CloseSceneEffect = 38,
    ---关闭CTS
    CTSStop = 39,
    ---重载当前角色通用动作
    ResetAnimState = 40,
    ---强制更换女主发型
    ForceReplacePLHair = 41,
    ---特殊图文
    SpecialImageText = 101,
    ---3D转场
    Transition3D = 102,
    ---后处理效果
    PPV = 103,
    ---2D转场
    Transition2D = 104,
    ---动效
    Motion = 105,
    ---镜头移动
    CameraMove = 106,
    ---关闭效果
    CloseEffect = 107,
    ---镜头动画
    CameraAnim = 108,
    ---行为组
    ActionGroup = 899,
    --模板行为
    Template = 999
}

---
---@class DialogueEnum.PPVSubType
DialogueEnum.PPVSubType =
{
    --景深
    DOF = 1,
    --下雨
    Rain = 2,
}

---转场中的切换场景方案
---@class DialogueEnum.ChangeSceneType
DialogueEnum.ChangeSceneType = {
    ---无
    None = 0,
    ---2D转场
    Scene2D = 1,
    ---3D转场
    Scene3D = 2
}

---剧情ActionUpdate状态
---@class DialogueEnum.UpdateActionState
DialogueEnum.UpdateActionState = {
    --正在运行
    Running = 0,
    --结束
    Complete = 1
}

---剧情Action状态
---@class DialogueEnum.DialogueActionState
DialogueEnum.DialogueActionState = {
    --初始状态
    None = 0,
    --Update状态
    Update = 1,
    --退出状态
    Complete = 2
}

---行为延迟类型
---@class DialogueEnum.DelayType
DialogueEnum.DelayType = {
    ---绝对延迟
    Absolute = 0,
    ---相对延迟
    Relative = 1,
    ---字幕结束后
    AfterText = 2,
}

---Anim行为动作类型
---@class DialogueEnum.AnimStateType
DialogueEnum.AnimStateType = {
    --AnimationClip
    AnimationClip = 0,
    --ProceduralAnimationClip
    ProceduralAnimationClip = 1,
    --CTS
    CutScene = 2,
}

---Camera行为镜头变化类型
---@class DialogueEnum.CameraChangeType
DialogueEnum.CameraChangeType = {
    --保持
    Hold = 0,
    --瞬切
    Change = 1,
    --平滑过渡
    TweenTo = 2,
}

---后处理行为过渡类型
---@class DialogueEnum.TransitionType
DialogueEnum.TransitionType = {
    ---黑屏渐入
    DarkScreenFadeIn = 0,
    ---黑屏渐出
    DarkScreenFadeOut = 1,
    ---白屏渐入
    WhiteScreenFadeIn = 2,
    ---白屏渐出
    WhiteScreenFadeOut = 3,
}

---UI显隐
---@class DialogueEnum.UIActiveType
DialogueEnum.UIActiveType = {
    ---显示
    Show = 0,
    ---隐藏
    Hide = 1,
}

---业务事件的类型
---@class DialogueEnum.DialogueFucType
DialogueEnum.DialogueFucType = {
    ---特殊逻辑
    Special = 1,
    ---统一事件
    Event = 2,
}

---节点退出类型
---@class DialogueEnum.ExitFinishType
DialogueEnum.ExitFinishType = {
    ---播完本节点
    FinishSelf = 0,
    ---不播完
    Stop = 1,
}

---节点连接类型
---@class DialogueEnum.ExitLinkType
DialogueEnum.ExitLinkType = {
    ---立刻退出
    Exit = 0,
    ---连接至下一节点
    Link = 1,
}

---特殊图文属性类型
---@class DialogueEnum.SpecialImageTextType
DialogueEnum.SpecialImageTextType = {
    ---文本
    Text = 1,
    ---图片
    Image = 2,
}

---特殊图文属性类型
---@class DialogueEnum.SpecialImageTextSubType
DialogueEnum.SpecialImageTextSubType = {
    ---文本和图片
    TextAndImage = 1,
    ---跑马灯
    Marquee = 2,
}

---灯光方案行为Type
---@class DialogueEnum.ChangeLightBindingType
DialogueEnum.ChangeLightBindingType = {
    ---更改
    Bind = 0,
    ---重置
    Reset = 1,
}
--endregion

return DialogueEnum