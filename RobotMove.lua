local component = require("component")
local robot = require("robot")
local sides = require("sides")

---向前走一步(如遇到障碍物或没电则反复重试)
local function tryForward()
    local forwardFlag
    repeat
        forwardFlag = robot.forward()
    until forwardFlag
end

---向左平移 默认移动1步
---@param step integer @comment 平移{step}步
local function leftWard(step)
    step = step or 1
    robot.turnLeft()
    for i = 1, step, 1 do
        robot.forward()
    end
    robot.turnRight()
end

---向右平移 默认移动1步
---@param step integer @comment 平移{step}步
local function rightWard(step)
    step = step or 1
    robot.turnRight()
    for i = 1, step, 1 do
        tryForward()
    end
    robot.turnLeft()
end

return {
    leftWard = leftWard,
    rightWard = rightWard,
    tryForward = tryForward
}
