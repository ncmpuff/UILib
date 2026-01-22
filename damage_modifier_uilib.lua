-- Damage Modifier with UILib
-- Standalone script for Retro Breach

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
        modifyWeaponStats()
    end
})

-- Status Display
local statusText = "⏳ Waiting..."
UILib:CreateButton(MainPanel, {
    Text = "Refresh Weapon Stats",
    Callback = function()
        modifyWeaponStats()
    end
})

-- Damage Modifier Function
function modifyWeaponStats()
    local workspace = game:GetService("Workspace")
    
    -- Try multiple paths to find stats folder
    local statsFolder = nil
    
    -- Method 1: Standard path
    if workspace:FindFirstChild("Workspace") then
        local lobby = workspace.Workspace:FindFirstChild("Lobby")
        if lobby then
            local gunModels = lobby:FindFirstChild("GunModels")
            if gunModels then
                statsFolder = gunModels:FindFirstChild("Stats")
            end
        end
    end
    
    -- Method 2: Direct search from workspace
    if not statsFolder then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Stats" and obj.Parent and obj.Parent.Name == "GunModels" then
                statsFolder = obj
                break
            end
        end
    end
    
    -- Method 3: Search for any folder with ModuleScripts that have BodyDamage
    if not statsFolder then
        for _, folder in pairs(workspace:GetDescendants()) do
            if folder:IsA("Folder") and folder.Name == "Stats" then
                for _, child in pairs(folder:GetChildren()) do
                    if child:IsA("ModuleScript") then
                        local success, stats = pcall(require, child)
                        if success and stats and stats.BodyDamage then
                            statsFolder = folder
                            warn("Found stats folder at:", folder:GetFullName())
                            break
                        end
                    end
                end
                if statsFolder then break end
            end
        end
    end
    
    if not statsFolder then
        UILib:CreateNotification({
            Text = "❌ Stats folder not found - weapon stats may not have loaded yet",
            Duration = 5
        })
        warn("Could not find weapon stats folder. Make sure you're in the game lobby.")
        return
    end
    
    local modifiedCount = 0
    for _, statModule in pairs(statsFolder:GetChildren()) do
        if statModule:IsA("ModuleScript") then
            pcall(function()
                local stats = require(statModule)
                if stats.BodyDamage then
                    local originalDamage = stats.BodyDamage
                    stats.BodyDamage = originalDamage * DamageMultiplier
                    
                    if stats.Damage then
                        stats.Damage.Body = stats.BodyDamage
                        stats.Damage.Headshot = stats.BodyDamage * 1.25
                    end
                    
                    modifiedCount = modifiedCount + 1
                end
            end)
        end
    end
    
    if modifiedCount > 0 then
        UILib:CreateNotification({
            Text = string.format("✅ Modified %d weapons (%dx damage)", modifiedCount, DamageMultiplier),
            Duration = 3
        })
    else
        UILib:CreateNotification({
            Text = "⚠️ No weapons modified",
            Duration = 3
        })
    end
end

-- Initial modification
task.wait(1)
modifyWeaponStats()

print("✅ Damage Modifier (UILib) loaded!")
