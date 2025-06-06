-- Загрузка библиотек Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Загрузка функций
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/ipso1337/tridenopenscr/main/functions.lua"))()

-- Загрузка BoxESP
local BoxESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ipso1337/tridenopenscr/main/BoxESP.lua"))()

-- Создание окна
local Window = Fluent:CreateWindow({
    Title = "Triden Client",
    SubTitle = "by ipso1337",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Вкладки
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Features = Window:AddTab({ Title = "Features", Icon = "zap" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Уведомление при загрузке
Fluent:Notify({
    Title = "Script Loaded",
    Content = "Triden Client успешно загружен!",
    Duration = 5
})

-- === MAIN TAB ===
Tabs.Main:AddParagraph({
    Title = "Добро пожаловать!",
    Content = "Это твой кастомный Roblox скрипт.\nПриятного использования!"
})

Tabs.Main:AddButton({
    Title = "Тест функции",
    Description = "Нажми для теста",
    Callback = function()
        Functions.testFunction()
    end
})

-- === FEATURES TAB ===
Tabs.Features:AddToggle("BoxESP_Toggle", {
    Title = "Box ESP",
    Default = false
}):OnChanged(function(state)
    BoxESP:Toggle(state)
end)

-- === SETTINGS TAB ===
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("TridenClient")
SaveManager:SetFolder("TridenClient/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Выбор первой вкладки
Window:SelectTab(1)

-- Автозагрузка конфигурации
SaveManager:LoadAutoloadConfig()

-- Финальное уведомление
Fluent:Notify({
    Title = "Готово!",
    Content = "Все функции успешно загружены.",
    Duration = 3
})
