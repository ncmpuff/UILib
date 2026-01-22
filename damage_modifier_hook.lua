-- ═══════════════════════════════════════════════════════
-- DAMAGE MODIFIER HOOK
-- Hooks into weapon stat modules to multiply damage
-- ═══════════════════════════════════════════════════════

local Config = Config or {} -- Use existing Config if available
Config.DamageMultiplier = Config.DamageMultiplier or 1

-- Hook require to intercept weapon stat modules
local oldRequire = require
local requireHook = function(module)
    local result = oldRequire(module)
    
    -- Check if this is a weapon stat module (has BodyDamage property)
    if type(result) == "table" and result.BodyDamage then
        -- Apply damage multiplier
        local originalBodyDamage = result.BodyDamage
        result.BodyDamage = originalBodyDamage * Config.DamageMultiplier
        
        -- Recalculate dependent damage values
        if result.Damage then
            result.Damage.Body = result.BodyDamage
            result.Damage.Headshot = result.BodyDamage * 1.25
        end
        
        -- Optional: Log for debugging
        -- print(string.format("🔫 Hooked weapon stats: %s | Base: %d → Modified: %d (x%d)", 
        --     tostring(module), originalBodyDamage, result.BodyDamage, Config.DamageMultiplier))
    end
    
    return result
end

-- Replace global require
local hookSuccess = pcall(function()
    getgenv().require = requireHook
    -- Also hook the function environment require
    local env = getfenv(2)
    if env then
        env.require = requireHook
    end
end)

if hookSuccess then
    print("✅ Damage modifier hook installed!")
    print("ℹ️  All weapon damage will be multiplied by: " .. Config.DamageMultiplier .."x")
else
    warn("⚠️ Failed to install damage modifier hook")
end

-- ═══════════════════════════════════════════════════════
-- ALTERNATIVE METHOD: Direct stat modification
-- Use this if the require hook doesn't work
-- ═══════════════════════════════════════════════════════

local function modifyWeaponStats()
    local workspace = game:GetService("Workspace")
    local statsFolder = workspace:FindFirstChild("Workspace") 
        and workspace.Workspace:FindFirstChild("Lobby") 
        and workspace.Workspace.Lobby:FindFirstChild("GunModels")
        and workspace.Workspace.Lobby.GunModels:FindFirstChild("Stats")
    
    if not statsFolder then
        warn("⚠️ Could not find weapon stats folder")
        return
    end
    
    local modifiedCount = 0
    for _, statModule in pairs(statsFolder:GetChildren()) do
        if statModule:IsA("ModuleScript") then
            local success = pcall(function()
                local stats = require(statModule)
                if stats.BodyDamage then
                    local originalDamage = stats.BodyDamage
                    stats.BodyDamage = originalDamage * Config.DamageMultiplier
                    
                    if stats.Damage then
                        stats.Damage.Body = stats.BodyDamage
                        stats.Damage.Headshot = stats.BodyDamage * 1.25
                    end
                    
                    modifiedCount = modifiedCount + 1
                end
            end)
        end
    end
    
    if modifiedCount > 0 then
        print(string.format("✅ Modified %d weapon stats with %dx damage multiplier", modifiedCount, Config.DamageMultiplier))
    end
end

-- Run the direct modification method as backup
task.spawn(function()
    task.wait(2) -- Wait for game to load
    modifyWeaponStats()
end)
