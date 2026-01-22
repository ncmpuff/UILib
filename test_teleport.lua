-- VOID BYPASS + TELEPORT TEST
-- Prevents falling into void while testing teleports

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

print("═══════════════════════════════════════════════════════")
print("      VOID BYPASS + TELEPORT TEST")
print("═══════════════════════════════════════════════════════")
print("")

-- Wait for character
repeat task.wait() until player.Character
local character = player.Character
local hrp = character:WaitForChild("HumanoidRootPart")

print("✅ Character loaded")
print("📍 Current position:", hrp.Position)
print("")

-- VOID BYPASS: Prevent falling below -500 (typical void threshold)
local MIN_Y_POSITION = -400  -- Safe threshold before void kick
local voidBypassActive = true

local voidBypass = RunService.Heartbeat:Connect(function()
    if voidBypassActive and hrp and hrp.Parent then
        local currentPos = hrp.Position
        if currentPos.Y < MIN_Y_POSITION then
            -- Teleport back up immediately
            hrp.CFrame = CFrame.new(currentPos.X, MIN_Y_POSITION + 50, currentPos.Z)
            hrp.Velocity = Vector3.new(0, 0, 0)
            print("⚠️ Void protection triggered! Saved from Y=" .. math.floor(currentPos.Y))
        end
    end
end)

print("🛡️ Void bypass active (prevents falling below Y=" .. MIN_Y_POSITION .. ")")
print("")

-- Test direct CFrame teleport function
local function testTeleport(position, testName)
    print("🔄 Test #" .. testName)
    print("   Target position:", position)
    
    -- Direct CFrame manipulation
    hrp.CFrame = CFrame.new(position)
    hrp.Velocity = Vector3.new(0, 0, 0)
    
    -- Wait a moment
    task.wait(0.3)
    
    local endPos = hrp.Position
    local distance = (endPos - position).Magnitude
    
    if distance < 5 then
        print("   ✅ SUCCESS! Teleported to", endPos)
        print("   📏 Distance from target:", string.format("%.2f", distance), "studs")
    else
        warn("   ❌ FAILED! At", endPos)
        warn("   📏 Distance from target:", string.format("%.2f", distance), "studs")
    end
    print("")
end

print("Starting teleport tests in 3 seconds...")
print("")
task.wait(3)

-- Test 1: Teleport up
testTeleport(hrp.Position + Vector3.new(0, 50, 0), "1 - Up 50 studs")
task.wait(2)

-- Test 2: Teleport forward  
testTeleport(hrp.Position + Vector3.new(0, 0, 100), "2 - Forward 100 studs")
task.wait(2)

-- Test 3: Try teleporting DOWN (void bypass should save us)
print("🔄 Test #3 - Dangerous fall (void bypass test)")
print("   Teleporting to Y=-450 (below threshold)")
testTeleport(Vector3.new(hrp.Position.X, -450, hrp.Position.Z), "3 - Below void threshold")
task.wait(2)

-- Test 4: Teleport to spawn
local spawn = workspace:FindFirstChild("SpawnLocation")
if spawn then
    testTeleport(spawn.Position + Vector3.new(0, 5, 0), "4 - To spawn location")
else
    print("⚠️ Test 4 skipped - no spawn location found")
end

print("═══════════════════════════════════════════════════════")
print("           TEST COMPLETE")
print("═══════════════════════════════════════════════════════")
print("")
print("✅ If you weren't kicked:")
print("   - Direct teleports work!")
print("   - Void bypass works!")
print("")
print("🛡️ Void bypass still running in background")
print("   To disable: type 'voidBypassActive = false' in console")
