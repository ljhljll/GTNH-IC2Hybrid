---@class HybridBlockCrop @define 作物架类
local HybridBlockCrop = {
    ga = 0,
    gr = 0,
    re = 0,
    name = nil,
    stage = 0
}

HybridBlockCrop.__index = HybridBlockCrop

---默认构造方法
---@return table 作物架实例对象
function HybridBlockCrop:new()
    local t = {}
    setmetatable(t, HybridBlockCrop)
    return t
end

---根据geolyzer分析器扫描出的方块信息创建作物架对象
---@param geInfo table
---@return table
function HybridBlockCrop:newByTarget(geInfo)
    local t = {}
    setmetatable(t, HybridBlockCrop)
    local entityGa, entityGr, entityRe, entityStage, entityName = t:getHybridInformation(geInfo)
    t.ga = entityGa
    t.gr = entityGr
    t.re = entityRe
    t.name = entityName
    t.stage = entityStage
    return t
end

--- 根据ge信息获取到方块名
--- @param geInfo table
--- @return string 扫描的实体名
function HybridBlockCrop:getName(geInfo)
    local name = geInfo["crop:name"] or geInfo["name"]
    return name
end

---根据ge信息获取到作物架的三种植属性
---@param geInfo table
---@return number @comment 产量
---@return number @comment 生长速度
---@return number @comment 抗性
---@return number @comment 生长阶段
---@return string @comment 植物名
function HybridBlockCrop:getHybridInformation(geInfo)
    local gain = geInfo["crop:gain"] or -1
    local growth = geInfo["crop:growth"] or -1
    local resistance = geInfo["crop:resistance"] or -1
    local stage = geInfo["crop:size"] or -1
    local name = geInfo["crop:name"] or geInfo["name"]
    return gain, growth, resistance, stage, name
end

---获取作物生长阶段
---@param geInfo table
---@return number
function HybridBlockCrop:getGrowthStage(geInfo)
    local cropSize = geInfo["crop:size"] or -1
    return cropSize
end

function HybridBlockCrop:compareHybrid(otherHybrid)
    local maxA = self.ga + self.gr * 2 + self.re
    local maxB = otherHybrid.ga + otherHybrid.gr * 2 + otherHybrid.re

    return maxA > maxB
end

function HybridBlockCrop:equals(otherHybrid)
    return self.name == otherHybrid.name and self.ga == otherHybrid.gr and self.re == otherHybrid.re
end

return HybridBlockCrop
