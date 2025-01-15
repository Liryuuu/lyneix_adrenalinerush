Config = {}

Config.Debug = false
-- Adrenaline rush settings
Config.Cooldown = 30 -- Cooldown duration in seconds
Config.AdrenalineDuration = 10 -- Duration in seconds
Config.SpeedMultiplier = 1.2 -- Sprint speed multiplier Multiplier goes up to 1.49 any value above will be completely overruled by the game
Config.Invincibility = false -- Enable/disable invincibility during adrenaline rush
Config.UseGroundDamageProof = true -- Enable/disable ground damage proof during adrenaline rush  
Config.RestorePlayerStamina = 100 -- percent of player stamina that gonna be restore when adrenaline rush

Config.ByPassInjuryClipset = {
    Enabled = true, -- Enable/disable ByPassInjuryClipset
    UseQbAmbulanceJobInjury = true, -- Use qb-ambulancejob's Event for temporary ease player injury, set false to use disable ragdoll instead.
    PainkillerMessage = "Using qb-ambulancejob Event. Adjust interval in qb-ambulancejob's config (default: 60s).",
    NoQbAmbulanceNote = "Without qb-ambulancejob, player will have no ragdoll during adrenaline. This may cause janky animations if hit by a vehicle during adrenaline effects."
}

-- Weapon hashes for vehicle-related damage
Config.WeaponHashes = {
    `weapon_run_over_by_car`,
    `weapon_rammed_by_car`
}

-- Visual effects
Config.Effects = {
    ScreenEffect = "FocusIn", -- Screen effect for adrenaline rush
    CamShakeType = "LARGE_EXPLOSION_SHAKE", -- Camera shake type
    CamShakeIntensity = 0.1 -- Intensity of the camera shake
}

-- Audio settings https://wiki.rage.mp/index.php?title=Sounds
Config.Sounds = {
    Enabled = true, -- Enable/disable sound effects
    SoundName = "TIMER_STOP",
    SoundSet = "HUD_MINI_GAME_SOUNDSET"
}

-- Notifications
Config.Notify = {
    Enabled = true, -- Enable/disable notifications
    
    UseOxLib = true, -- Enable ox_lib notifications , it gonna overide NotifyFunction
    OxLibFunction = function(message)
        -- If UseOxLib = false ,Custom notification logic; defaults to server chat if enabled
        lib.notify({
            title = 'Adrenaline Rush',
            description = message,
            showDuration = false,
            position = 'top',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = {
                  color = '#ffff00'
                }
            },
            icon = 'bolt',
            iconColor = '#ffff00'
        })
    end,

    NotifyFunction = function(message)
        -- If UseOxLib = false ,Custom notification logic; defaults to server chat if enabled
        TriggerEvent('chat:addMessage', { args = { "Custom Notify", message } })
    end,
}

-- Chat messages
Config.Messages = {
    AdrenalineActivated = "Adrenaline Rush activated!",
    AdrenalineEnded = "Adrenaline Rush has ended. Cooldown {cooldown}s."
}

Config.OnStartAdrenaline = function()
    print("Adrenaline Rush Started!") -- Add your custom logic here
end
Config.OnEndAdrenaline = function()
    print("Adrenaline Rush Ended!") -- Add your custom logic here
end
