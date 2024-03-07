local currentWaxedVehicles = {};

local function formatWaxTimeToHours(waxTime)
    local timeLeftInSeconds = waxTime - os.time()
    local timeLeftInHours = timeLeftInSeconds / 3600 -- There are 3600 seconds in an hour
    return timeLeftInHours
end

local function GetVehicleWaxTime(vehiclePlate)
    local waxTime = MySQL.scalar.await('SELECT `wax` FROM ' .. Config.DatabaseTable .. ' WHERE `plate` = ?',
        { vehiclePlate })

    if waxTime and waxTime > os.time() then
        return waxTime;
    end

    return 0;
end

local function UpdateWax(vehicleEntity, hasWax)
    table.insert(currentWaxedVehicles, vehicleEntity); Entity(vehicleEntity).state:set('hasWax', hasWax, true);

    if Config.Debug then
        local vehiclePlate = GetVehicleNumberPlateText(vehicleEntity); local waxTime = GetVehicleWaxTime(vehiclePlate);
        if waxTime > 0 then
            print(string.format('Updated wax for vehicle %s. Time left: %s hours.', vehiclePlate,
                formatWaxTimeToHours(waxTime)));
        end
    end
end

local function SetVehicleWax(vehicleEntity, expireTime)
    local vehiclePlate = DoesEntityExist(vehicleEntity) and GetVehicleNumberPlateText(vehicleEntity) or nil;
    if not vehiclePlate then return false; end

    local affectedRows = MySQL.update.await('UPDATE ' .. Config.DatabaseTable .. ' SET `wax` = ? WHERE `plate` = ?',
        { expireTime, vehiclePlate })

    if affectedRows > 0 then UpdateWax(vehicleEntity, true); end

    return affectedRows > 0;
end

local function RemoveVehicleWax(vehicleEntity)
    local vehiclePlate = DoesEntityExist(vehicleEntity) and GetVehicleNumberPlateText(vehicleEntity) or nil;
    if not vehiclePlate then return false; end

    local affectedRows = MySQL.update.await('UPDATE ' .. Config.DatabaseTable .. ' SET `wax` = ? WHERE `plate` = ?',
        { 0, vehiclePlate })

    if affectedRows > 0 then UpdateWax(vehicleEntity, false); end

    return affectedRows > 0;
end

local function DoesVehicleHaveWax(vehiclePlate)
    local waxTime = MySQL.scalar.await('SELECT `wax` FROM ' .. Config.DatabaseTable .. ' WHERE `plate` = ?',
        { vehiclePlate })

    if waxTime and waxTime > os.time() then
        return true;
    end

    return false
end

local function EnsureVehicleWax(vehicleEntity)
    Wait(500); -- For me the vehicle plate is not set immediately after the vehicle is created.

    if not DoesEntityExist(vehicleEntity) then return false; end

    local vehiclePlate = GetVehicleNumberPlateText(vehicleEntity);
    if not vehiclePlate or vehiclePlate == '' then return false; end

    local waxTime = GetVehicleWaxTime(vehiclePlate);
    if waxTime > 0 and waxTime > os.time() then
        UpdateWax(vehicleEntity, true);
        return true;
    end

    return false;
end

lib.callback.register('vehiclewax:server:isVehicleOwned', function(playerId, vehicleNetId)
    local vehicleEntity = NetworkGetEntityFromNetworkId(vehicleNetId); if not DoesEntityExist(vehicleEntity) then return false; end

    return MySQL.scalar.await('SELECT 1 FROM ' .. Config.DatabaseTable .. ' WHERE `plate` = ?',
        { GetVehicleNumberPlateText(vehicleEntity) });
end)

lib.callback.register('vehiclewax:server:waxVehicle', function(playerId, vehicleNetId, waxItem)
    local vehicleEntity = NetworkGetEntityFromNetworkId(vehicleNetId); if not DoesEntityExist(vehicleEntity) then return false; end

    local isOwned = MySQL.scalar.await('SELECT 1 FROM ' .. Config.DatabaseTable .. ' WHERE `plate` = ?',
        { GetVehicleNumberPlateText(vehicleEntity) });
    if not isOwned then
        TriggerClientEvent('ox_lib:notify', playerId,
            { type = 'error', text = 'This vehicle is not owned by any player.' })

        if Config.Debug then
            print(string.format('Vehicle %s is not owned by any player.', GetVehicleNumberPlateText(vehicleEntity)));
        end

        return false;
    end

    if type(waxItem) ~= 'string' and not Config.Items[waxItem] then
        print(string.format('Invalid wax item (%s). Define it in the Config.', waxItem));
        return false;
    end

    local waxTime = os.time() + 60 * 60 * Config.Items[waxItem].time;

    return SetVehicleWax(vehicleEntity, waxTime);
end)

local function RefreshWaxedVehicles()
    if #currentWaxedVehicles <= 0 then return; end

    for i = 1, #currentWaxedVehicles do
        local vehicleEntity = currentWaxedVehicles[i];

        if not DoesEntityExist(vehicleEntity) then
            if Config.Debug then
                print(string.format('Vehicle %s does not exist.', vehicleEntity));
            end

            table.remove(currentWaxedVehicles, i);

            goto continue;
        end

        local waxTime = GetVehicleWaxTime(GetVehicleNumberPlateText(vehicleEntity));
        if waxTime < os.time() then
            RemoveVehicleWax(vehicleEntity); table.remove(currentWaxedVehicles, i);

            if Config.Debug then
                print(string.format('Removed wax from vehicle %s.', GetVehicleNumberPlateText(vehicleEntity)));
            end
        else
            if Config.Debug then
                print(string.format('Vehicle %s has wax until %s.', GetVehicleNumberPlateText(vehicleEntity),
                    formatWaxTimeToHours(waxTime)));
            end
        end

        ::continue::
    end

    if Config.Debug then
        print(string.format('Refreshed %d waxed vehicles.', #currentWaxedVehicles));
    end
end

lib.cron.new('* 1 * * *', RefreshWaxedVehicles); -- Every hour

exports('SetVehicleWax', SetVehicleWax);
exports('RemoveVehicleWax', RemoveVehicleWax);
exports('DoesVehicleHaveWax', DoesVehicleHaveWax);
exports('GetVehicleWaxTime', GetVehicleWaxTime);
exports('EnsureVehicleWax', EnsureVehicleWax);
