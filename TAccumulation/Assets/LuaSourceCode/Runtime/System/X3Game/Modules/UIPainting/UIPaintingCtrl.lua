﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by liyan.
--- DateTime: 2023/12/5 11:27

---@class UIPaintingCtrl:UICtrl
local UIPaintingCtrl = class("UIPaintingCtrl", UICtrl)
local UIPaintingConst = require("Runtime.System.X3Game.Modules.UIPainting.UIPaintingConst")

local CS_Graphics = CS.UnityEngine.Graphics
local CS_Matrix = CS.UnityEngine.Matrix4x4
local CS_Shader = CS.UnityEngine.Shader

function UIPaintingCtrl:Init()
    ---@type UnityEngine.RenderTexture
    self.renderTexture = nil

    ---@type UnityEngine.RenderTexture
    self.positionMapRT = nil

    ---@type UnityEngine.Rendering.CommandBuffer
    self.commandBuffer = nil

    ---@type Vector2
    self.beginPoint = Vector2.zero
    ---@type Vector2
    self.endPoint = Vector2.zero
    ---@type Vector3
    self.drawScale = Vector3.zero
    ---@type Vector3
    self.drawPoint = Vector3.zero
    ---@type Quaternion
    self.drawRotation = Quaternion.new()
    ---@type Vector3
    self.drawDir = Vector3.zero

    ---@type Color
    self.clearColor = nil

    ---@type UnityEngine.VFX.VisualEffect
    self.vfx = nil

    ---@type UnityEngine.RectTransform
    self.rectTransform = nil

    ---@type UnityEngine.Mesh
    self.quadMesh = nil

    ---@type UnityEngine.Material
    self.material = nil

    ---@type Vector2[]
    self.samples = {}
    self.positionMapWidth = 16
    self.positionMapHeight = 16
    self.positionMapPixels = self.positionMapWidth * self.positionMapHeight

    self.positionMapClearColor = Color.new(0,0,0,0)

    self.frameCount = 0
    self.isDrawing = false


    ---@type int
    self.StartXShaderID = CS_Shader.PropertyToID("_StartX")
    ---@type int
    self.StartYShaderID = CS_Shader.PropertyToID("_StartY")
    ---@type int
    self.EndXShaderID = CS_Shader.PropertyToID("_EndX")
    ---@type int
    self.EndYShaderID = CS_Shader.PropertyToID("_EndY")
    ---@type int
    self.TextureWidthID = CS_Shader.PropertyToID("_TextureWidth")
    ---@type int
    self.TextureHeightID = CS_Shader.PropertyToID("_TextureHeight")
    ---@type int
    self.WorldPosXShaderID = CS_Shader.PropertyToID("_WorldPosX")
    ---@type int
    self.WorldPosYShaderID = CS_Shader.PropertyToID("_WorldPosY")
    ---@type int
    self.WorldPosZShaderID = CS_Shader.PropertyToID("_WorldPosZ")
    ---@type int
    self.PositionMapPixelIndexID = CS_Shader.PropertyToID("_PixelIndex")
end

function UIPaintingCtrl:Setup(clearColor, material, mode)
    self.clearColor = clearColor or Color.white
    self.commandBuffer = CS.UnityEngine.Rendering.CommandBuffer()
    self.commandBuffer.name = "UIPainting"
    self.commandBuffer:Clear()

    self.rectTransform = self:GetComponent(nil, "RectTransform")
    self.rectWidth = self.rectTransform.rect.width
    self.rectHeight = self.rectTransform.rect.height

    self.material = material

    self.lineWidth = self.material:GetFloat("_LineWidth") or 20
    self.underlayWidth = self.material:GetFloat("_UnderlayWidth") or 40

    self.mainCamera = GlobalCameraMgr.GetUnityMainCamera()
    self.uiCamera = UIMgr.GetUICamera()
    local halfWidth = self.rectWidth * 0.5
    local halfHeight = self.rectHeight * 0.5

    self.rtWidth = halfWidth
    self.rtHeight = halfHeight

    self.vfx = self.gameObject:GetComponentInChildren(typeof(CS.UnityEngine.VFX.VisualEffect))

    self.colorType = mode & UIPaintingConst.DrawType.COLOR > 0
    self.textureType = mode & UIPaintingConst.DrawType.TEXTURE > 0
    self.vfxType = (mode & UIPaintingConst.DrawType.VFX > 0) and (not GameObjectUtil.IsNull(self.vfx))

    if self.colorType or self.textureType then
        self.renderTexture = RenderTextureUtil.GetRt(self.rtWidth, self.rtHeight, 0, CS.UnityEngine.RenderTextureFormat.ARGB32)
        self.renderTexture:Create()
        self.renderTargetId = CS.UnityEngine.Rendering.RenderTargetIdentifier(self.renderTexture)
    end

    if self.vfxType then
        self.positionMapRT = RenderTextureUtil.GetRt(self.positionMapWidth, self.positionMapHeight, 0, CS.UnityEngine.RenderTextureFormat.ARGBHalf)
        self.positionMapRT:Create()
        self.positionMapRTId = CS.UnityEngine.Rendering.RenderTargetIdentifier(self.positionMapRT)
    end

    self.worldToViewMatrix = self.uiCamera.worldToCameraMatrix
    self.projMatrix = CS_Matrix.Ortho(-halfWidth, halfWidth, -halfHeight, halfHeight, 0.2, 1000)

    self:_InitQuadMesh()
    self:RePaint()
end

function UIPaintingCtrl:Clear()
    if self.commandBuffer then
        self.commandBuffer:Release()
        self.commandBuffer = nil
    end

    if self.renderTexture then
        RenderTextureUtil.ReleaseRt(self.renderTexture)
        self.renderTexture = nil
    end

    if self.positionMapRT then
        RenderTextureUtil.ReleaseRt(self.positionMapRT)
        self.positionMapRT = nil
    end

    self.quadMesh = nil
    self.vfx = nil
end

function UIPaintingCtrl:GetRenderTexture()
    return self.renderTexture
end

function UIPaintingCtrl:BeginPaint()
    if not self.isDrawing then
        self.isDrawing = true
        self.frameCount = 0



        if self.vfxType and not GameObjectUtil.IsNull(self.vfx) then
            local camTrans = self.mainCamera.transform
            local vfxTrans = self.vfx.transform

            vfxTrans.parent = camTrans
            vfxTrans.position = camTrans.position
            vfxTrans.rotation = Quaternion.identity
            vfxTrans.localScale = Vector3.one

            self.mainCameraPos = camTrans.position

            GameObjectUtil.SetLayer(self.vfx.gameObject, Const.LayerMask.DEFAULT, true)

            self.vfx:Reinit()
            self.vfx:SetTexture("position map", self.positionMapRT)
        end
    end
end

function UIPaintingCtrl:EndPaint()
    if self.isDrawing then
        self.isDrawing = false

        if self.vfxType and not GameObjectUtil.IsNull(self.vfx) then
            self.vfx.transform.parent = self.rectTransform
        end
    end
end

function UIPaintingCtrl:RePaint()
    if self.commandBuffer then
        self.commandBuffer:Clear()
        if self.renderTexture then
            self.commandBuffer:SetRenderTarget(self.renderTargetId)
            self.commandBuffer:ClearRenderTarget(false, true, self.clearColor)
        end

        if self.positionMapRT then
            self.commandBuffer:SetRenderTarget(self.positionMapRTId)
            self.commandBuffer:ClearRenderTarget(false, true, self.positionMapClearColor)
        end

        CS_Graphics.ExecuteCommandBuffer(self.commandBuffer)
    end
end

---@param pos Vector3
---@param deltaPos Vector3
function UIPaintingCtrl:Painting(pos, deltaPos)
    if self.isDrawing then
        local _, localPos = RectTransformUtil.GetLocalPosFromScreenPos(self.rectTransform, pos)
        if self.frameCount > 0 then
            self.beginPoint.x = self.endPoint.x
            self.beginPoint.y = self.endPoint.y
            if deltaPos.magnitude > 0 and self.commandBuffer then
                self.endPoint.x = localPos.x
                self.endPoint.y = localPos.y
                local vec = self.endPoint - self.beginPoint
                self.segmentLength = vec.magnitude
                vec = vec.normalized

                self.drawDir.x = vec.x
                self.drawDir.y = vec.y

                self.drawRotation:SetFromToRotation(Vector3.up, self.drawDir)

                self.commandBuffer:Clear()

                ---处于性能和设计上的考虑，贴图绘制模式和实线绘制模式，两两互斥
                if self.textureType then
                    self:_DrawTexturePass()
                elseif self.colorType then
                    self:_DrawLinePass()
                end

                if self.vfxType then
                    self:_DrawPositionMapPass(pos)
                end

                CS_Graphics.ExecuteCommandBuffer(self.commandBuffer)
            end
        else
            self.endPoint.x = localPos.x
            self.endPoint.y = localPos.y
        end

        self.frameCount = self.frameCount + 1
    end
end

---绘制贴图
function UIPaintingCtrl:_DrawTexturePass()
    local threshold = 0.3 * self.lineWidth
    local drawCalls = math.floor(self.segmentLength / threshold)

    self.drawScale.x = self.lineWidth
    self.drawScale.y = self.lineWidth
    self.drawScale.z = self.lineWidth

    if drawCalls > 1 then
        for i=1, drawCalls do
            self.drawPoint.x = self.beginPoint.x + i * threshold * self.drawDir.x
            self.drawPoint.y = self.beginPoint.y + i * threshold * self.drawDir.y
            self.drawPoint.z = 100

            local TRSMatrix = CS_Matrix.TRS(self.drawPoint, self.drawRotation, self.drawScale)
            self.commandBuffer:SetRenderTarget(self.renderTargetId)
            self.commandBuffer:ClearRenderTarget(false, false, self.clearColor)
            self.commandBuffer:SetViewProjectionMatrices(self.worldToViewMatrix, self.projMatrix)
            self.commandBuffer:DrawMesh(self.quadMesh, TRSMatrix, self.material, 0, 0)
        end
    end

    self.drawPoint.x = self.endPoint.x
    self.drawPoint.y = self.endPoint.y
    self.drawPoint.z = 100

    local TRSMatrix = CS_Matrix.TRS(self.drawPoint, self.drawRotation, self.drawScale)
    self.commandBuffer:SetRenderTarget(self.renderTargetId)
    self.commandBuffer:ClearRenderTarget(false, false, self.clearColor)
    self.commandBuffer:SetViewProjectionMatrices(self.worldToViewMatrix, self.projMatrix)
    self.commandBuffer:DrawMesh(self.quadMesh, TRSMatrix, self.material, 0, 0)
end

---绘制实线
function UIPaintingCtrl:_DrawLinePass()
    local scale = 1.5 * self.underlayWidth + self.segmentLength
    self.drawScale.x = scale
    self.drawScale.y = scale
    self.drawScale.z = scale

    self.drawPoint.x = (self.beginPoint.x + self.endPoint.x) * 0.5
    self.drawPoint.y = (self.beginPoint.y + self.endPoint.y) * 0.5
    self.drawPoint.z = 100

    local startU = (self.beginPoint.x + self.rectWidth * 0.5) / self.rectWidth
    local startV = (self.beginPoint.y + self.rectHeight * 0.5) / self.rectHeight
    local endU = (self.endPoint.x + self.rectWidth * 0.5) / self.rectWidth
    local endV = (self.endPoint.y + self.rectHeight * 0.5) / self.rectHeight

    self.material:SetFloat(self.StartXShaderID, startU)
    self.material:SetFloat(self.StartYShaderID, startV)
    self.material:SetFloat(self.EndXShaderID, endU)
    self.material:SetFloat(self.EndYShaderID, endV)
    self.material:SetFloat(self.TextureWidthID, self.rtWidth)
    self.material:SetFloat(self.TextureHeightID, self.rtHeight)

    local TRSMatrix = CS_Matrix.TRS(self.drawPoint, self.drawRotation, self.drawScale)
    self.commandBuffer:SetRenderTarget(self.renderTargetId)
    self.commandBuffer:ClearRenderTarget(false, false, self.clearColor)
    self.commandBuffer:SetViewProjectionMatrices(self.worldToViewMatrix, self.projMatrix)
    self.commandBuffer:DrawMesh(self.quadMesh, TRSMatrix, self.material, 0, 1)
end

---绘制 VFX
function UIPaintingCtrl:_DrawPositionMapPass(pos)
    if self.commandBuffer and self.positionMapRT then
        if not GameObjectUtil.IsNull(self.vfx) then
            self.drawPoint.x = pos.x
            self.drawPoint.y = pos.y
            self.drawPoint.z = 1
            local worldPos = GlobalCameraMgr.ScreenToWorldPoint(self.drawPoint)
            worldPos = worldPos - self.mainCameraPos
            local index = 0
            if self.frameCount <= self.positionMapPixels then
                index = self.frameCount - 1
            else
                index = math.random(0, self.positionMapPixels - 1)
            end
            index = math.clamp(index, 0, self.positionMapPixels - 1)

            self.material:SetFloat(self.WorldPosXShaderID, worldPos.x)
            self.material:SetFloat(self.WorldPosYShaderID, worldPos.y)
            self.material:SetFloat(self.WorldPosZShaderID, worldPos.z)
            self.material:SetInt(self.PositionMapPixelIndexID, index)

            self.commandBuffer:SetRenderTarget(self.positionMapRTId)
            self.commandBuffer:ClearRenderTarget(false, false, self.positionMapClearColor)
            self.commandBuffer:DrawMesh(self.quadMesh, CS_Matrix.identity, self.material, 0, 2)
        end
    end
end

function UIPaintingCtrl:_InitQuadMesh()
    if self.quadMesh == nil then
        self.quadMesh = CS.UnityEngine.Mesh()

        local vertices = {
            Vector3.new(-1,-1,0),
            Vector3.new(1,-1,0),
            Vector3.new(1,1,0),
            Vector3.new(-1,1,0),
        }

        local uvs = {
            Vector2.new(0, 0),
            Vector2.new(1, 0),
            Vector2.new(1, 1),
            Vector2.new(0, 1),
        }

        local indices = {
            0,1,2,
            2,3,0
        }

        self.quadMesh:SetVertices(vertices);
        self.quadMesh:SetUVs(0, uvs);
        self.quadMesh:SetTriangles(indices, 0, true);
    end
end

function UIPaintingCtrl:OnDestroy()
    self:Clear()
end

return UIPaintingCtrl