--[[
    OrionLib Compatibility Wrapper for uiv2.lua
    This allows using uiv2.lua with existing OrionLib API
]]

local uiv2 = loadstring(readfile('uiv2.lua'))()

-- Create compatibility wrapper
local OrionLib = {}

function OrionLib:MakeWindow(settings)
    local name = settings.Name or "Window"
    local hidePremium = settings.HidePremium or false
    local saveConfig = settings.SaveConfig or false
    local configFolder = settings.ConfigFolder or "OrionConfig"
    local introText = settings.IntroText or ""
    local introIcon = settings.IntroIcon or ""
    
    -- Create window using uiv2
    local window = uiv2:CreateWindow(name, "v1.0", introIcon)
    
    -- Add wrapper methods
    function window:MakeTab(tabSettings)
        local tabName = tabSettings.Name or "Tab"
        local icon = tabSettings.Icon or ""
        local premiumOnly = tabSettings.PremiumOnly or false
        
        -- Create tab using uiv2
        local tab = window:CreateTab(tabName)
        
        -- Add wrapper methods for tab
        function tab:AddSection(sectionSettings)
            local sectionName = sectionSettings.Name or "Section"
            
            -- Create frame using uiv2
            local section = tab:CreateFrame(sectionName)
            
            -- Add wrapper methods for section
            function section:AddButton(buttonSettings)
                local name = buttonSettings.Name or "Button"
                local callback = buttonSettings.Callback or function() end
                
                return section:CreateButton(name, "", callback)
            end
            
            function section:AddToggle(toggleSettings)
                local name = toggleSettings.Name or "Toggle"
                local default = toggleSettings.Default or false
                local flag = toggleSettings.Flag or ""
                local save = toggleSettings.Save or false
                local callback = toggleSettings.Callback or function() end
                
                return section:CreateToggle(name, "", callback)
            end
            
            function section:AddSlider(sliderSettings)
                local name = sliderSettings.Name or "Slider"
                local min = sliderSettings.Min or 0
                local max = sliderSettings.Max or 100
                local default = sliderSettings.Default or 0
                local callback = sliderSettings.Callback or function() end
                
                return section:CreateSlider(name, min, max, callback)
            end
            
            function section:AddTextbox(textboxSettings)
                local name = textboxSettings.Name or "Textbox"
                local default = textboxSettings.Default or ""
                local textDisappear = textboxSettings.TextDisappear or false
                local callback = textboxSettings.Callback or function() end
                
                return section:CreateBox(name, "", callback)
            end
            
            function section:AddBind(bindSettings)
                local name = bindSettings.Name or "Keybind"
                local default = bindSettings.Default or Enum.KeyCode.E
                local hold = bindSettings.Hold or false
                local callback = bindSettings.Callback or function() end
                
                return section:CreateBind(name, default, callback)
            end
            
            function section:AddLabel(text)
                return section:CreateLabel(text or "Label")
            end
            
            function section:AddColorpicker(colorSettings)
                local name = colorSettings.Name or "Color Picker"
                local default = colorSettings.Default or Color3.fromRGB(255, 255, 255)
                local callback = colorSettings.Callback or function() end
                
                return section:CreateColorPicker(name, callback)
            end
            
            function section:AddDropdown(dropdownSettings)
                -- uiv2.lua doesn't have dropdown, create as label
                local name = dropdownSettings.Name or "Dropdown"
                return section:CreateLabel(name .. " (Dropdown not supported)")
            end
            
            return section
        end
        
        return tab
    end
    
    return window
end

function OrionLib:MakeNotification(notificationSettings)
    local name = notificationSettings.Name or "Notification"
    local content = notificationSettings.Content or ""
    local image = notificationSettings.Image or ""
    local time = notificationSettings.Time or 5
    
    -- Create simple notification using game StarterGui
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = name,
        Text = content,
        Duration = time,
        Icon = image
    })
end

function OrionLib:Init()
    -- Initialize if needed
end

function OrionLib:Destroy()
    -- Cleanup if needed
end

return OrionLib
