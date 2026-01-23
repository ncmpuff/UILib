-- TELEPORT BYPASS for Retro Breach
-- Uses the game's authorized TeleportPlayer remote to bypass anti-cheat

local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = game.Players.LocalPlayer

-- Get the authorized teleport remote
local BridgeNet2 = require(RS.Assets.Modules.BridgeNet2)
local TeleportPlayer = BridgeNet2.ClientBridge("TeleportPlayer")

-- Bypass function
local function bypassTeleport(targetCFrame)
    -- Fire the authorized remote instead of directly setting CFrame
    -- The anti-cheat allows this because it comes from the TeleportPlayer remote
    TeleportPlayer:Fire({CFrame = targetCFrame})
    
    print("✅ Teleported via authorized remote!")
end

-- Example usage:
-- bypassTeleport(CFrame.new(0, 100, 0))  -- Teleport to Y=100

-- Integration with item grab:
-- Replace this line in your smooth teleport:
--   myRoot.CFrame = CFrame.new(nextPos)
-- With this:
--   bypassTeleport(CFrame.new(nextPos))

return bypassTeleport
