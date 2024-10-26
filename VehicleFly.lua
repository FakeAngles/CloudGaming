-- Vehicle Fly Script

local VehicleFlyEnabled = false
local VehicleFlyConnection = nil
local VehicleFlySpeed = 100 -- Speed of flying, can be adjusted

local function EnableVehicleFly()
    local vehicle = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("VehicleSeat")
    if not vehicle then return end

    VehicleFlyEnabled = true
    VehicleFlyConnection = RunService.Heartbeat:Connect(function()
        if VehicleFlyEnabled and vehicle then
            local direction = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            vehicle.Velocity = direction.Unit * VehicleFlySpeed
        end
    end)
    SendNotification("Vehicle Fly", "Vehicle Fly включен", 3)
end

local function DisableVehicleFly()
    if VehicleFlyConnection then
        VehicleFlyConnection:Disconnect()
        VehicleFlyConnection = nil
    end
    VehicleFlyEnabled = false
    SendNotification("Vehicle Fly", "Vehicle Fly выключен", 3)
end

-- Toggle Vehicle Fly based on menu interaction
local function ToggleVehicleFly()
    if VehicleFlyEnabled then
        DisableVehicleFly()
    else
        EnableVehicleFly()
    end
end

-- Bind ToggleVehicleFly to the menu button or key
VehicleFlyButton.MouseButton1Click:Connect(function()
    ToggleVehicleFly()
end)
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == VehicleFlyBindKey and not gameProcessedEvent then
        ToggleVehicleFly()
    end
end)

-- Unload Vehicle Fly Script
local function UnloadVehicleFly()
    DisableVehicleFly()
end

-- Add UnloadVehicleFly to the unload button in the menu
UnloadButton.MouseButton1Click:Connect(function()
    UnloadVehicleFly()
end)
