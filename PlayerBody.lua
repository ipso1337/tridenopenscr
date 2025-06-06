-- Исправленный скрипт для Roblox ESP Suite
-- Версия с улучшенной отладкой и обработкой ошибок

print("=== ЗАПУСК TRIDEN ESP SUITE ===")

-- Функция безопасной загрузки
local function safeLoadstring(url, name)
    print("[LOAD] Загружаем " .. name .. "...")
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("[SUCCESS] " .. name .. " загружен успешно")
        return result
    else
        warn("[ERROR] Ошибка загрузки " .. name .. ": " .. tostring(result))
        return nil
    end
end

-- Проверка HTTP
if not game:GetService("HttpService").HttpEnabled then
    warn("[CRITICAL] HTTP запросы отключены!")
    return
end

-- Загрузка основных библиотек
print("[INFO] Загружаем основные библиотеки...")

local Fluent = safeLoadstring("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", "Fluent UI")
if not Fluent then
    error("[CRITICAL] Не удалось загрузить Fluent UI!")
end

local SaveManager = safeLoadstring("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua", "SaveManager")
local InterfaceManager = safeLoadstring("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua", "InterfaceManager")

print("[INFO] Основные библиотеки загружены")

-- Создание окна
print("[INFO] Создаем интерфейс...")

local Window = Fluent:CreateWindow({
    Title = "Triden ESP Suite v2.0",
    SubTitle = "Исправленная версия",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

print("[SUCCESS] Окно создано")

-- Создание вкладок
local Tabs = {
    Main = Window:AddTab({ Title = "Главная", Icon = "home" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Player = Window:AddTab({ Title = "Игрок", Icon = "user" }),
    Teleport = Window:AddTab({ Title = "Телепорт", Icon = "zap" }),
    Settings = Window:AddTab({ Title = "Настройки", Icon = "settings" })
}

print("[SUCCESS] Вкладки созданы")

local Options = Fluent.Options

-- === ГЛАВНАЯ ВКЛАДКА ===
Tabs.Main:AddParagraph({
    Title = "Добро пожаловать в Triden ESP Suite! 🎮",
    Content = "Этот скрипт предоставляет множество функций для улучшения игрового опыта.\n\n• ESP - визуализация игроков\n• Телепорт - быстрое перемещение\n• Настройки персонажа\n\nИспользуйте LeftControl для сворачивания интерфейса."
})

-- Статус системы
local statusText = "🟢 Fluent UI: Загружен\n"
statusText = statusText .. (SaveManager and "🟢 SaveManager: Загружен\n" or "🔴 SaveManager: Ошибка\n")
statusText = statusText .. (InterfaceManager and "🟢 InterfaceManager: Загружен" or "🔴 InterfaceManager: Ошибка")

Tabs.Main:AddParagraph({
    Title = "Статус модулей",
    Content = statusText
})

-- Кнопка тестирования
Tabs.Main:AddButton({
    Title = "Тест уведомлений",
    Description = "Проверить работу системы уведомлений",
    Callback = function()
        Fluent:Notify({
            Title = "Тест пройден! ✅",
            Content = "Система уведомлений работает корректно",
            Duration = 3
        })
    end
})

-- === ESP ВКЛАДКА ===
print("[INFO] Настраиваем ESP...")

-- Переменные для ESP
local espEnabled = false
local espBoxes = {}
local espConnections = {}

-- Функция создания ESP для игрока
local function createESP(player)
    if player == game.Players.LocalPlayer then return end
    
    local function addESP()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
        
        if not humanoidRootPart then return end
        
        -- Создаем BillboardGui
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_" .. player.Name
        billboard.Adornee = humanoidRootPart
        billboard.Size = UDim2.new(4, 0, 6, 0)
        billboard.StudsOffset = Vector3.new(0, 0, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = game.CoreGui
        
        -- Создаем рамку
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
        frame.Parent = billboard
        
        -- Добавляем текст с именем
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, -0.1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextScaled = true
        nameLabel.Parent = billboard
        
        espBoxes[player] = billboard
    end
    
    if player.Character then
        addESP()
    end
    
    espConnections[player] = player.CharacterAdded:Connect(addESP)
end

-- Функция удаления ESP
local function removeESP(player)
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
    if espConnections[player] then
        espConnections[player]:Disconnect()
        espConnections[player] = nil
    end
end

-- Функция обновления ESP для всех игроков
local function updateESP()
    if espEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if not espBoxes[player] then
                createESP(player)
            end
        end
    else
        for player, _ in pairs(espBoxes) do
            removeESP(player)
        end
    end
end

-- ESP контролы
Tabs.ESP:AddToggle("ESPToggle", {
    Title = "Включить ESP",
    Description = "Показывать рамки вокруг игроков",
    Default = false
}):OnChanged(function(value)
    espEnabled = value
    updateESP()
    print("[ESP] ESP " .. (value and "включен" or "выключен"))
end)

-- Цвет ESP
local ESPColor = Tabs.ESP:AddColorpicker("ESPColor", {
    Title = "Цвет ESP",
    Description = "Изменить цвет рамок",
    Default = Color3.fromRGB(0, 255, 0)
})

ESPColor:OnChanged(function()
    local color = ESPColor.Value
    for _, billboard in pairs(espBoxes) do
        if billboard and billboard:FindFirstChild("Frame") then
            billboard.Frame.BorderColor3 = color
        end
    end
end)

-- Обработчики подключения/отключения игроков
game.Players.PlayerAdded:Connect(function(player)
    if espEnabled then
        createESP(player)
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- === ВКЛАДКА ИГРОКА ===
print("[INFO] Настраиваем управление игроком...")

-- Скорость ходьбы
local WalkSpeedSlider = Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Скорость ходьбы",
    Description = "Изменить скорость передвижения",
    Default = 16,
    Min = 1,
    Max = 100,
    Rounding = 1
})

WalkSpeedSlider:OnChanged(function(value)
    local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = value
    end
end)

-- Высота прыжка
local JumpPowerSlider = Tabs.Player:AddSlider("JumpPower", {
    Title = "Сила прыжка",
    Description = "Изменить высоту прыжка",
    Default = 50,
    Min = 1,
    Max = 200,
    Rounding = 1
})

JumpPowerSlider:OnChanged(function(value)
    local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        if humanoid.JumpPower then
            humanoid.JumpPower = value
        elseif humanoid.JumpHeight then
            humanoid.JumpHeight = value
        end
    end
end)

-- Невидимость
Tabs.Player:AddToggle("Invisible", {
    Title = "Невидимость",
    Description = "Сделать персонажа невидимым",
    Default = false
}):OnChanged(function(value)
    local character = game.Players.LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = value and 1 or 0
            elseif part:IsA("Accessory") then
                part.Handle.Transparency = value and 1 or 0
            end
        end
    end
end)

-- Полет
local flying = false
local flyConnection

local function toggleFly(enabled)
    flying = enabled
    local character = game.Players.LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart then return end
    
    if flying then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = humanoidRootPart
        
        flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local camera = workspace.CurrentCamera
            local moveVector = game.Players.LocalPlayer:GetMouse()
            
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                bodyVelocity.Velocity = bodyVelocity.Velocity + camera.CFrame.LookVector * 50
            end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                bodyVelocity.Velocity = bodyVelocity.Velocity - camera.CFrame.LookVector * 50
            end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                bodyVelocity.Velocity = bodyVelocity.Velocity - camera.CFrame.RightVector * 50
            end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                bodyVelocity.Velocity = bodyVelocity.Velocity + camera.CFrame.RightVector * 50
            end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                bodyVelocity.Velocity = bodyVelocity.Velocity + Vector3.new(0, 50, 0)
            end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
                bodyVelocity.Velocity = bodyVelocity.Velocity - Vector3.new(0, 50, 0)
            end
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
        end
        if humanoidRootPart:FindFirstChild("BodyVelocity") then
            humanoidRootPart.BodyVelocity:Destroy()
        end
    end
end

Tabs.Player:AddToggle("Fly", {
    Title = "Полет",
    Description = "Включить режим полета (WASD для управления)",
    Default = false
}):OnChanged(function(value)
    toggleFly(value)
end)

-- === ВКЛАДКА ТЕЛЕПОРТА ===
print("[INFO] Настраиваем телепорт...")

-- Телепорт к игроку
local playerNames = {}
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        table.insert(playerNames, player.Name)
    end
end

if #playerNames > 0 then
    local TeleportDropdown = Tabs.Teleport:AddDropdown("TeleportPlayer", {
        Title = "Телепорт к игроку",
        Description = "Выберите игрока для телепортации",
        Values = playerNames,
        Multi = false,
        Default = playerNames[1]
    })
    
    Tabs.Teleport:AddButton({
        Title = "Телепортироваться",
        Description = "Телепортироваться к выбранному игроку",
        Callback = function()
            local selectedPlayer = game.Players:FindFirstChild(Options.TeleportPlayer.Value)
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local localPlayer = game.Players.LocalPlayer
                if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    localPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
                    Fluent:Notify({
                        Title = "Телепорт выполнен! ✅",
                        Content = "Вы телепортировались к " .. selectedPlayer.Name,
                        Duration = 3
                    })
                end
            end
        end
    })
else
    Tabs.Teleport:AddParagraph({
        Title = "Нет доступных игроков",
        Content = "В игре нет других игроков для телепортации"
    })
end

-- === НАСТРОЙКИ ===
if SaveManager and InterfaceManager then
    print("[INFO] Настраиваем SaveManager...")
    
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    
    InterfaceManager:SetFolder("TridenESP")
    SaveManager:SetFolder("TridenESP/configs")
    
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)
    
    print("[SUCCESS] SaveManager настроен")
end

-- Выбираем первую вкладку
Window:SelectTab(1)

-- Загружаем сохраненные настройки
if SaveManager then
    SaveManager:LoadAutoloadConfig()
end

-- Финальные уведомления
Fluent:Notify({
    Title = "Triden ESP Suite загружен! 🚀",
    Content = "Все функции готовы к использованию. Нажмите LeftControl для сворачивания.",
    Duration = 5
})

print("=== TRIDEN ESP SUITE УСПЕШНО ЗАПУЩЕН ===")

-- Команда отладки в чат
game.Players.LocalPlayer.Chatted:Connect(function(message)
    if message:lower() == "/debug" then
        print("=== ОТЛАДОЧНАЯ ИНФОРМАЦИЯ ===")
        print("Fluent UI: " .. (Fluent and "✅ OK" or "❌ ERROR"))
        print("SaveManager: " .. (SaveManager and "✅ OK" or "❌ ERROR"))
        print("InterfaceManager: " .. (InterfaceManager and "✅ OK" or "❌ ERROR"))
        print("ESP активен: " .. (espEnabled and "✅ ДА" or "❌ НЕТ"))
        print("ESP объектов: " .. tostring(#espBoxes))
        print("Полет активен: " .. (flying and "✅ ДА" or "❌ НЕТ"))
        print("===============================")
    end
end)
