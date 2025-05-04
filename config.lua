Config = {}

Config.RequiredJob = "police"
Config.Progressbar = "qs" -- qs of "qb"
Config.VehicleReturn = {x = 208.53, y = -3103.7, z = 5.79}

-- NPC instellingen
Config.NPC = {
    model = 's_m_m_gardener_01',
    coords = vector3(210.1, -3091.62, 5.77),
    heading = 91.84,
}

Config.RewardPerWindow = {
    min = 10, -- Minimum bedrag per raam
    max = 15  -- Maximum bedrag per raam
}

-- Voertuig instellingen
Config.Vehicle = {
    model = 'bison2', -- Het voertuigmodel dat je wilt gebruiken
    spawnPoint = vector4(208.53, -3103.7, 5.79, 181.15), -- Spawn locatie en richting voor het voertuig
}

-- Locaties voor het ramen wassen
Config.Locations = {
    vector3(-104.51, -1747.6, 30.0),
    vector3(-253.89, -1358.35, 31.3),
    vector3(-162.47, -877.18, 29.22),
    vector3(138.27, -1027.29, 29.35),
    vector3(360.26, -1033.95, 29.33),
    vector3(401.83, -669.95, 29.29),
    vector3(-20.82, -1389.29, 29.37) 
    --- add more
}