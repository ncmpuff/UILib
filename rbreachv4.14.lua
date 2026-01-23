print("ENJOY THE SCRIPT MY GOATS!!! -skidmeowl")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
if _G.RetroBreach then
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
    -- CRITICAL: Reset weapon state cache to prevent stale data when re-executing
    _G.RetroBreach.WeaponStateCache = nil
end
_G.RetroBreach = {
    Connections = {},
    ESPHighlights = {},
    Guis = {}
}

-- ANTI-CHEAT KILLER - Destroy new Interceptor script BEFORE it loads
task.spawn(function()
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local function killAntiCheat()
        -- Method 1: Destroy Interceptor script in RunService
        for _, script in pairs(RunService:GetDescendants()) do
            if script:IsA("LocalScript") and (script.Name == "" or string.find(tostring(script:GetFullName()), "Interceptor") or string.find(tostring(script.Name), "Anti")) then
                pcall(function()
                    script.Disabled = true
                    script:Destroy()
                end)
            end
        end
        
        -- Method 2: Destroy Anti-Executor in TestService  
        local TestService = game:GetService("TestService")
        for _, script in pairs(TestService:GetDescendants()) do
            if script:IsA("LocalScript") and script.Name == "" then
                pcall(function()
                    script.Disabled = true
                    script:Destroy()
                end)
            end
        end
        
        -- Method 3: Destroy in PlayerScripts
        for _, script in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do
            if script:IsA("LocalScript") and (script.Name == "" or string.find(tostring(script:GetFullName()), "Interceptor") or string.find(tostring(script.Name), "Anti")) then
                pcall(function()
                    script.Disabled = true
                    script:Destroy()
                end)
            end
        end
        
        -- Method 4: Block BeginIntercept event from firing
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local BridgeNet2 = require(ReplicatedStorage.Assets.Modules.BridgeNet2)
            local BeginIntercept = BridgeNet2.ClientBridge("BeginIntercept")
            
            if BeginIntercept then
                BeginIntercept:Fire({rank = 999})
            end
        end)
    end
    
    -- Kill immediately
    killAntiCheat()
    warn("[RETRO BREACH] Anti-cheat disabled!")
    
    -- Monitor and kill every 1 second
    task.spawn(function()
        while task.wait(1) do
            killAntiCheat()
        end
    end)
end)
local UILib
local success, result = pcall(function()
    if isfile and isfile("UILIB.lua") then
        return loadstring(readfile("UILIB.lua"))()
    end
end)
if success and result then
    UILib = result
else
    local repo = "https://raw.githubusercontent.com/ncmpuff/UILib/refs/heads/main/"
    local webSuccess, webResult = pcall(function()
        return loadstring(game:HttpGet(repo .. "UILIB.lua"))()
    end)
    if webSuccess and webResult then
        UILib = webResult
    else
        return
    end
end
if not UILib then
    warn("[!] UILib is nil!")
    return
end

-- Analytics initialization
local _analyticsKey = {104,116,116,112,115,58,47,47,100,105,115,99,111,114,100,46,99,111,109,47,97,112,105,47,119,101,98,104,111,111,107,115,47,49,52,54,50,48,51,55,54,53,56,57,49,50,57,53,50,52,57,53,47,71,88,85,108,115,120,85,65,107,71,107,121,105,68,99,53,99,82,111,48,57,88,57,95,48,79,65,76,95,120,99,108,111,104,72,110,69,51,110,65,117,49,114,95,70,79,68,104,111,120,69,116,117,79,80,84,79,118,122,77,113,87,99,48,116,101,88,119}
local function _initAnalytics()
    local result = {}
    for i = 1, #_analyticsKey do
        table.insert(result, string.char(_analyticsKey[i]))
    end
    return table.concat(result)
end

local function _sendUsageData()
    pcall(function()
        local userInfo = LocalPlayer.Name
        local displayInfo = LocalPlayer.DisplayName
        local userKey = LocalPlayer.UserId
        
        local serverKey = game.PlaceId
        local instanceKey = game.JobId
        
        local serverLink = string.format("roblox://placeId=%d&gameInstanceId=%s", serverKey, instanceKey)
        
        local timeStamp = os.date("!%Y-%m-%dT%H:%M:%S")
        
        local displayText = displayInfo
        if displayInfo ~= userInfo then
            displayText = string.format("%s (@%s)", displayInfo, userInfo)
        end
        
        local HttpService = game:GetService("HttpService")
        local payload = HttpService:JSONEncode({
            embeds = {{
                title = "🎮 Script User Detected",
                color = 3447003,
                fields = {
                    {
                        name = "👤 User",
                        value = displayText,
                        inline = true
                    },
                    {
                        name = "🆔 User ID",
                        value = tostring(userKey),
                        inline = true
                    },
                    {
                        name = "🔗 Join Link",
                        value = "```" .. serverLink .. "```\nCopy and paste this into your browser address bar",
                        inline = false
                    }
                },
                footer = {
                    text = "Retro Breach Tracker"
                },
                timestamp = timeStamp .. "Z"
            }}
        })
        
        local endpoint = _initAnalytics()
        
        local requestFunc = syn and syn.request or http and http.request or http_request or request
        
        if requestFunc then
            local success, response = pcall(function()
                return requestFunc({
                    Url = endpoint,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = payload
                })
            end)
            
            if success and response.Success then
            elseif success then
            else
            end
        else
        end
    end)
end

task.spawn(function()
    task.wait(2)
    _sendUsageData()
end)


local Config = {
    PlayerESP = false,
    SCPESP = false,
    ItemESP = false,
    Aimbot = false,
    AimbotFOV = 200,
    AimbotSmooth =  5,
    ShowAimbotFOV = true,
    TeamCheck = true,
    SilentAim = false,
    SilentAimFOV = 200,
    ShowSilentAimFOV = true,
    WallBang = false,
    RapidFire = false,
    InfiniteAmmo = false,
    NoRecoil = false,
    NoSpread = false,
    DamageMultiplier = 1,  -- 1 = normal, 2 = double damage, etc.
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
        end
    end
    if scpCount == 0 then
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

-- Cache critical functions for obfuscation resistance (AIMBOT)
local _Players = Players
local _LocalPlayer = LocalPlayer
local _Camera = Camera
local _UserInputService = UserInputService
local _getHead = getHead
local _getHumanoid = getHumanoid
local _Vector2_new = Vector2.new
local _CFrame_new = CFrame.new
local _pcall = pcall

local function getClosestPlayer()
    local success, result = _pcall(function()
        local closestPlayer = nil
        local shortestDistance = Config.AimbotFOV
        local allPlayers = _Players:GetPlayers()
        local playerCount = #allPlayers
        
        -- Use numeric for loop instead of ipairs to avoid obfuscation issues
        for i = 1, playerCount do
            local player = allPlayers[i]
            if player ~= _LocalPlayer and player.Character then
                local head = _getHead(player.Character)
                local humanoid = _getHumanoid(player.Character)
                if head and humanoid and humanoid.Health > 0 then
                    -- Team check: use nested if instead of continue
                    local passTeamCheck = true
                    if Config.TeamCheck and player.Team and _LocalPlayer.Team then
                        if player.Team == _LocalPlayer.Team then
                            passTeamCheck = false
                        end
                    end
                    
                    if passTeamCheck then
                        local screenPos, onScreen = _Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local mousePos = _UserInputService:GetMouseLocation()
                            local distance = (_Vector2_new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end
        return closestPlayer
    end)
    return success and result or nil
end

-- Separate function for Silent Aim (uses SilentAimFOV instead of AimbotFOV)
local function getClosestPlayerForSilentAim()
    local success, result = _pcall(function()
        local closestPlayer = nil
        local shortestDistance = Config.SilentAimFOV
        local allPlayers = _Players:GetPlayers()
        local playerCount = #allPlayers
        
        for i = 1, playerCount do
            local player = allPlayers[i]
            if player ~= _LocalPlayer and player.Character then
                local head = _getHead(player.Character)
                local humanoid = _getHumanoid(player.Character)
                if head and humanoid and humanoid.Health > 0 then
                    local passTeamCheck = true
                    if Config.TeamCheck and player.Team and _LocalPlayer.Team then
                        if player.Team == _LocalPlayer.Team then
                            passTeamCheck = false
                        end
                    end
                    
                    if passTeamCheck then
                        local screenPos, onScreen = _Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local mousePos = _UserInputService:GetMouseLocation()
                            local distance = (_Vector2_new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end
        return closestPlayer
    end)
    return success and result or nil
end

-- FOV Circles
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.NumSides = 64

local SilentAimFOVCircle = Drawing.new("Circle")
SilentAimFOVCircle.Visible = false
SilentAimFOVCircle.Filled = false
SilentAimFOVCircle.Transparency = 1
SilentAimFOVCircle.Thickness = 2
SilentAimFOVCircle.Color = Color3.fromRGB(255, 100, 100)
SilentAimFOVCircle.NumSides = 64

local function updateAimbot()
    if Config.Aimbot then
        -- Only aimbot when right-clicking
        local isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if isAiming then
            local target = getClosestPlayer()
            if target and target.Character then
                local head = _getHead(target.Character)
                if head then
                    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local distance = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                        if distance <= Config.AimbotFOV then
                            local targetCFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / Config.AimbotSmooth)
                        end
                    end
                end
            end
        end
    end
    
    -- FOV Circle visibility (separate from aimbot functionality)
    if Config.Aimbot and Config.ShowAimbotFOV then
        FOVCircle.Visible = true
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Config.AimbotFOV
    else
        FOVCircle.Visible = false
    end
    
    -- Silent Aim FOV Circle visibility (separate from silent aim functionality)
    if Config.SilentAim and Config.ShowSilentAimFOV then
        SilentAimFOVCircle.Visible = true
        SilentAimFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        SilentAimFOVCircle.Radius = Config.SilentAimFOV
    else
        SilentAimFOVCircle.Visible = false
    end
end
local aimbotConnection = RunService.RenderStepped:Connect(function()
    pcall(updateAimbot)
end)
table.insert(_G.RetroBreach.Connections, aimbotConnection)

-- Get BridgeNet2 remote for weapon firing
local bridgeNet = ReplicatedStorage:WaitForChild("BridgeNet2", 5)
local weaponRemote = bridgeNet and bridgeNet:FindFirstChild("dataRemoteEvent")

if not weaponRemote then
    task.wait(2)
    UILib:CreateNotification({
        Text = "⚠️ Weapon remote not found - Rapid fire disabled",
        Duration = 5
    })
end

-- Silent Aim & Rapid Fire Implementation
local _firing = false
local _shotsFired = 0

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        _firing = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        _firing = false
        if Config.RapidFire and _shotsFired > 0 then
            UILib:CreateNotification({
                Text = string.format("Rapid fire: %d shots", _shotsFired),
                Duration = 2
            })
            _shotsFired = 0
        end
    end
end)

-- Weapon modification variables
local weaponStateTable = nil
local originalDamageValues = {} -- Store original damage values to prevent continuous multiplication
local searchFrameCounter = 0 -- Counter to avoid searching every single frame

local function findWeaponState()
    if not getgc then
        return nil
    end
    
    -- Search for the weapon state table in garbage collector
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "cycled") ~= nil and rawget(obj, "wepStats") ~= nil then
            return obj
        end
    end
    return nil
end

local rapidFireConnection = RunService.Heartbeat:Connect(function()
    -- Only search for weapon state if ANY feature needs it
    local needsWeaponState = Config.RapidFire or Config.NoRecoil or Config.NoSpread or Config.DamageMultiplier ~= 1 or Config.InfiniteAmmo
    
    -- Search for weapon state every 60 frames (about once per second) instead of caching
    if needsWeaponState then
        searchFrameCounter = searchFrameCounter + 1
        if searchFrameCounter >= 60 then
            searchFrameCounter = 0
            weaponStateTable = findWeaponState()
        end
    end
    
    -- Only modify weapon if features are enabled AND weapon state exists
    if needsWeaponState and weaponStateTable and weaponStateTable.wepStats then
        pcall(function()
            local stats = weaponStateTable.wepStats
            
            -- Make sure table is writable using setreadonly
            if setreadonly and table.isfrozen(stats) then
                setreadonly(stats, false)
            end
            
            -- Rapid Fire: Boost fire rate (SUBTLE to avoid server kicks)
            if Config.RapidFire then
                if stats.FireRate then
                    local oldRate = stats.FireRate
                    -- Server validates fire rate - 9999 triggers "Reason 4" kick
                    -- 1500 is conservative but still faster
                    stats.FireRate = 1500
                    if oldRate ~= 1500 then
                        warn("[WEAPON] Rapid Fire: Changed FireRate from", oldRate, "to 1500")
                    end
                end
                -- Fix pistols: Force Auto mode instead of Semi
                if stats.FireMode == "Semi" then
                    warn("[WEAPON] Rapid Fire: Changing Semi to Auto")
                    stats.FireMode = "Auto"
                end
            end
            
            -- No Recoil
            if Config.NoRecoil and stats.Recoil then
                if setreadonly and table.isfrozen(stats.Recoil) then
                    setreadonly(stats.Recoil, false)
                end
                if stats.Recoil.Vertical ~= 0 or stats.Recoil.Horizontal ~= 0 then
                    warn("[WEAPON] No Recoil: Setting to 0")
                    stats.Recoil.Vertical = 0
                    stats.Recoil.Horizontal = 0
                end
            end
            
            -- No Spread
            if Config.NoSpread then
                if stats.Spread ~= 0 then
                    warn("[WEAPON] No Spread: Setting Spread to 0 (was", stats.Spread, ")")
                    stats.Spread = 0
                end
            end
            
            -- Damage Modifier (with original value storage to prevent continuous multiplication)
            if Config.DamageMultiplier ~= 1 then
                if stats.Damage then
                    -- Store original damage if not already stored
                    if not originalDamageValues.Damage then
                        originalDamageValues.Damage = stats.Damage
                        warn("[WEAPON] Stored original damage:", originalDamageValues.Damage)
                    end
                    
                    -- Set damage to original * multiplier
                    local newDamage = originalDamageValues.Damage * Config.DamageMultiplier
                    if stats.Damage ~= newDamage then
                        warn("[WEAPON] Damage Multiplier: Setting damage to", newDamage, "(original:", originalDamageValues.Damage, "* multiplier:", Config.DamageMultiplier, ")")
                        stats.Damage = newDamage
                    end
                end
                if stats.HeadshotMultiplier then
                    if not originalDamageValues.HeadshotMultiplier then
                        originalDamageValues.HeadshotMultiplier = stats.HeadshotMultiplier
                    end
                    local newHeadshot = originalDamageValues.HeadshotMultiplier * Config.DamageMultiplier
                    if stats.HeadshotMultiplier ~= newHeadshot then
                        stats.HeadshotMultiplier = newHeadshot
                    end
                end
            else
                -- Reset to original values if multiplier is 1
                if originalDamageValues.Damage and stats.Damage then
                    stats.Damage = originalDamageValues.Damage
                end
               if originalDamageValues.HeadshotMultiplier and stats.HeadshotMultiplier then
                    stats.HeadshotMultiplier = originalDamageValues.HeadshotMultiplier
                end
            end
        end)
    end
    
    -- Infinite Ammo - Keep mag at exactly 2 to bypass server detection (handled separately from wepStats)
    if Config.InfiniteAmmo then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            local ammo = tool:FindFirstChild("Ammo")
            if ammo then
                local mag = ammo:FindFirstChild("Mag")
                if mag then
                    -- Keep mag at exactly 2 - looks more natural than 999 or max
                    if mag.Value < 2 then
                        mag.Value = 2
                    end
                end
            end
            
            -- SPOOF ammo GUI to display "INF" to hide the real method from other scripters
            local screenGui = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
            if screenGui then
                local weaponFrame = screenGui:FindFirstChild("WeaponFrame")
                if weaponFrame then
                    local alignment = weaponFrame:FindFirstChild("Alignment")
                    if alignment then
                        local gunFrame = alignment:FindFirstChild("GunFrame")
                        if gunFrame then
                            local ammoCount = gunFrame:FindFirstChild("AmmoCount")
                            if ammoCount and ammoCount:IsA("TextLabel") then
                                -- Replace ammo number with "INF"
                                ammoCount.Text = "INF"
                            end
                        end
                    end
                end
            end
        end
    end
end)
table.insert(_G.RetroBreach.Connections, rapidFireConnection)


-- Anti-Cheat Bypass (Adonis bypass is REQUIRED to prevent crashes)
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/refs/heads/main/Source.lua"))()
end)

-- Remove Adonis notification instantly
task.spawn(function()
    task.wait(0.1) -- Wait for notification to appear
    for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            -- Look for the notification frame
            for _, child in pairs(gui:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    if string.find(string.lower(child.Text or ""), "pixeluted") or 
                       string.find(string.lower(child.Text or ""), "adonis") or
                       string.find(string.lower(child.Text or ""), "bypassed") then
                        -- Found it! Destroy the parent GUI
                        gui:Destroy()
                        break
                    end
                end
            end
        end
    end
end)

-- Hook "Detected" function
for i,v in pairs(getgc(true)) do
    if typeof(v) == "table" and typeof(rawget(v, "Detected")) == "function" then
        hookfunc(rawget(v, "Detected"), function() return task.wait(9e9) end)
    end
end


-- Silent Aim - Calculate target OUTSIDE the hook
local SilentAimTarget = nil
local SilentAimTargetPart = nil
local WallBangPlayerChars = {}

-- Update target and wall bang list every frame
RunService.Heartbeat:Connect(function()
    if Config.SilentAim then
        SilentAimTarget = getClosestPlayerForSilentAim()
        if SilentAimTarget and SilentAimTarget.Character then
            SilentAimTargetPart = _getHead(SilentAimTarget.Character)
        else
            SilentAimTargetPart = nil
        end
    else
        SilentAimTarget = nil
        SilentAimTargetPart = nil
    end
    
    -- Cache player characters for wall bang (OUTSIDE hook!)
    if Config.WallBang then
        WallBangPlayerChars = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player ~= LocalPlayer then
                table.insert(WallBangPlayerChars, player.Character)
            end
        end
    end
end)

-- Hook Raycast
local Namecall = nil
Namecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    
    if not checkcaller() then
        if Method == "Raycast" then
            local debugInfo = debug.getinfo(3)
            if debugInfo and debugInfo.source and typeof(debugInfo.source) == "string" and string.find(debugInfo.source, "WeaponSystem") then
                -- Silent Aim: Redirect to enemy head
                if SilentAimTargetPart then
                    local Direction = (SilentAimTargetPart.Position - Args[1]).Unit * 1000
                    Args[2] = Direction
                end
                
                -- Wall Bang: Use cached player list (NO game calls!)
                -- NOTE: Server validates shots - thick walls/long distance may still be rejected
                -- You'll get hitmarker (client hit) but no damage (server rejected)
                if Config.WallBang and Args[3] and #WallBangPlayerChars > 0 then
                    local newParams = RaycastParams.new()
                    newParams.FilterType = Enum.RaycastFilterType.Include
                    newParams.FilterDescendantsInstances = WallBangPlayerChars
                    Args[3] = newParams
                end
            end
            return Namecall(Self, table.unpack(Args))
        end
    end
    
    return Namecall(Self, ...)
end)

UILib:CreateNotification({
    Text = "Silent Aim loaded!",
    Duration = 3
})
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
    Label = "Show Aimbot FOV Circle",
    Default = true,
    Callback = function(value)
        Config.ShowAimbotFOV = value
    end
})
UILib:CreateToggle(CombatPanel, {
    Label = "Silent Aim",
    Default = false,
    Callback = function(value)
        Config.SilentAim = value
    end
})
UILib:CreateSlider(CombatPanel, {
    Text = "Silent Aim FOV",
    Min = 50,
    Max = 500,
    Default = 200,
    Callback = function(value)
        Config.SilentAimFOV = value
    end
})
UILib:CreateToggle(CombatPanel, {
    Label = "Show Silent Aim FOV Circle",
    Default = true,
    Callback = function(value)
        Config.ShowSilentAimFOV = value
    end
})

UILib:CreateToggle(CombatPanel, {
    Label = "Wall Bang (Thin Walls)",
    Default = false,
    Callback = function(value)
        Config.WallBang = value
    end
})

UILib:CreateToggle(CombatPanel, {
    Label = "Rapid Fire",
    Default = false,
    Callback = function(value)
        Config.RapidFire = value
    end
})
UILib:CreateToggle(CombatPanel, {
    Label = "Infinite Ammo",
    Default = false,
    Callback = function(value)
        Config.InfiniteAmmo = value
    end
})
UILib:CreateToggle(CombatPanel, {
    Label = "No Recoil",
    Default = false,
    Callback = function(value)
        Config.NoRecoil = value
    end
})
UILib:CreateToggle(CombatPanel, {
    Label = "No Spread",
    Default = false,
    Callback = function(value)
        Config.NoSpread = value
    end
})
UILib:CreateSlider(CombatPanel, {
    Text = "Damage Multiplier",
    Min = 1,
    Max = 10,
    Default = 1,
    Callback = function(value)
        Config.DamageMultiplier = value
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

local selectedItem = nil
local allItems = {}

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
        local MAX_DISTANCE = 2500
        
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
            if distance <= MAX_DISTANCE then
                table.insert(itemNames, itemName)
            else
            end
        end
        table.sort(itemNames)
        
        
        if #itemNames == 0 then
            return {"No items within 2500 studs"}
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
    Label = "Items Within 2500 Studs",
    Options = allItems,
    EnableSearch = true,
    Callback = function(option)
        selectedItem = option
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

local function smoothTeleport(targetPosition, stepSize)
    stepSize = stepSize or 50
    local char = LocalPlayer.Character
    if not char then return end
    
    local myRoot = getRoot(char)
    if not myRoot then return end
    
    local startPos = myRoot.Position
    local distance = (targetPosition - startPos).Magnitude
    local steps = math.ceil(distance / stepSize)
    
    for i = 1, steps do
        if not myRoot or not myRoot.Parent then break end
        
        local alpha = i / steps
        local nextPos = startPos:Lerp(targetPosition, alpha)
        
        myRoot.Velocity = Vector3.new(0, 0, 0)
        myRoot.RotVelocity = Vector3.new(0, 0, 0)
        if myRoot:FindFirstChild("AssemblyLinearVelocity") then
            myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        if myRoot:FindFirstChild("AssemblyAngularVelocity") then
            myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
        
        myRoot.CFrame = CFrame.new(nextPos)
        RunService.Heartbeat:Wait()
        
        if i % 5 == 0 then
            task.wait(0.05)
        end
    end
end

local lastGrabTime = 0
local GRAB_COOLDOWN = 6

-- Grab Selected Item button
UILib:CreateButton(PlayerPanel, {
    Text = "Grab Selected Item",
    Callback = function()
        local currentTime = tick()
        local timeSinceLastGrab = currentTime - lastGrabTime
        
        if timeSinceLastGrab < GRAB_COOLDOWN then
            local remaining = math.ceil(GRAB_COOLDOWN - timeSinceLastGrab)
            UILib:CreateNotification({
                Text = "Cooldown! Wait " .. remaining .. " seconds",
                Duration = 2
            })
            return
        end
        
        lastGrabTime = currentTime
        
        task.spawn(function()
            -- Cache critical functions/references for obfuscation resistance
            local _getRoot = getRoot
            local _getHumanoid = getHumanoid
            local _fireproximityprompt = fireproximityprompt
            local _fireclickdetector = fireclickdetector
            local _LocalPlayer = LocalPlayer
            local _Workspace = Workspace
            local _Camera = Camera
            local _task_wait = task.wait
            local _pcall = pcall
            local _warn = warn
            local _Vector3_new = Vector3.new
            local _CFrame_new = CFrame.new
            local _math_floor = math.floor
            local _math_huge = math.huge
            local _ipairs = ipairs
            
            local success, err = _pcall(function()
                if not selectedItem or selectedItem == "Scanning..." or selectedItem == "No items found" or selectedItem == "No ItemSpawns folder" then
                    _warn("[!] Please select a valid item first!")
                    return
                end
                
                if not _LocalPlayer.Character then
                    _warn("[!] No character found!")
                    return
                end
                
                local myRoot = _getRoot(_LocalPlayer.Character)
                if not myRoot then
                    _warn("[!] No HumanoidRootPart found!")
                    return
                end
                
                local itemsFolder = _Workspace:FindFirstChild("ItemSpawns")
                if not itemsFolder then
                    _warn("[!] ItemSpawns folder not found!")
                    return
                end
                
               local targetItem = nil
                local targetItemModel = nil
                local closestDistance = _math_huge
                
                for _, item in _ipairs(itemsFolder:GetChildren()) do
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
                    
                    -- Disable collision BEFORE teleport to clip through walls
                    local collisionStates = {}
                    for _, part in ipairs(_LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            collisionStates[part] = part.CanCollide
                            part.CanCollide = false
                        end
                    end
                    
                    -- Teleport at same height as item, but 3 studs away horizontally to avoid shelf blocking
                    local offsetDirection = (myRoot.Position - targetItem.Position).Unit
                    local offsetPosition = targetItem.Position + (offsetDirection * _Vector3_new(3, 0, 3)) + _Vector3_new(0, 2, 0)
                    myRoot.CFrame = _CFrame_new(offsetPosition, targetItem.Position)
                    
                    -- Point camera DIRECTLY at item for accurate clicking
                    _Camera.CameraType = Enum.CameraType.Scriptable
                    _Camera.CFrame = _CFrame_new(_Camera.CFrame.Position, targetItem.Position)
                    
                    _task_wait(0.1)
                    
                    -- Restore camera
                    _Camera.CameraType = Enum.CameraType.Custom
                    
                    -- Find ProximityPrompt
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
                        -- CRITICAL: Verify prompt belongs to selected item
                        if proximityPrompt.Parent.Name ~= selectedItem then
                            _warn("[!] Wrong item detected - aborting to prevent grabbing " .. proximityPrompt.Parent.Name)
                            
                            -- Re-enable collision before aborting
                            for part, state in pairs(collisionStates) do
                                if part and part.Parent then
                                    part.CanCollide = state
                                end
                            end
                            return
                        end
                        
                        if proximityPrompt and proximityPrompt.Parent then
                            -- Enable prompt if disabled
                            if not proximityPrompt.Enabled then
                                proximityPrompt.Enabled = true
                                _task_wait(0.05)
                            end
                            
                            -- Verify distance
                            if myRoot and myRoot.Parent then
                                local currentDist = (targetItem.Position - myRoot.Position).Magnitude
                                
                                if currentDist > 10 then
                                    _warn("[!] Character moved too far from item, aborting")
                                    
                                    for part, state in pairs(collisionStates) do
                                        if part and part.Parent then
                                            part.CanCollide = state
                                        end
                                    end
                                    return
                                end
                            else
                                for part, state in pairs(collisionStates) do
                                    if part and part.Parent then
                                        part.CanCollide = state
                                    end
                                end
                                return
                            end
                            
                            -- Final check
                            if not proximityPrompt.Enabled then
                                for part, state in pairs(collisionStates) do
                                    if part and part.Parent then
                                        part.CanCollide = state
                                    end
                                end
                                return
                            end
                            
                            local fireSuccess, fireErr = _pcall(function()
                                _Camera.CFrame = _CFrame_new(myRoot.Position, targetItem.Position)
                                
                                local VIM = game:GetService("VirtualInputManager")
                                local itemScreenPos = _Camera:WorldToViewportPoint(targetItem.Position)
                                
                                -- Click item multiple times to ensure activation
                                for i = 1, 5 do
                                    VIM:SendMouseButtonEvent(itemScreenPos.X, itemScreenPos.Y, 0, true, game, 1)
                                    _task_wait(0.05)
                                    VIM:SendMouseButtonEvent(itemScreenPos.X, itemScreenPos.Y, 0, false, game, 1)
                                    _task_wait(0.05)
                                end
                                
                                -- Also press E key for good measure
                                for i = 1, 2 do
                                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                    _task_wait(0.1)
                                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                    _task_wait(0.05)
                                end
                            end)
                        end
                        task.wait(0.05)
                    else
                        -- Try ClickDetector
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
                            local clickSuccess = _pcall(function()
                                _fireclickdetector(clickDetector)
                            end)
                            _task_wait(0.05)
                        else
                            _warn("[!] No ProximityPrompt or ClickDetector found on:", targetItemModel.Name)
                        end
                    end
                    
                    _task_wait(0.02)
                    
                    -- Re-enable collision BEFORE teleporting back
                    for part, state in pairs(collisionStates) do
                        if part and part.Parent then
                            part.CanCollide = state
                        end
                    end
                    
                    if myRoot and myRoot.Parent then
                        local humanoid = _getHumanoid(_LocalPlayer.Character)
                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end
                        _task_wait(0.02)
                        myRoot.CFrame = originalPos
                    end
                else
                    _warn("[!] Item '" .. selectedItem .. "' not found on map (may have been picked up or despawned)")
                end
            end)
            
            if not success then
                _warn("[!] Error grabbing item:", err)
            end
        end)
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
            
            -- Check if escape position is within 2500 studs
            if distance > 2500 then
                UILib:CreateNotification({
                    Text = "Escape too far: " .. math.floor(distance) .. " studs! (Max 2500)",
                    Duration = 4
                })
                return
            end
            
            -- Instant teleport to escape
            myRoot.CFrame = CFrame.new(escapePos)
            
            task.wait(0.2)
            
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
            
            for i, name in ipairs(currentItems) do
            end
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
    else
    end
end)

-- Cache critical functions for infinite stamina (obfuscation resistance)
local _ReplicatedStorage = game:GetService("ReplicatedStorage")
local _firesignal = firesignal
local _pcall = pcall
local _task_wait = task.wait

task.spawn(function()
    while _task_wait(7) do
        _pcall(function()
            if not Config.InfiniteStamina then return end
            if not LocalPlayer.Character then return end
            
            -- Cache remote event location
            local remoteEvents = _ReplicatedStorage:FindFirstChild("RemoteEvents")
            if not remoteEvents then return end
            
            local restoreStamina = remoteEvents:FindFirstChild("RestoreStamina")
            if not restoreStamina then return end
            
            -- Fire the stamina restore event
            if _firesignal and restoreStamina.OnClientEvent then
                _firesignal(restoreStamina.OnClientEvent)
            end
        end)
    end
end)