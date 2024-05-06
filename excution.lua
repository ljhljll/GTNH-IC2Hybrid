local HybridBlockCrop = require("Hybrid")

local geInfo = {
    ["crop:gain"] = 123,
    ["crop:growth"] = 456,
    ["crop:resistance"] = 789
}

local leftBlockCrop = HybridBlockCrop:newByTarget(geInfo)

print("产量:" .. leftBlockCrop.ga .. ", 生长速度:" .. leftBlockCrop.gr .. ", 抗性:" .. leftBlockCrop.re)
