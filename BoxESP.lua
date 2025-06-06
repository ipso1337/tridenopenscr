-- BoxESP.lua
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local BoxESP = {}
local enabled = false
local boxType = "Box" -- "Box", "Corner", "3D" (можно потом переключать)

-- Таблица хранения отрисовки
local espDrawings = {}

-- Удаление отрисовки
local function clearESP()
    for _, drawings in pairs(espDrawings) do
        for _, obj in pairs(drawings) do
            if typeof(obj) == "Instance" and obj.Destroy then
                obj:Destroy()
            elseif typeof(obj) == "table" and obj.Remove then
                obj:Remove()
            end
        end
    end
    espDrawings = {}
end

-- Создание бокса
local function createBox(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")

    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(96, 205, 255)
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false

    espDrawings[player] = { box = box }
end

-- Обновление ESP
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)

            if not espDrawings[player] then
                createBox(player)
            end

            local box = espDrawings[player].box
            if onScreen and box then
                local size = Vector3.new(4, 6, 0) -- фиксированный размер
                local scale = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position + Vector3.new(2, 3, 0))
                local w, h = math.abs(vector.X - scale.X), math.abs(vector.Y - scale.Y)

                box.Size = Vector2.new(w, h)
                box.Position = Vector2.new(vector.X - w / 2, vector.Y - h / 2)
                box.Visible = true
            else
                if box then
                    box.Visible = false
                end
            end
        end
    end
end

-- Подключение к RenderStepped
RunService.RenderStepped:Connect(function()
    if not enabled then return end
    updateESP()
end)

-- Включение ESP
function BoxESP:Enable()
    enabled = true
    print("BoxESP enabled.")
end

-- Выключение ESP
function BoxESP:Disable()
    enabled = false
    clearESP()
    print("BoxESP disabled.")
end

-- Переключение
function BoxESP:Toggle(state)
    if state then
        self:Enable()
    else
        self:Disable()
    end
end

return BoxESP
