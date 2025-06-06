local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

local ModelESP = {}
local enabled = false
local boxType = "Box"
local boxColor = Color3.fromRGB(0, 255, 0)
local transparency = 0
local visibleOnly = false
local maxDistance = 1000
local targetName = "Model" -- Название объекта для поиска
local showText = true
local textSize = 16

local espDrawings = {}
local connection

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
        for i = 1, 8 do
            drawings.corners[i] = Drawing.new("Line")
            drawings.corners[i].Visible = false
            drawings.corners[i].Color = boxColor
            drawings.corners[i].Thickness = 2
            drawings.corners[i].Transparency = 1 - transparency
        end
    end

    if showText then
        drawings.text = Drawing.new("Text")
        drawings.text.Text = "🎯 " .. model.Name
        drawings.text.Size = textSize
        drawings.text.Center = true
        drawings.text.Outline = true
        drawings.text.Color = boxColor
        drawings.text.Visible = false
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
    local origin = Camera.CFrame.Position
    local direction = (center - origin).Unit * (center - origin).Magnitude
    local ray = Ray.new(origin, direction)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {Camera})
    return hit and hit:IsDescendantOf(model)
end

-- Обновление ESP
local function updateESP()
    if not enabled then return end
    
    if not Camera then return end
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == targetName then
            local center, size = getModelBounds(obj)
            if not center then continue end
            
            -- Проверяем дистанцию
            local distance = (Camera.CFrame.Position - center).Magnitude
            if distance > maxDistance then continue end
            
            if not espDrawings[obj] then
                createESP(obj)
            end

            local drawings = espDrawings[obj]
            local vector, onScreen = Camera:WorldToViewportPoint(center)
            local isVisible = isModelVisible(obj, center)

            if onScreen and isVisible then
                -- Вычисляем размер на экране
                local topPoint = Camera:WorldToViewportPoint(center + Vector3.new(0, size.Y/2, 0))
                local bottomPoint = Camera:WorldToViewportPoint(center - Vector3.new(0, size.Y/2, 0))
                local leftPoint = Camera:WorldToViewportPoint(center - Vector3.new(size.X/2, 0, 0))
                local rightPoint = Camera:WorldToViewportPoint(center + Vector3.new(size.X/2, 0, 0))
                
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

                if drawings.text then
                    drawings.text.Position = Vector2.new(vector.X, vector.Y - h/2 - 25)
                    drawings.text.Visible = true
                end
            else
                if drawings.box then drawings.box.Visible = false end
                if drawings.corners then
                    for _, corner in pairs(drawings.corners) do
                        corner.Visible = false
                    end
                end
                if drawings.text then drawings.text.Visible = false end
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
    for _, drawings in pairs(espDrawings) do
        if drawings.box then drawings.box:Remove() end
        if drawings.corners then
            for _, line in pairs(drawings.corners) do
                line:Remove()
            end
        end
        if drawings.text then drawings.text:Remove() end
    end
    espDrawings = {}
end

function ModelESP:SetTargetName(name)
    targetName = name
    -- Сброс ESP при смене цели
    if enabled then
        self:Disable()
        self:Enable()
    end
end

function ModelESP:SetBoxType(type)
    boxType = type
    if enabled then
        self:Disable()
        self:Enable()
    end
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
        if drawings.text then drawings.text.Color = color end
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

function ModelESP:SetShowText(state)
    showText = state
    if enabled then
        self:Disable()
        self:Enable()
    end
end

function ModelESP:SetTextSize(size)
    textSize = size
    for _, drawings in pairs(espDrawings) do
        if drawings.text then drawings.text.Size = size end
    end
end

return ModelESP
