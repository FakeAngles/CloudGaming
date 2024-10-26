-- Assuming the menu script already has buttons for 'Vehicle Fly' and 'Bind'

local flying = false
local e1, e2
local gyro, pos
local speed = 10

local function startFly()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local torso = character:WaitForChild("HumanoidRootPart")
    local mouse = player:GetMouse()

    local bg = Instance.new("BodyGyro", torso)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = torso.CFrame
    gyro = bg

    local bp = Instance.new("BodyPosition", torso)
    bp.maxForce = Vector3.new(9e9, 9e9, 9e9)
    bp.position = torso.Position
    pos = bp

    flying = true
    character.Humanoid.PlatformStand = true

    coroutine.resume(coroutine.create(function()
        repeat
            wait()
            local new = workspace.CurrentCamera.CoordinateFrame
            if flying and keys.w then
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

            if speed > 10 then
                speed = 5
            end

            pos.position = new.p
            gyro.cframe = workspace.CurrentCamera.CoordinateFrame
        until flying == false

        if gyro then gyro:Destroy() end
        if pos then pos:Destroy() end
        flying = false
        character.Humanoid.PlatformStand = false
        speed = 10
    end))

    e1 = mouse.KeyDown:connect(function(key)
        if not torso or not torso.Parent then flying = false e1:disconnect() e2:disconnect() return end
        if key == "w" then
            keys.w = true
        elseif key == "s" then
            keys.s = true
        elseif key == "a" then
            keys.a = true
        elseif key == "d" then
            keys.d = true
        end
    end)

    e2 = mouse.KeyUp:connect(function(key)
        if key == "w" then
            keys.w = false
        elseif key == "s" then
            keys.s = false
        elseif key == "a" then
            keys.a = false
        elseif key == "d" then
            keys.d = false
        end
    end)
end

local function stopFly()
    flying = false
    if e1 then e1:Disconnect() end
    if e2 then e2:Disconnect() end
    if workspace:FindFirstChild("Core") then
        workspace.Core:Destroy()
    end
    if gyro then gyro:Destroy() end
    if pos then pos:Destroy() end
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        character.Humanoid.PlatformStand = false
    end
end

-- Assuming there are buttons called 'VehicleFlyButton' and 'BindButton'
local VehicleFlyButton = ... -- Reference to the Vehicle Fly button in your menu
local BindButton = ... -- Reference to the Bind button in your menu

VehicleFlyButton.MouseButton1Click:Connect(function()
    if not flying then
        startFly()
    else
        stopFly()
    end
end)

BindButton.MouseButton1Click:Connect(function()
    if not flying then
        startFly()
    else
        stopFly()
    end
end)
