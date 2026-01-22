-- ═══════════════════════════════════════════════════════
-- ROOM TELEPORT SYSTEM
-- ═══════════════════════════════════════════════════════
local RoomLocations = {
    ["Class D Cells"] = CFrame.new(1111.91, 61.00, 297.14, -1.0000, 0.0000, 0.0040, 0.0000, 1.0000, 0.0000, -0.0040, 0.0000, -1.0000),
    ["Entrance Zone"] = CFrame.new(1213.92, 49.00, 629.73, 1.0000, 0.0000, 0.0059, -0.0000, 1.0000, 0.0000, -0.0059, -0.0000, 1.0000),
    ["914"] = CFrame.new(913.95, 49.00, 584.90, -1.0000, 0.0000, 0.0021, 0.0000, 1.0000, 0.0000, -0.0021, 0.0000, -1.0000),
    ["Heavy Containment Zone"] = CFrame.new(1093.80, 49.00, 690.85, -1.0000, 0.0000, -0.0007, 0.0000, 1.0000, -0.0000, 0.0007, -0.0000, -1.0000),
    ["Gate A"] = CFrame.new(1462.33, 49.00, 403.17, -0.0024, 0.0000, -1.0000, -0.0000, 1.0000, 0.0000, 1.0000, 0.0000, -0.0024),
    ["Gate B"] = CFrame.new(1207.11, 49.00, 103.05, -0.0177, 0.0000, -0.9998, -0.0000, 1.0000, 0.0000, 0.9998, 0.0000, -0.0177),
    ["Gate A Surface"] = CFrame.new(1469.67, 565.50, 265.52, -0.0273, -0.0000, -0.9996, -0.0000, 1.0000, -0.0000, 0.9996, 0.0000, -0.0273),
    ["Gate B Surface"] = CFrame.new(1601.50, 565.50, 319.37, 0.9999, 0.0000, -0.0130, -0.0000, 1.0000, 0.0000, 0.0130, -0.0000, 0.9999),
    ["Alpha Warhead"] = CFrame.new(1560.24, 566.00, 328.63, 0.0186, 0.0000, 0.9998, 0.0000, 1.0000, -0.0000, -0.9998, 0.0000, 0.0186)
}

local function getRoomList()
    return {
        "Class D Cells",
        "Entrance Zone",
        "914",
        "Heavy Containment Zone",
        "Gate A",
        "Gate B",
        "Gate A Surface",
        "Gate B Surface",
        "Alpha Warhead"
    }
end

local function teleportToRoom(roomName)
    local myChar = LocalPlayer.Character
    if not myChar then
        UILib:CreateNotification({
            Text = "⚠️ You have no character!",
            Duration = 3
        })
        return
    end
    
    local myRoot = getRoot(myChar)
    if not myRoot then
        UILib:CreateNotification({
            Text = "⚠️ HumanoidRootPart not found!",
            Duration = 3
        })
        return
    end
    
    local targetCFrame = RoomLocations[roomName]
    if targetCFrame then
        myRoot.CFrame = targetCFrame
        UILib:CreateNotification({
            Text = "✅ Teleported to " .. roomName,
            Duration = 2
        })
    else
        UILib:CreateNotification({
            Text = "⚠️ Room not found!",
            Duration = 3
        })
    end
end

-- Add the dropdown to PlayerPanel (place this where you create UI elements)
-- UILib:CreateDropdown(PlayerPanel, {
--     Label = "Room Teleport",
--     Options = getRoomList(),
--     Callback = function(selectedRoom)
--         teleportToRoom(selectedRoom)
--     end,
--     Searchable = true
-- })
