local resourceName = GetCurrentResourceName()

local state = {
    static = {},
    dynamic = {},
    menuOpen = false
}

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

local function normalizeBlipData(data)
    if type(data) ~= 'table' then
        return nil
    end

    local coords = normalizeCoords(data.coords)
    if not coords then
        return nil
    end

    return {
        coords = coords,
        sprite = tonumber(data.sprite) or Config.Defaults.sprite,
        color = tonumber(data.color) or Config.Defaults.color,
        scale = tonumber(data.scale) or Config.Defaults.scale,
        shortRange = data.shortRange,
        alpha = tonumber(data.alpha) or Config.Defaults.alpha,
        display = tonumber(data.display) or Config.Defaults.display,
        category = tonumber(data.category) or Config.Defaults.category,
        heading = tonumber(data.heading) or Config.Defaults.heading,
        route = data.route == true or Config.Defaults.route,
        routeColor = tonumber(data.routeColor) or Config.Defaults.routeColor,
        highDetail = data.highDetail == true or Config.Defaults.highDetail,
        name = data.name or Config.Defaults.name
    }
end

local function serializeBlip(id, entry)
    return {
        id = id,
        name = entry.data.name,
        sprite = entry.data.sprite,
        color = entry.data.color,
        scale = entry.data.scale,
        shortRange = entry.data.shortRange ~= false,
        coords = {
            x = entry.data.coords.x,
            y = entry.data.coords.y,
            z = entry.data.coords.z
        }
    }
end

local function buildBlipList(collection)
    local list = {}

    for id, entry in pairs(collection) do
        list[#list + 1] = serializeBlip(id, entry)
    end

    table.sort(list, function(a, b)
        return a.id < b.id
    end)

    return list
end

local function pushUiState()
    SendNUIMessage({
        action = 'state',
        staticBlips = buildBlipList(state.static),
        dynamicBlips = buildBlipList(state.dynamic)
    })
end

local function setMenuOpen(open)
    state.menuOpen = open == true
    SetNuiFocus(state.menuOpen, state.menuOpen)
    SendNUIMessage({ action = 'toggle', open = state.menuOpen })

    if state.menuOpen then
        pushUiState()
    end
end

local function destroyBlip(handle)
    if handle and DoesBlipExist(handle) then
        RemoveBlip(handle)
    end
end

local function createBlip(data)
    local info = normalizeBlipData(data)
    if not info then
        return nil, nil
    end

    local blip = AddBlipForCoord(info.coords.x, info.coords.y, info.coords.z)

    SetBlipSprite(blip, info.sprite)
    SetBlipDisplay(blip, info.display)
    SetBlipScale(blip, info.scale)
    SetBlipColour(blip, info.color)
    SetBlipAsShortRange(blip, info.shortRange ~= false)
    SetBlipAlpha(blip, info.alpha)
    SetBlipCategory(blip, info.category)
    SetBlipHighDetail(blip, info.highDetail == true)
    SetBlipRotation(blip, math.floor(info.heading))

    if info.route == true then
        SetBlipRoute(blip, true)
        SetBlipRouteColour(blip, info.routeColor)
    end

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(info.name)
    EndTextCommandSetBlipName(blip)

    return blip, info
end

local function upsertBlip(collection, id, data)
    if collection[id] then
        destroyBlip(collection[id].handle)
        collection[id] = nil
    end

    local handle, info = createBlip(data)
    if handle and info then
        collection[id] = { handle = handle, data = info }
    end

    if state.menuOpen then
        pushUiState()
    end
end

local function removeBlip(collection, id)
    local entry = collection[id]
    if not entry then
        return
    end

    destroyBlip(entry.handle)
    collection[id] = nil

    if state.menuOpen then
        pushUiState()
    end
end

local function clearCollection(collection)
    for id, entry in pairs(collection) do
        destroyBlip(entry.handle)
        collection[id] = nil
    end

    if state.menuOpen then
        pushUiState()
    end
end

local function loadStaticBlips()
    clearCollection(state.static)

    for index, data in ipairs(Config.StaticBlips or {}) do
        local key = data.id or ('static_%s'):format(index)
        upsertBlip(state.static, key, data)
    end

    notify(('Loaded %d static blips.'):format(#(Config.StaticBlips or {})))
end

RegisterNetEvent('c8n_blips:client:syncBlips', function(blips)
    clearCollection(state.dynamic)

    for id, data in pairs(blips or {}) do
        if type(id) == 'string' then
            upsertBlip(state.dynamic, id, data)
        end
    end
end)

RegisterNetEvent('c8n_blips:client:addBlip', function(id, data)
    if type(id) ~= 'string' then
        return
    end

    upsertBlip(state.dynamic, id, data)
end)

RegisterNetEvent('c8n_blips:client:removeBlip', function(id)
    if type(id) ~= 'string' then
        return
    end

    removeBlip(state.dynamic, id)
end)

RegisterNetEvent('c8n_blips:client:clearBlips', function()
    clearCollection(state.dynamic)
end)

RegisterNUICallback('close', function(_, cb)
    setMenuOpen(false)
    cb({ ok = true })
end)

RegisterNUICallback('createBlip', function(payload, cb)
    if not payload then
        cb({ ok = false, message = 'Missing payload.' })
        return
    end

    local blipData = {
        id = payload.id,
        name = payload.name,
        sprite = payload.sprite,
        color = payload.color,
        scale = payload.scale,
        shortRange = payload.shortRange,
        coords = {
            x = payload.x,
            y = payload.y,
            z = payload.z
        }
    }

    TriggerServerEvent('c8n_blips:server:addBlipFromClient', blipData)
    cb({ ok = true })
end)

RegisterNUICallback('removeBlip', function(payload, cb)
    if type(payload) ~= 'table' or type(payload.id) ~= 'string' then
        cb({ ok = false, message = 'Invalid id.' })
        return
    end

    TriggerServerEvent('c8n_blips:server:removeBlipFromClient', payload.id)
    cb({ ok = true })
end)

RegisterNUICallback('setRoute', function(payload, cb)
    if type(payload) ~= 'table' or type(payload.id) ~= 'string' then
        cb({ ok = false, message = 'Invalid id.' })
        return
    end

    local entry = state.dynamic[payload.id] or state.static[payload.id]
    if not entry or not entry.handle then
        cb({ ok = false, message = 'Blip not found.' })
        return
    end

    SetBlipRoute(entry.handle, true)
    cb({ ok = true })
end)

RegisterCommand(Config.Commands.openMenu, function()
    setMenuOpen(not state.menuOpen)
end, false)

RegisterKeyMapping(Config.Commands.openMenu, 'Open c8n_blips menu', 'keyboard', Config.Commands.defaultKey)

AddEventHandler('onClientResourceStart', function(startedResource)
    if startedResource ~= resourceName then
        return
    end

    loadStaticBlips()
    TriggerServerEvent('c8n_blips:server:requestSync')
end)

AddEventHandler('onClientResourceStop', function(stoppedResource)
    if stoppedResource ~= resourceName then
        return
    end

    setMenuOpen(false)
    clearCollection(state.dynamic)
    clearCollection(state.static)
end)
