-- New Vehicle Fly Script with NoClip Integration into Menu

local VehicleFlyEnabled = false
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SPEED = 150  -- Flight speed, adjust as needed

-- Function to toggle vehicle fly
local function VehicleFlyToggle()
    VehicleFlyEnabled = not VehicleFlyEnabled
    if VehicleFlyEnabled then
        print("[DEBUG] Vehicle Fly Enabled")
        RunService:BindToRenderStep("VehicleFly", Enum.RenderPriority.Input.Value, function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = LocalPlayer.Character.HumanoidRootPart
                local flyDirection = Vector3.new(0, 0, 0)

                -- Directional controls for flying
                if UserInputService:IsKeyDown(VehicleFlyBindKey) then
                    flyDirection = flyDirection + (Camera.CFrame.LookVector * SPEED)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    flyDirection = flyDirection - (Camera.CFrame.LookVector * SPEED)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    flyDirection = flyDirection - (Camera.CFrame.RightVector * SPEED)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    flyDirection = flyDirection + (Camera.CFrame.RightVector * SPEED)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    flyDirection = flyDirection + Vector3.new(0, SPEED, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    flyDirection = flyDirection - Vector3.new(0, SPEED, 0)
                end

                -- Apply velocity to move the vehicle through all obstacles (NoClip)
                rootPart.Velocity = flyDirection
                rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + Camera.CFrame.LookVector)
                rootPart.CanCollide = false  -- Disable collision to allow flying through textures
            end
        end)
    else
        print("[DEBUG] Vehicle Fly Disabled")
        RunService:UnbindFromRenderStep("VehicleFly")
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CanCollide = true  -- Restore collision when disabled
        end
    end
end

-- Function to unload the script
local function UnloadVehicleFlyScript()
    if VehicleFlyEnabled then
        VehicleFlyToggle()  -- Disable the fly mode if it's currently enabled
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CanCollide = true  -- Restore collision
    end
    print("[DEBUG] Vehicle Fly Script Unloaded")
    VehicleFlyEnabled = false
end

-- Integrate VehicleFly control into existing menu
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == VehicleFlyBindKey then
        VehicleFlyToggle()
    end
end)

return UnloadVehicleFlyScript
