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
-- 种子属性权重
local cropSeedWeight = { 0.5, 0.35, 0.15 }
local breedingName

local breeding = {}

---检索机器人物品栏中的指定物品
---@param name string 要检索的物品名
---@param hasSelect boolean as 是否要选中找到的槽位
---@param startIndex integer as 从第几位开始查找
---@return integer as 找到的槽位
---@return table as 槽位的物品信息 如果是ic2种子则会返回封装了基础属性的table
local function findBotInventory(name, hasSelect, startIndex)
    local index = -1
    startIndex = startIndex or 1
    local itemInfo
    for i = startIndex, robot.inventorySize(), 1 do
        itemInfo = ic.getStackInInternalSlot(i)

        if (itemInfo.name == name) then
            index = i
            break
        end
    end
    -- 获取机器人物品栏中的种子信息并封装
    if name == itemCropSeedName and itemInfo.name == itemCropSeedName then
        local itemSpring = hybridBlockCrop:new()
        itemSpring.ga = itemInfo.crop.gain
        itemSpring.gr = itemInfo.crop.growth
        itemSpring.re = itemInfo.crop.rsistance
        itemSpring.name = itemInfo.crop.name
        itemInfo = itemSpring
    end
    if index ~= -1 and hasSelect then
        robot.select(index)
    end
    return index, itemInfo
end

--放置杂交架
local function plantBlockCrop()
    -- 面前有物品挡住，尝试挖掉
    if hybridBlockCrop:getName(ge.analyze(sides.front)) ~= itemAirName then
        robot.swing()
    end

    while true do
        local itemIndex = findBotInventory(blockCropName, true)
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

local function waitMiddleGrow(middleHybrid)
    while true do
        if middleHybrid.stage >= 3 then
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
    return middleHybrid:compareHybrid(leftHybrid) or middleHybrid:compareHybrid(rightHybrid)
end

---获取左右父母本植物的属性信息
---@return table @comment 左边植物属性
---@return table @comment 右边植物属性
local function checkParentBlockCropInfo()
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
    print("开始育种")

    return leftHybrid, rightHybrid
end
local function changeParent(leftHybrid, rightHybrid, middleHybrid)
    if not leftHybrid:compareHybrid(rightHybrid) then
        botMove.leftWard()
        robot.swing()
        local index = 1
        while index <= robot.inventorySize() do
            local itemIndex, itemInfo = findBotInventory(itemCropSeedName, false, index)
            -- 检测当前选中的种子是否为子代掉落的种子袋
            if middleHybrid:equals(itemInfo) then
                findBotInventory(blockCropName, true)
                robot.place()
                robot.select(itemIndex)
                ic.equip()
                robot.use()
                ic.equip()

                -- 回到中间
                botMove.rightWard()
                break;
            end
            if itemIndex ~= -1 then
                index = itemIndex
            end
            index = index + 1
        end
        if index > robot.inventorySize() then
            print("未拾取到育种成功的种子,程序错误")
            os.exit(0)
        end
    else
        botMove.rightWard()
        robot.swing()
        local index = 1
        while index <= robot.inventorySize() do
            local itemIndex, itemInfo = findBotInventory(itemCropSeedName, false, index)
            if middleHybrid:equals(itemInfo) then
                findBotInventory(blockCropName, true)
                robot.place()
                robot.select(itemIndex)
                ic.equip()
                robot.use()
                ic.equip()

                -- 回到中间
                botMove.leftWard()
                break;
            end
            if itemIndex ~= -1 then
                index = itemIndex
            end
            index = index + 1
        end
        if index > robot.inventorySize() then
            print("未拾取到育种成功的种子,程序错误")
            os.exit(0)
        end
    end
end

-- 育种
function breeding.breeding()
    -- 检测左右父母本植物是否成熟以及获取属性
    local leftHybrid, rightHybrid = checkParentBlockCropInfo()
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
                plantBlockCrop()
                goto continue
            end
            waitMiddleGrow(middleHybrid)
            robot.swing()
            changeParent(leftHybrid, rightHybrid, middleHybrid)
        else
            plantBlockCrop()
        end
        ::continue::
    end
end

return breeding
