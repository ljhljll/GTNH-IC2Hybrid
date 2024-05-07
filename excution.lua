local component = require("component")
local robot = require("robot")
local sides = require("sides")
local ge = component.geolyzer
local ic = component.inventory_controller
local hybridBlockCrop = require("HybridBlockCrop")
local breedingName

---检索机器人物品栏中的指定物品
---@param name string 要检索的物品名
---@param hasSelect boolean as 是否要选中找到的槽位
---@param startIndex integer as 从第几位开始查找
---@return integer as 找到的槽位
---@return table as 槽位的物品信息
local function findBotInventory(name, hasSelect, startIndex)
    local index = -1
    startIndex = startIndex or 1
    local itemInfo
    for i = startIndex, robot.inventorySize(), 1 do
        -- 获取机器人物品栏中的种子信息并封装
        itemInfo = ic.getStackInInternalSlot(i)

        if (itemInfo.name == name) then
            index = i
            break
        end
    end
    if itemInfo.name == "IC2:itemCropSeed" then
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

local function changeParent(leftHybrid, rightHybrid, middleHybrid)
    if (leftHybrid:compareHybrid(rightHybrid)) then
        robot.turnLeft()
        robot.forward()
        robot.turnRight()
        robot.swing()
        local index = 1
        while index <= robot.inventorySize() do
            local itemIndex, itemInfo = findBotInventory(breedingName, false, index)
            if middleHybrid:equals(itemInfo) then
                findBotInventory("IC2:blockCrop", true)
                robot.place()
                robot.select(itemIndex)
                ic.equip()
                robot.use()
                ic.equip()

                -- 回到中间
                robot.turnRight()
                robot.forward()
                robot.turnLeft()
                break;
            end
            index = index + 1
        end
        print("未拾取到育种成功的种子,程序错误")
        os.exit(0)
    else
        robot.turnRight()
        robot.forward()
        robot.turnLeft()
        robot.swing()
        local index = 1
        while index <= robot.inventorySize() do
            local itemIndex, itemInfo = findBotInventory(breedingName, false, index)
            if middleHybrid:equals(itemInfo) then
                findBotInventory("IC2:blockCrop", true)
                robot.place()
                robot.select(itemIndex)
                ic.equip()
                robot.use()
                ic.equip()

                -- 回到中间
                robot.turnLeft()
                robot.forward()
                robot.turnRight()
                break;
            end
            index = index + 1
        end
        print("未拾取到育种成功的种子,程序错误")
        os.exit(0)
    end
end

local function waitMiddleGrow(middleHybrid)
    while true do
        if middleHybrid.stage == 3 then
            print("作物成熟")
            break;
        else
            print("作物未成熟,生长阶段:" .. middleHybrid.stage)
            os.sleep(5)
        end
    end
end

--放置杂交架
local function plantBlockCrop()
    -- 面前有物品挡住，尝试挖掉
    if hybridBlockCrop:getName(ge.analyze(sides.front)) ~= "minecraft:air" then
        robot.swing()
    end

    local itemIndex = findBotInventory("IC2:blockCrop", true)
    if itemIndex == -1 then
        print("机器人物品栏中没有作物架")
        return
    end
    robot.place()
    ic.equip()
    robot.use(sides.front)
    ic.equip()
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
    robot.turnLeft()
    robot.forward()
    robot.turnRight()
    local leftBlockCropGe = ge.analyze(sides.front)
    local leftHybrid = hybridBlockCrop:newByTarget(leftBlockCropGe)
    print("左侧植物名:" .. leftHybrid.name .. " 属性为:")
    print("ga:" .. leftHybrid.ga)
    print("gr:" .. leftHybrid.gr)
    print("re:" .. leftHybrid.re)

    robot.turnRight()
    robot.forward()
    robot.forward()
    robot.turnLeft()
    local rightBlockCropGe = ge.analyze(sides.front)
    local rightHybrid = hybridBlockCrop:newByTarget(rightBlockCropGe)
    print("右侧植物名:" .. rightHybrid.name .. " 属性为:")
    print("ga:" .. rightHybrid.ga)
    print("gr:" .. rightHybrid.gr)
    print("re:" .. rightHybrid.re)

    for i = 5, 0, -1 do
        print(i .. "秒后开始育种")
        os.sleep(1)
    end

    robot.turnLeft()
    robot.forward()
    robot.turnRight()

    return leftHybrid, rightHybrid
end

-- 育种
local function breeding()
    -- 检测左右父母本植物是否成熟以及获取属性
    local leftHybrid, rightHybrid = checkParentBlockCropInfo()
    if leftHybrid.name == nil or leftHybrid.name == "minecraft:air" then
        print("左侧植物为空,无法开始育种")
        return
    end

    if rightHybrid.name == nil or rightHybrid.name == "minecraft:air" then
        print("右侧植物为空,无法开始育种")
        return
    end
    print("请输入想育种的植物名")
    breedingName = io.read()
    while true do
        local middleInfo = ge.analyze(sides.front)
        local middleHybrid = hybridBlockCrop:newByTarget(middleInfo)
        if (middleHybrid.name == "IC2:blockCrop") then
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

local function initialize()
    while true do
        print("请输入指令(1)育种 (2)杂交 (3)繁殖 (-1)退出")
        local select = io.read()
        if select == "1" then
            breeding()
        elseif select == "2" then
        elseif select == "3" then
        elseif select == "-1" then
            print("程序退出")
            os.exit(0)
        else
            print("指令错误")
        end
    end
end

initialize()
