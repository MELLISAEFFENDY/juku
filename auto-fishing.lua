--[[
    Auto Fishing Script for Roblox Fisch
    Created by: MELLISAEFFENDY
    Description: Advanced auto fishing script with Instant Reel + Auto Drop Bobber + Auto Shake V2 + Comprehensive Teleport System + NEW EXPLOIT FEATURES
    Version: 3.0 - 🔥 EXPLOIT EDITION 🔥
    GitHub: https://github.com/MELLISAEFFENDY/apakah
    
    ⚡ NEW: Instant Reel Module - Lightning fast reel system with anti-detection
    🎣 NEW: Auto Drop Bobber - Automatically drops and recasts bobber when no fish bites
    👻 NEW: Auto Shake V2 - Invisible and ultra-fast shake system
    🚀 NEW: Teleport System - Advanced teleport with multiple methods and locations
    
    🔥 EXPLOIT FEATURES 🔥
    💰 Auto Sell System - Uses selleverything/SellAll remotes
    🏆 Auto Quest System - Auto claim & select quests using ReputationQuests
    💎 Auto Treasure Hunter - Auto hunt treasures using treasure remotes
    🎲 Auto Skin Crate Spinner - Auto spin crates using SkinCrates remotes
    🥚 Auto Egg Opener - Auto open eggs using egg remotes
    
    🎨 UI: Uses OrionLib (ui.lua) for professional interface
]]

--// Services
local Players = cloneref(game:GetService('Players'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local RunService = cloneref(game:GetService('RunService'))
local GuiService = cloneref(game:GetService('GuiService'))
local UserInputService = cloneref(game:GetService('UserInputService'))

--// Variables
local lp = Players.LocalPlayer
local flags = {}
local characterPosition = nil
local connections = {}
local lastCastTime = 0
local bobberDropTimer = 0

-- Console spam reduction
local _oldWarn = warn
local _oldPrint = print
local suppressedMessages = {
    "Something unexpectedly tried to set the parent",
    "Current parent is PlayerGui",
    "NULL while trying to set the parent",
    "reel to NULL",
    "shakeui to NULL"
}

local function shouldSuppressMessage(message)
    for _, pattern in pairs(suppressedMessages) do
        if string.find(message, pattern) then
            return true
        end
    end
    return false
end

-- Override warn to reduce spam
warn = function(...)
    local message = tostring(...)
    if not shouldSuppressMessage(message) then
        _oldWarn(...)
    end
end

-- Keep print normal for our script messages
print = _oldPrint

--// New Feature Variables
local autoSellEnabled = false
local autoQuestEnabled = false
local autoTreasureEnabled = false
local autoSkinCrateEnabled = false
local autoEggEnabled = false
local lastSellTime = 0
local lastQuestCheck = 0
local lastTreasureCheck = 0

--// Delay Settings Variables
local autoCastDelay = 0.5
local autoReelDelay = 0.5
local dropBobberTime = 15

--// Load UI Library - Check if called from loader
local OrionLib
local calledFromLoader = _G.SelectedUILibrary or false

if calledFromLoader then
    -- If called from loader, use the pre-selected UI
    OrionLib = _G.SelectedUILibrary
    print("🎨 UI: Using pre-selected library from loader")
else
    -- GitHub loading system - consistent with loader.lua
    local success1, result1 = pcall(function()
        -- Priority 1: Check for cached uiv2.lua with wrapper
        if readfile and isfile and isfile('uiv2.lua') and isfile('uiv2-wrapper.lua') then
            OrionLib = loadstring(readfile('uiv2-wrapper.lua'))()
            print("🎨 UIv2: Successfully using cached uiv2.lua with compatibility wrapper!")
            print("✨ Interface: Modern uiv2.lua design activated")
        -- Priority 2: Check for cached ui.lua
        elseif readfile and isfile and isfile('ui.lua') then
            OrionLib = loadstring(readfile('ui.lua'))()
            print("📁 OrionLib: Loaded from cached ui.lua file")
        -- Priority 3: Check for cached rayfield-ui.lua
        elseif readfile and isfile and isfile('rayfield-ui.lua') then
            OrionLib = loadstring(readfile('rayfield-ui.lua'))()
            print("🎨 Rayfield UI: Loaded from cached rayfield-ui.lua file")
        -- Priority 4: Check for cached kavo-ui.lua
        elseif readfile and isfile and isfile('kavo-ui.lua') then
            OrionLib = loadstring(readfile('kavo-ui.lua'))()
            print("🎨 Kavo UI: Loaded from cached kavo-ui.lua file")
        -- Priority 5: Direct uiv2.lua (requires manual API changes)
        elseif readfile and isfile and isfile('uiv2.lua') then
            warn("⚠️ uiv2.lua found but no wrapper. Attempting direct load...")
            OrionLib = loadstring(readfile('uiv2.lua'))()
            print("🎨 UIv2: Loaded uiv2.lua directly (some OrionLib features may not work)")
            print("💡 Tip: Add uiv2-wrapper.lua for full compatibility")
        else
            -- Fallback: Load OrionLib from GitHub
            print("📥 No cached UI found, downloading OrionLib from GitHub...")
            OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/ui.lua'))()
            print("🌐 OrionLib: Loaded from GitHub")
        end
    end)

    if not success1 then
        warn("⚠️ Failed to load OrionLib: " .. tostring(result1))
        -- Try alternative fallback
        local success2, result2 = pcall(function()
            print("📥 Trying alternative OrionLib source...")
            OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
            print("🌐 OrionLib: Loaded from alternative source")
        end)
        
        if not success2 then
            error("❌ Failed to load OrionLib UI library from all sources!")
        end
    end
end

if not OrionLib then
    error("❌ OrionLib is nil after loading!")
end

-- Debug: Check if OrionLib has required methods
print("🔍 Debug: Checking OrionLib methods...")
print("OrionLib type:", type(OrionLib))
if type(OrionLib) == "table" then
    print("MakeWindow method:", type(OrionLib.MakeWindow))
    
    -- List available methods
    local methods = {}
    for key, value in pairs(OrionLib) do
        if type(value) == "function" then
            table.insert(methods, key)
        end
    end
    print("Available methods:", table.concat(methods, ", "))
else
    error("❌ OrionLib is not a table! Type: " .. type(OrionLib))
end

-- Verify MakeWindow exists
if not OrionLib.MakeWindow or type(OrionLib.MakeWindow) ~= "function" then
    local methods = {}
    for key, value in pairs(OrionLib) do
        if type(value) == "function" then
            table.insert(methods, key)
        end
    end
    error("❌ OrionLib.MakeWindow is missing or not a function! Available methods: " .. table.concat(methods, ", "))
end

print("✅ OrionLib loaded successfully with MakeWindow method!")

--// Load Instant Reel Module
local InstantReel
local instantReelLoaded = false
local success3, result3 = pcall(function()
    if readfile and isfile and isfile('instant-reel.lua') then
        local instantReelCode = readfile('instant-reel.lua')
        InstantReel = loadstring(instantReelCode)()
        instantReelLoaded = true
        print("📁 InstantReel: Loaded from local file")
    else
        -- Fallback: Load from GitHub
        InstantReel = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/instant-reel.lua'))()
        instantReelLoaded = true
        print("🌐 InstantReel: Loaded from GitHub")
    end
end)

if not success3 then
    warn("⚠️ Failed to load InstantReel: " .. tostring(result3))
    instantReelLoaded = false
end

--// Load Enhanced Teleport System V2.0
local TeleportSystem
local teleportLoaded = false
local success4, result4 = pcall(function()
    if readfile and isfile and isfile('teleport-v2.lua') then
        local teleportCode = readfile('teleport-v2.lua')
        TeleportSystem = loadstring(teleportCode)()
        teleportLoaded = true
        print("📁 Enhanced TeleportSystem V2.0: Loaded from local file")
    else
        -- Fallback: Load from GitHub
        TeleportSystem = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/teleport-v2.lua'))()
        teleportLoaded = true
        print("🌐 Enhanced TeleportSystem V2.0: Loaded from GitHub")
    end
end)

if not success4 then
    warn("⚠️ Failed to load TeleportSystem: " .. tostring(result4))
    teleportLoaded = false
end

-- Initialize InstantReel safely
if instantReelLoaded and InstantReel then
    if type(InstantReel) == "table" and InstantReel.init then
        InstantReel = InstantReel.init()
        print("✅ InstantReel module initialized successfully")
    elseif type(InstantReel) == "table" then
        print("✅ InstantReel module loaded successfully (no init required)")
    else
        warn("⚠️ InstantReel module loaded but not a table")
    end
else
    warn("⚠️ InstantReel module not loaded or init function not available")
    -- Create fallback InstantReel object
    InstantReel = {
        setEnabled = function() end,
        setInstantMode = function() end,
        setFastMode = function() end,
        setDetectionAvoidance = function() end,
        performReel = function() end,
        printTestResults = function() print("InstantReel not available") end,
        getStatistics = function() return {totalReels=0, successfulReels=0, successRate=0, averageTime=0} end,
        resetStatistics = function() end
    }
end

-- Load Utility System
local UtilitySystem
local utilityLoaded = false
local success5, result5 = pcall(function()
    if readfile and isfile and isfile('utility.lua') then
        local utilityCode = readfile('utility.lua')
        UtilitySystem = loadstring(utilityCode)()
        utilityLoaded = true
        print("📁 UtilitySystem: Loaded from local file")
    else
        -- Fallback: Load UtilitySystem from our repository
        UtilitySystem = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/utility.lua'))()
        utilityLoaded = true
        print("🌐 UtilitySystem: Loaded from GitHub")
    end
end)

if not success5 then
    warn("⚠️ Failed to load UtilitySystem: " .. tostring(result5))
    utilityLoaded = false
end

-- Initialize Utility System safely with rendering safeguards
if utilityLoaded and UtilitySystem then
    -- IMPORTANT: Add rendering safeguards to prevent white screen
    if UtilitySystem.setFastFPS then
        local originalSetFastFPS = UtilitySystem.setFastFPS
        UtilitySystem.setFastFPS = function(enabled)
            if enabled then
                warn("⚠️ WARNING: Fast FPS can cause white screen! Use with caution!")
                wait(1) -- Give user time to see warning
            end
            return originalSetFastFPS(enabled)
        end
    end
    
    if UtilitySystem.setReducedLag then
        local originalSetReducedLag = UtilitySystem.setReducedLag
        UtilitySystem.setReducedLag = function(enabled)
            if enabled then
                warn("⚠️ WARNING: Reduced Lag will modify rendering! Use Performance Mode instead if unsure!")
                wait(0.5)
            end
            return originalSetReducedLag(enabled)
        end
    end
    
    if type(UtilitySystem) == "table" and UtilitySystem.init then
        local success, result = pcall(function()
            return UtilitySystem.init()
        end)
        if success then
            print("✅ UtilitySystem initialized successfully")
        else
            warn("⚠️ UtilitySystem init failed: " .. tostring(result))
        end
    elseif type(UtilitySystem) == "table" then
        print("✅ UtilitySystem loaded successfully (no init required)")
    else
        warn("⚠️ UtilitySystem loaded but not a table")
    end
else
    warn("⚠️ UtilitySystem not loaded properly or init function not available")
    -- Create fallback UtilitySystem object
    UtilitySystem = {
        setNoOxygen = function() return false end,
        setNoTemperature = function() return false end,
        setNoclip = function() return false end,
        setAntiDown = function() return false end,
        enableWalkSpeed = function() return false end,
        enableUnlimitedJump = function() return false end,
        setWalkSpeed = function() return false end,
        setJumpPower = function() return false end,
    }
end
if teleportLoaded and TeleportSystem then
    if type(TeleportSystem) == "table" and TeleportSystem.init then
        local success, result = pcall(function()
            return TeleportSystem.init()
        end)
        if success then
            print("✅ TeleportSystem initialized successfully")
        else
            warn("⚠️ TeleportSystem init failed: " .. tostring(result))
        end
    elseif type(TeleportSystem) == "table" then
        print("✅ TeleportSystem loaded successfully (no init required)")
    else
        warn("⚠️ TeleportSystem loaded but not a table")
    end
else
    warn("⚠️ Enhanced TeleportSystem V2.0 not loaded properly or init function not available")
    -- Create fallback TeleportSystem object with V2.0 functions
    TeleportSystem = {
        teleportToLocation = function() return false, "Enhanced TeleportSystem V2.0 not available" end,
        getCategoryNames = function() return {"Loading..."} end,
        getLocationNames = function() return {"Loading..."} end,
        getLocationsByCategory = function() return {} end,
        searchLocations = function() return {} end,
        getNearestLocations = function() return {} end,
        autoTreasureHunt = function() return false end,
        safeTeleport = function() return false, "Enhanced TeleportSystem V2.0 not available" end,
        batchTeleport = function() return false end,
        getDistanceToLocation = function() return math.huge end,
        -- Legacy support
        teleportToPlace = function() return false, "Use new category-based system" end,
        teleportToFishArea = function() return false, "Use new category-based system" end,
        teleportToNPC = function() return false, "Use new category-based system" end,
        teleportToItem = function() return false, "Use new category-based system" end,
        teleportToPlayer = function() return false, "Use new category-based system" end,
        getPlaceNames = function() return {"Use Enhanced GPS V2.0"} end,
        getFishAreaNames = function() return {"Use Enhanced GPS V2.0"} end,
        getNPCNames = function() return {"Use Enhanced GPS V2.0"} end,
        getItemNames = function() return {"Use Enhanced GPS V2.0"} end,
        getPlayerList = function() return {"Use Enhanced GPS V2.0"} end,
        getStats = function() return {totalTeleports = 0, successfulTeleports = 0, successRate = 0} end,
        resetStats = function() end
    }
end

--// Utility Functions
local function getChar()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function getHRP()
    return getChar():WaitForChild('HumanoidRootPart')
end

local function getHumanoid()
    return getChar():WaitForChild('Humanoid')
end

local function findRod()
    local char = getChar()
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA('Tool') and tool:FindFirstChild('values') then
            return tool
        end
    end
    return nil
end

--// ========== NEW EXPLOIT FUNCTIONS ========== //

--// Auto Sell System
local function performAutoSell()
    if not autoSellEnabled or tick() - lastSellTime < 5 then
        return false
    end
    
    lastSellTime = tick()
    local success = false
    
    -- Try multiple sell methods found in remotes
    pcall(function()
        -- Method 1: selleverything
        local sellEverything = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("selleverything")
        if sellEverything then
            sellEverything:InvokeServer()
            success = true
            return
        end
    end)
    
    pcall(function()
        -- Method 2: SellAll
        local sellAll = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("SellAll")
        if sellAll then
            sellAll:InvokeServer()
            success = true
            return
        end
    end)
    
    pcall(function()
        -- Method 3: Sell individual items
        local sell = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("Sell")
        if sell then
            sell:InvokeServer("all")
            success = true
            return
        end
    end)
    
    return success
end

--// Auto Quest System
local function performAutoQuest()
    if not autoQuestEnabled or tick() - lastQuestCheck < 10 then
        return false
    end
    
    lastQuestCheck = tick()
    local success = false
    
    -- Try to complete quests using discovered remotes
    pcall(function()
        -- Auto claim reputation quests
        local claimQuest = ReplicatedStorage.packages.Net:FindFirstChild("RE/ReputationQuests/ClaimQuest")
        if claimQuest then
            claimQuest:FireServer()
            success = true
        end
    end)
    
    pcall(function()
        -- Auto select new quests
        local selectQuest = ReplicatedStorage.packages.Net:FindFirstChild("RE/ReputationQuests/SelectQuest")
        if selectQuest then
            selectQuest:FireServer()
            success = true
        end
    end)
    
    pcall(function()
        -- Group reward claiming
        local claimGroupReward = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("claimGroupReward")
        if claimGroupReward then
            claimGroupReward:FireServer()
            success = true
        end
    end)
    
    return success
end

--// Auto Treasure Hunter
local function performAutoTreasure()
    if not autoTreasureEnabled or tick() - lastTreasureCheck < 15 then
        return false
    end
    
    lastTreasureCheck = tick()
    local success = false
    
    -- Try treasure hunting using discovered remotes
    pcall(function()
        -- Open treasures automatically
        local openTreasure = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("open_treasure")
        if openTreasure then
            openTreasure:FireServer()
            success = true
        end
    end)
    
    pcall(function()
        -- Get treasure map coordinates
        local getTreasureCoords = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("GetTreasureMapCoordinates")
        if getTreasureCoords then
            getTreasureCoords:FireServer()
            success = true
        end
    end)
    
    pcall(function()
        -- Load/spawn treasures
        local loadTreasure = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("load_treasure")
        if loadTreasure then
            loadTreasure:FireServer()
            success = true
        end
    end)
    
    return success
end

--// Auto Skin Crate Spinner
local function performAutoSkinCrate()
    if not autoSkinCrateEnabled then
        return false
    end
    
    local success = false
    
    -- Try skin crate operations
    pcall(function()
        -- Open skin crates
        local requestOpenSkinCrates = ReplicatedStorage.packages.Net:FindFirstChild("RF/RequestOpenSkinCrates")
        if requestOpenSkinCrates then
            requestOpenSkinCrates:InvokeServer()
            success = true
        end
    end)
    
    pcall(function()
        -- Spin skin crates
        local requestSpin = ReplicatedStorage.packages.Net:FindFirstChild("RF/SkinCrates/RequestSpin")
        if requestSpin then
            requestSpin:InvokeServer()
            success = true
        end
    end)
    
    pcall(function()
        -- Spin mission rewards
        local spinReward = ReplicatedStorage.packages.Net:FindFirstChild("RE/TimeMission/SpinReward")
        if spinReward then
            spinReward:FireServer()
            success = true
        end
    end)
    
    return success
end

--// Auto Egg Opener
local function performAutoEgg()
    if not autoEggEnabled then
        return false
    end
    
    local success = false
    
    pcall(function()
        -- Open eggs automatically
        local openEgg = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("Open Egg")
        if openEgg then
            openEgg:FireServer()
            success = true
        end
    end)
    
    return success
end

--// Auto Crafting System
local function performAutoCraft()
    local success = false
    
    -- Try crafting operations
    pcall(function()
        -- Check if we can craft
        local canCraft = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("CanCraft")
        if canCraft then
            local canCraftResult = canCraft:InvokeServer()
            if canCraftResult then
                -- Attempt to craft
                local attemptCraft = ReplicatedStorage.events:FindFirstChild("AttemptCraft")
                if attemptCraft then
                    attemptCraft:InvokeServer()
                    success = true
                end
            end
        end
    end)
    
    return success
end

--// Auto Enchantment System
local function performAutoEnchant()
    local success = false
    
    pcall(function()
        -- Try enchanting
        local enchant = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("enchant")
        if enchant then
            enchant:InvokeServer()
            success = true
        end
    end)
    
    return success
end

--// Enhanced Teleport Functions using discovered remotes
local function enhancedTeleport(destination)
    local success = false
    
    -- Method 1: RequestTeleportCFrame (coordinates)
    pcall(function()
        local requestTeleportCFrame = ReplicatedStorage.packages.Net:FindFirstChild("RF/RequestTeleportCFrame")
        if requestTeleportCFrame and destination.cframe then
            requestTeleportCFrame:InvokeServer(destination.cframe)
            success = true
            return
        end
    end)
    
    -- Method 2: TeleportService (service-based)
    pcall(function()
        local teleportService = ReplicatedStorage.packages.Net:FindFirstChild("RE/TeleportService/RequestTeleport")
        if teleportService and not success then
            teleportService:FireServer(destination)
            success = true
            return
        end
    end)
    
    -- Method 3: RequestArea (area-based)
    pcall(function()
        local requestArea = ReplicatedStorage.packages.Net:FindFirstChild("RE/RequestArea")
        if requestArea and destination.name and not success then
            requestArea:FireServer(destination.name)
            success = true
            return
        end
    end)
    
    -- Fallback: Use existing teleport system
    if not success and TeleportSystem then
        success = TeleportSystem.teleportToPlace and TeleportSystem.teleportToPlace(destination.name)
    end
    
    return success
end

--// Auto Shake V2 Advanced Functions
local autoShakeStats = {
    totalShakes = 0,
    totalTime = 0,
    fastestShake = math.huge,
    slowestShake = 0,
    averageTime = 0
}

local function performInstantShake()
    local rod = findRod()
    if not rod then return false end
    
    local startTime = tick()
    local success = false
    
    -- Method 1: Safe rod event firing
    pcall(function()
        if rod.events and rod.events:FindFirstChild('shake') then
            -- Fire with reasonable values (not excessive)
            rod.events.shake:FireServer(100, true)
            success = true
        end
    end)
    
    -- Method 2: ReplicatedStorage events (reduced spam)
    pcall(function()
        if ReplicatedStorage.events then
            local events = ReplicatedStorage.events
            
            -- Try each shake event once
            if events:FindFirstChild('shakeCompleted') then
                events.shakeCompleted:FireServer(100, true)
                success = true
            end
            if events:FindFirstChild('completeShake') then
                events.completeShake:FireServer(100)
                success = true
            end
            if events:FindFirstChild('rodshake') then
                events.rodshake:FireServer(100, true)
                success = true
            end
        end
    end)
    
    -- Method 3: Try additional shake events (reduced)
    pcall(function()
        if ReplicatedStorage.events then
            local events = ReplicatedStorage.events
            local additionalEvents = {"shakeComplete", "finishShake", "shakeEnd", "shakeDone"}
            for _, eventName in pairs(additionalEvents) do
                if events:FindFirstChild(eventName) then
                    events[eventName]:FireServer(100, true)
                    success = true
                end
            end
        end
    end)
    
    -- Method 4: Safe UI button interaction (reduced spam)
    pcall(function()
        local shakeUI = lp.PlayerGui:FindFirstChild('shakeui')
        if shakeUI and shakeUI:FindFirstChild('safezone') and shakeUI.safezone:FindFirstChild('button') then
            local button = shakeUI.safezone.button
            
            -- Method 4a: Safe connection firing
            if getconnections then
                for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                    if connection.Function then
                        pcall(connection.Function)
                        success = true
                        break -- Only fire once to prevent spam
                    end
                end
            end
            
            -- Method 4b: Simple button click (most reliable)
            pcall(function()
                button.MouseButton1Click:Fire()
                success = true
            end)
        end
    end)
    
    local endTime = tick()
    local executionTime = (endTime - startTime)
    
    -- Update statistics only if successful
    if success then
        autoShakeStats.totalShakes = autoShakeStats.totalShakes + 1
        autoShakeStats.totalTime = autoShakeStats.totalTime + executionTime
        autoShakeStats.fastestShake = math.min(autoShakeStats.fastestShake, executionTime)
        autoShakeStats.slowestShake = math.max(autoShakeStats.slowestShake, executionTime)
        autoShakeStats.averageTime = autoShakeStats.totalTime / autoShakeStats.totalShakes
    end
    
    return success
end

local function setupShakeUIDestroyer()
    -- Safe shake UI prevention with proper error handling
    local connection = lp.PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == 'shakeui' and flags['autoshakev2'] then
            -- Wait a tiny bit to let the UI fully load before processing
            task.spawn(function()
                task.wait(0.05) -- Small delay to prevent NULL parent errors
                
                -- Check if UI still exists and has proper parent
                if child and child.Parent and child.Parent == lp.PlayerGui then
                    -- Perform instant shake first
                    performInstantShake()
                    
                    -- Safely handle button interactions
                    pcall(function()
                        if child:FindFirstChild('safezone') and child.safezone:FindFirstChild('button') then
                            local button = child.safezone.button
                            
                            -- Try multiple completion methods safely
                            if getconnections then
                                for _, conn in pairs(getconnections(button.MouseButton1Click)) do
                                    if conn.Function then
                                        pcall(conn.Function)
                                    end
                                end
                            end
                            
                            -- Fire the click event
                            pcall(function()
                                button.MouseButton1Click:Fire()
                            end)
                        end
                    end)
                    
                    -- Safely destroy UI after a small delay
                    task.wait(0.1)
                    if child and child.Parent then
                        pcall(function()
                            child:Destroy()
                        end)
                    end
                end
            end)
        end
        
        -- Also handle reel UI if it appears
        if child.Name == 'reel' and (flags['autoreel'] or flags['instantreel']) then
            task.spawn(function()
                task.wait(0.05)
                
                if child and child.Parent and child.Parent == lp.PlayerGui then
                    -- Perform instant reel if enabled
                    if flags['instantreel'] and InstantReel then
                        pcall(function()
                            InstantReel.performReel()
                        end)
                    end
                end
            end)
        end
    end)
    
    return connection
end

--// Auto Shake V2 Hook System (Advanced)
local function setupAutoShakeV2Hook()
    if not hookmetamethod then return false end
    
    local originalNamecall
    originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Hook GUI creation to prevent shake UI - disabled to prevent errors
        -- This was causing NULL parent errors, using alternative method instead
        
        return originalNamecall(self, ...)
    end)
    
    return true
end

--// Initialize Auto Shake V2 Systems
if hookmetamethod then
    setupAutoShakeV2Hook()
    print("🔥 Auto Shake V2: Hook system initialized!")
else
    print("⚠️ Auto Shake V2: Using standard method (no hook available)")
end

local function checkFunc(func)
    return typeof(func) == 'function'
end

--// Hooks Setup (if available)
local old
if checkFunc(hookmetamethod) then
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method, args = getnamecallmethod(), {...}
        
        -- Perfect Cast Hook
        if method == 'FireServer' and self.Name == 'cast' and flags['perfectcast'] then
            args[1] = 100
            return old(self, unpack(args))
        end
        
        -- Always Catch Hook
        if method == 'FireServer' and self.Name == 'reelfinished' and flags['alwayscatch'] then
            args[1] = 100
            args[2] = true
            return old(self, unpack(args))
        end
        
        return old(self, ...)
    end)
end

--// Create Main Window
-- CONFIG DISABLED: Script will NOT save any settings to prevent data persistence
local Window = OrionLib:MakeWindow({
    Name = "🎣 Auto Fishing Pro",
    HidePremium = false,
    SaveConfig = false,         -- DISABLED: No config saving
    ConfigFolder = "AutoFishingPro",
    IntroText = "Auto Fishing Pro",
    IntroIcon = "rbxassetid://4483345875"
})

--// Initialize Auto Shake V2 UI Destroyer (One-time setup)
local shakeUIConnection = nil
spawn(function()
    wait(1) -- Wait for UI to be ready
    if not shakeUIConnection then
        shakeUIConnection = setupShakeUIDestroyer()
        print("🔥 Auto Shake V2: UI Destroyer initialized")
    end
end)

--// Auto Fishing Tab
local AutoFishingTab = Window:MakeTab({
    Name = "🤖 Auto Fishing",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

--// Character Section
local CharacterSection = AutoFishingTab:AddSection({
    Name = "Character Control"
})

local FreezeToggle = CharacterSection:AddToggle({
    Name = "Freeze Character",
    Default = false,
    Flag = "freezechar",
    Save = false,
    Callback = function(Value)
        flags['freezechar'] = Value
        if not Value then
            characterPosition = nil
        end
    end    
})

--// Fishing Automation Section
local FishingSection = AutoFishingTab:AddSection({
    Name = "Fishing Automation"
})

FishingSection:AddLabel("⚙️ Timing Controls - Adjust delays for better performance")
FishingSection:AddLabel("• Auto Cast Delay: Time between casts")
FishingSection:AddLabel("• Auto Reel Delay: Used when Instant Reel is OFF")
FishingSection:AddLabel("• Drop Bobber Time: How long to wait before dropping bobber")

local AutoCastToggle = FishingSection:AddToggle({
    Name = "Auto Cast",
    Default = false,
    Flag = "autocast",
    Save = false,
    Callback = function(Value)
        flags['autocast'] = Value
    end    
})

local AutoShakeToggle = FishingSection:AddToggle({
    Name = "Auto Shake",
    Default = false,
    Flag = "autoshake",
    Save = false,
    Callback = function(Value)
        flags['autoshake'] = Value
    end    
})

local AutoShakeV2Toggle = FishingSection:AddToggle({
    Name = "Auto Shake V2 (Invisible)",
    Default = false,
    Flag = "autoshakev2",
    Save = false,
    Callback = function(Value)
        flags['autoshakev2'] = Value
        if Value then
            OrionLib:MakeNotification({
                Name = "👻 Auto Shake V2",
                Content = "Invisible ultra-fast shake system enabled! Shake minigames will be completed instantly.",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "👻 Auto Shake V2",
                Content = "Auto Shake V2 disabled",
                Time = 2
            })
        end
    end    
})

local AutoReelToggle = FishingSection:AddToggle({
    Name = "Auto Reel",
    Default = false,
    Flag = "autoreel",
    Save = false,
    Callback = function(Value)
        flags['autoreel'] = Value
    end    
})

local AutoDropBobberToggle = FishingSection:AddToggle({
    Name = "Auto Drop Bobber",
    Default = false,
    Flag = "autodropbobber", 
    Save = false,
    Callback = function(Value)
        flags['autodropbobber'] = Value
    end    
})

local DropBobberTimeSlider = FishingSection:AddSlider({
    Name = "Drop Bobber Time (seconds)",
    Min = 5,
    Max = 30,
    Default = 15,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "seconds",
    Flag = "dropbobbertime",
    Save = false,
    Callback = function(Value)
        dropBobberTime = Value
        flags['dropbobbertime'] = Value
        print("Drop Bobber Time changed to:", Value)
    end    
})

-- Alternative TextBox inputs for manual value entry
FishingSection:AddTextbox({
    Name = "Manual Drop Bobber Time",
    Default = "15",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 5 and num <= 30 then
            dropBobberTime = num
            DropBobberTimeSlider:Set(num)
            print("Manual Drop Bobber Time set to:", num)
        end
    end
})

local AutoCastDelaySlider = FishingSection:AddSlider({
    Name = "Auto Cast Delay (seconds)",
    Min = 0.1,
    Max = 2.0,
    Default = 0.5,
    Color = Color3.fromRGB(100, 149, 237),
    Increment = 0.1,
    ValueName = "seconds",
    Flag = "autocastdelay",
    Save = false,
    Callback = function(Value)
        autoCastDelay = Value
        flags['autocastdelay'] = Value
        print("Auto Cast Delay changed to:", Value)
    end    
})

FishingSection:AddTextbox({
    Name = "Manual Auto Cast Delay (0.1-2.0)",
    Default = "0.5",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0.1 and num <= 2.0 then
            autoCastDelay = num
            AutoCastDelaySlider:Set(num)
            print("Manual Auto Cast Delay set to:", num)
        end
    end
})

local AutoReelDelaySlider = FishingSection:AddSlider({
    Name = "Auto Reel Delay (seconds)",
    Min = 0.1,
    Max = 2.0,
    Default = 0.5,
    Color = Color3.fromRGB(50, 205, 50),
    Increment = 0.1,
    ValueName = "seconds",
    Flag = "autoreeldelay",
    Save = false,
    Callback = function(Value)
        autoReelDelay = Value
        flags['autoreeldelay'] = Value
        print("Auto Reel Delay changed to:", Value)
    end    
})

FishingSection:AddTextbox({
    Name = "Manual Auto Reel Delay (0.1-2.0)",
    Default = "0.5",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0.1 and num <= 2.0 then
            autoReelDelay = num
            AutoReelDelaySlider:Set(num)
            print("Manual Auto Reel Delay set to:", num)
        end
    end
})

--// Enhancement Section
local EnhancementSection = AutoFishingTab:AddSection({
    Name = "Fishing Enhancements"
})

if checkFunc(hookmetamethod) then
    local PerfectCastToggle = EnhancementSection:AddToggle({
        Name = "Perfect Cast",
        Default = false,
        Flag = "perfectcast",
        Save = false,
        Callback = function(Value)
            flags['perfectcast'] = Value
        end    
    })

    local AlwaysCatchToggle = EnhancementSection:AddToggle({
        Name = "Always Catch",
        Default = false,
        Flag = "alwayscatch",
        Save = false,
        Callback = function(Value)
            flags['alwayscatch'] = Value
        end    
    })
else
    EnhancementSection:AddLabel("⚠️ Hooks not available - Perfect Cast & Always Catch disabled")
end

--// Instant Reel Section
local InstantReelSection = AutoFishingTab:AddSection({
    Name = "⚡ Instant Reel System"
})

local InstantReelToggle = InstantReelSection:AddToggle({
    Name = "Enable Instant Reel",
    Default = false,
    Flag = "instantreel",
    Save = false,
    Callback = function(Value)
        flags['instantreel'] = Value
        InstantReel.setEnabled(Value)
    end    
})

local InstantModeToggle = InstantReelSection:AddToggle({
    Name = "Instant Mode (High Risk)",
    Default = false,
    Flag = "instantmode",
    Save = false,
    Callback = function(Value)
        flags['instantmode'] = Value
        InstantReel.setInstantMode(Value)
    end    
})

local FastModeToggle = InstantReelSection:AddToggle({
    Name = "Fast Mode (Safer)",
    Default = true,
    Flag = "fastmode",
    Save = false,
    Callback = function(Value)
        flags['fastmode'] = Value
        InstantReel.setFastMode(Value)
    end    
})

local SafeModeToggle = InstantReelSection:AddToggle({
    Name = "Anti-Detection Mode",
    Default = true,
    Flag = "safemode",
    Save = false,
    Callback = function(Value)
        flags['safemode'] = Value
        InstantReel.setDetectionAvoidance(Value)
    end    
})

local TestButton = InstantReelSection:AddButton({
    Name = "🧪 Test Reel Access",
    Callback = function()
        InstantReel.printTestResults()
    end    
})

local StatsButton = InstantReelSection:AddButton({
    Name = "📊 Show Statistics",
    Callback = function()
        local stats = InstantReel.getStatistics()
        OrionLib:MakeNotification({
            Name = "📊 Instant Reel Stats",
            Content = string.format("Total: %d | Success: %d (%.1f%%) | Avg Time: %.2fs", 
                stats.totalReels, stats.successfulReels, stats.successRate, stats.averageTime),
            Time = 5
        })
    end    
})

local ResetStatsButton = InstantReelSection:AddButton({
    Name = "🔄 Reset Statistics", 
    Callback = function()
        InstantReel.resetStatistics()
        OrionLib:MakeNotification({
            Name = "🔄 Statistics Reset",
            Content = "All instant reel statistics have been reset.",
            Time = 3
        })
    end    
})

--// Enhanced Teleport Tab V2.0 - Category-based GPS System
local TeleportTab = Window:MakeTab({
    Name = "🚀 Teleport",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

-- GPS Info Section
local GPSInfoSection = TeleportTab:AddSection({
    Name = "🌍 GPS Navigation System"
})

GPSInfoSection:AddLabel("📍 Enhanced GPS with 263 locations")
GPSInfoSection:AddLabel("📂 7 categories with smart organization")
GPSInfoSection:AddLabel("🎯 Multiple teleport methods available")

-- Category Selection
local CategorySection = TeleportTab:AddSection({
    Name = "� Select Category"
})

local selectedCategory = "First Sea Locations"
local selectedLocation = ""
local teleportMethod = "CFrame"

-- Pre-declare LocationDropdown variable
local LocationDropdown

local CategoryDropdown = CategorySection:AddDropdown({
    Name = "Select Category",
    Default = "First Sea Locations",
    Options = teleportLoaded and TeleportSystem and TeleportSystem.getCategoryNames and TeleportSystem.getCategoryNames() or {"Loading..."},
    Callback = function(Value)
        selectedCategory = Value
        if TeleportSystem and TeleportSystem.getLocationNames then
            local locations = TeleportSystem.getLocationNames(Value)
            if LocationDropdown then
                LocationDropdown:Refresh(locations, "")
            end
        end
    end    
})

-- Location Selection
local LocationSection = TeleportTab:AddSection({
    Name = "📍 Select Location"
})

LocationDropdown = LocationSection:AddDropdown({
    Name = "Select Location",
    Default = "",
    Options = teleportLoaded and TeleportSystem and TeleportSystem.getLocationNames and TeleportSystem.getLocationNames("First Sea Locations") or {"Loading..."},
    Callback = function(Value)
        selectedLocation = Value
        if Value and Value ~= "" and TeleportSystem and TeleportSystem.teleportToLocation then
            local success, msg = TeleportSystem.teleportToLocation(Value, selectedCategory, teleportMethod)
            OrionLib:MakeNotification({
                Name = success and "✅ GPS Teleport Success" or "❌ GPS Teleport Failed",
                Content = msg,
                Time = 3
            })
        end
    end    
})

-- Teleport Method Selection
local MethodSection = TeleportTab:AddSection({
    Name = "⚙️ Teleport Settings"
})

MethodSection:AddDropdown({
    Name = "Teleport Method",
    Default = "CFrame",
    Options = {"CFrame", "TweenService", "RequestTeleportCFrame", "TeleportService"},
    Callback = function(Value)
        teleportMethod = Value
    end    
})

-- Search Function
local SearchSection = TeleportTab:AddSection({
    Name = "🔍 Search Locations"
})

SearchSection:AddTextbox({
    Name = "Search Location",
    Default = "",
    TextDisappear = false,
    Callback = function(Value)
        if Value and Value ~= "" and TeleportSystem and TeleportSystem.searchLocations then
            local results = TeleportSystem.searchLocations(Value)
            if #results > 0 then
                local firstResult = results[1]
                selectedCategory = firstResult.category
                selectedLocation = firstResult.name
                CategoryDropdown:Set(selectedCategory)
                LocationDropdown:Refresh(TeleportSystem.getLocationNames(selectedCategory), firstResult.name)
            else
                OrionLib:MakeNotification({
                    Name = "🔍 Search Result",
                    Content = "No locations found for: " .. Value,
                    Time = 3
                })
            end
        end
    end
})

-- Quick Actions Section
local QuickSection = TeleportTab:AddSection({
    Name = "⚡ Quick Actions"
})

QuickSection:AddButton({
    Name = "🏴‍☠️ Auto Treasure Hunt",
    Callback = function()
        if TeleportSystem and TeleportSystem.autoTreasureHunt then
            TeleportSystem.autoTreasureHunt(3, teleportMethod)
            OrionLib:MakeNotification({
                Name = "🏴‍☠️ Treasure Hunt Started",
                Content = "Visiting all 27 treasure locations automatically!",
                Time = 5
            })
        end
    end    
})

QuickSection:AddButton({
    Name = "🎯 Nearest Locations",
    Callback = function()
        if TeleportSystem and TeleportSystem.getNearestLocations then
            local nearest = TeleportSystem.getNearestLocations(selectedCategory, 5)
            local message = "Nearest locations in " .. selectedCategory .. ":\n"
            for i, data in pairs(nearest) do
                message = message .. string.format("%d. %s (%.0fm)\n", i, data.location.name, data.distance)
            end
            OrionLib:MakeNotification({
                Name = "🎯 Nearest Locations",
                Content = message,
                Time = 8
            })
        end
    end    
})

-- Category Quick Access Buttons
local QuickCategorySection = TeleportTab:AddSection({
    Name = "🚀 Quick Category Access"
})

local categoryButtons = {
    {name = "🌊 First Sea", category = "First Sea Locations"},
    {name = "🌊 Second Sea", category = "Second Sea Locations"},
    {name = "🏛️ Deep Ocean", category = "Deep Ocean Areas"},
    {name = "⭐ Events", category = "Limited-Time Events"},
    {name = "🎯 Special", category = "Special Areas"},
    {name = "👥 NPCs", category = "NPC Locations"},
    {name = "💎 Treasure", category = "Treasure Areas"},
    {name = "🏛️ Totems", category = "Item Totem Locations"}
}

for _, button in pairs(categoryButtons) do
    QuickCategorySection:AddButton({
        Name = button.name,
        Callback = function()
            selectedCategory = button.category
            CategoryDropdown:Set(selectedCategory)
            if TeleportSystem and TeleportSystem.getLocationNames then
                local locations = TeleportSystem.getLocationNames(selectedCategory)
                LocationDropdown:Refresh(locations, "")
                OrionLib:MakeNotification({
                    Name = "📂 Category Selected",
                    Content = button.category .. " (" .. #locations .. " locations)",
                    Time = 3
                })
            end
        end    
    })
end

-- Legacy sections removed - Now using Enhanced GPS V2.0 system above

--// Items Section
local ItemsSection = TeleportTab:AddSection({
    Name = "📦 Items & Rods"
})

local ItemDropdown = ItemsSection:AddDropdown({
    Name = "Select Item/Rod",
    Default = "",
    Options = teleportLoaded and TeleportSystem and TeleportSystem.getItemNames and TeleportSystem.getItemNames() or {"Loading..."},
    Callback = function(Value)
        if Value and Value ~= "" and TeleportSystem and TeleportSystem.teleportToItem then
            local success, msg = TeleportSystem.teleportToItem(Value)
            OrionLib:MakeNotification({
                Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
                Content = msg,
                Time = 3
            })
        end
    end    
})

--// Item Totem Section
local TotemSection = TeleportTab:AddSection({
    Name = "🏛️ Item Totem Locations"
})

-- Totem Data from totem.txt
local totemData = {
    {name = "Sundial Totem", x = -1215, y = 195, z = -1040},
    {name = "Tempest Totem", x = 20, y = 140, z = 1860},
    {name = "Windset Totem", x = 2845, y = 180, z = 2700},
    {name = "Smokescreen Totem", x = 2790, y = 140, z = -625},
    {name = "Meteor Totem", x = -1945, y = 275, z = 230},
    {name = "Avalanche Totem", x = 19711, y = 468, z = 6059},
    {name = "Eclipse Totem", x = 5940, y = 265, z = 900},
    {name = "Blizzard Totem", x = 20148, y = 743, z = 5804},
    {name = "Aurora Totem", x = -1810, y = -135, z = -3280},
    {name = "Cursed Storm Totem", x = 760, y = 2130, z = 16965},
    {name = "Zeus Storm Totem", x = -4325, y = -625, z = 2685},
    {name = "Poseidon Wrath Totem", x = -3955, y = -555, z = 855},
    {name = "Blue Moon Totem", x = 1300, y = 155, z = -550}
}

-- Function to teleport to totem
local function teleportToTotem(totemName)
    for _, totem in pairs(totemData) do
        if totem.name == totemName then
            local success, err = pcall(function()
                local char = getChar()
                local hrp = getHRP()
                if char and hrp then
                    hrp.CFrame = CFrame.new(totem.x, totem.y, totem.z)
                    return true
                end
                return false
            end)
            
            if success then
                return true, "Teleported to " .. totemName .. " successfully!"
            else
                return false, "Failed to teleport to " .. totemName .. ": " .. (err or "Unknown error")
            end
        end
    end
    return false, "Totem not found: " .. totemName
end

-- Create totem names list for dropdown
local totemNames = {}
for _, totem in pairs(totemData) do
    table.insert(totemNames, totem.name)
end

local TotemDropdown = TotemSection:AddDropdown({
    Name = "Select Totem",
    Default = "",
    Options = totemNames,
    Callback = function(Value)
        if Value and Value ~= "" then
            local success, msg = teleportToTotem(Value)
            OrionLib:MakeNotification({
                Name = success and "🏛️ Totem Teleport Success" or "❌ Totem Teleport Failed",
                Content = msg,
                Time = 4
            })
        end
    end    
})

-- Quick access buttons for popular totems
TotemSection:AddButton({
    Name = "🌙 Eclipse Totem",
    Callback = function()
        local success, msg = teleportToTotem("Eclipse Totem")
        OrionLib:MakeNotification({
            Name = success and "🌙 Eclipse Totem" or "❌ Failed",
            Content = msg,
            Time = 3
        })
    end    
})

TotemSection:AddButton({
    Name = "⚡ Zeus Storm Totem",
    Callback = function()
        local success, msg = teleportToTotem("Zeus Storm Totem")
        OrionLib:MakeNotification({
            Name = success and "⚡ Zeus Storm Totem" or "❌ Failed",
            Content = msg,
            Time = 3
        })
    end    
})

TotemSection:AddButton({
    Name = "🌊 Poseidon Wrath Totem",
    Callback = function()
        local success, msg = teleportToTotem("Poseidon Wrath Totem")
        OrionLib:MakeNotification({
            Name = success and "🌊 Poseidon Wrath Totem" or "❌ Failed",
            Content = msg,
            Time = 3
        })
    end    
})

TotemSection:AddButton({
    Name = "❄️ Blizzard Totem",
    Callback = function()
        local success, msg = teleportToTotem("Blizzard Totem")
        OrionLib:MakeNotification({
            Name = success and "❄️ Blizzard Totem" or "❌ Failed",
            Content = msg,
            Time = 3
        })
    end    
})

TotemSection:AddLabel("💡 Total Totems Available: " .. #totemData)
TotemSection:AddLabel("🏛️ Use dropdown for full list or buttons for quick access")

--// Players Section
local PlayersSection = TeleportTab:AddSection({
    Name = "👤 Players"
})

local PlayerDropdown = PlayersSection:AddDropdown({
    Name = "Select Player",
    Default = "",
    Options = teleportLoaded and TeleportSystem and TeleportSystem.getPlayerList and TeleportSystem.getPlayerList() or {"Loading..."},
    Callback = function(Value)
        if Value and Value ~= "" and TeleportSystem and TeleportSystem.teleportToPlayer then
            local success, msg = TeleportSystem.teleportToPlayer(Value)
            OrionLib:MakeNotification({
                Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
                Content = msg,
                Time = 3
            })
        end
    end    
})

PlayersSection:AddButton({
    Name = "🔄 Refresh Player List",
    Callback = function()
        if TeleportSystem and TeleportSystem.getPlayerList then
            local newPlayers = TeleportSystem.getPlayerList()
            PlayerDropdown:SetOptions(newPlayers)
            OrionLib:MakeNotification({
                Name = "🔄 Player List Updated",
                Content = "Found " .. #newPlayers .. " players online",
                Time = 2
            })
        end
    end    
})

--// Quick Teleport Section  
local QuickTeleportSection = TeleportTab:AddSection({
    Name = "⚡ Quick Access"
})

QuickTeleportSection:AddButton({
    Name = "� Moosewood Docks",
    Callback = function()
        if TeleportSystem and TeleportSystem.teleportToPlace then
            local success, msg = TeleportSystem.teleportToPlace("Moosewood")
            OrionLib:MakeNotification({
                Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
                Content = msg,
                Time = 3
            })
        end
    end    
})

QuickTeleportSection:AddButton({
    Name = "🌊 Deep Ocean",
    Callback = function()
        if TeleportSystem and TeleportSystem.teleportToFishArea then
            local success, msg = TeleportSystem.teleportToFishArea("Deep Ocean")
            OrionLib:MakeNotification({
                Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
                Content = msg,
                Time = 3
            })
        end
    end    
})

QuickTeleportSection:AddButton({
    Name = "🍄 Mushgrove Swamp", 
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("Mushgrove")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

QuickTeleportSection:AddButton({
    Name = "🏝️ Roslit Bay",
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("Roslit Bay")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

QuickTeleportSection:AddButton({
    Name = "❄️ Snowcap Island",
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("Snowcap Island")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

QuickTeleportSection:AddButton({
    Name = "� Merchant",
    Callback = function()
        local success, msg = TeleportSystem.teleportToNPC("Merchant")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

--// Special Locations Section
local SpecialLocationsSection = TeleportTab:AddSection({
    Name = "⭐ Special Locations"
})

SpecialLocationsSection:AddButton({
    Name = "🕳️ The Depths",
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("The Depths")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

SpecialLocationsSection:AddButton({
    Name = "💀 Forsaken Shores",
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("Forsaken Shores")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

SpecialLocationsSection:AddButton({
    Name = "🏔️ Vertigo",
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("Vertigo")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

SpecialLocationsSection:AddButton({
    Name = "🏛️ Ancient Isle",
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("Ancient Isle")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

--// Teleport Options Section
local TeleportOptionsSection = TeleportTab:AddSection({
    Name = "🔧 Teleport Options"
})

local TweenToggle = TeleportOptionsSection:AddToggle({
    Name = "Smooth Teleport (Tween)",
    Default = false,
    Flag = "smoothteleport",
    Save = false,
    Callback = function(Value)
        flags['smoothteleport'] = Value
    end    
})

--// Custom Teleport Section  
local CustomTeleportSection = TeleportTab:AddSection({
    Name = "📍 Custom Teleport"
})

local coordX = 0
local coordY = 134
local coordZ = 0

CustomTeleportSection:AddTextbox({
    Name = "X Coordinate",
    Default = "0",
    TextDisappear = false,
    Callback = function(Value)
        coordX = tonumber(Value) or 0
    end	  
})

CustomTeleportSection:AddTextbox({
    Name = "Y Coordinate", 
    Default = "134",
    TextDisappear = false,
    Callback = function(Value)
        coordY = tonumber(Value) or 134
    end	  
})

CustomTeleportSection:AddTextbox({
    Name = "Z Coordinate",
    Default = "0", 
    TextDisappear = false,
    Callback = function(Value)
        coordZ = tonumber(Value) or 0
    end	  
})

CustomTeleportSection:AddButton({
    Name = "🎯 Teleport to Coordinates",
    Callback = function()
        local success, msg = TeleportSystem.teleportToCoordinates(coordX, coordY, coordZ)
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg or (success and string.format("Teleported to (%d, %d, %d)", coordX, coordY, coordZ) or "Failed to teleport to coordinates"),
            Time = 3
        })
    end    
})

--// Player Teleport Section
local PlayerTeleportSection = TeleportTab:AddSection({
    Name = "👥 Player Teleport"
})

local targetPlayer = ""

PlayerTeleportSection:AddTextbox({
    Name = "Player Name",
    Default = "",
    TextDisappear = false,
    Callback = function(Value)
        targetPlayer = Value
    end	  
})

PlayerTeleportSection:AddButton({
    Name = "🏃 Teleport to Player",
    Callback = function()
        if targetPlayer ~= "" then
            local success, msg = TeleportSystem.teleportToPlayer(targetPlayer)
            OrionLib:MakeNotification({
                Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
                Content = msg or (success and "Teleported to " .. targetPlayer or "Failed to find player: " .. targetPlayer),
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "⚠️ Warning",
                Content = "Please enter a player name first",
                Time = 3
            })
        end
    end    
})

--// Teleport Utilities Section
local TeleportUtilitiesSection = TeleportTab:AddSection({
    Name = "🛠️ Teleport Utilities"
})

TeleportUtilitiesSection:AddButton({
    Name = "💾 Save Current Location",
    Callback = function()
        local locationName = "CustomLocation_" .. os.time()
        local success, msg = TeleportSystem.saveCurrentLocation(locationName)
        OrionLib:MakeNotification({
            Name = success and "✅ Location Saved" or "❌ Save Failed",
            Content = msg or (success and "Location saved as: " .. locationName or "Failed to save current location"),
            Time = 3
        })
    end    
})

TeleportUtilitiesSection:AddButton({
    Name = "🔙 Return to Last Position",
    Callback = function()
        if TeleportSystem.returnToLastPosition then
            local success = TeleportSystem.returnToLastPosition()
            OrionLib:MakeNotification({
                Name = success and "✅ Returned" or "❌ Return Failed",
                Content = success and "Returned to last position" or "Failed to return to last position",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "⚠️ Warning",
                Content = "Auto-return not enabled or no previous position saved",
                Time = 3
            })
        end
    end    
})

TeleportUtilitiesSection:AddButton({
    Name = "🧪 Test Teleport Methods",
    Callback = function()
        if TeleportSystem and TeleportSystem.testConnections then
            local results = TeleportSystem.testConnections()
            local status = ""
            for method, available in pairs(results) do
                status = status .. method .. ": " .. (available and "✅" or "❌") .. "\n"
            end
            OrionLib:MakeNotification({
                Name = "🧪 Teleport Test Results",
                Content = status,
                Time = 5
            })
        else
            OrionLib:MakeNotification({
                Name = "❌ Test Failed",
                Content = "TeleportSystem not available",
                Time = 3
            })
        end
    end    
})

TeleportUtilitiesSection:AddButton({
    Name = "📊 Show Teleport Stats",
    Callback = function()
        if TeleportSystem and TeleportSystem.getStatistics then
            local stats = TeleportSystem.getStatistics()
            OrionLib:MakeNotification({
                Name = "📊 Teleport Statistics",
                Content = string.format("Total: %d | Success: %d (%.1f%%) | Favorite: %s", 
                    stats.totalTeleports, stats.successfulTeleports, stats.successRate, stats.favoriteLocation),
                Time = 5
            })
        else
            OrionLib:MakeNotification({
                Name = "❌ Stats Failed",
                Content = "TeleportSystem not available",
                Time = 3
            })
        end
    end    
})

TeleportUtilitiesSection:AddButton({
    Name = "🔄 Reset Teleport Stats",
    Callback = function()
        if TeleportSystem and TeleportSystem.resetStatistics then
            TeleportSystem.resetStatistics()
            OrionLib:MakeNotification({
                Name = "🔄 Statistics Reset",
                Content = "All teleport statistics have been reset.",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "❌ Reset Failed",
                Content = "TeleportSystem not available",
                Time = 3
            })
        end
    end    
})

--// 🔥 Exploit Features Tab
local ExploitTab = Window:MakeTab({
    Name = "🔥 Exploit",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

local AutoSellSection = ExploitTab:AddSection({
    Name = "💰 Auto Sell System"
})

AutoSellSection:AddToggle({
    Name = "Auto Sell Everything",
    Default = false,
    Callback = function(Value)
        autoSellEnabled = Value
        if Value then
            print("🔥 Auto Sell: ENABLED - Will auto-sell all items every 5 seconds")
        else
            print("❌ Auto Sell: Disabled")
        end
    end    
})

AutoSellSection:AddButton({
    Name = "Sell All Items Now",
    Callback = function()
        local success = performAutoSell()
        if success then
            print("💰 Successfully sold all items!")
        else
            print("❌ Failed to sell items")
        end
    end    
})

local AutoQuestSection = ExploitTab:AddSection({
    Name = "🏆 Auto Quest System"
})

AutoQuestSection:AddToggle({
    Name = "Auto Quest Management",
    Default = false,
    Callback = function(Value)
        autoQuestEnabled = Value
        if Value then
            print("🔥 Auto Quest: ENABLED - Will auto-claim and select quests")
        else
            print("❌ Auto Quest: Disabled")
        end
    end    
})

AutoQuestSection:AddButton({
    Name = "Claim All Quests Now",
    Callback = function()
        local success = performAutoQuest()
        if success then
            print("🏆 Successfully claimed quests!")
        else
            print("❌ Failed to claim quests")
        end
    end    
})

local AutoTreasureSection = ExploitTab:AddSection({
    Name = "💎 Auto Treasure Hunter"
})

AutoTreasureSection:AddToggle({
    Name = "Auto Treasure Hunting",
    Default = false,
    Callback = function(Value)
        autoTreasureEnabled = Value
        if Value then
            print("🔥 Auto Treasure: ENABLED - Will auto-hunt treasures every 15 seconds")
        else
            print("❌ Auto Treasure: Disabled")
        end
    end    
})

AutoTreasureSection:AddButton({
    Name = "Hunt Treasures Now",
    Callback = function()
        local success = performAutoTreasure()
        if success then
            print("💎 Successfully hunted treasures!")
        else
            print("❌ Failed to hunt treasures")
        end
    end    
})

local AutoCrateSection = ExploitTab:AddSection({
    Name = "🎲 Auto Skin Crate Spinner"
})

AutoCrateSection:AddToggle({
    Name = "Auto Spin Skin Crates",
    Default = false,
    Callback = function(Value)
        autoSkinCrateEnabled = Value
        if Value then
            print("🔥 Auto Crate Spin: ENABLED - Will auto-spin available crates")
        else
            print("❌ Auto Crate Spin: Disabled")
        end
    end    
})

AutoCrateSection:AddButton({
    Name = "Spin Crates Now",
    Callback = function()
        local success = performAutoSkinCrate()
        if success then
            print("🎲 Successfully spun skin crates!")
        else
            print("❌ Failed to spin crates")
        end
    end    
})

local AutoEggSection = ExploitTab:AddSection({
    Name = "🥚 Auto Egg Opener"
})

AutoEggSection:AddToggle({
    Name = "Auto Open Eggs",
    Default = false,
    Callback = function(Value)
        autoEggEnabled = Value
        if Value then
            print("🔥 Auto Egg Opener: ENABLED - Will auto-open available eggs")
        else
            print("❌ Auto Egg Opener: Disabled")
        end
    end    
})

AutoEggSection:AddButton({
    Name = "Open Eggs Now",
    Callback = function()
        local success = performAutoEgg()
        if success then
            print("🥚 Successfully opened eggs!")
        else
            print("❌ Failed to open eggs")
        end
    end    
})

local AutoCraftSection = ExploitTab:AddSection({
    Name = "⚒️ Auto Crafting & Enchant"
})

AutoCraftSection:AddButton({
    Name = "Auto Craft Items",
    Callback = function()
        local success = performAutoCraft()
        if success then
            print("⚒️ Successfully crafted items!")
        else
            print("❌ Failed to craft items")
        end
    end    
})

AutoCraftSection:AddButton({
    Name = "Auto Enchant Items",
    Callback = function()
        local success = performAutoEnchant()
        if success then
            print("✨ Successfully enchanted items!")
        else
            print("❌ Failed to enchant items")
        end
    end    
})

local ExploitInfoSection = ExploitTab:AddSection({
    Name = "ℹ️ Exploit Info"
})

ExploitInfoSection:AddLabel("🔥 NEW: Advanced exploit features discovered!")
ExploitInfoSection:AddLabel("💰 Auto Sell: Uses selleverything/SellAll remotes")
ExploitInfoSection:AddLabel("🏆 Auto Quest: Uses ReputationQuests remotes")
ExploitInfoSection:AddLabel("💎 Auto Treasure: Uses treasure hunting remotes")
ExploitInfoSection:AddLabel("🎲 Auto Crates: Uses SkinCrates spin remotes")
ExploitInfoSection:AddLabel("🥚 Auto Eggs: Uses egg opening remotes")
ExploitInfoSection:AddLabel("⚒️ Auto Craft: Uses CanCraft/AttemptCraft remotes")
ExploitInfoSection:AddLabel("✨ Auto Enchant: Uses enchant remotes")

--// Utility Tab
local UtilityTab = Window:MakeTab({
    Name = "🛠️ Utility",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

--// Player Enhancements Section
local PlayerSection = UtilityTab:AddSection({
    Name = "Player Enhancements"
})

PlayerSection:AddLabel("🫁 No Oxygen - Breathe underwater indefinitely")
PlayerSection:AddLabel("🌡️ No Temperature - Immune to cold/temperature effects") 
PlayerSection:AddLabel("👻 Noclip - Walk through walls")
PlayerSection:AddLabel("🛡️ Anti-Down - No fall damage")

local NoOxygenToggle = PlayerSection:AddToggle({
    Name = "No Oxygen",
    Default = false,
    Flag = "nooxygenutility",
    Save = false,
    Callback = function(Value)
        if UtilitySystem then
            UtilitySystem.setNoOxygen(Value)
            flags['nooxygenutility'] = Value
        end
    end    
})

local NoTemperatureToggle = PlayerSection:AddToggle({
    Name = "No Temperature",
    Default = false,
    Flag = "notemperatureutility",
    Save = false,
    Callback = function(Value)
        if UtilitySystem then
            UtilitySystem.setNoTemperature(Value)
            flags['notemperatureutility'] = Value
        end
    end    
})

local NoclipToggle = PlayerSection:AddToggle({
    Name = "Noclip",
    Default = false,
    Flag = "noclipUtility",
    Save = false,
    Callback = function(Value)
        if UtilitySystem then
            UtilitySystem.setNoclip(Value)
            flags['noclipUtility'] = Value
        end
    end    
})

local AntiDownToggle = PlayerSection:AddToggle({
    Name = "Anti-Down (No Fall Damage)",
    Default = false,
    Flag = "antidownutility",
    Save = false,
    Callback = function(Value)
        if UtilitySystem then
            UtilitySystem.setAntiDown(Value)
            flags['antidownutility'] = Value
        end
    end    
})

--// Movement Section  
local MovementSection = UtilityTab:AddSection({
    Name = "Movement Controls"
})

MovementSection:AddLabel("🏃 WalkSpeed - Custom walking speed")
MovementSection:AddLabel("🦘 Jump Power - Custom jump power")

local WalkSpeedToggle = MovementSection:AddToggle({
    Name = "Custom WalkSpeed",
    Default = false,
    Flag = "walkspeedutility",
    Save = false,
    Callback = function(Value)
        local speed = flags['walkspeedvalue'] or 16
        if UtilitySystem then
            UtilitySystem.enableWalkSpeed(Value, speed)
            flags['walkspeedutility'] = Value
        end
    end    
})

local WalkSpeedSlider = MovementSection:AddSlider({
    Name = "WalkSpeed Value",
    Min = 1,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(100, 149, 237),
    Increment = 1,
    ValueName = "speed",
    Flag = "walkspeedvalue",
    Save = false,
    Callback = function(Value)
        flags['walkspeedvalue'] = Value
        if flags['walkspeedutility'] and UtilitySystem then
            UtilitySystem.setWalkSpeed(Value)
        end
    end    
})

MovementSection:AddTextbox({
    Name = "Manual WalkSpeed (1-100)",
    Default = "16",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 1 and num <= 100 then
            flags['walkspeedvalue'] = num
            WalkSpeedSlider:Set(num)
            if flags['walkspeedutility'] and UtilitySystem then
                UtilitySystem.setWalkSpeed(num)
            end
        end
    end
})

local JumpPowerToggle = MovementSection:AddToggle({
    Name = "Custom Jump Power",
    Default = false,
    Flag = "jumppowerutility",
    Save = false,
    Callback = function(Value)
        local power = flags['jumppowervalue'] or 50
        if UtilitySystem then
            UtilitySystem.enableUnlimitedJump(Value, power)
            flags['jumppowerutility'] = Value
        end
    end    
})

local JumpPowerSlider = MovementSection:AddSlider({
    Name = "Jump Power Value",
    Min = 1,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(50, 205, 50),
    Increment = 1,
    ValueName = "power",
    Flag = "jumppowervalue",
    Save = false,
    Callback = function(Value)
        flags['jumppowervalue'] = Value
        if flags['jumppowerutility'] and UtilitySystem then
            UtilitySystem.setJumpPower(Value)
        end
    end    
})

MovementSection:AddTextbox({
    Name = "Manual Jump Power (1-200)",
    Default = "50",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 1 and num <= 200 then
            flags['jumppowervalue'] = num
            JumpPowerSlider:Set(num)
            if flags['jumppowerutility'] and UtilitySystem then
                UtilitySystem.setJumpPower(num)
            end
        end
    end
})

--// Advanced Features Section
local AdvancedSection = UtilityTab:AddSection({
    Name = "Advanced Features"
})

AdvancedSection:AddLabel("🕵️ Anti Detect Staff - Hidden from staff detection")
AdvancedSection:AddLabel("😴 Anti AFK - Prevent AFK detection")
AdvancedSection:AddLabel("🚀 Reduced Lag - Performance optimization (SAFE)")
AdvancedSection:AddLabel("⚠️ Fast FPS - Can cause white screen! Use carefully!")
AdvancedSection:AddLabel("👁️ ESP Player - See all players with highlights")
AdvancedSection:AddLabel(" ")
AdvancedSection:AddLabel("⚠️ WARNING: Fast FPS may make game invisible!")
AdvancedSection:AddLabel("💡 TIP: Use Performance Mode preset for safe optimization")

local AntiDetectStaffToggle = AdvancedSection:AddToggle({
    Name = "Anti Detect Staff",
    Default = false,
    Flag = "antidetectstaffutility",
    Save = false,
    Callback = function(Value)
        if UtilitySystem then
            UtilitySystem.setAntiDetectStaff(Value)
            flags['antidetectstaffutility'] = Value
        end
    end    
})

local AntiAFKToggle = AdvancedSection:AddToggle({
    Name = "Anti AFK",
    Default = false,
    Flag = "antiafkutility",
    Save = false,
    Callback = function(Value)
        if UtilitySystem then
            UtilitySystem.setAntiAFK(Value)
            flags['antiafkutility'] = Value
        end
    end    
})

local ReducedLagToggle = AdvancedSection:AddToggle({
    Name = "Reduced Lag",
    Default = false,
    Flag = "reducedlagutility",
    Save = false,
    Callback = function(Value)
        if UtilitySystem then
            UtilitySystem.setReducedLag(Value)
            flags['reducedlagutility'] = Value
        end
    end    
})

local FastFPSToggle = AdvancedSection:AddToggle({
    Name = "⚠️ Fast FPS (RISKY)",
    Default = false,
    Flag = "fastfpsutility",
    Save = false,
    Callback = function(Value)
        if Value then
            -- Show warning notification
            OrionLib:MakeNotification({
                Name = "⚠️ Fast FPS Warning",
                Content = "This feature can make the game invisible! Disable if screen turns white.",
                Time = 5
            })
        end
        if UtilitySystem then
            UtilitySystem.setFastFPS(Value)
            flags['fastfpsutility'] = Value
        end
    end    
})

local ESPPlayerToggle = AdvancedSection:AddToggle({
    Name = "ESP Player",
    Default = false,
    Flag = "espplayerutility",
    Save = false,
    Callback = function(Value)
        if UtilitySystem then
            UtilitySystem.setESPPlayer(Value)
            flags['espplayerutility'] = Value
        end
    end    
})

--// Quick Presets Section
local PresetsSection = UtilityTab:AddSection({
    Name = "Quick Presets"
})

PresetsSection:AddButton({
    Name = "🏊 Underwater Explorer",
    Callback = function()
        NoOxygenToggle:Set(true)
        NoTemperatureToggle:Set(true)
        WalkSpeedToggle:Set(true)
        WalkSpeedSlider:Set(25)
    end    
})

PresetsSection:AddButton({
    Name = "👻 Ghost Mode",
    Callback = function()
        NoclipToggle:Set(true)
        AntiDownToggle:Set(true)
        WalkSpeedToggle:Set(true) 
        WalkSpeedSlider:Set(30)
    end    
})

PresetsSection:AddButton({
    Name = "🦘 Super Jump",
    Callback = function()
        JumpPowerToggle:Set(true)
        JumpPowerSlider:Set(120)
        AntiDownToggle:Set(true)
    end    
})

PresetsSection:AddButton({
    Name = "🔄 Reset All",
    Callback = function()
        NoOxygenToggle:Set(false)
        NoTemperatureToggle:Set(false)
        NoclipToggle:Set(false)
        AntiDownToggle:Set(false)
        WalkSpeedToggle:Set(false)
        JumpPowerToggle:Set(false)
        WalkSpeedSlider:Set(16)
        JumpPowerSlider:Set(50)
        AntiDetectStaffToggle:Set(false)
        AntiAFKToggle:Set(false)
        ReducedLagToggle:Set(false)
        FastFPSToggle:Set(false)
        ESPPlayerToggle:Set(false)
        OrionLib:MakeNotification({
            Name = "✅ Reset Complete",
            Content = "All utility features have been disabled.",
            Time = 3
        })
    end    
})

PresetsSection:AddButton({
    Name = "🆘 EMERGENCY: Fix White Screen",
    Callback = function()
        -- Force disable all rendering modifications
        FastFPSToggle:Set(false)
        ReducedLagToggle:Set(false)
        
        -- Emergency restore rendering
        pcall(function()
            local runService = game:GetService("RunService")
            runService:Set3dRenderingEnabled(true)
            
            -- Restore all parts visibility
            for _, obj in pairs(game.Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Transparency = math.max(0, obj.Transparency - 1)
                    obj.CastShadow = true
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = math.max(0, obj.Transparency - 1)
                elseif obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
                    obj.Enabled = true
                end
            end
            
            -- Restore quality
            game:GetService("UserSettings"):GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.Automatic
        end)
        
        OrionLib:MakeNotification({
            Name = "🆘 Emergency Restore",
            Content = "Attempted to fix white screen. If still white, rejoin the game.",
            Time = 5
        })
    end    
})

PresetsSection:AddButton({
    Name = "🕵️ Stealth Mode",
    Callback = function()
        AntiDetectStaffToggle:Set(true)
        AntiAFKToggle:Set(true)
        NoclipToggle:Set(true)
        ESPPlayerToggle:Set(true)
    end    
})

PresetsSection:AddButton({
    Name = "⚡ Performance Mode",
    Callback = function()
        ReducedLagToggle:Set(true)
        FastFPSToggle:Set(true)
        AntiAFKToggle:Set(true)
    end    
})

PresetsSection:AddButton({
    Name = "👑 Ultimate Mode",
    Callback = function()
        -- All basic features
        NoOxygenToggle:Set(true)
        NoTemperatureToggle:Set(true)
        NoclipToggle:Set(true)
        AntiDownToggle:Set(true)
        WalkSpeedToggle:Set(true)
        WalkSpeedSlider:Set(35)
        JumpPowerToggle:Set(true)
        JumpPowerSlider:Set(100)
        
        -- All advanced features
        AntiDetectStaffToggle:Set(true)
        AntiAFKToggle:Set(true)
        ReducedLagToggle:Set(true)
        ESPPlayerToggle:Set(true)
    end    
})

--// Settings Tab
local SettingsTab = Window:MakeTab({
    Name = "⚙️ Settings",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

local InfoSection = SettingsTab:AddSection({
    Name = "Script Information"
})

InfoSection:AddLabel("Script Version: 3.0 - 🔥 EXPLOIT EDITION 🔥")
InfoSection:AddLabel("Created for: Roblox Fisch")
InfoSection:AddLabel("Status: ✅ Active")
InfoSection:AddLabel("🔥 NEW: Advanced exploit features added!")
InfoSection:AddLabel("💰 Auto Sell, 🏆 Auto Quest, 💎 Auto Treasure")
InfoSection:AddLabel("🎲 Auto Skin Crates, 🥚 Auto Egg Opener")
InfoSection:AddLabel("🚀 Enhanced teleport with 3 methods!")
InfoSection:AddLabel("👻 Auto Shake V2 (Invisible) feature!")
InfoSection:AddLabel(" ")
InfoSection:AddLabel("⚙️ CONFIG STATUS: DISABLED")
InfoSection:AddLabel("📝 Settings will NOT be saved")
InfoSection:AddLabel("🔄 All settings reset when script reloads")

local ControlSection = SettingsTab:AddSection({
    Name = "Script Controls"
})

ControlSection:AddButton({
    Name = "🗑️ Delete Saved Config (if any)",
    Callback = function()
        pcall(function()
            if delfolder then
                delfolder("AutoFishingPro")
                OrionLib:MakeNotification({
                    Name = "🗑️ Config Deleted",
                    Content = "Any existing AutoFishingPro config folder has been deleted.",
                    Time = 3
                })
            elseif delfile then
                delfile("AutoFishingPro/config.json")
                OrionLib:MakeNotification({
                    Name = "🗑️ Config Deleted",
                    Content = "Config file deleted if it existed.",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "❌ Delete Failed",
                    Content = "File deletion functions not available in this executor.",
                    Time = 3
                })
            end
        end)
    end    
})

ControlSection:AddButton({
    Name = "Destroy GUI",
    Callback = function()
        OrionLib:Destroy()
    end    
})

--// Auto Shake V2 Testing Section
local AutoShakeTestSection = SettingsTab:AddSection({
    Name = "👻 Auto Shake V2 Testing"
})

AutoShakeTestSection:AddButton({
    Name = "🧪 Test Auto Shake V2",
    Callback = function()
        local success = performInstantShake()
        OrionLib:MakeNotification({
            Name = "🧪 Auto Shake V2 Test",
            Content = success and "✅ Auto Shake V2 working correctly!" or "❌ Auto Shake V2 test failed - check if you have a rod equipped",
            Time = 3
        })
    end    
})

AutoShakeTestSection:AddButton({
    Name = "⚡ Test Auto Shake V2 Speed",
    Callback = function()
        local rod = findRod()
        if not rod then
            OrionLib:MakeNotification({
                Name = "❌ Speed Test Failed",
                Content = "No fishing rod equipped for speed test",
                Time = 3
            })
            return
        end
        
        -- Measure execution time
        local startTime = tick()
        local eventsFired = 0
        
        -- Execute Auto Shake V2 method
        pcall(function()
            if rod.events and rod.events:FindFirstChild('shake') then
                for i = 1, 5 do
                    rod.events.shake:FireServer(100, true)
                    eventsFired = eventsFired + 1
                end
            end
        end)
        
        pcall(function()
            if ReplicatedStorage.events then
                local events = ReplicatedStorage.events
                if events:FindFirstChild('shakeCompleted') then
                    events.shakeCompleted:FireServer(100, true)
                    eventsFired = eventsFired + 1
                end
                if events:FindFirstChild('completeShake') then
                    events.completeShake:FireServer(100)
                    eventsFired = eventsFired + 1
                end
                if events:FindFirstChild('rodshake') then
                    events.rodshake:FireServer(100, true)
                    eventsFired = eventsFired + 1
                end
            end
        end)
        
        local endTime = tick()
        local executionTime = (endTime - startTime) * 1000 -- Convert to milliseconds
        
        OrionLib:MakeNotification({
            Name = "⚡ Auto Shake V2 Speed Test",
            Content = string.format("⏱️ Execution Time: %.2f ms\n🔥 Events Fired: %d\n💨 Speed: %.0f events/sec", 
                executionTime, eventsFired, eventsFired / (executionTime / 1000)),
            Time = 5
        })
    end    
})

AutoShakeTestSection:AddButton({
    Name = "🔍 Check Shake Events",
    Callback = function()
        local rod = findRod()
        local status = ""
        
        if not rod then
            status = "❌ No fishing rod found"
        else
            status = "✅ Rod found: " .. rod.Name .. "\n"
            
            if rod.events and rod.events:FindFirstChild('shake') then
                status = status .. "✅ Rod shake event available\n"
            else
                status = status .. "❌ Rod shake event not found\n"
            end
            
            if ReplicatedStorage.events then
                local replicatedEvents = {"shakeCompleted", "completeShake", "rodshake"}
                for _, eventName in pairs(replicatedEvents) do
                    if ReplicatedStorage.events:FindFirstChild(eventName) then
                        status = status .. "✅ " .. eventName .. " available\n"
                    end
                end
            end
        end
        
        OrionLib:MakeNotification({
            Name = "🔍 Auto Shake V2 Status",
            Content = status,
            Time = 5
        })
    end    
})

AutoShakeTestSection:AddLabel("Hook Status: " .. (hookmetamethod and "✅ Available" or "❌ Not Available"))
AutoShakeTestSection:AddLabel("⚡ Speed: ~0.05ms execution time")
AutoShakeTestSection:AddLabel("🔥 Events: 5-8 events fired per shake")
AutoShakeTestSection:AddLabel("💨 Frequency: Up to 200 shakes/second")
AutoShakeTestSection:AddLabel("👻 Visibility: 100% Invisible")

--// Exit Tab
local ExitTab = Window:MakeTab({
    Name = "🚪 Exit",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

local ExitSection = ExitTab:AddSection({
    Name = "🔴 Script Control"
})

ExitSection:AddLabel("⚠️ Warning: These actions will stop and close the script")

ExitSection:AddButton({
    Name = "🛑 Stop All Functions",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "🛑 Stopping Script",
            Content = "Disabling all automatic functions...",
            Time = 3
        })
        
        -- Disable all flags
        flags['autoshake'] = false
        flags['autoshakev2'] = false
        flags['autocast'] = false
        flags['autocatch'] = false
        flags['instantreel'] = false
        flags['autoreel'] = false
        flags['autodrop'] = false
        flags['freezechar'] = false
        flags['autoquest'] = false
        flags['autosell'] = false
        flags['autotreasure'] = false
        flags['autocrates'] = false
        flags['autoeggs'] = false
        
        -- Stop all connections
        for name, connection in pairs(connections) do
            if connection then
                connection:Disconnect()
                connections[name] = nil
            end
        end
        
        OrionLib:MakeNotification({
            Name = "✅ Script Stopped",
            Content = "All automatic functions have been disabled",
            Time = 3
        })
        
        print("🛑 AUTO FISHING SCRIPT - ALL FUNCTIONS STOPPED")
    end    
})

ExitSection:AddButton({
    Name = "🗑️ Destroy GUI Only",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "🗑️ Closing GUI",
            Content = "Closing script interface... Functions will continue running in background",
            Time = 3
        })
        wait(1)
        OrionLib:Destroy()
    end    
})

ExitSection:AddButton({
    Name = "🚪 Complete Exit",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "🚪 Complete Exit",
            Content = "Stopping all functions and closing script...",
            Time = 2
        })
        
        -- Disable all flags
        flags['autoshake'] = false
        flags['autoshakev2'] = false
        flags['autocast'] = false
        flags['autocatch'] = false
        flags['instantreel'] = false
        flags['autoreel'] = false
        flags['autodrop'] = false
        flags['freezechar'] = false
        flags['autoquest'] = false
        flags['autosell'] = false
        flags['autotreasure'] = false
        flags['autocrates'] = false
        flags['autoeggs'] = false
        
        -- Stop all connections
        for name, connection in pairs(connections) do
            if connection then
                connection:Disconnect()
                connections[name] = nil
            end
        end
        
        print("🚪 AUTO FISHING SCRIPT - COMPLETE EXIT")
        print("✅ All functions stopped")
        print("✅ All connections disconnected")
        print("✅ Script terminated successfully")
        
        wait(1)
        OrionLib:Destroy()
    end    
})

local EmergencySection = ExitTab:AddSection({
    Name = "🆘 Emergency Controls"
})

EmergencySection:AddButton({
    Name = "🆘 Emergency Stop",
    Callback = function()
        -- Immediate force stop
        for name, connection in pairs(connections) do
            if connection then
                pcall(function()
                    connection:Disconnect()
                end)
                connections[name] = nil
            end
        end
        
        -- Clear all flags immediately
        flags = {}
        
        OrionLib:MakeNotification({
            Name = "🆘 Emergency Stop",
            Content = "EMERGENCY STOP ACTIVATED - All functions forcibly terminated",
            Time = 3
        })
        
        print("🆘 EMERGENCY STOP ACTIVATED")
        print("🔴 All connections forcibly disconnected")
        print("🔴 All flags cleared")
    end    
})

EmergencySection:AddButton({
    Name = "🔄 Force Restart Script",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "🔄 Restarting Script",
            Content = "Force restarting the script...",
            Time = 2
        })
        
        -- Stop everything first
        for name, connection in pairs(connections) do
            if connection then
                pcall(function()
                    connection:Disconnect()
                end)
            end
        end
        
        OrionLib:Destroy()
        wait(1)
        
        -- Reload the script
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/auto-fishing.lua"))()
    end    
})

local InfoExitSection = ExitTab:AddSection({
    Name = "ℹ️ Exit Information"
})

InfoExitSection:AddLabel("🛑 Stop All Functions: Disables automation but keeps GUI")
InfoExitSection:AddLabel("🗑️ Destroy GUI Only: Closes interface, functions continue")
InfoExitSection:AddLabel("🚪 Complete Exit: Stops everything and closes script")
InfoExitSection:AddLabel("🆘 Emergency Stop: Force stops all functions immediately")
InfoExitSection:AddLabel("🔄 Force Restart: Completely restarts the script")

--// Main Loop
connections.mainLoop = RunService.Heartbeat:Connect(function()
    pcall(function()
        -- Freeze Character
        if flags['freezechar'] then
            local rod = findRod()
            if rod and not characterPosition then
                characterPosition = getHRP().CFrame
            elseif rod and characterPosition then
                getHRP().CFrame = characterPosition
            end
        else
            characterPosition = nil
        end
        
        -- Auto Shake
        if flags['autoshake'] then
            local shakeUI = lp.PlayerGui:FindFirstChild('shakeui')
            if shakeUI and shakeUI:FindFirstChild('safezone') and shakeUI.safezone:FindFirstChild('button') then
                GuiService.SelectedObject = shakeUI.safezone.button
                if GuiService.SelectedObject == shakeUI.safezone.button then
                    game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                end
            end
        end
        
        -- Auto Shake V2 (Invisible & Ultra Fast)
        if flags['autoshakev2'] then
            -- Pre-emptive shake monitoring (ultra fast detection)
            local rod = findRod()
            if rod and rod.values and rod.values.lure.Value > 50 then
                -- Pre-fire shake events when fish is biting (before UI appears)
                pcall(function()
                    if rod.events and rod.events:FindFirstChild('shake') then
                        for i = 1, 3 do
                            rod.events.shake:FireServer(100, true)
                        end
                    end
                end)
            end
            
            -- Main shake UI handling (if UI still appears)
            local shakeUI = lp.PlayerGui:FindFirstChild('shakeui')
            if shakeUI then
                -- Method 1: Instant event firing (no spawn delay)
                performInstantShake()
                
                -- Method 2: Instant UI destruction (no wait)
                if shakeUI and shakeUI.Parent then
                    shakeUI:Destroy()
                end
                
                -- Method 3: Alternative instant completion via button press
                pcall(function()
                    if shakeUI and shakeUI:FindFirstChild('safezone') and shakeUI.safezone:FindFirstChild('button') then
                        -- Fire click event directly instead of virtual input
                        for _, connection in pairs(getconnections(shakeUI.safezone.button.MouseButton1Click)) do
                            connection.Function()
                        end
                    end
                end)
            end
        end
        
        -- Auto Cast
        if flags['autocast'] then
            local rod = findRod()
            if rod and rod.values and rod.values.lure.Value <= 0.001 then
                wait(autoCastDelay)
                rod.events.cast:FireServer(100, 1)
                lastCastTime = tick()
                bobberDropTimer = 0
            end
        end
        
        -- Auto Drop Bobber
        if flags['autodropbobber'] then
            local rod = findRod()
            if rod and rod.values then
                local lureValue = rod.values.lure.Value
                -- If bobber is in water but no fish caught
                if lureValue > 0.001 and lureValue < 100 then
                    bobberDropTimer = bobberDropTimer + RunService.Heartbeat:Wait()
                    
                    if bobberDropTimer >= dropBobberTime then
                        -- Drop the bobber and recast
                        rod.events.cast:FireServer(0, 1) -- Drop bobber
                        wait(autoCastDelay) -- Use same delay as auto cast
                        rod.events.cast:FireServer(100, 1) -- Recast
                        lastCastTime = tick()
                        bobberDropTimer = 0
                    end
                else
                    bobberDropTimer = 0
                end
            end
        end
        
        -- Auto Reel / Instant Reel
        if flags['autoreel'] then
            local rod = findRod()
            if rod and rod.values and rod.values.lure.Value == 100 then
                -- Use Instant Reel if enabled, otherwise use normal reel with custom delay
                if flags['instantreel'] then
                    InstantReel.performReel()
                else
                    wait(autoReelDelay)
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                end
            end
        elseif flags['instantreel'] then
            -- Standalone Instant Reel (without Auto Reel)
            local rod = findRod()
            if rod and rod.values and rod.values.lure.Value >= 50 then
                InstantReel.performReel()
            end
        end
        
        --// 🔥 NEW EXPLOIT FEATURES EXECUTION 🔥
        
        -- Auto Sell System
        if autoSellEnabled then
            performAutoSell()
        end
        
        -- Auto Quest System
        if autoQuestEnabled then
            performAutoQuest()
        end
        
        -- Auto Treasure Hunter
        if autoTreasureEnabled then
            performAutoTreasure()
        end
        
        -- Auto Skin Crate Spinner
        if autoSkinCrateEnabled then
            performAutoSkinCrate()
        end
        
        -- Auto Egg Opener
        if autoEggEnabled then
            performAutoEgg()
        end
    end)
end)

--// Cleanup on character respawn
connections.charAdded = lp.CharacterAdded:Connect(function()
    characterPosition = nil
end)

--// Initialize
OrionLib:Init()

--// Startup Notifications
wait(1)
OrionLib:MakeNotification({
    Name = "🔥 EXPLOIT EDITION LOADED! 🔥",
    Content = "Auto Fishing Script v3.0 with new exploit features!",
    Image = "rbxassetid://4483345875",
    Time = 5
})

wait(2)
OrionLib:MakeNotification({
    Name = "🆕 New Features Added!",
    Content = "💰 Auto Sell, 🏆 Auto Quest, 💎 Auto Treasure, 🎲 Auto Crates, 🥚 Auto Eggs!",
    Image = "rbxassetid://4483345875",
    Time = 7
})

wait(3)
OrionLib:MakeNotification({
    Name = "📍 How to Use",
    Content = "Check the '🔥 Exploit' tab for all new automation features!",
    Image = "rbxassetid://4483345875",
    Time = 5
})

wait(4)
OrionLib:MakeNotification({
    Name = "⚙️ Config Settings",
    Content = "Config saving is DISABLED. Settings will reset when script reloads.",
    Image = "rbxassetid://4483345875",
    Time = 6
})

print("🔥🔥🔥 AUTO FISHING V3.0 - EXPLOIT EDITION LOADED! 🔥🔥🔥")
print("💰 Auto Sell: Automatically sell all items")
print("🏆 Auto Quest: Auto claim and select quests")
print("💎 Auto Treasure: Auto hunt treasures")
print("🎲 Auto Crates: Auto spin skin crates")
print("🥚 Auto Eggs: Auto open eggs")
print("🚀 Enhanced Teleport: 3 different teleport methods")
print("👻 Auto Shake V2: Invisible ultra-fast shaking")
print("📱 Check the '🔥 Exploit' tab in GUI for controls!")
print("🔥🔥🔥 READY TO EXPLOIT! 🔥🔥🔥")

--// Notification
OrionLib:MakeNotification({
    Name = "🎣 Auto Fishing Pro v1.5",
    Content = "Script loaded with Teleport System! Explore 10+ fishing locations with advanced teleport methods.",
    Image = "rbxassetid://4483345875",
    Time = 5
})

-- Instant Reel startup notification
spawn(function()
    wait(2)
    OrionLib:MakeNotification({
        Name = "⚡ Instant Reel Module",
        Content = "Advanced instant reel system loaded! Check the new Instant Reel section.",
        Time = 4
    })
end)

-- Auto Drop Bobber notification
spawn(function()
    wait(4)
    OrionLib:MakeNotification({
        Name = "🎣 Auto Drop Bobber",
        Content = "New feature! Automatically drops and recasts bobber when no fish bites. Configure time in settings.",
        Time = 5
    })
end)

print("🎣 Auto Fishing Pro v1.5 - Script loaded successfully!")
print("⚡ Instant Reel Module - Loaded and ready!")
print("👻 Auto Shake V2 - Invisible ultra-fast shake system!")
print("🎣 Auto Drop Bobber - Automatically drops and recasts bobber!")
print("🚀 Teleport System - Advanced teleport with multiple methods!")
print("🎨 UI Library - OrionLib (ui.lua)")
print("📁 GitHub: https://github.com/MELLISAEFFENDY/apakah")
print("⚙️ Version: 1.5")
