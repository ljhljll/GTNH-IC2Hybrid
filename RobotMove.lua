local component = require("component")
local robot = require("robot")
local sides = require("sides")

local robotMove = {}

---向左平移 默认移动1步
---@param step integer @comment 平移{step}步
function robotMove.leftWard(step)
    step = step or 1
    robot.turnLeft()
    for i = 1, step, 1 do
        robot.forward()
    end
    robot.turnRight()
end

---向右平移 默认移动1步
---@param step integer @comment 平移{step}步
function robotMove.rightWard(step)
    step = step or 1
    robot.turnRight()
    for i = 1, step, 1 do
        robot.forward()
    end
    robot.turnLeft()
end

return robotMove
