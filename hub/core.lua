-- StarHub UI Library
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local CoreGui = game:GetService('CoreGui')

local StarHub = {
    connections = {},
    Flags = {},
    Enabled = true,
    slider_drag = false,
    core = nil,
    dragging = false,
    drag_position = nil,
    start_position = nil
}

-- 🌟 NOTIFICATION SYSTEM
function StarHub:Notify(title, message)
    print("[StarHub] "..title..": "..message)
    -- Can be enhanced with visual UI notifications
end

-- 🖼️ CREATE MAIN WINDOW
function StarHub:CreateWindow(title)
    -- Clear existing UI
    for _, object in CoreGui:GetChildren() do
        if object.Name == "StarHubUI" then
            object:Destroy()
        end
    end

    -- Main container
    local container = Instance.new("ScreenGui")
    container.Name = "StarHubUI"
    container.Parent = CoreGui
    StarHub.core = container

    -- Main frame (simplified from original)
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = container
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(19, 20, 24)
    Container.BackgroundTransparency = 0.5
    Container.Size = UDim2.new(0, 600, 0, 400)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Visible = false

    -- Title bar
    local Top = Instance.new("Frame")
    Top.Name = "Top"
    Top.Parent = Container
    Top.BackgroundColor3 = Color3.fromRGB(30, 31, 38)
    Top.Size = UDim2.new(1, 0, 0, 30)

    local Title = Instance.new("TextLabel")
    Title.Parent = Top
    Title.Text = "  "..title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Font = Enum.Font.GothamSemibold

    -- Close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = Top
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    CloseButton.MouseButton1Click:Connect(function()
        StarHub:Close()
    end)

    -- Tab system
    local Tabs = Instance.new("Frame")
    Tabs.Name = "Tabs"
    Tabs.Parent = Container
    Tabs.BackgroundColor3 = Color3.fromRGB(25, 26, 32)
    Tabs.Size = UDim2.new(0, 150, 1, -30)
    Tabs.Position = UDim2.new(0, 0, 0, 30)

    -- Content area
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Parent = Container
    Content.BackgroundTransparency = 1
    Content.Size = UDim2.new(1, -150, 1, -30)
    Content.Position = UDim2.new(0, 150, 0, 30)

    -- Window controls
    function StarHub:Open()
        Container.Visible = true
        TweenService:Create(Container, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 600, 0, 400)
        }):Play()
    end

    function StarHub:Close()
        TweenService:Create(Container, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.3)
        Container.Visible = false
    end

    -- Toggle visibility
    function StarHub:Toggle()
        StarHub.Enabled = not StarHub.Enabled
        if StarHub.Enabled then
            StarHub:Open()
        else
            StarHub:Close()
        end
    end

    -- Keybind to toggle UI
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.RightControl then
            StarHub:Toggle()
        end
    end)

    -- Return tab creation function
    return {
        AddTab = function(self, tabName)
            local TabButton = Instance.new("TextButton")
            TabButton.Parent = Tabs
            TabButton.Text = tabName
            TabButton.Size = UDim2.new(1, 0, 0, 30)
            TabButton.Position = UDim2.new(0, 0, 0, #Tabs:GetChildren() * 30)
            TabButton.BackgroundColor3 = Color3.fromRGB(35, 36, 42)

            local TabContent = Instance.new("ScrollingFrame")
            TabContent.Parent = Content
            TabContent.Size = UDim2.new(1, 0, 1, 0)
            TabContent.Visible = false
            TabContent.Name = tabName.."Content"
            TabContent.BackgroundTransparency = 1
            TabContent.ScrollBarThickness = 5

            if #Tabs:GetChildren() == 1 then
                TabContent.Visible = true
            end

            TabButton.MouseButton1Click:Connect(function()
                for _, child in Content:GetChildren() do
                    if child:IsA("ScrollingFrame") then
                        child.Visible = false
                    end
                end
                TabContent.Visible = true
            end)

            -- Return functions to add controls
            return {
                Button = function(self, params)
                    -- Button implementation here
                    local Button = Instance.new("TextButton")
                    Button.Parent = TabContent
                    Button.Text = params.Title
                    Button.Size = UDim2.new(1, -20, 0, 30)
                    Button.Position = UDim2.new(0, 10, 0, #TabContent:GetChildren() * 35)
                    Button.MouseButton1Click = params.Callback
                end,
                Toggle = function(self, params)
                    -- Toggle implementation here
                end,
                -- Add other control types as needed
            }
        end
    }
end

-- 🚀 INITIALIZE STARHUB
local Window = StarHub:CreateWindow("StarHub v1.0")
local MainTab = Window:AddTab("Main")
local SettingsTab = Window:AddTab("Settings")

-- Example usage
MainTab:Button({
    Title = "Test Button",
    Callback = function()
        StarHub:Notify("Test", "Button clicked!")
    end
})

return StarHub
