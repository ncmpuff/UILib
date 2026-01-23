-- Rapid Fire Test GUI v2
-- Uses BridgeNet2 interception (no getgc needed!)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Config
local RapidFireEnabled = false
local FireRate = 1900  -- RPM
local currentWeaponName = "None"

-- Get BridgeNet2
local RS = game:GetService("ReplicatedStorage")
local BridgeNet2 = require(RS.Assets.Modules.BridgeNet2)
local equipWeapon = BridgeNet2.ClientBridge("equipWeapon")

-- Create simple GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RapidFireTest"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 20, 147)
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Make draggable
local dragging = false
local dragInput, mousePos, framePos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "Rapid Fire Tester v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -20, 0, 35)
ToggleButton.Position = UDim2.new(0, 10, 0, 45)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Text = "Rapid Fire: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

-- Fire Rate Label
local RateLabel = Instance.new("TextLabel")
RateLabel.Size = UDim2.new(1, -20, 0, 20)
RateLabel.Position = UDim2.new(0, 10, 0, 90)
RateLabel.BackgroundTransparency = 1
RateLabel.Text = "Fire Rate: 1900 RPM"
RateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RateLabel.TextSize = 14
RateLabel.Font = Enum.Font.Gotham
RateLabel.Parent = MainFrame

-- Fire Rate Slider
local SliderBG = Instance.new("Frame")
SliderBG.Size = UDim2.new(1, -20, 0, 20)
SliderBG.Position = UDim2.new(0, 10, 0, 115)
SliderBG.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderBG.BorderSizePixel = 0
SliderBG.Parent = MainFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 10)
SliderCorner.Parent = SliderBG

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.9, 0, 1, 0)  -- 90% = 1900 out of ~2000
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBG

local SliderFillCorner = Instance.new("UICorner")
SliderFillCorner.CornerRadius = UDim.new(0, 10)
SliderFillCorner.Parent = SliderFill

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 145)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Method: BridgeNet2 (No getgc!)"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- Weapon Label
local WeaponLabel = Instance.new("TextLabel")
WeaponLabel.Size = UDim2.new(1, -20, 0, 20)
WeaponLabel.Position = UDim2.new(0, 10, 0, 170)
WeaponLabel.BackgroundTransparency = 1
WeaponLabel.Text = "Current: None"
WeaponLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
WeaponLabel.TextSize = 11
WeaponLabel.Font = Enum.Font.Gotham
WeaponLabel.Parent = MainFrame

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Slider interaction
local sliderDragging = false

SliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
        
        local mouseX = input.Position.X
        local sliderX = SliderBG.AbsolutePosition.X
        local sliderWidth = SliderBG.AbsoluteSize.X
        local percent = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        
        FireRate = math.floor(100 + (percent * 1900))  -- 100 to 2000 RPM
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        RateLabel.Text = string.format("Fire Rate: %d RPM", FireRate)
    end
end)

SliderBG.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local sliderX = SliderBG.AbsolutePosition.X
        local sliderWidth = SliderBG.AbsoluteSize.X
        local percent = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        
        FireRate = math.floor(100 + (percent * 1900))  -- 100 to 2000 RPM
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        RateLabel.Text = string.format("Fire Rate: %d RPM", FireRate)
    end
end)

-- Toggle button
ToggleButton.MouseButton1Click:Connect(function()
    RapidFireEnabled = not RapidFireEnabled
    
    if RapidFireEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "Rapid Fire: ON"
        StatusLabel.Text = "✅ Intercepting weapon equips..."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "Rapid Fire: OFF"
        StatusLabel.Text = "Method: BridgeNet2 (No getgc!)"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- Close button
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- BridgeNet2 Interception - This is where the magic happens!
equipWeapon:InboundMiddleware({
    function(data)
        if RapidFireEnabled and data.wepStats then
            -- Get weapon name
            local weaponName = "Unknown"
            if data.tool and data.tool.Name then
                weaponName = data.tool.Name
            end
            
            currentWeaponName = weaponName
            WeaponLabel.Text = "Current: " .. weaponName
            
            -- Store original values for debugging
            local originalFireRate = data.wepStats.FireRate or "N/A"
            local originalFireMode = data.wepStats.FireMode or "N/A"
            
            -- Modify stats BEFORE they reach the game!
            pcall(function()
                if setreadonly then
                    setreadonly(data.wepStats, false)
                end
                
                -- Set custom fire rate
                if rawget(data.wepStats, "FireRate") then
                    rawset(data.wepStats, "FireRate", FireRate)
                end
                
                -- Force auto mode for semi-auto weapons
                if rawget(data.wepStats, "FireMode") then
                    rawset(data.wepStats, "FireMode", "Auto")
                end
            end)
            
            print(string.format(
                "🔥 Rapid Fire Applied to %s | Original: %s RPM (%s) → Modified: %d RPM (Auto)",
                weaponName,
                tostring(originalFireRate),
                tostring(originalFireMode),
                FireRate
            ))
        end
        
        return data
    end
})

print("✅ Rapid Fire Tester v2 loaded!")
print("📡 Using BridgeNet2 interception (faster & more reliable!)")
print("🎯 Toggle rapid fire and adjust slider to test")
