-- ULTIMATE COMPETITOR DUMPER
-- Captures EVERYTHING about their rapid fire implementation
-- Output saved to: dump_output.txt

local output = {}
local function log(text)
    print(text)
    table.insert(output, text)
end

log("═══════════════════════════════════════════════════════")
log("     ULTIMATE RAPID FIRE REVERSE ENGINEERING DUMP")
log("═══════════════════════════════════════════════════════")
log("")

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local capturedStats = {}
local capturedCalls = {}

-- ═══════════════════════════════════════════════════════
-- SECTION 1: CAPTURE ALL WEAPON MODULES
-- ═══════════════════════════════════════════════════════
log("[SECTION 1] WEAPON MODULES IN REPLICATEDSTORAGE")
log("─────────────────────────────────────────────────────")

for _, module in ipairs(RS:GetDescendants()) do
    if module:IsA("ModuleScript") then
        local success, stats = pcall(require, module)
        if success and type(stats) == "table" then
            -- Safely check for FireRate
            local hasFireRate = pcall(function() return stats.FireRate end)
            if hasFireRate and stats.FireRate then
                log("📦 Module: " .. module:GetFullName())
                
                -- Safely get each property
                local fireRateSuccess, fireRate = pcall(function() return stats.FireRate end)
                local fireModeSuccess, fireMode = pcall(function() return stats.FireMode end)
                local spreadSuccess, spread = pcall(function() return stats.Spread end)
                local recoilSuccess, recoilType = pcall(function() return type(stats.Recoil) end)
                
                if fireRateSuccess then log("   FireRate: " .. tostring(fireRate)) end
                if fireModeSuccess then log("   FireMode: " .. tostring(fireMode or "N/A")) end
                if spreadSuccess then log("   Spread: " .. tostring(spread or "N/A")) end
                if recoilSuccess then log("   Recoil: " .. tostring(recoilType)) end
                
                -- Store original for comparison
                if fireRateSuccess and fireRate then
                    capturedStats[module.Name] = {
                        original = fireRate,
                        module = module
                    }
                end
            end
        end
    end
end

log("")

-- ═══════════════════════════════════════════════════════
-- SECTION 2: MONITOR FIRERATE CHANGES IN REAL-TIME
-- ═══════════════════════════════════════════════════════
log("[SECTION 2] REAL-TIME FIRERATE MONITOR")
log("─────────────────────────────────────────────────────")
log("Monitoring started... Equip weapons to see changes")
log("")

task.spawn(function()
    local lastTool = nil
    while task.wait(0.05) do
        if player.Character then
            local tool = player.Character:FindFirstChildOfClass("Tool")
            
            if tool and tool ~= lastTool then
                lastTool = tool
                log("🔫 WEAPON EQUIPPED: " .. tool.Name)
                
                -- Find and monitor its stats
                for _, module in ipairs(RS:GetDescendants()) do
                    if module:IsA("ModuleScript") and string.find(module.Name, tool.Name) then
                        local success, stats = pcall(require, module)
                        if success and type(stats) == "table" then
                            local currentRate = stats.FireRate
                            local original = capturedStats[module.Name] and capturedStats[module.Name].original or currentRate
                            
                            if currentRate ~= original then
                                log("🔥 FIRERATE MODIFIED!")
                                log("   Original: " .. original)
                                log("   Modified: " .. currentRate)
                                log("   Change: " .. (currentRate - original))
                                log("   Factor: " .. string.format("%.2fx", currentRate / original))
                            else
                                log("   FireRate: " .. currentRate .. " (unchanged)")
                            end
                            
                            -- Dump ALL stats
                            log("   📊 Complete Stats Dump:")
                            for k, v in pairs(stats) do
                                if type(v) ~= "table" and type(v) ~= "function" then
                                    log("      " .. k .. " = " .. tostring(v))
                                end
                            end
                            log("")
                        end
                    end
                end
            elseif not tool and lastTool then
                lastTool = nil
                log("🔓 Weapon unequipped")
                log("")
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════
-- SECTION 3: INTERCEPT ALL METAMETHOD CALLS
-- ═══════════════════════════════════════════════════════
log("[SECTION 3] METAMETHOD HOOK INTERCEPTION")
log("─────────────────────────────────────────────────────")

local game_meta = getrawmetatable(game)
if setreadonly then setreadonly(game_meta, false) end

-- Hook __index
local old_index = game_meta.__index
game_meta.__index = newcclosure(function(self, key)
    if key == "FireRate" or key == "FireMode" or key == "wepStats" then
        local value = old_index(self, key)
        local caller = debug.getinfo(2)
        
        log("📥 __index READ: " .. tostring(key) .. " = " .. tostring(value))
        if caller and caller.source then
            log("   Source: " .. caller.source:sub(1, 80))
            log("   Line: " .. tostring(caller.currentline))
        end
        
        return value
    end
    return old_index(self, key)
end)

-- Hook __newindex
local old_newindex = game_meta.__newindex
game_meta.__newindex = newcclosure(function(self, key, value)
    if key == "FireRate" or key == "FireMode" then
        local caller = debug.getinfo(2)
        
        log("📤 __newindex WRITE: " .. tostring(key) .. " = " .. tostring(value))
        if caller and caller.source then
            log("   Source: " .. caller.source:sub(1, 80))
            log("   Line: " .. tostring(caller.currentline))
            log("   Function: " .. tostring(caller.name or "anonymous"))
        end
        
        table.insert(capturedCalls, {
            type = "newindex",
            key = key,
            value = value,
            source = caller and caller.source or "unknown",
            line = caller and caller.currentline or 0
        })
    end
    return old_newindex(self, key, value)
end)

log("✅ Metamethod hooks installed!")
log("")

-- ═══════════════════════════════════════════════════════
-- SECTION 4: SCAN FOR FIRE-RELATED FUNCTIONS
-- ═══════════════════════════════════════════════════════
log("[SECTION 4] FIRE-RELATED FUNCTION SCAN")
log("─────────────────────────────────────────────────────")

if getgc then
    local found = 0
    for i, v in pairs(getgc(true)) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info and info.name then
                local name = string.lower(info.name)
                if string.find(name, "fire") or string.find(name, "rapid") or 
                   string.find(name, "weapon") or string.find(name, "shoot") then
                    found = found + 1
                    log("🎯 Function #" .. found .. ": " .. info.name)
                    log("   Source: " .. tostring(info.source):sub(1, 80))
                    log("   What: " .. tostring(info.what))
                    log("")
                end
            end
        end
    end
    log("Found " .. found .. " fire-related functions")
else
    log("⚠️ getgc not available")
end

log("")

-- ═══════════════════════════════════════════════════════
-- SECTION 5: INSTRUCTIONS
-- ═══════════════════════════════════════════════════════
log("[SECTION 5] NEXT STEPS")
log("─────────────────────────────────────────────────────")
log("1. Enable their rapid fire in Anxiety GUI")
log("2. Equip different weapons")
log("3. Wait 10 seconds")
log("4. Press F9 to see this console")
log("5. Output will also save to dump_output.txt")
log("")

-- ═══════════════════════════════════════════════════════
-- SAVE TO FILE AFTER 15 SECONDS
-- ═══════════════════════════════════════════════════════
task.delay(15, function()
    log("")
    log("═══════════════════════════════════════════════════════")
    log("               ANALYSIS COMPLETE")
    log("═══════════════════════════════════════════════════════")
    log("")
    log("[SUMMARY OF CAPTURED CALL PATTERN]")
    log("Total calls captured: " .. #capturedCalls)
    
    if #capturedCalls > 0 then
        log("")
        log("Call sequence:")
        for i, call in ipairs(capturedCalls) do
            log(string.format("  %d. %s.%s = %s", i, call.type, call.key, tostring(call.value)))
        end
        
        -- Identify the pattern
        log("")
        log("[IMPLEMENTATION PATTERN DETECTED]")
        local mostCommonValue = nil
        local valueCount = {}
        for _, call in ipairs(capturedCalls) do
            if call.key == "FireRate" then
                valueCount[call.value] = (valueCount[call.value] or 0) + 1
            end
        end
        
        for value, count in pairs(valueCount) do
            if not mostCommonValue or count > valueCount[mostCommonValue] then
                mostCommonValue = value
            end
        end
        
        if mostCommonValue then
            log("✅ They set FireRate to: " .. mostCommonValue)
            log("✅ Method: Using __newindex metamethod hook")
            log("")
            log("[RECOMMENDED IMPLEMENTATION]")
            log("Replace your rapid fire code with:")
            log("─────────────────────────────────────────────────────")
            log("rawset(stats, \"FireRate\", " .. mostCommonValue .. ")")
            log("─────────────────────────────────────────────────────")
        end
    end
    
    -- Save to file
    local fullOutput = table.concat(output, "\n")
    if writefile then
        writefile("dump_output.txt", fullOutput)
        log("")
        log("💾 Output saved to dump_output.txt")
    end
    
    if setclipboard then
        setclipboard(fullOutput)
        log("📋 Output copied to clipboard!")
    end
    
    log("")
    log("✅ DUMP COMPLETE - Check dump_output.txt in your executor folder")
end)

log("⏳ Monitoring... Will auto-save in 15 seconds")
