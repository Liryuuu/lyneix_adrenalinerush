local recentlyDamagedByVehicle = false
local BUILD = GetGameBuildNumber()
local playerTimeouts = {}
-- Framework detection (same as before)
Citizen.CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        Framework = 'ESX'
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    elseif GetResourceState('qb-core') == 'started' then
        Framework = 'QB'
        QBCore = exports['qb-core']:GetCoreObject()
    else
        print('No supported framework detected. Defaulting to standalone mode.')
    end
end)

-- Function to notify player with priority for custom Config.Notify.NotifyFunction
function NotifyPlayer(message)
    if Framework == 'ESX' then
        -- Fall back to ESX notification
        ESX.ShowNotification(message)
    elseif Framework == 'QB' then
        -- Fall back to QB notification
        QBCore.Functions.Notify(message, 'error')
        
    elseif Config.Notify.NotifyFunction then
        -- Use custom notification function from config
        Config.Notify.NotifyFunction(message)
    end
end

-- Event listener for entity damage
AddEventHandler('gameEventTriggered', function(eventName, args)
    if eventName == "CEventNetworkEntityDamage" then
        local i = 1
        local victim = args[i] i = i + 1
        local attacker = args[i] i = i + 1
        
        -- Skip unknown value
        i = i + 1 

        -- Skip build-specific unknown values
        if BUILD >= 2060 then
            i = i + 1
        end
        if BUILD >= 2189 then
            i = i + 1
        end

        local isFatal = args[i] == true i = i + 1
        local weaponHash = args[i] i = i + 1

        -- Skip additional unknown values
        i = i + 5

        local isMelee = args[i] == true i = i + 1
        local vehicleDamageTypeFlag = args[i] i = i + 1
        local player = PlayerPedId()
            
        -- Check if player was hit by a configured vehicle damage type
        if IsWeaponHashInConfig(weaponHash) then
            if victim == PlayerPedId() then
                if recentlyDamagedByVehicle == false and playerTimeouts[player] == nil then
                    AdrenalineRush(Config.AdrenalineDuration)
                end
            end
        end        
    end
end)
-- Function to check if weaponHash matches any in Config.WeaponHashes
function IsWeaponHashInConfig(weaponHash)
    for _, hash in ipairs(Config.WeaponHashes) do
        if weaponHash == hash then
            return true
        end
    end
    return false
end
-- Function to apply adrenaline rush effect
function AdrenalineRush(duration)
    recentlyDamagedByVehicle = true
    local player = PlayerPedId()
    
    -- Prevent duplicate activations
    if playerTimeouts[player] then
        return
    end

    -- Mark the player as "in cooldown"
    playerTimeouts[player] = true
    
    -- Apply visual effects
    StartScreenEffect(Config.Effects.ScreenEffect, 0, false)
    ShakeGameplayCam(Config.Effects.CamShakeType, Config.Effects.CamShakeIntensity)

    -- Boost player stats
    SetRunSprintMultiplierForPlayer(PlayerId(), Config.SpeedMultiplier)
    SetPedMoveRateOverride(player, Config.MoveRateMultiplier)
    SetPlayerStamina(PlayerId(), 100.0)

    if Config.Invincibility then
        SetEntityInvincible(player, true)
    end

    -- Play sound if enabled
    if Config.Sounds.Enabled then
        PlaySoundFrontend(-1, Config.Sounds.SoundName, Config.Sounds.SoundSet, true)
    end

    -- Notify player if enabled
    if Config.Notify.Enabled then
        NotifyPlayer(Config.Messages.AdrenalineActivated)
    end

    -- Wait for the effect duration
    Citizen.Wait(duration * 1000)

    -- Reset effects
    StopScreenEffect(Config.Effects.ScreenEffect)
    StopGameplayCamShaking(true)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    SetPedMoveRateOverride(player, 1.0)
    SetEntityInvincible(player, false)
    

    -- Notify player if enabled
    if Config.Notify.Enabled then
        local cooldownMessage = string.gsub(Config.Messages.AdrenalineEnded, "{cooldown}", tostring(Config.Cooldown))
        NotifyPlayer(cooldownMessage)
    end
    
    recentlyDamagedByVehicle = false
    -- Start the cooldown timeout
    Citizen.SetTimeout(Config.Cooldown * 1000, function()
        playerTimeouts[player] = nil
    end)
end
