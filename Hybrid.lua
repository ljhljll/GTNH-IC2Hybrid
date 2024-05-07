local component = require("component")
local sides = require("sides")
local ge = component.geolyzer
local blockCropName = "IC2:blockCrop"
local itemAirName = "minecraft:air"
local comment = require("Comment")
local hybridBlockCrop = require("HybridBlockCrop")

local breedingName

local hybrid = {}

function hybrid.hybrid()
    local leftHybrid, rightHybrid = comment.checkParentBlockCropInfo()

    if leftHybrid.name == nil or leftHybrid.name == itemAirName then
        print("左侧植物为空,无法开始杂交")
        return
    end

    if rightHybrid.name == nil or rightHybrid.name == itemAirName then
        print("右侧植物为空,无法开始杂交")
        return
    end

    print("请输入杂交植物名")
    breedingName = io.read()
    while true do
        local middleInfo = ge.analyze(sides.front)
        local middleHybrid = hybridBlockCrop:newByTarget(middleInfo)
        if (middleHybrid.name == blockCropName) then
            -- 未杂交出植物,等待5秒
            os.sleep(5)
        elseif middleHybrid.name == breedingName then
            print("已杂交出" .. breedingName .. "作物")
            break
        else
            comment.plantBlockCrop()
        end
    end
end

return hybrid
