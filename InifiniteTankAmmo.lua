local player = game.Players.LocalPlayer
local workspace = game:GetService("Workspace")

-- Функция для изменения значения Mag
local function setMagValue(weapon)
    local mag = weapon:FindFirstChild("Mag")
    if mag and mag:IsA("IntValue") then
        mag.Value = 10000
        print("Значение Mag для оружия " .. weapon.Name .. " изменено на 10000.")
    end
end

-- Функция для поиска ближайшего транспортного средства в пределах заданного расстояния
local function findClosestVehicle(maxDistance)
    local closestVehicle = nil
    local closestDistance = math.huge -- Начальное значение бесконечности

    -- Убедимся, что персонаж игрока существует
    local character = player.Character or player.CharacterAdded:Wait()
    local playerPosition = character:WaitForChild("HumanoidRootPart").Position

    -- Проходим по всем транспортным средствам в workspace.SpawnedVehicles
    for _, vehicle in ipairs(workspace:FindFirstChild("SpawnedVehicles"):GetChildren()) do
        if vehicle:FindFirstChild("Turrets") and vehicle.PrimaryPart then
            local vehiclePosition = vehicle.PrimaryPart.Position
            local distance = (vehiclePosition - playerPosition).magnitude

            -- Проверяем, если это ближайшее транспортное средство и в пределах maxDistance
            if distance < closestDistance and distance <= maxDistance then
                closestDistance = distance
                closestVehicle = vehicle
            end
        end
    end

    return closestVehicle
end

-- Основная логика для изменения значения Mag у ближайшего транспортного средства
local function updateMagForClosestVehicle()
    local maxDistance = 10 -- Максимальное расстояние в студах
    local closestVehicle = findClosestVehicle(maxDistance)
    
    if closestVehicle then
        -- Проходим по всем башням
        for _, turret in ipairs(closestVehicle.Turrets:GetChildren()) do
            if turret:FindFirstChild("Weapons") then
                -- Проходим по всем оружиям
                for _, weapon in ipairs(turret.Weapons:GetChildren()) do
                    setMagValue(weapon)
                end
            end
        end
    else
        print("Ближайшее транспортное средство не найдено в пределах " .. maxDistance .. " студов.")
    end
end

-- Пример вызова функции для обновления Mag
updateMagForClosestVehicle()
