-- ========================================
-- ITEM ESP + WALLHACK PICKUP
-- Highlights all items and allows pickup through walls
-- ========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Color coding by item type
local Colors = {
    Weapon = Color3.fromRGB(255, 100, 100),    -- Red
    Card = Color3.fromRGB(100, 200, 255),      -- Blue
    Support = Color3.fromRGB(100, 255, 100),   -- Green
    Grenade = Color3.fromRGB(255, 200, 0)      -- Yellow
}

-- Track highlighted items
local highlightedItems = {}

-- Function to highlight an item
local function highlightItem(model)
    -- Prevent duplicate highlights
    if highlightedItems[model] then return end
    
    -- Determine item type
    local itemType = "Weapon"  -- default
    if model:HasTag("Card") then
        itemType = "Card"
    elseif model:HasTag("Support") then
        itemType = "Support"
    elseif model:HasTag("Grenade") then
        itemType = "Grenade"
    end
    
    -- Enable proximity prompt
    local prompt = model:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt.Enabled = true
        prompt.MaxActivationDistance = 9999
        prompt.RequiresLineOfSight = false
    end
    
    -- Add ESP highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ItemESP"
    highlight.FillColor = Colors[itemType]
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.3
    highlight.Parent = model
    
    -- Add text label
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ItemLabel"
    billboardGui.Size = UDim2.new(0, 100, 0, 40)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Adornee = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    billboardGui.Parent = model
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = model.Name
    textLabel.TextColor3 = Colors[itemType]
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboardGui
    
    -- Track it
    highlightedItems[model] = true
    
    -- Clean up when destroyed
    model.Destroying:Once(function()
        highlightedItems[model] = nil
    end)
end

-- Function to scan for items
local function scanItems()
    local count = 0
    
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and (
           model:HasTag("Weapon") or 
           model:HasTag("Card") or 
           model:HasTag("Support") or 
           model:HasTag("Grenade")
        ) then
            highlightItem(model)
            count = count + 1
        end
    end
    
    return count
end

-- Initial scan
local itemCount = scanItems()
warn(string.format("✅ Item ESP Active! Found %d items", itemCount))

-- Auto-detect new items that spawn
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") then
        task.wait(0.1)  -- Wait for tags to be set
        
        if descendant:HasTag("Weapon") or 
           descendant:HasTag("Card") or 
           descendant:HasTag("Support") or 
           descendant:HasTag("Grenade") then
            highlightItem(descendant)
            warn("🆕 New item detected:", descendant.Name)
        end
    end
end)

-- Toggle function (store in global)
_G.ToggleItemESP = function()
    for model, _ in pairs(highlightedItems) do
        if model:IsDescendantOf(workspace) then
            local highlight = model:FindFirstChild("ItemESP")
            local label = model:FindFirstChild("ItemLabel")
            
            if highlight then
                highlight.Enabled = not highlight.Enabled
            end
            if label then
                label.Enabled = not label.Enabled
            end
        end
    end
    warn("🔄 Item ESP toggled")
end

-- Info
warn([[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 ITEM ESP + WALLHACK ACTIVE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Features:
✅ All items highlighted
✅ Pickup through walls
✅ Infinite range (9999 studs)
✅ Color coded by type:
   🔴 Red = Weapons
   🔵 Blue = Cards
   🟢 Green = Support items
   🟡 Yellow = Grenades

Commands:
• _G.ToggleItemESP() - Toggle on/off

Enjoy! 🎯
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]])
