-- interface.lua
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/ipso1337/tridenopenscr/refs/heads/main/functions.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ipso1337/tridenopenscr/refs/heads/main/BoxESP.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Your Script Name",
    SubTitle = "by YourName",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

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

Tabs.Main:AddButton({
    Title = "Test Function",
    Description = "Click to test a function",
    Callback = function()
        Functions.testFunction()
    end
})

-- === FEATURES TAB ===

-- Включение фичи
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

-- Слайдер скорости
local SpeedSlider = Tabs.Features:AddSlider("SpeedSlider", {
    Title = "Speed",
    Description = "Adjust the speed",
    Default = 16,
    Min = 1,
    Max = 100,
    Rounding = 1,
    Callback = function(value)
        Functions.setSpeed(value)
    end
})

-- Выпадающий список для выбора режима
local ModeDropdown = Tabs.Features:AddDropdown("ModeDropdown", {
    Title = "Mode",
    Values = {"Mode 1", "Mode 2", "Mode 3"},
    Multi = false,
    Default = 1
})

ModeDropdown:OnChanged(function(value)
    Functions.changeMode(value)
end)

-- Привязка клавиши для переключения скрипта
local MainKeybind = Tabs.Features:AddKeybind("MainKeybind", {
    Title = "Toggle Script",
    Mode = "Toggle",
    Default = "F",
    Callback = function(value)
        Functions.toggleScript(value)
    end
})

-- Ввод имени игрока
local PlayerInput = Tabs.Features:AddInput("PlayerInput", {
    Title = "Player Name",
    Default = "",
    Placeholder = "Enter player name...",
    Numeric = false,
    Finished = false,
    Callback = function(value)
        Functions.setTargetPlayer(value)
    end
})

-- Цветовая палитра для темы
local ColorPicker = Tabs.Features:AddColorpicker("ColorPicker", {
    Title = "Theme Color",
    Default = Color3.fromRGB(96, 205, 255)
})

ColorPicker:OnChanged(function()
    Functions.setThemeColor(ColorPicker.Value)
end)

-- === ESP Box Settings ===

local BoxTypeDropdown = Tabs.Features:AddDropdown("BoxTypeDropdown", {
    Title = "Box Type",
    Values = {"2D Box", "3D Box", "Corner Box"},
    Default = 1
})

BoxTypeDropdown:OnChanged(function(value)
    ESP.BoxType = value
end)

local BoxThicknessSlider = Tabs.Features:AddSlider("BoxThicknessSlider", {
    Title = "Box Thickness",
    Min = 1,
    Max = 5,
    Default = 2,
    Rounding = 0
})

BoxThicknessSlider:OnChanged(function(value)
    ESP.BoxThickness = value
end)

local BoxTransparencySlider = Tabs.Features:AddSlider("BoxTransparencySlider", {
    Title = "Box Transparency",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Rounding = 0.1
})

BoxTransparencySlider:OnChanged(function(value)
    ESP.BoxTransparency = value
end)

-- === SETTINGS TAB ===

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

return {
    Window = Window,
    Tabs = Tabs,
    Options = Options,
    ESP = ESP
}
