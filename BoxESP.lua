local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local ModelESP = {}
local enabled = false
local boxType = "Box"
local boxColor = Color3.fromRGB(96, 205, 255)
local transparency = 0
local visibleOnly = false
local maxDistance = 1000 -- Максимальная дистанция для отображения ESP

local espDrawings = {}
local connection

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
local function createESP(model)
    if espDrawings[model] then return end

    local drawings = {}

    if boxType == "Box" then
        drawings.box = Drawing.new("Square")
        drawings.box.Visible = false
        drawings.box.Color = boxColor
        drawings.box.Thickness = 2
        drawings.box.Transparency = 1 - transparency
        drawings.box.Filled = false
    end

    if boxType == "Corner" then
        drawings.corners = {}
        for i = 1, 8 do -- 8 линий для углов
            drawings.corners[i] = Drawing.new("Line")
            drawings.corners[i].Visible = false
            drawings.corners[i].Color = boxColor
            drawings.corners[i].Thickness = 2
            drawings.corners[i].Transparency = 1 - transparency
        end
    end

    espDrawings[model] = drawings
end

-- Получение центра и размера модели
local function getModelBounds(model)
    local parts = {}
    local function getParts(obj)
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("BasePart") then
                table.insert(parts, child)
            elseif child:IsA("Model") then
                getParts(child)
            end
        end
    end
    
    getParts(model)
    
    if #parts == 0 then return nil end
    
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
    
    for _, part in pairs(parts) do
        local cf = part.CFrame
        local size = part.Size
        local corners = {
            cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
            cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2),
            cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
            cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
            cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
            cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
            cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
            cf * CFrame.new(size.X/2, size.Y/2, size.Z/2)
        }
        
        for _, corner in pairs(corners) do
            local pos = corner.Position
            minX, minY, minZ = math.min(minX, pos.X), math.min(minY, pos.Y), math.min(minZ, pos.Z)
            maxX, maxY, maxZ = math.max(maxX, pos.X), math.max(maxY, pos.Y), math.max(maxZ, pos.Z)
        end
    end
    
    local center = Vector3.new((minX + maxX)/2, (minY + maxY)/2, (minZ + minZ)/2)
    local size = Vector3.new(maxX - minX, maxY - minY, maxZ - minZ)
    
    return center, size
end

-- Проверка видимости модели
local function isModelVisible(model, center)
    if not visibleOnly then return true end
    local camera = workspace.CurrentCamera
    local origin = camera.CFrame.Position
    local direction = (center - origin).Unit * (center - origin).Magnitude
    local ray = Ray.new(origin, direction)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {camera})
    return hit and hit:IsDescendantOf(model)
end

-- Обновление ESP
local function updateESP()
    if not enabled then return end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    -- Получаем все модели в workspace
    local models = {}
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= workspace.CurrentCamera then
            table.insert(models, obj)
        end
    end
    
    -- Очищаем ESP для удаленных моделей
    for model, _ in pairs(espDrawings) do
        if not model.Parent then
            if espDrawings[model].box then espDrawings[model].box:Remove() end
            if espDrawings[model].corners then
                for _, line in pairs(espDrawings[model].corners) do
                    line:Remove()
                end
            end
            espDrawings[model] = nil
        end
    end
    
    for _, model in pairs(models) do
        local center, size = getModelBounds(model)
        if not center then continue end
        
        -- Проверяем дистанцию
        local distance = (camera.CFrame.Position - center).Magnitude
        if distance > maxDistance then continue end
        
        if not espDrawings[model] then
            createESP(model)
        end

        local drawings = espDrawings[model]
        local vector, onScreen = camera:WorldToViewportPoint(center)
        local isVisible = isModelVisible(model, center)

        if onScreen and isVisible then
            -- Вычисляем размер на экране
            local topPoint = camera:WorldToViewportPoint(center + Vector3.new(0, size.Y/2, 0))
            local bottomPoint = camera:WorldToViewportPoint(center - Vector3.new(0, size.Y/2, 0))
            local leftPoint = camera:WorldToViewportPoint(center - Vector3.new(size.X/2, 0, 0))
            local rightPoint = camera:WorldToViewportPoint(center + Vector3.new(size.X/2, 0, 0))
            
            local h = math.abs(topPoint.Y - bottomPoint.Y)
            local w = math.abs(rightPoint.X - leftPoint.X)

            if boxType == "Box" and drawings.box then
                drawings.box.Size = Vector2.new(w, h)
                drawings.box.Position = Vector2.new(vector.X - w/2, vector.Y - h/2)
                drawings.box.Visible = true
            elseif boxType == "Corner" and drawings.corners then
                local cornerSize = math.min(w, h) * 0.2
                local topLeft = Vector2.new(vector.X - w/2, vector.Y - h/2)
                local topRight = Vector2.new(vector.X + w/2, vector.Y - h/2)
                local bottomLeft = Vector2.new(vector.X - w/2, vector.Y + h/2)
                local bottomRight = Vector2.new(vector.X + w/2, vector.Y + h/2)
                
                -- Верхний левый угол
                drawings.corners[1].From = topLeft
                drawings.corners[1].To = Vector2.new(topLeft.X + cornerSize, topLeft.Y)
                drawings.corners[2].From = topLeft
                drawings.corners[2].To = Vector2.new(topLeft.X, topLeft.Y + cornerSize)
                
                -- Верхний правый угол
                drawings.corners[3].From = topRight
                drawings.corners[3].To = Vector2.new(topRight.X - cornerSize, topRight.Y)
                drawings.corners[4].From = topRight
                drawings.corners[4].To = Vector2.new(topRight.X, topRight.Y + cornerSize)
                
                -- Нижний левый угол
                drawings.corners[5].From = bottomLeft
                drawings.corners[5].To = Vector2.new(bottomLeft.X + cornerSize, bottomLeft.Y)
                drawings.corners[6].From = bottomLeft
                drawings.corners[6].To = Vector2.new(bottomLeft.X, bottomLeft.Y - cornerSize)
                
                -- Нижний правый угол
                drawings.corners[7].From = bottomRight
                drawings.corners[7].To = Vector2.new(bottomRight.X - cornerSize, bottomRight.Y)
                drawings.corners[8].From = bottomRight
                drawings.corners[8].To = Vector2.new(bottomRight.X, bottomRight.Y - cornerSize)
                
                for i = 1, 8 do
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

-- Функции управления
function ModelESP:Toggle(state)
    if state then
        self:Enable()
    else
        self:Disable()
    end
end

function ModelESP:Enable()
    if enabled then return end
    enabled = true
    connection = RunService.RenderStepped:Connect(updateESP)
end

function ModelESP:Disable()
    if not enabled then return end
    enabled = false
    if connection then
        connection:Disconnect()
        connection = nil
    end
    clearESP()
end

function ModelESP:SetBoxType(type)
    boxType = type
    clearESP()
end

function ModelESP:SetColor(color)
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

function ModelESP:SetTransparency(value)
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

function ModelESP:SetVisibleOnly(state)
    visibleOnly = state
end

function ModelESP:SetMaxDistance(distance)
    maxDistance = distance
end

return ModelESP
