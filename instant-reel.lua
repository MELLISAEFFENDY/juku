--[[
    Instant Reel Module for Auto Fishing
    Created by: MELLISAEFFENDY
    Description: Advanced instant reel system with anti-detection features
    Version: 1.0
    GitHub: https://github.com/MELLISAEFFENDY/apakah
]]

local InstantReel = {}

--// Services
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

--// Variables
local lp = Players.LocalPlayer
local settings = {
    enabled = false,
    instantMode = false,
    fastMode = true,
    safeMode = true,
    randomDelay = true,
    minDelay = 0.1,
    maxDelay = 0.3,
    detectionAvoidance = true
}

local statistics = {
    totalReels = 0,
    successfulReels = 0,
    failedReels = 0,
    averageTime = 0
}

--// Utility Functions
local function getChar()
    return lp.Character or lp.CharacterAdded:Wait()
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

local function randomDelay()
    if settings.randomDelay then
        return math.random(settings.minDelay * 100, settings.maxDelay * 100) / 100
    end
    return settings.minDelay
end

-- Function to instantly remove minigame UI
local function removeMinigameUI()
    pcall(function()
        local reelUI = lp.PlayerGui:FindFirstChild('reel')
        if reelUI then
            reelUI:Destroy()
        end
        
        local shakeUI = lp.PlayerGui:FindFirstChild('shakeui')
        if shakeUI then
            shakeUI:Destroy()
        end
    end)
end

-- Function to prevent minigame UI from appearing
local function preventMinigameUI()
    spawn(function()
        local connection
        connection = lp.PlayerGui.ChildAdded:Connect(function(child)
            if child.Name == 'reel' or child.Name == 'shakeui' then
                child:Destroy()
            end
        end)
        
        wait(2) -- Monitor for 2 seconds
        connection:Disconnect()
    end)
end

local function logReel(success, time)
    statistics.totalReels = statistics.totalReels + 1
    if success then
        statistics.successfulReels = statistics.successfulReels + 1
    else
        statistics.failedReels = statistics.failedReels + 1
    end
    
    -- Calculate average time
    if statistics.totalReels > 0 then
        statistics.averageTime = (statistics.averageTime * (statistics.totalReels - 1) + time) / statistics.totalReels
    end
end

--// Detection Avoidance System
local lastReelTime = 0
local reelPattern = {}
local maxPatternSize = 10

local function isPatternSuspicious()
    if #reelPattern < 5 then return false end
    
    -- Check for too consistent timing
    local timeDiffs = {}
    for i = 2, #reelPattern do
        table.insert(timeDiffs, reelPattern[i] - reelPattern[i-1])
    end
    
    -- If all time differences are too similar, it's suspicious
    local avgDiff = 0
    for _, diff in pairs(timeDiffs) do
        avgDiff = avgDiff + diff
    end
    avgDiff = avgDiff / #timeDiffs
    
    local variance = 0
    for _, diff in pairs(timeDiffs) do
        variance = variance + (diff - avgDiff)^2
    end
    variance = variance / #timeDiffs
    
    -- Low variance indicates bot-like behavior
    return variance < 0.01
end

local function updateReelPattern()
    local currentTime = tick()
    table.insert(reelPattern, currentTime)
    
    -- Keep pattern size manageable
    if #reelPattern > maxPatternSize then
        table.remove(reelPattern, 1)
    end
    
    lastReelTime = currentTime
end

--// Core Instant Reel Functions

-- Method 1: Ultra Instant Reel (No Minigame)
function InstantReel.directInstantReel()
    local rod = findRod()
    if not rod or not rod.values then return false end
    
    local startTime = tick()
    
    -- Instantly complete when any lure value is detected
    if rod.values.lure.Value >= 1 then
        -- Prevent minigame UI from appearing
        preventMinigameUI()
        
        spawn(function()
            pcall(function()
                -- Remove any existing minigame UI
                removeMinigameUI()
                
                -- Immediately fire reelfinished to bypass minigame
                ReplicatedStorage.events.reelfinished:FireServer(100, true)
                wait(0.001)
                ReplicatedStorage.events.reelfinished:FireServer(100, true)
                wait(0.001)
                ReplicatedStorage.events.reelfinished:FireServer(100, true)
                
                -- Clean up any UI that might have appeared
                removeMinigameUI()
                
                updateReelPattern()
                logReel(true, tick() - startTime)
            end)
        end)
        return true
    end
    
    return false
end

-- Method 2: Fast Reel with minimal delay
function InstantReel.fastReel()
    local rod = findRod()
    if not rod or not rod.values then return false end
    
    local startTime = tick()
    
    spawn(function()
        if rod.values.lure.Value > 0 then
            wait(randomDelay())
            pcall(function()
                ReplicatedStorage.events.reelfinished:FireServer(100, true)
                updateReelPattern()
                logReel(true, tick() - startTime)
            end)
        end
    end)
    
    return true
end

-- Method 3: Safe Reel with sequence
function InstantReel.safeSequenceReel()
    local rod = findRod()
    if not rod or not rod.values then return false end
    
    local startTime = tick()
    
    spawn(function()
        if rod.values.lure.Value > 50 then
            -- Simulate more realistic sequence
            if rod.events:FindFirstChild('handlebobber') then
                rod.events.handlebobber:FireServer()
                wait(randomDelay())
            end
            
            if rod.events:FindFirstChild('catchfinish') then
                rod.events.catchfinish:FireServer()
                wait(randomDelay())
            end
            
            -- Final reel
            pcall(function()
                ReplicatedStorage.events.reelfinished:FireServer(100, true)
                updateReelPattern()
                logReel(true, tick() - startTime)
            end)
        end
    end)
    
    return true
end

-- Method 4: Hook-based instant reel
local originalHook
function InstantReel.setupHookReel()
    if not hookmetamethod then return false end
    
    originalHook = hookmetamethod(game, "__namecall", function(self, ...)
        local method, args = getnamecallmethod(), {...}
        
        if method == 'FireServer' and self.Name == 'reelfinished' and settings.enabled then
            if settings.instantMode then
                args[1] = 100  -- Max power
                args[2] = true -- Success
                updateReelPattern()
            end
        end
        
        return originalHook(self, ...)
    end)
    
    return true
end

--// Main Reel Function
function InstantReel.performReel()
    if not settings.enabled then return false end
    
    local rod = findRod()
    if not rod or not rod.values then return false end
    
    -- Ultra instant mode - completely bypass minigame
    if settings.instantMode then
        if rod.values.lure.Value >= 1 then
            -- Prevent any minigame UI from appearing
            preventMinigameUI()
            
            spawn(function()
                pcall(function()
                    -- Immediately remove any existing UI
                    removeMinigameUI()
                    
                    -- Fire multiple times to ensure success and bypass any UI
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                    wait(0.001)
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                    wait(0.001)
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                    
                    -- Final cleanup
                    removeMinigameUI()
                    
                    updateReelPattern()
                    statistics.totalReels = statistics.totalReels + 1
                    statistics.successfulReels = statistics.successfulReels + 1
                end)
            end)
            return true
        end
        return false
    end
    
    -- Check for suspicious patterns and adjust behavior
    if settings.detectionAvoidance and isPatternSuspicious() then
        -- Use safer method when pattern is suspicious
        return InstantReel.safeSequenceReel()
    end
    
    -- Choose reel method based on settings
    if settings.fastMode then
        return InstantReel.fastReel()
    else
        return InstantReel.directInstantReel()
    end
end

--// Configuration Functions
function InstantReel.setEnabled(enabled)
    settings.enabled = enabled
end

function InstantReel.setInstantMode(enabled)
    settings.instantMode = enabled
    settings.fastMode = not enabled
end

function InstantReel.setFastMode(enabled)
    settings.fastMode = enabled
    settings.instantMode = not enabled
end

function InstantReel.setSafeMode(enabled)
    settings.safeMode = enabled
end

function InstantReel.setRandomDelay(enabled, minDelay, maxDelay)
    settings.randomDelay = enabled
    if minDelay then settings.minDelay = minDelay end
    if maxDelay then settings.maxDelay = maxDelay end
end

function InstantReel.setDetectionAvoidance(enabled)
    settings.detectionAvoidance = enabled
end

--// Statistics Functions
function InstantReel.getStatistics()
    return {
        totalReels = statistics.totalReels,
        successfulReels = statistics.successfulReels,
        failedReels = statistics.failedReels,
        successRate = statistics.totalReels > 0 and (statistics.successfulReels / statistics.totalReels * 100) or 0,
        averageTime = statistics.averageTime
    }
end

function InstantReel.resetStatistics()
    statistics = {
        totalReels = 0,
        successfulReels = 0,
        failedReels = 0,
        averageTime = 0
    }
    reelPattern = {}
end

--// Testing Functions
function InstantReel.testReelAccess()
    local tests = {}
    
    -- Test ReplicatedStorage access
    tests.replicatedStorage = ReplicatedStorage ~= nil
    tests.eventsFolder = ReplicatedStorage:FindFirstChild("events") ~= nil
    tests.reelfinishedEvent = ReplicatedStorage:FindFirstChild("events") and 
                             ReplicatedStorage.events:FindFirstChild("reelfinished") ~= nil
    
    -- Test rod access
    local rod = findRod()
    tests.rodFound = rod ~= nil
    tests.rodValues = rod and rod:FindFirstChild("values") ~= nil
    tests.rodEvents = rod and rod:FindFirstChild("events") ~= nil
    
    -- Test hook capabilities
    tests.hookAvailable = hookmetamethod ~= nil
    
    return tests
end

function InstantReel.printTestResults()
    local tests = InstantReel.testReelAccess()
    print("🧪 Instant Reel Access Test Results:")
    for test, result in pairs(tests) do
        print(string.format("  %s %s", result and "✅" or "❌", test))
    end
end

--// Initialize
function InstantReel.init()
    InstantReel.setupHookReel()
    print("⚡ Instant Reel Module loaded successfully!")
    return InstantReel
end

return InstantReel
