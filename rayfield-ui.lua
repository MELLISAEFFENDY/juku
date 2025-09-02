--[[
    Rayfield UI Library - Local Implementation
    Created by: MELLISAEFFENDY
    Description: Fast, modern UI library for Roblox scripts
    
    Features:
    ⚡ Ultra-fast performance
    🎨 Modern design
    📱 Mobile-friendly
    🔧 Easy to use API
]]

local Rayfield = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Create main GUI
function Rayfield:CreateWindow(Config)
    local WindowConfig = Config or {}
    
    -- Main ScreenGui
    local RayfieldGui = Instance.new("ScreenGui")
    RayfieldGui.Name = "RayfieldUI"
    RayfieldGui.Parent = PlayerGui
    RayfieldGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    RayfieldGui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = RayfieldGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Size = UDim2.new(0, 550, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Corner radius
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- Stroke
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(0, 162, 255)
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Size = UDim2.new(1, -100, 1, 0)
    TitleText.Position = UDim2.new(0, 20, 0, 0)
    TitleText.Text = WindowConfig.Name or "Rayfield UI"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextScaled = true
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    CloseButton.BorderSizePixel = 0
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -40, 0.5, -15)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextScaled = true
    CloseButton.Font = Enum.Font.GothamBold
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        RayfieldGui:Destroy()
    end)
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundTransparency = 1
    TabContainer.Size = UDim2.new(0, 120, 1, -60)
    TabContainer.Position = UDim2.new(0, 10, 0, 55)
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabContainer
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Size = UDim2.new(1, -150, 1, -70)
    ContentContainer.Position = UDim2.new(0, 140, 0, 60)
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = ContentContainer
    
    -- Window object
    local Window = {
        GUI = RayfieldGui,
        MainFrame = MainFrame,
        TabContainer = TabContainer,
        ContentContainer = ContentContainer,
        CurrentTab = nil,
        Tabs = {}
    }
    
    function Window:CreateTab(Config)
        local TabConfig = Config or {}
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabButton"
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.Text = TabConfig.Name or "Tab"
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextScaled = true
        TabButton.Font = Enum.Font.Gotham
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        -- Tab Content Frame
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = "TabContent"
        TabContent.Parent = ContentContainer
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, -20, 1, -20)
        TabContent.Position = UDim2.new(0, 10, 0, 10)
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
        TabContent.Visible = false
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = TabContent
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)
        
        -- Tab object
        local Tab = {
            Button = TabButton,
            Content = TabContent,
            Elements = {}
        }
        
        -- Tab click handler
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            -- Show current tab
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            Window.CurrentTab = Tab
        end)
        
        -- Auto-select first tab
        if #Window.Tabs == 0 then
            TabButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Tab functions
        function Tab:CreateButton(Config)
            local ButtonConfig = Config or {}
            
            local Button = Instance.new("TextButton")
            Button.Name = "Button"
            Button.Parent = TabContent
            Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            Button.BorderSizePixel = 0
            Button.Size = UDim2.new(1, 0, 0, 40)
            Button.Text = ButtonConfig.Name or "Button"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextScaled = true
            Button.Font = Enum.Font.Gotham
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = Button
            
            Button.MouseButton1Click:Connect(function()
                if ButtonConfig.Callback then
                    ButtonConfig.Callback()
                end
            end)
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            return Button
        end
        
        function Tab:CreateToggle(Config)
            local ToggleConfig = Config or {}
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "ToggleFrame"
            ToggleFrame.Parent = TabContent
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "ToggleLabel"
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Size = UDim2.new(1, -80, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
            ToggleLabel.Text = ToggleConfig.Name or "Toggle"
            ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleLabel.TextScaled = true
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Parent = ToggleFrame
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Size = UDim2.new(0, 50, 0, 25)
            ToggleButton.Position = UDim2.new(1, -65, 0.5, -12.5)
            ToggleButton.Text = ""
            
            local ToggleBtnCorner = Instance.new("UICorner")
            ToggleBtnCorner.CornerRadius = UDim.new(0, 12)
            ToggleBtnCorner.Parent = ToggleButton
            
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Name = "ToggleIndicator"
            ToggleIndicator.Parent = ToggleButton
            ToggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Size = UDim2.new(0, 21, 0, 21)
            ToggleIndicator.Position = UDim2.new(0, 2, 0, 2)
            
            local IndicatorCorner = Instance.new("UICorner")
            IndicatorCorner.CornerRadius = UDim.new(0, 10)
            IndicatorCorner.Parent = ToggleIndicator
            
            local isToggled = ToggleConfig.Default or false
            
            local function updateToggle()
                if isToggled then
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
                    ToggleIndicator.Position = UDim2.new(1, -23, 0, 2)
                    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                else
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
                    ToggleIndicator.Position = UDim2.new(0, 2, 0, 2)
                    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                end
                
                if ToggleConfig.Callback then
                    ToggleConfig.Callback(isToggled)
                end
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                updateToggle()
            end)
            
            updateToggle()
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            return {
                Set = function(value)
                    isToggled = value
                    updateToggle()
                end
            }
        end
        
        -- Compatibility methods for OrionLib API
        function Tab:AddButton(Config)
            return self:CreateButton(Config)
        end
        
        function Tab:AddToggle(Config)
            return self:CreateToggle(Config)
        end
        
        function Tab:AddSlider(Config)
            local SliderConfig = Config or {}
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = "SliderFrame"
            SliderFrame.Parent = TabContent
            SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Size = UDim2.new(1, 0, 0, 60)
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "SliderLabel"
            SliderLabel.Parent = SliderFrame
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Size = UDim2.new(1, -80, 0, 25)
            SliderLabel.Position = UDim2.new(0, 15, 0, 5)
            SliderLabel.Text = SliderConfig.Name or "Slider"
            SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderLabel.TextScaled = true
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = "ValueLabel"
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Size = UDim2.new(0, 60, 0, 25)
            ValueLabel.Position = UDim2.new(1, -75, 0, 5)
            ValueLabel.Text = tostring(SliderConfig.Default or SliderConfig.Min or 0)
            ValueLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
            ValueLabel.TextScaled = true
            ValueLabel.Font = Enum.Font.GothamBold
            
            local SliderBar = Instance.new("Frame")
            SliderBar.Name = "SliderBar"
            SliderBar.Parent = SliderFrame
            SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            SliderBar.BorderSizePixel = 0
            SliderBar.Size = UDim2.new(1, -30, 0, 6)
            SliderBar.Position = UDim2.new(0, 15, 1, -20)
            
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(0, 3)
            BarCorner.Parent = SliderBar
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "SliderFill"
            SliderFill.Parent = SliderBar
            SliderFill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
            SliderFill.BorderSizePixel = 0
            SliderFill.Size = UDim2.new(0, 0, 1, 0)
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(0, 3)
            FillCorner.Parent = SliderFill
            
            local currentValue = SliderConfig.Default or SliderConfig.Min or 0
            local minValue = SliderConfig.Min or 0
            local maxValue = SliderConfig.Max or 100
            
            local function updateSlider()
                local percentage = (currentValue - minValue) / (maxValue - minValue)
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                ValueLabel.Text = tostring(math.floor(currentValue))
                
                if SliderConfig.Callback then
                    SliderConfig.Callback(currentValue)
                end
            end
            
            local dragging = false
            
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mouse = UserInputService:GetMouseLocation()
                    local sliderPos = SliderBar.AbsolutePosition
                    local sliderSize = SliderBar.AbsoluteSize
                    
                    local percentage = math.clamp((mouse.X - sliderPos.X) / sliderSize.X, 0, 1)
                    currentValue = minValue + (percentage * (maxValue - minValue))
                    updateSlider()
                end
            end)
            
            updateSlider()
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            return {
                Set = function(value)
                    currentValue = math.clamp(value, minValue, maxValue)
                    updateSlider()
                end
            }
        end
        
        function Tab:AddDropdown(Config)
            return self:CreateDropdown(Config)
        end
        
        function Tab:AddSection(Config)
            local SectionConfig = Config or {}
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "SectionFrame"
            SectionFrame.Parent = TabContent
            SectionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Size = UDim2.new(1, 0, 0, 30)
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = SectionFrame
            
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Name = "SectionLabel"
            SectionLabel.Parent = SectionFrame
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Size = UDim2.new(1, -20, 1, 0)
            SectionLabel.Position = UDim2.new(0, 10, 0, 0)
            SectionLabel.Text = SectionConfig.Name or "Section"
            SectionLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
            SectionLabel.TextScaled = true
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            -- Return the tab itself so methods can be chained
            return Tab
        end
        
        function Tab:CreateToggle(Config)
            local ToggleConfig = Config or {}
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "ToggleFrame"
            ToggleFrame.Parent = TabContent
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "ToggleLabel"
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Size = UDim2.new(1, -80, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
            ToggleLabel.Text = ToggleConfig.Name or "Toggle"
            ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleLabel.TextScaled = true
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Parent = ToggleFrame
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Size = UDim2.new(0, 50, 0, 25)
            ToggleButton.Position = UDim2.new(1, -65, 0.5, -12.5)
            ToggleButton.Text = ""
            
            local ToggleBtnCorner = Instance.new("UICorner")
            ToggleBtnCorner.CornerRadius = UDim.new(0, 12)
            ToggleBtnCorner.Parent = ToggleButton
            
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Name = "ToggleIndicator"
            ToggleIndicator.Parent = ToggleButton
            ToggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Size = UDim2.new(0, 21, 0, 21)
            ToggleIndicator.Position = UDim2.new(0, 2, 0, 2)
            
            local IndicatorCorner = Instance.new("UICorner")
            IndicatorCorner.CornerRadius = UDim.new(0, 10)
            IndicatorCorner.Parent = ToggleIndicator
            
            local isToggled = ToggleConfig.Default or false
            
            local function updateToggle()
                if isToggled then
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
                    ToggleIndicator.Position = UDim2.new(1, -23, 0, 2)
                    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                else
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
                    ToggleIndicator.Position = UDim2.new(0, 2, 0, 2)
                    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                end
                
                if ToggleConfig.Callback then
                    ToggleConfig.Callback(isToggled)
                end
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                updateToggle()
            end)
            
            updateToggle()
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            return {
                Set = function(value)
                    isToggled = value
                    updateToggle()
                end
            }
        end
        
        function Tab:CreateSlider(Config)
            local SliderConfig = Config or {}
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = "SliderFrame"
            SliderFrame.Parent = TabContent
            SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Size = UDim2.new(1, 0, 0, 60)
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "SliderLabel"
            SliderLabel.Parent = SliderFrame
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Size = UDim2.new(1, -80, 0, 25)
            SliderLabel.Position = UDim2.new(0, 15, 0, 5)
            SliderLabel.Text = SliderConfig.Name or "Slider"
            SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderLabel.TextScaled = true
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = "ValueLabel"
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Size = UDim2.new(0, 60, 0, 25)
            ValueLabel.Position = UDim2.new(1, -75, 0, 5)
            ValueLabel.Text = tostring(SliderConfig.Default or SliderConfig.Min or 0)
            ValueLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
            ValueLabel.TextScaled = true
            ValueLabel.Font = Enum.Font.GothamBold
            
            local SliderBar = Instance.new("Frame")
            SliderBar.Name = "SliderBar"
            SliderBar.Parent = SliderFrame
            SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            SliderBar.BorderSizePixel = 0
            SliderBar.Size = UDim2.new(1, -30, 0, 6)
            SliderBar.Position = UDim2.new(0, 15, 1, -20)
            
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(0, 3)
            BarCorner.Parent = SliderBar
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "SliderFill"
            SliderFill.Parent = SliderBar
            SliderFill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
            SliderFill.BorderSizePixel = 0
            SliderFill.Size = UDim2.new(0, 0, 1, 0)
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(0, 3)
            FillCorner.Parent = SliderFill
            
            local currentValue = SliderConfig.Default or SliderConfig.Min or 0
            local minValue = SliderConfig.Min or 0
            local maxValue = SliderConfig.Max or 100
            
            local function updateSlider()
                local percentage = (currentValue - minValue) / (maxValue - minValue)
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                ValueLabel.Text = tostring(math.floor(currentValue))
                
                if SliderConfig.Callback then
                    SliderConfig.Callback(currentValue)
                end
            end
            
            local dragging = false
            
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mouse = UserInputService:GetMouseLocation()
                    local sliderPos = SliderBar.AbsolutePosition
                    local sliderSize = SliderBar.AbsoluteSize
                    
                    local percentage = math.clamp((mouse.X - sliderPos.X) / sliderSize.X, 0, 1)
                    currentValue = minValue + (percentage * (maxValue - minValue))
                    updateSlider()
                end
            end)
            
            updateSlider()
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            return {
                Set = function(value)
                    currentValue = math.clamp(value, minValue, maxValue)
                    updateSlider()
                end
            }
        end
            local DropdownConfig = Config or {}
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = "DropdownFrame"
            DropdownFrame.Parent = TabContent
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
            
            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Name = "DropdownButton"
            DropdownButton.Parent = DropdownFrame
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Size = UDim2.new(1, 0, 1, 0)
            DropdownButton.Text = DropdownConfig.Name or "Dropdown"
            DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropdownButton.TextScaled = true
            DropdownButton.Font = Enum.Font.Gotham
            DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
            DropdownButton.TextXOffset = 15
            
            local DropdownArrow = Instance.new("TextLabel")
            DropdownArrow.Name = "DropdownArrow"
            DropdownArrow.Parent = DropdownFrame
            DropdownArrow.BackgroundTransparency = 1
            DropdownArrow.Size = UDim2.new(0, 30, 1, 0)
            DropdownArrow.Position = UDim2.new(1, -30, 0, 0)
            DropdownArrow.Text = "▼"
            DropdownArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropdownArrow.TextScaled = true
            DropdownArrow.Font = Enum.Font.Gotham
            
            local DropdownList = Instance.new("Frame")
            DropdownList.Name = "DropdownList"
            DropdownList.Parent = DropdownFrame
            DropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            DropdownList.BorderSizePixel = 0
            DropdownList.Size = UDim2.new(1, 0, 0, 0)
            DropdownList.Position = UDim2.new(0, 0, 1, 5)
            DropdownList.Visible = false
            DropdownList.ZIndex = 10
            
            local ListCorner = Instance.new("UICorner")
            ListCorner.CornerRadius = UDim.new(0, 6)
            ListCorner.Parent = DropdownList
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = DropdownList
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local isOpen = false
            local selectedValue = DropdownConfig.Default
            
            if selectedValue then
                DropdownButton.Text = selectedValue
            end
            
            DropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                if isOpen then
                    DropdownList.Visible = true
                    DropdownArrow.Text = "▲"
                    
                    -- Create options
                    for _, option in pairs(DropdownConfig.Options or {}) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Name = "OptionButton"
                        OptionButton.Parent = DropdownList
                        OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                        OptionButton.BorderSizePixel = 0
                        OptionButton.Size = UDim2.new(1, 0, 0, 30)
                        OptionButton.Text = option
                        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        OptionButton.TextScaled = true
                        OptionButton.Font = Enum.Font.Gotham
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            selectedValue = option
                            DropdownButton.Text = option
                            
                            if DropdownConfig.Callback then
                                DropdownConfig.Callback(option)
                            end
                            
                            -- Close dropdown
                            isOpen = false
                            DropdownList.Visible = false
                            DropdownArrow.Text = "▼"
                            
                            -- Clear options
                            for _, child in pairs(DropdownList:GetChildren()) do
                                if child:IsA("TextButton") then
                                    child:Destroy()
                                end
                            end
                        end)
                    end
                    
                    -- Update list size
                    DropdownList.Size = UDim2.new(1, 0, 0, #(DropdownConfig.Options or {}) * 30)
                else
                    DropdownList.Visible = false
                    DropdownArrow.Text = "▼"
                    
                    -- Clear options
                    for _, child in pairs(DropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                end
            end)
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            return {
                Set = function(value)
                    selectedValue = value
                    DropdownButton.Text = value
                    if DropdownConfig.Callback then
                        DropdownConfig.Callback(value)
                    end
                end
            }
        end
        
        return Tab
    end
    
    -- Compatibility function for OrionLib API
    function Window:MakeTab(Config)
        return self:CreateTab(Config)
    end
    
    return Window
end

-- Notification system
function Rayfield:Notify(Config)
    local NotifyConfig = Config or {}
    
    local NotifyGui = Instance.new("ScreenGui")
    NotifyGui.Name = "RayfieldNotification"
    NotifyGui.Parent = PlayerGui
    NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Name = "NotifyFrame"
    NotifyFrame.Parent = NotifyGui
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.Size = UDim2.new(0, 300, 0, 80)
    NotifyFrame.Position = UDim2.new(1, 0, 0, 50)
    
    local NotifyCorner = Instance.new("UICorner")
    NotifyCorner.CornerRadius = UDim.new(0, 8)
    NotifyCorner.Parent = NotifyFrame
    
    local NotifyStroke = Instance.new("UIStroke")
    NotifyStroke.Color = Color3.fromRGB(0, 162, 255)
    NotifyStroke.Thickness = 2
    NotifyStroke.Parent = NotifyFrame
    
    local NotifyTitle = Instance.new("TextLabel")
    NotifyTitle.Name = "NotifyTitle"
    NotifyTitle.Parent = NotifyFrame
    NotifyTitle.BackgroundTransparency = 1
    NotifyTitle.Size = UDim2.new(1, -20, 0, 25)
    NotifyTitle.Position = UDim2.new(0, 10, 0, 5)
    NotifyTitle.Text = NotifyConfig.Title or "Notification"
    NotifyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifyTitle.TextScaled = true
    NotifyTitle.Font = Enum.Font.GothamBold
    NotifyTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local NotifyContent = Instance.new("TextLabel")
    NotifyContent.Name = "NotifyContent"
    NotifyContent.Parent = NotifyFrame
    NotifyContent.BackgroundTransparency = 1
    NotifyContent.Size = UDim2.new(1, -20, 0, 40)
    NotifyContent.Position = UDim2.new(0, 10, 0, 30)
    NotifyContent.Text = NotifyConfig.Content or ""
    NotifyContent.TextColor3 = Color3.fromRGB(200, 200, 200)
    NotifyContent.TextScaled = true
    NotifyContent.Font = Enum.Font.Gotham
    NotifyContent.TextXAlignment = Enum.TextXAlignment.Left
    NotifyContent.TextWrapped = true
    
    -- Slide in animation
    local slideIn = TweenService:Create(NotifyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -320, 0, 50)
    })
    slideIn:Play()
    
    -- Auto-close after duration
    local duration = NotifyConfig.Duration or 5
    wait(duration)
    
    -- Slide out animation
    local slideOut = TweenService:Create(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(1, 0, 0, 50)
    })
    slideOut:Play()
    
    slideOut.Completed:Connect(function()
        NotifyGui:Destroy()
    end)
end

-- OrionLib Compatibility Layer
local CompatibilityLayer = {}

-- Debug: Add some debug info
print("🔧 Rayfield UI: Setting up OrionLib compatibility layer...")

-- Make Rayfield compatible with OrionLib API
function CompatibilityLayer:MakeWindow(Config)
    print("🪟 MakeWindow called via method syntax")
    return Rayfield:CreateWindow(Config)
end

function CompatibilityLayer.MakeWindow(Config)
    print("🪟 MakeWindow called via function syntax")
    return Rayfield:CreateWindow(Config)
end

-- Copy all Rayfield methods to compatibility layer
for key, value in pairs(Rayfield) do
    if type(value) == "function" then
        CompatibilityLayer[key] = value
    end
end

-- Additional OrionLib methods
CompatibilityLayer.MakeNotification = function(Config)
    return Rayfield:Notify(Config)
end

CompatibilityLayer.Init = function()
    print("✅ OrionLib compatibility layer initialized")
    return true
end

CompatibilityLayer.Destroy = function()
    if Rayfield.Destroy then
        return Rayfield:Destroy()
    end
end

-- Debug: Show available methods
print("🔍 Available methods in CompatibilityLayer:")
for key, value in pairs(CompatibilityLayer) do
    if type(value) == "function" then
        print("   📝 " .. key .. ": " .. type(value))
    end
end

-- Ensure MakeWindow is definitely available
if CompatibilityLayer.MakeWindow then
    print("✅ MakeWindow method is available!")
else
    print("❌ MakeWindow method is missing!")
    -- Force add it if missing
    CompatibilityLayer.MakeWindow = function(Config)
        print("🔧 Force-created MakeWindow function")
        return Rayfield:CreateWindow(Config)
    end
end

return CompatibilityLayer
