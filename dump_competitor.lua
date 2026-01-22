-- Competitor Rapid Fire Dumper
-- Run this AFTER running their obfuscated script to capture how rapid fire works

print("=== DUMPING COMPETITOR'S RAPID FIRE ===")

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-- 1. Monitor FireRate changes in real-time
print("\n[1] MONITORING FIRERATE CHANGES...")
local weaponStats = {}

task.spawn(function()
    while task.wait(0.1) do
        if player.Character then
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool and tool.Name then
                -- Search for weapon module in ReplicatedStorage
                for _, module in pairs(RS:GetDescendants()) do
                    if module:IsA("ModuleScript") and string.find(module.Name, tool.Name) then
                        local success, stats = pcall(require, module)
                        if success and type(stats) == "table" and stats.FireRate then
                            local currentRate = stats.FireRate
                            
                            -- Check if this is new or changed
                            if not weaponStats[tool.Name] or weaponStats[tool.Name] ~= currentRate then
                                print("🔥 FIRERATE CHANGED:", tool.Name, "→", currentRate)
                                weaponStats[tool.Name] = currentRate
                                
                                -- Dump entire stats table
                                print("  Full weapon stats:")
                                for k, v in pairs(stats) do
                                    if type(v) ~= "table" then
                                        print("    ", k, "=", v)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- 2. Scan for FireRate-related functions
print("\n[2] SCANNING FOR FIRERATE FUNCTIONS...")
if getgc then
    for i, v in pairs(getgc(true)) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info and info.source then
                local funcName = info.name or "anonymous"
                
                -- Look for fire-related functions
                if string.find(string.lower(funcName), "fire") or 
                   string.find(string.lower(funcName), "shoot") or
                   string.find(string.lower(funcName), "weapon") then
                    print("  ⭐ Fire-related function:", funcName)
                    print("    Source:", info.source:sub(1, 60))
                end
            end
        end
    end
end

-- 3. Check for metamethod hooks
print("\n[3] CHECKING METAMETHOD HOOKS...")
local game_meta = getrawmetatable(game)
if game_meta then
    if setreadonly then setreadonly(game_meta, false) end
    
    -- Hook __index to see what they're accessing
    local old_index = game_meta.__index
    game_meta.__index = newcclosure(function(self, key)
        if key == "FireRate" or key == "wepStats" then
            print("🔍 __index accessed:", tostring(self), ".", key)
            local caller = debug.getinfo(2)
            if caller then
                print("  Called from:", caller.source or "unknown")
            end
        end
        return old_index(self, key)
    end)
    
    -- Hook __newindex to see what they're setting
    local old_newindex = game_meta.__newindex
    game_meta.__newindex = newcclosure(function(self, key, value)
        if key == "FireRate" then
            print("✏️ __newindex SET:", tostring(self), ".", key, "=", value)
            local caller = debug.getinfo(2)
            if caller then
                print("  Called from:", caller.source or "unknown")
            end
        end
        return old_newindex(self, key, value)
    end)
    
    print("  ✅ Metamethod hooks installed!")
end

-- 4. Monitor for hookfunc/hookmetamethod usage
print("\n[4] CHECKING IF THEY HOOKED FUNCTIONS...")
if hookfunc and debug.getupvalues then
    print("  Scanning hooked functions...")
    -- This is tricky, but we can check if common functions have been hooked
    local checklist = {
        ["require"] = require,
        ["rawget"] = rawget,
        ["rawset"] = rawset,
    }
    
    for name, func in pairs(checklist) do
        local info = debug.getinfo(func)
        if info and info.what ~= "C" then
            print("  ⚠️", name, "appears to be hooked! Type:", info.what)
        end
    end
end

-- 5. Instructions for user
print("\n[5] ====== NEXT STEPS ======")
print("  1️⃣ Now ENABLE their rapid fire")
print("  2️⃣ EQUIP A WEAPON")
print("  3️⃣ Watch the console for FireRate changes and hooks")
print("  4️⃣ Try switching weapons to see if it re-applies")
print("  5️⃣ Send me the console output!")
print("\n✅ Monitoring... Keep this running and test their script!")
