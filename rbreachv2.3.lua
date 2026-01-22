print("===================================")
print("[*] Retro Breach V1 - Starting...")
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
    
    for _, accessory in ipairs(character:GetDescendants()) do
        if accessory:IsA("Accessory") or accessory:IsA("Hat") then
            local name = accessory.Name
            if name:find("HappyMask") or name:find("Ghostface") then
                return "The Mask"
            end
        end
    end
    
    local shirt = character:FindFirstChildOfClass("Shirt")
    if shirt and shirt.ShirtTemplate:find("11499060129") then
        return "Plague Doctor"
    end
    
    if shirt and shirt.ShirtTemplate:find("2938677333") then
        return "Zombie"
    end
    
    if shirt and shirt.ShirtTemplate:find("16099679561") then
        return "Cain"
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart and rootPart:FindFirstChild("Flame") then
        return "Burning Man"
    end
    
    if shirt and shirt.ShirtTemplate:find("11514423812") then
        return "The Old Man"
    end
    
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
                    esp.highlight.Enabled = false
                    if esp.teamText then esp.teamText.Visible = false end
                    esp.nameText.Visible = false
                end
            else
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
local function updateAimbot()
    local canAim = Config.Aimbot and Camera and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if canAim then
        local closestPlayer = nil
        local shortestDistance = Config.AimbotFOV
        for _, player in ipairs(Players:GetPlayers()) do
            local validTarget = player ~= LocalPlayer and player.Character
            if validTarget then
                local head = getHead(player.Character)
                local humanoid = getHumanoid(player.Character)
                local hasValidParts = head and humanoid and humanoid.Health > 0
                if hasValidParts then
                    local skipTeammate = Config.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team
                    if not skipTeammate then
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
        end
        if closestPlayer and closestPlayer.Character then
            local head = getHead(closestPlayer.Character)
            if head then
                local targetPos = head.Position
                local cameraPos = Camera.CFrame.Position
                local direction = (targetPos - cameraPos).Unit
                local currentLook = Camera.CFrame.LookVector
                local smoothing = Config.AimbotSmooth
                if smoothing <= 0 then smoothing = 1 end
                local smoothed = currentLook:Lerp(direction, 1 / smoothing)
                Camera.CFrame = CFrame.new(cameraPos, cameraPos + smoothed)
            end
        end
    end
end
local aimbotConnection = RunService.RenderStepped:Connect(updateAimbot)
table.insert(_G.RetroBreach.Connections, aimbotConnection)
print("[*] Creating UI...")
local Window = UILib:CreateWindow({
    Title = "Retro Breach V1",
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

-- Auto-refresh ESP every 20 seconds to catch ALL players
task.spawn(function()
    while true do
        task.wait(20)
        if Config.PlayerESP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if _G.RetroBreach.ESPHighlights[player.Character] then
                        local esp = _G.RetroBreach.ESPHighlights[player.Character]
                        if esp.highlight then pcall(function() esp.highlight:Destroy() end) end
                        if esp.teamText then pcall(function() esp.teamText:Remove() end) end
                        if esp.nameText then pcall(function() esp.nameText:Remove() end) end
                        _G.RetroBreach.ESPHighlights[player.Character] = nil
                    end
                    createPlayerESP(player.Character)
                end
            end
            print("[*] ESP refreshed - tracking all players!")
        end
    end
end)
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

UILib:CreateToggle(PlayerPanel, {
    Label = "Infinite Stamina",
    Default = false,
    Callback = function(value)
        Config.InfiniteStamina = value
    end
})

-- Infinite Stamina Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.InfiniteStamina then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").RemoteEvents.RestoreStamina
                firesignal(Event.OnClientEvent)
            end)
        end
    end
end)

-- Item selection with dropdown
local selectedItem = nil
local allItems = {}

-- Function to scan and get unique items
local function getUniqueItems()
    local success, result = pcall(function()
        local itemsFolder = Workspace:FindFirstChild("ItemSpawns")
        if not itemsFolder then
            return {"No ItemSpawns folder"}
        end
        
        local excludeList = {
            "EZ1", "EZ2", "EZ3", "EZ4",
            "HCZ1", "HCZ2",
            "LCZ1", "LCZ2", "LCZ3", "LCZ4", "LCZ5", "LCZ6", "LCZ7", "LCZ8",
            "Part", "SU1"
        }
        
        local itemNames = {}
        local seen = {}
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local itemName = item.Name
            local shouldExclude = false
            for _, excluded in ipairs(excludeList) do
                if itemName == excluded then
                    shouldExclude = true
                    break
                end
            end
            
            if not shouldExclude and not seen[itemName] then
                seen[itemName] = true
                table.insert(itemNames, itemName)
            end
        end
        table.sort(itemNames)
        
        if #itemNames == 0 then
            return {"No items found"}
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

-- Auto-refresh items every 10 seconds
task.spawn(function()
    while true do
        task.wait(10)
        local newItems = getUniqueItems()
        if #newItems ~= #allItems then
            allItems = newItems
            print("[*] Item list auto-updated - Found", #allItems, "items")
        end
    end
end)


UILib:CreateDropdown(PlayerPanel, {
    Label = "Select Item (only items within 500 studs)",
    Options = allItems,
    EnableSearch = true,
    Callback = function(option)
        selectedItem = option
        print("[*] Selected:", option)
    end
})

UILib:CreateButton(PlayerPanel, {
    Text = "Get Item",
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
            
            local itemsFolder = Workspace:FindFirstChild("ItemSpawns")
            if not itemsFolder then
                warn("[!] ItemSpawns folder not found!")
                return
            end
            
            local targetItem = nil
            local targetItemModel = nil
            for _, item in ipairs(itemsFolder:GetChildren()) do
                if item.Name == selectedItem then
                    local handle = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
                    if handle then
                        targetItem = handle
                        targetItemModel = item
                        break
                    end
                end
            end
            
            if targetItem and targetItemModel then
                local originalPos = myRoot.CFrame
                local distance = (targetItem.Position - myRoot.Position).Magnitude
                
                if distance > 500 then
                    UILib:CreateNotification({Text = "Item too far: " .. math.floor(distance) .. " studs!", Duration = 3})
                    return
                end
                
                print("[*] Item is", math.floor(distance), "studs away - proceeding...")
                
                myRoot.CFrame = targetItem.CFrame * CFrame.new(0, 2, 0)
                task.wait(0.2)
                
                local proximityPrompt = targetItemModel:FindFirstChildOfClass("ProximityPrompt", true)
                if not proximityPrompt then
                    for _, descendant in ipairs(targetItemModel:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            proximityPrompt = descendant
                            break
                        end
                    end
                end
                
                if proximityPrompt then
                    print("[+] Found ProximityPrompt on:", targetItemModel.Name)
                    fireproximityprompt(proximityPrompt)
                    task.wait(0.2)
                    fireproximityprompt(proximityPrompt)
                    task.wait(0.2)
                    fireproximityprompt(proximityPrompt)
                    task.wait(0.3)
                    print("[+] Grabbed item (ProximityPrompt):", targetItemModel.Name, "- Distance:", math.floor(distance), "studs")
                else
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
                        fireclickdetector(clickDetector)
                        task.wait(0.2)
                        fireclickdetector(clickDetector)
                        task.wait(0.2)
                        fireclickdetector(clickDetector)
                        task.wait(0.3)
                        print("[+] Grabbed item (ClickDetector):", targetItemModel.Name, "- Distance:", math.floor(distance), "studs")
                    else
                        warn("[!] No ProximityPrompt or ClickDetector found on:", targetItemModel.Name)
                    end
                end
                
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
            local distance = (escapePos - myRoot.Position).Magnitude
            
            if distance > 5000 then
                warn("[!] REJECTED: Escape is", math.floor(distance), "studs away!")
                warn("[!] Only teleport within 500 studs to prevent getting kicked")
                return
            end
            
            myRoot.CFrame = CFrame.new(escapePos)
            print("[+] Teleported to Escape! Distance:", math.floor(distance), "studs")
            
            task.wait(0.5)
            
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
        Text = "Retro Breach V1 Loaded!",
        Duration = 5,
        Color = UILib.Colors and UILib.Colors.SUCCESS or Color3.fromRGB(0, 255, 0)
    })
end
print("===================================")
print("[+] Retro Breach V1 - Ready!")
print("===================================")
print("Features:")
print("  - Player ESP (Highlight + Drawing)")
print("  - SCP ESP")
print("  - Item ESP")
print("  - Aimbot (Hold Right Click)")
print("  - Speed Hacks")
print("  - NoClip")
print("  - Full Bright")

print("===================================")
print("[*] Scanning for items on map...")
task.spawn(function()
    task.wait(1)
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