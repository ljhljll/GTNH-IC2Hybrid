---@class HybridBlockCrop @define 作物架类
local HybridBlockCrop = {
    ga = 0,
    gr = 0,
    re = 0
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
    print(next(geInfo))
    local t = {}
    setmetatable(t, HybridBlockCrop)
    local entityGa, entityGr, entityRe = t:getHybridInformation(geInfo)
    t.ga = entityGa
    t.gr = entityGr
    t.re = entityRe
    return t
end

--- 根据ge信息获取到方块名
--- @param geInfo table
--- @return string 扫描的实体名
function HybridBlockCrop:getName(geInfo)
    local name
    for key, value in pairs(geInfo) do
        if key == "crop:name" or key == "name" then
            name = value
            break
        end
    end
    return name
end

---根据ge信息获取到作物架的三种植属性
---@param geInfo table
---@return number @comment 产量
---@return number @comment 生长速度
---@return number @comment 抗性
function HybridBlockCrop:getHybridInformation(geInfo)
    local gain, growth, resistance
    for key, value in pairs(geInfo) do
        if gain ~= nil and growth ~= nil and resistance ~= nil then
            break
        end

        if key == "crop:gain" then
            gain = value
        elseif key == "crop:growth" then
            growth = value
        elseif key == "crop:resistance" then
            resistance = value
        end
    end
    return gain, growth, resistance
end

---获取作物生长阶段
---@param geInfo table
---@return number
function HybridBlockCrop:getGrowthStage(geInfo)
    local stage
    for key, value in pairs(geInfo) do
        if key == "crop:size" then
            stage = value
            break
        end
    end
    return stage
end

return HybridBlockCrop
