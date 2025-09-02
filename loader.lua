--[[
    UI Loader System - Choose Your Interface
    Created by: MELLISAEFFENDY
    Description: Interactive UI selector with preview and auto-detection
    
    Features:
    ✨ Interactive UI selection menu
    🎨 Preview each UI style
    ⚡ Performance metrics display
    🔄 Auto-detection of available UIs
    💾 Remember user preference
    🚀 Fast loading system
]]

local Players = cloneref(game:GetService('Players'))
local TweenService = cloneref(game:GetService('TweenService'))
local UserInputService = cloneref(game:GetService('UserInputService'))

local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- UI Libraries Configuration
local UILibraries = {
    {
        name = "Rayfield UI",
        file = "rayfield-ui.lua",
        url = "https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/rayfield-ui.lua",
        description = "🏆 Fastest & Most Responsive",
        performance = 95,
        features = {"Ultra Fast", "60fps Smooth", "Minimal Memory"},
        color = Color3.fromRGB(0, 162, 255),
        recommended = true
    },
    {
        name = "UIv2 Library",
        file = "uiv2.lua",
        url = "https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/uiv2.lua",
        description = "🎨 Modern & Aesthetic Design",
        performance = 90,
        features = {"Modern Design", "Smooth Animations", "Lightweight"},
        color = Color3.fromRGB(138, 43, 226),
        recommended = false
    },
    {
        name = "OrionLib",
        file = "ui.lua",
        url = "https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/ui.lua",
        description = "🛡️ Stable & Compatible",
        performance = 80,
        features = {"Most Compatible", "Well Documented", "Stable"},
        color = Color3.fromRGB(255, 87, 51),
        recommended = false
    },
    {
        name = "Kavo UI",
        file = "kavo-ui.lua",
        url = "https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/kavo-ui.lua",
        description = "🎯 Simple & Clean",
        performance = 88,
        features = {"Minimalist", "Clean Design", "Good Performance"},
        color = Color3.fromRGB(46, 204, 113),
        recommended = false
    }
}

-- Check what UI files are available
local function checkAvailableUIs()
    local available = {}
    for _, ui in pairs(UILibraries) do
        -- All UIs will be downloaded from GitHub
        if readfile and isfile then
            -- Check for cached files
            local success, result = pcall(function()
                return isfile(ui.file)
            end)
            if success and result then
                ui.available = true
                ui.status = "✅ Cached & Ready"
                print("✅ Found cached file: " .. ui.file)
            else
                ui.available = "download"
                ui.status = "📥 Will Download from GitHub"
                print("📥 Will download from GitHub: " .. ui.file)
            end
        else
            ui.available = "download"
            ui.status = "📥 Will Download from GitHub"
            print("📥 No file functions - will download from GitHub: " .. ui.file)
        end
        table.insert(available, ui)
    end
    return available
end

-- Create UI Selector GUI
local function createUISelector()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UISelector"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Size = UDim2.new(0, 600, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Add stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 70, 90)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = mainFrame
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "🎨 Choose Your UI Interface"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Parent = mainFrame
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 50)
    subtitle.Text = "Select the UI library that best fits your needs"
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
    subtitle.TextScaled = true
    subtitle.Font = Enum.Font.Gotham
    
    -- Scroll Frame for UI options
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Parent = mainFrame
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Size = UDim2.new(1, -40, 1, -140)
    scrollFrame.Position = UDim2.new(0, 20, 0, 90)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = scrollFrame
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    
    return screenGui, scrollFrame
end

-- Create UI option card
local function createUICard(ui, parent, index, onSelect)
    local card = Instance.new("Frame")
    card.Name = "UICard" .. index
    card.Parent = parent
    card.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, 80)
    card.LayoutOrder = ui.recommended and 0 or index
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = ui.available == true and ui.color or Color3.fromRGB(60, 60, 70)
    cardStroke.Thickness = ui.recommended and 3 or 1
    cardStroke.Parent = card
    
    -- Performance Bar Background
    local perfBarBg = Instance.new("Frame")
    perfBarBg.Name = "PerfBarBg"
    perfBarBg.Parent = card
    perfBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    perfBarBg.BorderSizePixel = 0
    perfBarBg.Size = UDim2.new(0, 100, 0, 4)
    perfBarBg.Position = UDim2.new(1, -110, 0, 50)
    
    local perfBarBgCorner = Instance.new("UICorner")
    perfBarBgCorner.CornerRadius = UDim.new(0, 2)
    perfBarBgCorner.Parent = perfBarBg
    
    -- Performance Bar Fill
    local perfBar = Instance.new("Frame")
    perfBar.Name = "PerfBar"
    perfBar.Parent = perfBarBg
    perfBar.BackgroundColor3 = ui.color
    perfBar.BorderSizePixel = 0
    perfBar.Size = UDim2.new(ui.performance / 100, 0, 1, 0)
    
    local perfBarCorner = Instance.new("UICorner")
    perfBarCorner.CornerRadius = UDim.new(0, 2)
    perfBarCorner.Parent = perfBar
    
    -- UI Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Parent = card
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(0, 200, 0, 25)
    nameLabel.Position = UDim2.new(0, 15, 0, 8)
    nameLabel.Text = ui.name .. (ui.recommended and " 🏆" or "")
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "DescLabel"
    descLabel.Parent = card
    descLabel.BackgroundTransparency = 1
    descLabel.Size = UDim2.new(0, 300, 0, 20)
    descLabel.Position = UDim2.new(0, 15, 0, 30)
    descLabel.Text = ui.description
    descLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Parent = card
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(0, 150, 0, 15)
    statusLabel.Position = UDim2.new(0, 15, 0, 55)
    statusLabel.Text = ui.status
    statusLabel.TextColor3 = ui.available == true and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 200, 100)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Performance Text
    local perfLabel = Instance.new("TextLabel")
    perfLabel.Name = "PerfLabel"
    perfLabel.Parent = card
    perfLabel.BackgroundTransparency = 1
    perfLabel.Size = UDim2.new(0, 80, 0, 15)
    perfLabel.Position = UDim2.new(1, -90, 0, 30)
    perfLabel.Text = "Performance: " .. ui.performance .. "%"
    perfLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    perfLabel.TextScaled = true
    perfLabel.Font = Enum.Font.Gotham
    perfLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Select Button
    local selectBtn = Instance.new("TextButton")
    selectBtn.Name = "SelectBtn"
    selectBtn.Parent = card
    selectBtn.BackgroundColor3 = ui.color
    selectBtn.BorderSizePixel = 0
    selectBtn.Size = UDim2.new(0, 80, 0, 25)
    selectBtn.Position = UDim2.new(1, -90, 1, -35)
    selectBtn.Text = "SELECT"
    selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectBtn.TextScaled = true
    selectBtn.Font = Enum.Font.GothamBold
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = selectBtn
    
    -- Button animations and click handler
    local function animateButton(scale, transparency)
        local tween = TweenService:Create(selectBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 80 * scale, 0, 25 * scale),
            BackgroundTransparency = transparency
        })
        tween:Play()
    end
    
    selectBtn.MouseEnter:Connect(function()
        animateButton(1.05, 0)
    end)
    
    selectBtn.MouseLeave:Connect(function()
        animateButton(1, 0)
    end)
    
    selectBtn.MouseButton1Click:Connect(function()
        animateButton(0.95, 0.1)
        wait(0.1)
        onSelect(ui)
    end)
    
    -- Card hover effect
    card.MouseEnter:Connect(function()
        local tween = TweenService:Create(cardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Thickness = 2,
            Color = ui.color
        })
        tween:Play()
    end)
    
    card.MouseLeave:Connect(function()
        local tween = TweenService:Create(cardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Thickness = ui.recommended and 3 or 1,
            Color = ui.available == true and ui.color or Color3.fromRGB(60, 60, 70)
        })
        tween:Play()
    end)
    
    return card
end

-- Loading animation
local function showLoadingScreen(selectedUI)
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "LoadingScreen"
    loadingGui.Parent = playerGui
    loadingGui.ResetOnSpawn = false
    
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Parent = loadingGui
    loadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    loadingFrame.BorderSizePixel = 0
    loadingFrame.Size = UDim2.new(1, 0, 1, 0)
    
    local loadingText = Instance.new("TextLabel")
    loadingText.Parent = loadingFrame
    loadingText.BackgroundTransparency = 1
    loadingText.Size = UDim2.new(0, 400, 0, 50)
    loadingText.Position = UDim2.new(0.5, -200, 0.5, -25)
    loadingText.Text = "Loading " .. selectedUI.name .. "..."
    loadingText.TextColor3 = selectedUI.color
    loadingText.TextScaled = true
    loadingText.Font = Enum.Font.GothamBold
    
    -- Spinning circle animation
    local spinner = Instance.new("Frame")
    spinner.Parent = loadingFrame
    spinner.BackgroundTransparency = 1
    spinner.Size = UDim2.new(0, 60, 0, 60)
    spinner.Position = UDim2.new(0.5, -30, 0.5, -80)
    
    local circle = Instance.new("ImageLabel")
    circle.Parent = spinner
    circle.BackgroundTransparency = 1
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.Image = "rbxasset://textures/loading/robloxTilt.png"
    circle.ImageColor3 = selectedUI.color
    
    local spinTween = TweenService:Create(circle, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
        Rotation = 360
    })
    spinTween:Play()
    
    return loadingGui
end

-- Save user preference
local function saveUIPreference(uiName)
    if writefile then
        local success, err = pcall(function()
            writefile("ui-preference.txt", uiName)
        end)
        if success then
            print("✅ UI preference saved: " .. uiName)
        end
    end
end

-- Load user preference
local function loadUIPreference()
    if readfile and isfile and isfile("ui-preference.txt") then
        local success, result = pcall(function()
            return readfile("ui-preference.txt")
        end)
        if success then
            return result
        end
    end
    return nil
end

-- Load selected UI and launch auto-fishing script
local function loadSelectedUI(selectedUI)
    local loadingScreen = showLoadingScreen(selectedUI)
    
    -- First load the UI library
    local success, OrionLib = pcall(function()
        print("🌐 Loading UI from GitHub: " .. selectedUI.url)
        
        -- Check if we have a cached version first
        if selectedUI.file and readfile and isfile and isfile(selectedUI.file) then
            print("� Using cached file: " .. selectedUI.file)
            
            -- Special handling for uiv2.lua
            if selectedUI.file == "uiv2.lua" then
                print("🎨 Detected UIv2.lua - checking for wrapper...")
                
                -- Check if wrapper exists
                local wrapperSuccess, wrapperExists = pcall(function()
                    return isfile("uiv2-wrapper.lua")
                end)
                
                if wrapperSuccess and wrapperExists then
                    print("✅ UIv2 wrapper found - loading with compatibility layer")
                    return loadstring(readfile("uiv2-wrapper.lua"))()
                else
                    print("⚠️ UIv2 wrapper not found - loading direct uiv2.lua")
                    return loadstring(readfile(selectedUI.file))()
                end
            else
                return loadstring(readfile(selectedUI.file))()
            end
        else
            print("📥 Downloading fresh copy from GitHub...")
            local response = game:HttpGet(selectedUI.url)
            
            -- Cache the downloaded file
            if writefile then
                pcall(function()
                    writefile(selectedUI.file, response)
                    print("💾 Cached to: " .. selectedUI.file)
                end)
            end
            
            return loadstring(response)()
        end
    end)
    
    wait(1) -- Show loading animation
    loadingScreen:Destroy()
    
    if success then
        saveUIPreference(selectedUI.name)
        print("✅ Successfully loaded " .. selectedUI.name)
        
        -- Store selected UI in global variable for auto-fishing script
        _G.SelectedUILibrary = OrionLib
        _G.SelectedUIName = selectedUI.name
        
        -- Now load the auto-fishing script with the selected UI
        print("🎣 Loading Auto Fishing Script...")
        local scriptSuccess, scriptResult = pcall(function()
            if isfile("auto-fishing.lua") then
                return loadstring(readfile("auto-fishing.lua"))()
            else
                local scriptCode = game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/auto-fishing.lua")
                return loadstring(scriptCode)()
            end
        end)
        
        if scriptSuccess then
            print("🎣 Auto Fishing Pro loaded successfully with " .. selectedUI.name .. "!")
        else
            warn("❌ Failed to load auto-fishing script: " .. tostring(scriptResult))
        end
        
        return OrionLib
    else
        warn("❌ Failed to load " .. selectedUI.name)
        return nil
    end
end

-- Main UI Selection Function
local function selectUI()
    local availableUIs = checkAvailableUIs()
    local savedPreference = loadUIPreference()
    
    -- ALWAYS show UI selector (removed auto-load behavior)
    print("🎨 Showing UI Selection Menu...")
    
    -- Show UI selector
    local screenGui, scrollFrame = createUISelector()
    
    -- If there's a saved preference, highlight it
    if savedPreference then
        print("💾 Last used UI: " .. savedPreference)
        
        -- Add "Use Last UI" button at the top
        local useLastCard = Instance.new("Frame")
        useLastCard.Name = "UseLastCard"
        useLastCard.Parent = scrollFrame
        useLastCard.BackgroundColor3 = Color3.fromRGB(45, 85, 45)
        useLastCard.BorderSizePixel = 0
        useLastCard.Size = UDim2.new(1, 0, 0, 60)
        useLastCard.LayoutOrder = -1
        
        local useLastCorner = Instance.new("UICorner")
        useLastCorner.CornerRadius = UDim.new(0, 8)
        useLastCorner.Parent = useLastCard
        
        local useLastStroke = Instance.new("UIStroke")
        useLastStroke.Color = Color3.fromRGB(100, 255, 100)
        useLastStroke.Thickness = 2
        useLastStroke.Parent = useLastCard
        
        local useLastLabel = Instance.new("TextLabel")
        useLastLabel.Name = "UseLastLabel"
        useLastLabel.Parent = useLastCard
        useLastLabel.BackgroundTransparency = 1
        useLastLabel.Size = UDim2.new(1, -120, 1, 0)
        useLastLabel.Position = UDim2.new(0, 15, 0, 0)
        useLastLabel.Text = "⚡ Quick Load: " .. savedPreference
        useLastLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        useLastLabel.TextScaled = true
        useLastLabel.Font = Enum.Font.GothamBold
        useLastLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local useLastBtn = Instance.new("TextButton")
        useLastBtn.Name = "UseLastBtn"
        useLastBtn.Parent = useLastCard
        useLastBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        useLastBtn.BorderSizePixel = 0
        useLastBtn.Size = UDim2.new(0, 100, 0, 35)
        useLastBtn.Position = UDim2.new(1, -110, 0.5, -17.5)
        useLastBtn.Text = "QUICK LOAD"
        useLastBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        useLastBtn.TextScaled = true
        useLastBtn.Font = Enum.Font.GothamBold
        
        local useLastBtnCorner = Instance.new("UICorner")
        useLastBtnCorner.CornerRadius = UDim.new(0, 4)
        useLastBtnCorner.Parent = useLastBtn
        
        useLastBtn.MouseButton1Click:Connect(function()
            -- Find the saved UI and load it
            for _, ui in pairs(availableUIs) do
                if ui.name == savedPreference and ui.available == true then
                    screenGui:Destroy()
                    loadSelectedUI(ui)
                    return
                end
            end
            
            -- If saved UI not available, show error
            warn("❌ Saved UI '" .. savedPreference .. "' not available")
        end)
    end
    
    for i, ui in pairs(availableUIs) do
        createUICard(ui, scrollFrame, i, function(selectedUI)
            screenGui:Destroy()
            loadSelectedUI(selectedUI)
        end)
    end
    
    -- Update scroll frame size
    local totalHeight = #availableUIs * 90 + (savedPreference and 70 or 0)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

-- Start the UI selection process
selectUI()

-- Debug function - can be called to test file detection
_G.debugUIFiles = function()
    print("🔍 Debugging UI file detection...")
    
    local files = {"uiv2.lua", "ui.lua", "uiv2-wrapper.lua", "rayfield-ui.lua", "kavo-ui.lua"}
    
    for _, file in pairs(files) do
        if readfile and isfile then
            local success, exists = pcall(function()
                return isfile(file)
            end)
            
            if success then
                if exists then
                    print("✅ " .. file .. " - FOUND")
                    
                    -- Try to read file size
                    local sizeSuccess, content = pcall(function()
                        return readfile(file)
                    end)
                    
                    if sizeSuccess then
                        print("   📏 Size: " .. string.len(content) .. " characters")
                    end
                else
                    print("❌ " .. file .. " - NOT FOUND")
                end
            else
                print("⚠️ " .. file .. " - ERROR CHECKING")
            end
        else
            print("⚠️ No file functions available")
            break
        end
    end
    
    print("🔍 Debug complete!")
end

print("💡 To debug file detection, run: _G.debugUIFiles()")
