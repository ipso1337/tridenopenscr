-- BoxESP.lua
local BoxESP = {}

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Настройки ESP
BoxESP.Enabled = false
BoxESP.Type = "Box" -- "Box", "3D", "Corner"
BoxESP.Color = Color3.fromRGB(96, 205, 255)
BoxESP.Targets = {} -- Таблица объектов для ESP

local function createDrawing(type)
    local drawing = Drawing.new(type)
    drawing.Visible = false
    drawing.Color = BoxESP.Color
    drawing.Thickness = 2
    drawing.Filled = false
    drawing.Transparency = 1
    return drawing
end

-- Обновление цвета
function BoxESP:SetColor(color)
    BoxESP.Color = color
end

-- Добавление объекта
function BoxESP:AddTarget(object)
    BoxESP.Targets[object] = true
end

-- Удаление объекта
function BoxESP:RemoveTarget(object)
    BoxESP.Targets[object] = nil
end

-- Простой 2D box вокруг объекта
local function drawBox2D(obj, color)
    local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
    if not root then return end
    
    local size = Vector3.new(4, 6, 4) -- примерный размер бокса
    local corners = {}

    local cf = root.CFrame
    local extent = root.Size / 2

    local points3D = {
        cf * Vector3.new(-extent.X, extent.Y, -extent.Z),
        cf * Vector3.new(extent.X, extent.Y, -extent.Z),
        cf * Vector3.new(extent.X, extent.Y, extent.Z),
        cf * Vector3.new(-extent.X, extent.Y, extent.Z),

        cf * Vector3.new(-extent.X, -extent.Y, -extent.Z),
        cf * Vector3.new(extent.X, -extent.Y, -extent.Z),
        cf * Vector3.new(extent.X, -extent.Y, extent.Z),
        cf * Vector3.new(-extent.X, -extent.Y, extent.Z),
    }

    for i, point in pairs(points3D) do
        local pos, onScreen = Camera:WorldToViewportPoint(point)
        if onScreen then
            corners[i] = Vector2.new(pos.X, pos.Y)
        else
            return nil
        end
    end

    local left = math.huge
    local right = 0
    local top = math.huge
    local bottom = 0

    for _, corner in pairs(corners) do
        if corner.X < left then left = corner.X end
        if corner.X > right then right = corner.X end
        if corner.Y < top then top = corner.Y end
        if corner.Y > bottom then bottom = corner.Y end
    end

    local width = right - left
    local height = bottom - top

    return left, top, width, height
end

-- Corner box drawing
local function drawCornerBox(x, y, w, h, color)
    local thickness = 2
    local length = math.min(w, h) / 4

    local lines = {}

    -- Create lines for corners (8 lines, 2 for each corner)
    -- Left Top
    table.insert(lines, {from = Vector2.new(x, y), to = Vector2.new(x + length, y), color = color})
    table.insert(lines, {from = Vector2.new(x, y), to = Vector2.new(x, y + length), color = color})
    -- Right Top
    table.insert(lines, {from = Vector2.new(x + w, y), to = Vector2.new(x + w - length, y), color = color})
    table.insert(lines, {from = Vector2.new(x + w, y), to = Vector2.new(x + w, y + length), color = color})
    -- Left Bottom
    table.insert(lines, {from = Vector2.new(x, y + h), to = Vector2.new(x + length, y + h), color = color})
    table.insert(lines, {from = Vector2.new(x, y + h), to = Vector2.new(x, y + h - length), color = color})
    -- Right Bottom
    table.insert(lines, {from = Vector2.new(x + w, y + h), to = Vector2.new(x + w - length, y + h), color = color})
    table.insert(lines, {from = Vector2.new(x + w, y + h), to = Vector2.new(x + w, y + h - length), color = color})

    return lines
end

-- Рисование 3D бокса (каркас)
local function draw3DBox(obj, color)
    local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
    if not root then return nil end

    local cf = root.CFrame
    local size = root.Size / 2

    local points = {
        cf * Vector3.new(-size.X, size.Y, -size.Z),
        cf * Vector3.new(size.X, size.Y, -size.Z),
        cf * Vector3.new(size.X, size.Y, size.Z),
        cf * Vector3.new(-size.X, size.Y, size.Z),

        cf * Vector3.new(-size.X, -size.Y, -size.Z),
        cf * Vector3.new(size.X, -size.Y, -size.Z),
        cf * Vector3.new(size.X, -size.Y, size.Z),
        cf * Vector3.new(-size.X, -size.Y, size.Z),
    }

    local screenPoints = {}
    for i, point in pairs(points) do
        local pos, onScreen = Camera:WorldToViewportPoint(point)
        if not onScreen then
            return nil
        end
        screenPoints[i] = Vector2.new(pos.X, pos.Y)
    end

    local lines = {}

    -- Bottom rectangle
    table.insert(lines, {from = screenPoints[5], to = screenPoints[6], color = color})
    table.insert(lines, {from = screenPoints[6], to = screenPoints[7], color = color})
    table.insert(lines, {from = screenPoints[7], to = screenPoints[8], color = color})
    table.insert(lines, {from = screenPoints[8], to = screenPoints[5], color = color})

    -- Top rectangle
    table.insert(lines, {from = screenPoints[1], to = screenPoints[2], color = color})
    table.insert(lines, {from = screenPoints[2], to = screenPoints[3], color = color})
    table.insert(lines, {from = screenPoints[3], to = screenPoints[4], color = color})
    table.insert(lines, {from = screenPoints[4], to = screenPoints[1], color = color})

    -- Vertical lines
    table.insert(lines, {from = screenPoints[1], to = screenPoints[5], color = color})
    table.insert(lines, {from = screenPoints[2], to = screenPoints[6], color = color})
    table.insert(lines, {from = screenPoints[3], to = screenPoints[7], color = color})
    table.insert(lines, {from = screenPoints[4], to = screenPoints[8], color = color})

    return lines
end

local espLines = {}
local espBoxes = {}

RunService.RenderStepped:Connect(function()
    if not BoxESP.Enabled then
        for _, line in pairs(espLines) do
            line.Visible = false
            line:Remove()
        end
        espLines = {}
        for _, box in pairs(espBoxes) do
            box.Visible = false
            box:Remove()
        end
        espBoxes = {}
        return
    end

    -- Обновление цвета ESP
    local color = BoxESP.Color

    local count = 1

    for obj, _ in pairs(BoxESP.Targets) do
        if obj and obj.Parent then
            if BoxESP.Type == "Box" then
                -- Рисуем простой 2D box
                local left, top, width, height = drawBox2D(obj, color)
                if left and top and width and height then
                    -- Создаем/обновляем Drawing квадраты
                    if not espBoxes[count] then
                        espBoxes[count] = createDrawing("Square")
                    end
                    local box = espBoxes[count]
                    box.Visible = true
                    box.Color = color
                    box.Position = Vector2.new(left, top)
                    box.Size = Vector2.new(width, height)
                    count = count + 1
                end

            elseif BoxESP.Type == "Corner" then
                local left, top, width, height = drawBox2D(obj, color)
                if left and top and width and height then
                    local cornerLines = drawCornerBox(left, top, width, height, color)
                    -- Рисуем линии углов
                    for i, lineData in ipairs(cornerLines) do
                        if not espLines[count] then
                            espLines[count] = createDrawing("Line")
                        end
                        local line = espLines[count]
                        line.Visible = true
                        line.Color = lineData.color
                        line.From = lineData.from
                        line.To = lineData.to
                        count = count + 1
                    end
                end

            elseif BoxESP.Type == "3D" then
                local lines3D = draw3DBox(obj, color)
                if lines3D then
                    for i, lineData in ipairs(lines3D) do
                        if not espLines[count] then
                            espLines[count] = createDrawing("Line")
                        end
                        local line = espLines[count]
                        line.Visible = true
                        line.Color = lineData.color
                        line.From = lineData.from
                        line.To = lineData.to
                        count = count + 1
                    end
                end
            end
        end
    end

    -- Скрываем неиспользуемые Drawing объекты
    for i = count, #espLines do
        espLines[i].Visible = false
    end
    for i = count, #espBoxes do
        espBoxes[i].Visible = false
    end
end)

return BoxESP
