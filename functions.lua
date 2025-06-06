-- functions.lua - Все функции и логика скрипта
local Functions = {}

-- Переменные для хранения состояния
local isFeatureEnabled = false
local currentSpeed = 16
local currentMode = "Mode 1"
local isScriptActive = false
local targetPlayer = ""
local themeColor = Color3.fromRGB(96, 205, 255)

-- Сервисы Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- === ОСНОВНЫЕ ФУНКЦИИ ===

-- Тестовая функция
function Functions.testFunction()
    print("Test function called!")
    LocalPlayer:Kick("This is a test function!")
end

-- Включение фичи
function Functions.enableFeature()
    isFeatureEnabled = true
    print("Feature enabled!")
    
    -- Здесь добавьте вашу логику
    -- Например:
    -- spawn(function()
    --     while isFeatureEnabled do
    --         -- Ваш код здесь
    --         wait(0.1)
    --     end
    -- end)
end

-- Отключение фичи
function Functions.disableFeature()
    isFeatureEnabled = false
    print("Feature disabled!")
end

-- Установка скорости
function Functions.setSpeed(speed)
    currentSpeed = speed
    print("Speed set to:", speed)
    
    -- Пример применения скорости к персонажу
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end
end

-- Смена режима
function Functions.changeMode(mode)
    currentMode = mode
    print("Mode changed to:", mode)
    
    -- Логика для разных режимов
    if mode == "Mode 1" then
        -- Логика для режима 1
        print("Executing Mode 1 logic")
    elseif mode == "Mode 2" then
        -- Логика для режима 2
        print("Executing Mode 2 logic")
    elseif mode == "Mode 3" then
        -- Логика для режима 3
        print("Executing Mode 3 logic")
    end
end

-- Переключение скрипта
function Functions.toggleScript(state)
    isScriptActive = state
    print("Script toggled:", state and "ON" or "OFF")
    
    if state then
        -- Включить основной функционал
        print("Main script functionality activated")
        -- Здесь ваш основной код
    else
        -- Отключить основной функционал
        print("Main script functionality deactivated")
    end
end

-- Установка целевого игрока
function Functions.setTargetPlayer(playerName)
    targetPlayer = playerName
    print("Target player set to:", playerName)
    
    -- Поиск игрока
    local player = Players:FindFirstChild(playerName)
    if player then
        print("Player found:", player.Name)
        -- Ваша логика для работы с игроком
    else
        print("Player not found!")
    end
end

-- Установка цвета темы
function Functions.setThemeColor(color)
    themeColor = color
    print("Theme color set to:", color)
    
    -- Здесь можете применить цвет к элементам UI или персонажу
end

-- === ДОПОЛНИТЕЛЬНЫЕ УТИЛИТЫ ===

-- Получение всех игроков
function Functions.getAllPlayers()
    local playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        table.insert(playerNames, player.Name)
    end
    return playerNames
end

-- Телепортация к игроку
function Functions.teleportToPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            print("Teleported to", playerName)
        end
    else
        print("Cannot teleport to", playerName)
    end
end

-- Получение позиции игрока
function Functions.getPlayerPosition(playerName)
    local player = Players:FindFirstChild(playerName)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        return player.Character.HumanoidRootPart.Position
    end
    return nil
end

-- Проверка, находится ли игрок в игре
function Functions.isPlayerInGame(playerName)
    return Players:FindFirstChild(playerName) ~= nil
end

-- === СИСТЕМНЫЕ ФУНКЦИИ ===

-- Очистка всех ресурсов
function Functions.cleanup()
    isFeatureEnabled = false
    isScriptActive = false
    print("Script cleaned up!")
end

-- Получение текущего состояния
function Functions.getStatus()
    return {
        featureEnabled = isFeatureEnabled,
        speed = currentSpeed,
        mode = currentMode,
        scriptActive = isScriptActive,
        targetPlayer = targetPlayer,
        themeColor = themeColor
    }
end

-- === СОБЫТИЯ ===

-- Обработка отключения игрока
Players.PlayerRemoving:Connect(function(player)
    if player.Name == targetPlayer then
        print("Target player left the game")
        targetPlayer = ""
    end
end)

-- Обработка смерти персонажа
LocalPlayer.CharacterAdded:Connect(function(character)
    -- Восстановление настроек после респавна
    wait(1) -- Небольшая задержка
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = currentSpeed
    end
end)

-- Возврат модуля функций
return Functions
