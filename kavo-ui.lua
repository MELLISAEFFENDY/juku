--[[
    Kavo UI Library - Local Version
    Created by: MELLISAEFFENDY
    Based on: Kavo UI Framework
    Description: Simple, clean, and performant UI library
    
    Features:
    🎯 Minimalist design
    🚀 Fast performance
    📱 Mobile-friendly
    🔧 Easy API
]]

local Library = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Create main window
function Library.CreateLib(title, theme)
    local KavoGui = Instance.new("ScreenGui")
    KavoGui.Name = "KavoUI"
    KavoGui.Parent = PlayerGui
    KavoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KavoGui.ResetOnSpawn = false
    
    -- Main frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = KavoGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Corner radius
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    -- Stroke
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(46, 204, 113)
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame
    
    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    -- Title text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Size = UDim2.new(1, -80, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.Text = title or "Kavo UI"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextScaled = true
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextScaled = true
    CloseBtn.Font = Enum.Font.GothamBold
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        KavoGui:Destroy()
    end)
    
    -- Tab sidebar
    local TabSidebar = Instance.new("Frame")
    TabSidebar.Name = "TabSidebar"
    TabSidebar.Parent = MainFrame
    TabSidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabSidebar.BorderSizePixel = 0
    TabSidebar.Size = UDim2.new(0, 120, 1, -50)
    TabSidebar.Position = UDim2.new(0, 5, 0, 45)
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 6)
    SidebarCorner.Parent = TabSidebar
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabSidebar
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 2)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.Parent = TabSidebar
    TabPadding.PaddingTop = UDim.new(0, 5)
    TabPadding.PaddingLeft = UDim.new(0, 5)
    TabPadding.PaddingRight = UDim.new(0, 5)
    
    -- Content area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ContentArea.BorderSizePixel = 0
    ContentArea.Size = UDim2.new(1, -135, 1, -50)
    ContentArea.Position = UDim2.new(0, 130, 0, 45)
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 6)
    ContentCorner.Parent = ContentArea
    
    -- Library object
    local Lib = {
        GUI = KavoGui,
        MainFrame = MainFrame,
        TabSidebar = TabSidebar,
        ContentArea = ContentArea,
        CurrentTab = nil,
        Tabs = {}
    }
    
    function Lib:NewTab(tabName)
        -- Tab button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabButton"
        TabButton.Parent = TabSidebar
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, -10, 0, 30)
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextScaled = true
        TabButton.Font = Enum.Font.Gotham
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabButton
        
        -- Tab content frame
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = "TabContent"
        TabContent.Parent = ContentArea
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, -20, 1, -20)
        TabContent.Position = UDim2.new(0, 10, 0, 10)
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(46, 204, 113)
        TabContent.Visible = false
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = TabContent
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 5)
        
        -- Tab object
        local Tab = {
            Button = TabButton,
            Content = TabContent,
            Elements = {}
        }
        
        -- Tab click handler
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, tab in pairs(Lib.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            -- Show current tab
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            Lib.CurrentTab = Tab
        end)
        
        -- Auto-select first tab
        if #Lib.Tabs == 0 then
            TabButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            Lib.CurrentTab = Tab
        end
        
        table.insert(Lib.Tabs, Tab)
        
        -- Tab section object
        local Section = {}
        
        function Section:NewButton(buttonName, callback)
            local Button = Instance.new("TextButton")
            Button.Name = "Button"
            Button.Parent = TabContent
            Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Button.BorderSizePixel = 0
            Button.Size = UDim2.new(1, 0, 0, 35)
            Button.Text = buttonName
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextScaled = true
            Button.Font = Enum.Font.Gotham
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 4)
            ButtonCorner.Parent = Button
            
            Button.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            return Button
        end
        
        function Section:NewToggle(toggleName, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "ToggleFrame"
            ToggleFrame.Parent = TabContent
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 4)
            ToggleCorner.Parent = ToggleFrame
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "ToggleLabel"
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.Text = toggleName
            ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleLabel.TextScaled = true
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Parent = ToggleFrame
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Size = UDim2.new(0, 40, 0, 20)
            ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
            ToggleButton.Text = ""
            
            local ToggleBtnCorner = Instance.new("UICorner")
            ToggleBtnCorner.CornerRadius = UDim.new(0, 10)
            ToggleBtnCorner.Parent = ToggleButton
            
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Name = "ToggleIndicator"
            ToggleIndicator.Parent = ToggleButton
            ToggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
            ToggleIndicator.Position = UDim2.new(0, 2, 0, 2)
            
            local IndicatorCorner = Instance.new("UICorner")
            IndicatorCorner.CornerRadius = UDim.new(0, 8)
            IndicatorCorner.Parent = ToggleIndicator
            
            local isToggled = false
            
            local function updateToggle()
                if isToggled then
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                    ToggleIndicator.Position = UDim2.new(1, -18, 0, 2)
                    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                else
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    ToggleIndicator.Position = UDim2.new(0, 2, 0, 2)
                    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                end
                
                if callback then
                    callback(isToggled)
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
        
        function Section:NewSlider(sliderName, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = "SliderFrame"
            SliderFrame.Parent = TabContent
            SliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 4)
            SliderCorner.Parent = SliderFrame
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "SliderLabel"
            SliderLabel.Parent = SliderFrame
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Size = UDim2.new(1, -60, 0, 20)
            SliderLabel.Position = UDim2.new(0, 10, 0, 5)
            SliderLabel.Text = sliderName
            SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderLabel.TextScaled = true
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = "ValueLabel"
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -60, 0, 5)
            ValueLabel.Text = tostring(default or min)
            ValueLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
            ValueLabel.TextScaled = true
            ValueLabel.Font = Enum.Font.GothamBold
            
            local SliderBar = Instance.new("Frame")
            SliderBar.Name = "SliderBar"
            SliderBar.Parent = SliderFrame
            SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            SliderBar.BorderSizePixel = 0
            SliderBar.Size = UDim2.new(1, -20, 0, 4)
            SliderBar.Position = UDim2.new(0, 10, 1, -15)
            
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(0, 2)
            BarCorner.Parent = SliderBar
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "SliderFill"
            SliderFill.Parent = SliderBar
            SliderFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            SliderFill.BorderSizePixel = 0
            SliderFill.Size = UDim2.new(0, 0, 1, 0)
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(0, 2)
            FillCorner.Parent = SliderFill
            
            local currentValue = default or min
            
            local function updateSlider()
                local percentage = (currentValue - min) / (max - min)
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                ValueLabel.Text = tostring(math.floor(currentValue))
                
                if callback then
                    callback(currentValue)
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
                    currentValue = min + (percentage * (max - min))
                    updateSlider()
                end
            end)
            
            updateSlider()
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            return {
                Set = function(value)
                    currentValue = math.clamp(value, min, max)
                    updateSlider()
                end
            }
        end
        
        function Section:NewDropdown(dropdownName, options, callback)
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = "DropdownFrame"
            DropdownFrame.Parent = TabContent
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            
            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 4)
            DropdownCorner.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Name = "DropdownButton"
            DropdownButton.Parent = DropdownFrame
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Size = UDim2.new(1, 0, 1, 0)
            DropdownButton.Text = dropdownName
            DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropdownButton.TextScaled = true
            DropdownButton.Font = Enum.Font.Gotham
            DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
            DropdownButton.TextXOffset = 10
            
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
            DropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            DropdownList.BorderSizePixel = 0
            DropdownList.Size = UDim2.new(1, 0, 0, 0)
            DropdownList.Position = UDim2.new(0, 0, 1, 2)
            DropdownList.Visible = false
            DropdownList.ZIndex = 10
            
            local ListCorner = Instance.new("UICorner")
            ListCorner.CornerRadius = UDim.new(0, 4)
            ListCorner.Parent = DropdownList
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = DropdownList
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local isOpen = false
            local selectedValue = options[1]
            
            DropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                if isOpen then
                    DropdownList.Visible = true
                    DropdownArrow.Text = "▲"
                    
                    -- Clear existing options
                    for _, child in pairs(DropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Create option buttons
                    for _, option in pairs(options) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Name = "OptionButton"
                        OptionButton.Parent = DropdownList
                        OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        OptionButton.BorderSizePixel = 0
                        OptionButton.Size = UDim2.new(1, 0, 0, 25)
                        OptionButton.Text = option
                        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        OptionButton.TextScaled = true
                        OptionButton.Font = Enum.Font.Gotham
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            selectedValue = option
                            DropdownButton.Text = option
                            
                            if callback then
                                callback(option)
                            end
                            
                            -- Close dropdown
                            isOpen = false
                            DropdownList.Visible = false
                            DropdownArrow.Text = "▼"
                        end)
                    end
                    
                    -- Update list size
                    DropdownList.Size = UDim2.new(1, 0, 0, #options * 25)
                else
                    DropdownList.Visible = false
                    DropdownArrow.Text = "▼"
                end
            end)
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            return {
                Set = function(value)
                    selectedValue = value
                    DropdownButton.Text = value
                    if callback then
                        callback(value)
                    end
                end
            }
        end
        
        function Section:NewTextBox(textboxName, callback)
            local TextBoxFrame = Instance.new("Frame")
            TextBoxFrame.Name = "TextBoxFrame"
            TextBoxFrame.Parent = TabContent
            TextBoxFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            TextBoxFrame.BorderSizePixel = 0
            TextBoxFrame.Size = UDim2.new(1, 0, 0, 35)
            
            local TextBoxCorner = Instance.new("UICorner")
            TextBoxCorner.CornerRadius = UDim.new(0, 4)
            TextBoxCorner.Parent = TextBoxFrame
            
            local TextBoxLabel = Instance.new("TextLabel")
            TextBoxLabel.Name = "TextBoxLabel"
            TextBoxLabel.Parent = TextBoxFrame
            TextBoxLabel.BackgroundTransparency = 1
            TextBoxLabel.Size = UDim2.new(0, 100, 1, 0)
            TextBoxLabel.Position = UDim2.new(0, 10, 0, 0)
            TextBoxLabel.Text = textboxName
            TextBoxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBoxLabel.TextScaled = true
            TextBoxLabel.Font = Enum.Font.Gotham
            TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local TextBox = Instance.new("TextBox")
            TextBox.Name = "TextBox"
            TextBox.Parent = TextBoxFrame
            TextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            TextBox.BorderSizePixel = 0
            TextBox.Size = UDim2.new(1, -120, 0, 25)
            TextBox.Position = UDim2.new(0, 110, 0.5, -12.5)
            TextBox.Text = ""
            TextBox.PlaceholderText = "Enter text..."
            TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.TextScaled = true
            TextBox.Font = Enum.Font.Gotham
            
            local TextBoxCorner2 = Instance.new("UICorner")
            TextBoxCorner2.CornerRadius = UDim.new(0, 4)
            TextBoxCorner2.Parent = TextBox
            
            TextBox.FocusLost:Connect(function(enterPressed)
                if callback then
                    callback(TextBox.Text)
                end
            end)
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            return TextBox
        end
        
        -- Compatibility methods for OrionLib API
        function Section:AddButton(buttonName, callback)
            return self:NewButton(buttonName, callback)
        end
        
        function Section:AddToggle(toggleName, callback)
            return self:NewToggle(toggleName, callback)
        end
        
        function Section:AddSlider(sliderName, min, max, default, callback)
            return self:NewSlider(sliderName, min, max, default, callback)
        end
        
        function Section:AddDropdown(dropdownName, options, callback)
            return self:NewDropdown(dropdownName, options, callback)
        end
        
        function Section:AddTextBox(textboxName, callback)
            return self:NewTextBox(textboxName, callback)
        end
        
        return Section
    end
    
    -- Compatibility function for OrionLib API
    function Lib:MakeWindow(Config)
        return self
    end
    
    function Lib:MakeTab(tabName)
        return self:NewTab(tabName)
    end
    
    return Lib
end

-- Compatibility function for OrionLib API at library level
function Library.MakeWindow(Config)
    local WindowConfig = Config or {}
    return Library.CreateLib(WindowConfig.Name or "Kavo UI", WindowConfig.Theme or "Ocean")
end

-- Notification system
function Library.CreateNotification(title, text, duration)
    local NotifyGui = Instance.new("ScreenGui")
    NotifyGui.Name = "KavoNotification"
    NotifyGui.Parent = PlayerGui
    NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Name = "NotifyFrame"
    NotifyFrame.Parent = NotifyGui
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.Size = UDim2.new(0, 250, 0, 70)
    NotifyFrame.Position = UDim2.new(1, 0, 0, 50)
    
    local NotifyCorner = Instance.new("UICorner")
    NotifyCorner.CornerRadius = UDim.new(0, 6)
    NotifyCorner.Parent = NotifyFrame
    
    local NotifyStroke = Instance.new("UIStroke")
    NotifyStroke.Color = Color3.fromRGB(46, 204, 113)
    NotifyStroke.Thickness = 1
    NotifyStroke.Parent = NotifyFrame
    
    local NotifyTitle = Instance.new("TextLabel")
    NotifyTitle.Name = "NotifyTitle"
    NotifyTitle.Parent = NotifyFrame
    NotifyTitle.BackgroundTransparency = 1
    NotifyTitle.Size = UDim2.new(1, -20, 0, 25)
    NotifyTitle.Position = UDim2.new(0, 10, 0, 5)
    NotifyTitle.Text = title or "Notification"
    NotifyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifyTitle.TextScaled = true
    NotifyTitle.Font = Enum.Font.GothamBold
    NotifyTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local NotifyText = Instance.new("TextLabel")
    NotifyText.Name = "NotifyText"
    NotifyText.Parent = NotifyFrame
    NotifyText.BackgroundTransparency = 1
    NotifyText.Size = UDim2.new(1, -20, 0, 35)
    NotifyText.Position = UDim2.new(0, 10, 0, 30)
    NotifyText.Text = text or ""
    NotifyText.TextColor3 = Color3.fromRGB(200, 200, 200)
    NotifyText.TextScaled = true
    NotifyText.Font = Enum.Font.Gotham
    NotifyText.TextXAlignment = Enum.TextXAlignment.Left
    NotifyText.TextWrapped = true
    
    -- Slide in animation
    local slideIn = TweenService:Create(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -270, 0, 50)
    })
    slideIn:Play()
    
    -- Auto-close
    wait(duration or 3)
    
    -- Slide out animation
    local slideOut = TweenService:Create(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(1, 0, 0, 50)
    })
    slideOut:Play()
    
    slideOut.Completed:Connect(function()
        NotifyGui:Destroy()
    end)
end

return Library
