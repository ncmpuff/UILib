-- CLICK TO TELEPORT (with Void Bypass)
-- Click on any part to teleport to it safely

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local RunService = game:GetService("RunService")

print("═══════════════════════════════════════════════════════")
print("         CLICK TO TELEPORT - ACTIVATED")
print("═══════════════════════════════════════════════════════")
print("")
print("📌 Click on any part to teleport to it")
print("🛡️ Void bypass active")
print("")

-- Get character
local function getChar()
    return player.Character
end

local function getRoot()
    local char = getChar()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

-- VOID BYPASS: Prevent falling below threshold
local MIN_Y_POSITION = -400
local voidBypass = RunService.Heartbeat:Connect(function()
    local hrp = getRoot()
    if hrp and hrp.Parent then
        local currentPos = hrp.Position
        if currentPos.Y < MIN_Y_POSITION then
            -- Teleport back up
            hrp.CFrame = CFrame.new(currentPos.X, MIN_Y_POSITION + 50, currentPos.Z)
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            if hrp.AssemblyLinearVelocity then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
            if hrp.AssemblyAngularVelocity then
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
            warn("⚠️ Void protection triggered!")
        end
    end
end)

-- Safe teleport function with velocity control
local function safeTeleport(targetPosition)
    local hrp = getRoot()
    if not hrp then 
        warn("❌ No HumanoidRootPart found!")
        return 
    end
    
    -- Disable all velocity
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.RotVelocity = Vector3.new(0, 0, 0)
    if hrp.AssemblyLinearVelocity then
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
    if hrp.AssemblyAngularVelocity then
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
    
    -- Teleport
    hrp.CFrame = CFrame.new(targetPosition)
    
    -- Keep velocity disabled for a moment
    task.wait(0.1)
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.RotVelocity = Vector3.new(0, 0, 0)
end

-- Click to teleport
mouse.Button1Down:Connect(function()
    local target = mouse.Target
    
    if target and target:IsA("BasePart") then
        local targetPos = target.Position + Vector3.new(0, 5, 0) -- Teleport 5 studs above
        
        print("📍 Teleporting to:", target.Name)
        print("   Position:", targetPos)
        
        safeTeleport(targetPos)
        
        print("✅ Teleported!")
        print("")
    else
        warn("❌ No valid part clicked!")
    end
end)

print("✅ Click-to-teleport ready!")
print("🖱️ Left-click on any part to teleport")
print("")
print("Note: Script will keep running until you stop it")
