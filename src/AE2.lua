local component = require("component")
local ME = component.me_interface

local AE2 = {}


local itemCache = {}
local cacheTimestamp = 0
local CACHE_DURATION = 600 

local function getCraftableForItem(itemName)
    local currentTime = os.time()
    
    if itemCache[itemName] and currentTime - cacheTimestamp < CACHE_DURATION then
        return itemCache[itemName]
    end
    
    if currentTime - cacheTimestamp >= CACHE_DURATION then
        itemCache = {}
        cacheTimestamp = currentTime
    end
    
    local craftables = ME.getCraftables({["label"] = itemName})
    if #craftables >= 1 then
        itemCache[itemName] = craftables[1]
        return craftables[1]
    end
    
    itemCache[itemName] = nil 
    return nil
end

function AE2.requestItem(name, threshold, count, fluidName)
    local craftable = getCraftableForItem(name)

    if craftable then
        local item = craftable.getItemStack()
        if threshold ~= nil then
            local itemInSystem = nil
            
            if fluidName then
                local fluidTag = '{Fluid:' .. fluidName .. '}'
                itemInSystem = ME.getItemInNetwork("ae2fc:fluid_drop", 0, fluidTag)
            else
                if item.name then
                    if item.tag then
                        itemInSystem = ME.getItemInNetwork(item.name, item.damage or 0, item.tag)
                    end
               
                    if itemInSystem == nil then
                        itemInSystem = ME.getItemInNetwork(item.name, item.damage or 0)
                    end
                end
            end
            
            if(threshold ~= nil and itemInSystem == nil) then
                return table.unpack({false, "Not Found: " .. name .. "/" .. fluidName})
            end
        end
        
        if item.label == name then
            local craft = craftable.request(count)

            while craft.isComputing() == true do
                os.sleep(1)
            end
            if craft.hasFailed() then
                return table.unpack({true, nil})
                -- return table.unpack({false, "Failed to request " .. name .. " x " .. count})
            else
                return table.unpack({true, nil})
                -- return table.unpack({true, "Requested " .. name .. " x " .. count})
            end
        end
    end
    return table.unpack({false, "Not craftable: " .. name .. "/" .. fluidName})
end

function AE2.checkIfCrafting()
    local cpus = ME.getCpus()
    local items = {}
    for k, v in pairs(cpus) do
        local finaloutput = v.cpu.finalOutput()
        if finaloutput ~= nil then
            items[finaloutput.label] = true
        end
    end

    return items
end

function AE2.clearCache()
    itemCache = {}
    cacheTimestamp = 0
end

return AE2