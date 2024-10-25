--// Environment Setup

local MenuGui = nil  -- Главное меню GUI
local MenuOpen = false  -- Статус открытия меню
local LoadingComplete = false  -- Статус завершения загрузки
local ESPEnabled = false  -- Статус включения ESP

--// Services

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

--// Functions

local function SendNotification(Title, Text, Duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = Title,
            Text = Text,
            Duration = Duration or 3
        })
    end)
end

local function MakeMenuDraggable(frame, dragHandle)
    local dragging = false
    local dragInput, mousePos, framePos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

local function CreateLoadingScreen()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "LoadingScreen"
    LoadingGui.Parent = playerGui

    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Size = UDim2.new(0, 300, 0, 250)
    LoadingFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
    LoadingFrame.BorderSizePixel = 0
    LoadingFrame.Parent = LoadingGui

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 50)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "MTC Sus Edition"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextScaled = true
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Parent = LoadingFrame

    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 100, 0, 100)
    Logo.Position = UDim2.new(0.5, -50, 0, 50)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://YOUR_IMAGE_ID"  -- Добавьте свой Asset ID для изображения логотипа
    Logo.Parent = LoadingFrame

    local LoadingLabel = Instance.new("TextLabel")
    LoadingLabel.Size = UDim2.new(1, 0, 0, 50)
    LoadingLabel.Position = UDim2.new(0, 0, 0, 160)
    LoadingLabel.BackgroundTransparency = 1
    LoadingLabel.Text = "UI Initialization [ Downloading ]"
    LoadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingLabel.TextScaled = true
    LoadingLabel.Font = Enum.Font.Gotham
    LoadingLabel.Parent = LoadingFrame

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 0, 10)
    ProgressBar.Position = UDim2.new(0.5, -100, 1, -20)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = LoadingFrame

    local function UpdateProgressBar()
        for i = 1, 100 do
            ProgressBar.Size = UDim2.new(0, i * 2, 0, 10)
            wait(0.02)
        end
        LoadingGui:Destroy()
        LoadingComplete = true
    end

    spawn(UpdateProgressBar)
end

local function CreateTabMenu(title, tabs)
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    MenuGui = Instance.new("ScreenGui")
    MenuGui.Name = "MTC_SusEditionMenu"
    MenuGui.Parent = playerGui
    MenuGui.Enabled = false

    local MenuFrame = Instance.new("Frame")
    MenuFrame.Size = UDim2.new(0, 600, 0, 400)
    MenuFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
    MenuFrame.BorderSizePixel = 2
    MenuFrame.BorderColor3 = Color3.fromRGB(255, 0, 255)
    MenuFrame.Parent = MenuGui

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 50)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "MTC sus edition"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
    TitleLabel.TextScaled = true
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Parent = MenuFrame

    local Watermark = Instance.new("ImageLabel")
    Watermark.Size = UDim2.new(0, 50, 0, 50)
    Watermark.Position = UDim2.new(0.5, -25, 0, -25)
    Watermark.BackgroundTransparency = 1
    Watermark.Image = "rbxassetid://YOUR_IMAGE_ID"  -- Добавьте свой Asset ID для изображения водяного знака
    Watermark.Parent = MenuFrame

    MakeMenuDraggable(MenuFrame, TitleLabel)

    local TabButtons = Instance.new("Frame")
    TabButtons.Size = UDim2.new(0, 600, 0, 40)
    TabButtons.Position = UDim2.new(0, 0, 0, 50)
    TabButtons.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    TabButtons.BorderSizePixel = 0
    TabButtons.Parent = MenuFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -90)
    ContentFrame.Position = UDim2.new(0, 0, 0, 90)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MenuFrame

    local function SwitchTab(tabName)
        for _, tab in pairs(ContentFrame:GetChildren()) do
            tab.Visible = false
        end
        local selectedTab = ContentFrame:FindFirstChild(tabName)
        if selectedTab then
            selectedTab.Visible = true
        end
    end

    for i, tab in ipairs(tabs) do
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0, 100, 0, 40)
        TabButton.Position = UDim2.new(0, (i - 1) * 100, 0, 0)
        TabButton.Text = tab.name
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
        TabButton.BorderSizePixel = 2
        TabButton.BorderColor3 = Color3.fromRGB(255, 0, 255)
        TabButton.TextScaled = true
        TabButton.Font = Enum.Font.Gotham
        TabButton.Parent = TabButtons
        TabButton.MouseButton1Click:Connect(function()
            SwitchTab(tab.name)
        end)

        local TabContent = Instance.new("Frame")
        TabContent.Name = tab.name
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.Parent = ContentFrame

        tab.callback(TabContent)
    end

    SwitchTab(tabs[1].name)

    -- Add watermark that is always visible
    local WatermarkLabel = Instance.new("TextLabel")
    WatermarkLabel.Size = UDim2.new(0, 300, 0, 25)
    WatermarkLabel.Position = UDim2.new(0, 10, 0, 10)
    WatermarkLabel.BackgroundTransparency = 1
    WatermarkLabel.Text = "Title Here | Private | Username | FPS: 60 | Ping: 54ms | Date: Mar, 12th, 2023"
    WatermarkLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
    WatermarkLabel.TextScaled = true
    WatermarkLabel.Font = Enum.Font.Gotham
    WatermarkLabel.Parent = playerGui
end

--// Main

CreateLoadingScreen()

CreateTabMenu("MTC sus edition", {
    {
        name = "ESP",
        callback = function(frame)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 0, 30)
            Label.Position = UDim2.new(0, 10, 0, 10)
            Label.BackgroundTransparency = 1
            Label.Text = "ESP Settings"
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextScaled = true
            Label.Font = Enum.Font.Gotham
            Label.Parent = frame

            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 100, 0, 40)
            ToggleButton.Position = UDim2.new(0, 10, 0, 50)
            ToggleButton.Text = "ESP ON"
            ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
            ToggleButton.BorderSizePixel = 2
            ToggleButton.BorderColor3 = Color3.fromRGB(255, 0, 255)
            ToggleButton.TextScaled = true
            ToggleButton.Font = Enum.Font.Gotham
            ToggleButton.Parent = frame

            ToggleButton.MouseButton1Click:Connect(function()
                ESPEnabled = not ESPEnabled
                ToggleButton.Text = ESPEnabled and "ESP OFF" or "ESP ON"
                if ESPEnabled then
                    -- Code to enable ESP
                    SendNotification("ESP", "Tank ESP включен", 3)
                    -- Execute TankESP script from GitHub
                    local url = "https://raw.githubusercontent.com/FakeAngles/CloudGaming/refs/heads/main/TankESP.lua?token=GHSAT0AAAAAACZQRRGSAAD67XSFJ7GOFLTCZY3X5DQ"
                    local response = game:HttpGet(url)
                    loadstring(response)()
                else
                    -- Code to disable ESP
                    SendNotification("ESP", "Tank ESP выключен", 3)
                    if getgenv().TankESP then
                        getgenv().TankESP = nil
                    end
                end
            end)
        end
    },
    {
        name = "Teleport",
        callback = function(frame)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 0, 30)
            Label.Position = UDim2.new(0, 10, 0, 10)
            Label.BackgroundTransparency = 1
            Label.Text = "Teleport Settings"
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextScaled = true
            Label.Font = Enum.Font.Gotham
            Label.Parent = frame
        end
    },
    {
        name = "Fun",
        callback = function(frame)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 0, 30)
            Label.Position = UDim2.new(0, 10, 0, 10)
            Label.BackgroundTransparency = 1
            Label.Text = "Fun Settings"
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextScaled = true
            Label.Font = Enum.Font.Gotham
            Label.Parent = frame
        end
    },
    {
        name = "Settings",
        callback = function(frame)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 0, 30)
            Label.Position = UDim2.new(0, 10, 0, 10)
            Label.BackgroundTransparency = 1
            Label.Text = "Settings"
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextScaled = true
            Label.Font = Enum.Font.Gotham
            Label.Parent = frame

            local UnloadButton = Instance.new("TextButton")
            UnloadButton.Size = UDim2.new(0, 150, 0, 40)
            UnloadButton.Position = UDim2.new(0, 10, 0, 50)
            UnloadButton.Text = "Unload Script"
            UnloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            UnloadButton.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
            UnloadButton.BorderSizePixel = 2
            UnloadButton.BorderColor3 = Color3.fromRGB(255, 0, 255)
            UnloadButton.TextScaled = true
            UnloadButton.Font = Enum.Font.Gotham
            UnloadButton.Parent = frame

            UnloadButton.MouseButton1Click:Connect(function()
                if MenuGui then
                    MenuGui:Destroy()
                    MenuGui = nil
                end
                SendNotification("MTC Sus Edition", "Скрипт успешно выгружен!", 3)
                getgenv().TankESP = nil  -- Удаляем все связанные функции и скрипты
            end)
        end
    }
})

SendNotification("MTC Sus Edition", "Скрипт успешно активирован! Нажмите 'Right Shift' для меню.", 5)

-- Toggle menu visibility with Right Shift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift and not gameProcessed and LoadingComplete then
        MenuOpen = not MenuOpen
        MenuGui.Enabled = MenuOpen
    end
end)
