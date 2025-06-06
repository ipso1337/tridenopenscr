local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SWIMHUB ESP",
    SubTitle = "by swimhub.xyz",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 580),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    ESP = Window:AddTab({ Title = "Player ESP", Icon = "user" }),
    ObjectESP = Window:AddTab({ Title = "Object ESP", Icon = "package" }),
    Config = Window:AddTab({ Title = "Config", Icon = "settings" })
}

-- Загрузка модуля ESP
local ESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourrepo/ESPModule.lua"))()

-- Вкладка Player ESP
do
    -- Основные настройки
    Tabs.ESP:AddToggle("ESPEnabled", {
        Title = "Enable ESP",
        Default = false,
        Callback = function(Value)
            ESPModule.TogglePlayerESP(Value)
        end
    })

    Tabs.ESP:AddDropdown("ESPFont", {
        Title = "Font",
        Values = {"UI", "System", "Plex", "Monospace"},
        Default = 4,
        Callback = function(Value)
            ESPModule.SetFont(Value)
        end
    })

    -- Настройки боксов
    local BoxToggle = Tabs.ESP:AddToggle("BoxESP", {
        Title = "Box ESP",
        Default = false,
        Callback = function(Value)
            ESPModule.ToggleBoxESP(Value)
        end
    })

    BoxToggle:AddColorPicker("BoxColor", {
        Default = Color3.new(1, 1, 1),
        Callback = function(Value)
            ESPModule.SetBoxColor(Value)
        end
    })

    -- Настройки скелетона
    Tabs.ESP:AddToggle("SkeletonESP", {
        Title = "Skeleton ESP",
        Default = false,
        Callback = function(Value)
            ESPModule.ToggleSkeletonESP(Value)
        end
    })

    -- Настройки чамсов
    Tabs.ESP:AddToggle("ChamsEnabled", {
        Title = "Chams",
        Default = false,
        Callback = function(Value)
            ESPModule.ToggleChams(Value)
        end
    })
end

-- Вкладка Object ESP
do
    Tabs.ObjectESP:AddToggle("ObjectESPEnabled", {
        Title = "Enable Object ESP",
        Default = false,
        Callback = function(Value)
            ESPModule.ToggleObjectESP(Value)
        end
    })

    Tabs.ObjectESP:AddDropdown("ObjectsFilter", {
        Title = "Objects Filter",
        Values = {"Stone", "Nitrate", "Iron", "Tree", "ATV"},
        Multi = true,
        Default = {},
        Callback = function(Value)
            ESPModule.SetObjectFilter(Value)
        end
    })
end

-- Настройки конфигурации
InterfaceManager:BuildInterfaceSection(Tabs.Config)
SaveManager:BuildConfigSection(Tabs.Config)
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("SWIMHUB_ESP")

Window:SelectTab(1)
