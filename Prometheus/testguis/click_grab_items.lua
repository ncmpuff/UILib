-- ========================================
-- GUI-BASED ITEM GRABBER v4.0
-- Click items on GUI list - WORKS THROUGH WALLS!
-- ========================================

-- CLEANUP
if _G.ItemGrabberActive then
    warn("🧹 Cleaning up...")
    if _G.ItemGrabberConnections then
        for _, conn in pairs(_G.ItemGrabberConnections) do
            pcall(function() conn:Disconnect() end)
        end
    end
    if _G.ItemGrabberGUI then
        _G.ItemGrabberGUI:Destroy()
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "ItemESP" then
            obj:Destroy()
        end
    end
    _G.ItemGrabberActive = false
    task.wait(0.3)
end

-- Initialize
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
_G.ItemGrabberActive = true
_G.ItemGrabberConnections = {}

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Colors
local Colors = {
    Weapon = Color3.fromRGB(255, 100, 100),
    Card = Color3.fromRGB(100, 200, 255),
    Support = Color3.fromRGB(100, 255, 100),
    Grenade = Color3.fromRGB(255, 200, 0)
}

local itemsList = {}

-- Grab function
local function grabItem(model)
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        warn("❌ Character not ready!")
        return 
    end
    
    local itemPos = model:GetPivot().Position
    local targetPos = itemPos + Vector3.new(0, 3, 0)
    
    warn(string.format("🎯 Grabbing %s", model.Name))
    character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
    
    task.wait(0.15)
    local prompt = model:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt.Enabled = true
        prompt.HoldDuration = 0
        pcall(function() fireproximityprompt(prompt) end)
    end
end

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ItemGrabberGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_G.ItemGrabberGUI = screenGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(1, -320, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "📦 ITEM GRABBER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Scroll frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -100)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = mainFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scrollFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Parent = scrollFrame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(1, -20, 0, 35)
closeBtn.Position = UDim2.new(0, 10, 1, -45)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕ CLOSE"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    _G.StopItemGrabber()
end)

-- Add item to GUI
local function addItemToGUI(model, itemType)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    button.BorderSizePixel = 0
    button.Text = string.format("  %s", model.Name)
    button.TextColor3 = Colors[itemType]
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = scrollFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button
    
    -- Click to grab
    button.MouseButton1Click:Connect(function()
        if model and model.Parent then
            grabItem(model)
        else
            warn("❌ Item no longer exists!")
            button:Destroy()
        end
    end)
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end)
    
    return button
end

-- Setup item
local function setupItem(model)
    local itemType = "Weapon"
    if model:HasTag("Card") then itemType = "Card"
    elseif model:HasTag("Support") then itemType = "Support"
    elseif model:HasTag("Grenade") then itemType = "Grenade"
    end
    
    -- ESP
    local highlight = Instance.new("Highlight")
    highlight.Name = "ItemESP"
    highlight.FillColor = Colors[itemType]
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Parent = model
    
    -- Add to GUI
    local guiButton = addItemToGUI(model, itemType)
    
    -- Store
    table.insert(itemsList, {
        Model = model,
        Type = itemType,
        Button = guiButton
    })
    
    -- Cleanup when destroyed
    model.Destroying:Once(function()
        if guiButton and guiButton.Parent then
            guiButton:Destroy()
        end
    end)
end

-- Scan items
local function scanItems()
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and (
           model:HasTag("Weapon") or model:HasTag("Card") or 
           model:HasTag("Support") or model:HasTag("Grenade")
        ) then
            setupItem(model)
        end
    end
end

-- Watch for new items
local conn1 = workspace.DescendantAdded:Connect(function(desc)
    if not _G.ItemGrabberActive then return end
    if desc:IsA("Model") then
        task.wait(0.1)
        if desc:HasTag("Weapon") or desc:HasTag("Card") or 
           desc:HasTag("Support") or desc:HasTag("Grenade") then
            setupItem(desc)
        end
    end
end)
table.insert(_G.ItemGrabberConnections, conn1)

-- Character respawn
local conn2 = LocalPlayer.CharacterAdded:Connect(function(char)
    character = char
end)
table.insert(_G.ItemGrabberConnections, conn2)

-- Scan and show GUI
scanItems()
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Update scroll size
task.spawn(function()
    task.wait(0.1)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- Stop function
_G.StopItemGrabber = function()
    if _G.ItemGrabberConnections then
        for _, conn in pairs(_G.ItemGrabberConnections) do
            pcall(function() conn:Disconnect() end)
        end
    end
    if _G.ItemGrabberGUI then
        _G.ItemGrabberGUI:Destroy()
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "ItemESP" then
            obj:Destroy()
        end
    end
    _G.ItemGrabberActive = false
    warn("🛑 Item Grabber stopped!")
end

warn([[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
� GUI ITEM GRABBER v4.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ GUI menu on right side of screen!
✅ Click item names to teleport & grab!
✅ WORKS THROUGH WALLS! (GUI-based)
✅ Color-coded list

HOW TO USE:
1. Look at the GUI menu (right side)
2. Click any item name
3. Auto-teleports and grabs it!

Colors in list:
🔴 Red = Weapons
🔵 Blue = Cards
🟢 Green = Support
🟡 Yellow = Grenades

Commands:
• _G.StopItemGrabber() - Stop & close

Enjoy! �
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]])
