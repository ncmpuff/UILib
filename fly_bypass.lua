-- ADVANCED FLY BYPASS
-- - Periodic ground touches every 1.5s to reset anti-cheat
-- - Variable speed (average → fast → average) to avoid detection
-- Controls: F = Fly, E = Noclip, WASD + Space/Shift

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

print("═══════════════════════════════════════════════════════")
print("       ADVANCED FLY BYPASS")
print("═══════════════════════════════════════════════════════")
print("")
print("Controls:")
print("  F - Toggle fly on/off")
print("  E - Toggle noclip on/off")
print("  W/A/S/D - Move")
print("  Space - Up")
print("  Shift - Down")
print("")
print("ℹ️  Anti-cheat bypasses:")
print("   - Touches ground every 1.5s")
print("   - Variable speed pattern")
print("")

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
                warn("⚠️ Void protection triggered!")
            end
        end
    end)
end

-- Start noclip
local function startNoclip()
    if noclipping then return end
    noclipping = true
    
    print("✅ Noclip enabled!")
    
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
    
    print("❌ Noclip disabled!")
    
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
        local spawnWaitTime = aboveGround and 0.5 or 6.0  -- 6s over void (3x longer), 0.5s over ground
        
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
        print(string.format("🔄 Spawn reset (%.1fs) [%s - waited %.1fs]", timeSinceStart, groundStatus, spawnWaitTime))
    end
end

-- Start flying
local function startFly()
    if flying then return end
    flying = true
    
    local hrp = getRoot()
    if not hrp then 
        warn("❌ Character not found!")
        return 
    end
    
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
    
    print("✅ Fly enabled!")
    print("ℹ️  New system: Body stays at spawn, teleports to camera when shooting")
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
        
        -- Continuously enforce mouse lock (in case user unlocks it)
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        
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
        if keys.w then
            direction = direction + (cam.CFrame.LookVector * currentSpeed)
        end
        if keys.s then
            direction = direction - (cam.CFrame.LookVector * currentSpeed)
        end
        if keys.a then
            direction = direction - (cam.CFrame.RightVector * currentSpeed)
        end
        if keys.d then
            direction = direction + (cam.CFrame.RightVector * currentSpeed)
        end
        if keys.space then
            direction = direction + (Vector3.new(0, 1, 0) * currentSpeed)
        end
        if keys.shift then
            direction = direction - (Vector3.new(0, 1, 0) * currentSpeed)
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
    
    print("❌ Fly disabled!")
    
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
        isShooting = true
        print("🔫 Shooting - body teleporting to camera")
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
        bodyAtSpawn = false
        print("✋ Stopped shooting - body returning to spawn")
    end
end)

-- Character respawn handling
player.CharacterAdded:Connect(function()
    task.wait(1)
    if flying then
        stopFly()
        print("⚠️ Respawned - fly disabled")
    end
    if noclipping then
        stopNoclip()
        print("⚠️ Respawned - noclip disabled")
    end
end)

print("✅ Script ready!")
print("🛡️ Void bypass active")
print("⌨️ Press V for fly, E for noclip")
print("")
