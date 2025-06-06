-- Загрузка библиотек Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Загрузка функций (замените YOUR_USERNAME и YOUR_REPO_NAME на свои)
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO_NAME/main/functions.lua"))()

-- Создание окна
local Window = Fluent:CreateWindow({
    Title = "Your Script Name",
    SubTitle = "by YourName",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Создание вкладок
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Features = Window:AddTab({ Title = "Features", Icon = "zap" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Уведомление о загрузке
Fluent:Notify({
    Title = "Script Loaded",
    Content = "Your script has been successfully loaded!",
    Duration = 5
})

-- === MAIN TAB ===
Tabs.Main:AddParagraph({
    Title = "Welcome!",
    Content = "This is your custom Roblox script.\nEnjoy using it!"
})

-- Пример кнопки
Tabs.Main:AddButton({
    Title = "Test Function",
    Description = "Click to test a function",
    Callback = function()
        Functions.testFunction() -- Вызов функции из functions.lua
    end
})

-- === FEATURES TAB ===
-- Переключатель
local FeatureToggle = Tabs.Features:AddToggle("FeatureToggle", {
    Title = "Enable Feature", 
    Default = false 
})

FeatureToggle:OnChanged(function()
    if Options.FeatureToggle.Value then
        Functions.enableFeature()
    else
        Functions.disableFeature()
    end
end)

-- Слайдер
local SpeedSlider = Tabs.Features:AddSlider("SpeedSlider", {
    Title = "Speed",
    Description = "Adjust the speed",
    Default = 16,
    Min = 1,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        Functions.setSpeed(Value)
    end
})

-- Выпадающий список
local ModeDropdown = Tabs.Features:AddDropdown("ModeDropdown", {
    Title = "Mode",
    Values = {"Mode 1", "Mode 2", "Mode 3"},
    Multi = false,
    Default = 1,
})

ModeDropdown:OnChanged(function(Value)
    Functions.changeMode(Value)
end)

-- Привязка клавиш
local MainKeybind = Tabs.Features:AddKeybind("MainKeybind", {
    Title = "Toggle Script",
    Mode = "Toggle",
    Default = "F",
    Callback = function(Value)
        Functions.toggleScript(Value)
    end
})

-- Поле ввода
local PlayerInput = Tabs.Features:AddInput("PlayerInput", {
    Title = "Player Name",
    Default = "",
    Placeholder = "Enter player name...",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        Functions.setTargetPlayer(Value)
    end
})

-- Цветовая палитра
local ColorPicker = Tabs.Features:AddColorpicker("ColorPicker", {
    Title = "Theme Color",
    Default = Color3.fromRGB(96, 205, 255)
})

ColorPicker:OnChanged(function()
    Functions.setThemeColor(ColorPicker.Value)
end)

-- === SETTINGS TAB ===
-- Менеджеры конфигурации
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("YourScriptName")
SaveManager:SetFolder("YourScriptName/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Выбор первой вкладки
Window:SelectTab(1)

-- Автозагрузка конфигурации
SaveManager:LoadAutoloadConfig()

-- Финальное уведомление
Fluent:Notify({
    Title = "Ready!",
    Content = "All features loaded successfully.",
    Duration = 3
})
