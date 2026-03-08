-- =====================================================
-- JPUFF UI LIBRARY V1.0.2 (CLEANED)
-- A comprehensive UI library for creating beautiful GUIs
-- Extracted from JPUFF GUI V26
-- =====================================================

local UILib = {}

-- Shared state for auto-closing collapsible toggles
UILib.OpenCollapsibles = {}

-- Global animation lock to prevent simultaneous arrow clicks
UILib.CollapsibleAnimating = false

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Wait for player to load
local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() and Players.LocalPlayer
repeat task.wait() until player
local gui = player:WaitForChild("PlayerGui")

-- =====================================================
-- METHODS FOR WINDOW (Defined early)
-- =====================================================
function UILib:AddMethods(window)
    -- Window Navigation
    window.ShowPanel = function(self, panelName)
        UILib:ShowPanel(self, panelName)
    end
    
    window.HidePanel = function(self, panelName)
        UILib:HidePanel(self, panelName)
    end

    window.CreatePanel = function(self, config)
        return UILib:CreatePanel(self, config)
    end
    
    window.AddToggleKey = function(self, keyCode)
        UILib:AddToggleKey(self, keyCode)
    end

    -- Global Helpers accessible via Window
    window.Notify = function(self, config)
        return UILib:CreateNotification(config)
    end
    
    window.Confirm = function(self, config)
        return UILib:CreateConfirmation(config)
    end

    window.Destroy = function(self)
        if self.DragConnection then
            self.DragConnection:Disconnect()
            self.DragConnection = nil
        end
        if self.ScreenGui then
            self.ScreenGui:Destroy()
        end
    end
end


-- =====================================================
-- COLOR PALETTE
-- =====================================================
UILib.Colors = {
    JPUFF_PINK = Color3.fromRGB(255, 182, 193),
    JPUFF_HOT_PINK = Color3.fromRGB(255, 105, 180),
    JPUFF_DARK_PINK = Color3.fromRGB(255, 140, 170),
    BG_DARK = Color3.fromRGB(25, 25, 35),
    BG_CARD = Color3.fromRGB(35, 35, 45),
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
    TEXT_SECONDARY = Color3.fromRGB(200, 200, 210),
    TOGGLE_OFF = Color3.fromRGB(60, 60, 70),
    SUCCESS = Color3.fromRGB(80, 200, 120),
        ING = Color3.fromRGB(255, 215, 0),
    ERROR = Color3.fromRGB(220, 80, 100),
}

-- =====================================================
-- MOBILE DETECTION
-- =====================================================
UILib.IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- Mobile-specific sizing (increased for better visibility)
UILib.MobileSizes = {
    -- Window/Selector
    SelectorWidth = 160,
    SelectorHeight = 300,
    SelectorPosition = UDim2.fromOffset(10, 10),
    
    -- Panel
    PanelWidth = 260,
    PanelHeight = 300,  -- Match selector height
    PanelOffsetX = 175,
    
    -- Text sizes
    HeaderTextSize = 14,
    PanelHeaderTextSize = 18,
    LabelTextSize = 14,
    ButtonTextSize = 14,
    
    -- Element sizes
    ToggleTrackWidth = 70,
    ToggleTrackHeight = 35,
    ToggleBallSize = 30,
    SliderWidth = 160,
    
    -- Spacing
    ButtonPadding = 8,
    ContentPadding = 15,
}

-- Desktop sizing (defaults)
UILib.DesktopSizes = {
    SelectorWidth = 220,
    SelectorHeight = 375,
    SelectorPosition = UDim2.fromOffset(50, 50),
    
    PanelWidth = 340,
    PanelHeight = 530,
    PanelOffsetX = 290,
    
    HeaderTextSize = 18,
    PanelHeaderTextSize = 22,
    LabelTextSize = 16,
    ButtonTextSize = 16,
    
    ToggleTrackWidth = 90,
    ToggleTrackHeight = 40,
    ToggleBallSize = 34,
    SliderWidth = 200,
    
    ButtonPadding = 10,
    ContentPadding = 20,
}

-- Helper to get current platform sizes
function UILib:GetSizes()
    return self.IsMobile and self.MobileSizes or self.DesktopSizes
end


-- =====================================================
-- KEYBINDING SYSTEM
-- =====================================================
UILib.Keybinds = {} -- Storage for all keybinds: {ActionName = {Key = Enum.KeyCode, Callback = function}}
UILib.KeybindListener = nil -- Global listener connection
UILib.ListeningForKeybind = false -- Flag to prevent triggering during rebind
UILib.KeybindStorageFile = "UILib_Keybinds.json" -- File to save keybinds

-- Helper: Convert KeyCode to readable name
function UILib:GetKeyName(keyCode)
    if not keyCode then return "None" end
    local name = tostring(keyCode):gsub("Enum.KeyCode.", "")
    return name
end

-- Helper: Save keybinds to file
function UILib:SaveKeybinds()
    if not writefile then return end -- Executor doesn't support file writing
    
    local saveData = {}
    for actionName, keybind in pairs(self.Keybinds) do
        if keybind.Key then
            saveData[actionName] = tostring(keybind.Key)
        end
    end
    
    local success, err = pcall(function()
        writefile(self.KeybindStorageFile, game:GetService("HttpService"):JSONEncode(saveData))
    end)
    
    if not success then
    end
end

-- Helper: Load keybinds from file
function UILib:LoadKeybinds()
    if not readfile or not isfile then return {} end
    
    if not isfile(self.KeybindStorageFile) then return {} end
    
    local success, result = pcall(function()
        local data = readfile(self.KeybindStorageFile)
        return game:GetService("HttpService"):JSONDecode(data)
    end)
    
    if success and type(result) == "table" then
        return result
    else
        return {}
    end
end

-- Helper: Start global keybind listener
function UILib:StartKeybindListener()
    if self.KeybindListener then return end -- Already running
    
    self.KeybindListener = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end -- Ignore if typing in textbox
        if self.ListeningForKeybind then return end -- Ignore if changing a keybind
        
        for actionName, keybind in pairs(self.Keybinds) do
            if keybind.Key and input.KeyCode == keybind.Key then
                if keybind.Callback then
                    keybind.Callback()
                end
            end
        end
    end)
end


-- =====================================================
-- LOADING SCREEN
-- =====================================================
function UILib:CreateLoadingScreen(config)
    config = config or {}
    local title = config.Title or "Loading"
    local accentColor = config.AccentColor or self.Colors.JPUFF_HOT_PINK
    local duration = config.Duration or 2.5
    local onComplete = config.OnComplete or function() end

    -- Safety watchdog
    task.spawn(function()
        task.wait(duration + 5)
        local stuckBlur = Lighting:FindFirstChild("UILibLoadBlur")
        if stuckBlur then stuckBlur:Destroy() end
        local stuckLoading = gui:FindFirstChild("UILibLoadingScreen")
        if stuckLoading then stuckLoading:Destroy() end
    end)

    -- Create loading screen GUI
    local loadingGui = Instance.new("ScreenGui", gui)
    loadingGui.Name = "UILibLoadingScreen"
    loadingGui.ResetOnSpawn = false
    loadingGui.IgnoreGuiInset = true
    loadingGui.DisplayOrder = 999

    -- Blur effect
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Name = "UILibLoadBlur"
    blur.Size = 0

    -- Full screen background
    local loadingBg = Instance.new("Frame", loadingGui)
    loadingBg.Size = UDim2.fromScale(1, 1)
    loadingBg.Position = UDim2.fromScale(0, 0)
    loadingBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    loadingBg.BackgroundTransparency = 0.3
    loadingBg.BorderSizePixel = 0

    -- Center container
    local loadingFrame = Instance.new("Frame", loadingBg)
    loadingFrame.Size = UDim2.fromOffset(400, 200)
    loadingFrame.Position = UDim2.fromScale(0.5, 0.5)
    loadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    loadingFrame.BorderSizePixel = 0
    Instance.new("UICorner", loadingFrame).CornerRadius = UDim.new(0, 15)

    -- Loading text
    local loadingText = Instance.new("TextLabel", loadingFrame)
    loadingText.Size = UDim2.new(1, 0, 0, 50)
    loadingText.Position = UDim2.fromScale(0, 0.3)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = title .. "..."
    loadingText.Font = Enum.Font.GothamBold
    loadingText.TextSize = 24
    loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingText.TextTransparency = 0
    loadingText.RichText = true

    -- Animated dots
    local dots = ""
    task.spawn(function()
        while loadingGui.Parent do
            dots = dots .. "."
            if #dots > 3 then dots = "" end
            loadingText.Text = string.format('Loading <font color="rgb(%d,%d,%d)">%s</font>%s', 
                accentColor.R * 255, accentColor.G * 255, accentColor.B * 255, title, dots)
            task.wait(0.5)
        end
    end)

    -- Progress bar background
    local progressBg = Instance.new("Frame", loadingFrame)
    progressBg.Size = UDim2.new(0.8, 0, 0, 6)
    progressBg.Position = UDim2.fromScale(0.5, 0.65)
    progressBg.AnchorPoint = Vector2.new(0.5, 0.5)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    progressBg.BorderSizePixel = 0
    Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)

    -- Progress bar fill
    local progressFill = Instance.new("Frame", progressBg)
    progressFill.Size = UDim2.fromScale(0, 1)
    progressFill.BackgroundColor3 = accentColor
    progressFill.BorderSizePixel = 0
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

    -- Animate blur in
    TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 24}):Play()

    -- Animate progress bar
    local progressTween = TweenService:Create(
        progressFill,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.fromScale(1, 1)}
    )
    progressTween:Play()

    -- Wait and fade out
    task.spawn(function()
        task.wait(duration)

        loadingText.Text = string.format('<font color="rgb(%d,%d,%d)">%s Loaded!</font>', 
            accentColor.R * 255, accentColor.G * 255, accentColor.B * 255, title)
        task.wait(0.5)

        -- Fade out
        TweenService:Create(loadingBg, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(loadingText, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(loadingFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(blur, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = 0}):Play()

        task.wait(0.9)
        if blur then blur:Destroy() end
        if loadingGui then loadingGui:Destroy() end

        onComplete()
    end)

    return {
        Gui = loadingGui,
        Blur = blur,
        Destroy = function()
            if blur then blur:Destroy() end
            if loadingGui then loadingGui:Destroy() end
        end
    }
end

-- =====================================================
-- MAIN WINDOW
-- =====================================================
function UILib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "UI Window"
    local accentColor = config.AccentColor or self.Colors.JPUFF_HOT_PINK
    local winName = config.Name or "UILibWindow"
    
    -- Get platform-specific sizes
    local sizes = self:GetSizes()
    local position = config.Position or sizes.SelectorPosition

    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui", gui)
    screenGui.Name = winName
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = config.DisplayOrder or 10000
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Enabled = true

    local window = {
        ScreenGui = screenGui,
        Panels = {},
        CurrentPanel = nil,
        AccentColor = accentColor,
        SelectorFrame = nil,
    }

    -- Create selector frame (left panel) - responsive size
    local selectorFrame = Instance.new("Frame", screenGui)
    selectorFrame.Size = UDim2.fromOffset(sizes.SelectorWidth, sizes.SelectorHeight)
    selectorFrame.Position = position
    selectorFrame.BackgroundColor3 = self.Colors.BG_DARK
    selectorFrame.Active = true
    selectorFrame.Draggable = true
    selectorFrame.BackgroundTransparency = 1
    Instance.new("UICorner", selectorFrame).CornerRadius = UDim.new(0, 20)

    local selectorStroke = Instance.new("UIStroke", selectorFrame)
    selectorStroke.Color = accentColor
    selectorStroke.Thickness = 2
    selectorStroke.Transparency = 1

    -- Selector header - responsive text size
    local selectorHeader = Instance.new("TextLabel", selectorFrame)
    selectorHeader.Size = config.HelpText and UDim2.new(1, -50, 0, 40) or UDim2.new(1, -20, 0, 40)
    selectorHeader.Position = UDim2.fromOffset(10, 10)
    selectorHeader.BackgroundTransparency = 1
    selectorHeader.Text = title
    selectorHeader.Font = Enum.Font.GothamBold
    selectorHeader.TextSize = sizes.HeaderTextSize
    selectorHeader.TextColor3 = accentColor
    selectorHeader.TextXAlignment = Enum.TextXAlignment.Center
    selectorHeader.TextTransparency = 1

    -- Help Button
    local helpBtn = nil
    if config.HelpText then
        helpBtn = Instance.new("TextButton", selectorFrame)
        helpBtn.Size = UDim2.fromOffset(30, 30)
        helpBtn.AnchorPoint = Vector2.new(1, 0)
        helpBtn.Position = UDim2.new(1, -10, 0, 15)
        helpBtn.BackgroundTransparency = 1
        helpBtn.Text = "?"
        helpBtn.Font = Enum.Font.GothamBold
        helpBtn.TextSize = sizes.HeaderTextSize
        helpBtn.TextColor3 = accentColor
        helpBtn.TextTransparency = 1

        -- Help Menu Popup
        local helpOverlay = Instance.new("Frame", screenGui)
        helpOverlay.Size = UDim2.fromScale(1, 1)
        helpOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        helpOverlay.BackgroundTransparency = 1
        helpOverlay.Visible = false
        helpOverlay.ZIndex = 50

        local helpMenu = Instance.new("Frame", helpOverlay)
        helpMenu.Size = UDim2.fromOffset(400, 300)
        helpMenu.Position = UDim2.fromScale(0.5, -0.5) -- Start Above screen
        helpMenu.AnchorPoint = Vector2.new(0.5, 0.5)
        helpMenu.BackgroundColor3 = UILib.Colors.BG_CARD
        helpMenu.BorderSizePixel = 0
        helpMenu.ZIndex = 51
        Instance.new("UICorner", helpMenu).CornerRadius = UDim.new(0, 15)
        
        local helpStroke = Instance.new("UIStroke", helpMenu)
        helpStroke.Color = accentColor
        helpStroke.Thickness = 2
        
        local helpTitle = Instance.new("TextLabel", helpMenu)
        helpTitle.Size = UDim2.new(1, 0, 0, 50)
        helpTitle.BackgroundTransparency = 1
        helpTitle.Text = "How to use"
        helpTitle.Font = Enum.Font.GothamBold
        helpTitle.TextSize = 20
        helpTitle.TextColor3 = accentColor
        helpTitle.ZIndex = 52

        local helpDesc = Instance.new("TextLabel", helpMenu)
        helpDesc.Size = UDim2.new(1, -40, 1, -110)
        helpDesc.Position = UDim2.fromOffset(20, 50)
        helpDesc.BackgroundTransparency = 1
        helpDesc.Text = config.HelpText
        helpDesc.Font = Enum.Font.GothamMedium
        helpDesc.TextSize = 14
        helpDesc.TextColor3 = UILib.Colors.TEXT_PRIMARY
        helpDesc.TextWrapped = true
        helpDesc.TextXAlignment = Enum.TextXAlignment.Left
        helpDesc.TextYAlignment = Enum.TextYAlignment.Top
        helpDesc.ZIndex = 52

        local closeHelpBtn = Instance.new("TextButton", helpMenu)
        closeHelpBtn.Size = UDim2.new(0, 120, 0, 40)
        closeHelpBtn.Position = UDim2.new(0.5, -60, 1, -50)
        closeHelpBtn.BackgroundColor3 = accentColor
        closeHelpBtn.Text = "Got it!"
        closeHelpBtn.Font = Enum.Font.GothamBold
        closeHelpBtn.TextSize = 16
        closeHelpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeHelpBtn.ZIndex = 52
        Instance.new("UICorner", closeHelpBtn).CornerRadius = UDim.new(0, 8)

        local isHelpOpen = false

        helpBtn.MouseButton1Click:Connect(function()
            if isHelpOpen then return end
            isHelpOpen = true
            helpOverlay.Visible = true
            
            TweenService:Create(helpOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
            TweenService:Create(helpMenu, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 0.5)}):Play()
        end)

        closeHelpBtn.MouseButton1Click:Connect(function()
            if not isHelpOpen then return end
            isHelpOpen = false
            
            TweenService:Create(helpOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            local closeTween = TweenService:Create(helpMenu, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.fromScale(0.5, -0.5)})
            closeTween:Play()
            
            closeTween.Completed:Connect(function()
                if not isHelpOpen then
                    helpOverlay.Visible = false
                end
            end)
        end)
    end

    -- Buttons container - responsive height (ScrollingFrame for scrollable panel list)
    local containerHeight = sizes.SelectorHeight - 60
    local selectorButtonsContainer = Instance.new("ScrollingFrame", selectorFrame)
    selectorButtonsContainer.Size = UDim2.new(1, -20, 0, containerHeight)
    selectorButtonsContainer.Position = UDim2.fromOffset(10, 55)
    selectorButtonsContainer.BackgroundTransparency = 1
    selectorButtonsContainer.BorderSizePixel = 0
    selectorButtonsContainer.ScrollBarThickness = 4
    selectorButtonsContainer.ScrollBarImageColor3 = accentColor
    selectorButtonsContainer.CanvasSize = UDim2.fromOffset(0, 0)
    selectorButtonsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    selectorButtonsContainer.ClipsDescendants = true

    local selectorListLayout = Instance.new("UIListLayout", selectorButtonsContainer)
    selectorListLayout.FillDirection = Enum.FillDirection.Vertical
    selectorListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    selectorListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    selectorListLayout.Padding = UDim.new(0, sizes.ButtonPadding)
    selectorListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Auto-update canvas size when buttons are added
    selectorListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        selectorButtonsContainer.CanvasSize = UDim2.fromOffset(0, selectorListLayout.AbsoluteContentSize.Y + 10)
    end)

    window.SelectorFrame = selectorFrame
    window.SelectorButtonsContainer = selectorButtonsContainer
    window.SelectorStroke = selectorStroke
    window.SelectorHeader = selectorHeader

    -- Custom Drag Logic with Panel Sync
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        selectorFrame.Position = newPos
        
        -- SYNC ALL VISIBLE PANELS
        if window.Panels then
            for _, panel in pairs(window.Panels) do
                if panel.Frame and panel.Frame.Visible then
                    panel.Frame.Position = UDim2.new(
                        newPos.X.Scale, newPos.X.Offset + selectorFrame.AbsoluteSize.X + 20,
                        newPos.Y.Scale, newPos.Y.Offset
                    )
                end
            end
        end
    end

    local function enableDrag(frame)
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = selectorFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
    
        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
    end

    -- Enable drag on both Frame and Header to ensure input is captured
    selectorHeader.Active = true 
    enableDrag(selectorFrame)
    enableDrag(selectorHeader)

    local dragConnection = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    window.DragConnection = dragConnection

    -- Attach methods to window
    UILib:AddMethods(window)

    -- Fade in animation
    task.spawn(function()
        task.wait(0.3)
        TweenService:Create(selectorFrame, TweenInfo.new(0.6), {BackgroundTransparency = 0.15}):Play()
        TweenService:Create(selectorStroke, TweenInfo.new(0.6), {Transparency = 0.5}):Play()
        TweenService:Create(selectorHeader, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        if helpBtn then
            TweenService:Create(helpBtn, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        end
    end)

    return window
end

-- =====================================================
-- PANEL (TAB)
-- =====================================================
function UILib:CreatePanel(window, config)
    config = config or {}
    local name = config.Name or "Panel"
    local displayName = config.DisplayName or name
    local color = config.Color or window.AccentColor
    local layoutOrder = config.LayoutOrder or 1
    
    -- Get platform-specific sizes
    local sizes = self:GetSizes()
    local size = config.Size or UDim2.fromOffset(sizes.PanelWidth, sizes.PanelHeight)

    -- Create panel frame - responsive size
    local panelFrame = Instance.new("Frame", window.ScreenGui)
    panelFrame.Size = size
    panelFrame.Position = UDim2.fromOffset(sizes.PanelOffsetX, sizes.SelectorPosition.Y.Offset)
    panelFrame.BackgroundColor3 = UILib.Colors.BG_DARK
    panelFrame.Active = true
    panelFrame.BackgroundTransparency = 1
    panelFrame.Visible = false
    panelFrame.ClipsDescendants = true
    Instance.new("UICorner", panelFrame).CornerRadius = UDim.new(0, 20)

    local panelStroke = Instance.new("UIStroke", panelFrame)
    panelStroke.Color = UILib.Colors.JPUFF_PINK
    panelStroke.Thickness = 2
    panelStroke.Transparency = 1

    -- Panel header - responsive text size
    local panelHeader = Instance.new("TextLabel", panelFrame)
    panelHeader.Size = config.HelpText and UDim2.new(1, -70, 0, 50) or UDim2.new(1, -40, 0, 50)
    panelHeader.Position = UDim2.fromOffset(sizes.ContentPadding, 15)

    -- Help Button for Panel
    local helpBtn = nil
    if config.HelpText then
        helpBtn = Instance.new("TextButton", panelFrame)
        helpBtn.Size = UDim2.fromOffset(30, 30)
        helpBtn.AnchorPoint = Vector2.new(1, 0)
        helpBtn.Position = UDim2.new(1, -15, 0, 25) -- Adjusted for panel
        helpBtn.BackgroundTransparency = 1
        helpBtn.Text = "?"
        helpBtn.Font = Enum.Font.GothamBold
        helpBtn.TextSize = sizes.PanelHeaderTextSize
        helpBtn.TextColor3 = color
        helpBtn.TextTransparency = 1

        -- Help Menu Popup
        local helpOverlay = Instance.new("Frame", window.ScreenGui)
        helpOverlay.Size = UDim2.fromScale(1, 1)
        helpOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        helpOverlay.BackgroundTransparency = 1
        helpOverlay.Visible = false
        helpOverlay.ZIndex = 60

        local helpMenu = Instance.new("Frame", helpOverlay)
        helpMenu.Size = UDim2.fromOffset(400, 300)
        helpMenu.Position = UDim2.fromScale(0.5, -0.5) -- Start Above screen
        helpMenu.AnchorPoint = Vector2.new(0.5, 0.5)
        helpMenu.BackgroundColor3 = UILib.Colors.BG_CARD
        helpMenu.BorderSizePixel = 0
        helpMenu.ZIndex = 61
        Instance.new("UICorner", helpMenu).CornerRadius = UDim.new(0, 15)
        
        local helpStroke = Instance.new("UIStroke", helpMenu)
        helpStroke.Color = color
        helpStroke.Thickness = 2
        
        local helpTitle = Instance.new("TextLabel", helpMenu)
        helpTitle.Size = UDim2.new(1, 0, 0, 50)
        helpTitle.BackgroundTransparency = 1
        helpTitle.Text = displayName .. " Help"
        helpTitle.Font = Enum.Font.GothamBold
        helpTitle.TextSize = 20
        helpTitle.TextColor3 = color
        helpTitle.ZIndex = 62

        local helpDesc = Instance.new("TextLabel", helpMenu)
        helpDesc.Size = UDim2.new(1, -40, 1, -110)
        helpDesc.Position = UDim2.fromOffset(20, 50)
        helpDesc.BackgroundTransparency = 1
        helpDesc.Text = config.HelpText
        helpDesc.Font = Enum.Font.GothamMedium
        helpDesc.TextSize = 14
        helpDesc.TextColor3 = UILib.Colors.TEXT_PRIMARY
        helpDesc.TextWrapped = true
        helpDesc.TextXAlignment = Enum.TextXAlignment.Left
        helpDesc.TextYAlignment = Enum.TextYAlignment.Top
        helpDesc.ZIndex = 62

        local closeHelpBtn = Instance.new("TextButton", helpMenu)
        closeHelpBtn.Size = UDim2.new(0, 120, 0, 40)
        closeHelpBtn.Position = UDim2.new(0.5, -60, 1, -50)
        closeHelpBtn.BackgroundColor3 = color
        closeHelpBtn.Text = "Got it!"
        closeHelpBtn.Font = Enum.Font.GothamBold
        closeHelpBtn.TextSize = 16
        closeHelpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeHelpBtn.ZIndex = 62
        Instance.new("UICorner", closeHelpBtn).CornerRadius = UDim.new(0, 8)

        local isHelpOpen = false

        helpBtn.MouseButton1Click:Connect(function()
            if isHelpOpen then return end
            isHelpOpen = true
            helpOverlay.Visible = true
            
            TweenService:Create(helpOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
            TweenService:Create(helpMenu, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 0.5)}):Play()
        end)

        closeHelpBtn.MouseButton1Click:Connect(function()
            if not isHelpOpen then return end
            isHelpOpen = false
            
            TweenService:Create(helpOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            local closeTween = TweenService:Create(helpMenu, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.fromScale(0.5, -0.5)})
            closeTween:Play()
            
            closeTween.Completed:Connect(function()
                if not isHelpOpen then
                    helpOverlay.Visible = false
                end
            end)
        end)
    end
    panelHeader.BackgroundTransparency = 1
    panelHeader.Text = displayName
    panelHeader.Font = Enum.Font.GothamBold
    panelHeader.TextSize = sizes.PanelHeaderTextSize
    panelHeader.TextColor3 = UILib.Colors.JPUFF_PINK
    panelHeader.TextXAlignment = Enum.TextXAlignment.Left
    panelHeader.TextTransparency = 1

    -- Panel divider
    local panelDivider = Instance.new("Frame", panelFrame)
    panelDivider.Size = UDim2.new(1, -(sizes.ContentPadding * 2), 0, 2)
    panelDivider.Position = UDim2.fromOffset(sizes.ContentPadding, 70)
    panelDivider.BackgroundColor3 = UILib.Colors.JPUFF_PINK
    panelDivider.BorderSizePixel = 0
    panelDivider.BackgroundTransparency = 1
    Instance.new("UICorner", panelDivider).CornerRadius = UDim.new(1, 0)

    -- Scrolling container for panel content
    local scrollingFrame = Instance.new("ScrollingFrame", panelFrame)
    scrollingFrame.Size = UDim2.new(1, 0, 1, -85) -- Full width, height minus header
    scrollingFrame.Position = UDim2.fromOffset(0, 85)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.ScrollBarImageColor3 = UILib.Colors.JPUFF_PINK
    scrollingFrame.CanvasSize = UDim2.fromOffset(0, 0) -- Will auto-adjust
    scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollingFrame.ClipsDescendants = true

    -- Create selector button
    local btn = Instance.new("TextButton", window.SelectorButtonsContainer)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = color
    btn.Text = ""
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = sizes.ButtonTextSize
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 1
    btn.LayoutOrder = layoutOrder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    local mainText = Instance.new("TextLabel", btn)
    mainText.Size = UDim2.new(1, -50, 1, 0)
    mainText.Position = UDim2.fromOffset(15, 0)
    mainText.BackgroundTransparency = 1
    mainText.Text = displayName
    mainText.Font = Enum.Font.GothamBold
    mainText.TextSize = sizes.ButtonTextSize
    mainText.TextColor3 = Color3.fromRGB(150, 150, 160)
    mainText.TextXAlignment = Enum.TextXAlignment.Left
    mainText.TextTransparency = 1

    local arrow = Instance.new("TextLabel", btn)
    arrow.Size = UDim2.fromOffset(30, 45)
    arrow.Position = UDim2.fromOffset(10, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "→"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 20
    arrow.TextColor3 = color
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.TextTransparency = 1

    -- Hover effects
    btn.MouseEnter:Connect(function()
        TweenService:Create(mainText, TweenInfo.new(0.2), {TextColor3 = UILib.Colors.TEXT_PRIMARY}):Play()
    end)

    btn.MouseLeave:Connect(function()
        if window.CurrentPanel == name then
            TweenService:Create(mainText, TweenInfo.new(0.2), {TextColor3 = color}):Play()
        else
            TweenService:Create(mainText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
        end
    end)

    -- Fade in button text
    task.spawn(function()
        task.wait(0.5)
        TweenService:Create(mainText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    end)

    local panel = {
        Name = name,
        Frame = panelFrame,
        ScrollingFrame = scrollingFrame,
        Button = btn,
        Arrow = arrow,
        MainText = mainText,
        Color = color,
        Size = size,
        ContentY = 0, -- Starting Y position for content (relative to scrolling frame)
        UpdateCanvasSize = function(self)
            -- Auto-adjust canvas size based on ContentY
            scrollingFrame.CanvasSize = UDim2.fromOffset(0, math.max(self.ContentY + 20, scrollingFrame.AbsoluteSize.Y or 400))
        end
    }

    -- Panel switching logic
    btn.MouseButton1Click:Connect(function()
        window:ShowPanel(name)
    end)

    window.Panels[name] = panel

    return panel
end

-- =====================================================
-- SHOW/HIDE PANEL
-- =====================================================
function UILib:ShowPanel(window, panelName)
    local panel = window.Panels[panelName]
    if not panel then return end

    -- If clicking the same panel, hide it
    if window.CurrentPanel == panelName then
        window:HidePanel(panelName)
        TweenService:Create(panel.Arrow, TweenInfo.new(0.3), {TextTransparency = 1, Position = UDim2.fromOffset(10, 0)}):Play()
        TweenService:Create(panel.MainText, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 160), Position = UDim2.fromOffset(15, 0)}):Play()
        return
    end

    -- Hide current panel if exists
    if window.CurrentPanel then
        local oldPanel = window.Panels[window.CurrentPanel]
        if oldPanel then
            window:HidePanel(window.CurrentPanel)
            TweenService:Create(oldPanel.Arrow, TweenInfo.new(0.3), {TextTransparency = 1, Position = UDim2.fromOffset(10, 0)}):Play()
            TweenService:Create(oldPanel.MainText, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 160), Position = UDim2.fromOffset(15, 0)}):Play()
        end
        task.wait(0.4)
    end

    -- Show new panel
    window.CurrentPanel = panelName
    panel.Frame.Visible = true
    panel.Frame.Size = UDim2.fromOffset(0, 0)
    panel.Frame.Position = UDim2.fromOffset(
        window.SelectorFrame.AbsolutePosition.X + window.SelectorFrame.AbsoluteSize.X / 2,
        window.SelectorFrame.AbsolutePosition.Y + 80
    )

    -- Animate text and arrow
    TweenService:Create(panel.MainText, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {TextColor3 = panel.Color, Position = UDim2.fromOffset(45, 0)}):Play()

    task.delay(0.12, function()
        if window.CurrentPanel == panelName then
            TweenService:Create(panel.Arrow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
                {TextTransparency = 0, Position = UDim2.fromOffset(15, 0)}):Play()
        end
    end)

    -- Animate panel
    TweenService:Create(panel.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
        {Size = panel.Size, Position = UDim2.fromOffset(
            window.SelectorFrame.AbsolutePosition.X + window.SelectorFrame.AbsoluteSize.X + 20,
            window.SelectorFrame.AbsolutePosition.Y
        )}):Play()
    TweenService:Create(panel.Frame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {BackgroundTransparency = 0.15}):Play()

    local panelStroke = panel.Frame:FindFirstChildOfClass("UIStroke")
    if panelStroke then
        TweenService:Create(panelStroke, TweenInfo.new(0.6), {Transparency = 0.5}):Play()
    end

    -- Fade in all content
    for _, child in ipairs(panel.Frame:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            TweenService:Create(child, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        end
        if child:IsA("Frame") and child.Parent ~= window.ScreenGui then
            local goalBg = 0
            if child:FindFirstChild("IsTransparent") then
                goalBg = 0.2
            end
            TweenService:Create(child, TweenInfo.new(0.5), {BackgroundTransparency = goalBg}):Play()
        end
        if child:IsA("ScrollingFrame") then
            -- Skip: ScrollingFrame should stay transparent
        elseif child:IsA("ImageLabel") then
            -- Skip toggle icons (they manage their own transparency based on state)
            if child.Name ~= "ImgOn" and child.Name ~= "ImgOff" then
                TweenService:Create(child, TweenInfo.new(0.5), {ImageTransparency = 0}):Play()
            end
        end
    end
end

function UILib:HidePanel(window, panelName)
    local panel = window.Panels[panelName]
    if not panel or window.CurrentPanel ~= panelName then return end

    TweenService:Create(panel.Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), 
        {Size = UDim2.fromOffset(0, 0), Position = UDim2.fromOffset(
            window.SelectorFrame.AbsolutePosition.X + window.SelectorFrame.AbsoluteSize.X / 2,
            window.SelectorFrame.AbsolutePosition.Y + 80
        )}):Play()

    task.wait(0.4)
    panel.Frame.Visible = false
    window.CurrentPanel = nil
end

-- =====================================================
-- TOGGLE
-- =====================================================
function UILib:CreateToggle(panel, config)
    config = config or {}
    local labelText = config.Label or "Toggle"
    local initialState = config.Default or false
    local callback = config.Callback or function() end
    local y = panel.ContentY
    
    -- Get platform-specific sizes
    local sizes = self:GetSizes()

    -- Calculate responsive label width to leave space for toggle
    local labelLeftMargin = 30
    local toggleRightMargin = 15
    local labelToggleSpacing = 10
    local totalToggleSpace = sizes.ToggleTrackWidth + toggleRightMargin + labelToggleSpacing
    
    local label = Instance.new("TextLabel", panel.ScrollingFrame)
    label.Size = UDim2.new(1, -(labelLeftMargin + totalToggleSpace), 0, 45)
    label.Position = UDim2.fromOffset(labelLeftMargin, y)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.GothamMedium
    label.TextSize = sizes.LabelTextSize
    label.TextColor3 = UILib.Colors.TEXT_PRIMARY
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextTransparency = 0

    -- Calculate responsive toggle position based on panel width
    local toggleRightMargin = 15
    local toggleOffset = -(sizes.ToggleTrackWidth + toggleRightMargin)
    
    local track = Instance.new("Frame", panel.ScrollingFrame)
    track.Size = UDim2.fromOffset(sizes.ToggleTrackWidth, sizes.ToggleTrackHeight)
    track.Position = UDim2.new(1, toggleOffset, 0, y + 2.5)
    track.BackgroundColor3 = initialState and UILib.Colors.JPUFF_HOT_PINK or UILib.Colors.TOGGLE_OFF
    track.BorderSizePixel = 0
    track.BackgroundTransparency = 0
    track.ClipsDescendants = true
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local ballBg = Instance.new("Frame", track)
    ballBg.Size = UDim2.fromOffset(sizes.ToggleBallSize, sizes.ToggleBallSize)
    ballBg.AnchorPoint = Vector2.new(0.5, 0.5)
    local ballOffOn = sizes.ToggleTrackWidth - (sizes.ToggleBallSize / 2) - 3
    local ballOffOff = sizes.ToggleBallSize / 2 + 3
    ballBg.Position = initialState and UDim2.fromOffset(ballOffOn, sizes.ToggleTrackHeight / 2) or UDim2.fromOffset(ballOffOff, sizes.ToggleTrackHeight / 2)
    ballBg.BackgroundColor3 = UILib.Colors.TOGGLE_OFF
    ballBg.BackgroundTransparency = 1
    ballBg.BorderSizePixel = 0
    ballBg.ClipsDescendants = true
    Instance.new("UICorner", ballBg).CornerRadius = UDim.new(1, 0)

    -- OFF IMAGE (Sleep)
    local imgOff = Instance.new("ImageLabel", ballBg)
    imgOff.Name = "ImgOff"
    imgOff.Size = UDim2.fromScale(1, 1)
    imgOff.Position = UDim2.fromScale(0, 0)
    imgOff.BackgroundTransparency = 1
    imgOff.Image = "rbxthumb://type=Asset&id=134295060007569&w=150&h=150"
    imgOff.ScaleType = Enum.ScaleType.Crop
    imgOff.BorderSizePixel = 0
    Instance.new("UICorner", imgOff).CornerRadius = UDim.new(1, 0)

    -- ON IMAGE (Awake)
    local imgOn = Instance.new("ImageLabel", ballBg)
    imgOn.Name = "ImgOn"
    imgOn.Size = UDim2.fromScale(1, 1)
    imgOn.Position = UDim2.fromScale(0, 0)
    imgOn.BackgroundTransparency = 1
    imgOn.Image = "rbxthumb://type=Asset&id=111028440784816&w=150&h=150"
    imgOn.ScaleType = Enum.ScaleType.Crop
    imgOn.BorderSizePixel = 0
    Instance.new("UICorner", imgOn).CornerRadius = UDim.new(1, 0)

    -- Set initial visibility
    if initialState then
        imgOn.Visible = true
        imgOff.Visible = false
    else
        imgOn.Visible = false
        imgOff.Visible = true
    end

    local button = Instance.new("TextButton", track)
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.Text = ""

    local state = initialState
    local accumulatedRotation = 0
    local isAnimating = false

    local function toggle()
        if isAnimating then return state end
        isAnimating = true

        local oldState = state
        state = not state

        -- Animate track color
        TweenService:Create(track, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {BackgroundColor3 = state and UILib.Colors.JPUFF_HOT_PINK or UILib.Colors.TOGGLE_OFF}):Play()

        -- Animate ball position
        TweenService:Create(ballBg, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
            {Position = state and UDim2.fromOffset(70, 20) or UDim2.fromOffset(20, 20)}):Play()

        -- Spin animation
        local rotationChange = state and 360 or -360
        accumulatedRotation = accumulatedRotation + rotationChange
        TweenService:Create(ballBg, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
            {Rotation = accumulatedRotation}):Play()

        -- Swap icon at midpoint of spin (no tweening ImageLabels to avoid clipping bugs)
        task.delay(0.3, function()
            imgOn.Visible = state and true or false
            imgOff.Visible = state and false or true
        end)

        task.delay(0.65, function()
            isAnimating = false
            ballBg.Rotation = 0
            accumulatedRotation = 0
        end)

        -- Call callback and check if it returns false to cancel
        local result = callback(state)
        if result == false then
            -- Callback canceled, revert state immediately
            state = not state
            -- Instantly set visuals to match reverted state
            task.wait(0.05)
            track.BackgroundColor3 = state and UILib.Colors.JPUFF_HOT_PINK or UILib.Colors.TOGGLE_OFF
            ballBg.Position = state and UDim2.fromOffset(70, 20) or UDim2.fromOffset(20, 20)
            imgOn.Visible = state and true or false
            imgOff.Visible = state and false or true
        end
        return state
    end

    button.MouseButton1Click:Connect(toggle)

    panel.ContentY = panel.ContentY + 55
    panel:UpdateCanvasSize()

    return {
        Toggle = toggle,
        GetState = function() return state end,
        SetState = function(newState)
            if newState ~= state then
                toggle()
            end
        end,
        -- Silent state update (for config loading) - updates UI without triggering callback
        SetStateSilent = function(newState)
            if newState == state then return end
            state = newState
            -- Instantly update visuals without animation
            track.BackgroundColor3 = state and UILib.Colors.JPUFF_HOT_PINK or UILib.Colors.TOGGLE_OFF
            local ballOnPos = sizes.ToggleTrackWidth - (sizes.ToggleBallSize / 2) - 3
            local ballOffPos = sizes.ToggleBallSize / 2 + 3
            ballBg.Position = state and UDim2.fromOffset(ballOnPos, sizes.ToggleTrackHeight / 2) or UDim2.fromOffset(ballOffPos, sizes.ToggleTrackHeight / 2)
            imgOn.Visible = state and true or false
            imgOff.Visible = state and false or true
        end,
        -- Direct access to track for custom styling
        Track = track,
        Label = label
    }
end

-- =====================================================
-- COLLAPSIBLE TOGGLE
-- =====================================================
function UILib:CreateCollapsibleToggle(panel, config)
    config = config or {}
    local labelText = config.Label or "Toggle"
    local initialState = config.Default or false
    local callback = config.Callback or function() end
    local subToggles = config.SubToggles or {}
    local autoCloseDelay = config.AutoCloseDelay or 1  -- Delay between closing others and opening this one
    local y = panel.ContentY
    
    -- Generate unique ID for this collapsible toggle
    local toggleId = tostring(panel) .. "_" .. labelText .. "_" .. tostring(y)
    
    -- Get platform-specific sizes
    local sizes = self:GetSizes()
    
    -- Calculate responsive label width
    local arrowWidth = 40
    local labelLeftMargin = 30 + arrowWidth  -- Space for arrow
    local toggleRightMargin = 15
    local labelToggleSpacing = 10
    local totalToggleSpace = sizes.ToggleTrackWidth + toggleRightMargin + labelToggleSpacing
    
    -- Create arrow button
    local arrowButton = Instance.new("TextButton", panel.ScrollingFrame)
    arrowButton.Size = UDim2.fromOffset(30, 45)
    arrowButton.Position = UDim2.fromOffset(5, y)
    arrowButton.BackgroundTransparency = 1
    arrowButton.Text = "▶"
    arrowButton.TextColor3 = UILib.Colors.JPUFF_HOT_PINK
    arrowButton.Font = Enum.Font.GothamBold
    arrowButton.TextSize = 16
    arrowButton.ZIndex = 10
    arrowButton.AutoButtonColor = false
    
    -- Create main toggle label
    local label = Instance.new("TextLabel", panel.ScrollingFrame)
    label.Size = UDim2.new(1, -(labelLeftMargin + totalToggleSpace), 0, 45)
    label.Position = UDim2.fromOffset(labelLeftMargin, y)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.GothamMedium
    label.TextSize = sizes.LabelTextSize
    label.TextColor3 = UILib.Colors.TEXT_PRIMARY
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextTransparency = 0

    -- Create toggle track
    local toggleRightMargin = 15
    local toggleOffset = -(sizes.ToggleTrackWidth + toggleRightMargin)
    
    local track = Instance.new("Frame", panel.ScrollingFrame)
    track.Size = UDim2.fromOffset(sizes.ToggleTrackWidth, sizes.ToggleTrackHeight)
    track.Position = UDim2.new(1, toggleOffset, 0, y + 2.5)
    track.BackgroundColor3 = initialState and UILib.Colors.JPUFF_HOT_PINK or UILib.Colors.TOGGLE_OFF
    track.BorderSizePixel = 0
    track.BackgroundTransparency = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local ballBg = Instance.new("Frame", track)
    ballBg.Size = UDim2.fromOffset(sizes.ToggleBallSize, sizes.ToggleBallSize)
    ballBg.AnchorPoint = Vector2.new(0.5, 0.5)
    local ballOffOn = sizes.ToggleTrackWidth - (sizes.ToggleBallSize / 2) - 3
    local ballOffOff = sizes.ToggleBallSize / 2 + 3
    ballBg.Position = initialState and UDim2.fromOffset(ballOffOn, sizes.ToggleTrackHeight / 2) or UDim2.fromOffset(ballOffOff, sizes.ToggleTrackHeight / 2)
    ballBg.BackgroundColor3 = UILib.Colors.TOGGLE_OFF
    ballBg.BackgroundTransparency = 1
    ballBg.BorderSizePixel = 0
    Instance.new("UICorner", ballBg).CornerRadius = UDim.new(1, 0)

    -- Toggle images
    local imgOff = Instance.new("ImageLabel", ballBg)
    imgOff.Name = "ImgOff"
    imgOff.Size = UDim2.fromScale(1.2, 1.2)
    imgOff.Position = UDim2.fromScale(-0.1, -0.1)
    imgOff.BackgroundTransparency = 1
    imgOff.Image = "rbxthumb://type=Asset&id=134295060007569&w=150&h=150"
    imgOff.ScaleType = Enum.ScaleType.Crop
    imgOff.BorderSizePixel = 0
    imgOff.ZIndex = 2
    Instance.new("UICorner", imgOff).CornerRadius = UDim.new(1, 0)

    local imgOn = Instance.new("ImageLabel", ballBg)
    imgOn.Name = "ImgOn"
    imgOn.Size = UDim2.fromScale(1.2, 1.2)
    imgOn.Position = UDim2.fromScale(-0.1, -0.1)
    imgOn.BackgroundTransparency = 1
    imgOn.Image = "rbxthumb://type=Asset&id=111028440784816&w=150&h=150"
    imgOn.ScaleType = Enum.ScaleType.Crop
    imgOn.BorderSizePixel = 0
    imgOn.ZIndex = 2
    Instance.new("UICorner", imgOn).CornerRadius = UDim.new(1, 0)

    -- Set initial transparency - KEEP BOTH ICONS ALWAYS VISIBLE
    -- Control visibility purely through ImageTransparency
    imgOn.Visible = true
    imgOff.Visible = true
    
    if initialState then
        -- ON state: show imgOn, hide imgOff
        imgOn.ImageTransparency = 0
        imgOff.ImageTransparency = 1
    else
        -- OFF state: hide imgOn, show imgOff
        imgOn.ImageTransparency = 1
        imgOff.ImageTransparency = 0
    end

    local button = Instance.new("TextButton", track)
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.Text = ""

    local state = initialState
    local accumulatedRotation = 0
    local isAnimating = false

    local function toggle()
        if isAnimating then return state end
        isAnimating = true

        state = not state

        imgOn.Visible = true
        imgOn.ImageTransparency = state and 1 or 0
        imgOff.Visible = true
        imgOff.ImageTransparency = state and 0 or 1

        TweenService:Create(track, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {BackgroundColor3 = state and UILib.Colors.JPUFF_HOT_PINK or UILib.Colors.TOGGLE_OFF}):Play()

        TweenService:Create(ballBg, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
            {Position = state and UDim2.fromOffset(ballOffOn, sizes.ToggleTrackHeight / 2) or UDim2.fromOffset(ballOffOff, sizes.ToggleTrackHeight / 2)}):Play()

        local rotationChange = state and 360 or -360
        accumulatedRotation = accumulatedRotation + rotationChange
        TweenService:Create(ballBg, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
            {Rotation = accumulatedRotation}):Play()

        TweenService:Create(imgOn, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
            {ImageTransparency = state and 0 or 1}):Play()
        TweenService:Create(imgOff, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
            {ImageTransparency = state and 1 or 0}):Play()

        task.delay(0.65, function()
            isAnimating = false
            if state then
                imgOff.Visible = false
            else
                imgOn.Visible = false
            end
        end)

        local result = callback(state)
        if result == false then
            state = not state
            task.wait(0.05)
            track.BackgroundColor3 = state and UILib.Colors.JPUFF_HOT_PINK or UILib.Colors.TOGGLE_OFF
            ballBg.Position = state and UDim2.fromOffset(ballOffOn, sizes.ToggleTrackHeight / 2) or UDim2.fromOffset(ballOffOff, sizes.ToggleTrackHeight / 2)
            imgOn.ImageTransparency = state and 0 or 1
            imgOff.ImageTransparency = state and 1 or 0
        end
        return state
    end

    button.MouseButton1Click:Connect(toggle)

    -- Move ContentY forward for main toggle
    panel.ContentY = panel.ContentY + 55
    
    -- Create sub-toggles (initially removed from parent)
    local subFrames = {}
    local subToggleHeight = #subToggles * 55
    
    for _, subConfig in ipairs(subToggles) do
        local subY = panel.ContentY
        local subLabel = Instance.new("TextLabel", panel.ScrollingFrame)
        subLabel.Size = UDim2.new(1, -(60 + totalToggleSpace), 0, 45)
        subLabel.Position = UDim2.fromOffset(60, subY)  -- Indented
        subLabel.BackgroundTransparency = 1
        subLabel.Text = subConfig.Label or "Sub-Toggle"
        subLabel.Font = Enum.Font.GothamMedium
        subLabel.TextSize = sizes.LabelTextSize - 2
        subLabel.TextColor3 = UILib.Colors.TEXT_SECONDARY
        subLabel.TextXAlignment = Enum.TextXAlignment.Left
        subLabel.TextYAlignment = Enum.TextYAlignment.Center
        subLabel.TextTransparency = 0

        local subTrack = Instance.new("Frame", panel.ScrollingFrame)
        subTrack.Size = UDim2.fromOffset(sizes.ToggleTrackWidth, sizes.ToggleTrackHeight)
        subTrack.Position = UDim2.new(1, toggleOffset, 0, subY + 2.5)
        subTrack.BackgroundColor3 = (subConfig.Default or false) and UILib.Colors.JPUFF_HOT_PINK or UILib.Colors.TOGGLE_OFF
        subTrack.BorderSizePixel = 0
        subTrack.BackgroundTransparency = 0
        Instance.new("UICorner", subTrack).CornerRadius = UDim.new(1, 0)

        local subBallBg = Instance.new("Frame", subTrack)
        subBallBg.Size = UDim2.fromOffset(sizes.ToggleBallSize, sizes.ToggleBallSize)
        subBallBg.AnchorPoint = Vector2.new(0.5, 0.5)
        subBallBg.Position = (subConfig.Default or false) and UDim2.fromOffset(ballOffOn, sizes.ToggleTrackHeight / 2) or UDim2.fromOffset(ballOffOff, sizes.ToggleTrackHeight / 2)
        subBallBg.BackgroundColor3 = UILib.Colors.TOGGLE_OFF
        subBallBg.BackgroundTransparency = 1
        subBallBg.BorderSizePixel = 0
        Instance.new("UICorner", subBallBg).CornerRadius = UDim.new(1, 0)

        local subImgOff = Instance.new("ImageLabel", subBallBg)
        subImgOff.Size = UDim2.fromScale(1.2, 1.2)
        subImgOff.Position = UDim2.fromScale(-0.1, -0.1)
        subImgOff.BackgroundTransparency = 1
        subImgOff.Image = "rbxthumb://type=Asset&id=134295060007569&w=150&h=150"
        subImgOff.ScaleType = Enum.ScaleType.Crop
        subImgOff.BorderSizePixel = 0
        subImgOff.ZIndex = 2
        Instance.new("UICorner", subImgOff).CornerRadius = UDim.new(1, 0)

        local subImgOn = Instance.new("ImageLabel", subBallBg)
        subImgOn.Size = UDim2.fromScale(1.2, 1.2)
        subImgOn.Position = UDim2.fromScale(-0.1, -0.1)
        subImgOn.BackgroundTransparency = 1
        subImgOn.Image = "rbxthumb://type=Asset&id=111028440784816&w=150&h=150"
        subImgOn.ScaleType = Enum.ScaleType.Crop
        subImgOn.BorderSizePixel = 0
        subImgOn.ZIndex = 2
        subImgOn.ImageTransparency = (subConfig.Default or false) and 0 or 1
        Instance.new("UICorner", subImgOn).CornerRadius = UDim.new(1, 0)

        -- KEEP BOTH SUB-TOGGLE ICONS ALWAYS VISIBLE
        subImgOn.Visible = true
        subImgOff.Visible = true
        subImgOff.ImageTransparency = (subConfig.Default or false) and 1 or 0

        local subButton = Instance.new("TextButton", subTrack)
        subButton.Size = UDim2.fromScale(1, 1)
        subButton.BackgroundTransparency = 1
        subButton.Text = ""

        local subState = subConfig.Default or false
        local subAccumulatedRotation = 0
        local subIsAnimating = false

        local function subToggle(force)
            if subIsAnimating and not force then return subState end
            if force then subIsAnimating = false end
            subIsAnimating = true

            local oldSubState = subState
            subState = not subState

            -- Keep both icons always visible but set correct starting transparency
            subImgOn.Visible = true
            subImgOff.Visible = true
            
            -- Set STARTING transparency based on OLD state
            subImgOn.ImageTransparency = oldSubState and 0 or 1
            subImgOff.ImageTransparency = oldSubState and 1 or 0

            TweenService:Create(subTrack, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {BackgroundColor3 = subState and UILib.Colors.JPUFF_HOT_PINK or UILib.Colors.TOGGLE_OFF}):Play()

            TweenService:Create(subBallBg, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
                {Position = subState and UDim2.fromOffset(ballOffOn, sizes.ToggleTrackHeight / 2) or UDim2.fromOffset(ballOffOff, sizes.ToggleTrackHeight / 2)}):Play()

            local subRotationChange = subState and 360 or -360
            subAccumulatedRotation = subAccumulatedRotation + subRotationChange
            TweenService:Create(subBallBg, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
                {Rotation = subAccumulatedRotation}):Play()

            -- Animate to TARGET transparency based on NEW state
            TweenService:Create(subImgOn, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
                {ImageTransparency = subState and 0 or 1}):Play()
            TweenService:Create(subImgOff, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
                {ImageTransparency = subState and 1 or 0}):Play()

            task.delay(0.65, function()
                subIsAnimating = false
            end)

            if subConfig.Callback then
                subConfig.Callback(subState)
            end
            return subState
        end

        subButton.MouseButton1Click:Connect(subToggle)

        -- Store all elements for this sub-toggle INCLUDING ICON REFERENCES
        table.insert(subFrames, {
            label = subLabel,
            track = subTrack,
            imgOn = subImgOn,  -- CRITICAL: Store icon references
            imgOff = subImgOff,
            getState = function() return subState end,  -- Store state getter
            toggleFunc = subToggle, -- CRITICAL: Store toggle function for external sync
            yPosition = subY
        })

        panel.ContentY = panel.ContentY + 55
    end
    
    -- Remove sub-toggles from parent initially (collapsed state)
    for _, frameData in ipairs(subFrames) do
        frameData.label.Parent = nil
        frameData.track.Parent = nil
    end
    
    -- Reset ContentY since we removed the sub-toggles
    panel.ContentY = panel.ContentY - subToggleHeight
    
    -- Arrow click handler for expand/collapse
    local isExpanded = false
    local isAnimating = false  -- Prevent spam-clicking
    
    -- Function to collapse THIS toggle (will be stored for auto-close)
    local function collapseThisToggle()
        if not isExpanded then return end
        isExpanded = false
        
        
        -- Animate arrow rotation
        TweenService:Create(arrowButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Rotation = 0}):Play()
        
        -- Find all elements below this toggle
        local mainToggleY = y
        local elementsToShift = {}
        
        -- Build a set of sub-toggle elements to exclude
        local subToggleElements = {}
        for _, frameData in ipairs(subFrames) do
            subToggleElements[frameData.label] = true
            subToggleElements[frameData.track] = true
        end
        
        for _, child in ipairs(panel.ScrollingFrame:GetChildren()) do
            if child:IsA("GuiObject") and child.Position and child.Position.Y.Offset then
                if not subToggleElements[child] and child.Position.Y.Offset > mainToggleY + 50 then
                    table.insert(elementsToShift, child)
                end
            end
        end
        
        -- Hide sub-toggles with animation
        for i, frameData in ipairs(subFrames) do
            if frameData.imgOn and frameData.imgOff then
                frameData.imgOn.ImageTransparency = 1
                frameData.imgOff.ImageTransparency = 1
            end
            
            TweenService:Create(frameData.label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 
                {TextTransparency = 1}):Play()
            TweenService:Create(frameData.track, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 
                {BackgroundTransparency = 1}):Play()
            
            task.delay(0.2, function()
                frameData.label.Parent = nil
                frameData.track.Parent = nil
            end)
        end
        
        -- Shift elements up
        for _, element in ipairs(elementsToShift) do
            local newY = element.Position.Y.Offset - subToggleHeight
            TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Position = UDim2.new(element.Position.X.Scale, element.Position.X.Offset, element.Position.Y.Scale, newY)}):Play()
        end
        
        panel.ContentY = panel.ContentY - subToggleHeight
        
        task.delay(0.3, function()
            panel:UpdateCanvasSize()
        end)
    end
    
    arrowButton.MouseButton1Click:Connect(function()
        -- GLOBAL ANTI-SPAM: Ignore clicks while ANY collapsible is animating
        if UILib.CollapsibleAnimating then 
            return 
        end
        
        UILib.CollapsibleAnimating = true  -- Lock ALL collapsible toggles globally

        
        local targetState = not isExpanded
        
        if targetState then
            -- Expanding: First auto-close all other collapsible toggles
            local otherToggles = {}
            for otherId, otherCollapse in pairs(UILib.OpenCollapsibles) do
                if otherId ~= toggleId then
                    table.insert(otherToggles, otherCollapse)
                end
            end
            
            if #otherToggles > 0 then
                for _, otherCollapse in ipairs(otherToggles) do
                    otherCollapse()
                end
                
                -- Wait for the auto-close delay before expanding this one
                task.wait(autoCloseDelay)
            end
            
            -- Now expand THIS toggle
            isExpanded = true
            UILib.OpenCollapsibles[toggleId] = collapseThisToggle
        else
            -- Collapsing: Remove from open list and collapse
            UILib.OpenCollapsibles[toggleId] = nil
            collapseThisToggle()
            
            -- Unlock after collapse animation completes
            task.delay(0.3, function()
                UILib.CollapsibleAnimating = false
            end)
            
            return  -- Exit early since collapseThisToggle handles everything
        end
        
        -- Animate arrow rotation for expansion
        TweenService:Create(arrowButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Rotation = isExpanded and 90 or 0}):Play()
        
        -- Find all elements below this toggle for shifting
        local mainToggleY = y
        local elementsToShift = {}
        
        
        -- Build a set of sub-toggle elements to exclude
        local subToggleElements = {}
        for _, frameData in ipairs(subFrames) do
            subToggleElements[frameData.label] = true
            subToggleElements[frameData.track] = true
        end
        
        for _, child in ipairs(panel.ScrollingFrame:GetChildren()) do
            if child:IsA("GuiObject") and child.Position and child.Position.Y.Offset then
                -- CRITICAL: Skip sub-toggle elements - they shouldn't be shifted!
                if not subToggleElements[child] and child.Position.Y.Offset > mainToggleY + 50 then
                    table.insert(elementsToShift, child)
                end
            end
        end
        
        
        -- Show sub-toggles with animation
        for i, frameData in ipairs(subFrames) do
            frameData.label.Parent = panel.ScrollingFrame
            frameData.track.Parent = panel.ScrollingFrame
            
            -- CRITICAL FIX: Use stored references instead of searching
            -- This prevents accidentally finding the parent toggle's icons!
            if frameData.imgOn and frameData.imgOff and frameData.getState then
                -- Make sure both are visible
                frameData.imgOn.Visible = true
                frameData.imgOff.Visible = true
                
                -- Get current state and set correct transparency
                local currentState = frameData.getState()
                frameData.imgOn.ImageTransparency = currentState and 0 or 1
                frameData.imgOff.ImageTransparency = currentState and 1 or 0
                

            end
            
            -- Fade in animation
            frameData.label.TextTransparency = 1
            frameData.track.BackgroundTransparency = 1
            
            TweenService:Create(frameData.label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {TextTransparency = 0}):Play()
            TweenService:Create(frameData.track, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {BackgroundTransparency = 0}):Play()
        end
        
        -- Shift elements down
        for _, element in ipairs(elementsToShift) do
            local newY = element.Position.Y.Offset + subToggleHeight
            TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Position = UDim2.new(element.Position.X.Scale, element.Position.X.Offset, element.Position.Y.Scale, newY)}):Play()
        end
        
        panel.ContentY = panel.ContentY + subToggleHeight

        
        -- Unlock after full expand sequence (auto-close delay + expand animation)
        -- Increased to 2s to ensure second arrow cannot be clicked until first is FULLY done
        task.delay(2, function()
            panel:UpdateCanvasSize()
            UILib.CollapsibleAnimating = false
        end)
    end)

    panel:UpdateCanvasSize()

    return {
        Toggle = toggle,
        GetState = function() return state end,
        SetState = function(newState)
            if newState ~= state then
                 -- Force reset animation lock to ensure SyncToggles works
                isAnimating = false
                toggle()
            end
        end,
        IsExpanded = function() return isExpanded end,
        Expand = function()
            if not isExpanded then
                arrowButton.MouseButton1Click:Fire()
            end
        end,
        Collapse = function()
            if isExpanded then
                arrowButton.MouseButton1Click:Fire()
            end
        end,
        -- Expose sub-toggles for external sync (Config System)
        SubToggles = (function()
            local exposed = {}
            for i, frameData in ipairs(subFrames) do
                table.insert(exposed, {
                    SetState = function(val)
                        -- Only toggle if different
                        if val ~= frameData.getState() then
                            if frameData.toggleFunc then
                                -- Pass true to force update (bypass animation lock)
                                frameData.toggleFunc(true)
                            end
                        end
                    end
                })
            end
            return exposed
        end)()
    }
end

-- =====================================================
-- BUTTON
-- =====================================================
function UILib:CreateButton(panel, config)
    config = config or {}
    local text = config.Text or "Button"
    local color = config.Color or UILib.Colors.SUCCESS
    local callback = config.Callback or function() end
    local y = panel.ContentY

    local btn = Instance.new("TextButton", panel.ScrollingFrame)
    btn.Size = UDim2.new(1, -60, 0, 45)
    btn.Position = UDim2.fromOffset(30, y)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = UILib.Colors.TEXT_PRIMARY
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 0.1
    btn.TextTransparency = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, color.R * 255 + 20),
                math.min(255, color.G * 255 + 20),
                math.min(255, color.B * 255 + 20)
            )
        }):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)

    btn.MouseButton1Click:Connect(callback)

    panel.ContentY = panel.ContentY + 55
    panel:UpdateCanvasSize()

    return {
        Button = btn,
        SetText = function(newText) btn.Text = newText end,
        SetColor = function(newColor) 
            color = newColor
            btn.BackgroundColor3 = newColor 
        end,
        SetEnabled = function(enabled)
            btn.Active = enabled
            btn.BackgroundTransparency = enabled and 0.1 or 0.5
        end,
        SetCallback = function(newCallback)
            -- Note: Old callback still connected, but new clicks will use new callback
            callback = newCallback
        end
    }
end

-- =====================================================
-- TEXT INPUT
-- =====================================================
function UILib:CreateTextInput(panel, config)
    config = config or {}
    local placeholder = config.Placeholder or "Enter text..."
    local defaultText = config.Default or ""
    local callback = config.Callback or function() end
    local y = panel.ContentY

    local input = Instance.new("TextBox", panel.ScrollingFrame)
    input.Size = UDim2.new(1, -40, 0, 45)
    input.Position = UDim2.fromOffset(20, y)
    input.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    input.Text = defaultText
    input.PlaceholderText = placeholder
    input.Font = Enum.Font.GothamBold
    input.TextSize = 16
    input.TextColor3 = UILib.Colors.TEXT_PRIMARY
    input.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
    input.BorderSizePixel = 0
    input.BackgroundTransparency = 0.2
    input.TextTransparency = 0
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", input)
    stroke.Color = UILib.Colors.JPUFF_PINK
    stroke.Transparency = 0.8
    
    -- Callback on focus lost
    input.FocusLost:Connect(function(enterPressed)
        callback(input.Text, enterPressed)
    end)

    panel.ContentY = panel.ContentY + 55
    panel:UpdateCanvasSize()

    return {
        TextBox = input,
        GetText = function() return input.Text end,
        SetText = function(text) input.Text = text end,
        SetPlaceholder = function(text) input.PlaceholderText = text end
    }
end

-- =====================================================
-- SLIDER
-- =====================================================
function UILib:CreateSlider(panel, config)
    config = config or {}
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local callback = config.Callback or function() end
    local y = panel.ContentY

    local label = Instance.new("TextLabel", panel.ScrollingFrame)
    label.Size = UDim2.new(1, -40, 0, 20)
    label.Position = UDim2.fromOffset(30, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextColor3 = UILib.Colors.TEXT_PRIMARY
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel", panel.ScrollingFrame)
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -80, 0, y)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.TextColor3 = UILib.Colors.JPUFF_PINK
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBg = Instance.new("Frame", panel.ScrollingFrame)
    sliderBg.Size = UDim2.new(1, -60, 0, 8)
    sliderBg.Position = UDim2.fromOffset(30, y + 25)
    sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    sliderBg.BorderSizePixel = 0
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.fromScale((default - min) / (max - min), 1)
    sliderFill.BackgroundColor3 = UILib.Colors.JPUFF_HOT_PINK
    sliderFill.BorderSizePixel = 0
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    
    local sliderKnob = Instance.new("Frame", sliderBg)
    sliderKnob.Size = UDim2.fromOffset(16, 16)
    sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderKnob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    sliderKnob.BorderSizePixel = 0
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton", sliderBg)
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + ((max - min) * pos))
        
        TweenService:Create(sliderFill, TweenInfo.new(0.05), {Size = UDim2.fromScale(pos, 1)}):Play()
        TweenService:Create(sliderKnob, TweenInfo.new(0.05), {Position = UDim2.new(pos, 0, 0.5, 0)}):Play()
        valueLabel.Text = tostring(value)
        
        callback(value)
    end
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    panel.ContentY = panel.ContentY + 50
    panel:UpdateCanvasSize()

    return {
        SetValue = function(val)
            local pos = math.clamp((val - min) / (max - min), 0, 1)
            TweenService:Create(sliderFill, TweenInfo.new(0.2), {Size = UDim2.fromScale(pos, 1)}):Play()
            TweenService:Create(sliderKnob, TweenInfo.new(0.2), {Position = UDim2.new(pos, 0, 0.5, 0)}):Play()
            valueLabel.Text = tostring(val)
        end
    }
end

-- =====================================================
-- DROPDOWN
-- =====================================================
function UILib:CreateDropdown(panel, config)
    config = config or {}
    local label = config.Label or "Dropdown"
    local options = config.Options or {"Option 1", "Option 2", "Option 3"}
    local callback = config.Callback or function() end
    local enableSearch = config.EnableSearch ~= false -- Default to true
    local y = panel.ContentY
    
    -- Label
    local labelText = Instance.new("TextLabel", panel.ScrollingFrame)
    labelText.Size = UDim2.new(1, -60, 0, 20)
    labelText.Position = UDim2.fromOffset(30, y)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextSize = 14
    labelText.TextColor3 = UILib.Colors.TEXT_PRIMARY
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.TextTransparency = 0
    
    -- Dropdown button
    local dropdownBtn = Instance.new("TextButton", panel.ScrollingFrame)
    dropdownBtn.Size = UDim2.new(1, -60, 0, 45)
    dropdownBtn.Position = UDim2.fromOffset(30, y + 25)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    dropdownBtn.Text = ""
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.BackgroundTransparency = 0.2
    Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 12)
    
    local dropdownStroke = Instance.new("UIStroke", dropdownBtn)
    dropdownStroke.Color = UILib.Colors.JPUFF_PINK
    dropdownStroke.Transparency = 0.8
    
    -- Selected text
    local selectedText = Instance.new("TextLabel", dropdownBtn)
    selectedText.Size = UDim2.new(1, -40, 1, 0)
    selectedText.Position = UDim2.fromOffset(15, 0)
    selectedText.BackgroundTransparency = 1
    selectedText.Text = "Select..."
    selectedText.Font = Enum.Font.GothamMedium
    selectedText.TextSize = 15
    selectedText.TextColor3 = UILib.Colors.TEXT_SECONDARY
    selectedText.TextXAlignment = Enum.TextXAlignment.Center
    selectedText.TextTransparency = 0
    
    -- Arrow indicator
    local arrow = Instance.new("TextLabel", dropdownBtn)
    arrow.Size = UDim2.fromOffset(30, 45)
    arrow.Position = UDim2.new(1, -35, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 12
    arrow.TextColor3 = UILib.Colors.JPUFF_PINK
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.TextTransparency = 0
    
    -- Options container (hidden by default)
    local optionsContainer = Instance.new("Frame", panel.ScrollingFrame)
    optionsContainer.Size = UDim2.new(1, -60, 0, 0)
    optionsContainer.Position = UDim2.fromOffset(30, y + 75)
    optionsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    optionsContainer.BorderSizePixel = 0
    optionsContainer.Visible = false
    optionsContainer.ClipsDescendants = true
    optionsContainer.ZIndex = 100
    Instance.new("UICorner", optionsContainer).CornerRadius = UDim.new(0, 12)
    
    local optionsStroke = Instance.new("UIStroke", optionsContainer)
    optionsStroke.Color = UILib.Colors.JPUFF_PINK
    optionsStroke.Transparency = 0.6
    
    -- Search textbox (at top of dropdown)
    local searchBox = nil
    local searchOffset = 0
    
    if enableSearch then
        searchBox = Instance.new("TextBox", optionsContainer)
        searchBox.Size = UDim2.new(1, -20, 0, 35)
        searchBox.Position = UDim2.fromOffset(10, 5)
        searchBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        searchBox.Text = ""
        searchBox.PlaceholderText = "Search..."
        searchBox.Font = Enum.Font.GothamMedium
        searchBox.TextSize = 14
        searchBox.TextColor3 = UILib.Colors.TEXT_PRIMARY
        searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
        searchBox.BorderSizePixel = 0
        searchBox.BackgroundTransparency = 0.3
        searchBox.TextXAlignment = Enum.TextXAlignment.Left
        searchBox.ClearTextOnFocus = false
        searchBox.ZIndex = 101
        Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8)
        
        local searchStroke = Instance.new("UIStroke", searchBox)
        searchStroke.Color = UILib.Colors.JPUFF_PINK
        searchStroke.Transparency = 0.8
        searchStroke.Thickness = 1
        
        searchOffset = 45 -- Offset for options below search
    end
    
    -- Scrolling frame for options
    local scrollFrame = Instance.new("ScrollingFrame", optionsContainer)
    scrollFrame.Size = UDim2.new(1, 0, 1, -searchOffset)
    scrollFrame.Position = UDim2.fromOffset(0, searchOffset)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = UILib.Colors.JPUFF_PINK
    scrollFrame.ZIndex = 101
    
    local listLayout = Instance.new("UIListLayout", scrollFrame)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local isOpen = false
    local selectedOption = nil
    local optionButtons = {}
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local optionBtn = Instance.new("TextButton", scrollFrame)
        optionBtn.Size = UDim2.new(1, -10, 0, 40)
        optionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        optionBtn.Text = option
        optionBtn.Font = Enum.Font.GothamMedium
        optionBtn.TextSize = 14
        optionBtn.TextColor3 = UILib.Colors.TEXT_PRIMARY
        optionBtn.BorderSizePixel = 0
        optionBtn.BackgroundTransparency = 0.3
        optionBtn.ZIndex = 102
        Instance.new("UICorner", optionBtn).CornerRadius = UDim.new(0, 8)
        
        optionButtons[option] = optionBtn
        
        -- Hover effect
        optionBtn.MouseEnter:Connect(function()
            TweenService:Create(optionBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                BackgroundTransparency = 0
            }):Play()
end)
        
        optionBtn.MouseLeave:Connect(function()
            TweenService:Create(optionBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                BackgroundTransparency = 0.3
            }):Play()
        end)
        
        -- Click handler
        optionBtn.MouseButton1Click:Connect(function()
            selectedOption = option
            selectedText.Text = option
            selectedText.TextColor3 = UILib.Colors.TEXT_PRIMARY
            
            -- Close dropdown
            isOpen = false
            TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
            TweenService:Create(optionsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(1, -60, 0, 0)
            }):Play()
            
            task.delay(0.3, function()
                optionsContainer.Visible = false
            end)
            
            -- Execute callback
            callback(option)
        end)
    end
    
    -- Search filtering
    if searchBox then
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local searchText = searchBox.Text:lower()
            local visibleCount = 0
            
            for option, btn in pairs(optionButtons) do
                if searchText == "" or option:lower():find(searchText, 1, true) then
                    btn.Visible = true
                    visibleCount = visibleCount + 1
                else
                    btn.Visible = false
                end
            end
            
            -- Update canvas size based on visible options
            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
        end)
    end
    
    -- Update scroll canvas size
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    
    -- Toggle dropdown
    dropdownBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            optionsContainer.Visible = true
            local maxHeight = math.min(#options * 42 + searchOffset, 350 + searchOffset)
            
            -- FIX FOR MOBILE/CLIPPING: Ensure CanvasSize is large enough to show the dropdown
            -- If dropdown extends beyond current canvas, extend canvas
            local dropdownBottom = y + 75 + maxHeight
            local currentCanvas = panel.ScrollingFrame.CanvasSize.Y.Offset
            if dropdownBottom > currentCanvas then
                panel.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, dropdownBottom + 20)
            end
            
            TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = 180}):Play()
            TweenService:Create(optionsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -60, 0, maxHeight)
            }):Play()
            
            -- Focus search box when opened
            if searchBox then
                task.wait(0.1)
                searchBox:CaptureFocus()
            end
        else
            TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
            TweenService:Create(optionsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(1, -60, 0, 0)
            }):Play()
            
            task.delay(0.3, function()
                optionsContainer.Visible = false
                -- Restore canvas size when closed
                panel:UpdateCanvasSize()
            end)
            
            -- Clear search when closed
            if searchBox then
                searchBox.Text = ""
            end
        end
    end)
    
    panel.ContentY = panel.ContentY + 80
    panel:UpdateCanvasSize()
    
    return {
        SetValue = function(value)
            selectedOption = value
            selectedText.Text = value
            selectedText.TextColor3 = UILib.Colors.TEXT_PRIMARY
        end,
        GetValue = function()
            return selectedOption
        end,
        UpdateOptions = function(newOptions)
            -- Clear old option buttons
            for _, btn in pairs(optionButtons) do
                btn:Destroy()
            end
            optionButtons = {}
            
            -- Create new option buttons
            for i, option in ipairs(newOptions) do
                local optionBtn = Instance.new("TextButton", scrollFrame)
                optionBtn.Size = UDim2.new(1, -10, 0, 40)
                optionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                optionBtn.Text = option
                optionBtn.Font = Enum.Font.GothamMedium
                optionBtn.TextSize = 14
                optionBtn.TextColor3 = UILib.Colors.TEXT_PRIMARY
                optionBtn.BorderSizePixel = 0
                optionBtn.BackgroundTransparency = 0.3
                optionBtn.ZIndex = 102
                Instance.new("UICorner", optionBtn).CornerRadius = UDim.new(0, 8)
                
                optionButtons[option] = optionBtn
                
                -- Hover effect
                optionBtn.MouseEnter:Connect(function()
                    TweenService:Create(optionBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                        BackgroundTransparency = 0
                    }):Play()
                end)
                
                optionBtn.MouseLeave:Connect(function()
                    TweenService:Create(optionBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                        BackgroundTransparency = 0.3
                    }):Play()
                end)
                
                -- Click handler
                optionBtn.MouseButton1Click:Connect(function()
                    selectedOption = option
                    selectedText.Text = option
                    selectedText.TextColor3 = UILib.Colors.TEXT_PRIMARY
                    
                    -- Close dropdown
                    isOpen = false
                    TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                    TweenService:Create(optionsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        Size = UDim2.new(1, -60, 0, 0)
                    }):Play()
                    
                    task.delay(0.3, function()
                        optionsContainer.Visible = false
                    end)
                    
                    -- Execute callback
                    callback(option)
                end)
            end
            
            -- Update scroll canvas size
            task.wait(0.05) -- Wait for layout to update
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
            
            -- Reset selected text if current selection is no longer in options
            if selectedOption then
                local found = false
                for _, opt in ipairs(newOptions) do
                    if opt == selectedOption then
                        found = true
                        break
                    end
                end
                if not found then
                    selectedOption = nil
                    selectedText.Text = "Select..."
                    selectedText.TextColor3 = UILib.Colors.TEXT_SECONDARY
                end
            end
        end
    }
end

-- =====================================================
-- KEYBIND
-- =====================================================
function UILib:CreateKeybind(panel, config)
    config = config or {}
    local actionName = config.ActionName or "Action"
    local defaultKey = config.DefaultKey or nil
    local callback = config.Callback or function() end
    local y = panel.ContentY
    
    -- Start the global listener if not already started
    self:StartKeybindListener()
    
    -- Load saved keybinds
    local savedKeybinds = self:LoadKeybinds()
    local savedKey = savedKeybinds[actionName]
    if savedKey then
        -- Convert string back to KeyCode
        local keyCodeStr = savedKey:gsub("Enum.KeyCode.", "")
        defaultKey = Enum.KeyCode[keyCodeStr]
    end
    
    -- Register keybind
    self.Keybinds[actionName] = {
        Key = defaultKey,
        Callback = callback
    }
    
    -- Container for the keybind row (pink background with rounded corners)
    local container = Instance.new("Frame", panel.ScrollingFrame)
    container.Size = UDim2.new(1, -20, 0, 35)
    container.Position = UDim2.fromOffset(10, y)
    container.BackgroundColor3 = self.Colors.JPUFF_PINK
    container.BackgroundTransparency = 0.85 -- Slightly transparent pink
    container.BorderSizePixel = 0
    
    -- Rounded corners
    local corner = Instance.new("UICorner", container)
    corner.CornerRadius = UDim.new(0, 8)
    
    -- Dark pink outline
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = self.Colors.JPUFF_DARK_PINK
    stroke.Thickness = 2
    
    -- Action name label (left side)
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.fromOffset(20, 0)
    label.BackgroundColor3 = self.Colors.BG_DARK
    label.BackgroundTransparency = 1
    label.Text = actionName
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 15
    label.TextColor3 = self.Colors.TEXT_PRIMARY
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    
    -- Keybind display (right side) - Simple text like panel selector
    local keybindText = Instance.new("TextLabel", container)
    keybindText.Size = UDim2.fromOffset(60, 35)
    keybindText.Position = UDim2.new(1, -70, 0, 0)
    keybindText.BackgroundColor3 = self.Colors.BG_DARK
    keybindText.BackgroundTransparency = 1
    keybindText.Text = self:GetKeyName(defaultKey)
    keybindText.Font = Enum.Font.GothamBold
    keybindText.TextSize = 14
    keybindText.TextColor3 = self.Colors.TEXT_SECONDARY
    keybindText.TextXAlignment = Enum.TextXAlignment.Right
    keybindText.TextYAlignment = Enum.TextYAlignment.Center
    
    -- Invisible button for clicking
    local clickBtn = Instance.new("TextButton", container)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundColor3 = self.Colors.BG_DARK
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 2
    
    -- Hover effect
    local listening = false
    clickBtn.MouseEnter:Connect(function()
        if not listening then
            keybindText.TextColor3 = self.Colors.JPUFF_HOT_PINK
        end
    end)
    
    clickBtn.MouseLeave:Connect(function()
        if not listening then
            keybindText.TextColor3 = self.Colors.TEXT_SECONDARY
        end
    end)
    
    -- Click to rebind
    clickBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        self.ListeningForKeybind = true -- Disable global keybind listener
        keybindText.Text = "..."
        keybindText.TextColor3 = self.Colors.JPUFF_PINK
        
        -- Small delay to ensure flag is set before accepting input
        task.wait(0.1)
        
        -- Wait for key press
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            
            connection:Disconnect()
            listening = false
            self.ListeningForKeybind = false -- Re-enable global keybind listener
            
            -- ESC = unbind
            if input.KeyCode == Enum.KeyCode.Escape then
                self.Keybinds[actionName].Key = nil
                keybindText.Text = "None"
                keybindText.TextColor3 = self.Colors.TEXT_SECONDARY
                self:SaveKeybinds() -- Save after unbind
            else
                -- Set new key (DO NOT trigger callback here!)
                self.Keybinds[actionName].Key = input.KeyCode
                keybindText.Text = self:GetKeyName(input.KeyCode)
                keybindText.TextColor3 = self.Colors.TEXT_SECONDARY
                self:SaveKeybinds() -- Save after binding
            end
        end)
    end)
    
    panel.ContentY = panel.ContentY + 40
    panel:UpdateCanvasSize()
    
    return {
        SetKey = function(keyCode)
            self.Keybinds[actionName].Key = keyCode
            keybindText.Text = self:GetKeyName(keyCode)
        end,
        GetKey = function()
            return self.Keybinds[actionName].Key
        end,
        Remove = function()
            self.Keybinds[actionName] = nil
            container:Destroy()
        end
    }
end

-- =====================================================
-- NOTIFICATION
-- =====================================================
function UILib:CreateNotification(config)
    config = config or {}
    local text = config.Text or "Notification"
    local duration = config.Duration or 3
    local color = config.Color or UILib.Colors.SUCCESS

    local notif = Instance.new("ScreenGui", gui)
    notif.Name = "UILibNotification"
    notif.ResetOnSpawn = false
    notif.DisplayOrder = 200

    local frame = Instance.new("Frame", notif)
    frame.Size = UDim2.new(0, 300, 0, 80)
    frame.Position = UDim2.new(1, -320, 0, 20)
    frame.BackgroundColor3 = UILib.Colors.BG_DARK
    frame.BackgroundTransparency = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = color
    stroke.Thickness = 2

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.fromOffset(10, 10)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = UILib.Colors.TEXT_PRIMARY
    label.TextWrapped = true
    label.TextYAlignment = Enum.TextYAlignment.Center

    -- Slide in
    frame.Position = UDim2.new(1, 0, 0, 20)
    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
        {Position = UDim2.new(1, -320, 0, 20)}):Play()

    -- Slide out and destroy
    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 
            {Position = UDim2.new(1, 0, 0, 20)}):Play()
        task.wait(0.3)
        notif:Destroy()
    end)

    return notif
end

-- =====================================================
-- TOGGLE GUI VISIBILITY (RIGHT SHIFT)
-- =====================================================
function UILib:AddToggleKey(window, keyCode)
    keyCode = keyCode or Enum.KeyCode.RightShift
    local guiVisible = true

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == keyCode then
            guiVisible = not guiVisible
            if guiVisible then
                window.ScreenGui.Enabled = true
                TweenService:Create(window.SelectorFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
                if window.CurrentPanel then
                    local panel = window.Panels[window.CurrentPanel]
                    if panel then
                        panel.Frame.Visible = true
                        TweenService:Create(panel.Frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
                    end
                end
            else
                TweenService:Create(window.SelectorFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                if window.CurrentPanel then
                    local panel = window.Panels[window.CurrentPanel]
                    if panel then
                        TweenService:Create(panel.Frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                    end
                end
                task.wait(0.3)
                window.ScreenGui.Enabled = false
            end
        end
    end)
end



-- =====================================================
-- 20. UNIVERSAL ESP MODULE
-- =====================================================
UILib.ESP = {
    Config = {
        Enabled = false,
        
        -- Player ESP
        PlayerESP = false,
        ShowName = true,
        ShowRole = true, -- Or Team
        ShowHealth = true,
        ShowItems = false,
        ShowDistance = false,
        ShowTracers = false,
        UseTeamColors = true,
        
        -- Item ESP
        ItemESP = false,
        ItemDistance = 150,
        ShowItemName = true,
        ShowItemDistance = true,
        
        -- Colors
        EnemyColor = Color3.fromRGB(255, 0, 0),
        AllyColor = Color3.fromRGB(0, 255, 0),
        ItemColor = Color3.fromRGB(255, 255, 0),
        
        -- Performance
        UpdateRate = 0.05 -- Seconds between heavy updates
    },
    
    -- Runtime Storage
    Cache = {
        Players = {}, -- [player] = {Highlight, Billboard, Labels...}
        Items = {},   -- [part] = {Highlight, Billboard}
    },
    Connections = {},
    IsRunning = false
}

-- Helper: Get Player Team Color or default
function UILib.ESP:GetTeamColor(player)
    if not player then return Color3.fromRGB(255, 255, 255) end
    if self.Config.UseTeamColors and player.Team then
        return player.Team.TeamColor.Color
    end
    return self.Config.EnemyColor -- Default fallback
end

-- Helper: Get Health Color
function UILib.ESP:GetHealthColor(health, maxHealth)
    local hpPercent = health / maxHealth
    if hpPercent > 0.6 then return Color3.fromRGB(0, 255, 0)
    elseif hpPercent > 0.3 then return Color3.fromRGB(255, 165, 0)
    else return Color3.fromRGB(255, 0, 0) end
end

-- Create Player ESP Objects
function UILib.ESP:AddPlayer(player)
    if self.Cache.Players[player] then return end
    if player == Players.LocalPlayer then return end
    
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not root then return end
    
    -- 1. Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "UILIB_ESP_Highlight"
    highlight.Adornee = char
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = self:GetTeamColor(player)
    highlight.Enabled = self.Config.PlayerESP
    highlight.Parent = char

    -- 2. BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "UILIB_ESP_Info"
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 200, 0, 70) 
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = self.Config.PlayerESP
    billboard.Parent = char
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = billboard
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    
    -- Label Creator Helper
    local function createLabel(order, color, fontSize)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, fontSize + 2)
        label.BackgroundTransparency = 1
        label.TextColor3 = color
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.Font = Enum.Font.RobotoMono
        label.TextSize = fontSize
        label.LayoutOrder = order
        label.Parent = billboard
        label.Text = ""
        label.Visible = false
        return label
    end

    local teamLabel = createLabel(1, Color3.new(1,1,1), 11)   -- Role
    local nameLabel = createLabel(2, Color3.new(1,1,1), 13)   -- Name
    local healthLabel = createLabel(3, Color3.new(0,1,0), 11) -- Health
    local distLabel = createLabel(4, Color3.new(1,1,1), 10)   -- Distance
    local itemLabel = createLabel(5, Color3.new(1,1,0), 10)   -- Item

    self.Cache.Players[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Labels = {
            Team = teamLabel,
            Name = nameLabel,
            Health = healthLabel,
            Distance = distLabel,
            Item = itemLabel
        },
        Character = char
    }
end

function UILib.ESP:RemovePlayer(player)
    local data = self.Cache.Players[player]
    if data then
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        self.Cache.Players[player] = nil
    end
end

-- Item ESP Implementation
function UILib.ESP:ScanItems()
    if not self.Config.ItemESP then 
        -- Cleanup if disabled
        for item, data in pairs(self.Cache.Items) do
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
            self.Cache.Items[item] = nil
        end
        return 
    end

    local myChar = Players.LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    -- Scan Workspace for dropped tools or handles
    -- Note: This is a simple generic scan. For specific games, you might target specific folders.
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
            -- Check Distance
            local handle = obj.Handle
            local dist = (handle.Position - myRoot.Position).Magnitude
            
            if dist <= self.Config.ItemDistance then
                -- Add ESP if not exists
                if not self.Cache.Items[obj] then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_ItemHighlight"
                    highlight.Adornee = handle
                    highlight.FillColor = self.Config.ItemColor
                    highlight.OutlineColor = self.Config.ItemColor
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = handle
                    
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "ESP_ItemInfo"
                    bb.Adornee = handle
                    bb.Size = UDim2.new(0, 100, 0, 30)
                    bb.StudsOffset = Vector3.new(0, 2, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = handle
                    
                    local txt = Instance.new("TextLabel", bb)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = self.Config.ItemColor
                    txt.TextStrokeTransparency = 0
                    txt.Text = obj.Name
                    txt.TextSize = 12
                    txt.Font = Enum.Font.RobotoMono
                    
                    self.Cache.Items[obj] = {
                        Highlight = highlight,
                        Billboard = bb,
                        Text = txt
                    }
                end
            else
                -- Remove if out of range
                if self.Cache.Items[obj] then
                    self.Cache.Items[obj].Highlight:Destroy()
                    self.Cache.Items[obj].Billboard:Destroy()
                    self.Cache.Items[obj] = nil
                end
            end
        end
    end
end

-- Main Update Loop
function UILib.ESP:Update()
    if not self.Config.Enabled then return end
    
    -- Update Players
    for player, data in pairs(self.Cache.Players) do
        if not player.Parent then
            self:RemovePlayer(player) -- Player left
        elseif not data.Character or not data.Character.Parent then
             -- Character respawned or deleted
             self:RemovePlayer(player)
             if player.Character then self:AddPlayer(player) end -- Re-add
        else
            -- Check visibility
            if not self.Config.PlayerESP then
                data.Highlight.Enabled = false
                data.Billboard.Enabled = false
            else
                local hum = data.Character:FindFirstChild("Humanoid")
                local root = data.Character:FindFirstChild("HumanoidRootPart")
                
                if hum and root then
                    data.Highlight.Enabled = true
                    data.Billboard.Enabled = true
                    
                    -- Color Update
                    data.Highlight.FillColor = self:GetTeamColor(player)
                    
                    -- Text Updates
                    local labels = data.Labels
                    
                    -- Role/Team
                    if self.Config.ShowRole then
                        labels.Team.Visible = true
                        labels.Team.Text = (player.Team and player.Team.Name) or "No Team"
                        labels.Team.TextColor3 = self:GetTeamColor(player)
                    else
                        labels.Team.Visible = false
                    end
                    
                    -- Name
                    if self.Config.ShowName then
                        labels.Name.Visible = true
                        labels.Name.Text = player.Name
                    else
                        labels.Name.Visible = false
                    end
                    
                    -- Health
                    if self.Config.ShowHealth then
                        local hp = math.floor(hum.Health)
                        local max = math.floor(hum.MaxHealth)
                        labels.Health.Visible = true
                        labels.Health.Text = string.format("HP: %d/%d", hp, max)
                        labels.Health.TextColor3 = self:GetHealthColor(hum.Health, hum.MaxHealth)
                    else
                        labels.Health.Visible = false
                    end
                    
                    -- Item (Equipped)
                    if self.Config.ShowItems then
                        local tool = data.Character:FindFirstChildOfClass("Tool")
                        if tool then
                            labels.Item.Visible = true
                            labels.Item.Text = tool.Name
                        else
                            labels.Item.Visible = false
                        end
                    else
                        labels.Item.Visible = false
                    end
                    
                    -- Distance
                    if self.Config.ShowDistance and Players.LocalPlayer.Character then
                        local myRoot = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            local dist = (root.Position - myRoot.Position).Magnitude
                            labels.Distance.Visible = true
                            labels.Distance.Text = string.format("[%d]", math.floor(dist))
                        else
                            labels.Distance.Visible = false
                        end
                    else
                        labels.Distance.Visible = false
                    end
                else
                    -- Hide if dead/incomplete
                    data.Highlight.Enabled = false
                    data.Billboard.Enabled = false
                end
            end
        end
    end
    
    -- Update Items (Throttled?)
    -- Ideally, don't run this every frame unless needed. 
    -- For this simple implementation, we'll run it but rely on the cache.
    -- self:ScanItems() -- Call this from a slower loop
end

-- Toggle ESP System
function UILib.ESP:Toggle(state)
    self.Config.Enabled = state
    self.IsRunning = state
    
    if state then
        -- Start Loop
        local RunService = game:GetService("RunService")
        self.Connections.Update = RunService.RenderStepped:Connect(function()
            self:Update()
        end)
        
        -- Slower loop for Item Scan and Player Cache Refresh
        task.spawn(function()
            while self.IsRunning do
                -- Refresh Players
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Players.LocalPlayer then
                        if not self.Cache.Players[p] and p.Character then
                            self:AddPlayer(p)
                        end
                    end
                end
                
                -- Refresh Items
                if self.Config.ItemESP then
                    self:ScanItems()
                end
                
                task.wait(1)
            end
        end)
        
        -- Player Added/Removing Listeners
        self.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(c)
                task.wait(0.5) -- Wait for load
                self:AddPlayer(p)
            end)
        end)
        
        self.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(p)
            self:RemovePlayer(p)
        end)
        
        -- Initial Add
        for _, p in ipairs(Players:GetPlayers()) do
            self:AddPlayer(p)
        end
        
    else
        -- Cleanup
        for _, conn in pairs(self.Connections) do
            conn:Disconnect()
        end
        self.Connections = {}
        
        -- Clear Visuals
        for p, _ in pairs(self.Cache.Players) do
            self:RemovePlayer(p)
        end
        for i, data in pairs(self.Cache.Items) do
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
        end
        self.Cache.Items = {}
    end
end

return UILib

