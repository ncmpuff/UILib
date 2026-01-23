-- ULTIMATE Weapon Stat Editor v2
-- Every single stat + Real-time info display!

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Get BridgeNet2
local RS = game:GetService("ReplicatedStorage")
local BridgeNet2 = require(RS.Assets.Modules.BridgeNet2)
local equipWeapon = BridgeNet2.ClientBridge("equipWeapon")

-- Config (Only working stats!)
local Config = {
    Enabled = false,
    FireRate = 1900,
    RecoilVertical = 0,
    RecoilHorizontal = 0,
    Spread = 0,
    MuzzleVelocity = 500,
    BulletsFired = 1,
    ViewPunch = 0,
    BurstAmount = 1,
    InitialSpread = 0,
    MaxSpread = 0,
    ReloadSpeed = 1,
    StartDamageDropoff = 9999,  -- Distance where damage starts decreasing (9999 = infinite range)
    MaxDamageDropOff = 9999     -- Distance where damage reaches minimum (9999 = no falloff)
}

local OriginalStats = {}
local CurrentWeapon = "None"
local CurrentAmmo = {mag = 0, reserve = 0}

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WeaponEditor"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 600)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 25)
TitleFix.Position = UDim2.new(0, 0, 1, -25)
TitleFix.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ WEAPON EDITOR PRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Draggable (only title bar!)
local dragging, dragInput, mousePos, framePos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Info Panel
local InfoPanel = Instance.new("Frame")
InfoPanel.Size = UDim2.new(1, -20, 0, 80)
InfoPanel.Position = UDim2.new(0, 10, 0, 60)
InfoPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
InfoPanel.BorderSizePixel = 0
InfoPanel.Parent = MainFrame
Instance.new("UICorner", InfoPanel).CornerRadius = UDim.new(0, 8)

local WeaponNameLabel = Instance.new("TextLabel")
WeaponNameLabel.Size = UDim2.new(1, -10, 0, 25)
WeaponNameLabel.Position = UDim2.new(0, 5, 0, 5)
WeaponNameLabel.BackgroundTransparency = 1
WeaponNameLabel.Text = "🔫 Weapon: None"
WeaponNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WeaponNameLabel.TextSize = 16
WeaponNameLabel.Font = Enum.Font.GothamBold
WeaponNameLabel.TextXAlignment = Enum.TextXAlignment.Left
WeaponNameLabel.Parent = InfoPanel

local AmmoLabel = Instance.new("TextLabel")
AmmoLabel.Size = UDim2.new(1, -10, 0, 20)
AmmoLabel.Position = UDim2.new(0, 5, 0, 30)
AmmoLabel.BackgroundTransparency = 1
AmmoLabel.Text = "📦 Ammo: 0 / 0"
AmmoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AmmoLabel.TextSize = 14
AmmoLabel.Font = Enum.Font.Gotham
AmmoLabel.TextXAlignment = Enum.TextXAlignment.Left
AmmoLabel.Parent = InfoPanel

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0, 20)
StatusLabel.Position = UDim2.new(0, 5, 0, 55)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "⚙️ Method: BridgeNet2 Interception"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = InfoPanel

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0, 150)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleBtn.Text = "🔴 DISABLED - Click to Enable"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 16
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

-- Reset Button
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0.48, 0, 0, 35)
ResetBtn.Position = UDim2.new(0, 10, 0, 200)
ResetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ResetBtn.Text = "🔄 Reset to Original"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.TextSize = 14
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.Parent = MainFrame
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 8)

-- Preset Buttons Container
local PresetFrame = Instance.new("Frame")
PresetFrame.Size = UDim2.new(1, -20, 0, 80)
PresetFrame.Position = UDim2.new(0, 10, 0, 200)
PresetFrame.BackgroundTransparency = 1
PresetFrame.Parent = MainFrame

-- Preset 1: Laser Attack
local Preset1 = Instance.new("TextButton")
Preset1.Size = UDim2.new(0.48, 0, 0, 35)
Preset1.Position = UDim2.new(0, 0, 0, 0)
Preset1.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Preset1.Text = "🔴 Laser Attack"
Preset1.TextColor3 = Color3.fromRGB(255, 255, 255)
Preset1.TextSize = 13
Preset1.Font = Enum.Font.GothamBold
Preset1.Parent = PresetFrame
Instance.new("UICorner", Preset1).CornerRadius = UDim.new(0, 8)

-- Preset 2: Instant Kill
local Preset2 = Instance.new("TextButton")
Preset2.Size = UDim2.new(0.48, 0, 0, 35)
Preset2.Position = UDim2.new(0.52, 0, 0, 0)
Preset2.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
Preset2.Text = "💥 Instant Kill"
Preset2.TextColor3 = Color3.fromRGB(255, 255, 255)
Preset2.TextSize = 13
Preset2.Font = Enum.Font.GothamBold
Preset2.Parent = PresetFrame
Instance.new("UICorner", Preset2).CornerRadius = UDim.new(0, 8)

-- Preset 3: Rapid Fire
local Preset3 = Instance.new("TextButton")
Preset3.Size = UDim2.new(0.48, 0, 0, 35)
Preset3.Position = UDim2.new(0, 0, 0, 43)
Preset3.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Preset3.Text = "⚡ Rapid Fire"
Preset3.TextColor3 = Color3.fromRGB(255, 255, 255)
Preset3.TextSize = 13
Preset3.Font = Enum.Font.GothamBold
Preset3.Parent = PresetFrame
Instance.new("UICorner", Preset3).CornerRadius = UDim.new(0, 8)

-- Preset 4: Sniper Mode
local Preset4 = Instance.new("TextButton")
Preset4.Size = UDim2.new(0.48, 0, 0, 35)
Preset4.Position = UDim2.new(0.52, 0, 0, 43)
Preset4.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
Preset4.Text = "🎯 Sniper Mode"
Preset4.TextColor3 = Color3.fromRGB(255, 255, 255)
Preset4.TextSize = 13
Preset4.Font = Enum.Font.GothamBold
Preset4.Parent = PresetFrame
Instance.new("UICorner", Preset4).CornerRadius = UDim.new(0, 8)

-- Scrolling Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -300)
ScrollFrame.Position = UDim2.new(0, 10, 0, 290)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.Parent = MainFrame
Instance.new("UICorner", ScrollFrame).CornerRadius = UDim.new(0, 8)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollFrame

-- Slider creator
local function createSlider(name, min, max, default, configKey, step)
    step = step or 1
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 50)
    Container.BackgroundTransparency = 1
    Container.Parent = ScrollFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    ValueLabel.TextSize = 13
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Container
    
    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, 0, 0, 18)
    SliderBG.Position = UDim2.new(0, 0, 0, 27)
    SliderBG.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = Container
    Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(0, 9)
    
    local SliderFill = Instance.new("Frame")
    local percent = (default - min) / (max - min)
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBG
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 9)
    
    local sliderDragging = false
    local function updateSlider(input)
        local mouseX = input.Position.X
        local sliderX = SliderBG.AbsolutePosition.X
        local sliderWidth = SliderBG.AbsoluteSize.X
        local percent = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        
        local rawValue = min + (percent * (max - min))
        local value = math.floor(rawValue / step) * step
        Config[configKey] = value
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        ValueLabel.Text = tostring(value)
    end
    
    SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = true
            updateSlider(input)
        end
    end)
    SliderBG.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
end

-- Create working sliders only
createSlider("🔥 Fire Rate (RPM)", 50, 5000, 1900, "FireRate", 50)
createSlider("� Bullets per Shot ✅", 1, 50, 1, "BulletsFired", 1)
createSlider("📉 Recoil Vertical", 0, 20, 0, "RecoilVertical", 0.1)
createSlider("↔️ Recoil Horizontal", 0, 20, 0, "RecoilHorizontal", 0.1)
createSlider("🎲 Spread", 0, 50, 0, "Spread", 0.5)
createSlider("🚀 Muzzle Velocity", 50, 3000, 500, "MuzzleVelocity", 10)
createSlider("👁️ ViewPunch (Screen Shake)", 0, 10, 0, "ViewPunch", 0.1)
createSlider("🔫 Burst Amount", 1, 10, 1, "BurstAmount", 1)
createSlider("🎯 Initial Spread", 0, 20, 0, "InitialSpread", 0.5)
createSlider("🎯 Max Spread", 0, 50, 0, "MaxSpread", 0.5)
createSlider("⚡ Reload Speed Multiplier", 0.1, 5, 1, "ReloadSpeed", 0.1)
createSlider("📏 Start Damage Dropoff (studs)", 0, 9999, 9999, "StartDamageDropoff", 10)
createSlider("📉 Max Damage Dropoff (studs)", 0, 9999, 9999, "MaxDamageDropOff", 10)

ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- Toggle
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    if Config.Enabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleBtn.Text = "🟢 ENABLED - Modifying Weapons"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleBtn.Text = "🔴 DISABLED - Click to Enable"
    end
end)

-- Reset
ResetBtn.MouseButton1Click:Connect(function()
    if next(OriginalStats) then
        for key, value in pairs(OriginalStats) do
            if Config[key] ~= nil then
                Config[key] = value
            end
        end
        print("✅ Reset to original stats!")
    end
end)

-- Preset 1: Laser Attack - Perfect accuracy, instant bullets
Preset1.MouseButton1Click:Connect(function()
    Config.FireRate = 2000
    Config.RecoilVertical = 0
    Config.RecoilHorizontal = 0
    Config.Spread = 0
    Config.MuzzleVelocity = 3000  -- Nearly instant bullets
    Config.BulletsFired = 1
    Config.ViewPunch = 0
    Config.InitialSpread = 0
    Config.MaxSpread = 0
    Config.ReloadSpeed = 3
    Config.StartDamageDropoff = 9999  -- Infinite range
    Config.MaxDamageDropOff = 9999
    print("🔴 LASER ATTACK! Perfect accuracy + instant hit bullets")
end)

-- Preset 2: Instant Kill - Massive shotgun spread
Preset2.MouseButton1Click:Connect(function()
    Config.FireRate = 1500
    Config.RecoilVertical = 0
    Config.RecoilHorizontal = 0
    Config.Spread = 5  -- Slight spread for shotgun effect
    Config.MuzzleVelocity = 1000
    Config.BulletsFired = 40  -- 40 pellets per shot!
    Config.ViewPunch = 0
    Config.InitialSpread = 2
    Config.MaxSpread = 5
    Config.ReloadSpeed = 2
    Config.StartDamageDropoff = 50  -- Close range only
    Config.MaxDamageDropOff = 100   -- Shotgun-style falloff
    print("💥 INSTANT KILL! 40 pellets per shot = devastation")
end)

-- Preset 3: Rapid Fire - Maximum fire rate
Preset3.MouseButton1Click:Connect(function()
    Config.FireRate = 5000  -- Max fire rate
    Config.RecoilVertical = 0
    Config.RecoilHorizontal = 0
    Config.Spread = 0
    Config.MuzzleVelocity = 800
    Config.BulletsFired = 1
    Config.ViewPunch = 0
    Config.InitialSpread = 0
    Config.MaxSpread = 0
    Config.ReloadSpeed = 5  -- Super fast reload
    Config.StartDamageDropoff = 9999  -- Infinite range
    Config.MaxDamageDropOff = 9999
    print("⚡ RAPID FIRE! 5000 RPM = bullet storm")
end)

-- Preset 4: Sniper Mode - Perfect long-range accuracy
Preset4.MouseButton1Click:Connect(function()
    Config.FireRate = 300  -- Slow, deliberate shots
    Config.RecoilVertical = 0
    Config.RecoilHorizontal = 0
    Config.Spread = 0
    Config.MuzzleVelocity = 2500  -- Fast bullets for distance
    Config.BulletsFired = 1
    Config.ViewPunch = 0
    Config.InitialSpread = 0
    Config.MaxSpread = 0
    Config.ReloadSpeed = 1.5
    Config.StartDamageDropoff = 9999  -- Perfect for sniping
    Config.MaxDamageDropOff = 9999
    print("🎯 SNIPER MODE! Perfect accuracy at any range")
end)

-- Real-time ammo tracking
RunService.Heartbeat:Connect(function()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        -- Try to get ammo from tool
        local ammoGui = tool:FindFirstChild("AmmoGui") or tool:FindFirstChild("Ammo")
        if ammoGui then
            -- Update ammo display
            AmmoLabel.Text = string.format("📦 Ammo: %d / %d", CurrentAmmo.mag, CurrentAmmo.reserve)
        end
    end
end)

-- BridgeNet2 Interception
equipWeapon:InboundMiddleware({
    function(data)
        if data.wepStats then
            local weaponName = (data.tool and data.tool.Name) or "Unknown"
            CurrentWeapon = weaponName
            WeaponNameLabel.Text = "🔫 Weapon: " .. weaponName
            
            -- Store original stats (only working ones)
            if not next(OriginalStats) then
                OriginalStats = {
                    FireRate = data.wepStats.FireRate or 0,
                    Spread = data.wepStats.Spread or 0,
                    MuzzleVelocity = data.wepStats.MuzzleVelocity or 0,
                    BulletsFired = data.wepStats.BulletsFired or 1
                }
            end
            
            if Config.Enabled then
                pcall(function()
                    local stats = data.wepStats
                    if setreadonly then setreadonly(stats, false) end
                    
                    -- Apply working stats only
                    if rawget(stats, "FireRate") then rawset(stats, "FireRate", Config.FireRate) end
                    if rawget(stats, "FireMode") then rawset(stats, "FireMode", "Auto") end
                    if rawget(stats, "MuzzleVelocity") then rawset(stats, "MuzzleVelocity", Config.MuzzleVelocity) end
                    if rawget(stats, "BulletsFired") then rawset(stats, "BulletsFired", Config.BulletsFired) end
                    if rawget(stats, "Spread") then rawset(stats, "Spread", Config.Spread) end
                    if rawget(stats, "ViewPunch") then rawset(stats, "ViewPunch", Config.ViewPunch) end
                    if rawget(stats, "BurstAmount") then rawset(stats, "BurstAmount", Config.BurstAmount) end
                    
                    if rawget(stats, "Recoil") and type(stats.Recoil) == "table" then
                        if setreadonly then setreadonly(stats.Recoil, false) end
                        if rawget(stats.Recoil, "Vertical") then rawset(stats.Recoil, "Vertical", Config.RecoilVertical) end
                        if rawget(stats.Recoil, "Horizontal") then rawset(stats.Recoil, "Horizontal", Config.RecoilHorizontal) end
                    end
                    
                    if rawget(stats, "Accuracy") and type(stats.Accuracy) == "table" then
                        if setreadonly then setreadonly(stats.Accuracy, false) end
                        if rawget(stats.Accuracy, "initialSpread") then rawset(stats.Accuracy, "initialSpread", Config.InitialSpread) end
                        if rawget(stats.Accuracy, "maxSpread") then rawset(stats.Accuracy, "maxSpread", Config.MaxSpread) end
                    end
                    
                    if rawget(stats, "reloadAnimSpeed") then
                        rawset(stats, "reloadAnimSpeed", Config.ReloadSpeed)
                    end
                    
                    -- Apply damage falloff stats
                    if rawget(stats, "StartDamageDropoff") then
                        rawset(stats, "StartDamageDropoff", Config.StartDamageDropoff)
                    end
                    if rawget(stats, "MaxDamageDropOff") then
                        rawset(stats, "MaxDamageDropOff", Config.MaxDamageDropOff)
                    end
                end)
                
                print(string.format("⚡ %s modified with custom stats!", weaponName))
            end
        end
        
        return data
    end
})

print("✅ ULTIMATE Weapon Editor loaded!")
print("🎯 Every stat is adjustable + Real-time info!")
print("⚡ Try the God Mode preset for maximum chaos!")
