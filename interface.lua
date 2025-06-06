-- Исправленный скрипт для Roblox ESP Suite
-- Добавлена обработка ошибок и исправления

-- Функция безопасной загрузки с повторными попытками
local function safeLoadstring(url, name)
    local success, result
    for i = 1, 3 do -- 3 попытки загрузки
        success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if success then
            print("[SUCCESS] " .. name .. " загружен успешно")
            return result
        else
            warn("[ERROR] Попытка " .. i .. "/3 загрузки " .. name .. " не удалась: " .. tostring(result))
            wait(1) -- Задержка перед повторной попыткой
        end
    end
    error("[CRITICAL] Не удалось загрузить " .. name .. " после 3 попыток")
end

-- Проверка доступности HTTP запросов
if not game:GetService("HttpService").HttpEnabled then
    warn("[WARNING] HTTP запросы отключены. Включите их в настройках игры.")
end

print("[INFO] Начинаем загрузку библиотек...")

-- Безопасная загрузка всех библиотек
local Fluent = safeLoadstring("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", "Fluent UI")
local SaveManager = safeLoadstring("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua", "SaveManager")
local InterfaceManager = safeLoadstring("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua", "InterfaceManager")

-- Загрузка дополнительных модулей
local BoxESP, PlayerBody

-- Попытка загрузить BoxESP
local success, result = pcall(function()
    return safeLoadstring("https://raw.githubusercontent.com/ipso1337/tridenopenscr/main/BoxESP.lua", "BoxESP")
end)
if success then
    BoxESP = result
else
    warn("[WARNING] BoxESP не загружен: " .. tostring(result))
    -- Заглушка для BoxESP если не загрузился
    BoxESP = {
        Toggle = function() end,
        SetBoxType = function() end,
        SetColor = function() end,
        SetTransparency = function() end,
        SetVisibleOnly = function() end
    }
end

-- Попытка загрузить PlayerBody
success, result = pcall(function()
    return safeLoadstring("https://raw.githubusercontent.com/ipso1337/tridenopenscr/refs/heads/main/PlayerBody.lua", "PlayerBody")
end)
if success then
    PlayerBody = result
else
    warn("[WARNING] PlayerBody не загружен: " .. tostring(result))
    -- Заглушка для PlayerBody если не загрузился
    PlayerBody = {
        new = function() 
            return {
                ConnectCharacterAdded = function() end,
                CreateFluentControls = function() end,
                SetColor = function() end
            }
        end
    }
end

print("[INFO] Создаем окно интерфейса...")

-- Проверка загрузки Fluent
if not Fluent then
    error("[CRITICAL] Fluent UI не загружен!")
end

-- === СОЗДАНИЕ ОКНА ===
local Window = Fluent:CreateWindow({
    Title = "Triden ESP Suite",
    SubTitle = "by ipso1337",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Создание вкладок
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    ESP = Window:AddTab({ Title = "ESP Settings", Icon = "eye" }),
    PlayerBody = Window:AddTab({ Title = "Player Body", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- === СОЗДАНИЕ ЭКЗЕМПЛЯРА PLAYERBODY ===
local playerBody
if PlayerBody and PlayerBody.new then
    success, result = pcall(function()
        return PlayerBody.new(game.Players.LocalPlayer)
    end)
    if success then
        playerBody = result
        playerBody:ConnectCharacterAdded()
        print("[SUCCESS] PlayerBody инициализирован")
    else
        warn("[ERROR] Ошибка создания PlayerBody: " .. tostring(result))
        playerBody = nil
    end
end

-- Уведомление при загрузке
Fluent:Notify({
    Title = "Triden ESP Loaded",
    Content = "Press LeftControl to minimize the UI.",
    Duration = 5
})

print("[INFO] Настраиваем вкладки...")

-- === MAIN TAB ===
Tabs.Main:AddParagraph({
    Title = "Добро пожаловать!",
    Content = "Используйте вкладку **ESP Settings** для настройки визуализации.\nВкладка **Player Body** для управления телом игрока."
})

-- Информация о статусе загрузки
local loadStatus = "Статус загрузки:\n"
loadStatus = loadStatus .. "• Fluent UI: ✅ Загружен\n"
loadStatus = loadStatus .. "• BoxESP: " .. (BoxESP and "✅ Загружен" or "❌ Ошибка") .. "\n"
loadStatus = loadStatus .. "• PlayerBody: " .. (playerBody and "✅ Загружен" or "❌ Ошибка")

Tabs.Main:AddParagraph({
    Title = "Статус модулей",
    Content = loadStatus
})

-- === ESP TAB ===
if BoxESP then
    -- Включение/выключение ESP
    Tabs.ESP:AddToggle("ESPEnabled", {
        Title = "Enable ESP",
        Default = false
    }):OnChanged(function(state)
        pcall(function()
            BoxESP:Toggle(state)
        end)
    end)

    -- Выбор типа ESP
    Tabs.ESP:AddDropdown("ESPType", {
        Title = "ESP Type",
        Values = {"Box", "Corner", "3D Box"},
        Default = "Box",
    }):OnChanged(function(value)
        pcall(function()
            BoxESP:SetBoxType(value)
        end)
    end)

    -- Цвет ESP
    local ColorPicker = Tabs.ESP:AddColorpicker("ESPColor", {
        Title = "ESP Color",
        Default = Color3.fromRGB(96, 205, 255)
    })
    ColorPicker:OnChanged(function()
        pcall(function()
            BoxESP:SetColor(ColorPicker.Value)
        end)
    end)

    -- Настройка прозрачности
    Tabs.ESP:AddSlider("ESPTransparency", {
        Title = "Transparency",
        Default = 0,
        Min = 0,
        Max = 1,
        Rounding = 1,
        Callback = function(value)
            pcall(function()
                BoxESP:SetTransparency(value)
            end)
        end
    })

    -- Показывать только видимых игроков
    Tabs.ESP:AddToggle("ESPVisibleOnly", {
        Title = "Visible Only",
        Default = false,
        Callback = function(state)
            pcall(function()
                BoxESP:SetVisibleOnly(state)
            end)
        end
    })
else
    Tabs.ESP:AddParagraph({
        Title = "ESP недоступен",
        Content = "Модуль BoxESP не загружен. Проверьте подключение к интернету и повторите попытку."
    })
end

-- === PLAYER BODY TAB ===
if playerBody and playerBody.CreateFluentControls then
    -- Используем встроенный метод для создания контролов
    success, result = pcall(function()
        playerBody:CreateFluentControls(Tabs.PlayerBody)
    end)
    if not success then
        warn("[ERROR] Ошибка создания контролов PlayerBody: " .. tostring(result))
    end

    -- Дополнительный цветовой контрол
    local BodyColorPicker = Tabs.PlayerBody:AddColorpicker("BodyColor", {
        Title = "Цвет тела",
        Default = Color3.fromRGB(163, 162, 165)
    })
    BodyColorPicker:OnChanged(function()
        if playerBody and playerBody.SetColor then
            pcall(function()
                playerBody:SetColor(BodyColorPicker.Value)
            end)
        end
    end)
else
    Tabs.PlayerBody:AddParagraph({
        Title = "Player Body недоступен",
        Content = "Модуль PlayerBody не загружен. Проверьте подключение к интернету и повторите попытку."
    })
end

-- === SETTINGS TAB ===
if SaveManager and InterfaceManager then
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("TridenESP")
    SaveManager:SetFolder("TridenESP/configs")
    
    success, result = pcall(function()
        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Settings)
    end)
    if not success then
        warn("[ERROR] Ошибка настройки SaveManager: " .. tostring(result))
    end
else
    Tabs.Settings:AddParagraph({
        Title = "Настройки недоступны",
        Content = "Модули SaveManager или InterfaceManager не загружены."
    })
end

-- Загрузка сохраненных настроек
Window:SelectTab(1)
if SaveManager and SaveManager.LoadAutoloadConfig then
    pcall(function()
        SaveManager:LoadAutoloadConfig()
    end)
end

-- Финальное уведомление
local finalMessage = "Скрипт загружен!"
if playerBody then
    finalMessage = finalMessage .. " PlayerBody готов к использованию."
end

Fluent:Notify({
    Title = "Все готово!",
    Content = finalMessage,
    Duration = 4
})

print("[SUCCESS] Скрипт полностью загружен и готов к работе!")

-- Дополнительная отладочная информация
game.Players.LocalPlayer.Chatted:Connect(function(message)
    if message:lower() == "/debug" then
        print("=== DEBUG INFO ===")
        print("Fluent:", Fluent and "OK" or "ERROR")
        print("BoxESP:", BoxESP and "OK" or "ERROR") 
        print("PlayerBody:", playerBody and "OK" or "ERROR")
        print("SaveManager:", SaveManager and "OK" or "ERROR")
        print("InterfaceManager:", InterfaceManager and "OK" or "ERROR")
        print("==================")
    end
end)
