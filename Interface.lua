local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Локальные версии менеджеров (чтобы не зависеть от GitHub)
local function CreateSaveManager()
    local SaveManager = {
        Configs = {},
        IgnoreIndexes = {},
        Folder = "FluentConfigs",
        Library = nil
    }
    
    function SaveManager:SetLibrary(lib)
        self.Library = lib
    end
    
    function SaveManager:SetFolder(folder)
        self.Folder = folder
        if not isfolder(self.Folder) then
            makefolder(self.Folder)
        end
    end
    
    function SaveManager:IgnoreThemeSettings()
        self.IgnoreIndexes = {"Theme", "ThemeColor"}
    end
    
    function SaveManager:SaveConfig(name)
        local config = {}
        for key, option in pairs(self.Library.Options) do
            if not table.find(self.IgnoreIndexes, key) then
                config[key] = option.Value
            end
        end
        
        local success, json = pcall(function()
            return game:GetService("HttpService"):JSONEncode(config)
        end)
        
        if success then
            writefile(self.Folder.."/"..name..".json", json)
        end
    end
    
    function SaveManager:LoadConfig(name)
        if not isfile(self.Folder.."/"..name..".json") then return false end
        
        local success, config = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(self.Folder.."/"..name..".json"))
        end)
        
        if success and config then
            for key, value in pairs(config) do
                if self.Library.Options[key] then
                    pcall(function()
                        self.Library.Options[key]:SetValue(value)
                    end)
                end
            end
            return true
        end
        return false
    end
    
    function SaveManager:BuildConfigSection(tab)
        local group = tab:AddGroupbox("Config Manager")
        
        local Input = group:AddInput("ConfigName", {
            Title = "Config Name",
            Default = "default",
            Placeholder = "config name",
            Numeric = false,
            Finished = false
        })
        
        group:AddButton({
            Title = "Save Config",
            Callback = function()
                self:SaveConfig(Input.Value)
                Fluent:Notify({
                    Title = "Config Saved",
                    Content = "Config '"..Input.Value.."' has been saved.",
                    Duration = 5
                })
            end
        })
        
        group:AddButton({
            Title = "Load Config",
            Callback = function()
                if self:LoadConfig(Input.Value) then
                    Fluent:Notify({
                        Title = "Config Loaded",
                        Content = "Config '"..Input.Value.."' has been loaded.",
                        Duration = 5
                    })
                else
                    Fluent:Notify({
                        Title = "Error",
                        Content = "Config '"..Input.Value.."' not found.",
                        Duration = 5
                    })
                end
            end
        })
    end
    
    return SaveManager
end

-- Инициализация интерфейса
local Window = Fluent:CreateWindow({
    Title = "ESP Hack v3.1",
    SubTitle = "Fixed Version",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

-- Вкладки
local Tabs = {
    ESP = Window:AddTab({ Title = "Player ESP", Icon = "user" }),
    ObjectESP = Window:AddTab({ Title = "Object ESP", Icon = "package" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Загрузка ESP модуля
local ESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/ipso1337/tridenopenscr/main/ESPModule.lua"))()

-- Инициализация ESP
pcall(function()
    ESPModule.Init()
end)

-- Player ESP Tab
do
    local group = Tabs.ESP:AddGroupbox("Player ESP Settings")
    
    group:AddToggle("ESPEnabled", {
        Title = "Enable Player ESP",
        Default = false,
        Callback = function(value)
            pcall(function()
                ESPModule.Toggle("Players", value)
            end)
        end
    })
    
    local BoxToggle = group:AddToggle("BoxESP", {
        Title = "Box ESP",
        Default = true,
        Callback = function(value)
            pcall(function()
                ESPModule.ToggleSetting("Players", "Box", value)
            end)
        end
    })
    
    BoxToggle:AddColorPicker("BoxColor", {
        Title = "Box Color",
        Default = Color3.new(1, 1, 1),
        Callback = function(color)
            pcall(function()
                ESPModule.UpdateSetting("Players", "BoxColor", color)
            end)
        end
    })
    
    group:AddToggle("NameESP", {
        Title = "Show Names",
        Default = true,
        Callback = function(value)
            pcall(function()
                ESPModule.ToggleSetting("Players", "Names", value)
            end)
        end
    })
    
    group:AddToggle("HealthESP", {
        Title = "Show Health",
        Default = true,
        Callback = function(value)
            pcall(function()
                ESPModule.ToggleSetting("Players", "Health", value)
            end)
        end
    })
    
    local ChamsToggle = group:AddToggle("Chams", {
        Title = "Chams",
        Default = false,
        Callback = function(value)
            pcall(function()
                ESPModule.ToggleSetting("Players", "Chams", value)
            end)
        end
    })
    
    ChamsToggle:AddColorPicker("ChamsColor", {
        Title = "Chams Color",
        Default = Color3.fromRGB(255, 0, 255),
        Callback = function(color)
            pcall(function()
                ESPModule.UpdateSetting("Players", "ChamsColor", color)
            end)
        end
    })
end

-- Object ESP Tab
do
    local group = Tabs.ObjectESP:AddGroupbox("Object ESP Settings")
    
    group:AddToggle("ObjectESPEnabled", {
        Title = "Enable Object ESP",
        Default = false,
        Callback = function(value)
            pcall(function()
                ESPModule.Toggle("Objects", value)
            end)
        end
    })
    
    group:AddDropdown("ObjectTypes", {
        Title = "Object Types",
        Values = {"Stone", "Nitrate", "Iron", "Tree", "ATV", "Backpack"},
        Multi = true,
        Default = {"Stone", "Nitrate", "Iron"},
        Callback = function(selected)
            pcall(function()
                ESPModule.UpdateSetting("Objects", "Filter", selected)
            end)
        end
    })
    
    group:AddColorPicker("ObjectColor", {
        Title = "Object Color",
        Default = Color3.fromRGB(0, 255, 255),
        Callback = function(color)
            pcall(function()
                ESPModule.UpdateSetting("Objects", "Color", color)
            end)
        end
    })
end

-- Settings Tab
do
    local SaveManager = CreateSaveManager()
    SaveManager:SetLibrary(Fluent)
    SaveManager:SetFolder("ESP_Configs_v3")
    SaveManager:IgnoreThemeSettings()
    SaveManager:BuildConfigSection(Tabs.Settings)
    
    local group = Tabs.Settings:AddGroupbox("Interface Settings")
    
    group:AddDropdown("Theme", {
        Title = "Theme",
        Values = Fluent.Themes,
        Default = "Dark",
        Callback = function(value)
            Fluent:SetTheme(value)
        end
    })
    
    group:AddColorPicker("ThemeColor", {
        Title = "Theme Color",
        Default = Fluent.ThemeColor,
        Callback = function(value)
            Fluent:SetThemeColor(value)
        end
    })
end

-- Загрузка конфига по умолчанию
task.spawn(function()
    wait(1)
    pcall(function()
        local SaveManager = CreateSaveManager()
        SaveManager:SetLibrary(Fluent)
        SaveManager:SetFolder("ESP_Configs_v3")
        SaveManager:LoadConfig("default")
    end)
end)

Window:SelectTab(1)
Fluent:Notify({
    Title = "ESP Hack",
    Content = "Interface loaded successfully!",
    Duration = 5
})
