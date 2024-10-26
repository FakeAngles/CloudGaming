local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local plr = Players.LocalPlayer
local mouse = plr:GetMouse()
local localplayer = plr

-- Variables for Vehicle Fly state
local flying = false
local speed = 10
local keys = {a = false, d = false, w = false, s = false, q = false, e = false}
local e1, e2, characterAddedConnection

-- Remove existing core part if exists
if workspace:FindFirstChild("Core") then
    workspace.Core:Destroy()
end

-- Create core part for flight mechanics
local Core = Instance.new("Part")
Core.Name = "Core"
Core.Size = Vector3.new(0.05, 0.05, 0.05)

spawn(function()
    Core.Parent = workspace
    local Weld = Instance.new("Weld", Core)
    Weld.Part0 = Core
    
    -- Check for character type and weld accordingly
    local Character = localplayer.Character or localplayer.CharacterAdded:Wait()
    if Character:FindFirstChild("LowerTorso") then
        Weld.Part1 = Character.LowerTorso
    elseif Character:FindFirstChild("Torso") then
        Weld.Part1 = Character.Torso
    else
        warn("Не удалось найти подходящую часть для привязки.")
        return
    end
    Weld.C0 = CFrame.new(0, 0, 0)
end)

workspace:WaitForChild("Core")

local torso = workspace.Core

local function startFlying()
    flying = true
    local pos = Instance.new("BodyPosition", torso)
    local gyro = Instance.new("BodyGyro", torso)
    pos.Name = "EPIXPOS"
    pos.maxForce = Vector3.new(math.huge, math.huge, math.huge)
    pos.position = torso.Position
    gyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    gyro.cframe = torso.CFrame

    RunService:BindToRenderStep("VehicleFly", Enum.RenderPriority.Camera.Value, function()
        local new = gyro.cframe - gyro.cframe.p + pos.position

        if not keys.w and not keys.s and not keys.a and not keys.d and not keys.q and not keys.e then
            speed = 5
        end
        if keys.w then
            new = new + workspace.CurrentCamera.CoordinateFrame.lookVector * speed
        end
        if keys.s then
            new = new - workspace.CurrentCamera.CoordinateFrame.lookVector * speed
        end
        if keys.d then
            new = new * CFrame.new(speed, 0, 0)
        end
        if keys.a then
            new = new * CFrame.new(-speed, 0, 0)
        end
        if keys.q then
            new = new * CFrame.new(0, speed, 0)
        end
        if keys.e then
            new = new * CFrame.new(0, -speed, 0)
        end

        if speed > 10 then
            speed = 5
        end

        pos.position = new.p
        gyro.cframe = workspace.CurrentCamera.CoordinateFrame
    end)
end

local function stopFlying()
    flying = false
    RunService:UnbindFromRenderStep("VehicleFly")
    if workspace:FindFirstChild("Core") then
        workspace.Core:Destroy()
    end
end

local function unloadScript()
    stopFlying()
    if e1 then e1:Disconnect() end
    if e2 then e2:Disconnect() end
    if characterAddedConnection then characterAddedConnection:Disconnect() end
end

e1 = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.W then
        keys.w = true
    elseif input.KeyCode == Enum.KeyCode.S then
        keys.s = true
    elseif input.KeyCode == Enum.KeyCode.A then
        keys.a = true
    elseif input.KeyCode == Enum.KeyCode.D then
        keys.d = true
    elseif input.KeyCode == Enum.KeyCode.Q then
        keys.q = true
    elseif input.KeyCode == Enum.KeyCode.E then
        keys.e = true
    elseif input.KeyCode == Enum.KeyCode.Space then -- Example key to toggle flying
        if flying then
            stopFlying()
        else
            startFlying()
        end
    end
end)

e2 = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.W then
        keys.w = false
    elseif input.KeyCode == Enum.KeyCode.S then
        keys.s = false
    elseif input.KeyCode == Enum.KeyCode.A then
        keys.a = false
    elseif input.KeyCode == Enum.KeyCode.D then
        keys.d = false
    elseif input.KeyCode == Enum.KeyCode.Q then
        keys.q = false
    elseif input.KeyCode == Enum.KeyCode.E then
        keys.e = false
    end
end)

-- Stop flying if the player dies
characterAddedConnection = plr.CharacterAdded:Connect(function()
    if flying then
        unloadScript()
    end
end)
