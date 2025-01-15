-- Variables for Adrenaline Rush system
local lastAdrenalineTime = 0 -- Timestamp of last adrenaline activation
local recentlyDamagedByVehicle = false -- Flag for vehicle damage check
local ragdollPrevent = false --Flag for ragdoll check
-- Game environment variables
local BUILD = GetGameBuildNumber() -- Current game build version

-- Framework detection
local Framework = '' -- Detected framework (e.g., ESX, QB-Core, Standalone)


-- Debugging command---------------------------
RegisterCommand("startadrenaline", function()
    if Config.Debug then
        StartAdrenalineRush(Config.AdrenalineDuration)
    end
end, false)
-----------------------------------------------

Citizen.CreateThread(function()
    local attempts = 10 -- Retry up to 10 times
    while attempts > 0 do
        if GetResourceState('es_extended') == 'started' then
            Framework = 'ESX'
            TriggerEvent('esx:getSharedObject', function(obj)
                ESX = obj
            end)
            print('^3[Adrenaline Rush]^7 Framework detected: ^5ESX')
            break
        elseif GetResourceState('qb-core') == 'started' then
            Framework = 'QB'
            QBCore = exports['qb-core']:GetCoreObject()
            print('^3[Adrenaline Rush]^7 Framework detected: ^1QB-Core')
            break
        else
            attempts = attempts - 1
            Citizen.Wait(1000) -- Wait and retry
        end
    end

    if not Framework then
        Framework = 'Standalone'
        print('^3[Adrenaline Rush]^7 No supported framework detected. Defaulting to standalone mode.')
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    print("^3[Adrenaline Rush]^7 Resource started. Configuration:")
    if Config.ByPassInjuryClipset.UseQbAmbulanceJobInjury then
        print("  - Using qb-ambulancejob ^3Event Trigger.")
        if GetResourceState('qb-ambulancejob') ~= 'started' then
            print("  - ^3WARNING:^7 qb-ambulancejob is not running. This feature will not work.")
        end
    else
        print("  - Using manual ^3no-ragdoll logic^7. Note: Animations may be janky if hit by a vehicle.")
    end
end)

-- Ensure cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupAdrenalineRush()
    end
end)

-- Constants for argument indexes
local ARG_VICTIM = 1
local ARG_ATTACKER = 2
local ARG_IS_FATAL = 6
local ARG_WEAPON_HASH = 7
local ARG_DAMAGE_TYPE_FLAG = 12

-- Event listener for entity damage
AddEventHandler('gameEventTriggered', function(eventName, args)
    if eventName ~= "CEventNetworkEntityDamage" then return end

    local victim = args[ARG_VICTIM]
    local attacker = args[ARG_ATTACKER]
    local isFatal = args[ARG_IS_FATAL]
    local weaponHash = args[ARG_WEAPON_HASH]
    local damageTypeFlag = args[ARG_DAMAGE_TYPE_FLAG]
    local player = PlayerPedId()

    -- Skip if the victim is not the local player
    if victim ~= player then return end

    -- Handle cleanup logic if damage is fatal
    if isFatal ~= 0 then
        if recentlyDamagedByVehicle then
            CleanupAdrenalineRush()
        end
        return
    end

    -- Check if the weapon hash matches configured vehicle damage types
    if IsWeaponHashInConfig(weaponHash) and damageTypeFlag == 0 then
        if not recentlyDamagedByVehicle then
            StartAdrenalineRush(Config.AdrenalineDuration)
        end
    end
end)

-- Function to start the adrenaline rush effect
function StartAdrenalineRush(duration)
    recentlyDamagedByVehicle = true
    local player = PlayerPedId()
    local ByPassInjuryClipset = false
    local currentTime = GetGameTimer()

    -- Check cooldown
    if currentTime - lastAdrenalineTime < Config.Cooldown * 1000 then
        if Config.Debug then print("Adrenaline on cooldown.") end
        return
    end

    lastAdrenalineTime = currentTime

    if IsPedDeadOrDying(player, true) then
        return
    end

    -- Apply visual effects
    StartScreenEffect(Config.Effects.ScreenEffect, 0, false)
    ShakeGameplayCam(Config.Effects.CamShakeType, Config.Effects.CamShakeIntensity)

    -- Boost player stats
    SetRunSprintMultiplierForPlayer(PlayerId(), Config.SpeedMultiplier)
    if Config.RestorePlayerStamina then
        SetPlayerStamina(PlayerId(), Config.RestorePlayerStamina)
    end
    

    ApplyDamageProtection(player, true)

    -- Play sound if enabled
    if Config.Sounds.Enabled then
        PlaySoundFrontend(-1, Config.Sounds.SoundName, Config.Sounds.SoundSet, true)
    end

    -- Notify player if enabled
    if Config.Notify.Enabled then
        NotifyPlayer(Config.Messages.AdrenalineActivated,'info')
    end

    -- Call user-defined function on adrenaline start
    if Config.OnStartAdrenaline then
        Config.OnStartAdrenaline()
    end

    -- ByPassInjuryClipset if enabled
    if Config.ByPassInjuryClipset.Enabled then
        ByPassInjuryClipset = true
        while IsPedRagdoll(player) do Wait(0) end
        if (GetPedMovementClipset(player) == `move_m@injured`) then
            SetPlayerSprint(PlayerId(), true)
            ResetPedMovementClipset(player, 0.0)
            if Config.ByPassInjuryClipset.UseQbAmbulanceJobInjury then
                if GetResourceState('qb-ambulancejob') == 'started' then
                    TriggerEvent('hospital:client:HealInjuries','full')
                end
            else
                SetPedCanRagdoll(player, false)
                ragdollPrevent = true
            end
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

    ApplyDamageProtection(player, false)

    -- Notify player if enabled
    if Config.Notify.Enabled then
        local cooldownMessage = string.gsub(Config.Messages.AdrenalineEnded, "{cooldown}", tostring(Config.Cooldown))
        NotifyPlayer(cooldownMessage,'info')
    end

    -- Restore injury clipset if bypassed
    if ByPassInjuryClipset then
        RequestAnimSet('move_m@injured')
        while not HasAnimSetLoaded('move_m@injured') do
            Wait(50)
        end
        SetPedMovementClipset(player, 'move_m@injured', 1)
        TriggerEvent("hospital:client:SetPain")
    end

    if Clean or ragdollPrevent then
        SetPedCanRagdoll(player, true)
    end

    recentlyDamagedByVehicle = false

    -- Call user-defined function on adrenaline end
    if Config.OnEndAdrenaline then
        Config.OnEndAdrenaline()
    end
end

-- Cleanup function to ensure proper state on script restart
function CleanupAdrenalineRush()
    local player = PlayerPedId()
    EndAdrenalineRush(player, false, true)
end

-- Helper function to manage damage immunity
function ApplyDamageProtection(player, enable)
    if Config.UseGroundDamageProof then
        -- Apply ground damage immunity
        SetEntityProofs(player, false, false, false, false, false, enable, false, false)
    end

    if Config.Invincibility then
        -- Apply full invincibility
        SetEntityInvincible(player, enable)
    end
end


-- Function to check if weaponHash matches any in Config.WeaponHashes
function IsWeaponHashInConfig(weaponHash)
    for _, hash in ipairs(Config.WeaponHashes) do
        if weaponHash == hash then
            return true
        end
    end
    return false
end

-- Function to notify player with priority for custom Config.Notify.NotifyFunction
function NotifyPlayer(message, type)
    if not Config.Notify.Enabled then return end -- Skip notifications if disabled

    local notifyType = type or 'info' -- Default to 'info'

    -- Custom notification function
    if Config.Notify.NotifyFunction and not Config.Notify.UseOxLib then
        Config.Notify.NotifyFunction(message, notifyType)
        return
    end

    -- Framework-based notifications
    if Framework == 'ESX' then
        if ESX and ESX.ShowNotification then
            ESX.ShowNotification(message)
        else
            print("[Adrenaline Rush] ESX notification failed.")
        end
    elseif Framework == 'QB' then
        if QBCore and QBCore.Functions and QBCore.Functions.Notify then
            QBCore.Functions.Notify(message, notifyType)
        else
            print("[Adrenaline Rush] QB notification failed.")
        end
    elseif Config.Notify.UseOxLib then
        -- ox_lib notification fallback
        if exports and exports.ox_lib then
            Config.Notify.OxLibFunction(message)            
        else
            print("[Adrenaline Rush] ox_lib notification failed.")
        end
    elseif Framework == '' then
        -- Standalone fallback
        print("[Adrenaline Rush] " .. message)
    else
        -- Log error for unhandled cases
        print("[Adrenaline Rush] Notification system not properly configured.")
    end
end
