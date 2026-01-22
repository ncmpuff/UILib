-- Weapon State Finder
-- Equip a gun and run this script to find where weapon state is stored

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("========== WEAPON STATE FINDER ==========")
print("Instructions:")
print("1. Equip a gun")
print("2. Shoot it once")
print("3. Wait for results...")
print("")

task.wait(2)

local function searchEverywhere()
    print("[1] Searching in Character (skipped - can't access Instance properties)...")
    
    print("[2] Searching in Tool (skipped - can't access Instance properties)...")
    
    print("[3] Searching in Scripts...")
    local character = LocalPlayer.Character
    for _, script in pairs(game:GetDescendants()) do
        if script:IsA("LocalScript") and string.find(script.Name:lower(), "weapon") then
            print("Found weapon script:", script:GetFullName())
        end
    end
    
    print("[4] Using getgc() to find it...")
    local found = false
    local gcTable = getgc(true)
    local totalObjects = #gcTable
    print("Total objects in memory:", totalObjects)
    
    for i, obj in pairs(gcTable) do
        if i % 5000 == 0 then
            print("Checked", i, "objects...")
        end
        
        if type(obj) == "table" then
            if rawget(obj, "cycled") ~= nil and rawget(obj, "wepStats") ~= nil then
                print("✅ ✅ ✅ FOUND via getgc() at index:", i, "/", totalObjects)
                print("\nProperties in weapon state table:")
                for k, v in pairs(obj) do
                    if type(v) == "table" then
                        print("  -", k, "= {table}")
                    else
                        print("  -", k, "=", tostring(v))
                    end
                end
                
                print("\nwepStats contents:")
                if obj.wepStats then
                    for k, v in pairs(obj.wepStats) do
                        if type(v) == "table" then
                            print("  -", k, "= {table}")
                        else
                            print("  -", k, "=", tostring(v))
                        end
                    end
                end
                
                print("\nequipped tool:", obj.equipped and obj.equipped.Name or "nil")
                found = true
                break
            end
        end
    end
    
    if not found then
        print("❌ Not found in first 10k objects!")
        print("NOTE: Weapon state only exists AFTER you shoot once!")
    end
    
    return found
end

searchEverywhere()

print("\n========== SEARCH COMPLETE ==========")
