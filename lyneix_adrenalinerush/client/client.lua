local recentlyDamagedByVehicle = false
local BUILD = GetGameBuildNumber()
local playerTimeouts = {}

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
    if Config.Notify.NotifyFunction then
        -- Use custom notification function from config
        Config.Notify.NotifyFunction(message)
    elseif Framework == 'ESX' then
        -- Fall back to ESX notification
        ESX.ShowNotification(message)
    elseif Framework == 'QB' then
        -- Fall back to QB notification
        QBCore.Functions.Notify(message, 'error')
    end    
end

-- Event listener for entity damage, thx VPagani for showing how he handle this event so I can get this script working https://forum.cfx.re/t/b2060-b2189-game-event-ceventnetworkentitydamage-not-working-as-expected/1922652/8?u=liryuuu
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
        if victim == player and args[6] == 1 then
            CleanupAdrenalineRush()
        end
        -- Check if player was hit by a configured vehicle damage type
        if IsWeaponHashInConfig(weaponHash) then
            if victim == player and args[6] == 0 then
                if recentlyDamagedByVehicle == false and playerTimeouts[player] == nil then
                    StartAdrenalineRush(Config.AdrenalineDuration)
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

-- Function to start the adrenaline rush effect
function StartAdrenalineRush(duration)
    recentlyDamagedByVehicle = true
    local player = PlayerPedId()
    local ByPassInjuryClipset = false

    -- Prevent duplicate activations
    if playerTimeouts[player] then
        return
    end

    if IsPedDeadOrDying(player, true) then
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

    if Config.UseGroundDamageProof then
        SetEntityProofs(player, false, false, false, false, false, true, false, false)
    elseif Config.Invincibility then
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

    -- Call user-defined function on adrenaline start
    if Config.OnStartAdrenaline then
        Config.OnStartAdrenaline()
    end

    -- ByPassInjuryClipset if enabled
    if Config.ByPassInjuryClipset then
        while IsPedRagdoll(player) do Wait(0) end
        if (GetPedMovementClipset(player) == `move_m@injured`) then
            SetPlayerSprint(PlayerId(), true)
            ResetPedMovementClipset(player, 0.0)
            SetPedCanRagdoll(player, false)
            ByPassInjuryClipset = true
        end
    end

    -- Wait for the effect duration
    Citizen.Wait(duration * 1000)

    -- End the adrenaline rush
    EndAdrenalineRush(player, ByPassInjuryClipset)
end

-- Function to end the adrenaline rush effect
function EndAdrenalineRush(player, ByPassInjuryClipset,Clean)
    -- Reset visual effects
    StopScreenEffect(Config.Effects.ScreenEffect)
    StopGameplayCamShaking(true)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    SetPedMoveRateOverride(player, 1.0)

    if Config.UseGroundDamageProof then
        SetEntityProofs(player, false, false, false, false, false, false, false, false)
    elseif Config.Invincibility then
        SetEntityInvincible(player, false)
    end

    -- Notify player if enabled
    if Config.Notify.Enabled then
        local cooldownMessage = string.gsub(Config.Messages.AdrenalineEnded, "{cooldown}", tostring(Config.Cooldown))
        NotifyPlayer(cooldownMessage)
    end

    -- Restore injury clipset if bypassed
    if ByPassInjuryClipset then
        RequestAnimSet('move_m@injured')
        while not HasAnimSetLoaded('move_m@injured') do
            Wait(0)
        end
        SetPedMovementClipset(player, 'move_m@injured', 1)
        SetPedCanRagdoll(player, true)
    end
    if Clean then
        SetPedCanRagdoll(player, true)
    end

    recentlyDamagedByVehicle = false

    -- Call user-defined function on adrenaline end
    if Config.OnEndAdrenaline then
        Config.OnEndAdrenaline()
    end

    -- Start the cooldown timeout
    Citizen.SetTimeout(Config.Cooldown * 1000, function()
        playerTimeouts[player] = nil
    end)
end

-- Cleanup function to ensure proper state on script restart
function CleanupAdrenalineRush()
    for player, _ in pairs(playerTimeouts) do
        EndAdrenalineRush(player, false, true)
    end
end

-- Ensure cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupAdrenalineRush()
    end
end)
