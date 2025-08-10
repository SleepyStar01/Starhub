-- StarHub UI Library Core (Fixed Version)
-- GitHub: https://raw.githubusercontent.com/SleepyStar01/Starhub/main/hub/core.lua

local StarHub = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Cleanup previous UI
for _, obj in ipairs(CoreGui:GetChildren()) do
    if obj.Name == "StarHubUI" then
        obj:Destroy()
    end
end

function StarHub:CreateWindow(title)
    -- Main container
    local container = Instance.new("ScreenGui")
    container.Name = "StarHubUI"
    container.Parent = CoreGui
    container.ZIndexBehavior = Enum.ZIndexBehavior.Global

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = container
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 26, 32)
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Visible = false

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Parent = mainFrame
    header.BackgroundColor3 = Color3.fromRGB(35, 36, 42)
    header.Size = UDim2.new(1, 0, 0, 30)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = header
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Close button (fixed click handler)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = header
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 1, 0)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    -- Content area (fixed parenting)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Parent = mainFrame
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30)

    -- Tab system
    local tabs = {}
    
    function self:AddTab(tabName)
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Parent = content
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Visible = false
        tabContent.Name = tabName.."Content"
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local tabButton = Instance.new("TextButton")
        tabButton.Parent = header
        tabButton.Text = tabName
        tabButton.Size = UDim2.new(0, 80, 1, 0)
        tabButton.Position = UDim2.new(0, 40 + (#tabs * 85), 0, 0)
        
        tabButton.MouseButton1Click:Connect(function()
            for _, child in content:GetChildren() do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            tabContent.Visible = true
        end)

        table.insert(tabs, tabContent)

        return {
            Button = function(settings)
                local btn = Instance.new("TextButton")
                btn.Parent = tabContent
                btn.Text = settings.Title
                btn.Size = UDim2.new(1, -20, 0, 30)
                btn.Position = UDim2.new(0, 10, 0, #tabContent:GetChildren() * 35)
                btn.MouseButton1Click:Connect(function()
                    pcall(settings.Callback) -- Safe execution
                end)
            end
        }
    end

    -- Toggle visibility
    function self:Toggle()
        mainFrame.Visible = not mainFrame.Visible
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightControl then
            self:Toggle()
        end
    end)

    return self
end

return StarHub
