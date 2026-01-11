package.loaded.config=nil

local ae2 = require("src.AE2")
local cfg = require("config")
local util = require("src.Utility") 

local items = cfg.items
local sleepInterval = cfg.sleep

local function sleepWithHeartbeat(totalSeconds)
  local HEARTBEAT = 60
  local remaining = totalSeconds

  while remaining > 0 do
    local chunk = (remaining > HEARTBEAT) and HEARTBEAT or remaining
    os.sleep(chunk)
    remaining = remaining - chunk

    if totalSeconds > HEARTBEAT and remaining > 0 then
      logInfo("Running...")
    end
  end
end

local count = 0
for _ in pairs(items) do
  count = count + 1
end
logInfo("Loaded " .. count .. " items to maintain.")

logInfo("Running...")

while true do
  local itemsCrafting = ae2.checkIfCrafting()

  for item, config in pairs(items) do
    if itemsCrafting[item] ~= true then
      local success, answer = ae2.requestItem(item, config[1], config[2], config[3])
      if success == false and answer ~= nil then
        logInfo("Error: " .. answer)
      end
    end
  end

  sleepWithHeartbeat(sleepInterval)
end