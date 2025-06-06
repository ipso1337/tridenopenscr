local ESP = {
    Players = {},
    Objects = {},
    Settings = {
        Enabled = false,
        Box = {
            Enabled = false,
            Color = Color3.new(1, 1, 1),
            Fill = false,
            FillColor = Color3.new(1, 0, 0),
            Transparency = 0.5
        },
        Skeleton = {
            Enabled = false,
            Color = Color3.new(1, 1, 1)
        },
        Chams = {
            Enabled = false,
            Color = Color3.new(1, 0, 1),
            Transparency = 0.5
        },
        ObjectESP = {
            Enabled = false,
            Filter = {}
        }
    }
}

-- Инициализация
function ESP.Init()
    -- Создаем подключения к игре
    game:GetService("Workspace").ChildAdded:Connect(function(child)
        ESP.AddChild(child)
    end)

    game:GetService("Workspace").ChildRemoved:Connect(function(child)
        ESP.RemoveChild(child)
    end)

    -- Инициализируем существующие объекты
    for _, child in pairs(game:GetService("Workspace"):GetChildren()) do
        ESP.AddChild(child)
    end
end

-- Добавление объекта
function ESP.AddChild(child)
    if child:FindFirstChild("Humanoid") then
        ESP.CreatePlayerESP(child)
    elseif table.find({"Stone", "Nitrate", "Iron"}, child.Name) then
        ESP.CreateObjectESP(child)
    end
end

-- Создание ESP для игрока
function ESP.CreatePlayerESP(character)
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Chams = Instance.new("Highlight")
    }
    
    -- Настройка внешнего вида
    esp.Box.Visible = false
    esp.Box.Color = ESP.Settings.Box.Color
    esp.Box.Thickness = 1
    
    -- Добавляем в таблицу
    ESP.Players[character] = esp
end

-- Обновление ESP
function ESP.Update()
    for character, esp in pairs(ESP.Players) do
        if character:IsDescendantOf(workspace) then
            local head = character:FindFirstChild("Head")
            if head then
                local position, onScreen = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- Обновляем позиции элементов ESP
                    esp.Box.Position = Vector2.new(position.X, position.Y)
                    esp.Box.Size = Vector2.new(50, 80)
                    esp.Box.Visible = ESP.Settings.Enabled and ESP.Settings.Box.Enabled
                    
                    -- Обновляем чамсы
                    if esp.Chams then
                        esp.Chams.Enabled = ESP.Settings.Chams.Enabled
                        esp.Chams.FillColor = ESP.Settings.Chams.Color
                        esp.Chams.FillTransparency = ESP.Settings.Chams.Transparency
                        esp.Chams.Adornee = character
                    end
                else
                    esp.Box.Visible = false
                    if esp.Chams then
                        esp.Chams.Enabled = false
                    end
                end
            end
        else
            -- Удаляем если персонаж больше не существует
            ESP.RemoveChild(character)
        end
    end
end

-- API для GUI
function ESP.TogglePlayerESP(Value)
    ESP.Settings.Enabled = Value
    if not Value then
        ESP.ClearPlayers()
    end
end

function ESP.ToggleBoxESP(Value)
    ESP.Settings.Box.Enabled = Value
end

function ESP.SetBoxColor(Color)
    ESP.Settings.Box.Color = Color
    for _, esp in pairs(ESP.Players) do
        esp.Box.Color = Color
    end
end

-- Основной цикл
task.spawn(function()
    ESP.Init()
    while true do
        if ESP.Settings.Enabled then
            ESP.Update()
        end
        task.wait(0.1)
    end
end)

return ESP
