local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local ESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/ipso1337/tridenopenscr/main/ESPModule.lua"))()

local Window = Fluent:CreateWindow({
    Title = "TRIDENT ESP v2.0",
    SubTitle = "by ipso1337",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    PlayerESP = Window:AddTab({ Title = "Player ESP", Icon = "user" }),
    ObjectESP = Window:AddTab({ Title = "Object ESP", Icon = "package" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Player ESP Tab
do
    -- Main toggle
    Tabs.PlayerESP:AddToggle("PlayerESPEnabled", {
        Title = "Enable Player ESP",
        Default = false,
        Callback = function(value)
            ESPModule.Toggle("Players", value)
        end
    })

    -- Box ESP
    local BoxToggle = Tabs.PlayerESP:AddToggle("BoxESP", {
        Title = "Box ESP",
        Default = false,
        Callback = function(value)
            ESPModule.ToggleSetting("Players", "Box", value)
        end
    })
    
    BoxToggle:AddColorPicker("BoxColor", {
        Title = "Box Color",
        Default = Color3.new(1, 1, 1),
        Callback = function(color)
            ESPModule.UpdateSetting("Players", "BoxColor", color)
        end
    })

    -- Name ESP
    Tabs.PlayerESP:AddToggle("NameESP", {
        Title = "Show Names",
        Default = true,
        Callback = function(value)
            ESPModule.ToggleSetting("Players", "Names", value)
        end
    })

    -- Health ESP
    Tabs.PlayerESP:AddToggle("HealthESP", {
        Title = "Show Health",
        Default = true,
        Callback = function(value)
            ESPModule.ToggleSetting("Players", "Health", value)
        end
    })

    -- Chams
    local ChamsToggle = Tabs.PlayerESP:AddToggle("Chams", {
        Title = "Chams",
        Default = false,
        Callback = function(value)
            ESPModule.ToggleSetting("Players", "Chams", value)
        end
    })
    
    ChamsToggle:AddColorPicker("ChamsColor", {
        Title = "Chams Color",
        Default = Color3.fromRGB(255, 0, 255),
        Callback = function(color)
            ESPModule.UpdateSetting("Players", "ChamsColor", color)
        end
    })
end

-- Object ESP Tab
do
    Tabs.ObjectESP:AddToggle("ObjectESPEnabled", {
        Title = "Enable Object ESP",
        Default = false,
        Callback = function(value)
            ESPModule.Toggle("Objects", value)
        end
    })

    Tabs.ObjectESP:AddDropdown("ObjectTypes", {
        Title = "Object Types",
        Values = {"Stone", "Nitrate", "Iron", "Tree", "ATV", "Backpack"},
        Multi = true,
        Default = {"Stone", "Nitrate", "Iron"},
        Callback = function(selected)
            ESPModule.UpdateSetting("Objects", "Filter", selected)
        end
    })

    Tabs.ObjectESP:AddColorPicker("ObjectColor", {
        Title = "Object Color",
        Default = Color3.fromRGB(0, 255, 255),
        Callback = function(color)
            ESPModule.UpdateSetting("Objects", "Color", color)
        end
    })
end

-- Settings Tab
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
