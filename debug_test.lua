-- SIMPLE DEBUG TEST - Shows which element you're clicking

print("\n=== DEBUG TEST - Loading local UILIB ===")

local UILib = loadstring(readfile([[C:\Users\lezpr\Desktop\scripts\Game Scripts\Retro Breach\UILIB.lua]]))()

print("✅ Loaded local UILIB with debug warnings")

local Window = UILib:CreateWindow({
    Title = "Debug Test",
    Name = "DebugTest",
    AccentColor = Color3.fromRGB(255, 105, 180)
})

Window:AddToggleKey(Enum.KeyCode.RightShift)

local TestPanel = UILib:CreatePanel(Window, {
    Name = "Test",
    DisplayName = "CLICK THE TOGGLE SWITCH (not the arrow)"
})

warn("\n=====================================")
warn("📍 INSTRUCTIONS:")
warn("1. Click the TOGGLE SWITCH (pink slider) to see toggle debug")
warn("2. Click the ARROW (▶) to see arrow debug")
warn("3. The double icon bug happens on the SWITCH, not the arrow")
warn("=====================================\n")

-- Create a collapsible toggle
UILib:CreateCollapsibleToggle(TestPanel, {
    Label = "Test Toggle",
    Default = false,
    Callback = function(value)
        warn(string.format("💥 CALLBACK: Toggle is now %s", tostring(value)))
    end,
    SubToggles = {
        {
            Label = "Sub Option 1",
            Default = false,
            Callback = function(value)
                warn(string.format("  📌 Sub Option 1: %s", tostring(value)))
            end
        }
    }
})

print("\n✅ Test loaded! Press RightShift to open")
print("Then click the PINK TOGGLE SWITCH (not the arrow) to see debug output")
