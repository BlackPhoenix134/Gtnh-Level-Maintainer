local ae2 = require("src.AE2")
local cfg = require("config")
local util = require("src.Utility") 

local items = cfg.items
local sleepInterval = cfg.sleep
 
while true do
    local itemsCrafting = ae2.checkIfCrafting()
 
    for item, config in pairs(items) do
        if itemsCrafting[item] == true then
           -- logInfo(item .. " is already being crafted, skipping...")
        else
            local success, answer = ae2.requestItem(item, config[1], config[2], config[3])
            if(success == true and answer ~= nil) then
                logInfo(answer)
            elseif(success == false and answer ~= nil) then
                logInfo("Error: " .. answer)
            end
        end
 
    end
    os.sleep(sleepInterval)
end