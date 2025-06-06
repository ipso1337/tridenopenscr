--[[
    ЛОГИКА СКРИПТА (логика.lua)
    Всё, что отвечает за функционал, но не за интерфейс.
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- =============================================
-- ESP System (полная логика ESP)
-- =============================================
local ESP = {
    Enabled = false,
    Objects = {},
    Settings = {
        Box = true,
        BoxColor = Color3.new(1, 1, 1),
        Name = true,
        Distance = true,
        HealthBar = false,
        Chams = false,
        ChamsColor = Color3.new(1, 0, 0),
        Tracers = false,
        TracersColor = Color3.new(1, 1, 1)
    }
}

-- Создание ESP для игрока
function ESP:Create(player)
    if not player.Character then return end

    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        Tracer = Drawing.new("Line"),
        Chams = Instance.new("Highlight")
    }

    -- Настройка стилей
    esp.Box.Visible = false
    esp.Box.Color = self.Settings.BoxColor
    esp.Box.Thickness = 1
    esp.Box.Filled = false

    esp.Name.Visible = false
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Size = 14
    esp.Name.Center = true

    esp.Tracer.Visible = false
    esp.Tracer.Color = self.Settings.TracersColor
    esp.Tracer.Thickness = 1

    esp.Chams.Enabled = false
    esp.Chams.FillColor = self.Settings.ChamsColor
    esp.Chams.OutlineColor = self.Settings.ChamsColor
    esp.Chams.Parent = game.CoreGui

    self.Objects[player] = esp
    return esp
end

-- Обновление ESP в реальном времени
function ESP:Update()
    for player, esp in pairs(self.Objects) do
        if player and player:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.HumanoidRootPart
            local head = player:FindFirstChild("Head")

            if head then
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)

                if onScreen then
                    -- Расчёт размера ESP (как в оригинале)
                    local scale = 1 / (headPos.Z * math.tan(math.rad(Camera.FieldOfView / 2)))
                    local width = 100 * scale
                    local height = 150 * scale

                    -- Позиционирование бокса
                    esp.Box.Position = Vector2.new(headPos.X - width/2, headPos.Y - height/2)
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Visible = self.Settings.Box and self.Enabled

                    -- Имя игрока
                    esp.Name.Position = Vector2.new(headPos.X, headPos.Y - height/2 - 20)
                    esp.Name.Text = player.Name
                    esp.Name.Visible = self.Settings.Name and self.Enabled

                    -- Расстояние
                    local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                    esp.Distance.Text = string.format("[%d studs]", distance)
                    esp.Distance.Position = Vector2.new(headPos.X, headPos.Y + height/2 + 5)
                    esp.Distance.Visible = self.Settings.Distance and self.Enabled

                    -- Трейсеры (линии до игрока)
                    if self.Settings.Tracers and self.Enabled then
                        local bottomScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        esp.Tracer.From = bottomScreen
                        esp.Tracer.To = Vector2.new(headPos.X, headPos.Y)
                        esp.Tracer.Visible = true
                    else
                        esp.Tracer.Visible = false
                    end

                    -- Чампы
                    esp.Chams.Enabled = self.Settings.Chams and self.Enabled
                    esp.Chams.Adornee = player
                else
                    -- Если игрок вне экрана
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Distance.Visible = false
                    esp.Tracer.Visible = false
                    esp.Chams.Enabled = false
                end
            end
        else
            -- Удалить ESP, если игрока нет
            ESP:Remove(player)
        end
    end
end

-- Удаление ESP
function ESP:Remove(player)
    if not self.Objects[player] then return end

    for _, drawing in pairs(self.Objects[player]) do
        if typeof(drawing) == "Instance" then
            drawing:Destroy()
        else
            drawing:Remove()
        end
    end

    self.Objects[player] = nil
end

-- Включение/выключение ESP
function ESP:Toggle(state)
    self.Enabled = state

    if state then
        -- Добавляем ESP для всех игроков
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                coroutine.wrap(function()
                    ESP:Create(player.Character or player.CharacterAdded:Wait())
                end)()
            end
        end

        -- Подключаем ивенты
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                ESP:Create(character)
            end)
        end)

        -- Запускаем цикл обновления
        RunService.RenderStepped:Connect(function()
            ESP:Update()
        end)
    else
        -- Очищаем все ESP
        for player in pairs(self.Objects) do
            ESP:Remove(player)
        end
    end
end

-- =============================================
-- Time Changer (управление временем)
-- =============================================
local TimeChanger = {
    Enabled = false,
    Time = 12
}

function TimeChanger:Toggle(state)
    self.Enabled = state
    if state then
        coroutine.wrap(function()
            while self.Enabled do
                Lighting.ClockTime = self.Time
                RunService.RenderStepped:Wait()
            end
        end)()
    end
end

-- =============================================
-- Экспортируем модули для GUI
-- =============================================
return {
    ESP = ESP,
    TimeChanger = TimeChanger
}
