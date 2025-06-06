-- PlayerBody.lua - Класс для управления всеми частями тела игрока в Roblox
local PlayerBody = {}
PlayerBody.__index = PlayerBody

-- Конструктор класса
function PlayerBody.new(player)
    local self = setmetatable({}, PlayerBody)
    
    -- Ссылка на игрока
    self.Player = player or game.Players.LocalPlayer
    
    -- Ссылка на модель персонажа
    self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
    
    -- Инициализация всех частей тела
    self:InitializeBodyParts()
    
    return self
end

-- Инициализация всех частей тела
function PlayerBody:InitializeBodyParts()
    -- Основные части тела
    self.BodyParts = {
        -- Голова и шея
        Head = self.Character:FindFirstChild("Head"),
        
        -- Туловище
        Torso = self.Character:FindFirstChild("Torso"),
        UpperTorso = self.Character:FindFirstChild("UpperTorso"),
        LowerTorso = self.Character:FindFirstChild("LowerTorso"),
        
        -- Руки
        LeftArm = self.Character:FindFirstChild("LeftArm"),
        RightArm = self.Character:FindFirstChild("RightArm"),
        LeftUpperArm = self.Character:FindFirstChild("LeftUpperArm"),
        RightUpperArm = self.Character:FindFirstChild("RightUpperArm"),
        LeftLowerArm = self.Character:FindFirstChild("LeftLowerArm"),
        RightLowerArm = self.Character:FindFirstChild("RightLowerArm"),
        
        -- Кисти рук
        LeftHand = self.Character:FindFirstChild("LeftHand"),
        RightHand = self.Character:FindFirstChild("RightHand"),
        
        -- Ноги
        LeftLeg = self.Character:FindFirstChild("LeftLeg"),
        RightLeg = self.Character:FindFirstChild("RightLeg"),
        LeftUpperLeg = self.Character:FindFirstChild("LeftUpperLeg"),
        RightUpperLeg = self.Character:FindFirstChild("RightUpperLeg"),
        LeftLowerLeg = self.Character:FindFirstChild("LeftLowerLeg"),
        RightLowerLeg = self.Character:FindFirstChild("RightLowerLeg"),
        
        -- Стопы
        LeftFoot = self.Character:FindFirstChild("LeftFoot"),
        RightFoot = self.Character:FindFirstChild("RightFoot")
    }
    
    -- Удаляем несуществующие части
    for partName, part in pairs(self.BodyParts) do
        if not part then
            self.BodyParts[partName] = nil
        end
    end
end

-- Получить все существующие части тела
function PlayerBody:GetAllParts()
    return self.BodyParts
end

-- Получить конкретную часть тела
function PlayerBody:GetPart(partName)
    return self.BodyParts[partName]
end

-- Проверить, существует ли часть тела
function PlayerBody:HasPart(partName)
    return self.BodyParts[partName] ~= nil
end

-- Получить количество частей тела
function PlayerBody:GetPartCount()
    local count = 0
    for _, _ in pairs(self.BodyParts) do
        count = count + 1
    end
    return count
end

-- Применить функцию ко всем частям тела
function PlayerBody:ForEachPart(callback)
    for partName, part in pairs(self.BodyParts) do
        callback(partName, part)
    end
end

-- Изменить прозрачность всех частей тела
function PlayerBody:SetTransparency(transparency)
    self:ForEachPart(function(partName, part)
        if part then
            part.Transparency = transparency
        end
    end)
end

-- Изменить цвет всех частей тела
function PlayerBody:SetColor(color)
    self:ForEachPart(function(partName, part)
        if part then
            part.Color = color
        end
    end)
end

-- Изменить материал всех частей тела
function PlayerBody:SetMaterial(material)
    self:ForEachPart(function(partName, part)
        if part then
            part.Material = material
        end
    end)
end

-- Сделать все части тела невидимыми
function PlayerBody:MakeInvisible()
    self:SetTransparency(1)
end

-- Сделать все части тела видимыми
function PlayerBody:MakeVisible()
    self:SetTransparency(0)
end

-- Включить/выключить CanCollide для всех частей
function PlayerBody:SetCanCollide(canCollide)
    self:ForEachPart(function(partName, part)
        if part then
            part.CanCollide = canCollide
        end
    end)
end

-- Получить позицию центра тела (обычно торс)
function PlayerBody:GetCenterPosition()
    local torso = self.BodyParts.Torso or self.BodyParts.UpperTorso
    if torso then
        return torso.Position
    end
    return Vector3.new(0, 0, 0)
end

-- Получить HumanoidRootPart (если есть)
function PlayerBody:GetRootPart()
    return self.Character:FindFirstChild("HumanoidRootPart")
end

-- Получить Humanoid (если есть)
function PlayerBody:GetHumanoid()
    return self.Character:FindFirstChildOfClass("Humanoid")
end

-- Обновить ссылки на части тела (полезно после респавна)
function PlayerBody:RefreshBodyParts()
    self.Character = self.Player.Character
    if self.Character then
        self:InitializeBodyParts()
    end
end

-- Подключить обновление при смене персонажа
function PlayerBody:ConnectCharacterAdded()
    self.Player.CharacterAdded:Connect(function(character)
        self.Character = character
        self:InitializeBodyParts()
    end)
end

-- Получить информацию о частях тела в виде таблицы
function PlayerBody:GetBodyInfo()
    local info = {
        PlayerName = self.Player.Name,
        CharacterName = self.Character.Name,
        PartCount = self:GetPartCount(),
        Parts = {}
    }
    
    self:ForEachPart(function(partName, part)
        info.Parts[partName] = {
            Name = part.Name,
            Position = part.Position,
            Size = part.Size,
            Transparency = part.Transparency,
            Color = part.Color,
            Material = part.Material.Name
        }
    end)
    
    return info
end

-- Метод для интеграции с Fluent GUI
function PlayerBody:CreateFluentControls(tab)
    if not tab then
        warn("PlayerBody: Не передан Tab для создания контролов")
        return
    end
    
    -- Параграф с информацией
    tab:AddParagraph({
        Title = "Player Body Info",
        Content = "Игрок: " .. self.Player.Name .. "\nЧастей тела: " .. self:GetPartCount()
    })
    
    -- Слайдер прозрачности
    local TransparencySlider = tab:AddSlider("BodyTransparency", {
        Title = "Прозрачность тела",
        Description = "Изменить прозрачность всех частей тела",
        Default = 0,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            self:SetTransparency(Value)
        end
    })
    
    -- Переключатель коллизии
    local CollisionToggle = tab:AddToggle("BodyCollision", {
        Title = "Коллизия тела", 
        Default = true,
        Callback = function(Value)
            self:SetCanCollide(Value)
        end
    })
    
    -- Кнопки быстрых действий
    tab:AddButton({
        Title = "Сделать невидимым",
        Description = "Полностью скрыть тело",
        Callback = function()
            self:MakeInvisible()
            TransparencySlider:SetValue(1)
        end
    })
    
    tab:AddButton({
        Title = "Сделать видимым",
        Description = "Показать тело",
        Callback = function()
            self:MakeVisible()
            TransparencySlider:SetValue(0)
        end
    })
    
    -- Выпадающий список материалов
    local MaterialDropdown = tab:AddDropdown("BodyMaterial", {
        Title = "Материал тела",
        Values = {"Plastic", "Wood", "Slate", "Concrete", "CorrodedMetal", "DiamondPlate", "Foil", "Grass", "Ice", "Marble", "Granite", "Brick", "Pebble", "Sand", "Fabric", "SmoothPlastic", "Metal", "WoodPlanks", "Cobblestone", "Neon", "Glass"},
        Multi = false,
        Default = "Plastic",
        Callback = function(Value)
            self:SetMaterial(Enum.Material[Value])
        end
    })
    
    -- Кнопка обновления
    tab:AddButton({
        Title = "Обновить части тела",
        Description = "Обновить ссылки на части тела",
        Callback = function()
            self:RefreshBodyParts()
        end
    })
end

-- Деструктор (очистка ресурсов)
function PlayerBody:Destroy()
    self.Player = nil
    self.Character = nil
    self.BodyParts = nil
end

return PlayerBody
