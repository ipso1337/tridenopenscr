local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local BoxESP = {}
local enabled = false
local boxType = "Box"
local boxColor = Color3.fromRGB(96, 205, 255)
local transparency = 0
local visibleOnly = false

local espDrawings = {}

-- Очистка ESP
local function clearESP()
    for _, drawings in pairs(espDrawings) do
        if drawings.box then drawings.box:Remove() end
        if drawings.corners then
            for _, line in pairs(drawings.corners) do
                line:Remove()
            end
        end
    end
    espDrawings = {}
end

-- Создание элементов ESP
local function createESP(player)
    if espDrawings[player] then return end

    local drawings = {}

    if boxType == "Box" or boxType == "3D Box" then
        drawings.box = Drawing.new("Square")
        drawings.box.Visible = false
        drawings.box.Color = boxColor
        drawings.box.Thickness = 2
        drawings.box.Transparency = 1 - transparency
        drawings.box.Filled = false
    end

    if boxType == "Corner" then
        drawings.corners = {}
        for i = 1, 4 do
            drawings.corners[i] = Drawing.new("Line")
            drawings.corners[i].Visible = false
            drawings.corners[i].Color = boxColor
            drawings.corners[i].Thickness = 2
            drawings.corners[i].Transparency = 1 - transparency
        end
    end

    espDrawings[player] = drawings
end

-- Проверка видимости игрока
local function isPlayerVisible(character, rootPart)
    if not visibleOnly then return true end
    local camera = workspace.CurrentCamera
    local origin = camera.CFrame.Position
    local direction = (rootPart.Position - origin).Unit * 1000
    local ray = Ray.new(origin, direction)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, camera})
    return hit and hit:IsDescendantOf(character)
end

-- Обновление ESP
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then continue end

            if not espDrawings[player] then
                createESP(player)
            end

            local drawings = espDrawings[player]
            local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
            local isVisible = isPlayerVisible(character, rootPart)

            if onScreen and isVisible then
                local size = Vector3.new(4, 6, 0)
                local scale = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position + Vector3.new(2, 3, 0))
                local w, h = math.abs(vector.X - scale.X), math.abs(vector.Y - scale.Y)

                if boxType == "Box" and drawings.box then
                    drawings.box.Size = Vector2.new(w, h)
                    drawings.box.Position = Vector2.new(vector.X - w/2, vector.Y - h/2)
                    drawings.box.Visible = true
                elseif boxType == "Corner" and drawings.corners then
                    local cornerSize = math.min(w, h) * 0.3
                    local points = {
                        Vector2.new(vector.X - w/2, vector.Y - h/2),
                        Vector2.new(vector.X + w/2, vector.Y - h/2),
                        Vector2.new(vector.X + w/2, vector.Y + h/2),
                        Vector2.new(vector.X - w/2, vector.Y + h/2)
                    }

                    for i = 1, 4 do
                        local nextI = i % 4 + 1
                        drawings.corners[i].From = points[i]
                        drawings.corners[i].To = points[i] + (points[nextI] - points[i]).Unit * cornerSize
                        drawings.corners[i].Visible = true
                    end
                end
            else
                if drawings.box then drawings.box.Visible = false end
                if drawings.corners then
                    for _, corner in pairs(drawings.corners) do
                        corner.Visible = false
                    end
                end
            end
        end
    end
end

-- Функции управления
function BoxESP:Toggle(state)
    if state then
        self:Enable()
    else
        self:Disable()
    end
end

function BoxESP:Enable()
    if enabled then return end
    enabled = true
    RunService.RenderStepped:Connect(updateESP)
end

function BoxESP:Disable()
    if not enabled then return end
    enabled = false
    clearESP()
end

function BoxESP:SetBoxType(type)
    boxType = type
    clearESP()
end

function BoxESP:SetColor(color)
    boxColor = color
    for _, drawings in pairs(espDrawings) do
        if drawings.box then drawings.box.Color = color end
        if drawings.corners then
            for _, corner in pairs(drawings.corners) do
                corner.Color = color
            end
        end
    end
end

function BoxESP:SetTransparency(value)
    transparency = value
    for _, drawings in pairs(espDrawings) do
        if drawings.box then drawings.box.Transparency = 1 - value end
        if drawings.corners then
            for _, corner in pairs(drawings.corners) do
                corner.Transparency = 1 - value
            end
        end
    end
end

function BoxESP:SetVisibleOnly(state)
    visibleOnly = state
end

return BoxESP
