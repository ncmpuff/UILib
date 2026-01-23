-- FIRE FUNCTION HOOK DUMPER
-- Captures how they make rapid fire by hooking the actual fire functions

print("═══════════════════════════════════════════════════════")
print("        FIRE FUNCTION HOOK ANALYSIS")
print("═══════════════════════════════════════════════════════")
print("")

local player = game.Players.LocalPlayer
local hooked = false

-- Wait for character to load
repeat task.wait() until player.Character

print("✅ Character loaded, scanning for WeaponSystem...")

-- Find WeaponSystem in character
task.spawn(function()
    while task.wait(0.5) do
        if player.Character then
            local weaponSystem = player.Character:FindFirstChild("WeaponSystem")
            if weaponSystem and not hooked then
                hooked = true
                print("🎯 Found WeaponSystem!")
                print("")
                
                -- Dump all functions in WeaponSystem
                print("[WEAPONSYSTEM FUNCTIONS]")
                print("─────────────────────────────────────────────────────")
                
                if getgc then
                    local foundFuncs = {}
                    for _, gc in pairs(getgc(true)) do
                        if type(gc) == "function" then
                            local info = debug.getinfo(gc)
                            if info and info.source and string.find(info.source, "WeaponSystem") then
                                local name = info.name or "anonymous"
                                if not foundFuncs[name] then
                                    foundFuncs[name] = true
                                    print("📌 " .. name)
                                    
                                    -- Hook fire-related functions
                                    if (name == "call_fire" or name == "cosmetic_fire" or 
                                        string.find(string.lower(name), "fire")) and hookfunc then
                                        
                                        print("   🔗 Hooking " .. name .. "...")
                                        
                                        hookfunc(gc, function(...)
                                            print("🔥 " .. name .. " CALLED!")
                                            print("   Arguments:", ...)
                                            local caller = debug.getinfo(2)
                                            if caller then
                                                print("   Caller:", caller.source or "unknown")
                                            end
                                            return gc(...)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                else
                    print("⚠️ getgc not available")
                end
                
                print("")
                print("[ANALYSIS]")
                print("─────────────────────────────────────────────────────")
                print("Now do these steps:")
                print("1. Enable their rapid fire")
                print("2. Shoot your weapon (hold down mouse)")
                print("3. Watch which functions get called")
                print("")
                print("If you see a function called MANY TIMES per second,")
                print("that's their rapid fire implementation!")
                print("")
            end
        end
    end
end)

-- Alternative approach: Monitor firing rate by counting RemoteEvent fires
print("[MONITORING REMOTE EVENTS]")
print("─────────────────────────────────────────────────────")

local RS = game:GetService("ReplicatedStorage")
local fireCount = 0
local lastReset = tick()

task.spawn(function()
    while task.wait(0.1) do
        local currentTime = tick()
        if currentTime - lastReset >= 1 then
            if fireCount > 0 then
                print("📊 Fire rate: " .. fireCount .. " shots/second")
                if fireCount > 15 then
                    print("   ⚠️ RAPID FIRE DETECTED! Normal rate is ~5-10/sec")
                end
            end
            fireCount = 0
            lastReset = currentTime
        end
    end
end)

-- Hook fireWeapon remote
local remoteEvents = RS:WaitForChild("RemoteEvents", 5)
if remoteEvents then
    local fireWeapon = remoteEvents:FindFirstChild("fireWeapon")
    if fireWeapon and hookmetamethod then
        print("✅ Hooking fireWeapon remote...")
        
        local old_namecall
        old_namecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            
            if self == fireWeapon and method == "Fire" then
                fireCount = fireCount + 1
            end
            
            return old_namecall(self, ...)
        end)
    end
end

print("")
print("✅ All hooks installed!")
print("⏳ Now enable their rapid fire and start shooting...")
