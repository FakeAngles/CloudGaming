--// Environment Setup

getgenv().TankESP = {}  -- Global variable to prevent duplication
local Environment = getgenv().TankESP

--// Services

local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local SpawnedVehicles = game:GetService("Workspace"):WaitForChild("SpawnedVehicles")

--// Cached Functions

local Drawingnew = Drawing.new
local Vector2new = Vector2.new

--// Variables

local ESPLabels = {}  -- Table to store ESP elements for each vehicle and player
local Connections = {}  -- Table to store connections

--// Functions

local function SendNotification(Title, Text, Duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = Title,
            Text = Text,
            Duration = Duration or 3
        })
    end)
end

local function AddESPForVehicle(vehicle)
    if ESPLabels[vehicle] then return end  -- Avoid adding duplicate ESP for the same vehicle

    local ESPLabel = Drawingnew("Text")
    ESPLabel.Visible = false
    ESPLabel.Size = 18
    ESPLabel.Color = Color3.fromRGB(255, 0, 0)  -- Red color for highlighting
    ESPLabel.Center = true
    ESPLabel.Outline = true
    ESPLabel.Text = vehicle.Name  -- Unique name for each tank
    ESPLabel.Position = Vector2new(0, 0)
    ESPLabels[vehicle] = { Label = ESPLabel, Type = "Vehicle" }
end

local function AddESPForPlayer(player)
    if ESPLabels[player] or player == LocalPlayer or player.Team == LocalPlayer.Team or player.Neutral then return end  -- Avoid adding duplicate ESP and only for enemies

    local ESPLabel = Drawingnew("Text")
    ESPLabel.Visible = false
    ESPLabel.Size = 18
    ESPLabel.Color = Color3.fromRGB(0, 255, 0)  -- Green color for highlighting enemies
    ESPLabel.Center = true
    ESPLabel.Outline = true
    ESPLabels[player] = { Label = ESPLabel, Type = "Player" }
end

local function UpdateESP()
    -- Check each vehicle in SpawnedVehicles and add ESP if not already added
    for _, vehicle in pairs(SpawnedVehicles:GetChildren()) do
        if vehicle:IsA("Model") and vehicle:FindFirstChildWhichIsA("BasePart") and not ESPLabels[vehicle] then
            AddESPForVehicle(vehicle)
        end
    end

    -- Check each player and add ESP if they are an enemy
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and not player.Neutral and not ESPLabels[player] then
            AddESPForPlayer(player)
        end
    end
end

local function AddESP()
    -- Create ESP for each vehicle in SpawnedVehicles and for enemy players
    UpdateESP()

    -- Connect to RenderStepped to update text positions
    Connections.RenderConnection = RunService.RenderStepped:Connect(function()
        for entity, data in pairs(ESPLabels) do
            local ESPLabel = data.Label
            if entity and entity.Parent then
                if data.Type == "Vehicle" and entity:IsA("Model") and entity:FindFirstChildWhichIsA("BasePart") then
                    local primaryPart = entity.PrimaryPart or entity:FindFirstChildWhichIsA("BasePart")
                    local distanceToNearestEnemy = math.huge
                    local nearestEnemy = nil

                    for _, player in pairs(Players:GetPlayers()) do
                        if player.Team ~= LocalPlayer.Team and not player.Neutral and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (primaryPart.Position - player.Character.HumanoidRootPart.Position).Magnitude * 0.28
                            if distance < distanceToNearestEnemy then
                                distanceToNearestEnemy = distance
                                nearestEnemy = player
                            end
                        end
                    end

                    if nearestEnemy and distanceToNearestEnemy <= 5 then
                        local Vector, OnScreen = Camera:WorldToViewportPoint(primaryPart.Position)
                        if OnScreen then
                            ESPLabel.Visible = true
                            ESPLabel.Position = Vector2new(Vector.X, Vector.Y + 20)  -- Offset position to avoid overlapping with player
                            ESPLabel.Text = string.format("%s (%.2f m)", entity.Name, (primaryPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude * 0.28)  -- Show vehicle name and distance to nearest enemy
                        else
                            ESPLabel.Visible = false
                        end
                    else
                        ESPLabel.Visible = false
                    end
                elseif data.Type == "Player" and entity:IsA("Player") and entity.Character and entity.Character:FindFirstChild("HumanoidRootPart") and entity.Character:FindFirstChild("Humanoid") and entity.Character.Humanoid.Health > 0 then
                    local humanoidRootPart = entity.Character.HumanoidRootPart
                    local Vector, OnScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                    if OnScreen then
                        ESPLabel.Visible = true
                        ESPLabel.Position = Vector2new(Vector.X, Vector.Y)
                        local isNearVehicle = false

                        for _, vehicle in pairs(SpawnedVehicles:GetChildren()) do
                            if vehicle:IsA("Model") and vehicle:FindFirstChildWhichIsA("BasePart") then
                                local primaryPart = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
                                local distance = (primaryPart.Position - humanoidRootPart.Position).Magnitude * 0.28
                                if distance <= 5 then
                                    isNearVehicle = true
                                    break
                                end
                            end
                        end

                        if not isNearVehicle then
                            local distanceToLocalPlayer = (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude * 0.28
                            local health = entity.Character.Humanoid.Health
                            ESPLabel.Text = string.format("%s (%.2f m) | HP: %.0f", entity.Name, distanceToLocalPlayer, health)
                        else
                            local health = entity.Character.Humanoid.Health
                            ESPLabel.Text = string.format("%s | HP: %.0f", entity.Name, health)
                        end
                    else
                        ESPLabel.Visible = false
                    end
                else
                    ESPLabel.Visible = false
                end
            else
                ESPLabel:Remove()
                ESPLabels[entity] = nil
            end
        end
    end)

    -- Connect to ChildAdded and ChildRemoved to automatically add and remove ESP for new vehicles
    Connections.ChildAddedConnection = SpawnedVehicles.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart") then
            task.defer(function()  -- Use task.defer for correct addition of new objects
                AddESPForVehicle(child)
            end)
        end
    end)

    Connections.ChildRemovedConnection = SpawnedVehicles.ChildRemoved:Connect(function(child)
        if ESPLabels[child] then
            ESPLabels[child].Label:Remove()
            ESPLabels[child] = nil
        end
    end)

    -- Connect to PlayerAdded and PlayerRemoving to add and remove ESP for players
    Connections.PlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
        if player.Team ~= LocalPlayer.Team and not player.Neutral then
            task.defer(function()
                AddESPForPlayer(player)
            end)
        end
    end)

    Connections.PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        if ESPLabels[player] then
            ESPLabels[player].Label:Remove()
            ESPLabels[player] = nil
        end
    end)
end

local function RemoveESP()
    -- Disconnect connections and remove ESP elements
    if Connections.RenderConnection then
        Connections.RenderConnection:Disconnect()
        Connections.RenderConnection = nil
    end
    if Connections.ChildAddedConnection then
        Connections.ChildAddedConnection:Disconnect()
        Connections.ChildAddedConnection = nil
    end
    if Connections.ChildRemovedConnection then
        Connections.ChildRemovedConnection:Disconnect()
        Connections.ChildRemovedConnection = nil
    end
    if Connections.PlayerAddedConnection then
        Connections.PlayerAddedConnection:Disconnect()
        Connections.PlayerAddedConnection = nil
    end
    if Connections.PlayerRemovingConnection then
        Connections.PlayerRemovingConnection:Disconnect()
        Connections.PlayerRemovingConnection = nil
    end
    for _, data in pairs(ESPLabels) do
        data.Label.Visible = false
        data.Label:Remove()
    end
    ESPLabels = {}
end

--// Main

Environment.AddESP = AddESP
Environment.RemoveESP = RemoveESP
