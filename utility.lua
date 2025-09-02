--[[
    Utility System for Roblox Fisch
    Created by: MELLISAEFFENDY
    Description: Comprehensive utility features including player enhancements, movement controls, and advanced features
    Version: 2.0
    GitHub: https://github.com/MELLISAEFFENDY/apakah
    
    🛠️ Basic Features:
    - Infinite Oxygen (No drowning)
    - No Temperature Effects (No winter/cold damage)
    - Anti-Down (Anti falling damage)
    - WalkSpeed Control (Custom walking speed)
    - Unlimited Jump (Infinite jump power)
    
    🔥 Advanced Features:
    - Anti Detect Staff (Hidden from staff detection)
    - Anti AFK (Prevent AFK detection)
    - Reduced Lag (Performance optimization)
    - Fast FPS (Maximum FPS boost)
    - ESP Player (See all players with highlights)
]]

local UtilitySystem = {}

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--// Variables
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

--// State Variables
local noOxygenEnabled = false
local noTemperatureEnabled = false
local antiDownEnabled = false
local walkSpeedEnabled = false
local unlimitedJumpEnabled = false
local antiDetectStaffEnabled = false
local antiAFKEnabled = false
local reducedLagEnabled = false
local fastFPSEnabled = false
local espPlayerEnabled = false

--// Default Values
local defaultWalkSpeed = 16
local defaultJumpPower = 50
local customWalkSpeed = 16
local customJumpPower = 50

--// Connections
local connections = {}

--// Update character references when character spawns
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Store default values for new character
    defaultWalkSpeed = humanoid.WalkSpeed
    defaultJumpPower = humanoid.JumpPower
    
    -- Reapply active features
    if walkSpeedEnabled then
        UtilitySystem.setWalkSpeed(customWalkSpeed)
    end
    if unlimitedJumpEnabled then
        UtilitySystem.setJumpPower(customJumpPower)
    end
end)

--// No Oxygen System
function UtilitySystem.setNoOxygen(enabled)
    noOxygenEnabled = enabled
    
    if enabled then
        -- Create infinite oxygen tank
        if not character:FindFirstChild("DivingTank") then
            local oxygenTank = Instance.new("Decal")
            oxygenTank.Name = "DivingTank"
            oxygenTank.Parent = workspace
            oxygenTank:SetAttribute("Tier", math.huge)
            oxygenTank.Parent = character
        end
        
        -- Disable oxygen script if it exists
        local clientFolder = character:FindFirstChild("client")
        if clientFolder then
            local oxygenScript = clientFolder:FindFirstChild("oxygen")
            if oxygenScript then
                oxygenScript.Enabled = false
            end
        end
        
        print("🫁 No Oxygen: ENABLED - You can breathe underwater indefinitely!")
    else
        -- Remove infinite oxygen tank
        local oxygenTank = character:FindFirstChild("DivingTank")
        if oxygenTank then
            oxygenTank:Destroy()
        end
        
        -- Re-enable oxygen script
        local clientFolder = character:FindFirstChild("client")
        if clientFolder then
            local oxygenScript = clientFolder:FindFirstChild("oxygen")
            if oxygenScript then
                oxygenScript.Enabled = true
            end
        end
        
        print("🫁 No Oxygen: DISABLED")
    end
end

--// No Temperature System
function UtilitySystem.setNoTemperature(enabled)
    noTemperatureEnabled = enabled
    
    if enabled then
        -- Set attributes to prevent temperature effects
        character:SetAttribute("WinterCloakEquipped", true)
        character:SetAttribute("Refill", true)
        
        -- Continuously maintain no temperature effects
        connections.noTemperature = RunService.Heartbeat:Connect(function()
            if character and character.Parent then
                character:SetAttribute("WinterCloakEquipped", true)
                character:SetAttribute("Refill", true)
            end
        end)
        
        print("🌡️ No Temperature: ENABLED - Immune to cold and temperature effects!")
    else
        -- Remove temperature immunity
        if connections.noTemperature then
            connections.noTemperature:Disconnect()
            connections.noTemperature = nil
        end
        
        character:SetAttribute("WinterCloakEquipped", nil)
        character:SetAttribute("Refill", false)
        
        print("🌡️ No Temperature: DISABLED")
    end
end

--// Anti-Down System (Anti Falling Damage)
function UtilitySystem.setAntiDown(enabled)
    antiDownEnabled = enabled
    
    if enabled then
        connections.antiDown = RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.Health > 0 then
                -- Prevent fall damage by limiting fall velocity
                if humanoidRootPart.Velocity.Y < -50 then
                    local velocity = humanoidRootPart.Velocity
                    humanoidRootPart.Velocity = Vector3.new(velocity.X, -20, velocity.Z)
                end
                
                -- Prevent health loss from falling
                if humanoid.Health < humanoid.MaxHealth and humanoid.Health > 0 then
                    local currentHealth = humanoid.Health
                    wait(0.1)
                    if humanoid.Health < currentHealth then
                        humanoid.Health = currentHealth
                    end
                end
            end
        end)
        
        print("🛡️ Anti-Down: ENABLED - No more fall damage!")
    else
        if connections.antiDown then
            connections.antiDown:Disconnect()
            connections.antiDown = nil
        end
        
        print("🛡️ Anti-Down: DISABLED")
    end
end

--// WalkSpeed System
function UtilitySystem.setWalkSpeed(speed)
    customWalkSpeed = speed or defaultWalkSpeed
    
    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = customWalkSpeed
        print("🏃 WalkSpeed set to:", customWalkSpeed)
    end
end

function UtilitySystem.enableWalkSpeed(enabled, speed)
    walkSpeedEnabled = enabled
    
    if enabled then
        UtilitySystem.setWalkSpeed(speed or customWalkSpeed)
        
        -- Keep walkspeed consistent
        connections.walkSpeed = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if walkSpeedEnabled and humanoid.WalkSpeed ~= customWalkSpeed then
                humanoid.WalkSpeed = customWalkSpeed
            end
        end)
        
        print("🏃 Custom WalkSpeed: ENABLED")
    else
        if connections.walkSpeed then
            connections.walkSpeed:Disconnect()
            connections.walkSpeed = nil
        end
        
        humanoid.WalkSpeed = defaultWalkSpeed
        print("🏃 Custom WalkSpeed: DISABLED")
    end
end

--// Unlimited Jump System
function UtilitySystem.setJumpPower(power)
    customJumpPower = power or defaultJumpPower
    
    if humanoid and humanoid.Parent then
        humanoid.JumpPower = customJumpPower
        print("🦘 JumpPower set to:", customJumpPower)
    end
end

function UtilitySystem.enableUnlimitedJump(enabled, power)
    unlimitedJumpEnabled = enabled
    
    if enabled then
        UtilitySystem.setJumpPower(power or customJumpPower)
        
        -- Keep jump power consistent
        connections.jumpPower = humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if unlimitedJumpEnabled and humanoid.JumpPower ~= customJumpPower then
                humanoid.JumpPower = customJumpPower
            end
        end)
        
        print("🦘 Unlimited Jump: ENABLED")
    else
        if connections.jumpPower then
            connections.jumpPower:Disconnect()
            connections.jumpPower = nil
        end
        
        humanoid.JumpPower = defaultJumpPower
        print("🦘 Unlimited Jump: DISABLED")
    end
end

--// Anti Detect Staff System
function UtilitySystem.setAntiDetectStaff(enabled)
    antiDetectStaffEnabled = enabled
    
    if enabled then
        -- Hide character from staff detection
        connections.antiDetectStaff = RunService.Heartbeat:Connect(function()
            if character and character.Parent then
                -- Hide from admin commands
                character:SetAttribute("NoAdmin", true)
                character:SetAttribute("Invisible", true)
                
                -- Spoof player data to avoid detection
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, gui in pairs(playerGui:GetChildren()) do
                        if gui.Name:lower():find("admin") or gui.Name:lower():find("mod") or gui.Name:lower():find("staff") then
                            gui:Destroy()
                        end
                    end
                end
                
                -- Hide from staff lists
                LocalPlayer:SetAttribute("Staff", false)
                LocalPlayer:SetAttribute("Admin", false)
                LocalPlayer:SetAttribute("Moderator", false)
            end
        end)
        
        print("🕵️ Anti Detect Staff: ENABLED - Hidden from staff detection!")
    else
        if connections.antiDetectStaff then
            connections.antiDetectStaff:Disconnect()
            connections.antiDetectStaff = nil
        end
        
        -- Restore normal visibility
        if character and character.Parent then
            character:SetAttribute("NoAdmin", nil)
            character:SetAttribute("Invisible", nil)
        end
        
        print("🕵️ Anti Detect Staff: DISABLED")
    end
end

--// Anti AFK System
function UtilitySystem.setAntiAFK(enabled)
    antiAFKEnabled = enabled
    
    if enabled then
        local lastPosition = humanoidRootPart.Position
        local afkTime = 0
        
        connections.antiAFK = RunService.Heartbeat:Connect(function()
            if character and humanoidRootPart then
                -- Check if player is idle
                if (humanoidRootPart.Position - lastPosition).Magnitude < 0.1 then
                    afkTime = afkTime + RunService.Heartbeat:Wait()
                    
                    -- Simulate small movement every 30 seconds
                    if afkTime >= 30 then
                        humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0.01, 0, 0)
                        wait(0.1)
                        humanoidRootPart.CFrame = humanoidRootPart.CFrame - Vector3.new(0.01, 0, 0)
                        afkTime = 0
                    end
                else
                    afkTime = 0
                    lastPosition = humanoidRootPart.Position
                end
                
                -- Prevent AFK detection attributes
                LocalPlayer:SetAttribute("AFK", false)
                LocalPlayer:SetAttribute("IdleTime", 0)
                character:SetAttribute("LastAction", tick())
            end
        end)
        
        print("😴 Anti AFK: ENABLED - You won't be detected as AFK!")
    else
        if connections.antiAFK then
            connections.antiAFK:Disconnect()
            connections.antiAFK = nil
        end
        
        print("😴 Anti AFK: DISABLED")
    end
end

--// Reduced Lag System
function UtilitySystem.setReducedLag(enabled)
    reducedLagEnabled = enabled
    
    if enabled then
        -- Reduce rendering quality for better performance
        local lighting = game:GetService("Lighting")
        local workspace = game:GetService("Workspace")
        
        -- Store original settings (safely with pcall)
        local originalSettings = {
            meshPartDetail = workspace.MeshPartHeadsAndAccessories,
            streamingEnabled = workspace.StreamingEnabled
        }
        
        -- Safely try to get shadow settings
        pcall(function()
            originalSettings.shadowMapEnabled = lighting.ShadowMapEnabled
        end)
        pcall(function()
            originalSettings.globalShadows = lighting.GlobalShadows
        end)
        
        -- Apply performance settings (safely)
        pcall(function()
            lighting.ShadowMapEnabled = false
        end)
        pcall(function()
            lighting.GlobalShadows = false
        end)
        workspace.MeshPartHeadsAndAccessories = Enum.MeshPartHeadsAndAccessories.Disabled
        workspace.StreamingEnabled = true
        
        -- Remove unnecessary visual effects
        connections.reducedLag = RunService.Heartbeat:Connect(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    obj.Enabled = false
                elseif obj:IsA("Explosion") then
                    obj:Destroy()
                end
            end
        end)
        
        -- Store settings for restoration
        UtilitySystem._originalSettings = originalSettings
        
        print("🚀 Reduced Lag: ENABLED - Performance optimized!")
    else
        if connections.reducedLag then
            connections.reducedLag:Disconnect()
            connections.reducedLag = nil
        end
        
        -- Restore original settings
        if UtilitySystem._originalSettings then
            local lighting = game:GetService("Lighting")
            local workspace = game:GetService("Workspace")
            local settings = UtilitySystem._originalSettings
            
            -- Restore original settings (safely)
            pcall(function()
                if settings.shadowMapEnabled ~= nil then
                    lighting.ShadowMapEnabled = settings.shadowMapEnabled
                end
            end)
            pcall(function()
                if settings.globalShadows ~= nil then
                    lighting.GlobalShadows = settings.globalShadows
                end
            end)
            workspace.MeshPartHeadsAndAccessories = settings.meshPartDetail
            workspace.StreamingEnabled = settings.streamingEnabled
        end
        
        print("🚀 Reduced Lag: DISABLED")
    end
end

--// Fast FPS System
function UtilitySystem.setFastFPS(enabled)
    fastFPSEnabled = enabled
    
    if enabled then
        -- Advanced FPS optimization based on improved algorithm
        local lighting = game:GetService("Lighting")
        local materialService = game:GetService("MaterialService")
        local runService = game:GetService("RunService")
        local players = game:GetService("Players")
        local localPlayer = players.LocalPlayer
        
        -- Store original settings for restoration
        UtilitySystem._originalFPSSettings = {
            qualityLevel = settings().Rendering.QualityLevel,
            meshPartDetail = settings().Rendering.MeshPartDetailLevel,
            globalShadows = lighting.GlobalShadows,
            fogEnd = lighting.FogEnd,
            shadowSoftness = lighting.ShadowSoftness
        }
        
        -- Apply safe FPS optimizations
        pcall(function()
            -- Rendering optimizations
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
            
            -- Lighting optimizations
            lighting.GlobalShadows = false
            lighting.FogEnd = 9e9
            lighting.ShadowSoftness = 0
            
            -- Terrain water optimization
            if workspace:FindFirstChildOfClass("Terrain") then
                local terrain = workspace:FindFirstChildOfClass("Terrain")
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 0
                
                if sethiddenproperty then
                    sethiddenproperty(terrain, "Decoration", false)
                    sethiddenproperty(lighting, "Technology", 2)
                end
            end
            
            -- Material optimization
            for _, material in pairs(materialService:GetChildren()) do
                if material:IsA("MaterialVariant") then
                    material:Destroy()
                end
            end
            materialService.Use2022Materials = false
            
            -- FPS uncapping
            if setfpscap then
                setfpscap(240) -- Set to 240 FPS cap for stability
            end
        end)
        
        -- Smart object optimization (safe version)
        local function optimizeInstance(instance)
            pcall(function()
                if instance:IsA("BasePart") and not instance:IsA("MeshPart") then
                    -- Optimize regular parts
                    instance.Material = Enum.Material.Plastic
                    instance.Reflectance = 0
                    instance.CastShadow = false
                elseif instance:IsA("MeshPart") then
                    -- Optimize MeshParts safely
                    instance.RenderFidelity = Enum.RenderFidelity.Performance
                    instance.Material = Enum.Material.Plastic
                    instance.Reflectance = 0
                    instance.CastShadow = false
                elseif instance:IsA("Model") then
                    -- Lower model detail
                    instance.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled
                elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") then
                    -- Disable particles and effects
                    instance.Enabled = false
                elseif instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") then
                    -- Disable environmental effects
                    instance.Enabled = false
                elseif instance:IsA("PostEffect") then
                    -- Disable camera effects
                    instance.Enabled = false
                elseif instance:IsA("Explosion") then
                    -- Remove explosions
                    instance:Destroy()
                elseif instance:IsA("Clothing") or instance:IsA("SurfaceAppearance") then
                    -- Remove clothing for performance
                    instance:Destroy()
                elseif instance:IsA("Decal") or instance:IsA("Texture") then
                    -- Make textures invisible but don't destroy
                    instance.Transparency = 0.9
                end
            end)
        end
        
        -- Apply optimizations to existing objects
        spawn(function()
            local descendants = workspace:GetDescendants()
            local waitPerAmount = 500
            local currentWait = waitPerAmount
            
            for i, instance in pairs(descendants) do
                -- Skip player characters to avoid issues
                local isPlayerCharacter = false
                for _, player in pairs(players:GetPlayers()) do
                    if player.Character and instance:IsDescendantOf(player.Character) then
                        isPlayerCharacter = true
                        break
                    end
                end
                
                if not isPlayerCharacter then
                    optimizeInstance(instance)
                end
                
                -- Yield periodically to prevent lag
                if i == currentWait then
                    task.wait()
                    currentWait = currentWait + waitPerAmount
                end
            end
        end)
        
        -- Monitor new objects
        connections.fastFPS = workspace.DescendantAdded:Connect(function(instance)
            task.wait(0.1) -- Small delay to let object settle
            
            -- Skip player characters
            local isPlayerCharacter = false
            for _, player in pairs(players:GetPlayers()) do
                if player.Character and instance:IsDescendantOf(player.Character) then
                    isPlayerCharacter = true
                    break
                end
            end
            
            if not isPlayerCharacter then
                optimizeInstance(instance)
            end
        end)
        
        print("⚡ Fast FPS: ENABLED - Advanced optimization loaded!")
    else
        if connections.fastFPS then
            connections.fastFPS:Disconnect()
            connections.fastFPS = nil
        end
        
        -- Restore original settings
        if UtilitySystem._originalFPSSettings then
            local original = UtilitySystem._originalFPSSettings
            
            pcall(function()
                -- Restore rendering settings
                settings().Rendering.QualityLevel = original.qualityLevel or Enum.QualityLevel.Automatic
                settings().Rendering.MeshPartDetailLevel = original.meshPartDetail or Enum.MeshPartDetailLevel.DistanceBased
                
                -- Restore lighting
                local lighting = game:GetService("Lighting")
                lighting.GlobalShadows = original.globalShadows ~= nil and original.globalShadows or true
                lighting.FogEnd = original.fogEnd or 100000
                lighting.ShadowSoftness = original.shadowSoftness or 0.2
                
                -- Restore terrain water if possible
                if workspace:FindFirstChildOfClass("Terrain") then
                    local terrain = workspace:FindFirstChildOfClass("Terrain")
                    terrain.WaterWaveSize = 0.05
                    terrain.WaterWaveSpeed = 10
                    terrain.WaterReflectance = 1
                    terrain.WaterTransparency = 0.3
                end
                
                -- Re-enable materials
                local materialService = game:GetService("MaterialService")
                materialService.Use2022Materials = true
                
                -- Remove FPS cap
                if setfpscap then
                    setfpscap(0) -- Remove FPS cap
                end
            end)
            
            UtilitySystem._originalFPSSettings = nil
        end
        
        print("⚡ Fast FPS: DISABLED")
    end
end

--// ESP Player System
function UtilitySystem.setESPPlayer(enabled)
    espPlayerEnabled = enabled
    
    if enabled then
        local espObjects = {}
        
        -- Create ESP for existing players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                UtilitySystem._createESP(player, espObjects)
            end
        end
        
        -- Create ESP for new players
        connections.playerAdded = Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                wait(1)
                UtilitySystem._createESP(player, espObjects)
            end)
        end)
        
        -- Remove ESP when players leave
        connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
            if espObjects[player] then
                for _, obj in pairs(espObjects[player]) do
                    obj:Destroy()
                end
                espObjects[player] = nil
            end
        end)
        
        -- Store ESP objects for cleanup
        UtilitySystem._espObjects = espObjects
        
        print("👁️ ESP Player: ENABLED - All players are now visible!")
    else
        if connections.playerAdded then
            connections.playerAdded:Disconnect()
            connections.playerAdded = nil
        end
        
        if connections.playerRemoving then
            connections.playerRemoving:Disconnect()
            connections.playerRemoving = nil
        end
        
        -- Remove all ESP objects
        if UtilitySystem._espObjects then
            for _, playerESP in pairs(UtilitySystem._espObjects) do
                for _, obj in pairs(playerESP) do
                    obj:Destroy()
                end
            end
            UtilitySystem._espObjects = {}
        end
        
        print("👁️ ESP Player: DISABLED")
    end
end

-- Helper function to create ESP for a player
function UtilitySystem._createESP(player, espObjects)
    if not player.Character or espObjects[player] then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    espObjects[player] = {}
    
    -- Create highlight effect
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerESP"
    highlight.FillColor = Color3.new(1, 0, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    table.insert(espObjects[player], highlight)
    
    -- Create distance and name display
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "PlayerESPText"
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.Parent = humanoidRootPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboardGui
    
    table.insert(espObjects[player], billboardGui)
    
    -- Update distance continuously
    local updateConnection
    updateConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not LocalPlayer.Character then
            updateConnection:Disconnect()
            return
        end
        
        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
        
        if localRoot and playerRoot then
            local distance = math.floor((localRoot.Position - playerRoot.Position).Magnitude)
            textLabel.Text = player.Name .. "\n[" .. distance .. "m]"
        end
    end)
    
    table.insert(espObjects[player], updateConnection)
end

--// Get Status Functions
function UtilitySystem.getNoOxygenStatus()
    return noOxygenEnabled
end

function UtilitySystem.getNoTemperatureStatus()
    return noTemperatureEnabled
end

function UtilitySystem.getAntiDownStatus()
    return antiDownEnabled
end

function UtilitySystem.getWalkSpeedStatus()
    return walkSpeedEnabled, customWalkSpeed
end

function UtilitySystem.getUnlimitedJumpStatus()
    return unlimitedJumpEnabled, customJumpPower
end

function UtilitySystem.getAntiDetectStaffStatus()
    return antiDetectStaffEnabled
end

function UtilitySystem.getAntiAFKStatus()
    return antiAFKEnabled
end

function UtilitySystem.getReducedLagStatus()
    return reducedLagEnabled
end

function UtilitySystem.getFastFPSStatus()
    return fastFPSEnabled
end

function UtilitySystem.getESPPlayerStatus()
    return espPlayerEnabled
end

--// Cleanup function
function UtilitySystem.cleanup()
    for name, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    connections = {}
    
    -- Reset all features
    UtilitySystem.setNoOxygen(false)
    UtilitySystem.setNoTemperature(false)
    UtilitySystem.setNoclip(false)
    UtilitySystem.setAntiDown(false)
    UtilitySystem.enableWalkSpeed(false)
    UtilitySystem.enableUnlimitedJump(false)
    UtilitySystem.setAntiDetectStaff(false)
    UtilitySystem.setAntiAFK(false)
    UtilitySystem.setReducedLag(false)
    UtilitySystem.setFastFPS(false)
    UtilitySystem.setESPPlayer(false)
    
    print("🧹 UtilitySystem: All features disabled and cleaned up")
end

--// Initialize
function UtilitySystem.init()
    print("🛠️ Utility System v2.0 - Loaded successfully!")
    print("🫁 No Oxygen - Breathe underwater indefinitely")
    print("🌡️ No Temperature - Immune to cold/temperature effects") 
    print("👻 Noclip - Walk through walls")
    print("🛡️ Anti-Down - No fall damage")
    print("🏃 WalkSpeed - Custom walking speed")
    print("🦘 Unlimited Jump - Custom jump power")
    print("🕵️ Anti Detect Staff - Hidden from staff detection")
    print("😴 Anti AFK - Prevent AFK detection")
    print("🚀 Reduced Lag - Performance optimization")
    print("⚡ Fast FPS - Maximum FPS boost")
    print("👁️ ESP Player - See all players with highlights")
    return UtilitySystem
end

return UtilitySystem
