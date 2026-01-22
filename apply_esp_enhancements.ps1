$file = "c:\Users\lezpr\Desktop\scripts\Game Scripts\Retro Breach\rbreachv4.34.lua"
$content = Get-Content $file -Raw

Write-Host "Applying ESP enhancements..."

# Step 2: Add ESP toggles in UI
$content = $content -replace '(\}\)[\r\n]+UILib:CreateButton\(ESPPanel, \{[\r\n]+    Text = "Refresh ESP")', @'
})

-- ESP Display Options
UILib:CreateToggle(ESPPanel, {
    Label = "Show Role",
    Default = true,
    Callback = function(value)
        Config.ESPShowRole = value
    end
})
UILib:CreateToggle(ESPPanel, {
    Label = "Show Player Name",
    Default = true,
    Callback = function(value)
        Config.ESPShowName = value
    end
})
UILib:CreateToggle(ESPPanel, {
    Label = "Show Health",
    Default = true,
    Callback = function(value)
        Config.ESPShowHealth = value
    end
})
UILib:CreateToggle(ESPPanel, {
    Label = "Show Player Items",
    Default = true,
    Callback = function(value)
        Config.ESPShowItems = value
    end
})

UILib:CreateButton(ESPPanel, {
    Text = "Refresh ESP"
'@

Write-Host "Step 2: UI toggles added"

# Step 3: Add helper function for items
$content = $content -replace 'local scpTypeCache = \{\}', @'
local function getPlayerItems(character)
    local items = {}
    local player = Players:GetPlayerFromCharacter(character)
    local backpack = player and player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(items, item.Name)
            end
        end
    end
    local equippedItem = character:FindFirstChildOfClass("Tool")
    if equippedItem then
        table.insert(items, equippedItem.Name .. " (E)")
    end
    return table.concat(items, ", ")
end

local scpTypeCache = {}
'@

Write-Host "Step 3: Helper function added"

# Step 4: Add health and items text to ESP creation
$oldCreation = @'
    _G.RetroBreach.ESPHighlights[character] = {
        highlight = highlight,
        teamText = teamText,
        nameText = nameText,
        char = character,
        player = player
    }
'@

$newCreation = @'
    local healthText = pcall(function()
        if not Drawing then return nil end
        local h = Drawing.new("Text")
        h.Visible = false
        h.Center = true
        h.Outline = true
        h.Color = Color3.fromRGB(0, 255, 0)
        h.Size = 14
        h.Text = "HP: 100/100"
        return h
    end) and Drawing.new("Text") or nil
    
    local itemsText = pcall(function()
        if not Drawing then return nil end
        local i = Drawing.new("Text")
        i.Visible = false
        i.Center = true
        i.Outline = true
        i.Color = Color3.fromRGB(255, 255, 0)
        i.Size = 13
        i.Text = ""
        return i
    end) and Drawing.new("Text") or nil
    
    _G.RetroBreach.ESPHighlights[character] = {
        highlight = highlight,
        teamText = teamText,
        nameText = nameText,
        healthText = healthText,
        itemsText = itemsText,
        char = character,
        player = player
    }
'@

$content = $content.Replace($oldCreation, $newCreation)
Write-Host "Step 4: Health and items text added to creation"

# Step 5: Update display logic
$oldDisplay = @'
                    if esp.teamText and esp.player then
                        esp.teamText.Position = Vector2.new(headPos.X, headPos.Y - 20)
                        local teamName = esp.player.Team and esp.player.Team.Name or "No Team"
                        if teamName == "SCP" then
                            if not scpTypeCache[char] then
                                scpTypeCache[char] = getSCPType(char) or teamName
                            end
                            esp.teamText.Text = scpTypeCache[char]
                        else
                            esp.teamText.Text = teamName
                        end
                        esp.teamText.Color = esp.player.Team and esp.player.Team.TeamColor.Color or Color3.fromRGB(200, 200, 200)
                        esp.teamText.Visible = true
                    end
                    esp.nameText.Position = Vector2.new(headPos.X, headPos.Y)
                    esp.nameText.Visible = true
'@

$newDisplay = @'
                    local yOffset = 0
                    
                    -- Role (first)
                    if Config.ESPShowRole and esp.teamText and esp.player then
                        local teamName = esp.player.Team and esp.player.Team.Name or "No Team"
                        if teamName == "SCP" then
                            if not scpTypeCache[char] then
                                scpTypeCache[char] = getSCPType(char) or teamName
                            end
                            esp.teamText.Text = scpTypeCache[char]
                        else
                            esp.teamText.Text = teamName
                        end
                        esp.teamText.Color = esp.player.Team and esp.player.Team.TeamColor.Color or Color3.fromRGB(200, 200, 200)
                        esp.teamText.Position = Vector2.new(headPos.X, headPos.Y + yOffset)
                        esp.teamText.Visible = true
                        yOffset = yOffset + 18
                    elseif esp.teamText then
                        esp.teamText.Visible = false
                    end
                    
                    -- Player Name (second)
                    if Config.ESPShowName and esp.nameText then
                        esp.nameText.Position = Vector2.new(headPos.X, headPos.Y + yOffset)
                        esp.nameText.Visible = true
                        yOffset = yOffset + 20
                    elseif esp.nameText then
                        esp.nameText.Visible = false
                    end
                    
                    -- Health (third)
                    if Config.ESPShowHealth and esp.healthText then
                        local currentHP = math.floor(humanoid.Health)
                        local maxHP = math.floor(humanoid.MaxHealth)
                        esp.healthText.Text = "HP: " .. currentHP .. "/" .. maxHP
                        
                        local hpPercent = humanoid.Health / humanoid.MaxHealth
                        if hpPercent > 0.6 then
                            esp.healthText.Color = Color3.fromRGB(0, 255, 0)
                        elseif hpPercent > 0.3 then
                            esp.healthText.Color = Color3.fromRGB(255, 165, 0)
                        else
                            esp.healthText.Color = Color3.fromRGB(255, 0, 0)
                        end
                        
                        esp.healthText.Position = Vector2.new(headPos.X, headPos.Y + yOffset)
                        esp.healthText.Visible = true
                        yOffset = yOffset + 17
                    elseif esp.healthText then
                        esp.healthText.Visible = false
                    end
                    
                    -- Player Items (fourth)
                    if Config.ESPShowItems and esp.itemsText then
                        local items = getPlayerItems(char)
                        if items ~= "" then
                            esp.itemsText.Text = items
                            esp.itemsText.Position = Vector2.new(headPos.X, headPos.Y + yOffset)
                            esp.itemsText.Visible = true
                        else
                            esp.itemsText.Visible = false
                        end
                    elseif esp.itemsText then
                        esp.itemsText.Visible = false
                    end
'@

$content = $content.Replace($oldDisplay, $newDisplay)
Write-Host "Step 5: Display logic updated"

# Save
Set-Content $file -Value $content
Write-Host "✅ All ESP enhancements applied to rbreachv4.34.lua!"
