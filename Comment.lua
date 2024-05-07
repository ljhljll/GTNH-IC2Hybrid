local component = require("component")
local robot = require("robot")
local sides = require("sides")
local ge = component.geolyzer
local hybridBlockCrop = require("HybridBlockCrop")
local comment = {}
local botMove = require("RobotMove")
local itemAirName = "minecraft:air"
local blockCropName = "IC2:blockCrop"
local itemCropSeedName = "IC2:itemCropSeed"
local ic = component.inventory_controller

---获取左右父母本植物的属性信息
---@return table @comment 左边植物属性
---@return table @comment 右边植物属性
function comment.checkParentBlockCropInfo()
    botMove.leftWard()

    local leftBlockCropGe = ge.analyze(sides.front)
    local leftHybrid = hybridBlockCrop:newByTarget(leftBlockCropGe)
    print("左侧植物名:" .. leftHybrid.name .. " 属性为:")
    print("ga:" .. leftHybrid.ga)
    print("gr:" .. leftHybrid.gr)
    print("re:" .. leftHybrid.re)

    botMove.rightWard(2)

    local rightBlockCropGe = ge.analyze(sides.front)
    local rightHybrid = hybridBlockCrop:newByTarget(rightBlockCropGe)
    print("右侧植物名:" .. rightHybrid.name .. " 属性为:")
    print("ga:" .. rightHybrid.ga)
    print("gr:" .. rightHybrid.gr)
    print("re:" .. rightHybrid.re)

    botMove.leftWard()

    return leftHybrid, rightHybrid
end

---检索机器人物品栏中的指定物品
---@param name string 要检索的物品名
---@param hasSelect boolean as 是否要选中找到的槽位
---@param startIndex integer as 从第几位开始查找
---@return integer as 找到的槽位
---@return table as 槽位的物品信息 如果是ic2种子则会返回封装了基础属性的table
function comment.findBotInventory(name, hasSelect, startIndex)
    local index = -1
    startIndex = startIndex or 1
    local itemInfo
    for i = startIndex, robot.inventorySize(), 1 do
        itemInfo = ic.getStackInInternalSlot(i)

        if itemInfo ~= nil and itemInfo.name == name then
            index = i
            break
        end
    end
    -- 获取机器人物品栏中的种子信息并封装
    if name == itemCropSeedName and itemInfo ~= nil and itemInfo.name == itemCropSeedName then
        local itemSpring = hybridBlockCrop:new()
        itemSpring.ga = itemInfo.crop.gain
        itemSpring.gr = itemInfo.crop.growth
        itemSpring.re = itemInfo.crop.resistance
        itemSpring.name = itemInfo.crop.name
        itemInfo = itemSpring
    end
    if index ~= -1 and hasSelect then
        robot.select(index)
    end
    return index, itemInfo
end

--放置杂交架
function comment.plantBlockCrop()
    -- 面前有物品挡住，尝试挖掉
    if hybridBlockCrop:getName(ge.analyze(sides.front)) ~= itemAirName then
        robot.swing()
    end

    while true do
        local itemIndex = comment.findBotInventory(blockCropName, true)
        if itemIndex ~= -1 then
            break
        else
            print("机器人物品栏中没有作物架,请添加")
            for i = 5, 1, -1 do
                print(i .. "秒后重新检测")
            end
        end
    end
    robot.place()
    ic.equip()
    robot.use(sides.front)
    ic.equip()
end

return comment
