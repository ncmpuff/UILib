print("===================================")
print("[*] Retro Breach V2 - Starting...")
print("===================================")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
print("[+] Services loaded!")
if _G.RetroBreach then
    print("[*] Cleaning up old instance...")
    if _G.RetroBreach.Connections then
        for _, conn in ipairs(_G.RetroBreach.Connections) do
            pcall(function() conn:Disconnect() end)
        end
    end
    if _G.RetroBreach.ESPHighlights then
        for _, esp in pairs(_G.RetroBreach.ESPHighlights) do
            if esp.highlight then pcall(function() esp.highlight:Destroy() end) end
            if esp.nameText then pcall(function() esp.nameText:Remove() end) end
        end
    end
    if _G.RetroBreach.Guis then
        for _, gui in ipairs(_G.RetroBreach.Guis) do
            pcall(function() gui:Destroy() end)
        end
    end
end
_G.RetroBreach = {
    Connections = {},
    ESPHighlights = {},
    Guis = {}
}
print("[*] Loading UILIB...")
local UILib
local success, result = pcall(function()
    if isfile and isfile("UILIB.lua") then
        print("  -> Found local UILIB.lua")
        return loadstring(readfile("UILIB.lua"))()
    end
end)
if success and result then
    UILib = result
    print("[+] UILIB loaded from local file!")
else
    print("  -> Local file not found, loading from GitHub...")
    local repo = "https://raw.githubusercontent.com/ncmpuff/UILib/refs/heads/main/"
    local webSuccess, webResult = pcall(function()
        return loadstring(game:HttpGet(repo .. "UILIB.lua"))()
    end)
    if webSuccess and webResult then
        UILib = webResult
        print("[+] UILIB loaded from GitHub!")
    else
        warn("[!] FAILED to load UILIB")
        return
    end
end
if not UILib then
    warn("[!] UILib is nil!")
    return
end
print("[+] UILib ready!")
local Config = {
    PlayerESP = false,
    SCPESP = false,
    ItemESP = false,
    Aimbot = false,
    AimbotFOV = 200,
    AimbotSmooth = 5,
    TeamCheck = true,
    WalkSpeed = 16,
    JumpPower = 50,
    NoClip = false,
    InfiniteStamina = false,
    FullBright = false,
    ItemTeleport = false,
    InstantReload = false
}
local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end
local function getHead(char)
    return char:FindFirstChild("Head")
end
local function getHumanoid(char)
    return char:FindFirstChildOfClass("Humanoid")
end
local function getSCPType(character)
    if not character then return nil end
    
    -- Check for SCP-035 (The Mask)
    for _, accessory in ipairs(character:GetDescendants()) do
        if accessory:IsA("Accessory") or accessory:IsA("Hat") then
            local name = accessory.Name
            if name:find("HappyMask") or name:find("Ghostface") then
                return "The Mask"
            end
        end
    end
    
    -- Check for SCP-049 (Plague Doctor) - shirt ID 11499060129
    local shirt = character:FindFirstChildOfClass("Shirt")
    if shirt and shirt.ShirtTemplate:find("11499060129") then
        return "Plague Doctor"
    end
    
    -- Check for SCP-049-2 (Zombie) - shirt ID 2938677333
    if shirt and shirt.ShirtTemplate:find("2938677333") then
        return "Zombie"
    end
    
    -- Check for SCP-076-2 (Cain) - shirt ID 16099679561
    if shirt and shirt.ShirtTemplate:find("16099679561") then
        return "Cain"
    end
    
    -- Check for SCP-457 (Burning Man) - Flame in HumanoidRootPart (check BEFORE Old Man since they share same shirt)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart and rootPart:FindFirstChild("Flame") then
        return "Burning Man"
    end
    
    -- Check for SCP-106 (The Old Man) - shirt ID 11514423812
    if shirt and shirt.ShirtTemplate:find("11514423812") then
        return "The Old Man"
    end
    
    -- Check for SCP-966 (Ghost) - TransparencyMode NumberValue or white body colors
    if character:FindFirstChild("TransparencyMode") then
        return "Ghost"
    end
    local bodyColors = character:FindFirstChildOfClass("BodyColors")
    if bodyColors then
        local white = Color3.fromRGB(255, 255, 255)
        if bodyColors.HeadColor3 == white and 
           bodyColors.TorsoColor3 == white and
           bodyColors.LeftArmColor3 == white and
           bodyColors.RightArmColor3 == white then
            return "Ghost"
        end
    end
    
    -- Check for SCP-173
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            if part.BrickColor == BrickColor.new("Really black") or part.BrickColor == BrickColor.new("Dark stone grey") then
                if character.Name:find("173") then
                    return "SCP-173"
                end
            end
        end
    end
    
    return nil
end
local function createPlayerESP(character)
    if character == LocalPlayer.Character then return end
    if _G.RetroBreach.ESPHighlights[character] then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local player = Players:GetPlayerFromCharacter(character)
    if not player then return end
    local success, highlight = pcall(function()
        local h = Instance.new("Highlight")
        h.Parent = character
        h.Adornee = character
        h.FillTransparency = 0.5
        h.OutlineTransparency = 1
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.FillColor = Color3.fromRGB(0, 255, 0)
        return h
    end)
    if not success then return end
    local teamSuccess, teamText = pcall(function()
        local t = Drawing.new("Text")
        t.Visible = false
        t.Center = true
        t.Outline = true
        t.Color = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(200, 200, 200)
        t.Size = 14
        local teamName = player.Team and player.Team.Name or "No Team"
        if teamName == "SCP" then
            local scpType = getSCPType(character)
            t.Text = scpType or teamName
        else
            t.Text = teamName
        end
        return t
    end)
    if not teamSuccess then
        pcall(function() highlight:Destroy() end)
        return
    end
    local nameSuccess, nameText = pcall(function()
        local n = Drawing.new("Text")
        n.Visible = false
        n.Center = true
        n.Outline = true
        n.Color = Color3.fromRGB(255, 255, 255)
        n.Size = 18
        n.Text = character.Name
        return n
    end)
    if not nameSuccess then
        pcall(function() highlight:Destroy() end)
        pcall(function() teamText:Remove() end)
        return
    end
    _G.RetroBreach.ESPHighlights[character] = {
        highlight = highlight,
        teamText = teamText,
        nameText = nameText,
        char = character,
        player = player
    }
end
local function updatePlayerESP()
    if not Config.PlayerESP then
        -- Hide all highlights when ESP is disabled
        for char, esp in pairs(_G.RetroBreach.ESPHighlights) do
            if esp.highlight then esp.highlight.Enabled = false end
            if esp.teamText then esp.teamText.Visible = false end
            if esp.nameText then esp.nameText.Visible = false end
        end
        return
    end
    
    for char, esp in pairs(_G.RetroBreach.ESPHighlights) do
        if not char or not char.Parent then
            if esp.highlight then pcall(function() esp.highlight:Destroy() end) end
            if esp.teamText then pcall(function() esp.teamText:Remove() end) end
            if esp.nameText then pcall(function() esp.nameText:Remove() end) end
            _G.RetroBreach.ESPHighlights[char] = nil
        elseif char and char.Parent then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            if humanoid and head then
                local hpPercent = humanoid.Health / humanoid.MaxHealth
                if hpPercent > 0.6 then
                    esp.highlight.FillColor = Color3.fromRGB(0, 255, 0)
                elseif hpPercent > 0.3 then
                    esp.highlight.FillColor = Color3.fromRGB(255, 165, 0)
                else
                    esp.highlight.FillColor = Color3.fromRGB(255, 0, 0)
                end
                local headPos3D = head.Position + Vector3.new(0, head.Size.Y/2 + 0.5, 0)
                local headPos, onScreen = Camera:WorldToViewportPoint(headPos3D)
                if onScreen then
                    -- Enable highlight when on screen
                    esp.highlight.Enabled = true
                    
                    if esp.teamText and esp.player then
                        esp.teamText.Position = Vector2.new(headPos.X, headPos.Y - 20)
                        local teamName = esp.player.Team and esp.player.Team.Name or "No Team"
                        if teamName == "SCP" then
                            local scpType = getSCPType(char)
                            esp.teamText.Text = scpType or teamName
                        else
                            esp.teamText.Text = teamName
                        end
                        esp.teamText.Color = esp.player.Team and esp.player.Team.TeamColor.Color or Color3.fromRGB(200, 200, 200)
                        esp.teamText.Visible = true
                    end
                    esp.nameText.Position = Vector2.new(headPos.X, headPos.Y)
                    esp.nameText.Visible = true
                else
                    -- Disable highlight when off screen
                    esp.highlight.Enabled = false
                    if esp.teamText then esp.teamText.Visible = false end
                    esp.nameText.Visible = false
                end
            else
                -- Disable if no humanoid/head
                esp.highlight.Enabled = false
                if esp.teamText then esp.teamText.Visible = false end
                esp.nameText.Visible = false
            end
        end
    end
end
local SCPHighlights = {}
local function isSCP(model)
    local name = model.Name
    return name:match("SCP%-") or name:match("SCO%-") or name == "SCP-049" or name == "SCP-106" or name == "SCP-076-2"
end
local function updateSCPESP()
    for _, highlight in pairs(SCPHighlights) do
        pcall(function() highlight:Destroy() end)
    end
    SCPHighlights = {}
    if not Config.SCPESP then return end
    local scpCount = 0
    for _, model in ipairs(Workspace:WaitForChild("Workspace"):GetChildren()) do
        if isSCP(model) and model:FindFirstChildOfClass("Humanoid") then
            scpCount = scpCount + 1
            local highlight = Instance.new("Highlight")
            highlight.Parent = model
            highlight.Adornee = model
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 1
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            SCPHighlights[model] = highlight
            print("[+] Added SCP ESP:", model.Name)
        end
    end
    if scpCount == 0 then
        print("[!] No SCPs found in Workspace.Workspace")
    end
end
local ItemHighlights = {}
local ITEM_ESP_DISTANCE = 150
local MAX_ITEMS_PER_UPDATE = 10
local itemProcessIndex = 1
local function updateItemESP()
    if not Config.ItemESP or not LocalPlayer.Character then
        for _, espData in pairs(ItemHighlights) do
            if espData.highlight then pcall(function() espData.highlight:Destroy() end) end
            if espData.nameText then pcall(function() espData.nameText:Remove() end) end
        end
        ItemHighlights = {}
        return
    end
    local myRoot = getRoot(LocalPlayer.Character)
    if not myRoot then return end
    local itemsFolder = Workspace:FindFirstChild("ItemSpawns")
    if not itemsFolder then return end
    local allItems = itemsFolder:GetChildren()
    local totalItems = #allItems
    if totalItems == 0 then return end
    if itemProcessIndex > totalItems then
        itemProcessIndex = 1
    end
    local itemsInRange = {}
    local itemsProcessed = 0
    while itemsProcessed < MAX_ITEMS_PER_UPDATE and itemProcessIndex <= totalItems do
        local item = allItems[itemProcessIndex]
        itemProcessIndex = itemProcessIndex + 1
        if item then
            local handle = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
            if handle then
                local distance = (handle.Position - myRoot.Position).Magnitude
                if distance <= ITEM_ESP_DISTANCE then
                    itemsInRange[item] = true
                    if not ItemHighlights[item] then
                        pcall(function()
                            local highlight = Instance.new("Highlight")
                            highlight.Parent = handle
                            highlight.Adornee = handle
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 1
                            highlight.FillColor = Color3.fromRGB(255, 255, 0)
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            local nameText = Drawing.new("Text")
                            nameText.Center = true
                            nameText.Outline = true
                            nameText.Color = Color3.fromRGB(255, 255, 0)
                            nameText.Size = 16
                            nameText.Text = item.Name
                            nameText.Visible = false
                            ItemHighlights[item] = {
                                highlight = highlight,
                                nameText = nameText,
                                handle = handle
                            }
                        end)
                    end
                end
            end
        end
        itemsProcessed = itemsProcessed + 1
    end
    for item, espData in pairs(ItemHighlights) do
        if item and item.Parent then
            local handle = espData.handle
            if handle and handle.Parent then
                local distance = (handle.Position - myRoot.Position).Magnitude
                if distance <= ITEM_ESP_DISTANCE then
                    itemsInRange[item] = true
                    if espData.nameText then
                        local itemPos3D = handle.Position + Vector3.new(0, handle.Size.Y/2 + 1, 0)
                        local itemPos, onScreen = Camera:WorldToViewportPoint(itemPos3D)
                        espData.nameText.Position = Vector2.new(itemPos.X, itemPos.Y)
                        espData.nameText.Visible = onScreen
                    end
                end
            end
        end
    end
    for item, espData in pairs(ItemHighlights) do
        if not item or not item.Parent or not itemsInRange[item] then
            if espData.highlight then pcall(function() espData.highlight:Destroy() end) end
            if espData.nameText then pcall(function() espData.nameText:Remove() end) end
            ItemHighlights[item] = nil
        end
    end
end
local function getClosestPlayer()
    local success, result = pcall(function()
        local closestPlayer = nil
        local shortestDistance = Config.AimbotFOV
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = getHead(player.Character)
                local humanoid = getHumanoid(player.Character)
                if head and humanoid and humanoid.Health > 0 then
                    if Config.TeamCheck and player.Team and LocalPlayer.Team then
                        if player.Team == LocalPlayer.Team then
                            continue
                        end
                    end
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
        return closestPlayer
    end)
    return success and result or nil
end
local function updateAimbot()
    pcall(function()
        if not Config.Aimbot then return end
        if not Camera then return end
        local isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if isAiming then
            local target = getClosestPlayer()
            if target and target.Character then
                local head = getHead(target.Character)
                if head then
                    local targetPos = head.Position
                    local camera = Camera.CFrame.Position
                    local direction = (targetPos - camera).Unit
                    local currentLook = Camera.CFrame.LookVector
                    local smoothed = currentLook:Lerp(direction, 1 / Config.AimbotSmooth)
                    Camera.CFrame = CFrame.new(camera, camera + smoothed)
                end
            end
        end
    end)
end
local aimbotConnection = RunService.RenderStepped:Connect(function()
    pcall(updateAimbot)
end)
table.insert(_G.RetroBreach.Connections, aimbotConnection)
print("[*] Creating UI...")
local Window = UILib:CreateWindow({
    Title = "Retro Breach V2",
    Size = UDim2.fromOffset(550, 400),
    Position = UDim2.fromOffset(100, 100)
})
table.insert(_G.RetroBreach.Guis, Window.ScreenGui)
Window:AddToggleKey(Enum.KeyCode.RightShift)
UILib:CreateNotification({Text = "Press Right Shift to Toggle UI", Duration = 5})
local CombatPanel = UILib:CreatePanel(Window, {
    Name = "Combat",
    DisplayName = "Combat"
})
UILib:CreateToggle(CombatPanel, {
    Label = "Aimbot (Hold Right Click)",
    Default = false,
    Callback = function(value)
        Config.Aimbot = value
    end
})
UILib:CreateSlider(CombatPanel, {
    Text = "Aimbot FOV",
    Min = 50,
    Max = 500,
    Default = 200,
    Callback = function(value)
        Config.AimbotFOV = value
    end
})
UILib:CreateSlider(CombatPanel, {
    Text = "Aimbot Smoothness",
    Min = 1,
    Max = 20,
    Default = 5,
    Callback = function(value)
        Config.AimbotSmooth = value
    end
})
UILib:CreateToggle(CombatPanel, {
    Label = "Only Target Enemies",
    Default = true,
    Callback = function(value)
        Config.TeamCheck = value
    end
})
local ESPPanel = UILib:CreatePanel(Window, {
    Name = "ESP",
    DisplayName = "ESP"
})
UILib:CreateToggle(ESPPanel, {
    Label = "Player ESP",
    Default = false,
    Callback = function(value)
        Config.PlayerESP = value
        if value then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    createPlayerESP(player.Character)
                end
            end
        else
            for _, esp in pairs(_G.RetroBreach.ESPHighlights) do
                if esp.highlight then pcall(function() esp.highlight:Destroy() end) end
                if esp.teamText then pcall(function() esp.teamText:Remove() end) end
                if esp.nameText then pcall(function() esp.nameText:Remove() end) end
            end
            _G.RetroBreach.ESPHighlights = {}
        end
    end
})
UILib:CreateToggle(ESPPanel, {
    Label = "Item ESP",
    Default = false,
    Callback = function(value)
        Config.ItemESP = value
        updateItemESP()
    end
})
UILib:CreateButton(ESPPanel, {
    Text = "Refresh ESP",
    Callback = function()
        updateItemESP()
        print("ESP Refreshed!")
    end
})
local PlayerPanel = UILib:CreatePanel(Window, {
    Name = "Player",
    DisplayName = "Player"
})
UILib:CreateSlider(PlayerPanel, {
    Text = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        Config.WalkSpeed = value
    end
})
UILib:CreateSlider(PlayerPanel, {
    Text = "Jump Power",
    Min = 50,
    Max = 200,
    Default = 50,
    Callback = function(value)
        Config.JumpPower = value
    end
})
local originalCollisionStates = {}
UILib:CreateToggle(PlayerPanel, {
    Label = "NoClip (Toggle Or Hold B)",
    Default = false,
    Callback = function(value)
        Config.NoClip = value
        if not value and LocalPlayer.Character then
            for part, originalState in pairs(originalCollisionStates) do
                if part and part.Parent then
                    part.CanCollide = originalState
                end
            end
            originalCollisionStates = {}
        elseif value and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    originalCollisionStates[part] = part.CanCollide
                end
            end
        end
    end
})

-- Item selection with dropdown
local selectedItem = nil
local allItems = {}

-- Function to scan and get unique items within 200 studs
local function getUniqueItems()
    local success, result = pcall(function()
        local itemsFolder = Workspace:FindFirstChild("ItemSpawns")
        if not itemsFolder then
            return {"No ItemSpawns folder"}
        end
        
        -- Check if player character exists
        if not LocalPlayer.Character then
            return {"Waiting for character..."}
        end
        
        local myRoot = getRoot(LocalPlayer.Character)
        if not myRoot then
            return {"No HumanoidRootPart"}
        end
        
        -- List of non-items to exclude (zone markers)
        local excludeList = {
            "EZ1", "EZ2", "EZ3", "EZ4",
            "HCZ1", "HCZ2",
            "LCZ1", "LCZ2", "LCZ3", "LCZ4", "LCZ5", "LCZ6", "LCZ7", "LCZ8",
            "Part", "SU1"
        }
        
        local itemDistances = {}
        local MAX_DISTANCE = 200
        
        -- Scan all instances and track closest distance for each item type
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local itemName = item.Name
            -- Skip if in exclude list
            local shouldExclude = false
            for _, excluded in ipairs(excludeList) do
                if itemName == excluded then
                    shouldExclude = true
                    break
                end
            end
            
            if not shouldExclude then
                local handle = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
                if handle then
                    local distance = (handle.Position - myRoot.Position).Magnitude
                    -- Track closest instance of this item type
                    if not itemDistances[itemName] or distance < itemDistances[itemName] then
                        itemDistances[itemName] = distance
                    end
                end
            end
        end
        
        -- Only include items within range
        local itemNames = {}
        for itemName, distance in pairs(itemDistances) do
            print(string.format("[DEBUG] %s: %.1f studs", itemName, distance))
            if distance <= MAX_DISTANCE then
                table.insert(itemNames, itemName)
                print(string.format("  -> ADDED (within 200 studs)"))
            else
                print(string.format("  -> SKIPPED (too far)"))
            end
        end
        table.sort(itemNames)
        
        print(string.format("[*] Scan complete: %d items within %d studs (out of %d total)", #itemNames, MAX_DISTANCE, #itemsFolder:GetChildren()))
        
        if #itemNames == 0 then
            return {"No items within 200 studs"}
        end
        
        return itemNames
    end)
    
    if success then
        return result
    else
        warn("[!] Error scanning items:", result)
        return {"Error scanning items"}
    end
end

-- Initialize items
allItems = getUniqueItems()

-- Create dropdown and store reference for dynamic updates
local itemDropdown = UILib:CreateDropdown(PlayerPanel, {
    Label = "Items Within 200 Studs (Auto-Updates)",
    Options = allItems,
    EnableSearch = true,
    Callback = function(option)
        selectedItem = option
        print("[*] Selected:", option)
    end
})

-- Auto-refresh every 3 seconds and dynamically update dropdown
task.spawn(function()
    while true do
        task.wait(3)
        local newItems = getUniqueItems()
        
        -- Update dropdown with new items using UpdateOptions
        if itemDropdown and itemDropdown.UpdateOptions then
            itemDropdown.UpdateOptions(newItems)
        end
        
        allItems = newItems
    end
end)

-- Smooth teleport function with crash protection
local function smoothTeleport(targetPos, stepSize)
    local success, result = pcall(function()
        if not LocalPlayer.Character then return false end
        local myRoot = getRoot(LocalPlayer.Character)
        if not myRoot then return false end
        
        local startPos = myRoot.Position
        local distance = (targetPos - startPos).Magnitude
        
        -- Calculate steps with MAX LIMIT to prevent crashes
        local steps = math.ceil(distance / stepSize)
        local MAX_STEPS = 15
        
        if steps > MAX_STEPS then
            stepSize = math.ceil(distance / MAX_STEPS)
            steps = MAX_STEPS
        end
        
        -- Incremental teleport with crash protection
        for i = 1, steps do
            if not myRoot or not myRoot.Parent then break end
            
            local alpha = i / steps
            local newPos = startPos:Lerp(targetPos, alpha)
            
            pcall(function()
                myRoot.CFrame = CFrame.new(newPos)
                -- Reset all velocity types
                myRoot.Velocity = Vector3.new(0, 0, 0)
                myRoot.RotVelocity = Vector3.new(0, 0, 0)
                if myRoot.AssemblyLinearVelocity then
                    myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
                if myRoot.AssemblyAngularVelocity then
                    myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end)
            
            -- Physics-safe delay
            RunService.Heartbeat:Wait()
            task.wait(math.random(10, 15) / 100)
            
            -- Extra break every 5 steps
            if i % 5 == 0 then
                task.wait(0.1)
            end
        end
        
        return true
    end)
    
    return success and result
end

-- Grab Selected Item button
UILib:CreateButton(PlayerPanel, {
    Text = "Grab Selected Item",
    Callback = function()
        local success, err = pcall(function()
            if not selectedItem or selectedItem == "Scanning..." or selectedItem == "No items found" or selectedItem == "No ItemSpawns folder" then
                warn("[!] Please select a valid item first!")
                return
            end
            if not LocalPlayer.Character then
                warn("[!] No character found!")
                return
            end
            local myRoot = getRoot(LocalPlayer.Character)
            if not myRoot then
                warn("[!] No HumanoidRootPart found!")
                return
            end
            
            -- Scan items dynamically each time (always up-to-date)
            local itemsFolder = Workspace:FindFirstChild("ItemSpawns")
            if not itemsFolder then
                warn("[!] ItemSpawns folder not found!")
                return
            end
            
            -- Find the CLOSEST instance of the selected item
            local targetItem = nil
            local targetItemModel = nil
            local closestDistance = math.huge
            
            for _, item in ipairs(itemsFolder:GetChildren()) do
                if item.Name == selectedItem then
                    local handle = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
                    if handle then
                        local distance = (handle.Position - myRoot.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            targetItem = handle
                            targetItemModel = item
                        end
                    end
                end
            end
            
            if targetItem and targetItemModel then
                local originalPos = myRoot.CFrame
                local distance = (targetItem.Position - myRoot.Position).Magnitude
                
                if distance > 200 then
                    UILib:CreateNotification({Text = "Item too far: " .. math.floor(distance) .. " studs! (Max 200)", Duration = 4})
                    return
                end
                
                print("[*] Item is", math.floor(distance), "studs away")
                
                -- Instant teleport to item
                myRoot.CFrame = targetItem.CFrame * CFrame.new(0, 2, 0)
                task.wait(0.2)
                
                -- Try to find ProximityPrompt in descendants
                local proximityPrompt = targetItemModel:FindFirstChildOfClass("ProximityPrompt", true)
                if not proximityPrompt then
                    for _, descendant in ipairs(targetItemModel:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            proximityPrompt = descendant
                            break
                        end
                    end
                end
                
                -- Try ProximityPrompt first
                if proximityPrompt then
                    print("[+] Found ProximityPrompt on:", targetItemModel.Name)
                    -- Fire multiple times with longer delays for reliability
                    fireproximityprompt(proximityPrompt)
                    task.wait(0.2)
                    fireproximityprompt(proximityPrompt)
                    task.wait(0.2)
                    fireproximityprompt(proximityPrompt)
                    task.wait(0.3) -- Final wait to ensure server registers pickup
                    print("[+] Grabbed item (ProximityPrompt):", targetItemModel.Name, "- Distance:", math.floor(distance), "studs")
                else
                    -- Fallback to ClickDetector
                    local clickDetector = targetItemModel:FindFirstChildOfClass("ClickDetector", true)
                    if not clickDetector then
                        for _, descendant in ipairs(targetItemModel:GetDescendants()) do
                            if descendant:IsA("ClickDetector") then
                                clickDetector = descendant
                                break
                            end
                        end
                    end
                    
                    if clickDetector then
                        print("[+] Found ClickDetector on:", targetItemModel.Name)
                        -- Fire multiple times with longer delays for reliability
                        fireclickdetector(clickDetector)
                        task.wait(0.2)
                        fireclickdetector(clickDetector)
                        task.wait(0.2)
                        fireclickdetector(clickDetector)
                        task.wait(0.3) -- Final wait to ensure server registers pickup
                        print("[+] Grabbed item (ClickDetector):", targetItemModel.Name, "- Distance:", math.floor(distance), "studs")
                    else
                        warn("[!] No ProximityPrompt or ClickDetector found on:", targetItemModel.Name)
                    end
                end
                
                -- Instant teleport back
                if myRoot and myRoot.Parent then
                    myRoot.Velocity = Vector3.new(0, 0, 0)
                    myRoot.RotVelocity = Vector3.new(0, 0, 0)
                    local humanoid = getHumanoid(LocalPlayer.Character)
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                    myRoot.CFrame = originalPos
                end
            else
                warn("[!] Item '" .. selectedItem .. "' not found on map (may have been picked up or despawned)")
            end
        end)
        
        if not success then
            warn("[!] Error grabbing item:", err)
        end
    end
})
UILib:CreateButton(PlayerPanel, {
    Text = "Escape",
    Callback = function()
        local success, err = pcall(function()
            if not LocalPlayer.Character then
                warn("[!] No character found!")
                return
            end
            local myRoot = getRoot(LocalPlayer.Character)
            if not myRoot then
                warn("[!] No HumanoidRootPart found!")
                return
            end
            
            local originalPos = myRoot.CFrame
            local escapePos = Vector3.new(1112.26, 566.00, 56.86)
            
            -- Instant teleport to escape
            myRoot.CFrame = CFrame.new(escapePos)
            print("[+] Teleported to Escape!")
            
            task.wait(0.5)
            
            -- Instant teleport back
            if myRoot and myRoot.Parent then
                myRoot.Velocity = Vector3.new(0, 0, 0)
                myRoot.RotVelocity = Vector3.new(0, 0, 0)
                local humanoid = getHumanoid(LocalPlayer.Character)
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
                myRoot.CFrame = originalPos
                print("[+] Returned to original position")
            end
        end)
        if not success then
            warn("[!] Error using escape:", err)
        end
    end
})
UILib:CreateButton(PlayerPanel, {
    Text = "Refresh Items List",
    Callback = function()
        local success, err = pcall(function()
            local itemsFolder = Workspace:FindFirstChild("ItemSpawns")
            if not itemsFolder then
                warn("[!] ItemSpawns folder not found!")
                return
            end
            
            -- Same exclude list as getUniqueItems
            local excludeList = {
                "EZ1", "EZ2", "EZ3", "EZ4",
                "HCZ1", "HCZ2",
                "LCZ1", "LCZ2", "LCZ3", "LCZ4", "LCZ5", "LCZ6", "LCZ7", "LCZ8",
                "Part", "SU1"
            }
            
            local currentItems = {}
            local seen = {}
            for _, item in ipairs(itemsFolder:GetChildren()) do
                local itemName = item.Name
                -- Skip if in exclude list
                local shouldExclude = false
                for _, excluded in ipairs(excludeList) do
                    if itemName == excluded then
                        shouldExclude = true
                        break
                    end
                end
                
                if not shouldExclude and not seen[itemName] then
                    seen[itemName] = true
                    table.insert(currentItems, itemName)
                end
            end
            table.sort(currentItems)
            
            print("===================================")
            print("[+] CURRENT ITEMS ON MAP (" .. #currentItems .. " types):")
            print("===================================")
            for i, name in ipairs(currentItems) do
                print(string.format("%2d. %s", i, name))
            end
            print("===================================")
            print("[*] Select item from dropdown above")
        end)
        if not success then
            warn("[!] Error refreshing items:", err)
        end
    end
})
local MiscPanel = UILib:CreatePanel(Window, {
    Name = "Misc",
    DisplayName = "Misc"
})
UILib:CreateToggle(MiscPanel, {
    Label = "Full Bright",
    Default = false,
    Callback = function(value)
        Config.FullBright = value
        if value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end
    end
})
UILib:CreateButton(MiscPanel, {
    Text = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})
UILib:CreateButton(MiscPanel, {
    Text = "Close GUI",
    Callback = function()
        if Window.ScreenGui then
            Window.ScreenGui:Destroy()
        end
    end
})
print("[*] Setting up loops...")
local noclipKeyHeld = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.B then
        noclipKeyHeld = true
        if LocalPlayer.Character and not Config.NoClip then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and not originalCollisionStates[part] then
                    originalCollisionStates[part] = part.CanCollide
                end
            end
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.B then
        noclipKeyHeld = false
        if not Config.NoClip and LocalPlayer.Character then
            for part, originalState in pairs(originalCollisionStates) do
                if part and part.Parent then
                    part.CanCollide = originalState
                end
            end
            originalCollisionStates = {}
        end
    end
end)
local mainLoop = RunService.RenderStepped:Connect(function()
    updateAimbot()
    updatePlayerESP()
    updateItemESP()
end)
table.insert(_G.RetroBreach.Connections, mainLoop)
local playerLoop = RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local humanoid = getHumanoid(LocalPlayer.Character)
        if humanoid then
            if Config.WalkSpeed ~= 16 then
                humanoid.WalkSpeed = Config.WalkSpeed
            end
            if Config.JumpPower ~= 50 then
                humanoid.JumpPower = Config.JumpPower
            end
        end
        if Config.NoClip or noclipKeyHeld then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)
table.insert(_G.RetroBreach.Connections, playerLoop)
Players.PlayerAdded:Connect(function(player)
    if player.Character and Config.PlayerESP then
        player.Character:WaitForChild("HumanoidRootPart", 5)
        task.wait(0.2)
        createPlayerESP(player.Character)
    end
    player.CharacterAdded:Connect(function(character)
        if Config.PlayerESP then
            character:WaitForChild("HumanoidRootPart", 5)
            task.wait(0.2)
            createPlayerESP(character)
        end
    end)
end)
Players.PlayerRemoving:Connect(function(player)
    if player and player.Character and _G.RetroBreach.ESPHighlights[player.Character] then
        local esp = _G.RetroBreach.ESPHighlights[player.Character]
        if esp.highlight then pcall(function() esp.highlight:Destroy() end) end
        if esp.teamText then pcall(function() esp.teamText:Remove() end) end
        if esp.nameText then pcall(function() esp.nameText:Remove() end) end
        _G.RetroBreach.ESPHighlights[player.Character] = nil
    end
end)
for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function(character)
        if Config.PlayerESP then
            character:WaitForChild("HumanoidRootPart", 5)
            task.wait(0.2)
            createPlayerESP(character)
        end
    end)
end

if UILib.CreateNotification then
    UILib:CreateNotification({
        Text = "Retro Breach V2 Loaded!",
        Duration = 5,
        Color = UILib.Colors and UILib.Colors.SUCCESS or Color3.fromRGB(0, 255, 0)
    })
end
print("===================================")
print("[+] Retro Breach V2 - ENJOY MY GOATS!!!")
print("===================================")
task.spawn(function()
    task.wait(1) -- Wait for UI to fully load
    local itemsFolder = Workspace:FindFirstChild("ItemSpawns")
    if itemsFolder then
        local itemNames = {}
        for _, item in ipairs(itemsFolder:GetChildren()) do
            if not table.find(itemNames, item.Name) then
                table.insert(itemNames, item.Name)
            end
        end
        table.sort(itemNames)
        print("[+] Found", #itemNames, "unique items on the map!")
        print("[*] Use 'Select Item' dropdown to choose an item")
    else
        print("[!] ItemSpawns folder not found!")
    end
end)