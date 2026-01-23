-- ========================================
-- ITEM ESP + AUTO TELEPORT TO ITEMS
-- Highlights items AND teleports you to them
-- ========================================

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Load BridgeNet2 for teleport
local BN2 = require(RS.Assets.Modules.BridgeNet2)
local TeleportPlayer = BN2.ClientBridge("TeleportPlayer")

-- Color coding
local Colors = {
    Weapon = Color3.fromRGB(255, 100, 100),
    Card = Color3.fromRGB(100, 200, 255),
    Support = Color3.fromRGB(100, 255, 100),
    Grenade = Color3.fromRGB(255, 200, 0)
}

local highlightedItems = {}
local itemList = {}

-- Highlight item
local function highlightItem(model)
    if highlightedItems[model] then return end
    
    local itemType = "Weapon"
    if model:HasTag("Card") then itemType = "Card"
    elseif model:HasTag("Support") then itemType = "Support"
    elseif model:HasTag("Grenade") then itemType = "Grenade"
    end
    
    -- Enable prompt (helps but server still validates)
    local prompt = model:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt.Enabled = true
        prompt.MaxActivationDistance = 50
        prompt.RequiresLineOfSight = false
    end
    
    -- ESP
    local highlight = Instance.new("Highlight")
    highlight.Name = "ItemESP"
    highlight.FillColor = Colors[itemType]
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Parent = model
    
    -- Label
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ItemLabel"
    billboardGui.Size = UDim2.new(0, 120, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Adornee = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    billboardGui.Parent = model
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = model.Name .. "\n[Click to TP]"
    textLabel.TextColor3 = Colors[itemType]
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboardGui
    
    -- Make clickable
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 9999
    clickDetector.Parent = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    
    -- Teleport on click
    clickDetector.MouseClick:Connect(function()
        local itemPos = model:GetPivot().Position
        local targetPos = itemPos + Vector3.new(0, 3, 0)  -- Teleport slightly above
        
        -- Chain teleport if too far
        local currentPos = character.HumanoidRootPart.Position
        local distance = (targetPos - currentPos).Magnitude
        
        if distance > 40 then
            -- Chain in 35 stud increments
            local steps = math.ceil(distance / 35)
            for i = 1, steps do
                local progress = i / steps
                local nextPos = currentPos:Lerp(targetPos, progress)
                TeleportPlayer:Fire({CFrame = CFrame.new(nextPos)})
                task.wait(0.05)
            end
        else
            TeleportPlayer:Fire({CFrame = CFrame.new(targetPos)})
        end
        
        warn(string.format("📍 Teleported to %s", model.Name))
    end)
    
    highlightedItems[model] = true
    table.insert(itemList, {
        Name = model.Name,
        Type = itemType,
        Model = model,
        Position = model:GetPivot().Position
    })
    
    model.Destroying:Once(function()
        highlightedItems[model] = nil
    end)
end

-- Scan items
local function scanItems()
    local count = 0
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and (
           model:HasTag("Weapon") or model:HasTag("Card") or 
           model:HasTag("Support") or model:HasTag("Grenade")
        ) then
            highlightItem(model)
            count = count + 1
        end
    end
    return count
end

-- Auto-detect new items
workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("Model") then
        task.wait(0.1)
        if desc:HasTag("Weapon") or desc:HasTag("Card") or 
           desc:HasTag("Support") or desc:HasTag("Grenade") then
            highlightItem(desc)
            warn("🆕 New item:", desc.Name)
        end
    end
end)

-- Initial scan
local count = scanItems()

-- Teleport to nearest item
_G.TPToNearestItem = function()
    local nearestDist = math.huge
    local nearestItem = nil
    local currentPos = character.HumanoidRootPart.Position
    
    for _, item in pairs(itemList) do
        if item.Model:IsDescendantOf(workspace) then
            local dist = (item.Position - currentPos).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestItem = item
            end
        end
    end
    
    if nearestItem then
        local targetPos = nearestItem.Position + Vector3.new(0, 3, 0)
        TeleportPlayer:Fire({CFrame = CFrame.new(targetPos)})
        warn("📍 Teleported to nearest item:", nearestItem.Name)
    else
        warn("❌ No items found!")
    end
end

-- List all items
_G.ListItems = function()
    warn("━━━━━━━━━━━━━━━━━━━━━━━")
    warn("📦 CURRENT ITEMS:")
    for i, item in pairs(itemList) do
        if item.Model:IsDescendantOf(workspace) then
            warn(string.format("%d. %s (%s)", i, item.Name, item.Type))
        end
    end
    warn("━━━━━━━━━━━━━━━━━━━━━━━")
end

warn([[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 ITEM ESP + AUTO TP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Found ]] .. count .. [[ items!

HOW TO USE:
1. Click on any highlighted item to TP to it
2. Or use commands:
   • _G.TPToNearestItem() - TP to closest
   • _G.ListItems() - Show all items

Color codes:
🔴 Red = Weapons
🔵 Blue = Cards
🟢 Green = Support
🟡 Yellow = Grenades

Pro tip: Use freecam (LeftShift+F) to scout,
then click items to teleport to them!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]])
