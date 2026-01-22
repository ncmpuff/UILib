-- Damage Modifier with UILib (Proper require hook)
-- Hooks into require() to modify weapon damage when stats are loaded

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load UILib
local UILib
local success, result = pcall(function()
    if isfile and isfile("UILIB.lua") then
        return loadstring(readfile("UILIB.lua"))()
    end
end)

if success and result then
    UILib = result
else
    local repo = "https://raw.githubusercontent.com/ncmpuff/UILib/main/"
    local webSuccess, webResult = pcall(function()
        return loadstring(game:HttpGet(repo .. "UILIB.lua?t=" .. tick()))()
    end)
    
    if webSuccess and webResult then
        UILib = webResult
    else
        error("Failed to load UILib!")
    end
end

-- Config
local DamageMultiplier = 1
local weaponsModified = 0

-- Hook require to modify weapon stats as they load
local oldRequire = require
local requireHook
requireHook = function(module)
    local result = oldRequire(module)
    
    -- Check if this is a weapon stat module
    if type(result) == "table" and result.BodyDamage and result.Damage then
        -- Apply damage multiplier
        result.BodyDamage = result.BodyDamage * DamageMultiplier
        result.Damage.Body = result.BodyDamage
        result.Damage.Headshot = result.BodyDamage * 1.25
        
        weaponsModified = weaponsModified + 1
        warn(string.format("🔫 Modified weapon: %s | Damage: %d", tostring(module), result.BodyDamage))
    end
    
    return result
end

-- Install hook
getgenv().require = requireHook
warn("✅ Damage modifier require() hook installed!")

-- Create Window
local Window = UILib:CreateWindow({
    Title = "💥 Damage Modifier",
    Size = UDim2.fromOffset(400, 250),
    Position = UDim2.fromOffset(100, 100)
})

Window:AddToggleKey(Enum.KeyCode.RightControl)
UILib:CreateNotification({Text = "Press Right Ctrl to Toggle", Duration = 3})

-- Create Panel
local MainPanel = UILib:CreatePanel(Window, {
    Name = "Damage",
    DisplayName = "Damage Modifier"
})

-- Damage Slider
UILib:CreateSlider(MainPanel, {
    Text = "Damage Multiplier",
    Min = 1,
    Max = 10,
    Default = 1,
    Callback = function(value)
        DamageMultiplier = value
        UILib:CreateNotification({
            Text = string.format("💥 Damage set to %dx (re-equip weapon to apply)", value),
            Duration = 3
        })
    end
})

-- Info button
UILib:CreateButton(MainPanel, {
    Text = "How It Works",
    Callback = function()
        UILib:CreateNotification({
            Text = "Damage is applied when you equip a weapon. Change slider then re-equip to update!",
            Duration = 5
        })
    end
})

-- Show status
task.spawn(function()
    task.wait(2)
    if weaponsModified > 0 then
        UILib:CreateNotification({
            Text = string.format("✅ Hooked %d weapons", weaponsModified),
            Duration = 3
        })
    else
        UILib:CreateNotification({
            Text = "⏳ Waiting for weapons to load... (equip a weapon)",
            Duration = 3
        })
    end
end)

print("✅ Damage Modifier (require hook) loaded!")
print("ℹ️  Damage is applied when you equip weapons")
