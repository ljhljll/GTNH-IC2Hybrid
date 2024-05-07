local component = require("component")
local robot = require("robot")
local sides = require("sides")
local ge = component.geolyzer
local ic = component.inventory_controller
local breeding = require("Breeding")




local function initialize()
    while true do
        print("请输入指令(1)育种 (2)杂交 (3)繁殖 (-1)退出")
        local select = io.read()
        if select == "1" then
            breeding.breeding()
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
