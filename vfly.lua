-- Vehicle Fly Script

local VehicleFlyEnabled = false
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function VehicleFlyToggle()
    VehicleFlyEnabled = not VehicleFlyEnabled
    if VehicleFlyEnabled then
        RunService:BindToRenderStep("VehicleFly", Enum.RenderPriority.Input.Value, function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = LocalPlayer.Character.HumanoidRootPart
                local flyDirection = Vector3.new(0, 0, 0)

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    flyDirection = flyDirection + (Camera.CFrame.LookVector * 50)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    flyDirection = flyDirection - (Camera.CFrame.LookVector * 50)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    flyDirection = flyDirection - (Camera.CFrame.RightVector * 50)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    flyDirection = flyDirection + (Camera.CFrame.RightVector * 50)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    flyDirection = flyDirection + Vector3.new(0, 50, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    flyDirection = flyDirection - Vector3.new(0, 50, 0)
                end

                rootPart.Velocity = flyDirection
                rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Camera.CFrame.LookVector)
            end
        end)
    else
        RunService:UnbindFromRenderStep("VehicleFly")
    end
end

return VehicleFlyToggle
