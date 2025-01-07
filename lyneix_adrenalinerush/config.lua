Config = {}

-- Adrenaline rush settings
Config.Cooldown = 30 -- Cooldown duration in seconds
Config.AdrenalineDuration = 10 -- Duration in seconds
Config.SpeedMultiplier = 1.5 -- Sprint speed multiplier
Config.MoveRateMultiplier = 1.5 -- Movement rate multiplier
Config.Invincibility = true -- Enable/disable invincibility during adrenaline rush
Config.ByPassInjuryClipset = true -- Enable/disable ByPassInjuryClipset during adrenaline rush, If you use qb-ambulancejob and want player to run normal when in adrenaline effect enabled this

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
    NotifyFunction = function(message)
        -- Custom notification logic; use NotifyFunction = nil to skip to use Framework notifications, Dafault notufy for this func is display in server chat.
        TriggerEvent('chat:addMessage', { args = { "Custom Notify", message } })
    end 
}

-- Chat messages
Config.Messages = {
    AdrenalineActivated = "Adrenaline Rush activated!",
    AdrenalineEnded = "Adrenaline Rush has ended. Cooldown {cooldown}s."
}
