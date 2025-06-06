local ESP = {
    Players = {},
    Objects = {},
    Settings = {
        Players = {
            Enabled = false,
            Box = true,
            BoxColor = Color3.new(1, 1, 1),
            Names = true,
            Health = true,
            Chams = false,
            ChamsColor = Color3.fromRGB(255, 0, 255)
        },
        Objects = {
            Enabled = false,
            Filter = {"Stone", "Nitrate", "Iron"},
            Color = Color3.fromRGB(0, 255, 255)
        }
    },
    Connections = {},
    Drawings = {}
}

-- Core Functions
function ESP.Init()
    -- Cleanup previous connections
    for _, conn in pairs(ESP.Connections) do
        conn:Disconnect()
    end
    
    -- Set up new connections
    ESP.Connections.ChildAdded = game:GetService("Workspace").ChildAdded:Connect(function(child)
        pcall(ESP.AddChild, ESP, child)
    end)
    
    ESP.Connections.ChildRemoved = game:GetService("Workspace").ChildRemoved:Connect(function(child)
        pcall(ESP.RemoveChild, ESP, child)
    end)
    
    -- Initialize existing objects
    for _, child in pairs(game:GetService("Workspace"):GetChildren()) do
        task.spawn(ESP.AddChild, ESP, child)
    end
    
    -- Start update loop
    ESP.Connections.Update = game:GetService("RunService").RenderStepped:Connect(function()
        pcall(ESP.Update, ESP)
    end)
end

function ESP.AddChild(self, child)
    if not child or not child.Parent then return end
    
    if child:FindFirstChild("Humanoid") then
        self.CreatePlayerESP(self, child)
    elseif table.find(self.Settings.Objects.Filter, child.Name) then
        self.CreateObjectESP(self, child)
    end
end

function ESP.CreatePlayerESP(self, character)
    if not character or self.Players[character] then return end
    
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Chams = Instance.new("Highlight")
    }
    
    -- Configure visuals
    esp.Box.Visible = false
    esp.Box.Color = self.Settings.Players.BoxColor
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    
    esp.Name.Visible = false
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    
    esp.Health.Visible = false
    esp.Health.Color = Color3.new(0, 1, 0)
    esp.Health.Size = 14
    esp.Health.Center = true
    esp.Health.Outline = true
    
    esp.Chams.Enabled = false
    esp.Chams.FillColor = self.Settings.Players.ChamsColor
    esp.Chams.FillTransparency = 0.5
    esp.Chams.OutlineColor = Color3.new(1, 1, 1)
    esp.Chams.OutlineTransparency = 1
    esp.Chams.Adornee = character
    esp.Chams.Parent = game:GetService("CoreGui")
    
    self.Players[character] = esp
end

function ESP.CreateObjectESP(self, object)
    if not object or self.Objects[object] then return end
    
    local drawing = Drawing.new("Text")
    drawing.Visible = false
    drawing.Color = self.Settings.Objects.Color
    drawing.Size = 14
    drawing.Center = true
    drawing.Outline = true
    drawing.Text = object.Name
    
    self.Objects[object] = drawing
end

function ESP.RemoveChild(self, child)
    if self.Players[child] then
        for _, drawing in pairs(self.Players[child]) do
            if typeof(drawing) == "userdata" and drawing.Remove then
                pcall(drawing.Remove, drawing)
            end
        end
        self.Players[child] = nil
    end
    
    if self.Objects[child] then
        if typeof(self.Objects[child]) == "userdata" and self.Objects[child].Remove then
            pcall(self.Objects[child].Remove, self.Objects[child])
        end
        self.Objects[child] = nil
    end
end

function ESP.Update(self)
    -- Update players
    for character, esp in pairs(self.Players) do
        if not character or not character.Parent then
            self.RemoveChild(self, character)
            continue
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local head = character:FindFirstChild("Head")
        
        if not humanoid or not head then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
            if esp.Chams then
                esp.Chams.Enabled = false
            end
            continue
        end
        
        local success, pos, onScreen = pcall(function()
            local pos = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(head.Position)
            return pos, pos.Z > 0
        end)
        
        if not success or not onScreen then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
            if esp.Chams then
                esp.Chams.Enabled = false
            end
            continue
        end
        
        -- Box ESP
        esp.Box.Visible = self.Settings.Players.Enabled and self.Settings.Players.Box
        esp.Box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
        esp.Box.Size = Vector2.new(50, 80)
        esp.Box.Color = self.Settings.Players.BoxColor
        
        -- Name ESP
        esp.Name.Visible = self.Settings.Players.Enabled and self.Settings.Players.Names
        esp.Name.Position = Vector2.new(pos.X, pos.Y - 60)
        esp.Name.Text = character.Name
        
        -- Health ESP
        esp.Health.Visible = self.Settings.Players.Enabled and self.Settings.Players.Health
        esp.Health.Position = Vector2.new(pos.X, pos.Y + 40)
        esp.Health.Text = tostring(math.floor(humanoid.Health)).."/"..tostring(humanoid.MaxHealth)
        
        -- Chams
        if esp.Chams then
            esp.Chams.Enabled = self.Settings.Players.Enabled and self.Settings.Players.Chams
            esp.Chams.FillColor = self.Settings.Players.ChamsColor
        end
    end
    
    -- Update objects
    for object, drawing in pairs(self.Objects) do
        if not object or not object.Parent then
            self.RemoveChild(self, object)
            continue
        end
        
        local success, pos, onScreen = pcall(function()
            local pos = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(object.Position)
            return pos, pos.Z > 0
        end)
        
        if not success or not onScreen then
            drawing.Visible = false
            continue
        end
        
        drawing.Visible = self.Settings.Objects.Enabled
        drawing.Position = Vector2.new(pos.X, pos.Y)
        drawing.Color = self.Settings.Objects.Color
        drawing.Text = object.Name
    end
end

-- API for GUI
function ESP.Toggle(self, category, value)
    if self.Settings[category] then
        self.Settings[category].Enabled = value
        if not value then
            self.ClearCategory(self, category)
        end
    end
end

function ESP.ToggleSetting(self, category, setting, value)
    if self.Settings[category] then
        self.Settings[category][setting] = value
    end
end

function ESP.UpdateSetting(self, category, setting, value)
    if self.Settings[category] then
        self.Settings[category][setting] = value
    end
end

function ESP.ClearCategory(self, category)
    if category == "Players" then
        for character in pairs(self.Players) do
            self.RemoveChild(self, character)
        end
    elseif category == "Objects" then
        for object in pairs(self.Objects) do
            self.RemoveChild(self, object)
        end
    end
end

return ESP
