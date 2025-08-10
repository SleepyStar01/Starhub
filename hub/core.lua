-- StarHub UI Library Core
-- GitHub: https://raw.githubusercontent.com/SleepyStar01/Starhub/main/hub/core.lua

local StarHub = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Configuration
StarHub.settings = {
    Keybind = Enum.KeyCode.RightControl,
    DefaultSize = UDim2.new(0, 600, 0, 400),
    Theme = {
        Background = Color3.fromRGB(19, 20, 24),
        Header = Color3.fromRGB(30, 31, 38),
        Accent = Color3.fromRGB(66, 89, 182)
    }
}

-- Notification system
function StarHub:Notify(title, message, duration)
    duration = duration or 3
    print("[StarHub]", title, "-", message)
    -- Can be enhanced with visual notifications
end

-- Create main window
function StarHub:CreateWindow(title)
    -- Cleanup previous UI
    self:DestroyUI()

    -- Main container
    local container = Instance.new("ScreenGui")
    container.Name = "StarHubUI"
    container.Parent = CoreGui
    self.core = container

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = container
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = self.settings.Theme.Background
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Visible = false

    -- Add UI elements (header, tabs, etc.)
    -- ... (rest of your UI implementation)

    -- Window controls
    function self:Open()
        mainFrame.Visible = true
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {
            Size = self.settings.DefaultSize
        }):Play()
    end

    function self:Close()
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.3)
        mainFrame.Visible = false
    end

    -- Toggle visibility
    function self:Toggle()
        if mainFrame.Visible then
            self:Close()
        else
            self:Open()
        end
    end

    -- Set up keybind
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == self.settings.Keybind then
            self:Toggle()
        end
    end)

    return {
        AddTab = function(tabName)
            -- Tab implementation
            return {
                Button = function(settings)
                    -- Button implementation
                end,
                Toggle = function(settings)
                    -- Toggle implementation
                end
                -- Add other controls as needed
            }
        end
    }
end

-- Cleanup function
function StarHub:DestroyUI()
    if self.core and self.core.Parent then
        self.core:Destroy()
    end
    self.core = nil
end

return StarHub
