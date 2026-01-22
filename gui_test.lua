-- GUI Test Script - Testing UILIB Collapsible Toggles
-- Loading from GitHub with cache-busting

print("=== UILIB Loading from GitHub ===")

local repo = "https://raw.githubusercontent.com/ncmpuff/UILib/main/"
math.randomseed(tick())
local cacheBuster = math.random(1000000, 9999999)

local UILib = loadstring(game:HttpGet(repo .. "UILIB.lua?v=" .. cacheBuster))()

print(string.format("  ✅ Loaded from GitHub (v=%d)", cacheBuster))

if not UILib then
    error("❌ Failed to load UILib from any source!")
end

-- Check if CreateCollapsibleToggle exists
if UILib.CreateCollapsibleToggle then
    print("✅ CreateCollapsibleToggle method is available!")
else
    warn("⚠️ CreateCollapsibleToggle method NOT FOUND!")
    warn("   The collapsible toggles will not work!")
end

print("===================\n")

-- Create Window
local Window = UILib:CreateWindow({
    Title = "GUI Test",
    Name = "GUITest",
    AccentColor = Color3.fromRGB(255, 105, 180)
})

Window:AddToggleKey(Enum.KeyCode.RightShift)

-- Test Config
local Config = {
    SilentAim = false,
    SilentAimWallCheck = true,
    SilentAimIgnoreAlly = true,
    
    Aimbot = false,
    AimbotWallCheck = true,
    AimbotIgnoreAlly = true,
    
    TestToggle = false,
    TestSlider = 50,
    TestKeybind = Enum.KeyCode.F
}

-- Create Test Panel
local TestPanel = UILib:CreatePanel(Window, {
    Name = "Test",
    DisplayName = "Test Panel"
})

-- Only create collapsible toggles if the method exists
if UILib.CreateCollapsibleToggle then
    print("Creating collapsible toggles using native UILib method...")
    
    UILib:CreateCollapsibleToggle(TestPanel, {
        Label = "Silent Aim",
        Default = Config.SilentAim,
        Callback = function(value)
            Config.SilentAim = value
            print("Silent Aim:", value)
        end,
        SubToggles = {
            {
                Label = "Wall Check",
                Default = Config.SilentAimWallCheck,
                Callback = function(value)
                    Config.SilentAimWallCheck = value
                    print("Silent Aim Wall Check:", value)
                end
            },
            {
                Label = "Ignore Ally",
                Default = Config.SilentAimIgnoreAlly,
                Callback = function(value)
                    Config.SilentAimIgnoreAlly = value  
                    print("Silent Aim Ignore Ally:", value)
                end
            }
        }
    })

    UILib:CreateCollapsibleToggle(TestPanel, {
        Label = "Aimbot",
        Default = Config.Aimbot,
        Callback = function(value)
            Config.Aimbot = value
            print("Aimbot:", value)
        end,
        SubToggles = {
            {
                Label = "Wall Check",
                Default = Config.AimbotWallCheck,
                Callback = function(value)
                    Config.AimbotWallCheck = value
                    print("Aimbot Wall Check:", value)
                end
            },
            {
                Label = "Ignore Ally",
                Default = Config.AimbotIgnoreAlly,
                Callback = function(value)
                    Config.AimbotIgnoreAlly = value
                    print("Aimbot Ignore Ally:", value)
                end
            }
        }
    })
    
    print("✓ Collapsible toggles created!")
else
    warn("⚠️ Falling back to regular toggles...")
    
    -- Create regular toggles as fallback
    UILib:CreateToggle(TestPanel, {
        Label = "Silent Aim",
        Default = Config.SilentAim,
        Callback = function(value)
            Config.SilentAim = value
            print("Silent Aim:", value)
        end
    })
    
    UILib:CreateToggle(TestPanel, {
        Label = "Aimbot",
        Default = Config.Aimbot,
        Callback = function(value)
            Config.Aimbot = value
            print("Aimbot:", value)
        end
    })
end

-- Regular toggle
UILib:CreateToggle(TestPanel, {
    Label = "Regular Toggle",
    Default = Config.TestToggle,
    Callback = function(value)
        Config.TestToggle = value
        print("Regular Toggle:", value)
    end
})

-- Test Slider
UILib:CreateSlider(TestPanel, {
    Label = "Test Slider",
    Min = 0,
    Max = 100,
    Default = Config.TestSlider,
    Callback = function(value)
        Config.TestSlider = value
        print("Test Slider:", value)
    end
})

-- Test Keybind
UILib:CreateKeybind(TestPanel, {
    Label = "Test Keybind",
    Default = Config.TestKeybind,
    Callback = function()
        print("Test Keybind pressed!")
    end
})

-- Test Button
UILib:CreateButton(TestPanel, {
    Text = "Test Button",
    Callback = function()
        print("Button clicked!")
    end
})

print("\n✅ GUI Test loaded successfully!")
print("Press RightShift to toggle UI")
if UILib.CreateCollapsibleToggle then
    print("Click the pink arrows (▶) to expand/collapse sub-toggles!")
end
