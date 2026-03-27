local resourceName = GetCurrentResourceName()
local dynamicBlips = {}

local function notify(message)
    print(('[%s] %s'):format(resourceName, message))
end

local function normalizeCoords(coords)
    if type(coords) == 'vector3' then
        return coords
    end

    if type(coords) ~= 'table' then
        return nil
    end

    local x = tonumber(coords.x)
    local y = tonumber(coords.y)
    local z = tonumber(coords.z)

    if not x or not y or not z then
        return nil
    end

    return vector3(x, y, z)
end

local function sanitizeId(id)
    if type(id) ~= 'string' then
        return nil
    end

    local cleaned = id:lower():gsub('%s+', '_'):gsub('[^%w_%-]', '')
    if cleaned == '' then
        return nil
    end

    return cleaned
end

local function sanitizeBlipData(data)
    if type(data) ~= 'table' then
        return nil
    end

    local coords = normalizeCoords(data.coords)
    if not coords then
        return nil
    end

    return {
        coords = coords,
        name = data.name,
        sprite = tonumber(data.sprite),
        color = tonumber(data.color),
        scale = tonumber(data.scale),
        shortRange = data.shortRange == true,
        alpha = tonumber(data.alpha),
        display = tonumber(data.display),
        category = tonumber(data.category),
        heading = tonumber(data.heading),
        route = data.route == true,
        routeColor = tonumber(data.routeColor),
        highDetail = data.highDetail == true
    }
end

local function addGlobalBlip(id, data, target)
    if type(id) ~= 'string' or id == '' then
        return false, 'Invalid blip id.'
    end

    local normalizedData = sanitizeBlipData(data)
    if not normalizedData then
        return false, 'Invalid blip payload.'
    end

    dynamicBlips[id] = normalizedData

    if target then
        TriggerClientEvent('c8n_blips:client:addBlip', target, id, normalizedData)
    else
        TriggerClientEvent('c8n_blips:client:addBlip', -1, id, normalizedData)
    end

    return true
end

local function removeGlobalBlip(id, target)
    if type(id) ~= 'string' or dynamicBlips[id] == nil then
        return false
    end

    dynamicBlips[id] = nil

    if target then
        TriggerClientEvent('c8n_blips:client:removeBlip', target, id)
    else
        TriggerClientEvent('c8n_blips:client:removeBlip', -1, id)
    end

    return true
end

local function clearGlobalBlips(target)
    dynamicBlips = {}

    if target then
        TriggerClientEvent('c8n_blips:client:clearBlips', target)
    else
        TriggerClientEvent('c8n_blips:client:clearBlips', -1)
    end
end

RegisterNetEvent('c8n_blips:server:requestSync', function()
    local src = source
    TriggerClientEvent('c8n_blips:client:syncBlips', src, dynamicBlips)
end)

RegisterNetEvent('c8n_blips:server:addBlipFromClient', function(payload)
    local src = source

    if Config.AllowClientBlipEditing ~= true then
        return
    end

    local id = sanitizeId(payload and payload.id)
    if not id then
        return
    end

    local ok, err = addGlobalBlip(id, payload, nil)
    if not ok and err then
        notify(('Player %s failed to add blip: %s'):format(src, err))
    end
end)

RegisterNetEvent('c8n_blips:server:removeBlipFromClient', function(id)
    if Config.AllowClientBlipEditing ~= true then
        return
    end

    local cleanedId = sanitizeId(id)
    if not cleanedId then
        return
    end

    removeGlobalBlip(cleanedId, nil)
end)

exports('AddGlobalBlip', function(id, data, target)
    return addGlobalBlip(id, data, target)
end)

exports('RemoveGlobalBlip', function(id, target)
    return removeGlobalBlip(id, target)
end)

exports('ClearGlobalBlips', function(target)
    clearGlobalBlips(target)
end)

exports('GetGlobalBlips', function()
    return dynamicBlips
end)

if Config.EnableDebugCommands then
    RegisterCommand('blips_add_test', function(src)
        local ok, err = addGlobalBlip('debug_test', {
            coords = vector3(215.76, -810.12, 30.73),
            name = 'Debug Test Blip',
            sprite = 280,
            color = 5,
            scale = 0.9
        }, src ~= 0 and src or nil)

        if not ok and err then
            notify(err)
            return
        end

        notify('Added debug test blip.')
    end, true)

    RegisterCommand('blips_remove_test', function(src)
        removeGlobalBlip('debug_test', src ~= 0 and src or nil)
        notify('Removed debug test blip.')
    end, true)
end

notify('Server blip registry initialized.')
