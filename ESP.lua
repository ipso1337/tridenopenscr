local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

local TorsoESP = {}
local enabled = false
local boxType = "Box"
local boxColor = Color3.fromRGB(185, 182, 188) -- Matches the torso color (0.741176, 0.713726, 0.737255)
local transparency = 0
local visibleOnly = false
local maxDistance = 1000
local targetPath = "Workspace.Model.Torso" -- Direct path to the Torso part
local showText = true
local textSize = 16

local espDrawings = {}
local connection

-- Create ESP elements for the Torso
local function createESP(part)
    if espDrawings[part] then return end

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
        drawings.text.Text = "🦴 " .. part.Name
        drawings.text.Size = textSize
        drawings.text.Center = true
        drawings.text.Outline = true
        drawings.text.Color = boxColor
        drawings.text.Visible = false
    end

    espDrawings[part] = drawings
end

-- Get part bounds (simplified for single part)
local function getPartBounds(part)
    local cf = part.CFrame
    local size = part.Size
    return cf.Position, size
end

-- Check visibility
local function isPartVisible(part, center)
    if not visibleOnly then return true end
    local origin = Camera.CFrame.Position
    local direction = (center - origin).Unit * (center - origin).Magnitude
    local ray = Ray.new(origin, direction)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {Camera})
    return hit == part
end

-- Get object by path
local function getObjectByPath(path)
    local parts = string.split(path, ".")
    local current = game
    
    for _, part in pairs(parts) do
        if current:FindFirstChild(part) then
            current = current[part]
        else
            return nil
        end
    end
    
    return current
end

-- Update ESP
local function updateESP()
    if not enabled then return end
    if not Camera then return end
    
    local part = getObjectByPath(targetPath)
    if part and part:IsA("BasePart") then
        local center, size = getPartBounds(part)
        
        -- Check distance
        local distance = (Camera.CFrame.Position - center).Magnitude
        if distance > maxDistance then return end
        
        if not espDrawings[part] then
            createESP(part)
        end

        local drawings = espDrawings[part]
        local vector, onScreen = Camera:WorldToViewportPoint(center)
        local isVisible = isPartVisible(part, center)

        if onScreen and isVisible then
            -- Calculate screen size
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
                
                -- Top left corner
                drawings.corners[1].From = topLeft
                drawings.corners[1].To = Vector2.new(topLeft.X + cornerSize, topLeft.Y)
                drawings.corners[2].From = topLeft
                drawings.corners[2].To = Vector2.new(topLeft.X, topLeft.Y + cornerSize)
                
                -- Top right corner
                drawings.corners[3].From = topRight
                drawings.corners[3].To = Vector2.new(topRight.X - cornerSize, topRight.Y)
                drawings.corners[4].From = topRight
                drawings.corners[4].To = Vector2.new(topRight.X, topRight.Y + cornerSize)
                
                -- Bottom left corner
                drawings.corners[5].From = bottomLeft
                drawings.corners[5].To = Vector2.new(bottomLeft.X + cornerSize, bottomLeft.Y)
                drawings.corners[6].From = bottomLeft
                drawings.corners[6].To = Vector2.new(bottomLeft.X, bottomLeft.Y - cornerSize)
                
                -- Bottom right corner
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

-- Control functions
function TorsoESP:Toggle(state)
    if state then
        self:Enable()
    else
        self:Disable()
    end
end

function TorsoESP:Enable()
    if enabled then return end
    enabled = true
    connection = RunService.RenderStepped:Connect(updateESP)
end

function TorsoESP:Disable()
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

function TorsoESP:SetBoxType(type)
    boxType = type
    if enabled then
        self:Disable()
        self:Enable()
    end
end

function TorsoESP:SetColor(color)
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

function TorsoESP:SetTransparency(value)
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

function TorsoESP:SetVisibleOnly(state)
    visibleOnly = state
end

function TorsoESP:SetMaxDistance(distance)
    maxDistance = distance
end

function TorsoESP:SetShowText(state)
    showText = state
    if enabled then
        self:Disable()
        self:Enable()
    end
end

function TorsoESP:SetTextSize(size)
    textSize = size
    for _, drawings in pairs(espDrawings) do
        if drawings.text then drawings.text.Size = size end
    end
end

return TorsoESP
