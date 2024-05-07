local component = require("component")
local robot = require("robot")
local sides = require("sides")
local ge = component.geolyzer
local ic = component.inventory_controller
local itemCropSeedName = "IC2:itemCropSeed"
local blockCropName = "IC2:blockCrop"
local itemAirName = "minecraft:air"
local hybridBlockCrop = require("HybridBlockCrop")
local botMove = require("RobotMove")
local comment = require("Comment")
-- 种子属性权重
local cropSeedWeight = { 0.5, 0.35, 0.15 }
local breedingName



local breeding = {}


local function waitMiddleGrow()
    while true do
        local middleInfo = ge.analyze(sides.front)
        local middleHybrid = hybridBlockCrop:newByTarget(middleInfo)
        if middleHybrid.stage == middleInfo["crop:maxSize"] then
            print("作物成熟")
            break;
        else
            print("作物未成熟,生长阶段:" .. middleHybrid.stage)
            os.sleep(5)
        end
    end
end

local function meetsHybridAttr(leftHybrid, rightHybrid, middleHybrid)
    -- 防止生长属性过高变成杂草
    if middleHybrid.gr > 23 then
        return false
    end
    return middleHybrid:compareHybrid(leftHybrid, cropSeedWeight) or
        middleHybrid:compareHybrid(rightHybrid, cropSeedWeight)
end

local function changeParent(leftHybrid, rightHybrid, middleHybrid)
    local tag = -1
    if not leftHybrid:compareHybrid(rightHybrid, cropSeedWeight) then
        botMove.leftWard()
        local index = 1
        -- 遍历机器人物品栏得杂交
        while index <= robot.inventorySize() do
            local itemIndex, itemInfo = comment.findBotInventory(itemCropSeedName, false, index)
            if itemIndex == -1 then
                index = itemIndex
                break;
            end
            -- 检测当前选中的种子是否为子代掉落的种子袋
            if itemInfo ~= nil and middleHybrid:equals(itemInfo) then
                robot.swing()
                comment.findBotInventory(blockCropName, true)
                robot.place()
                robot.select(itemIndex)
                ic.equip()
                robot.use()
                ic.equip()

                -- 回到中间
                botMove.rightWard()
                return 1
            end
            if itemIndex ~= -1 then
                index = itemIndex
            end
            index = index + 1
        end
        if index == -1 or index > robot.inventorySize() then
            print("未拾取到育种成功的种子,育种失败")
            botMove.rightWard()
        end
    else
        botMove.rightWard()
        local index = 1
        while index <= robot.inventorySize() do
            local itemIndex, itemInfo = comment.findBotInventory(itemCropSeedName, false, index)
            if itemInfo ~= nil and middleHybrid:equals(itemInfo) then
                robot.swing()
                comment.findBotInventory(blockCropName, true)
                robot.place()
                robot.select(itemIndex)
                ic.equip()
                robot.use()
                ic.equip()

                -- 回到中间
                botMove.leftWard()
                return 2
            end
            if itemIndex ~= -1 then
                index = itemIndex
            end
            index = index + 1
        end
        if index == -1 or index > robot.inventorySize() then
            print("未拾取到育种成功的种子,育种失败")
            botMove.leftWard()
        end
    end
end

-- 育种
function breeding.breeding()
    -- 检测左右父母本植物是否成熟以及获取属性
    local leftHybrid, rightHybrid = comment.checkParentBlockCropInfo()
    if leftHybrid.name == nil or leftHybrid.name == itemAirName then
        print("左侧植物为空,无法开始育种")
        return
    end

    if rightHybrid.name == nil or rightHybrid.name == itemAirName then
        print("右侧植物为空,无法开始育种")
        return
    end
    print("请输入想育种的植物名")
    breedingName = io.read()
    while true do
        local middleInfo = ge.analyze(sides.front)
        local middleHybrid = hybridBlockCrop:newByTarget(middleInfo)
        if (middleHybrid.name == blockCropName) then
            -- 未杂交出植物,等待5秒
            os.sleep(5)
        elseif middleHybrid.name == breedingName then
            local flag = meetsHybridAttr(leftHybrid, rightHybrid, middleHybrid)
            if not flag then
                print("未达到期望的杂交属性")
                comment.plantBlockCrop()
                goto continue
            end
            waitMiddleGrow()
            robot.swing()
            -- 等待3秒待机器人捡起种子
            os.sleep(3)
            local tag = changeParent(leftHybrid, rightHybrid, middleHybrid)
            if tag == 1 then
                leftHybrid = middleHybrid
            elseif tag == 2 then
                rightHybrid = middleHybrid
            end
        else
            comment.plantBlockCrop()
        end
        ::continue::
    end
end

return breeding
