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
    -- Set up connections
    ESP.Connections.ChildAdded = game:GetService("Workspace").ChildAdded:Connect(ESP.AddChild)
    ESP.Connections.ChildRemoved = game:GetService("Workspace").ChildRemoved:Connect(ESP.RemoveChild)
    
    -- Initialize existing objects
    for _, child in pairs(game:GetService("Workspace"):GetChildren()) do
        task.spawn(ESP.AddChild, child)
    end
    
    -- Start update loop
    ESP.Connections.Update = game:GetService("RunService").RenderStepped:Connect(function()
        ESP.Update()
    end)
end

function ESP.AddChild(child)
    if child:FindFirstChild("Humanoid") then
        ESP.CreatePlayerESP(child)
    elseif table.find(ESP.Settings.Objects.Filter, child.Name) then
        ESP.CreateObjectESP(child)
    end
end

function ESP.CreatePlayerESP(character)
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Chams = Instance.new("Highlight")
    }
    
    -- Configure visuals
    esp.Box.Visible = false
    esp.Box.Color = ESP.Settings.Players.BoxColor
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    
    esp.Name.Visible = false
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Size = 14
    esp.Name.Center = true
    
    esp.Health.Visible = false
    esp.Health.Color = Color3.new(0, 1, 0)
    esp.Health.Size = 14
    esp.Health.Center = true
    
    esp.Chams.Enabled = false
    esp.Chams.FillColor = ESP.Settings.Players.ChamsColor
    esp.Chams.FillTransparency = 0.5
    esp.Chams.OutlineColor = Color3.new(1, 1, 1)
    esp.Chams.OutlineTransparency = 1
    esp.Chams.Adornee = character
    esp.Chams.Parent = game:GetService("CoreGui")
    
    ESP.Players[character] = esp
end

function ESP.Update()
    -- Update players
    for character, esp in pairs(ESP.Players) do
        if character.Parent then
            local head = character:FindFirstChild("Head")
            if head then
                local pos, onScreen = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- Box ESP
                    esp.Box.Visible = ESP.Settings.Players.Enabled and ESP.Settings.Players.Box
                    esp.Box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
                    esp.Box.Size = Vector2.new(50, 80)
                    
                    -- Name ESP
                    esp.Name.Visible = ESP.Settings.Players.Enabled and ESP.Settings.Players.Names
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - 60)
                    esp.Name.Text = character.Name
                    
                    -- Health ESP
                    esp.Health.Visible = ESP.Settings.Players.Enabled and ESP.Settings.Players.Health
                    esp.Health.Position = Vector2.new(pos.X, pos.Y + 40)
                    esp.Health.Text = tostring(math.floor(character.Humanoid.Health)) .. "/" .. tostring(character.Humanoid.MaxHealth)
                    
                    -- Chams
                    esp.Chams.Enabled = ESP.Settings.Players.Enabled and ESP.Settings.Players.Chams
                else
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Health.Visible = false
                    esp.Chams.Enabled = false
                end
            end
        else
            ESP.RemoveChild(character)
        end
    end
    
    -- Update objects
    for object, drawing in pairs(ESP.Objects) do
        if object.Parent then
            local pos, onScreen = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(object.Position)
            
            if onScreen then
                drawing.Visible = ESP.Settings.Objects.Enabled
                drawing.Position = Vector2.new(pos.X, pos.Y)
                drawing.Text = object.Name
            else
                drawing.Visible = false
            end
        else
            ESP.RemoveChild(object)
        end
    end
end

-- API for GUI
function ESP.Toggle(category, value)
    ESP.Settings[category].Enabled = value
    if not value then
        ESP.Clear(category)
    end
end

function ESP.ToggleSetting(category, setting, value)
    ESP.Settings[category][setting] = value
end

function ESP.UpdateSetting(category, setting, value)
    ESP.Settings[category][setting] = value
    ESP.UpdateAllVisuals()
end

-- Initialize
ESP.Init()

return ESP
