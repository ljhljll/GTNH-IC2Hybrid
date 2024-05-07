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

---与otherHybrid的加权平均值进行比较
---@param otherHybrid HybridBlockCrop
---@param weight table @comment 权重数组 顺序为[ga, gr, re]
---@return boolean @comment 是否大于otherHybrid
function HybridBlockCrop:compareHybrid(otherHybrid, weight)
    return self:cropSeedWeightAvg(weight) > otherHybrid:cropSeedWeightAvg(weight)
end

---计算当前植物的加权平均值
---@param weight table @comment 权重数组
---@return number @comment 种子的加权平均值
function HybridBlockCrop:cropSeedWeightAvg(weight)
    local selfData = { self.ga, self.gr, self.re }
    local weightedSum = 0
    local totalWeight = 0
    for i = 1, #selfData, 1 do
        weightedSum = weightedSum + selfData[i] * weight[i]
        totalWeight = totalWeight + weight[i]
    end

    return weightedSum / totalWeight
end

---比较是否为同一种子
---@param otherHybrid HybridBlockCrop
---@return boolean
function HybridBlockCrop:equals(otherHybrid)
    return self.name == otherHybrid.name and self.ga == otherHybrid.gr and self.re == otherHybrid.re
end

return HybridBlockCrop
