CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(500); end

    lib.onCache('vehicle', function(newVehicle)
        cache.vehicle = newVehicle;

        if not newVehicle then return end

        local _entityState = Entity(newVehicle).state;
        if not _entityState.hasWax then return end

        if Config.Debug then
            print(string.format('Vehicle with plate %s has wax.', GetVehicleNumberPlateText(newVehicle)));
        end

        CreateThread(function()
            while newVehicle == cache.vehicle do
                local dirtLevel = GetVehicleDirtLevel(newVehicle);
                if dirtLevel > 0.0 and _entityState.hasWax then
                    SetVehicleDirtLevel(newVehicle, 0.0); WashDecalsFromVehicle(newVehicle, 1.0);

                    if Config.Debug then
                        print(string.format('Removed dirt from vehicle %s.', GetVehicleNumberPlateText(newVehicle)));
                    end
                end

                Wait((Config.RefreshInterval * 1000) or 5000);
            end

            if Config.Debug then
                print(string.format('Player left from vehicle with plate %s.', GetVehicleNumberPlateText(newVehicle)));
            end
        end)
    end)

    local particleDict, particleName = 'scr_bike_business', 'scr_bike_spraybottle_spray';
    local animDict, animName, animProp = 'anim@scripted@freemode@postertag@graffiti_spray@male@', 'spray_can_var_02_male',
        `prop_cs_spray_can`;

    local function useWaxItem(itemData, slot)
        if cache.vehicle then return end;

        local _vehicleEntity = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, false);
        if not _vehicleEntity or not DoesEntityExist(_vehicleEntity) then
            lib.notify({ description = 'You are not near a vehicle.', type = 'error' });
            return
        end;

        if Entity(_vehicleEntity).state.hasWax then
            lib.notify({ description = 'This vehicle already has wax applied.', type = 'error' });
            return false;
        end

        local isOwned = lib.callback.await('vehiclewax:server:isVehicleOwned', false, VehToNet(_vehicleEntity));
        if not isOwned then
            lib.notify({ description = 'This vehicle is not owned by anyone.', type = 'error' });
            return false;
        end

        exports.ox_inventory:useItem(itemData, function(data)
            if not data then return end

            --[[             CreateThread(function()
                local propEntity = lib.waitFor(function()
                    local closestObject = GetClosestObjectOfType(GetEntityCoords(cache.ped), 1.0, animProp, false, false,
                        false);
                    if closestObject ~= 0 then
                        return closestObject
                    end
                end)

                if not DoesEntityExist(propEntity) then return end

                repeat
                    Entity(propEntity).state:set('entityParticle', {
                        dict = particleDict,
                        effect = particleName,
                        duration = Config.Items[itemData.name].usetime,
                        offset = vec3(0.2, 0.002, 0.0),
                        rotation = vec3(0.0, -95.0, 180.0),
                        scale = 4.0,
                    }); Wait(500)
                until not DoesEntityExist(propEntity)
            end) ]]

            if lib.progressBar({
                    duration = Config.Items[itemData.name].usetime,
                    label = string.format('Applying %s to the vehicle...', itemData.label),
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, car = true },
                    anim = {
                        dict = animDict,
                        clip = animName
                    },
                    prop = {
                        model = animProp,
                        bone = 28422,
                        pos = vec3(0, 0, 0.07),
                        rot = vec3(0.0017365, 0, 0)
                    },
                }) then
                lib.callback('vehiclewax:server:waxVehicle', false, function(success)
                    if success then
                        lib.notify({
                            description = string.format('You have applied %s to the vehicle.', itemData.label),
                            type =
                            'success'
                        });
                    else
                        lib.notify({ description = 'Failed to apply wax to the vehicle.', type = 'error' });
                    end
                end, VehToNet(_vehicleEntity), itemData.name);
            else
                lib.notify({ description = 'You have cancelled the action.', type = 'error' });
            end
        end)
    end

    exports('useWaxItem', useWaxItem);
end)
