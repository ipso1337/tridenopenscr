-- Загрузка библиотек Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Загрузка BoxESP
local BoxESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ipso1337/tridenopenscr/main/BoxESP.lua"))()

-- Загрузка PlayerBody класса
local PlayerBody = loadstring(game:HttpGet("https://raw.githubusercontent.com/ipso1337/tridenopenscr/refs/heads/main/PlayerBody.lua"))()

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

-- Вкладки
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    ESP = Window:AddTab({ Title = "ESP Settings", Icon = "eye" }),
    PlayerBody = Window:AddTab({ Title = "Player Body", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- === СОЗДАНИЕ ЭКЗЕМПЛЯРА PLAYERBODY ===
local playerBody = PlayerBody.new(game.Players.LocalPlayer)
playerBody:ConnectCharacterAdded()

-- Уведомление при загрузке
Fluent:Notify({
    Title = "Triden ESP Loaded",
    Content = "Press LeftControl to minimize the UI.",
    Duration = 5
})

-- === MAIN TAB ===
Tabs.Main:AddParagraph({
    Title = "Добро пожаловать!",
    Content = "Используйте вкладку **ESP Settings** для настройки визуализации.\nВкладка **Player Body** для управления телом игрока."
})

-- === ESP TAB ===
-- Включение/выключение ESP
Tabs.ESP:AddToggle("ESPEnabled", {
    Title = "Enable ESP",
    Default = false
}):OnChanged(function(state)
    BoxESP:Toggle(state)
end)

-- Выбор типа ESP
Tabs.ESP:AddDropdown("ESPType", {
    Title = "ESP Type",
    Values = {"Box", "Corner", "3D Box"},
    Default = "Box",
}):OnChanged(function(value)
    BoxESP:SetBoxType(value)
end)

-- Цвет ESP
local ColorPicker = Tabs.ESP:AddColorpicker("ESPColor", {
    Title = "ESP Color",
    Default = Color3.fromRGB(96, 205, 255) -- Голубой по умолчанию
})
ColorPicker:OnChanged(function()
    BoxESP:SetColor(ColorPicker.Value)
end)

-- Настройка прозрачности
Tabs.ESP:AddSlider("ESPTransparency", {
    Title = "Transparency",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Callback = function(value)
        BoxESP:SetTransparency(value)
    end
})

-- Показывать только видимых игроков
Tabs.ESP:AddToggle("ESPVisibleOnly", {
    Title = "Visible Only",
    Default = false,
    Callback = function(state)
        BoxESP:SetVisibleOnly(state)
    end
})

-- === PLAYER BODY TAB ===
-- Используем встроенный метод для создания контролов
playerBody:CreateFluentControls(Tabs.PlayerBody)

-- Дополнительный цветовой контрол
local BodyColorPicker = Tabs.PlayerBody:AddColorpicker("BodyColor", {
    Title = "Цвет тела",
    Default = Color3.fromRGB(163, 162, 165) -- Стандартный цвет тела
})
BodyColorPicker:OnChanged(function()
    playerBody:SetColor(BodyColorPicker.Value)
end)

-- === SETTINGS TAB ===
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("TridenESP")
SaveManager:SetFolder("TridenESP/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Загрузка сохраненных настроек
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

-- Финальное уведомление
Fluent:Notify({
    Title = "Все готово!",
    Content = "PlayerBody класс зарегистрирован и готов к использованию.",
    Duration = 4
})
