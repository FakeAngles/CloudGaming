-- Vehicle Fly Script with Debug Messages

local VehicleFlyEnabled = false
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SPEED = 150  -- Скорость полета, измените по необходимости

local function VehicleFlyToggle()
    VehicleFlyEnabled = not VehicleFlyEnabled
    print("[DEBUG] VehicleFlyEnabled set to:", VehicleFlyEnabled)
    if VehicleFlyEnabled then
        RunService:BindToRenderStep("VehicleFly", Enum.RenderPriority.Input.Value, function()
            print("[DEBUG] VehicleFly RenderStep running...")
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = LocalPlayer.Character.HumanoidRootPart
                local flyDirection = Vector3.new(0, 0, 0)

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    flyDirection = flyDirection + (Camera.CFrame.LookVector * SPEED)
                    print("[DEBUG] W Key Pressed: Moving Forward")
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    flyDirection = flyDirection - (Camera.CFrame.LookVector * SPEED)
                    print("[DEBUG] S Key Pressed: Moving Backward")
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    flyDirection = flyDirection - (Camera.CFrame.RightVector * SPEED)
                    print("[DEBUG] A Key Pressed: Moving Left")
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    flyDirection = flyDirection + (Camera.CFrame.RightVector * SPEED)
                    print("[DEBUG] D Key Pressed: Moving Right")
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    flyDirection = flyDirection + Vector3.new(0, SPEED, 0)
                    print("[DEBUG] Space Key Pressed: Moving Up")
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    flyDirection = flyDirection - Vector3.new(0, SPEED, 0)
                    print("[DEBUG] Left Shift Key Pressed: Moving Down")
                end

                rootPart.Velocity = flyDirection
                rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + Camera.CFrame.LookVector)
            else
                print("[DEBUG] HumanoidRootPart not found")
            end
        end)
    else
        RunService:UnbindFromRenderStep("VehicleFly")
        print("[DEBUG] VehicleFly RenderStep unbound")
    end
end

return VehicleFlyToggle
