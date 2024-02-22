﻿---@class cfg.SkillDamageBoxConfig  excel名称:BattleHurt.xlsx
---@field Angle Fix 扇形角度
---@field AngleY Fix 旋转
---@field BoxDamageIDIndex int 伤害ID序号
---@field BoxMaxHit int 最大次数
---@field BuffOperationIDs int[] Buff操作ID
---@field CameraShakeID int 受击震屏
---@field CheckMode int 判定模式
---@field Duration Fix 持续时间
---@field FactionRelationship int[] 阵营关系筛选
---@field FollowMode int 跟随模式
---@field FreezeFrameDelay Fix 命中特效定帧延迟
---@field FxFreezeFrame boolean 命中特效定帧缩放
---@field Height Fix 高度y轴
---@field HitScaleDuration Fix 打击定帧时长
---@field HitTimeScale Fix 打击定帧时间缩放
---@field HugeDamage boolean 高额伤害跳字
---@field HurtActionID int 受击动作类型
---@field HurtBackDistance Fix 击退距离
---@field HurtBackTime Fix 击退距离时长
---@field HurtFXID int 命中特效名称
---@field HurtFaceToTarget boolean 是否面朝攻击者
---@field HurtFxSpeed float[] 命中特效播放速度
---@field HurtScaleDuration Fix 受击定帧时长
---@field HurtScarAngle float 受击角度
---@field HurtScarID int 受击砍痕ID
---@field HurtShakeIndex int 受击抖动强度（0,1,2共三挡）
---@field HurtShakeType int 抖动类型（-1为整体抖动,局部位置从0开始计数)
---@field HurtSound string 命中音效名称
---@field HurtTime Fix 受击硬直时间
---@field HurtTimeScale Fix 受击定帧时间缩放
---@field ID int 伤害包围盒编号
---@field Length Fix 长度x轴或胶囊体长
---@field ModifyWeight int 伤害数值权重
---@field MountType int 挂载类型
---@field Name string #备注
---@field NoDamage boolean 是否不造成伤害
---@field Offset FVector3 偏移量
---@field Period Fix 周期
---@field PlayHurtFXMat boolean 播放受击闪白
---@field Radius Fix 半径
---@field RandomFloatWordRadius Fix 造成的跳字随机范围
---@field RandomHurtFxRadius Fix 特效位置随机半径
---@field RandomHurtFxType int 特效位置随机类型
---@field RigidBreak Fix 刚性破坏力
---@field ShapeArg1 Fix 形状参数1
---@field ShapeArg2 Fix ##形状参数2
---@field ShapeType int 形状类型
---@field UseAnimTime boolean 是否使用动画时长
---@field Width Fix 宽度z轴
