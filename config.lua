Config = {}

Config.Defaults = {
    sprite = 1,
    color = 0,
    scale = 0.8,
    shortRange = true,
    alpha = 255,
    display = 4,
    category = 7,
    heading = 0.0,
    route = false,
    routeColor = 0,
    highDetail = false,
    name = 'Blip'
}

Config.EnableDebugCommands = false
Config.AllowClientBlipEditing = true

Config.Commands = {
    openMenu = 'blips',
    defaultKey = 'F7'
}

Config.StaticBlips = {
    {
        id = 'mission_row_pd',
        coords = vector3(425.13, -979.56, 30.71),
        name = 'Mission Row Police',
        sprite = 60,
        color = 3,
        scale = 0.85,
        shortRange = true
    },
    {
        id = 'pillbox_hospital',
        coords = vector3(311.2, -592.66, 43.28),
        name = 'Pillbox Medical',
        sprite = 61,
        color = 2,
        scale = 0.85,
        shortRange = true
    }
}
