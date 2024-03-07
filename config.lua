Config = {
    Debug = false,                     -- set to true to enable debug messages
    RefreshInterval = 5,               -- in seconds

    DatabaseTable = 'player_vehicles', -- the table name in the database

    Items = {
        ['regular_wax'] = {
            time = 6,        -- in hours, how long the wax lasts
            usetime = 15000, -- in milliseconds, time it takes to use the item
        },
        ['gold_wax'] = {
            time = 12,       -- in hours, how long the wax lasts
            usetime = 17500, -- in milliseconds, time it takes to use the item
        },
        ['premium_wax'] = {
            time = 24,       -- in hours, how long the wax lasts
            usetime = 25000, -- in milliseconds, time it takes to use the item
        }
    },
}

-- ITEM EXAMPLE: ox_inventory

--[[
	['regular_wax'] = {
		label = 'Regular Wax',
		weight = 220,
		stack = true,
		close = true,
		client = {
			export = 'vehiclewax.useWaxItem',
		}
	},

	['gold_wax'] = {
		label = 'Gold Wax',
		weight = 220,
		stack = true,
		close = true,
		client = {
			export = 'vehiclewax.useWaxItem',
		}
	},

	['premium_wax'] = {
		label = 'Premium Wax',
		weight = 220,
		stack = true,
		close = true,
		client = {
			export = 'vehiclewax.useWaxItem',
		}
	},
]]
