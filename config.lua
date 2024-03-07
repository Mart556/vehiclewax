Config = {
    Debug = true,                      -- set to true to enable debug messages
    RefreshInterval = 5,               -- in seconds

    DatabaseTable = 'player_vehicles', -- the table name in the database

    Items = {
        ['regular_wax'] = {
            time = 6,        -- in hours
            usetime = 15000, -- in milliseconds
        },
        ['gold_wax'] = {
            time = 12,       -- in hours
            usetime = 17500, -- in milliseconds
        },
        ['premium_wax'] = {
            time = 24,       -- in hours
            usetime = 25000, -- in milliseconds
        }
    },
}

-- ITEM EXAMPLE: ox_inventory

--[[
    ['silver_wax'] = {
        label = 'Silver Wax',
        weight = 220,
        stack = true,
        close = true,
        client = {
            export = 'vehiclewax.useWaxItem',
        }
    },
]]
