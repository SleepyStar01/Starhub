local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService('CoreGui')
local Mouse = LocalPlayer:GetMouse()

local StarHub = {
    connections = {},
    Flags = {},
    Enabled = false,
    slider_drag = false,
    dragging = false,
    drag_position = nil,
    start_position = nil,
    theme = {
        Main = Color3.fromRGB(25, 28, 36),
        Secondary = Color3.fromRGB(35, 40, 50),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 180)
    }
}

-- Utility functions
function StarHub:Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

function StarHub:DestroyUI()
    if StarHub.Main then
        StarHub.Main:Destroy()
        StarHub.Main = nil
    end
end

-- Main UI Creation
function StarHub:CreateUI()
    -- Destroy existing UI if it exists
    StarHub:DestroyUI()

    -- Main ScreenGui
    StarHub.Main = StarHub:Create("ScreenGui", {
        Name = "StarHub",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })

    -- Main Frame
    local MainFrame = StarHub:Create("Frame", {
        Name = "MainFrame",
        Parent = StarHub.Main,
        BackgroundColor3 = StarHub.theme.Main,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -350, 0.5, -200),
        Size = UDim2.new(0, 700, 0, 400),
        ZIndex = 2
    })

    -- Corner
    StarHub:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = MainFrame
    })

    -- Drop Shadow
    local Shadow = StarHub:Create("ImageLabel", {
        Name = "Shadow",
        Parent = StarHub.Main,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 30, 1, 30),
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        ZIndex = 1
    })

    -- Top Bar
    local TopBar = StarHub:Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = StarHub.theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 3
    })

    StarHub:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = TopBar
    })

    -- Title
    StarHub:Create("TextLabel", {
        Parent = TopBar,
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = "StarHub",
        TextColor3 = StarHub.theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4
    })

    -- Close Button
    local CloseButton = StarHub:Create("TextButton", {
        Name = "CloseButton",
        Parent = TopBar,
        BackgroundColor3 = StarHub.theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 30, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = "X",
        TextColor3 = StarHub.theme.Text,
        TextSize = 14,
        ZIndex = 4
    })

    CloseButton.MouseButton1Click:Connect(function()
        StarHub:ToggleUI()
    end)

    -- Tab Buttons
    local TabButtons = StarHub:Create("Frame", {
        Name = "TabButtons",
        Parent = MainFrame,
        BackgroundColor3 = StarHub.theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(0, 150, 0, 370),
        ZIndex = 2
    })

    local TabList = StarHub:Create("ScrollingFrame", {
        Name = "TabList",
        Parent = TabButtons,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = StarHub.theme.Accent,
        ZIndex = 3
    })

    StarHub:Create("UIListLayout", {
        Parent = TabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    StarHub:Create("UIPadding", {
        Parent = TabList,
        PaddingTop = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5)
    })

    -- Content Area
    local ContentArea = StarHub:Create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 160, 0, 40),
        Size = UDim2.new(0, 530, 0, 350),
        ZIndex = 2
    })

    -- Dragging functionality
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Toggle keybind
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            StarHub:ToggleUI()
        end
    end)

    -- Return the UI elements we'll need to add content
    return {
        Main = StarHub.Main,
        MainFrame = MainFrame,
        TabList = TabList,
        ContentArea = ContentArea
    }
end

-- UI Toggle
function StarHub:ToggleUI()
    if not StarHub.Main then
        StarHub:CreateUI()
        StarHub.Enabled = true
        return
    end

    StarHub.Enabled = not StarHub.Enabled
    StarHub.Main.Enabled = StarHub.Enabled

    if StarHub.Enabled then
        -- Fade in animation
        StarHub.Main.MainFrame.BackgroundTransparency = 1
        StarHub.Main.Shadow.ImageTransparency = 1
        
        TweenService:Create(StarHub.Main.MainFrame, TweenInfo.new(0.3), {
            BackgroundTransparency = 0
        }):Play()
        
        TweenService:Create(StarHub.Main.Shadow, TweenInfo.new(0.3), {
            ImageTransparency = 0.8
        }):Play()
    else
        -- Fade out animation
        TweenService:Create(StarHub.Main.MainFrame, TweenInfo.new(0.3), {
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(StarHub.Main.Shadow, TweenInfo.new(0.3), {
            ImageTransparency = 1
        }):Play()
    end
end

-- Tab System
function StarHub:CreateTab(tabName, tabIcon)
    if not StarHub.Main then StarHub:CreateUI() end

    local TabButton = StarHub:Create("TextButton", {
        Name = tabName,
        Parent = StarHub.Main.MainFrame.TabButtons.TabList,
        BackgroundColor3 = StarHub.theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 0, 30),
        Font = Enum.Font.GothamSemibold,
        Text = "",
        TextColor3 = StarHub.theme.Text,
        TextSize = 14,
        AutoButtonColor = false,
        ZIndex = 4
    })

    StarHub:Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = TabButton
    })

    local Icon = StarHub:Create("ImageLabel", {
        Name = "Icon",
        Parent = TabButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = tabIcon or "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(324, 364),
        ImageRectSize = Vector2.new(36, 36),
        ZIndex = 5
    })

    local Label = StarHub:Create("TextLabel", {
        Name = "Label",
        Parent = TabButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 30, 0, 0),
        Size = UDim2.new(1, -35, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = tabName,
        TextColor3 = StarHub.theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5
    })

    -- Create content frame for this tab
    local ContentFrame = StarHub:Create("ScrollingFrame", {
        Name = tabName,
        Parent = StarHub.Main.MainFrame.ContentArea,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = StarHub.theme.Accent,
        ZIndex = 3
    })

    StarHub:Create("UIListLayout", {
        Parent = ContentFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })

    StarHub:Create("UIPadding", {
        Parent = ContentFrame,
        PaddingTop = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5)
    })

    -- Tab selection functionality
    TabButton.MouseButton1Click:Connect(function()
        -- Hide all content frames
        for _, child in pairs(StarHub.Main.MainFrame.ContentArea:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                child.Visible = false
            end
        end

        -- Reset all tab button colors
        for _, child in pairs(StarHub.Main.MainFrame.TabButtons.TabList:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = StarHub.theme.Secondary
            end
        end

        -- Show selected content frame and highlight tab button
        ContentFrame.Visible = true
        TabButton.BackgroundColor3 = StarHub.theme.Accent
    end)

    -- Make first tab active by default
    if #StarHub.Main.MainFrame.TabButtons.TabList:GetChildren() == 3 then -- UIListLayout + UIPadding + this tab
        TabButton.BackgroundColor3 = StarHub.theme.Accent
        ContentFrame.Visible = true
    end

    -- Return the content frame for adding elements
    return ContentFrame
end

-- UI Elements
function StarHub:CreateSection(parent, title)
    local Section = StarHub:Create("Frame", {
        Name = title,
        Parent = parent,
        BackgroundColor3 = StarHub.theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 0, 0), -- Height will be set by UIListLayout
        ZIndex = 4
    })

    StarHub:Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = Section
    })

    local Title = StarHub:Create("TextLabel", {
        Name = "Title",
        Parent = Section,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextColor3 = StarHub.theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5
    })

    local Content = StarHub:Create("Frame", {
        Name = "Content",
        Parent = Section,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 0), -- Height will be set by UIListLayout
        ZIndex = 4
    })

    local ListLayout = StarHub:Create("UIListLayout", {
        Parent = Content,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    StarHub:Create("UIPadding", {
        Parent = Content,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })

    -- Auto-size the section based on content
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y)
        Section.Size = UDim2.new(1, -10, 0, ListLayout.AbsoluteContentSize.Y + 35)
    end)

    return Content
end

function StarHub:CreateButton(parent, text, description, callback)
    local Button = StarHub:Create("TextButton", {
        Name = text,
        Parent = parent,
        BackgroundColor3 = StarHub.theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.GothamSemibold,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5
    })

    StarHub:Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = Button
    })

    local Title = StarHub:Create("TextLabel", {
        Name = "Title",
        Parent = Button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = StarHub.theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6
    })

    local Desc = StarHub:Create("TextLabel", {
        Name = "Description",
        Parent = Button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 25),
        Size = UDim2.new(1, -20, 0, 10),
        Font = Enum.Font.Gotham,
        Text = description,
        TextColor3 = StarHub.theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6
    })

    -- Hover effects
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.floor(StarHub.theme.Secondary.R * 255 * 1.1),
                math.floor(StarHub.theme.Secondary.G * 255 * 1.1),
                math.floor(StarHub.theme.Secondary.B * 255 * 1.1)
            )
        }):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = StarHub.theme.Secondary
        }):Play()
    end)

    -- Click effect
    Button.MouseButton1Down:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = StarHub.theme.Accent
        }):Play()
    end)

    Button.MouseButton1Up:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = StarHub.theme.Secondary
        }):Play()
        callback()
    end)

    return Button
end

function StarHub:CreateToggle(parent, text, description, default, flag, callback)
    if not StarHub.Flags[flag] then
        StarHub.Flags[flag] = default
    end

    local Toggle = StarHub:Create("TextButton", {
        Name = text,
        Parent = parent,
        BackgroundColor3 = StarHub.theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.GothamSemibold,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5
    })

    StarHub:Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = Toggle
    })

    local Title = StarHub:Create("TextLabel", {
        Name = "Title",
        Parent = Toggle,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(0.8, -20, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = StarHub.theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6
    })

    local Desc = StarHub:Create("TextLabel", {
        Name = "Description",
        Parent = Toggle,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 25),
        Size = UDim2.new(0.8, -20, 0, 10),
        Font = Enum.Font.Gotham,
        Text = description,
        TextColor3 = StarHub.theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6
    })

    local ToggleFrame = StarHub:Create("Frame", {
        Name = "ToggleFrame",
        Parent = Toggle,
        BackgroundColor3 = StarHub.theme.Secondary,
        BorderColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 1,
        Position = UDim2.new(1, -35, 0.5, -10),
        Size = UDim2.new(0, 30, 0, 20),
        ZIndex = 6
    })

    StarHub:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ToggleFrame
    })

    local ToggleCircle = StarHub:Create("Frame", {
        Name = "ToggleCircle",
        Parent = ToggleFrame,
        BackgroundColor3 = StarHub.theme.Text,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 2, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        ZIndex = 7
    })

    StarHub:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ToggleCircle
    })

    -- Update toggle state
    local function updateToggle()
        if StarHub.Flags[flag] then
            TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {
                BackgroundColor3 = StarHub.theme.Accent,
                BorderColor3 = StarHub.theme.Accent
            }):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -18, 0.5, -8)
            }):Play()
        else
            TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {
                BackgroundColor3 = StarHub.theme.Secondary,
                BorderColor3 = Color3.fromRGB(60, 60, 60)
            }):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0.5, -8)
            }):Play()
        end
    end

    -- Initialize
    updateToggle()

    -- Toggle on click
    Toggle.MouseButton1Click:Connect(function()
        StarHub.Flags[flag] = not StarHub.Flags[flag]
        updateToggle()
        callback(StarHub.Flags[flag])
    end)

    return Toggle
end

-- Initialize the UI
StarHub:CreateUI()
StarHub:ToggleUI() -- Start with UI hidden

return StarHub
