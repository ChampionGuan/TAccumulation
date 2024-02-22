local FreeMotionSDFData = {}

FreeMotionSDFData.sdfData = nil
FreeMotionSDFData.filledRegion = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,}
FreeMotionSDFData.filledRegionCount = 102

---获取距离数据索引
function FreeMotionSDFData:GetGetDistanceDataIndex(u, v, offsetX, offsetY)
    local i = math.floor(127 * u + offsetX)
    local j = math.floor(127 * v + offsetY)
    local index = j * 128 + i + 1
    math.clamp(index, 1, 16384) 
    return index
end

---获取距离
function FreeMotionSDFData:GetDistanceData(u, v, offsetX, offsetY)
    local index = self:GetGetDistanceDataIndex(u, v, offsetX, offsetY)
    if not table.isnilorempty(self.sdfData) then
        local dis = self.sdfData[index]
        return (dis - 128) / 256
    end
    return nil
end

---获取填充数据索引
function FreeMotionSDFData:GetFilledDataIndex(u, v, offsetX, offsetY)
    local i = math.floor(15 * u + offsetX)
    local j = math.floor(15 * v + offsetY)
    local index = j * 16 + i + 1
    math.clamp(index, 1, 256) 
    return index
end

---获取填充状态
function FreeMotionSDFData:GetFilledData(u, v, offsetX, offsetY)
    local index = self:GetFilledDataIndex(u, v, offsetX, offsetY)
    if not table.isnilorempty(self.filledRegion) then
        return self.filledRegion[index]
    end
    return nil
end

return FreeMotionSDFData