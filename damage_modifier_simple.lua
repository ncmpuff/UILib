-- Simple Damage Modifier GUI
-- Standalone script for Retro Breach

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Config
local DamageMultiplier = 1

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DamageModifierGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 150)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 20, 147)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "💥 Damage Modifier"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Name = "SliderLabel"
SliderLabel.Size = UDim2.new(1, -40, 0, 20)
SliderLabel.Position = UDim2.new(0, 20, 0, 50)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Damage: 1x"
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.TextSize = 14
SliderLabel.Font = Enum.Font.Gotham
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = MainFrame

-- Slider Background
local SliderBg = Instance.new("Frame")
SliderBg.Name = "SliderBg"
SliderBg.Size = UDim2.new(1, -40, 0, 8)
SliderBg.Position = UDim2.new(0, 20, 0, 80)
SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
SliderBg.BorderSizePixel = 0
SliderBg.Parent = MainFrame

local SliderBgCorner = Instance.new("UICorner")
SliderBgCorner.CornerRadius = UDim.new(0, 4)
SliderBgCorner.Parent = SliderBg

-- Slider Fill
local SliderFill = Instance.new("Frame")
SliderFill.Name = "SliderFill"
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBg

local SliderFillCorner = Instance.new("UICorner")
SliderFillCorner.CornerRadius = UDim.new(0, 4)
SliderFillCorner.Parent = SliderFill

-- Slider Button
local SliderButton = Instance.new("TextButton")
SliderButton.Name = "SliderButton"
SliderButton.Size = UDim2.new(0, 20, 0, 20)
SliderButton.Position = UDim2.new(0, -10, 0.5, -10)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderButton.BorderSizePixel = 0
SliderButton.Text = ""
SliderButton.Parent = SliderBg

local SliderButtonCorner = Instance.new("UICorner")
SliderButtonCorner.CornerRadius = UDim.new(1, 0)
SliderButtonCorner.Parent = SliderButton

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -40, 0, 20)
StatusLabel.Position = UDim2.new(0, 20, 0, 100)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "⏳ Waiting..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Slider Logic
local dragging = false
local function updateSlider(input)
    local sliderSize = SliderBg.AbsoluteSize.X
    local sliderPos = SliderBg.AbsolutePosition.X
    local mouseX = input.Position.X
    local relativeX = math.clamp(mouseX - sliderPos, 0, sliderSize)
    local percentage = relativeX / sliderSize
    
    -- Map to 1x - 10x
    DamageMultiplier = math.floor(1 + (percentage * 9))
    
    -- Update UI
    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    SliderButton.Position = UDim2.new(percentage, -10, 0.5, -10)
    SliderLabel.Text = "Damage: " .. DamageMultiplier .. "x"
end

SliderButton.MouseButton1Down:Connect(function()
    dragging = true
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateSlider(input)
    end
end)

SliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        updateSlider(input)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Damage Modifier Hook
local function modifyWeaponStats()
    local workspace = game:GetService("Workspace")
    local statsFolder = workspace:FindFirstChild("Workspace") 
        and workspace.Workspace:FindFirstChild("Lobby") 
        and workspace.Workspace.Lobby:FindFirstChild("GunModels")
        and workspace.Workspace.Lobby.GunModels:FindFirstChild("Stats")
    
    if not statsFolder then
        StatusLabel.Text = "❌ Stats folder not found"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
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
        StatusLabel.Text = string.format("✅ Modified %d weapons", modifiedCount)
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        StatusLabel.Text = "⚠️ No weapons modified"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
end

-- Auto-update when slider changes
local lastMultiplier = DamageMultiplier
task.spawn(function()
    while task.wait(0.5) do
        if DamageMultiplier ~= lastMultiplier then
            lastMultiplier = DamageMultiplier
            modifyWeaponStats()
        end
    end
end)

-- Initial modification
task.wait(1)
modifyWeaponStats()

print("✅ Damage Modifier GUI loaded!")
