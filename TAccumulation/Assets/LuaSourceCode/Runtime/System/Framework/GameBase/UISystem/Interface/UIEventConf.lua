﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/8/22 21:24
---@class UIEventConf
local UIEventConf = {}
---@class UIEventType
---@field Button int
---@field LongPressHandler int
---@field SwitchButton int
---@field TabMenu int
---@field Dropdown int
---@field InputField int
---@field ListView int
---@field GroupView int
---@field ExpandView int
---@field ScrollView int
---@field ToggleButton int
---@field ToggleButtonGroup int
---@field DragHandler int
---@field Slider int
---@field MilestoneSlider int
---@field TransformSizeChangingDispatcher int
---@field Joystick
---@field X3TabMenu
---@field GroupView
---@field GIFImage
UIEventConf.UIEventType = {
    Button = 1,
    LongPressHandler = 2,
    SwitchButton = 3,
    TabMenu = 4,
    Dropdown = 5,
    InputField = 6,
    ListView = 7,
    ExpandView = 8,
    ScrollView = 9,
    ToggleButton = 10,
    ToggleButtonGroup = 11,
    DragHandler = 12,
    Slider = 13,
    MilestoneSlider = 14,
    TransformSizeChangingDispatcher = 15,
    Joystick = 16,
    X3TabMenu = 17,
    GroupView = 18,
    GIFImage = 19,
}

---@class UIEventHandlerType
---@field Button_OnClick int
---@field Button_OnTouchDown int
---@field Button_OnTouchUp int
---@field Button_OnTouchExit int
---@field LongPressHandler_OnLongPress int
---@field SwitchButton_OnValueChanged int
---@field TabMenu_OnValueChanged int
---@field TabMenu_OnCellLoad int
---@field TabMenu_OnValueWillChange int
---@field Dropdown_OnValueChanged int
---@field Dropdown_OnCellLoad int
---@field Dropdown_OnValueWillChange int
---@field InputField_OnValueChanged int
---@field InputField_OnClick int
---@field InputField_OnEndEdit int
---@field InputField_OnEndEditAndCheck int
---@field ListView_OnCellLoad int
---@field ListView_OnCellClick int
---@field ListView_OnCellLongPress int
---@field ListView_OnCellCentered int
---@field GroupView_OnCellLoad int
---@field ExpandView_OnGetChildCellCount int
---@field ExpandView_OnChildCellLoad int
---@field ExpandView_OnChildCellClick int
---@field ExpandView_OnChildCellLongPress int
---@field ExpandView_OnCellExpand int
---@field ScrollView_OnScrolling int
---@field ScrollView_OnScrollEnd int
---@field ScrollView_OnRefresh int
---@field ToggleButton_OnValueChanged int
---@field ToggleButtonGroup_OnValueChanged int
---@field DragHandler_OnDrag int
---@field DragHandler_OnPointerDown int
---@field DragHandler_OnPointerUp int
---@field MilestoneSlider_OnCellLoad int
---@field MilestoneSlider_OnMilestoneEnter int
---@field Slider_OnValueChanged int
---@field TransformSizeChangingDispatcher_OnSizeChanged int
---@field Joystick_OnJoystickDown int
---@field Joystick_OnJoystickUp int
---@field Joystick_OnJoystickDrag int
---@field Joystick_OnJoystickUpdate int
---@field Joystick_OnJoystickFixUpdate int
---@field Joystick_OnJoystickLateUpdate int
---@field X3TabMenu_OnValueWillChange int
---@field X3TabMenu_OnValueChanged int
---@field X3TabMenu_OnCellLoad int
---@field X3TabMenu_OnChildCellLoad int
---@field X3TabMenu_OnGetChildCellCount int
---@field X3TabMenu_OnCellExpand int
---@field GroupView_OnCellLoad int
---@field GIFImage_OnBegin int
---@field GIFImage_OnComplete int
---@field GIFImage_OnKeyFrame int
UIEventConf.UIEventHandlerType = {
    --region Button
    Button_OnClick = 1,
    Button_OnTouchDown = 2,
    Button_OnTouchUp = 3,
    Button_OnTouchExit = 4,
    --endregion

    --region LongPressHandler
    LongPressHandler_OnLongPress = 1,
    --endregion

    --region SwitchButton
    SwitchButton_OnValueChanged = 1,
    --endregion

    --region TabMenu
    TabMenu_OnValueChanged = 1,
    TabMenu_OnCellLoad = 2,
    TabMenu_OnValueWillChange = 3,
    --endregion

    --region Dropdown
    Dropdown_OnValueChanged = 1,
    Dropdown_OnCellLoad = 2,
    Dropdown_OnValueWillChange = 3,
    --endregion

    --region InputField
    InputField_OnValueChanged = 1,
    InputField_OnClick = 2,
    InputField_OnEndEdit = 3,
    InputField_OnEndEditAndCheck = 4,
    --endregion

    --region ListView
    ListView_OnCellLoad = 1,
    ListView_OnCellClick = 2,
    ListView_OnCellLongPress = 3,
    ListView_OnCellCentered = 4,
    --endregion

    --region ExpandView
    ExpandView_OnGetChildCellCount = 1,
    ExpandView_OnChildCellLoad = 2,
    ExpandView_OnChildCellClick = 3,
    ExpandView_OnChildCellLongPress = 4,
    ExpandView_OnCellExpand = 5,
    --endregion

    --region ScrollView
    ScrollView_OnScrolling = 1,
    ScrollView_OnScrollEnd = 2,
    ScrollView_OnRefresh = 3,
    --endregion

    --region ToggleButton
    ToggleButton_OnValueChanged = 1,
    --endregion

    --region ToggleButtonGroup
    ToggleButtonGroup_OnValueChanged = 1,
    --endregion

    --region DragHandler
    DragHandler_OnDrag = 1,
    DragHandler_OnPointerDown = 2,
    DragHandler_OnPointerUp = 3,
    --endregion

    --region MilestoneSlider
    MilestoneSlider_OnCellLoad = 1,
    MilestoneSlider_OnMilestoneEnter = 2,
    --endregion

    --region Slider
    Slider_OnValueChanged = 1,
    --endregion

    --region TransformSizeChangingDispatcher
    TransformSizeChangingDispatcher_OnSizeChanged = 1,
    --endregion

    --region Joystick
    Joystick_OnJoystickDown = 1,
    Joystick_OnJoystickUp = 2,
    Joystick_OnJoystickDrag = 3,
    Joystick_OnJoystickUpdate = 4,
    Joystick_OnJoystickFixUpdate = 5,
    Joystick_OnJoystickLateUpdate = 6,
    --endregion

    --region X3TabMenu
    X3TabMenu_OnValueWillChange = 1,
    X3TabMenu_OnValueChanged = 2,
    X3TabMenu_OnCellLoad = 3,
    X3TabMenu_OnChildCellLoad = 4,
    X3TabMenu_OnGetChildCellCount = 5,
    X3TabMenu_OnCellExpand = 6,
    --endregion

    --region GroupView
    GroupView_OnCellLoad = 1,
    --endregion

    --region GIFImage
    GIFImage_OnBegin = 1,
    GIFImage_OnComplete = 2,
    GIFImage_OnKeyFrame = 3,
    --endregion
}

UIEventConf.UIEventTypeConf = {
    [UIEventConf.UIEventType.Button] = {
        GetComponentID = "GetButtonComponentID",
    },
    [UIEventConf.UIEventType.LongPressHandler] = {
        GetComponentID = "GetLongPressHandlerComponentID",
    },
    [UIEventConf.UIEventType.SwitchButton] = {
        GetComponentID = "GetSwitchButtonComponentID",
    },
    [UIEventConf.UIEventType.TabMenu] = {
        GetComponentID = "GetTabMenuComponentID",
    },
    [UIEventConf.UIEventType.Dropdown] = {
        GetComponentID = "GetDropdownComponentID",
    },
    [UIEventConf.UIEventType.InputField] = {
        GetComponentID = "GetInputFieldComponentID",
    },
    [UIEventConf.UIEventType.ListView] = {
        GetComponentID = "GetListViewComponentID",
    },
    [UIEventConf.UIEventType.ExpandView] = {
        GetComponentID = "GetExpandViewComponentID",
    },
    [UIEventConf.UIEventType.ScrollView] = {
        GetComponentID = "GetX3ScrollViewComponentID",
    },
    [UIEventConf.UIEventType.ToggleButton] = {
        GetComponentID = "GetToggleButtonComponentID",
    },
    [UIEventConf.UIEventType.ToggleButtonGroup] = {
        GetComponentID = "GetToggleButtonGroupComponentID",
    },
    [UIEventConf.UIEventType.DragHandler] = {
        GetComponentID = "GetDragHandlerComponentID",
    },
    [UIEventConf.UIEventType.Slider] = {
        GetComponentID = "GetSliderComponentID",
    },
    [UIEventConf.UIEventType.MilestoneSlider] = {
        GetComponentID = "GetMilestoneSliderComponentID",
    },
    [UIEventConf.UIEventType.TransformSizeChangingDispatcher] = {
        GetComponentID = "GetTransformSizeChangingDispatcherComponentID",
    },
    [UIEventConf.UIEventType.X3TabMenu] = {
        GetComponentID = "GetX3TabMenuComponentID",
    },
    [UIEventConf.UIEventType.GIFImage] = {
        GetComponentID = "GetGIFImageComponentID",
    },
}

return UIEventConf