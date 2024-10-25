--// Environment Setup

getgenv().TankESP = {}  -- Глобальная переменная для предотвращения дублирования
local Environment = getgenv().TankESP

--// Services

local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = game:GetService("Workspace").CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SpawnedVehicles = game:GetService("Workspace"):WaitForChild("SpawnedVehicles")

--// Cached Functions

local Drawingnew = Drawing.new
local Vector2new = Vector2.new

--// Variables

local ESPLabels = {}  -- Таблица для хранения ESP элементов для каждой техники и игроков
local Connections = {}  -- Таблица для хранения соединений

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
    if ESPLabels[vehicle] then return end  -- Не добавляем повторно ESP для одной и той же техники

    local ESPLabel = Drawingnew("Text")
    ESPLabel.Visible = false
    ESPLabel.Size = 18
    ESPLabel.Color = Color3.fromRGB(255, 0, 0)  -- Красный цвет для выделения
    ESPLabel.Center = true
    ESPLabel.Outline = true
    ESPLabel.Text = vehicle.Name  -- Уникальное название для каждого танка
    ESPLabel.Position = Vector2new(0, 0)
    ESPLabels[vehicle] = { Label = ESPLabel, Type = "Vehicle" }
end

local function AddESPForPlayer(player)
    if ESPLabels[player] or player == LocalPlayer or player.Team == LocalPlayer.Team or player.Neutral then return end  -- Не добавляем повторно ESP и только для врагов

    local ESPLabel = Drawingnew("Text")
    ESPLabel.Visible = false
    ESPLabel.Size = 18
    ESPLabel.Color = Color3.fromRGB(0, 255, 0)  -- Зеленый цвет для выделения врагов
    ESPLabel.Center = true
    ESPLabel.Outline = true
    ESPLabels[player] = { Label = ESPLabel, Type = "Player" }
end

local function UpdateESP()
    -- Проверяем каждую технику в SpawnedVehicles и добавляем ESP, если он еще не добавлен
    for _, vehicle in pairs(SpawnedVehicles:GetChildren()) do
        if vehicle:IsA("Model") and vehicle:FindFirstChildWhichIsA("BasePart") and not ESPLabels[vehicle] then
            AddESPForVehicle(vehicle)
        end
    end

    -- Проверяем каждого игрока и добавляем ESP, если он враг
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and not player.Neutral and not ESPLabels[player] then
            AddESPForPlayer(player)
        end
    end
end

local function AddESP()
    -- Создаем ESP для каждой техники в SpawnedVehicles и для вражеских игроков
    UpdateESP()

    -- Подключаемся к RenderStepped, чтобы обновлять позиции текста
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
                            ESPLabel.Position = Vector2new(Vector.X, Vector.Y + 20)  -- Смещаем позицию ниже, чтобы не накладываться на игрока
                            ESPLabel.Text = string.format("%s (%.2f м)", entity.Name, (primaryPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude * 0.28)  -- Показываем название техники и расстояние до ближайшего врага
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
                            ESPLabel.Text = string.format("%s (%.2f м) | HP: %.0f", entity.Name, distanceToLocalPlayer, health)
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

    -- Подключаемся к ChildAdded и ChildRemoved, чтобы автоматически добавлять и удалять ESP для новой техники
    Connections.ChildAddedConnection = SpawnedVehicles.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart") then
            task.defer(function()  -- Используем task.defer для корректного добавления нового объекта
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

    -- Подключаемся к PlayerAdded и PlayerRemoving, чтобы добавлять и удалять ESP для игроков
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
    -- Отключаем соединение и удаляем элементы ESP
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

AddESP()
SendNotification("Tank ESP", "Скрипт успешно активирован!", 5)
