local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") 
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Fenglib = {}
local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow" 
local RainbowSpeed = 1.0
local Registry = {} 
local ConfigObjects = {} 
local ThemeListeners = {}

local ConfigFolder = "Eternal_Configs"
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

local Theme = {
    Background = Color3.fromRGB(20, 20, 28),
    Sidebar    = Color3.fromRGB(25, 25, 35),
    Element    = Color3.fromRGB(32, 32, 42),
    Text       = Color3.fromRGB(245, 245, 255),
    TextDim    = Color3.fromRGB(160, 160, 180),
    Accent1    = Color3.fromRGB(140, 20, 255), 
    Accent2    = Color3.fromRGB(255, 50, 180)
}

local ThemePresets = {
    ["Eternal (Default)"] = {
        Background = Color3.fromRGB(20, 20, 28), 
        Sidebar = Color3.fromRGB(25, 25, 35), 
        Element = Color3.fromRGB(32, 32, 42),
        Text = Color3.fromRGB(245, 245, 255), 
        TextDim = Color3.fromRGB(160, 160, 180),
        Accent1 = Color3.fromRGB(140, 20, 255), 
        Accent2 = Color3.fromRGB(255, 50, 180)
    },
    ["Ocean Breeze"] = {
        Background = Color3.fromRGB(10, 20, 30), 
        Sidebar = Color3.fromRGB(15, 25, 40), 
        Element = Color3.fromRGB(20, 35, 55),
        Text = Color3.fromRGB(240, 250, 255), 
        TextDim = Color3.fromRGB(140, 160, 180),
        Accent1 = Color3.fromRGB(0, 190, 255), 
        Accent2 = Color3.fromRGB(0, 100, 255)
    },
    ["Toxic Nature"] = {
        Background = Color3.fromRGB(20, 25, 20), 
        Sidebar = Color3.fromRGB(25, 35, 25), 
        Element = Color3.fromRGB(35, 45, 35),
        Text = Color3.fromRGB(240, 255, 240), 
        TextDim = Color3.fromRGB(150, 180, 150),
        Accent1 = Color3.fromRGB(100, 255, 50), 
        Accent2 = Color3.fromRGB(50, 180, 0)
    },
    ["Blood Moon"] = {
        Background = Color3.fromRGB(25, 10, 10), 
        Sidebar = Color3.fromRGB(35, 15, 15), 
        Element = Color3.fromRGB(45, 20, 20),
        Text = Color3.fromRGB(255, 240, 240), 
        TextDim = Color3.fromRGB(180, 140, 140),
        Accent1 = Color3.fromRGB(255, 50, 50), 
        Accent2 = Color3.fromRGB(180, 0, 0)
    },
    ["Midnight Sky"] = {
        Background = Color3.fromRGB(15, 15, 20), 
        Sidebar = Color3.fromRGB(25, 25, 30), 
        Element = Color3.fromRGB(35, 35, 45),
        Text = Color3.fromRGB(255, 255, 255), 
        TextDim = Color3.fromRGB(160, 160, 170),
        Accent1 = Color3.fromRGB(100, 100, 255), 
        Accent2 = Color3.fromRGB(180, 180, 255)
    },
    ["Cotton Candy"] = {
        Background = Color3.fromRGB(30, 20, 30), 
        Sidebar = Color3.fromRGB(40, 25, 40), 
        Element = Color3.fromRGB(50, 35, 50),
        Text = Color3.fromRGB(255, 245, 255), 
        TextDim = Color3.fromRGB(200, 160, 200),
        Accent1 = Color3.fromRGB(255, 100, 200), 
        Accent2 = Color3.fromRGB(100, 200, 255)
    },
    ["Sunset Dunes"] = {
        Background = Color3.fromRGB(30, 20, 15), 
        Sidebar = Color3.fromRGB(40, 25, 20), 
        Element = Color3.fromRGB(55, 35, 25),
        Text = Color3.fromRGB(255, 245, 235), 
        TextDim = Color3.fromRGB(200, 170, 150),
        Accent1 = Color3.fromRGB(255, 150, 50), 
        Accent2 = Color3.fromRGB(255, 100, 0)
    },
    ["Arctic Frost"] = {
        Background = Color3.fromRGB(20, 25, 30), 
        Sidebar = Color3.fromRGB(25, 35, 40), 
        Element = Color3.fromRGB(35, 45, 55),
        Text = Color3.fromRGB(240, 250, 255), 
        TextDim = Color3.fromRGB(180, 200, 220),
        Accent1 = Color3.fromRGB(100, 220, 255), 
        Accent2 = Color3.fromRGB(50, 150, 255)
    },
    ["Cyberpunk Neon"] = {
        Background = Color3.fromRGB(10, 5, 20), 
        Sidebar = Color3.fromRGB(15, 10, 30), 
        Element = Color3.fromRGB(25, 15, 40),
        Text = Color3.fromRGB(255, 255, 255), 
        TextDim = Color3.fromRGB(180, 180, 220),
        Accent1 = Color3.fromRGB(255, 0, 255), 
        Accent2 = Color3.fromRGB(0, 255, 255)
    },
    ["Forest Guardian"] = {
        Background = Color3.fromRGB(15, 25, 20), 
        Sidebar = Color3.fromRGB(20, 35, 25), 
        Element = Color3.fromRGB(30, 45, 35),
        Text = Color3.fromRGB(230, 255, 240), 
        TextDim = Color3.fromRGB(160, 200, 170),
        Accent1 = Color3.fromRGB(80, 220, 120), 
        Accent2 = Color3.fromRGB(40, 180, 100)
    },
    ["Royal Purple"] = {
        Background = Color3.fromRGB(25, 15, 35), 
        Sidebar = Color3.fromRGB(35, 20, 50), 
        Element = Color3.fromRGB(45, 30, 65),
        Text = Color3.fromRGB(255, 245, 255), 
        TextDim = Color3.fromRGB(200, 180, 220),
        Accent1 = Color3.fromRGB(180, 80, 255), 
        Accent2 = Color3.fromRGB(140, 40, 220)
    },
    ["Golden Hour"] = {
        Background = Color3.fromRGB(30, 25, 15), 
        Sidebar = Color3.fromRGB(40, 30, 20), 
        Element = Color3.fromRGB(55, 40, 25),
        Text = Color3.fromRGB(255, 250, 235), 
        TextDim = Color3.fromRGB(220, 200, 160),
        Accent1 = Color3.fromRGB(255, 200, 50), 
        Accent2 = Color3.fromRGB(220, 160, 30)
    },
    ["Abyssal Deep"] = {
        Background = Color3.fromRGB(5, 10, 20), 
        Sidebar = Color3.fromRGB(10, 15, 30), 
        Element = Color3.fromRGB(15, 25, 45),
        Text = Color3.fromRGB(230, 240, 255), 
        TextDim = Color3.fromRGB(150, 170, 200),
        Accent1 = Color3.fromRGB(0, 150, 200), 
        Accent2 = Color3.fromRGB(0, 100, 150)
    },
    ["Crimson Dawn"] = {
        Background = Color3.fromRGB(30, 10, 15), 
        Sidebar = Color3.fromRGB(40, 15, 20), 
        Element = Color3.fromRGB(55, 20, 25),
        Text = Color3.fromRGB(255, 235, 240), 
        TextDim = Color3.fromRGB(220, 160, 170),
        Accent1 = Color3.fromRGB(255, 60, 80), 
        Accent2 = Color3.fromRGB(200, 30, 50)
    },
    ["Matrix Green"] = {
        Background = Color3.fromRGB(5, 15, 10), 
        Sidebar = Color3.fromRGB(10, 25, 15), 
        Element = Color3.fromRGB(15, 35, 20),
        Text = Color3.fromRGB(220, 255, 220), 
        TextDim = Color3.fromRGB(150, 220, 150),
        Accent1 = Color3.fromRGB(0, 255, 100), 
        Accent2 = Color3.fromRGB(0, 180, 70)
    },
    ["Pastel Dream"] = {
        Background = Color3.fromRGB(240, 235, 245), 
        Sidebar = Color3.fromRGB(245, 240, 250), 
        Element = Color3.fromRGB(250, 245, 255),
        Text = Color3.fromRGB(40, 35, 50), 
        TextDim = Color3.fromRGB(120, 110, 140),
        Accent1 = Color3.fromRGB(255, 150, 200), 
        Accent2 = Color3.fromRGB(150, 200, 255)
    },
    ["Industrial Gray"] = {
        Background = Color3.fromRGB(35, 35, 40), 
        Sidebar = Color3.fromRGB(45, 45, 50), 
        Element = Color3.fromRGB(55, 55, 60),
        Text = Color3.fromRGB(240, 240, 245), 
        TextDim = Color3.fromRGB(180, 180, 190),
        Accent1 = Color3.fromRGB(255, 100, 50), 
        Accent2 = Color3.fromRGB(200, 150, 50)
    },
    ["Solar Flare"] = {
        Background = Color3.fromRGB(40, 25, 10), 
        Sidebar = Color3.fromRGB(50, 30, 15), 
        Element = Color3.fromRGB(65, 40, 20),
        Text = Color3.fromRGB(255, 250, 240), 
        TextDim = Color3.fromRGB(220, 200, 170),
        Accent1 = Color3.fromRGB(255, 180, 50), 
        Accent2 = Color3.fromRGB(255, 120, 30)
    },
    ["Twilight Zone"] = {
        Background = Color3.fromRGB(20, 15, 30), 
        Sidebar = Color3.fromRGB(30, 20, 40), 
        Element = Color3.fromRGB(40, 30, 55),
        Text = Color3.fromRGB(245, 240, 255), 
        TextDim = Color3.fromRGB(180, 170, 200),
        Accent1 = Color3.fromRGB(180, 100, 255), 
        Accent2 = Color3.fromRGB(100, 200, 255)
    },
    ["Mono Chrome"] = {
        Background = Color3.fromRGB(20, 20, 20), 
        Sidebar = Color3.fromRGB(30, 30, 30), 
        Element = Color3.fromRGB(40, 40, 40),
        Text = Color3.fromRGB(255, 255, 255), 
        TextDim = Color3.fromRGB(180, 180, 180),
        Accent1 = Color3.fromRGB(255, 255, 255), 
        Accent2 = Color3.fromRGB(200, 200, 200)
    },
}

local ThemeRegistry = {Objects = {}, Gradients = {}, Customs = {}}

local function RegisterTheme(obj, prop, key) 
    table.insert(ThemeRegistry.Objects, {Object=obj, Property=prop, Key=key}) 
    obj[prop] = Theme[key] 
    return obj 
end

local function RegisterGradient(gradient, key1, key2)
    table.insert(ThemeRegistry.Gradients, {Object=gradient, K1=key1, K2=key2})
    gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme[key1]), ColorSequenceKeypoint.new(1, Theme[key2])}
    return gradient
end

local function UpdateTheme(themeName)
    local newTheme = ThemePresets[themeName] or ThemePresets["Eternal (Default)"]
    for k, v in pairs(newTheme) do Theme[k] = v end
    
    for i = #ThemeRegistry.Objects, 1, -1 do
        local data = ThemeRegistry.Objects[i]
        if data.Object and data.Object.Parent then
            pcall(function() TweenService:Create(data.Object, TweenInfo.new(0.5), {[data.Property]=Theme[data.Key]}):Play() end)
        else
            table.remove(ThemeRegistry.Objects, i)
        end
    end
    
    for i = #ThemeRegistry.Gradients, 1, -1 do
        local data = ThemeRegistry.Gradients[i]
        if data.Object and data.Object.Parent then
            pcall(function() data.Object.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme[data.K1]), ColorSequenceKeypoint.new(1, Theme[data.K2])} end)
        else
            table.remove(ThemeRegistry.Gradients, i)
        end
    end
end

local FontID = "rbxassetid://12187365364"
local FontMain = Font.new(FontID, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
local FontBold = Font.new(FontID, Enum.FontWeight.Bold, Enum.FontStyle.Normal)

local Icons = {
    ["settings"] = "rbxassetid://80758916183665",
    ["folder"] = "rbxassetid://109080612832751",
    ["paint-bucket"] = "rbxassetid://124275586663284",
    ["chevron"] = "rbxassetid://134243273101015",
    ["check"] = "rbxassetid://93898873302694",
    ["info"] = "rbxassetid://124560466474914",
    ["resize_custom"] = "rbxassetid://122360365318466",
}

local function RGBtoHex(color)
    local r, g, b = math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)
    return string.format("#%02X%02X%02X", r, g, b)
end
local function HexToRGB(hex)
    hex = hex:gsub("#","")
    local r = tonumber("0x"..hex:sub(1,2))
    local g = tonumber("0x"..hex:sub(3,4))
    local b = tonumber("0x"..hex:sub(5,6))
    if r and g and b then return Color3.fromRGB(r,g,b) end
    return nil
end

local function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

local function startNeonFlowEffect(object, property, speed)
    speed = speed or 0.008
    local hue = 0
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        hue = (hue + speed) % 1
        local r = math.sin(hue * 3 + 0) * 0.3 + 0.7
        local g = math.sin(hue * 3 + 2) * 0.1
        local b = math.sin(hue * 3 + 4) * 0.1
        object[property] = Color3.new(r, g, b)
    end)
    return connection
end

local function createPulseGlow(object)
    local connection
    local isRunning = true
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent or not isRunning then
            if connection then
                connection:Disconnect()
            end
            return
        end
        local alpha = 0.5 + math.sin(tick() * 3) * 0.3
        if object:IsA("UIStroke") then
            object.Transparency = alpha
        elseif object:IsA("Frame") or object:IsA("TextButton") then
            object.BackgroundTransparency = alpha
        end
    end)
    return {
        Disconnect = function()
            isRunning = false
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end,
        IsRunning = function()
            return isRunning and object and object.Parent
        end
    }
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local FloatLocked = false

local function MakeDraggable(object, dragObject)
    local dragging, dragInput, dragStart, startPos
    local function Update(input)
        local delta = input.Position - dragStart
        Tween(object, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
    end
    dragObject.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not FloatLocked then
            dragging = true dragStart = input.Position startPos = object.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    dragObject.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    RunService.RenderStepped:Connect(function() if dragging and dragInput then Update(dragInput) end end)
end

local function MakeResizable(frame, handle)
    local resizing, startSize, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true startSize = frame.AbsoluteSize startPos = input.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then resizing = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            frame.Size = UDim2.new(0, math.max(500, startSize.X + delta.X), 0, math.max(350, startSize.Y + delta.Y))
        end
    end)
end

function Fenglib:SetTheme(themeName)
    if ThemePresets[themeName] then
        UpdateTheme(themeName)
    end
end

function Fenglib:ToggleRainbow(bool) RainbowEnabled = bool end
function Fenglib:SetRainbowType(val) RainbowType = val end
function Fenglib:SetRainbowSpeed(val) RainbowSpeed = clamp(tonumber(val) or 1, 0.1, 10) end

function Fenglib:SaveConfig(configName, configFolder)
    local ok, err = pcall(function()
        if not isfolder(configFolder) then makefolder(configFolder) end
        local data = {}
        for flag, obj in pairs(ConfigObjects) do
            if obj and obj.Value ~= nil then
                if typeof(obj.Value) == "Color3" then
                    data[flag] = {Type = "Color3", R = obj.Value.R, G = obj.Value.G, B = obj.Value.B}
                elseif type(obj.Value) == "table" and obj.Value.Color then
                    data[flag] = {Type = "CP", R = obj.Value.Color.R, G = obj.Value.Color.G, B = obj.Value.Color.B, A = obj.Value.Transparency}
                else
                    data[flag] = obj.Value
                end
            end
        end
        local json = HttpService:JSONEncode(data)
        writefile(configFolder .. "/" .. configName .. ".json", json)
    end)
    if not ok then
        warn("SaveConfig error:", err)
    end
    return ok
end

function Fenglib:LoadConfig(path)
    if not pcall(isfile, path) then return false end
    local exists = false
    pcall(function() exists = isfile(path) end)
    if not exists then return false end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(data) ~= "table" then return false end

    Fenglib._loading = true
    for flag, val in pairs(data) do
        if ConfigObjects[flag] and ConfigObjects[flag].Set then
            if type(val) == "table" and val.Type == "Color3" then
                pcall(function() ConfigObjects[flag].Set(Color3.new(val.R, val.G, val.B)) end)
            elseif type(val) == "table" and val.Type == "CP" then
                pcall(function() ConfigObjects[flag].Set({Color = Color3.new(val.R, val.G, val.B), Transparency = val.A}) end)
            else
                pcall(function() ConfigObjects[flag].Set(val) end)
            end
        end
    end
    Fenglib._loading = false

    return true
end

function Fenglib:CreateWindow(Config)
    local Window = {}
    local Title = Config.Title or "FengY3"
    local Subtitle = Config.Subtitle
    local Keybind = Config.Keybind 
    local IconAsset = Config.Icon  
    local useTooltips = Config.UseTooltips or false
    
    Window.RootFolder = Title 
    Window.ConfigFolder = Title.."/Config"
    Window.CurrentConfig = ""

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FengYu-Bento"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ScreenInsets = Enum.ScreenInsets.None
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) elseif gethui then ScreenGui.Parent = gethui() end

    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "NotificationHolder"
    NotificationHolder.Size = UDim2.new(0, 300, 0, 0)
    NotificationHolder.AutomaticSize = Enum.AutomaticSize.Y
    NotificationHolder.Position = UDim2.new(1, -20, 1, -20)
    NotificationHolder.AnchorPoint = Vector2.new(1, 1)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.BorderSizePixel = 0
    NotificationHolder.Parent = ScreenGui
    NotificationHolder.ZIndex = 100

    local HolderList = Instance.new("UIListLayout")
    HolderList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    HolderList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    HolderList.SortOrder = Enum.SortOrder.LayoutOrder
    HolderList.Padding = UDim.new(0, 5)
    HolderList.Parent = NotificationHolder

    local HolderPadding = Instance.new("UIPadding")
    HolderPadding.PaddingRight = UDim.new(0, 5)
    HolderPadding.PaddingBottom = UDim.new(0, 5)
    HolderPadding.Parent = NotificationHolder

    local MainFrame = Instance.new("Frame")
    MainFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    MainFrame.Size = UDim2.new(0, 480, 0, 360)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui
    
    local UIScale = Instance.new("UIScale")
    UIScale.Scale = 0
    UIScale.Parent = MainFrame
    Tween(UIScale, {Scale = 1}, 0.4)
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 2.5
    MainStroke.Transparency = 0
    MainStroke.Parent = MainFrame
    local StrokeGrad = RegisterGradient(Instance.new("UIGradient"), "Accent1", "Accent2")
    StrokeGrad.Rotation = 45
    StrokeGrad.Parent = MainStroke

    local BgGradient = Instance.new("UIGradient")
    BgGradient.Parent = MainFrame
    
    RunService.RenderStepped:Connect(function()
        if not MainFrame.Parent then return end
        local t = tick()
        BgGradient.Rotation = 45 + math.sin(t * 0.5) * 15
        BgGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.Background),
            ColorSequenceKeypoint.new(1, Theme.Sidebar)
        }
    end)

    MakeDraggable(MainFrame, MainFrame)
    
    local ResizeHandle = Instance.new("ImageButton")
    ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
    ResizeHandle.Position = UDim2.new(1, -2, 1, -2)
    ResizeHandle.AnchorPoint = Vector2.new(1, 1)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Image = Icons["resize_custom"] or "rbxassetid://122360365318466"
    RegisterTheme(ResizeHandle, "ImageColor3", "TextDim")
    ResizeHandle.Parent = MainFrame
    MakeResizable(MainFrame, ResizeHandle)

    local VersionLabel = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
    VersionLabel.Name = "FooterInfo"
    VersionLabel.Text = Config.Footer or "Eternal V36"
    VersionLabel.Size = UDim2.new(1, 0, 0, 20)
    VersionLabel.AnchorPoint = Vector2.new(0.5, 1)
    VersionLabel.Position = UDim2.new(0.5, 0, 1, -2)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.FontFace = FontMain
    VersionLabel.TextSize = 12
    VersionLabel.ZIndex = 10
    VersionLabel.Parent = MainFrame

    local SidebarWidth = 110
    local Sidebar = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Sidebar")
    Sidebar.Size = UDim2.new(0, SidebarWidth, 1, 0)
    Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
    
    local SidebarLine = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Element")
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, 0, 0, 0)
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Parent = Sidebar
    
    local Logo = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "Text")
    Logo.Text = "E"
    Logo.Size = UDim2.new(1, 0, 0, 60)
    Logo.BackgroundTransparency = 1
    Logo.FontFace = FontBold
    Logo.TextSize = 32
    Logo.Parent = Sidebar

    if IconAsset then
        Logo.TextTransparency = 1
        local LogoIcon = Instance.new("ImageLabel")
        LogoIcon.Size = UDim2.new(0, 40, 0, 40)
        LogoIcon.Position = UDim2.new(0.5, -20, 0, 10)
        LogoIcon.BackgroundTransparency = 1
        LogoIcon.Image = IconAsset
        LogoIcon.Parent = Sidebar
        RegisterGradient(Instance.new("UIGradient"), "Accent1", "Accent2").Parent = LogoIcon
    else
        RegisterGradient(Instance.new("UIGradient"), "Accent1", "Accent2").Parent = Logo
    end
    
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, 0, 1, -100)
    TabScroll.Position = UDim2.new(0, 0, 0, 80)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.Parent = Sidebar
    local TL = Instance.new("UIListLayout")
    TL.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TL.Padding = UDim.new(0, 5)
    TL.SortOrder = Enum.SortOrder.LayoutOrder
    TL.Parent = TabScroll
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -SidebarWidth, 1, 0)
    Content.Position = UDim2.new(0, SidebarWidth, 0, 0)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true
    Content.Parent = MainFrame
    
    local MenuTitle = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "Text")
    MenuTitle.Text = Title or "Eternal Menu"
    MenuTitle.Size = UDim2.new(1, -40, 0, 50)
    MenuTitle.Position = UDim2.new(0, 25, 0, 0)
    MenuTitle.BackgroundTransparency = 1
    MenuTitle.FontFace = FontBold
    MenuTitle.TextSize = 22
    MenuTitle.TextXAlignment = Enum.TextXAlignment.Left
    MenuTitle.ZIndex = 5
    MenuTitle.Parent = Content
    RegisterGradient(Instance.new("UIGradient"), "Accent1", "Accent2").Parent = MenuTitle

    if Subtitle then
        local SubtitleLabel = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
        SubtitleLabel.Text = Subtitle
        SubtitleLabel.Size = UDim2.new(1, -40, 0, 20)
        SubtitleLabel.Position = UDim2.new(0, 25, 0, 28)
        SubtitleLabel.BackgroundTransparency = 1
        SubtitleLabel.FontFace = FontMain
        SubtitleLabel.TextSize = 12
        SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        SubtitleLabel.Parent = Content
    end

    local FloatFrame = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Sidebar")
    FloatFrame.Size = UDim2.new(0, 110, 0, 45)
    FloatFrame.Position = UDim2.new(0, 20, 1, -80)
    FloatFrame.Parent = ScreenGui
    Instance.new("UICorner", FloatFrame).CornerRadius = UDim.new(0, 8)
    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Thickness = 2
    FloatStroke.Parent = FloatFrame
    RegisterGradient(Instance.new("UIGradient"), "Accent1", "Accent2").Parent = FloatStroke
    local DragHandle = Instance.new("TextButton")
    DragHandle.Size = UDim2.new(1, 0, 1, 0)
    DragHandle.BackgroundTransparency = 1
    DragHandle.Text = ""
    DragHandle.ZIndex = 1
    DragHandle.Parent = FloatFrame
    local OpenBtn = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Element")
    OpenBtn.Size = UDim2.new(0, 65, 1, -10)
    OpenBtn.Position = UDim2.new(0, 5, 0, 5)
    OpenBtn.Text = "Close"
    RegisterTheme(OpenBtn, "TextColor3", "Text")
    OpenBtn.FontFace = FontBold
    OpenBtn.TextSize = 13
    OpenBtn.ZIndex = 2
    OpenBtn.Parent = FloatFrame
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 6)
    RegisterGradient(Instance.new("UIGradient"), "Accent1", "Accent2").Parent = OpenBtn
    local LockBtn = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Background")
    LockBtn.Size = UDim2.new(0, 30, 1, -10)
    LockBtn.Position = UDim2.new(1, -35, 0, 5)
    LockBtn.Text = "🔓"
    RegisterTheme(LockBtn, "TextColor3", "TextDim")
    LockBtn.FontFace = FontMain
    LockBtn.TextSize = 14
    LockBtn.ZIndex = 2
    LockBtn.Parent = FloatFrame
    Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(0, 6)
    
    MakeDraggable(FloatFrame, DragHandle)
    local menuOpen = true
    OpenBtn.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        if menuOpen then
            MainFrame.Visible = true
            Tween(UIScale, {Scale = 1})
            OpenBtn.Text = "Close"
        else
            Tween(UIScale, {Scale = 0})
            task.wait(0.2)
            MainFrame.Visible = false
            OpenBtn.Text = "Open"
        end
    end)
    LockBtn.MouseButton1Click:Connect(function()
        FloatLocked = not FloatLocked
        LockBtn.Text = FloatLocked and "🔒" or "🔓"
        Tween(LockBtn, {BackgroundColor3 = FloatLocked and Theme.Accent1 or Theme.Background})
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then
            menuOpen = not menuOpen
            if menuOpen then
                MainFrame.Visible = true
                Tween(UIScale, {Scale = 1})
                OpenBtn.Text = "Close"
            else
                Tween(UIScale, {Scale = 0})
                task.wait(0.2)
                MainFrame.Visible = false
                OpenBtn.Text = "Open"
            end
        end
    end)

    MainFrame.Visible = false
    FloatFrame.Visible = true

    function Window:Notification(titleText, descText, notifType, duration)
        notifType = notifType or "Info"
        duration = duration or 3
        
        local typeColors = {
            Success = Theme.Accent1,
            Error   = Color3.fromRGB(229, 51, 51),
            Info    = Theme.Accent2
        }
        local accentColor = typeColors[notifType] or typeColors.Info

        local F = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Element")
        F.Size = UDim2.new(1, 0, 0, 60)
        F.Parent = NotificationHolder
        Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
        
        local B = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Text")
        B.Size = UDim2.new(0, 4, 1, -16)
        B.Position = UDim2.new(0, 6, 0, 8)
        F.ClipsDescendants = true
        B.Parent = F
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 2)
        
        local G = RegisterGradient(Instance.new("UIGradient"), "Accent1", "Accent2")
        G.Rotation = 90
        G.Parent = B
        
        local T = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "Text")
        T.Text = titleText
        T.Size = UDim2.new(1, -20, 0, 20)
        T.Position = UDim2.new(0, 18, 0, 8)
        T.BackgroundTransparency = 1
        T.FontFace = FontBold
        T.TextSize = 15
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = F
        
        local D = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
        D.Text = descText
        D.Size = UDim2.new(1, -20, 0, 20)
        D.Position = UDim2.new(0, 18, 0, 28)
        D.BackgroundTransparency = 1
        D.FontFace = FontMain
        D.TextSize = 13
        D.TextXAlignment = Enum.TextXAlignment.Left
        D.TextWrapped = true
        D.Parent = F
        
        Tween(F, {Position = UDim2.new(0, 0, 0, 0)})
        task.delay(duration or 3, function()
            Tween(F, {Position = UDim2.new(1.2, 0, 0, 0)})
            task.wait(0.4)
            F:Destroy()
        end)
    end

    Window._ProjectorModeEnabled = false
    Window._ProjectorObjects = nil
    Window._ProjectorSettings = {
        distance = 8,
        width = 12,
        height = 8,
        transparency = 0.3,
        autoSize = true
    }

    local function addPressEffect(button)
        local originalSize = button.Size
        local originalPos = button.Position
        button.MouseButton1Down:Connect(function()
            Tween(button, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.95, originalSize.Y.Scale, originalSize.Y.Offset * 0.95), Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 2, originalPos.Y.Scale, originalPos.Y.Offset + 2)}, 0.05)
        end)
        button.MouseButton1Up:Connect(function()
            Tween(button, {Size = originalSize, Position = originalPos}, 0.1)
        end)
        button.MouseLeave:Connect(function()
            Tween(button, {Size = originalSize, Position = originalPos}, 0.1)
        end)
    end

    local function addPressEffectToAll(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("ImageButton") then
                addPressEffect(child)
            end
            addPressEffectToAll(child)
        end
    end

    function Window:UpdateProjectorSizeFromUI()
        if not Window._ProjectorModeEnabled or not Window._ProjectorObjects then return end
        local mainFrame = Window._ProjectorObjects.SurfaceGui:FindFirstChild("FengYu-Bento")
        if not mainFrame then return end
        local absSize = mainFrame.AbsoluteSize
        if absSize.X <= 0 or absSize.Y <= 0 then return end
        local aspect = absSize.X / absSize.Y
        local targetHeight = Window._ProjectorSettings.height
        local targetWidth = targetHeight * aspect
        targetWidth = clamp(targetWidth, 4, 24)
        targetHeight = clamp(targetHeight, 3, 16)
        Window._ProjectorObjects.Screen.Size = Vector3.new(targetWidth, targetHeight, 0.1)
        Window._ProjectorSettings.width = targetWidth
        Window._ProjectorSettings.height = targetHeight
    end

    local function SwitchToProjectorMode(distance, width, height, transparency)
        if Window._ProjectorModeEnabled then return end
        
        distance = distance or Window._ProjectorSettings.distance
        width = width or Window._ProjectorSettings.width
        height = height or Window._ProjectorSettings.height
        transparency = transparency or Window._ProjectorSettings.transparency
        
        local projectorScreen = Instance.new("Part")
        projectorScreen.Name = "FengYu_ProjectorScreen"
        projectorScreen.Anchored = true
        projectorScreen.CanCollide = false
        projectorScreen.Locked = true
        projectorScreen.Transparency = transparency
        projectorScreen.Size = Vector3.new(width, height, 0.1)
        projectorScreen.BrickColor = BrickColor.new("White")
        projectorScreen.Material = Enum.Material.SmoothPlastic
        projectorScreen.TopSurface = Enum.SurfaceType.Smooth
        projectorScreen.BottomSurface = Enum.SurfaceType.Smooth
        
        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Adornee = projectorScreen
        selectionBox.Color3 = Theme.Accent1
        selectionBox.LineThickness = 0.08
        selectionBox.Transparency = 0.4
        selectionBox.Parent = projectorScreen
        
        if syn and syn.protect_gui then syn.protect_gui(projectorScreen) end
        projectorScreen.Parent = workspace
        
        local surfaceGui = Instance.new("SurfaceGui")
        surfaceGui.Name = "ProjectorUI"
        surfaceGui.ResetOnSpawn = false
        surfaceGui.Face = Enum.NormalId.Front
        surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        surfaceGui.CanvasSize = Vector2.new(1600, 1200)
        surfaceGui.ClipsDescendants = true
        surfaceGui.AlwaysOnTop = true
        surfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        surfaceGui.Adornee = projectorScreen
        surfaceGui.Parent = projectorScreen
        
        local originalChildren = {}
        for _, child in ipairs(ScreenGui:GetChildren()) do
            if child ~= FloatFrame and child ~= NotificationHolder then
                originalChildren[#originalChildren + 1] = child
            end
        end
        
        for _, child in ipairs(originalChildren) do
            child.Parent = surfaceGui
        end
        
        Window._savedMainFrameSize = MainFrame.Size
        Window._savedMainFramePos = MainFrame.Position
        
        MainFrame.Size = UDim2.new(0, 600, 0, 400)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        addPressEffectToAll(surfaceGui)
        
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 2.5
        pointLight.Range = 20
        pointLight.Color = Theme.Accent1
        pointLight.Parent = projectorScreen
        
        local function updateScreenPosition()
            local character = LocalPlayer.Character
            if not character then return end
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            local forward = rootPart.CFrame.LookVector
            forward = Vector3.new(forward.X, 0, forward.Z).Unit
            local targetPos = rootPart.Position + forward * distance
            targetPos = Vector3.new(targetPos.X, targetPos.Y + 1.2, targetPos.Z)
            
            local lookAtPoint = Vector3.new(rootPart.Position.X, targetPos.Y, rootPart.Position.Z)
            local screenCF = CFrame.lookAt(targetPos, lookAtPoint, Vector3.new(0, 1, 0))
            
            projectorScreen.CFrame = screenCF
        end
        
        updateScreenPosition()
        
        local updateConnection
        updateConnection = RunService.RenderStepped:Connect(function()
            if not projectorScreen.Parent then
                if updateConnection then updateConnection:Disconnect() end
                return
            end
            updateScreenPosition()
        end)
        
        local sizeConnection
        sizeConnection = MainFrame:GetPropertyChangedSignal("Size"):Connect(function()
            if Window._ProjectorSettings.autoSize then
                Window:UpdateProjectorSizeFromUI()
            end
        end)
        task.wait(0.1)
        Window:UpdateProjectorSizeFromUI()
        
        Window._ProjectorModeEnabled = true
        Window._ProjectorObjects = {
            Screen = projectorScreen,
            SurfaceGui = surfaceGui,
            UpdateConnection = updateConnection,
            SizeConnection = sizeConnection,
            Light = pointLight,
            SelectionBox = selectionBox
        }
        
        return true
    end
    
    local function SwitchTo2DMode()
        if not Window._ProjectorModeEnabled then return end
        
        if Window._ProjectorObjects then
            if Window._ProjectorObjects.UpdateConnection then
                Window._ProjectorObjects.UpdateConnection:Disconnect()
            end
            if Window._ProjectorObjects.SizeConnection then
                Window._ProjectorObjects.SizeConnection:Disconnect()
            end
            if Window._ProjectorObjects.SurfaceGui then
                local surfaceGui = Window._ProjectorObjects.SurfaceGui
                for _, child in ipairs(surfaceGui:GetChildren()) do
                    child.Parent = ScreenGui
                end
            end
            if Window._ProjectorObjects.Screen then
                Window._ProjectorObjects.Screen:Destroy()
            end
        end
        
        if Window._savedMainFrameSize then
            MainFrame.Size = Window._savedMainFrameSize
            MainFrame.Position = Window._savedMainFramePos
        else
            MainFrame.Size = UDim2.new(0, 500, 0, 299)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
        
        Window._ProjectorModeEnabled = false
        Window._ProjectorObjects = nil
        
        return true
    end
    
    local function ToggleProjectorMode()
        if Window._ProjectorModeEnabled then
            SwitchTo2DMode()
        else
            SwitchToProjectorMode()
        end
    end

    local SidebarSortIndex = 0
    local FirstTab = true
    local PageContainer = Content

    function Window:TabSection(text)
        SidebarSortIndex = SidebarSortIndex + 1
        local SecLabel = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
        SecLabel.Text = text
        SecLabel.Size = UDim2.new(1, -20, 0, 20)
        SecLabel.BackgroundTransparency = 1
        SecLabel.FontFace = FontBold
        SecLabel.TextSize = 11
        SecLabel.TextXAlignment = Enum.TextXAlignment.Left
        SecLabel.TextTransparency = 0.4
        SecLabel.LayoutOrder = SidebarSortIndex
        SecLabel.Parent = TabScroll
        local Pad = Instance.new("UIPadding")
        Pad.PaddingLeft = UDim.new(0, 5)
        Pad.Parent = SecLabel
    end
    
    function Window:Tab(name, icon, description)
        SidebarSortIndex = SidebarSortIndex + 1
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -10, 0, 35)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.LayoutOrder = SidebarSortIndex
        TabBtn.Parent = TabScroll
        
        local hasText = (name and name ~= "")
        
        local TabIcon = RegisterTheme(Instance.new("ImageLabel"), "ImageColor3", "TextDim")
        TabIcon.Size = UDim2.new(0, 18, 0, 18)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Parent = TabBtn
        local RealIconId = Icons[icon] or icon
        local CleanId = tostring(RealIconId):gsub("rbxassetid://", "")
        TabIcon.Image = "rbxassetid://" .. CleanId
        local TabLabel = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
        TabLabel.Text = name or ""
        TabLabel.Size = UDim2.new(1, -35, 1, 0)
        TabLabel.Position = UDim2.new(0, 32, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.FontFace = FontMain
        TabLabel.TextSize = 13
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabBtn

        if hasText then
            TabIcon.Position = UDim2.new(0, 8, 0.5, -9)
            TabLabel.Visible = true
        else
            TabIcon.Position = UDim2.new(0.5, -9, 0.5, -9)
            TabLabel.Visible = false
        end

        local TabFrame = Instance.new("Frame")
        TabFrame.Size = UDim2.new(1, 0, 1, -70)
        TabFrame.Position = UDim2.new(0, 0, 0, 50)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.Parent = PageContainer
        
        local TopBar = Instance.new("Frame")
        TopBar.Size = UDim2.new(1, 0, 0, 50)
        TopBar.BackgroundTransparency = 1
        TopBar.Parent = TabFrame
        
        local BtnHold = Instance.new("ScrollingFrame")
        BtnHold.Size = UDim2.new(1, 0, 1, 0)
        BtnHold.BackgroundTransparency = 1
        BtnHold.Parent = TopBar
        BtnHold.ScrollBarThickness = 0
        BtnHold.ScrollingDirection = Enum.ScrollingDirection.X
        BtnHold.AutomaticCanvasSize = Enum.AutomaticSize.X
        BtnHold.CanvasSize = UDim2.new(0, 0, 0, 0)
        BtnHold.ClipsDescendants = true
        
        local THL = Instance.new("UIListLayout")
        THL.FillDirection = Enum.FillDirection.Horizontal
        THL.HorizontalAlignment = Enum.HorizontalAlignment.Left
        THL.VerticalAlignment = Enum.VerticalAlignment.Center
        THL.Padding = UDim.new(0, 10)
        THL.Parent = BtnHold
        
        local TPad = Instance.new("UIPadding")
        TPad.PaddingLeft = UDim.new(0, 10)
        TPad.PaddingRight = UDim.new(0, 10)
        TPad.Parent = BtnHold
        
        local ActiveLine = Instance.new("Frame")
        ActiveLine.Size = UDim2.new(0, 0, 0, 3)
        ActiveLine.BackgroundColor3 = Color3.new(1, 1, 1)
        ActiveLine.BorderSizePixel = 0
        ActiveLine.Parent = TopBar
        RegisterGradient(Instance.new("UIGradient"), "Accent1", "Accent2").Parent = ActiveLine
        
        local PagesCont = Instance.new("Frame")
        PagesCont.Size = UDim2.new(1, -40, 1, -60)
        PagesCont.Position = UDim2.new(0, 20, 0, 55)
        PagesCont.BackgroundTransparency = 1
        PagesCont.ClipsDescendants = true
        PagesCont.Parent = TabFrame

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(PageContainer:GetChildren()) do
                if t:IsA("Frame") and t ~= MenuTitle then
                    t.Visible = false
                end
            end
            for _, b in pairs(TabScroll:GetChildren()) do
                if b:IsA("TextButton") then
                    Tween(b.ImageLabel, {ImageColor3 = Theme.TextDim})
                    Tween(b.TextLabel, {TextColor3 = Theme.TextDim})
                end
            end
            TabFrame.Visible = true
            Tween(TabIcon, {ImageColor3 = Theme.Accent2})
            Tween(TabLabel, {TextColor3 = Theme.Accent2})
        end)

        if FirstTab then
            FirstTab = false
            TabFrame.Visible = true
            TabIcon.ImageColor3 = Theme.Accent2
            TabLabel.TextColor3 = Theme.Accent2
        end

        local TabObj = {}
        local FirstPage = true
        
        function TabObj:Page(name, pageIcon)
            local PBtn = Instance.new("TextButton")
            PBtn.Text = ""
            PBtn.AutomaticSize = Enum.AutomaticSize.X
            PBtn.Size = UDim2.new(0, 0, 1, 0)
            PBtn.BackgroundTransparency = 1
            PBtn.Parent = BtnHold
            
            local PBLayout = Instance.new("UIListLayout")
            PBLayout.FillDirection = Enum.FillDirection.Horizontal
            PBLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            PBLayout.Padding = UDim.new(0, 5)
            PBLayout.Parent = PBtn
            
            local Pad = Instance.new("UIPadding")
            Pad.PaddingLeft = UDim.new(0, 10)
            Pad.PaddingRight = UDim.new(0, 10)
            Pad.Parent = PBtn
            
            if pageIcon and Icons[pageIcon] then
                local PIco = RegisterTheme(Instance.new("ImageLabel"), "ImageColor3", "TextDim")
                PIco.Size = UDim2.new(0, 18, 0, 18)
                PIco.BackgroundTransparency = 1
                PIco.Image = Icons[pageIcon]
                PIco.Parent = PBtn
            end
            
            local PTxt = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
            PTxt.Text = name
            PTxt.FontFace = FontMain
            PTxt.TextSize = 16
            PTxt.AutomaticSize = Enum.AutomaticSize.XY
            PTxt.BackgroundTransparency = 1
            PTxt.Parent = PBtn

            local PCont = Instance.new("Frame")
            PCont.Size = UDim2.new(1, 0, 1, 0)
            PCont.BackgroundTransparency = 1
            PCont.Visible = false
            PCont.Parent = PagesCont
            
            local Left = Instance.new("ScrollingFrame")
            Left.Size = UDim2.new(0.49, 0, 1, 0)
            Left.BackgroundTransparency = 1
            Left.ScrollBarThickness = 0
            Left.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Left.CanvasSize = UDim2.new(0, 0, 0, 0)
            Left.Parent = PCont
            
            local Right = Instance.new("ScrollingFrame")
            Right.Size = UDim2.new(0.49, 0, 1, 0)
            Right.Position = UDim2.new(0.51, 0, 0, 0)
            Right.BackgroundTransparency = 1
            Right.ScrollBarThickness = 0
            Right.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Right.CanvasSize = UDim2.new(0, 0, 0, 0)
            Right.Parent = PCont
            
            Instance.new("UIListLayout", Left).Padding = UDim.new(0, 10)
            Instance.new("UIListLayout", Right).Padding = UDim.new(0, 10)

            local function Line(inst)
                if PBtn.Parent then
                    local w = PBtn.AbsoluteSize.X
                    local p = PBtn.AbsolutePosition.X - TopBar.AbsolutePosition.X
                    if p < 0 or p + w > TopBar.AbsoluteSize.X then
                        Tween(ActiveLine, {BackgroundTransparency = 1}, 0.1)
                    else
                        Tween(ActiveLine, {BackgroundTransparency = 0}, 0.1)
                    end
                    if inst then
                        ActiveLine.Size = UDim2.new(0, w, 0, 3)
                        ActiveLine.Position = UDim2.new(0, p, 0, 0)
                    else
                        Tween(ActiveLine, {Size = UDim2.new(0, w, 0, 3), Position = UDim2.new(0, p, 0, 0)})
                    end
                end
            end
            
            BtnHold:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                if PCont.Visible then Line(true) end
            end)
            
            PBtn.MouseButton1Click:Connect(function()
                for _, p in pairs(PagesCont:GetChildren()) do p.Visible = false end
                for _, b in pairs(BtnHold:GetChildren()) do
                    if b:IsA("TextButton") then
                        for _, c in pairs(b:GetChildren()) do
                            if c:IsA("TextLabel") then Tween(c, {TextColor3 = Theme.TextDim}) end
                            if c:IsA("ImageLabel") then Tween(c, {ImageColor3 = Theme.TextDim}) end
                        end
                    end
                end
                PCont.Visible = true
                for _, c in pairs(PBtn:GetChildren()) do
                    if c:IsA("TextLabel") then Tween(c, {TextColor3 = Theme.Text}) end
                    if c:IsA("ImageLabel") then Tween(c, {ImageColor3 = Theme.Text}) end
                end
                Line(false)
            end)
            
            if FirstPage then
                FirstPage = false
                PCont.Visible = true
                for _, c in pairs(PBtn:GetChildren()) do
                    if c:IsA("TextLabel") then c.TextColor3 = Theme.Text end
                    if c:IsA("ImageLabel") then c.ImageColor3 = Theme.Text end
                end
                task.spawn(function()
                    task.wait(0.1)
                    Line(true)
                end)
            end
            
            local function col(s) return s == "Right" and Right or Left end

            local function AddInfoIcon(parent, text)
                local I = RegisterTheme(Instance.new("ImageButton"), "ImageColor3", "TextDim")
                I.Name = "InfoIcon"
                I.Size = UDim2.new(0, 14, 0, 14)
                I.AnchorPoint = Vector2.new(0, 0)
                I.Position = UDim2.new(0, 5, 0, 2)
                I.BackgroundTransparency = 1
                I.Image = Icons["info"] or "rbxassetid://124560466474914"
                I.ZIndex = 20
                I.Parent = parent
                I.MouseEnter:Connect(function() Tween(I, {ImageColor3 = Theme.Accent2}) end)
                I.MouseLeave:Connect(function() Tween(I, {ImageColor3 = Theme.TextDim}) end)
                I.MouseButton1Click:Connect(function() Window:Notification("Info", text, "Info", 4) end)
            end

            local function CreateBase(parent, title, desc, baseH)
                local hasDesc = (desc and desc ~= "")
                local h = baseH
                local F = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Element")
                F.Size = UDim2.new(1, 0, 0, h)
                F.Parent = parent
                Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
                local titleOffset = hasDesc and 25 or 10
                local L = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "Text")
                L.Text = title
                L.Size = UDim2.new(1, -titleOffset - 10, 0, 20)
                L.Position = UDim2.new(0, titleOffset, 0, (baseH > 40) and 2 or 8)
                L.BackgroundTransparency = 1
                L.FontFace = FontMain
                L.TextSize = 14
                L.TextXAlignment = Enum.TextXAlignment.Left
                L.Parent = F
                if hasDesc then AddInfoIcon(F, desc) end
                return F
            end

            local function CreateSection(parent, text, icons, defaultOpen)
                if defaultOpen == nil then defaultOpen = true end
                
                local SectionFrame = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Element")
                SectionFrame.Size = UDim2.new(1, 0, 0, 36)
                SectionFrame.ClipsDescendants = true
                SectionFrame.Parent = parent
                Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 6)

                local HeaderBtn = Instance.new("TextButton")
                HeaderBtn.Size = UDim2.new(1, 0, 0, 36)
                HeaderBtn.BackgroundTransparency = 1
                HeaderBtn.Text = ""
                HeaderBtn.Parent = SectionFrame

                local HeaderText = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "Text")
                HeaderText.Text = text
                HeaderText.Size = UDim2.new(1, -30, 0, 36)
                HeaderText.Position = UDim2.new(0, 10, 0, 0)
                HeaderText.BackgroundTransparency = 1
                HeaderText.FontFace = FontBold
                HeaderText.TextSize = 13
                HeaderText.TextXAlignment = Enum.TextXAlignment.Left
                HeaderText.Parent = HeaderBtn

                local Chevron = RegisterTheme(Instance.new("ImageLabel"), "ImageColor3", "TextDim")
                Chevron.Size = UDim2.new(0, 16, 0, 16)
                Chevron.Position = UDim2.new(1, -26, 0.5, -8)
                Chevron.BackgroundTransparency = 1
                Chevron.Image = Icons["chevron"]
                Chevron.Parent = HeaderBtn

                local ContentFrame = Instance.new("Frame")
                ContentFrame.Size = UDim2.new(1, 0, 0, 0)
                ContentFrame.Position = UDim2.new(0, 0, 0, 36)
                ContentFrame.BackgroundTransparency = 1
                ContentFrame.AutomaticSize = Enum.AutomaticSize.Y
                ContentFrame.Parent = SectionFrame
                
                local Pad = Instance.new("UIPadding")
                Pad.PaddingTop = UDim.new(0, 5)
                Pad.PaddingBottom = UDim.new(0, 10)
                Pad.PaddingLeft = UDim.new(0, 5)
                Pad.PaddingRight = UDim.new(0, 5)
                Pad.Parent = ContentFrame
                
                local List = Instance.new("UIListLayout")
                List.Padding = UDim.new(0, 5)
                List.Parent = ContentFrame

                local expanded = defaultOpen or false
                
                HeaderBtn.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    Tween(Chevron, {Rotation = expanded and 180 or 0})
                    if expanded then
                        SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
                    else
                        SectionFrame.AutomaticSize = Enum.AutomaticSize.None
                        Tween(SectionFrame, {Size = UDim2.new(1, 0, 0, 36)})
                    end
                end)
                
                if expanded then
                    SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
                else
                    Tween(Chevron, {Rotation = 0})
                end

                local SectionElems = {}
                
                function SectionElems:Label(t)
                    local LC = Instance.new("Frame")
                    LC.Size = UDim2.new(1, 0, 0, 25)
                    LC.BackgroundTransparency = 1
                    LC.Parent = ContentFrame
                    local LT = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
                    LT.Text = t
                    LT.Size = UDim2.new(1, -10, 1, 0)
                    LT.Position = UDim2.new(0, 5, 0, 0)
                    LT.BackgroundTransparency = 1
                    LT.FontFace = FontBold
                    LT.TextSize = 13
                    LT.TextXAlignment = Enum.TextXAlignment.Left
                    LT.TextYAlignment = Enum.TextYAlignment.Bottom
                    LT.Parent = LC
                end
                
                function SectionElems:Button(t, desc, cb)
                    local B = CreateBase(ContentFrame, t, desc, 35)
                    local Btn = Instance.new("TextButton")
                    Btn.Size = UDim2.new(1, 0, 1, 0)
                    Btn.BackgroundTransparency = 1
                    Btn.Text = ""
                    Btn.Parent = B
                    Btn.MouseEnter:Connect(function() Tween(B, {BackgroundColor3 = Theme.Sidebar}) end)
                    Btn.MouseLeave:Connect(function() Tween(B, {BackgroundColor3 = Theme.Element}) end)
                    Btn.MouseButton1Down:Connect(function() Tween(B, {Size = UDim2.new(0.98, 0, 0, 33)}) end)
                    Btn.MouseButton1Up:Connect(function()
                        Tween(B, {Size = UDim2.new(1, 0, 0, 35)})
                        pcall(cb)
                    end)
                end
                
                function SectionElems:Keybind(t, f, def, cb, desc)
                    ConfigObjects[f] = {Type = "Keybind", Value = tostring(def or "None"):gsub("Enum.KeyCode.", ""), Set = function(val) end}
                    local B = CreateBase(ContentFrame, t, desc, 35)
                    local BindBtn = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Background")
                    BindBtn.Size = UDim2.new(0, 80, 0, 20)
                    BindBtn.Position = UDim2.new(1, -90, 0, 8)
                    BindBtn.Text = ""
                    BindBtn.Parent = B
                    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
                    local BindTxt = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
                    BindTxt.Text = tostring(def or "None"):gsub("Enum.KeyCode.", "")
                    BindTxt.Size = UDim2.new(1, 0, 1, 0)
                    BindTxt.BackgroundTransparency = 1
                    BindTxt.FontFace = FontMain
                    BindTxt.TextSize = 12
                    BindTxt.Parent = BindBtn
                    local binding = false
                    BindBtn.MouseButton1Click:Connect(function()
                        if binding then return end
                        binding = true
                        BindTxt.Text = "..."
                        local connection
                        connection = UserInputService.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
                                local key = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode or input.UserInputType
                                if key.Name == "Unknown" then return end
                                if key == Enum.KeyCode.Escape then
                                    ConfigObjects[f].Value = "None"
                                    BindTxt.Text = "None"
                                else
                                    ConfigObjects[f].Value = key.Name
                                    BindTxt.Text = key.Name
                                end
                                binding = false
                                connection:Disconnect()
                                pcall(cb, key)
                            end
                        end)
                    end)
                    ConfigObjects[f].Set = function(v)
                        ConfigObjects[f].Value = v and v.Name or "None"
                        BindTxt.Text = ConfigObjects[f].Value
                    end
                end
                
                function SectionElems:Checkbox(t, f, d, desc, cb)
                    local st = false
                    ConfigObjects[f] = {Type = "Toggle", Value = st, Set = function(val) end}
                    local B = CreateBase(ContentFrame, t, desc, 35)
                    local BoxOut = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Background")
                    BoxOut.Size = UDim2.new(0, 20, 0, 20)
                    BoxOut.Position = UDim2.new(1, -30, 0, 8)
                    BoxOut.Parent = B
                    Instance.new("UICorner", BoxOut).CornerRadius = UDim.new(0, 4)
                    local CheckImg = RegisterTheme(Instance.new("ImageLabel"), "ImageColor3", "Text")
                    CheckImg.Size = UDim2.new(0, 14, 0, 14)
                    CheckImg.Position = UDim2.new(0.5, -7, 0.5, -7)
                    CheckImg.BackgroundTransparency = 1
                    CheckImg.Image = Icons["check"]
                    CheckImg.ImageTransparency = 1
                    CheckImg.Parent = BoxOut
                    local BoxGrad = RegisterGradient(Instance.new("UIGradient"), "Accent1", "Accent2")
                    BoxGrad.Parent = BoxOut
                    BoxGrad.Enabled = false
                    local Click = Instance.new("TextButton")
                    Click.Size = UDim2.new(1, 0, 1, 0)
                    Click.BackgroundTransparency = 1
                    Click.Text = ""
                    Click.Parent = B
                    local function Set(b)
                        st = b
                        ConfigObjects[f].Value = st
                        Tween(CheckImg, {ImageTransparency = st and 0 or 1})
                        BoxGrad.Enabled = st
                        Tween(BoxOut, {BackgroundColor3 = st and Theme.Accent1 or Theme.Background})
                        pcall(cb, st)
                    end
                    Click.MouseButton1Click:Connect(function() Set(not st) end)
                    if d then Set(true) end
                    ConfigObjects[f].Set = Set
                end
                
                function SectionElems:Toggle(t, f, d, desc, cb)
                    local st = false
                    ConfigObjects[f] = {Type = "Toggle", Value = st, Set = function(val) end}
                    local B = CreateBase(ContentFrame, t, desc, 35)
                    local SwitchBg = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Background")
                    SwitchBg.Size = UDim2.new(0, 32, 0, 18)
                    SwitchBg.Position = UDim2.new(1, -42, 0, 9)
                    SwitchBg.Parent = B
                    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
                    local SwitchGrad = RegisterGradient(Instance.new("UIGradient"), "Accent1", "Accent2")
                    SwitchGrad.Parent = SwitchBg
                    SwitchGrad.Enabled = false
                    local Circle = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "TextDim")
                    Circle.Size = UDim2.new(0, 14, 0, 14)
                    Circle.Position = UDim2.new(0, 2, 0.5, -7)
                    Circle.Parent = SwitchBg
                    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
                    local Click = Instance.new("TextButton")
                    Click.Size = UDim2.new(1, 0, 1, 0)
                    Click.BackgroundTransparency = 1
                    Click.Text = ""
                    Click.Parent = B
                    local function Set(b)
                        st = b
                        ConfigObjects[f].Value = st
                        SwitchGrad.Enabled = st
                        Tween(Circle, {Position = UDim2.new(st and 1 or 0, st and -16 or 2, 0.5, -7), BackgroundColor3 = st and Theme.Text or Theme.TextDim})
                        Tween(SwitchBg, {BackgroundColor3 = st and Theme.Accent1 or Theme.Background})
                        pcall(cb, st)
                    end
                    Click.MouseButton1Click:Connect(function() Set(not st) end)
                    if d then Set(true) end
                    ConfigObjects[f].Set = Set
                end
                
                function SectionElems:Slider(t, f, min, max, def, cb, desc)
                    local v = def or min
                    ConfigObjects[f] = {Type = "Slider", Value = v, Set = function(val) end}
                    local F = CreateBase(ContentFrame, t, desc, 50)
                    local V = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
                    V.Text = tostring(v)
                    V.Size = UDim2.new(0.3, -10, 0, 20)
                    V.Position = UDim2.new(1, -10, 0, 5)
                    V.AnchorPoint = Vector2.new(1, 0)
                    V.BackgroundTransparency = 1
                    V.TextXAlignment = Enum.TextXAlignment.Right
                    V.Parent = F
                    local B = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Sidebar")
                    B.Size = UDim2.new(1, -20, 0, 6)
                    B.Position = UDim2.new(0, 10, 1, -15)
                    B.Text = ""
                    B.Parent = F
                    Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0)
                    local Fill = Instance.new("Frame")
                    Fill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0)
                    Fill.BackgroundColor3 = Color3.new(1, 1, 1)
                    Fill.Parent = B
                    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
                    local FG = Instance.new("UIGradient")
                    RegisterGradient(FG, "Accent1", "Accent2")
                    FG.Parent = Fill
                    
                    local isDragging = false
                    local function UpdateSlider(input)
                        local pos = input.Position.X
                        local percent = math.clamp((pos - B.AbsolutePosition.X) / B.AbsoluteSize.X, 0, 1)
                        local newVal = math.floor(min + (max - min) * percent)
                        if newVal ~= v then
                            v = newVal
                            ConfigObjects[f].Value = v
                            V.Text = tostring(v)
                            Tween(Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.05)
                            pcall(cb, v)
                        end
                    end

                    B.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            isDragging = true
                            UpdateSlider(input)
                            local con
                            con = RunService.RenderStepped:Connect(function()
                                if not isDragging then con:Disconnect() return end
                                local mouseLoc = UserInputService:GetMouseLocation()
                                UpdateSlider({Position = Vector3.new(mouseLoc.X, mouseLoc.Y, 0)})
                            end)
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            isDragging = false
                        end
                    end)
                    
                    local startP = (def - min) / (max - min)
                    Fill.Size = UDim2.new(startP, 0, 1, 0)
                    ConfigObjects[f].Set = function(n)
                        v = math.clamp(n, min, max)
                        ConfigObjects[f].Value = v
                        V.Text = tostring(v)
                        Tween(Fill, {Size = UDim2.new((v - min) / (max - min), 0, 1, 0)}, 0.1)
                    end
                end
                
                function SectionElems:TextBox(t, f, def, cb, desc)
                    ConfigObjects[f] = {Type = "Textbox", Value = def or "", Set = function(val) end}
                    local C = CreateBase(ContentFrame, t, desc, 45)
                    local B = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Background")
                    B.Size = UDim2.new(0.4, 0, 0, 26)
                    B.Position = UDim2.new(1, -10, 0, 5)
                    B.AnchorPoint = Vector2.new(1, 0)
                    B.Parent = C
                    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4)
                    local In = RegisterTheme(Instance.new("TextBox"), "TextColor3", "Text")
                    In.Size = UDim2.new(1, -10, 1, 0)
                    In.Position = UDim2.new(0, 5, 0, 0)
                    In.BackgroundTransparency = 1
                    In.Text = def or ""
                    In.PlaceholderText = "..."
                    In.TextXAlignment = Enum.TextXAlignment.Left
                    In.Parent = B
                    In.FocusLost:Connect(function()
                        ConfigObjects[f].Value = In.Text
                        pcall(cb, In.Text)
                    end)
                    ConfigObjects[f].Set = function(v)
                        In.Text = v
                        ConfigObjects[f].Value = v
                    end
                end
                
                function SectionElems:Dropdown(t, f, items, cb, desc)
                    local sel = items[1] or "None"
                    ConfigObjects[f] = {Type = "Dropdown", Value = sel, Set = function(val) end}
                    local exp = false
                    local Con = CreateBase(ContentFrame, t, desc, 40)
                    Con.ClipsDescendants = true
                    local B = Instance.new("TextButton")
                    B.Size = UDim2.new(1, 0, 0, 40)
                    B.BackgroundTransparency = 1
                    B.Text = ""
                    B.Parent = Con
                    local S = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
                    S.Text = sel
                    S.Size = UDim2.new(0.5, -40, 0, 20)
                    S.Position = UDim2.new(1, -30, 0, 10)
                    S.AnchorPoint = Vector2.new(1, 0)
                    S.BackgroundTransparency = 1
                    S.FontFace = FontMain
                    S.TextSize = 14
                    S.TextXAlignment = Enum.TextXAlignment.Right
                    S.Parent = B
                    local I = RegisterTheme(Instance.new("ImageLabel"), "ImageColor3", "TextDim")
                    I.Size = UDim2.new(0, 16, 0, 16)
                    I.Position = UDim2.new(1, -26, 0, 12)
                    I.BackgroundTransparency = 1
                    I.Image = Icons["chevron"]
                    I.Parent = B
                    
                    local List = Instance.new("ScrollingFrame")
                    List.Size = UDim2.new(1, -10, 1, -75)
                    List.Position = UDim2.new(0, 5, 0, 45)
                    List.BackgroundTransparency = 1
                    List.BorderSizePixel = 0
                    List.ScrollBarThickness = 2
                    List.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    List.CanvasSize = UDim2.new(0, 0, 0, 0)
                    List.Parent = Con
                    List.Visible = false
                    Instance.new("UIListLayout", List).Padding = UDim.new(0, 2)
                    
                    local function Upd()
                        for _, v in pairs(List:GetChildren()) do
                            if v:IsA("TextButton") then v:Destroy() end
                        end
                        for _, v in pairs(items) do
                            local IB = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Sidebar")
                            IB.Size = UDim2.new(1, 0, 0, 30)
                            IB.Text = "  " .. v
                            RegisterTheme(IB, "TextColor3", sel == v and "Accent2" or "TextDim")
                            IB.FontFace = FontMain
                            IB.TextSize = 14
                            IB.TextXAlignment = Enum.TextXAlignment.Left
                            IB.Parent = List
                            Instance.new("UICorner", IB).CornerRadius = UDim.new(0, 4)
                            if sel == v then
                                local Bar = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Accent2")
                                Bar.Size = UDim2.new(0, 2, 1, -10)
                                Bar.Position = UDim2.new(0, 0, 0, 5)
                                Bar.Parent = IB
                            end
                            IB.MouseButton1Click:Connect(function()
                                sel = v
                                S.Text = v
                                ConfigObjects[f].Value = v
                                exp = false
                                Tween(Con, {Size = UDim2.new(1, 0, 0, 40)})
                                task.delay(0.2, function()
                                    if not exp then List.Visible = false end
                                end)
                                Upd()
                                pcall(cb, v)
                            end)
                        end
                    end
                    
                    B.MouseButton1Click:Connect(function()
                        exp = not exp
                        if exp then List.Visible = true end
                        Tween(I, {Rotation = exp and 180 or 0})
                        Tween(Con, {Size = UDim2.new(1, 0, 0, exp and math.min(220, #items * 32 + 80) or 40)})
                        if not exp then
                            task.delay(0.2, function()
                                if not exp then List.Visible = false end
                            end)
                        end
                    end)
                    Upd()
                    ConfigObjects[f].Set = function(v)
                        sel = v
                        S.Text = v
                        ConfigObjects[f].Value = v
                        Upd()
                        pcall(cb, v)
                    end
                    
                    local self = {}
                    function self.Refresh(newItems)
                        items = newItems
                        if sel and not table.find(items, sel) then
                            sel = items[1] or "None"
                            S.Text = sel
                            ConfigObjects[f].Value = sel
                        end
                        Upd()
                    end
                    function self.Reset()
                        sel = items[1] or "None"
                        S.Text = sel
                        ConfigObjects[f].Value = sel
                        Upd()
                    end
                    return self
                end
                
                function SectionElems:MultiDropdown(t, f, items, cb, desc)
                    local sel = {}
                    ConfigObjects[f] = {Type = "MultiDropdown", Value = sel, Set = function(val) end}
                    local exp = false
                    local Con = CreateBase(ContentFrame, t, desc, 40)
                    Con.ClipsDescendants = true
                    local B = Instance.new("TextButton")
                    B.Size = UDim2.new(1, 0, 0, 40)
                    B.BackgroundTransparency = 1
                    B.Text = ""
                    B.Parent = Con
                    local S = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
                    S.Text = "None"
                    S.Size = UDim2.new(0.5, -40, 0, 20)
                    S.Position = UDim2.new(1, -30, 0, 10)
                    S.AnchorPoint = Vector2.new(1, 0)
                    S.BackgroundTransparency = 1
                    S.FontFace = FontMain
                    S.TextSize = 14
                    S.TextXAlignment = Enum.TextXAlignment.Right
                    S.Parent = B
                    local I = RegisterTheme(Instance.new("ImageLabel"), "ImageColor3", "TextDim")
                    I.Size = UDim2.new(0, 16, 0, 16)
                    I.Position = UDim2.new(1, -26, 0, 12)
                    I.BackgroundTransparency = 1
                    I.Image = Icons["chevron"]
                    I.Parent = B
                    
                    local List = Instance.new("ScrollingFrame")
                    List.Size = UDim2.new(1, -10, 1, -45)
                    List.Position = UDim2.new(0, 5, 0, 45)
                    List.BackgroundTransparency = 1
                    List.BorderSizePixel = 0
                    List.ScrollBarThickness = 2
                    List.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    List.CanvasSize = UDim2.new(0, 0, 0, 0)
                    List.Parent = Con
                    List.Visible = false
                    Instance.new("UIListLayout", List).Padding = UDim.new(0, 2)
                    
                    local function UpdateText()
                        local count = 0
                        local txt = ""
                        for k, v in pairs(sel) do
                            if v then
                                count = count + 1
                                txt = txt .. k .. ", "
                            end
                        end
                        if count == 0 then
                            S.Text = "None"
                        elseif count > 2 then
                            S.Text = count .. " Selected"
                        else
                            S.Text = txt:sub(1, -3)
                        end
                    end
                    
                    local function Upd()
                        for _, v in pairs(List:GetChildren()) do
                            if v:IsA("TextButton") then v:Destroy() end
                        end
                        for _, v in pairs(items) do
                            local IB = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Sidebar")
                            IB.Size = UDim2.new(1, 0, 0, 30)
                            IB.Text = "  " .. v
                            IB.TextColor3 = sel[v] and Theme.Accent2 or Theme.TextDim
                            IB.FontFace = FontMain
                            IB.TextSize = 14
                            IB.TextXAlignment = Enum.TextXAlignment.Left
                            IB.Parent = List
                            Instance.new("UICorner", IB).CornerRadius = UDim.new(0, 4)
                            IB.MouseButton1Click:Connect(function()
                                if sel[v] then
                                    sel[v] = nil
                                else
                                    sel[v] = true
                                end
                                ConfigObjects[f].Value = sel
                                IB.TextColor3 = sel[v] and Theme.Accent2 or Theme.TextDim
                                UpdateText()
                                pcall(cb, sel)
                            end)
                        end
                    end
                    
                    B.MouseButton1Click:Connect(function()
                        exp = not exp
                        if exp then List.Visible = true end
                        Tween(I, {Rotation = exp and 180 or 0})
                        Tween(Con, {Size = UDim2.new(1, 0, 0, exp and math.min(150, #items * 32 + 50) or 40)})
                        if not exp then
                            task.delay(0.2, function()
                                if not exp then List.Visible = false end
                            end)
                        end
                    end)
                    Upd()
                    ConfigObjects[f].Set = function(v)
                        sel = v or {}
                        ConfigObjects[f].Value = sel
                        UpdateText()
                        Upd()
                    end
                    
                    local self = {}
                    function self.Refresh(newItems)
                        items = newItems
                        local newSel = {}
                        for _, v in pairs(items) do
                            if sel[v] then newSel[v] = true end
                        end
                        sel = newSel
                        ConfigObjects[f].Value = sel
                        UpdateText()
                        Upd()
                    end
                    return self
                end
                
                function SectionElems:Paragraph(title, text)
                    local P = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Element")
                    P.Size = UDim2.new(1, 0, 0, 0)
                    P.Parent = ContentFrame
                    P.AutomaticSize = Enum.AutomaticSize.Y
                    Instance.new("UICorner", P).CornerRadius = UDim.new(0, 6)
                    local T = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "Text")
                    T.Text = title
                    T.Size = UDim2.new(1, -20, 0, 20)
                    T.Position = UDim2.new(0, 10, 0, 8)
                    T.BackgroundTransparency = 1
                    T.FontFace = FontBold
                    T.TextSize = 14
                    T.TextXAlignment = Enum.TextXAlignment.Left
                    T.Parent = P
                    local C = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
                    C.Text = text
                    C.Size = UDim2.new(1, -20, 0, 0)
                    C.Position = UDim2.new(0, 10, 0, 32)
                    C.BackgroundTransparency = 1
                    C.FontFace = FontMain
                    C.TextSize = 13
                    C.TextXAlignment = Enum.TextXAlignment.Left
                    C.TextWrapped = true
                    C.AutomaticSize = Enum.AutomaticSize.Y
                    C.Parent = P
                    local Pad = Instance.new("UIPadding")
                    Pad.PaddingBottom = UDim.new(0, 12)
                    Pad.Parent = P
                end
                
                function SectionElems:ColorPicker(t, f, def, alpha, cb, desc)
                    local curColor = def or Color3.fromRGB(255, 255, 255)
                    local curAlpha = alpha or 1
                    local h, s_hsv, v = curColor:ToHSV()
                    local expanded = false
                    local rainbowMode = false
                    ConfigObjects[f] = {Type = "ColorPicker", Value = {Color = curColor, Transparency = curAlpha}, Set = function(val) end}
                    
                    local Main = CreateBase(ContentFrame, t, desc, 40)
                    Main.ClipsDescendants = true
                    
                    local Trigger = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Background")
                    Trigger.Size = UDim2.new(0, 40, 0, 20)
                    Trigger.Position = UDim2.new(1, -70, 0, 10)
                    Trigger.Text = ""
                    Trigger.Parent = Main
                    Instance.new("UICorner", Trigger).CornerRadius = UDim.new(0, 4)
                    
                    local TChecker = Instance.new("ImageLabel")
                    TChecker.Size = UDim2.new(1, 0, 1, 0)
                    TChecker.Image = "rbxassetid://15655263661"
                    TChecker.ScaleType = Enum.ScaleType.Tile
                    TChecker.TileSize = UDim2.new(0, 10, 0, 10)
                    TChecker.Parent = Trigger
                    Instance.new("UICorner", TChecker).CornerRadius = UDim.new(0, 4)
                    local TColor = Instance.new("Frame")
                    TColor.Size = UDim2.new(1, 0, 1, 0)
                    TColor.BackgroundColor3 = curColor
                    TColor.BackgroundTransparency = 1 - curAlpha
                    TColor.Parent = Trigger
                    Instance.new("UICorner", TColor).CornerRadius = UDim.new(0, 4)

                    local Picker = Instance.new("Frame")
                    Picker.Size = UDim2.new(1, -20, 0, 260)
                    Picker.Position = UDim2.new(0, 10, 0, 45)
                    Picker.BackgroundTransparency = 1
                    Picker.Visible = false
                    Picker.Parent = Main
                    
                    local SV = Instance.new("TextButton")
                    SV.Size = UDim2.new(1, -30, 0, 150)
                    SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    SV.Text = ""
                    SV.AutoButtonColor = false
                    SV.Parent = Picker
                    Instance.new("UICorner", SV).CornerRadius = UDim.new(0, 4)
                    local SatLayer = Instance.new("Frame")
                    SatLayer.Size = UDim2.new(1, 0, 1, 0)
                    SatLayer.BackgroundColor3 = Color3.new(1, 1, 1)
                    SatLayer.Parent = SV
                    Instance.new("UICorner", SatLayer).CornerRadius = UDim.new(0, 4)
                    local SatGrad = Instance.new("UIGradient")
                    SatGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))}
                    SatGrad.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
                    SatGrad.Parent = SatLayer
                    local ValLayer = Instance.new("Frame")
                    ValLayer.Size = UDim2.new(1, 0, 1, 0)
                    ValLayer.BackgroundColor3 = Color3.new(0, 0, 0)
                    ValLayer.Parent = SV
                    Instance.new("UICorner", ValLayer).CornerRadius = UDim.new(0, 4)
                    local ValGrad = Instance.new("UIGradient")
                    ValGrad.Rotation = -90
                    ValGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))}
                    ValGrad.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
                    ValGrad.Parent = ValLayer
                    local SVPoint = Instance.new("Frame")
                    SVPoint.Size = UDim2.new(0, 10, 0, 10)
                    SVPoint.BackgroundColor3 = Color3.new(1, 1, 1)
                    SVPoint.Position = UDim2.new(s_hsv, -5, 1 - v, -5)
                    SVPoint.Parent = SV
                    Instance.new("UICorner", SVPoint).CornerRadius = UDim.new(1, 0)
                    Instance.new("UIStroke", SVPoint).Thickness = 2
                    
                    local HueF = Instance.new("TextButton")
                    HueF.Size = UDim2.new(0, 20, 0, 150)
                    HueF.Position = UDim2.new(1, -20, 0, 0)
                    HueF.BackgroundColor3 = Color3.new(1, 1, 1)
                    HueF.Text = ""
                    HueF.AutoButtonColor = false
                    HueF.Parent = Picker
                    Instance.new("UICorner", HueF).CornerRadius = UDim.new(0, 4)
                    local HG = Instance.new("UIGradient")
                    HG.Rotation = 90
                    HG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))}
                    HG.Parent = HueF
                    local HuePoint = Instance.new("Frame")
                    HuePoint.Size = UDim2.new(1, 4, 0, 6)
                    HuePoint.Position = UDim2.new(0, -2, h, -3)
                    HuePoint.BackgroundColor3 = Color3.new(1, 1, 1)
                    HuePoint.Parent = HueF
                    Instance.new("UICorner", HuePoint).CornerRadius = UDim.new(0, 2)
                    
                    local AlphaF = Instance.new("TextButton")
                    AlphaF.Size = UDim2.new(1, 0, 0, 15)
                    AlphaF.Position = UDim2.new(0, 0, 0, 160)
                    AlphaF.BackgroundColor3 = Color3.new(1, 1, 1)
                    AlphaF.Text = ""
                    AlphaF.AutoButtonColor = false
                    AlphaF.Parent = Picker
                    Instance.new("UICorner", AlphaF).CornerRadius = UDim.new(0, 4)
                    local Checker = Instance.new("ImageLabel")
                    Checker.Size = UDim2.new(1, 0, 1, 0)
                    Checker.Image = "rbxassetid://15655263661"
                    Checker.ScaleType = Enum.ScaleType.Tile
                    Checker.TileSize = UDim2.new(0, 10, 0, 10)
                    Checker.Parent = AlphaF
                    Instance.new("UICorner", Checker).CornerRadius = UDim.new(0, 4)
                    local AlphaGrad = Instance.new("Frame")
                    AlphaGrad.Size = UDim2.new(1, 0, 1, 0)
                    AlphaGrad.BackgroundColor3 = Color3.new(1, 1, 1)
                    AlphaGrad.Parent = AlphaF
                    Instance.new("UICorner", AlphaGrad).CornerRadius = UDim.new(0, 4)
                    local AG = Instance.new("UIGradient")
                    AG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, curColor), ColorSequenceKeypoint.new(1, curColor)}
                    AG.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}
                    AG.Parent = AlphaGrad
                    local AlphaPoint = Instance.new("Frame")
                    AlphaPoint.Size = UDim2.new(0, 6, 1, 4)
                    AlphaPoint.Position = UDim2.new(curAlpha, -3, 0, -2)
                    AlphaPoint.BackgroundColor3 = Color3.new(1, 1, 1)
                    AlphaPoint.Parent = AlphaF
                    Instance.new("UICorner", AlphaPoint).CornerRadius = UDim.new(0, 2)
                    
                    local Controls = Instance.new("Frame")
                    Controls.Size = UDim2.new(1, 0, 0, 30)
                    Controls.Position = UDim2.new(0, 0, 0, 185)
                    Controls.BackgroundTransparency = 1
                    Controls.Parent = Picker
                    
                    local function CreateBox(ph, size, pos)
                        local Box = RegisterTheme(Instance.new("TextBox"), "BackgroundColor3", "Background")
                        Box.Size = size
                        Box.Position = pos
                        RegisterTheme(Box, "TextColor3", "Text")
                        Box.FontFace = FontMain
                        Box.TextSize = 12
                        Box.PlaceholderText = ph
                        Box.Parent = Controls
                        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
                        return Box
                    end
                    
                    local HexBox = CreateBox("Hex", UDim2.new(0, 60, 1, 0), UDim2.new(0, 0, 0, 0))
                    local RBox = CreateBox("R", UDim2.new(0, 30, 1, 0), UDim2.new(0, 65, 0, 0))
                    local GBox = CreateBox("G", UDim2.new(0, 30, 1, 0), UDim2.new(0, 100, 0, 0))
                    local BBox = CreateBox("B", UDim2.new(0, 30, 1, 0), UDim2.new(0, 135, 0, 0))
                    local RainbowBtn = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Background")
                    RainbowBtn.Size = UDim2.new(0, 60, 1, 0)
                    RainbowBtn.Position = UDim2.new(1, -60, 0, 0)
                    RainbowBtn.Text = "Rainbow"
                    RegisterTheme(RainbowBtn, "TextColor3", "TextDim")
                    RainbowBtn.FontFace = FontMain
                    RainbowBtn.TextSize = 11
                    RainbowBtn.Parent = Controls
                    Instance.new("UICorner", RainbowBtn).CornerRadius = UDim.new(0, 4)
                    
                    local Actions = Instance.new("Frame")
                    Actions.Size = UDim2.new(1, 0, 0, 20)
                    Actions.Position = UDim2.new(0, 0, 0, 225)
                    Actions.BackgroundTransparency = 1
                    Actions.Parent = Picker
                    local CopyBtn = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Background")
                    CopyBtn.Size = UDim2.new(0.48, 0, 1, 0)
                    CopyBtn.Text = "Copy RGB"
                    RegisterTheme(CopyBtn, "TextColor3", "Text")
                    CopyBtn.FontFace = FontMain
                    CopyBtn.TextSize = 12
                    CopyBtn.Parent = Actions
                    Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 4)
                    local PasteBtn = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Background")
                    PasteBtn.Size = UDim2.new(0.48, 0, 1, 0)
                    PasteBtn.Position = UDim2.new(0.52, 0, 0, 0)
                    PasteBtn.Text = "Paste RGB"
                    RegisterTheme(PasteBtn, "TextColor3", "Text")
                    PasteBtn.FontFace = FontMain
                    PasteBtn.TextSize = 12
                    PasteBtn.Parent = Actions
                    Instance.new("UICorner", PasteBtn).CornerRadius = UDim.new(0, 4)

                    local function Update()
                        curColor = Color3.fromHSV(h, s_hsv, v)
                        ConfigObjects[f].Value = {Color = curColor, Transparency = curAlpha}
                        TColor.BackgroundColor3 = curColor
                        TColor.BackgroundTransparency = 1 - curAlpha
                        SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        AG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, curColor), ColorSequenceKeypoint.new(1, curColor)}
                        if not HexBox:IsFocused() then HexBox.Text = RGBtoHex(curColor) end
                        if not RBox:IsFocused() then RBox.Text = math.floor(curColor.R * 255) end
                        if not GBox:IsFocused() then GBox.Text = math.floor(curColor.G * 255) end
                        if not BBox:IsFocused() then BBox.Text = math.floor(curColor.B * 255) end
                        pcall(cb, curColor, curAlpha)
                    end
                    
                    HexBox.FocusLost:Connect(function()
                        local nc = HexToRGB(HexBox.Text)
                        if nc then
                            h, s_hsv, v = nc:ToHSV()
                            SVPoint.Position = UDim2.new(s_hsv, -5, 1 - v, -5)
                            HuePoint.Position = UDim2.new(0, -2, h, -3)
                            Update()
                        else
                            HexBox.Text = RGBtoHex(curColor)
                        end
                    end)
                    
                    local function UpdateRGB()
                        local r, g, b = tonumber(RBox.Text) or 0, tonumber(GBox.Text) or 0, tonumber(BBox.Text) or 0
                        local nc = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
                        h, s_hsv, v = nc:ToHSV()
                        SVPoint.Position = UDim2.new(s_hsv, -5, 1 - v, -5)
                        HuePoint.Position = UDim2.new(0, -2, h, -3)
                        Update()
                    end
                    
                    RBox.FocusLost:Connect(UpdateRGB)
                    GBox.FocusLost:Connect(UpdateRGB)
                    BBox.FocusLost:Connect(UpdateRGB)
                    
                    RunService.Heartbeat:Connect(function()
                        if rainbowMode and expanded then
                            h = (tick() % 5) / 5
                            HuePoint.Position = UDim2.new(0, -2, h, -3)
                            SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                            Update()
                        end
                    end)
                    
                    RainbowBtn.MouseButton1Click:Connect(function()
                        rainbowMode = not rainbowMode
                        RainbowBtn.TextColor3 = rainbowMode and Theme.Accent2 or Theme.TextDim
                    end)
                    
                    CopyBtn.MouseButton1Click:Connect(function()
                        if setclipboard then
                            setclipboard(math.floor(curColor.R * 255) .. "," .. math.floor(curColor.G * 255) .. "," .. math.floor(curColor.B * 255))
                            Window:Notification("Copied", "RGB copied to clipboard", "Info", 2)
                        end
                    end)
                    
                    PasteBtn.MouseButton1Click:Connect(function()
                        if not getclipboard then return end
                        local str = getclipboard()
                        local r, g, b = str:match("(%d+)%D+(%d+)%D+(%d+)")
                        if r and g and b then
                            RBox.Text = r
                            GBox.Text = g
                            BBox.Text = b
                            UpdateRGB()
                            Window:Notification("Pasted", "Color applied", "Info", 2)
                        else
                            Window:Notification("Error", "Invalid RGB format", "Error", 2)
                        end
                    end)

                    local dSV, dHue, dAlpha = false, false, false
                    SV.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            dSV = true
                            local m = i.Position
                            local rX = math.clamp((m.X - SV.AbsolutePosition.X) / SV.AbsoluteSize.X, 0, 1)
                            local rY = math.clamp((m.Y - SV.AbsolutePosition.Y) / SV.AbsoluteSize.Y, 0, 1)
                            s_hsv = rX
                            v = 1 - rY
                            SVPoint.Position = UDim2.new(s_hsv, -5, 1 - v, -5)
                            Update()
                        end
                    end)
                    HueF.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            dHue = true
                            rainbowMode = false
                            RainbowBtn.TextColor3 = Theme.TextDim
                            local m = i.Position
                            local rY = math.clamp((m.Y - HueF.AbsolutePosition.Y) / HueF.AbsoluteSize.Y, 0, 1)
                            h = rY
                            HuePoint.Position = UDim2.new(0, -2, h, -3)
                            Update()
                        end
                    end)
                    AlphaF.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            dAlpha = true
                            local m = i.Position
                            local rX = math.clamp((m.X - AlphaF.AbsolutePosition.X) / AlphaF.AbsoluteSize.X, 0, 1)
                            curAlpha = rX
                            AlphaPoint.Position = UDim2.new(curAlpha, -3, 0, -2)
                            Update()
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            dSV = false
                            dHue = false
                            dAlpha = false
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                            if dSV then
                                local m = i.Position
                                local rX = math.clamp((m.X - SV.AbsolutePosition.X) / SV.AbsoluteSize.X, 0, 1)
                                local rY = math.clamp((m.Y - SV.AbsolutePosition.Y) / SV.AbsoluteSize.Y, 0, 1)
                                s_hsv = rX
                                v = 1 - rY
                                SVPoint.Position = UDim2.new(s_hsv, -5, 1 - v, -5)
                                Update()
                            end
                            if dHue then
                                rainbowMode = false
                                RainbowBtn.TextColor3 = Theme.TextDim
                                local m = i.Position
                                local rY = math.clamp((m.Y - HueF.AbsolutePosition.Y) / HueF.AbsoluteSize.Y, 0, 1)
                                h = rY
                                HuePoint.Position = UDim2.new(0, -2, h, -3)
                                Update()
                            end
                            if dAlpha then
                                local m = i.Position
                                local rX = math.clamp((m.X - AlphaF.AbsolutePosition.X) / AlphaF.AbsoluteSize.X, 0, 1)
                                curAlpha = rX
                                AlphaPoint.Position = UDim2.new(curAlpha, -3, 0, -2)
                                Update()
                            end
                        end
                    end)
                    
                    Trigger.MouseButton1Click:Connect(function()
                        expanded = not expanded
                        if expanded then Picker.Visible = true end
                        Tween(Main, {Size = UDim2.new(1, 0, 0, expanded and 290 or 40)})
                        if not expanded then
                            task.delay(0.2, function()
                                if not expanded then Picker.Visible = false end
                            end)
                        end
                    end)
                    
                    ConfigObjects[f].Set = function(t)
                        if type(t) == "table" then
                            local nc = t.Color or curColor
                            local na = t.Transparency or curAlpha
                            h, s_hsv, v = nc:ToHSV()
                            curAlpha = na
                            SVPoint.Position = UDim2.new(s_hsv, -5, 1 - v, -5)
                            HuePoint.Position = UDim2.new(0, -2, h, -3)
                            AlphaPoint.Position = UDim2.new(curAlpha, -3, 0, -2)
                            Update()
                        end
                    end
                    Update()
                end
                
                return SectionElems
            end
            
            local function col(s) return s == "Right" and Right or Left end
            
            local Elems = {}
            
            function Elems:Section(text, icons, defaultOpen, side)
                return CreateSection(col(side), text, icons, defaultOpen)
            end
            
            function Elems:Label(t, s) 
                local LC = Instance.new("Frame")
                LC.Size = UDim2.new(1, 0, 0, 25)
                LC.BackgroundTransparency = 1
                LC.Parent = col(s)
                local LT = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
                LT.Text = t
                LT.Size = UDim2.new(1, -10, 1, 0)
                LT.Position = UDim2.new(0, 5, 0, 0)
                LT.BackgroundTransparency = 1
                LT.FontFace = FontBold
                LT.TextSize = 13
                LT.TextXAlignment = Enum.TextXAlignment.Left
                LT.TextYAlignment = Enum.TextYAlignment.Bottom
                LT.Parent = LC
            end
            
            function Elems:Button(t, desc, s, cb)
                local B = CreateBase(col(s), t, desc, 35)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.BackgroundTransparency = 1
                Btn.Text = ""
                Btn.Parent = B
                Btn.MouseEnter:Connect(function() Tween(B, {BackgroundColor3 = Theme.Sidebar}) end)
                Btn.MouseLeave:Connect(function() Tween(B, {BackgroundColor3 = Theme.Element}) end)
                Btn.MouseButton1Down:Connect(function() Tween(B, {Size = UDim2.new(0.98, 0, 0, 33)}) end)
                Btn.MouseButton1Up:Connect(function()
                    Tween(B, {Size = UDim2.new(1, 0, 0, 35)})
                    pcall(cb)
                end)
            end
            
            function Elems:Keybind(t, f, def, s, cb, desc)
                ConfigObjects[f] = {Type = "Keybind", Value = tostring(def or "None"):gsub("Enum.KeyCode.", ""), Set = function(val) end}
                local B = CreateBase(col(s), t, desc, 35)
                local BindBtn = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Background")
                BindBtn.Size = UDim2.new(0, 80, 0, 20)
                BindBtn.Position = UDim2.new(1, -90, 0, 8)
                BindBtn.Text = ""
                BindBtn.Parent = B
                Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
                local BindTxt = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
                BindTxt.Text = tostring(def or "None"):gsub("Enum.KeyCode.", "")
                BindTxt.Size = UDim2.new(1, 0, 1, 0)
                BindTxt.BackgroundTransparency = 1
                BindTxt.FontFace = FontMain
                BindTxt.TextSize = 12
                BindTxt.Parent = BindBtn
                local binding = false
                BindBtn.MouseButton1Click:Connect(function()
                    if binding then return end
                    binding = true
                    BindTxt.Text = "..."
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
                            local key = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode or input.UserInputType
                            if key.Name == "Unknown" then return end
                            if key == Enum.KeyCode.Escape then
                                ConfigObjects[f].Value = "None"
                                BindTxt.Text = "None"
                            else
                                ConfigObjects[f].Value = key.Name
                                BindTxt.Text = key.Name
                            end
                            binding = false
                            connection:Disconnect()
                            pcall(cb, key)
                        end
                    end)
                end)
                ConfigObjects[f].Set = function(v)
                    ConfigObjects[f].Value = v and v.Name or "None"
                    BindTxt.Text = ConfigObjects[f].Value
                end
            end
            
            function Elems:Checkbox(t, f, d, desc, s, cb)
                local st = false
                ConfigObjects[f] = {Type = "Toggle", Value = st, Set = function(val) end}
                local B = CreateBase(col(s), t, desc, 35)
                local BoxOut = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Background")
                BoxOut.Size = UDim2.new(0, 20, 0, 20)
                BoxOut.Position = UDim2.new(1, -30, 0, 8)
                BoxOut.Parent = B
                Instance.new("UICorner", BoxOut).CornerRadius = UDim.new(0, 4)
                local CheckImg = RegisterTheme(Instance.new("ImageLabel"), "ImageColor3", "Text")
                CheckImg.Size = UDim2.new(0, 14, 0, 14)
                CheckImg.Position = UDim2.new(0.5, -7, 0.5, -7)
                CheckImg.BackgroundTransparency = 1
                CheckImg.Image = Icons["check"]
                CheckImg.ImageTransparency = 1
                CheckImg.Parent = BoxOut
                local BoxGrad = RegisterGradient(Instance.new("UIGradient"), "Accent1", "Accent2")
                BoxGrad.Parent = BoxOut
                BoxGrad.Enabled = false
                local Click = Instance.new("TextButton")
                Click.Size = UDim2.new(1, 0, 1, 0)
                Click.BackgroundTransparency = 1
                Click.Text = ""
                Click.Parent = B
                local function Set(b)
                    st = b
                    ConfigObjects[f].Value = st
                    Tween(CheckImg, {ImageTransparency = st and 0 or 1})
                    BoxGrad.Enabled = st
                    Tween(BoxOut, {BackgroundColor3 = st and Theme.Accent1 or Theme.Background})
                    pcall(cb, st)
                end
                Click.MouseButton1Click:Connect(function() Set(not st) end)
                if d then Set(true) end
                ConfigObjects[f].Set = Set
            end
            
            function Elems:Toggle(t, f, d, desc, s, cb)
                local st = false
                ConfigObjects[f] = {Type = "Toggle", Value = st, Set = function(val) end}
                local B = CreateBase(col(s), t, desc, 35)
                local SwitchBg = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Background")
                SwitchBg.Size = UDim2.new(0, 32, 0, 18)
                SwitchBg.Position = UDim2.new(1, -42, 0, 9)
                SwitchBg.Parent = B
                Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
                local SwitchGrad = RegisterGradient(Instance.new("UIGradient"), "Accent1", "Accent2")
                SwitchGrad.Parent = SwitchBg
                SwitchGrad.Enabled = false
                local Circle = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "TextDim")
                Circle.Size = UDim2.new(0, 14, 0, 14)
                Circle.Position = UDim2.new(0, 2, 0.5, -7)
                Circle.Parent = SwitchBg
                Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
                local Click = Instance.new("TextButton")
                Click.Size = UDim2.new(1, 0, 1, 0)
                Click.BackgroundTransparency = 1
                Click.Text = ""
                Click.Parent = B
                local function Set(b)
                    st = b
                    ConfigObjects[f].Value = st
                    SwitchGrad.Enabled = st
                    Tween(Circle, {Position = UDim2.new(st and 1 or 0, st and -16 or 2, 0.5, -7), BackgroundColor3 = st and Theme.Text or Theme.TextDim})
                    Tween(SwitchBg, {BackgroundColor3 = st and Theme.Accent1 or Theme.Background})
                    pcall(cb, st)
                end
                Click.MouseButton1Click:Connect(function() Set(not st) end)
                if d then Set(true) end
                ConfigObjects[f].Set = Set
            end
            
            function Elems:Slider(t, f, min, max, def, s, cb, desc)
                local v = def or min
                ConfigObjects[f] = {Type = "Slider", Value = v, Set = function(val) end}
                local F = CreateBase(col(s), t, desc, 50)
                local V = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
                V.Text = tostring(v)
                V.Size = UDim2.new(0.3, -10, 0, 20)
                V.Position = UDim2.new(1, -10, 0, 5)
                V.AnchorPoint = Vector2.new(1, 0)
                V.BackgroundTransparency = 1
                V.TextXAlignment = Enum.TextXAlignment.Right
                V.Parent = F
                local B = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Sidebar")
                B.Size = UDim2.new(1, -20, 0, 6)
                B.Position = UDim2.new(0, 10, 1, -15)
                B.Text = ""
                B.Parent = F
                Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0)
                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Color3.new(1, 1, 1)
                Fill.Parent = B
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
                local FG = Instance.new("UIGradient")
                RegisterGradient(FG, "Accent1", "Accent2")
                FG.Parent = Fill
                
                local isDragging = false
                local function UpdateSlider(input)
                    local pos = input.Position.X
                    local percent = math.clamp((pos - B.AbsolutePosition.X) / B.AbsoluteSize.X, 0, 1)
                    local newVal = math.floor(min + (max - min) * percent)
                    if newVal ~= v then
                        v = newVal
                        ConfigObjects[f].Value = v
                        V.Text = tostring(v)
                        Tween(Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.05)
                        pcall(cb, v)
                    end
                end

                B.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDragging = true
                        UpdateSlider(input)
                        local con
                        con = RunService.RenderStepped:Connect(function()
                            if not isDragging then con:Disconnect() return end
                            local mouseLoc = UserInputService:GetMouseLocation()
                            UpdateSlider({Position = Vector3.new(mouseLoc.X, mouseLoc.Y, 0)})
                        end)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDragging = false
                    end
                end)
                
                local startP = (def - min) / (max - min)
                Fill.Size = UDim2.new(startP, 0, 1, 0)
                ConfigObjects[f].Set = function(n)
                    v = math.clamp(n, min, max)
                    ConfigObjects[f].Value = v
                    V.Text = tostring(v)
                    Tween(Fill, {Size = UDim2.new((v - min) / (max - min), 0, 1, 0)}, 0.1)
                end
            end
            
            function Elems:TextBox(t, f, def, s, cb, desc)
                ConfigObjects[f] = {Type = "Textbox", Value = def or "", Set = function(val) end}
                local C = CreateBase(col(s), t, desc, 45)
                local B = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Background")
                B.Size = UDim2.new(0.4, 0, 0, 26)
                B.Position = UDim2.new(1, -10, 0, 5)
                B.AnchorPoint = Vector2.new(1, 0)
                B.Parent = C
                Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4)
                local In = RegisterTheme(Instance.new("TextBox"), "TextColor3", "Text")
                In.Size = UDim2.new(1, -10, 1, 0)
                In.Position = UDim2.new(0, 5, 0, 0)
                In.BackgroundTransparency = 1
                In.Text = def or ""
                In.PlaceholderText = "..."
                In.TextXAlignment = Enum.TextXAlignment.Left
                In.Parent = B
                In.FocusLost:Connect(function()
                    ConfigObjects[f].Value = In.Text
                    pcall(cb, In.Text)
                end)
                ConfigObjects[f].Set = function(v)
                    In.Text = v
                    ConfigObjects[f].Value = v
                end
            end
            
            function Elems:Dropdown(t, f, items, s, cb, desc)
                local sel = items[1] or "None"
                ConfigObjects[f] = {Type = "Dropdown", Value = sel, Set = function(val) end}
                local exp = false
                local Con = CreateBase(col(s), t, desc, 40)
                Con.ClipsDescendants = true
                local B = Instance.new("TextButton")
                B.Size = UDim2.new(1, 0, 0, 40)
                B.BackgroundTransparency = 1
                B.Text = ""
                B.Parent = Con
                local S = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
                S.Text = sel
                S.Size = UDim2.new(0.5, -40, 0, 20)
                S.Position = UDim2.new(1, -30, 0, 10)
                S.AnchorPoint = Vector2.new(1, 0)
                S.BackgroundTransparency = 1
                S.FontFace = FontMain
                S.TextSize = 14
                S.TextXAlignment = Enum.TextXAlignment.Right
                S.Parent = B
                local I = RegisterTheme(Instance.new("ImageLabel"), "ImageColor3", "TextDim")
                I.Size = UDim2.new(0, 16, 0, 16)
                I.Position = UDim2.new(1, -26, 0, 12)
                I.BackgroundTransparency = 1
                I.Image = Icons["chevron"]
                I.Parent = B
                
                local List = Instance.new("ScrollingFrame")
                List.Size = UDim2.new(1, -10, 1, -75)
                List.Position = UDim2.new(0, 5, 0, 45)
                List.BackgroundTransparency = 1
                List.BorderSizePixel = 0
                List.ScrollBarThickness = 2
                List.AutomaticCanvasSize = Enum.AutomaticSize.Y
                List.CanvasSize = UDim2.new(0, 0, 0, 0)
                List.Parent = Con
                List.Visible = false
                Instance.new("UIListLayout", List).Padding = UDim.new(0, 2)
                
                local function Upd()
                    for _, v in pairs(List:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end
                    for _, v in pairs(items) do
                        local IB = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Sidebar")
                        IB.Size = UDim2.new(1, 0, 0, 30)
                        IB.Text = "  " .. v
                        RegisterTheme(IB, "TextColor3", sel == v and "Accent2" or "TextDim")
                        IB.FontFace = FontMain
                        IB.TextSize = 14
                        IB.TextXAlignment = Enum.TextXAlignment.Left
                        IB.Parent = List
                        Instance.new("UICorner", IB).CornerRadius = UDim.new(0, 4)
                        if sel == v then
                            local Bar = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Accent2")
                            Bar.Size = UDim2.new(0, 2, 1, -10)
                            Bar.Position = UDim2.new(0, 0, 0, 5)
                            Bar.Parent = IB
                        end
                        IB.MouseButton1Click:Connect(function()
                            sel = v
                            S.Text = v
                            ConfigObjects[f].Value = v
                            exp = false
                            Tween(Con, {Size = UDim2.new(1, 0, 0, 40)})
                            task.delay(0.2, function()
                                if not exp then List.Visible = false end
                            end)
                            Upd()
                            pcall(cb, v)
                        end)
                    end
                end
                
                B.MouseButton1Click:Connect(function()
                    exp = not exp
                    if exp then List.Visible = true end
                    Tween(I, {Rotation = exp and 180 or 0})
                    Tween(Con, {Size = UDim2.new(1, 0, 0, exp and math.min(220, #items * 32 + 80) or 40)})
                    if not exp then
                        task.delay(0.2, function()
                            if not exp then List.Visible = false end
                        end)
                    end
                end)
                Upd()
                ConfigObjects[f].Set = function(v)
                    sel = v
                    S.Text = v
                    ConfigObjects[f].Value = v
                    Upd()
                    pcall(cb, v)
                end
                
                local self = {}
                function self.Refresh(newItems)
                    items = newItems
                    if sel and not table.find(items, sel) then
                        sel = items[1] or "None"
                        S.Text = sel
                        ConfigObjects[f].Value = sel
                    end
                    Upd()
                end
                function self.Reset()
                    sel = items[1] or "None"
                    S.Text = sel
                    ConfigObjects[f].Value = sel
                    Upd()
                end
                return self
            end
            
            function Elems:MultiDropdown(t, f, items, s, cb, desc)
                local sel = {}
                ConfigObjects[f] = {Type = "MultiDropdown", Value = sel, Set = function(val) end}
                local exp = false
                local Con = CreateBase(col(s), t, desc, 40)
                Con.ClipsDescendants = true
                local B = Instance.new("TextButton")
                B.Size = UDim2.new(1, 0, 0, 40)
                B.BackgroundTransparency = 1
                B.Text = ""
                B.Parent = Con
                local S = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
                S.Text = "None"
                S.Size = UDim2.new(0.5, -40, 0, 20)
                S.Position = UDim2.new(1, -30, 0, 10)
                S.AnchorPoint = Vector2.new(1, 0)
                S.BackgroundTransparency = 1
                S.FontFace = FontMain
                S.TextSize = 14
                S.TextXAlignment = Enum.TextXAlignment.Right
                S.Parent = B
                local I = RegisterTheme(Instance.new("ImageLabel"), "ImageColor3", "TextDim")
                I.Size = UDim2.new(0, 16, 0, 16)
                I.Position = UDim2.new(1, -26, 0, 12)
                I.BackgroundTransparency = 1
                I.Image = Icons["chevron"]
                I.Parent = B
                
                local List = Instance.new("ScrollingFrame")
                List.Size = UDim2.new(1, -10, 1, -45)
                List.Position = UDim2.new(0, 5, 0, 45)
                List.BackgroundTransparency = 1
                List.BorderSizePixel = 0
                List.ScrollBarThickness = 2
                List.AutomaticCanvasSize = Enum.AutomaticSize.Y
                List.CanvasSize = UDim2.new(0, 0, 0, 0)
                List.Parent = Con
                List.Visible = false
                Instance.new("UIListLayout", List).Padding = UDim.new(0, 2)
                
                local function UpdateText()
                    local count = 0
                    local txt = ""
                    for k, v in pairs(sel) do
                        if v then
                            count = count + 1
                            txt = txt .. k .. ", "
                        end
                    end
                    if count == 0 then
                        S.Text = "None"
                    elseif count > 2 then
                        S.Text = count .. " Selected"
                    else
                        S.Text = txt:sub(1, -3)
                    end
                end
                
                local function Upd()
                    for _, v in pairs(List:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end
                    for _, v in pairs(items) do
                        local IB = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Sidebar")
                        IB.Size = UDim2.new(1, 0, 0, 30)
                        IB.Text = "  " .. v
                        IB.TextColor3 = sel[v] and Theme.Accent2 or Theme.TextDim
                        IB.FontFace = FontMain
                        IB.TextSize = 14
                        IB.TextXAlignment = Enum.TextXAlignment.Left
                        IB.Parent = List
                        Instance.new("UICorner", IB).CornerRadius = UDim.new(0, 4)
                        IB.MouseButton1Click:Connect(function()
                            if sel[v] then
                                sel[v] = nil
                            else
                                sel[v] = true
                            end
                            ConfigObjects[f].Value = sel
                            IB.TextColor3 = sel[v] and Theme.Accent2 or Theme.TextDim
                            UpdateText()
                            pcall(cb, sel)
                        end)
                    end
                end
                
                B.MouseButton1Click:Connect(function()
                    exp = not exp
                    if exp then List.Visible = true end
                    Tween(I, {Rotation = exp and 180 or 0})
                    Tween(Con, {Size = UDim2.new(1, 0, 0, exp and math.min(150, #items * 32 + 50) or 40)})
                    if not exp then
                        task.delay(0.2, function()
                            if not exp then List.Visible = false end
                        end)
                    end
                end)
                Upd()
                ConfigObjects[f].Set = function(v)
                    sel = v or {}
                    ConfigObjects[f].Value = sel
                    UpdateText()
                    Upd()
                end
                
                local self = {}
                function self.Refresh(newItems)
                    items = newItems
                    local newSel = {}
                    for _, v in pairs(items) do
                        if sel[v] then newSel[v] = true end
                    end
                    sel = newSel
                    ConfigObjects[f].Value = sel
                    UpdateText()
                    Upd()
                end
                return self
            end
            
            function Elems:Paragraph(title, text, s)
                local P = RegisterTheme(Instance.new("Frame"), "BackgroundColor3", "Element")
                P.Size = UDim2.new(1, 0, 0, 0)
                P.Parent = col(s)
                P.AutomaticSize = Enum.AutomaticSize.Y
                Instance.new("UICorner", P).CornerRadius = UDim.new(0, 6)
                local T = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "Text")
                T.Text = title
                T.Size = UDim2.new(1, -20, 0, 20)
                T.Position = UDim2.new(0, 10, 0, 8)
                T.BackgroundTransparency = 1
                T.FontFace = FontBold
                T.TextSize = 14
                T.TextXAlignment = Enum.TextXAlignment.Left
                T.Parent = P
                local C = RegisterTheme(Instance.new("TextLabel"), "TextColor3", "TextDim")
                C.Text = text
                C.Size = UDim2.new(1, -20, 0, 0)
                C.Position = UDim2.new(0, 10, 0, 32)
                C.BackgroundTransparency = 1
                C.FontFace = FontMain
                C.TextSize = 13
                C.TextXAlignment = Enum.TextXAlignment.Left
                C.TextWrapped = true
                C.AutomaticSize = Enum.AutomaticSize.Y
                C.Parent = P
                local Pad = Instance.new("UIPadding")
                Pad.PaddingBottom = UDim.new(0, 12)
                Pad.Parent = P
            end
            
            function Elems:ColorPicker(t, f, def, alpha, s, cb, desc)
                local curColor = def or Color3.fromRGB(255, 255, 255)
                local curAlpha = alpha or 1
                local h, s_hsv, v = curColor:ToHSV()
                local expanded = false
                local rainbowMode = false
                ConfigObjects[f] = {Type = "ColorPicker", Value = {Color = curColor, Transparency = curAlpha}, Set = function(val) end}
                
                local Main = CreateBase(col(s), t, desc, 40)
                Main.ClipsDescendants = true
                
                local Trigger = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Background")
                Trigger.Size = UDim2.new(0, 40, 0, 20)
                Trigger.Position = UDim2.new(1, -70, 0, 10)
                Trigger.Text = ""
                Trigger.Parent = Main
                Instance.new("UICorner", Trigger).CornerRadius = UDim.new(0, 4)
                
                local TChecker = Instance.new("ImageLabel")
                TChecker.Size = UDim2.new(1, 0, 1, 0)
                TChecker.Image = "rbxassetid://15655263661"
                TChecker.ScaleType = Enum.ScaleType.Tile
                TChecker.TileSize = UDim2.new(0, 10, 0, 10)
                TChecker.Parent = Trigger
                Instance.new("UICorner", TChecker).CornerRadius = UDim.new(0, 4)
                local TColor = Instance.new("Frame")
                TColor.Size = UDim2.new(1, 0, 1, 0)
                TColor.BackgroundColor3 = curColor
                TColor.BackgroundTransparency = 1 - curAlpha
                TColor.Parent = Trigger
                Instance.new("UICorner", TColor).CornerRadius = UDim.new(0, 4)

                local Picker = Instance.new("Frame")
                Picker.Size = UDim2.new(1, -20, 0, 260)
                Picker.Position = UDim2.new(0, 10, 0, 45)
                Picker.BackgroundTransparency = 1
                Picker.Visible = false
                Picker.Parent = Main
                
                local SV = Instance.new("TextButton")
                SV.Size = UDim2.new(1, -30, 0, 150)
                SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                SV.Text = ""
                SV.AutoButtonColor = false
                SV.Parent = Picker
                Instance.new("UICorner", SV).CornerRadius = UDim.new(0, 4)
                local SatLayer = Instance.new("Frame")
                SatLayer.Size = UDim2.new(1, 0, 1, 0)
                SatLayer.BackgroundColor3 = Color3.new(1, 1, 1)
                SatLayer.Parent = SV
                Instance.new("UICorner", SatLayer).CornerRadius = UDim.new(0, 4)
                local SatGrad = Instance.new("UIGradient")
                SatGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))}
                SatGrad.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
                SatGrad.Parent = SatLayer
                local ValLayer = Instance.new("Frame")
                ValLayer.Size = UDim2.new(1, 0, 1, 0)
                ValLayer.BackgroundColor3 = Color3.new(0, 0, 0)
                ValLayer.Parent = SV
                Instance.new("UICorner", ValLayer).CornerRadius = UDim.new(0, 4)
                local ValGrad = Instance.new("UIGradient")
                ValGrad.Rotation = -90
                ValGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))}
                ValGrad.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
                ValGrad.Parent = ValLayer
                local SVPoint = Instance.new("Frame")
                SVPoint.Size = UDim2.new(0, 10, 0, 10)
                SVPoint.BackgroundColor3 = Color3.new(1, 1, 1)
                SVPoint.Position = UDim2.new(s_hsv, -5, 1 - v, -5)
                SVPoint.Parent = SV
                Instance.new("UICorner", SVPoint).CornerRadius = UDim.new(1, 0)
                Instance.new("UIStroke", SVPoint).Thickness = 2
                
                local HueF = Instance.new("TextButton")
                HueF.Size = UDim2.new(0, 20, 0, 150)
                HueF.Position = UDim2.new(1, -20, 0, 0)
                HueF.BackgroundColor3 = Color3.new(1, 1, 1)
                HueF.Text = ""
                HueF.AutoButtonColor = false
                HueF.Parent = Picker
                Instance.new("UICorner", HueF).CornerRadius = UDim.new(0, 4)
                local HG = Instance.new("UIGradient")
                HG.Rotation = 90
                HG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))}
                HG.Parent = HueF
                local HuePoint = Instance.new("Frame")
                HuePoint.Size = UDim2.new(1, 4, 0, 6)
                HuePoint.Position = UDim2.new(0, -2, h, -3)
                HuePoint.BackgroundColor3 = Color3.new(1, 1, 1)
                HuePoint.Parent = HueF
                Instance.new("UICorner", HuePoint).CornerRadius = UDim.new(0, 2)
                
                local AlphaF = Instance.new("TextButton")
                AlphaF.Size = UDim2.new(1, 0, 0, 15)
                AlphaF.Position = UDim2.new(0, 0, 0, 160)
                AlphaF.BackgroundColor3 = Color3.new(1, 1, 1)
                AlphaF.Text = ""
                AlphaF.AutoButtonColor = false
                AlphaF.Parent = Picker
                Instance.new("UICorner", AlphaF).CornerRadius = UDim.new(0, 4)
                local Checker = Instance.new("ImageLabel")
                Checker.Size = UDim2.new(1, 0, 1, 0)
                Checker.Image = "rbxassetid://15655263661"
                Checker.ScaleType = Enum.ScaleType.Tile
                Checker.TileSize = UDim2.new(0, 10, 0, 10)
                Checker.Parent = AlphaF
                Instance.new("UICorner", Checker).CornerRadius = UDim.new(0, 4)
                local AlphaGrad = Instance.new("Frame")
                AlphaGrad.Size = UDim2.new(1, 0, 1, 0)
                AlphaGrad.BackgroundColor3 = Color3.new(1, 1, 1)
                AlphaGrad.Parent = AlphaF
                Instance.new("UICorner", AlphaGrad).CornerRadius = UDim.new(0, 4)
                local AG = Instance.new("UIGradient")
                AG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, curColor), ColorSequenceKeypoint.new(1, curColor)}
                AG.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}
                AG.Parent = AlphaGrad
                local AlphaPoint = Instance.new("Frame")
                AlphaPoint.Size = UDim2.new(0, 6, 1, 4)
                AlphaPoint.Position = UDim2.new(curAlpha, -3, 0, -2)
                AlphaPoint.BackgroundColor3 = Color3.new(1, 1, 1)
                AlphaPoint.Parent = AlphaF
                Instance.new("UICorner", AlphaPoint).CornerRadius = UDim.new(0, 2)
                
                local Controls = Instance.new("Frame")
                Controls.Size = UDim2.new(1, 0, 0, 30)
                Controls.Position = UDim2.new(0, 0, 0, 185)
                Controls.BackgroundTransparency = 1
                Controls.Parent = Picker
                
                local function CreateBox(ph, size, pos)
                    local Box = RegisterTheme(Instance.new("TextBox"), "BackgroundColor3", "Background")
                    Box.Size = size
                    Box.Position = pos
                    RegisterTheme(Box, "TextColor3", "Text")
                    Box.FontFace = FontMain
                    Box.TextSize = 12
                    Box.PlaceholderText = ph
                    Box.Parent = Controls
                    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
                    return Box
                end
                
                local HexBox = CreateBox("Hex", UDim2.new(0, 60, 1, 0), UDim2.new(0, 0, 0, 0))
                local RBox = CreateBox("R", UDim2.new(0, 30, 1, 0), UDim2.new(0, 65, 0, 0))
                local GBox = CreateBox("G", UDim2.new(0, 30, 1, 0), UDim2.new(0, 100, 0, 0))
                local BBox = CreateBox("B", UDim2.new(0, 30, 1, 0), UDim2.new(0, 135, 0, 0))
                local RainbowBtn = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Background")
                RainbowBtn.Size = UDim2.new(0, 60, 1, 0)
                RainbowBtn.Position = UDim2.new(1, -60, 0, 0)
                RainbowBtn.Text = "Rainbow"
                RegisterTheme(RainbowBtn, "TextColor3", "TextDim")
                RainbowBtn.FontFace = FontMain
                RainbowBtn.TextSize = 11
                RainbowBtn.Parent = Controls
                Instance.new("UICorner", RainbowBtn).CornerRadius = UDim.new(0, 4)
                
                local Actions = Instance.new("Frame")
                Actions.Size = UDim2.new(1, 0, 0, 20)
                Actions.Position = UDim2.new(0, 0, 0, 225)
                Actions.BackgroundTransparency = 1
                Actions.Parent = Picker
                local CopyBtn = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Background")
                CopyBtn.Size = UDim2.new(0.48, 0, 1, 0)
                CopyBtn.Text = "Copy RGB"
                RegisterTheme(CopyBtn, "TextColor3", "Text")
                CopyBtn.FontFace = FontMain
                CopyBtn.TextSize = 12
                CopyBtn.Parent = Actions
                Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 4)
                local PasteBtn = RegisterTheme(Instance.new("TextButton"), "BackgroundColor3", "Background")
                PasteBtn.Size = UDim2.new(0.48, 0, 1, 0)
                PasteBtn.Position = UDim2.new(0.52, 0, 0, 0)
                PasteBtn.Text = "Paste RGB"
                RegisterTheme(PasteBtn, "TextColor3", "Text")
                PasteBtn.FontFace = FontMain
                PasteBtn.TextSize = 12
                PasteBtn.Parent = Actions
                Instance.new("UICorner", PasteBtn).CornerRadius = UDim.new(0, 4)

                local function Update()
                    curColor = Color3.fromHSV(h, s_hsv, v)
                    ConfigObjects[f].Value = {Color = curColor, Transparency = curAlpha}
                    TColor.BackgroundColor3 = curColor
                    TColor.BackgroundTransparency = 1 - curAlpha
                    SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    AG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, curColor), ColorSequenceKeypoint.new(1, curColor)}
                    if not HexBox:IsFocused() then HexBox.Text = RGBtoHex(curColor) end
                    if not RBox:IsFocused() then RBox.Text = math.floor(curColor.R * 255) end
                    if not GBox:IsFocused() then GBox.Text = math.floor(curColor.G * 255) end
                    if not BBox:IsFocused() then BBox.Text = math.floor(curColor.B * 255) end
                    pcall(cb, curColor, curAlpha)
                end
                
                HexBox.FocusLost:Connect(function()
                    local nc = HexToRGB(HexBox.Text)
                    if nc then
                        h, s_hsv, v = nc:ToHSV()
                        SVPoint.Position = UDim2.new(s_hsv, -5, 1 - v, -5)
                        HuePoint.Position = UDim2.new(0, -2, h, -3)
                        Update()
                    else
                        HexBox.Text = RGBtoHex(curColor)
                    end
                end)
                
                local function UpdateRGB()
                    local r, g, b = tonumber(RBox.Text) or 0, tonumber(GBox.Text) or 0, tonumber(BBox.Text) or 0
                    local nc = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
                    h, s_hsv, v = nc:ToHSV()
                    SVPoint.Position = UDim2.new(s_hsv, -5, 1 - v, -5)
                    HuePoint.Position = UDim2.new(0, -2, h, -3)
                    Update()
                end
                
                RBox.FocusLost:Connect(UpdateRGB)
                GBox.FocusLost:Connect(UpdateRGB)
                BBox.FocusLost:Connect(UpdateRGB)
                
                RunService.Heartbeat:Connect(function()
                    if rainbowMode and expanded then
                        h = (tick() % 5) / 5
                        HuePoint.Position = UDim2.new(0, -2, h, -3)
                        SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        Update()
                    end
                end)
                
                RainbowBtn.MouseButton1Click:Connect(function()
                    rainbowMode = not rainbowMode
                    RainbowBtn.TextColor3 = rainbowMode and Theme.Accent2 or Theme.TextDim
                end)
                
                CopyBtn.MouseButton1Click:Connect(function()
                    if setclipboard then
                        setclipboard(math.floor(curColor.R * 255) .. "," .. math.floor(curColor.G * 255) .. "," .. math.floor(curColor.B * 255))
                        Window:Notification("Copied", "RGB copied to clipboard", "Info", 2)
                    end
                end)
                
                PasteBtn.MouseButton1Click:Connect(function()
                    if not getclipboard then return end
                    local str = getclipboard()
                    local r, g, b = str:match("(%d+)%D+(%d+)%D+(%d+)")
                    if r and g and b then
                        RBox.Text = r
                        GBox.Text = g
                        BBox.Text = b
                        UpdateRGB()
                        Window:Notification("Pasted", "Color applied", "Info", 2)
                    else
                        Window:Notification("Error", "Invalid RGB format", "Error", 2)
                    end
                end)

                local dSV, dHue, dAlpha = false, false, false
                SV.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dSV = true
                        local m = i.Position
                        local rX = math.clamp((m.X - SV.AbsolutePosition.X) / SV.AbsoluteSize.X, 0, 1)
                        local rY = math.clamp((m.Y - SV.AbsolutePosition.Y) / SV.AbsoluteSize.Y, 0, 1)
                        s_hsv = rX
                        v = 1 - rY
                        SVPoint.Position = UDim2.new(s_hsv, -5, 1 - v, -5)
                        Update()
                    end
                end)
                HueF.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dHue = true
                        rainbowMode = false
                        RainbowBtn.TextColor3 = Theme.TextDim
                        local m = i.Position
                        local rY = math.clamp((m.Y - HueF.AbsolutePosition.Y) / HueF.AbsoluteSize.Y, 0, 1)
                        h = rY
                        HuePoint.Position = UDim2.new(0, -2, h, -3)
                        Update()
                    end
                end)
                AlphaF.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dAlpha = true
                        local m = i.Position
                        local rX = math.clamp((m.X - AlphaF.AbsolutePosition.X) / AlphaF.AbsoluteSize.X, 0, 1)
                        curAlpha = rX
                        AlphaPoint.Position = UDim2.new(curAlpha, -3, 0, -2)
                        Update()
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dSV = false
                        dHue = false
                        dAlpha = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                        if dSV then
                            local m = i.Position
                            local rX = math.clamp((m.X - SV.AbsolutePosition.X) / SV.AbsoluteSize.X, 0, 1)
                            local rY = math.clamp((m.Y - SV.AbsolutePosition.Y) / SV.AbsoluteSize.Y, 0, 1)
                            s_hsv = rX
                            v = 1 - rY
                            SVPoint.Position = UDim2.new(s_hsv, -5, 1 - v, -5)
                            Update()
                        end
                        if dHue then
                            rainbowMode = false
                            RainbowBtn.TextColor3 = Theme.TextDim
                            local m = i.Position
                            local rY = math.clamp((m.Y - HueF.AbsolutePosition.Y) / HueF.AbsoluteSize.Y, 0, 1)
                            h = rY
                            HuePoint.Position = UDim2.new(0, -2, h, -3)
                            Update()
                        end
                        if dAlpha then
                            local m = i.Position
                            local rX = math.clamp((m.X - AlphaF.AbsolutePosition.X) / AlphaF.AbsoluteSize.X, 0, 1)
                            curAlpha = rX
                            AlphaPoint.Position = UDim2.new(curAlpha, -3, 0, -2)
                            Update()
                        end
                    end
                end)
                
                Trigger.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    if expanded then Picker.Visible = true end
                    Tween(Main, {Size = UDim2.new(1, 0, 0, expanded and 290 or 40)})
                    if not expanded then
                        task.delay(0.2, function()
                            if not expanded then Picker.Visible = false end
                        end)
                    end
                end)
                
                ConfigObjects[f].Set = function(t)
                    if type(t) == "table" then
                        local nc = t.Color or curColor
                        local na = t.Transparency or curAlpha
                        h, s_hsv, v = nc:ToHSV()
                        curAlpha = na
                        SVPoint.Position = UDim2.new(s_hsv, -5, 1 - v, -5)
                        HuePoint.Position = UDim2.new(0, -2, h, -3)
                        AlphaPoint.Position = UDim2.new(curAlpha, -3, 0, -2)
                        Update()
                    end
                end
                Update()
            end
            
            return Elems
        end
        
        return TabObj
    end

    function Window:DualTab(name, icon)
        return Window:Tab(name, icon)
    end

    function Window:ConfigSystem()
        local SettingsTab = self:Tab("Settings", "settings")
        local CfgPage = SettingsTab:Page("Configs", "folder")
        local ThemePage = SettingsTab:Page("Themes", "paint-bucket")
        
        local selConfig = ""
        local configDropdown = nil
        local configItems = {}
        
        local function GetConfigs()
            local files = listfiles(ConfigFolder)
            local names = {}
            for _, file in ipairs(files) do
                local name = file:gsub(ConfigFolder .. "\\", ""):gsub(ConfigFolder .. "/", ""):gsub(".json", "")
                table.insert(names, name)
            end
            return names
        end
        
        local function RefreshConfigs()
            local configs = GetConfigs()
            if configDropdown and ConfigObjects["ConfigList"] then
                configDropdown.Refresh(configs)
            end
        end
        
        local function SaveConfig(name)
            if not name or name == "" then
                Window:Notification("Config", "Invalid Config Name", "Error", 3)
                return
            end
            local data = {}
            for flag, obj in pairs(ConfigObjects) do
                if obj and obj.Value ~= nil then
                    if typeof(obj.Value) == "Color3" then
                        data[flag] = {Type = "Color3", R = obj.Value.R, G = obj.Value.G, B = obj.Value.B}
                    elseif type(obj.Value) == "table" and obj.Value.Color then
                        data[flag] = {Type = "CP", R = obj.Value.Color.R, G = obj.Value.Color.G, B = obj.Value.Color.B, A = obj.Value.Transparency}
                    elseif type(obj.Value) == "table" then
                        data[flag] = obj.Value
                    else
                        data[flag] = obj.Value
                    end
                end
            end
            local json = HttpService:JSONEncode(data)
            if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
            writefile(ConfigFolder .. "/" .. name .. ".json", json)
            Window:Notification("Config", "Saved config: " .. name, "Success", 3)
            RefreshConfigs()
        end
        
        local function LoadConfig(name)
            if not name or name == "" then
                Window:Notification("Config", "Config not found", "Error", 3)
                return
            end
            local path = ConfigFolder .. "/" .. name .. ".json"
            if not isfile(path) then
                Window:Notification("Config", "Config not found", "Error", 3)
                return
            end
            local content = readfile(path)
            local success, data = pcall(HttpService.JSONDecode, HttpService, content)
            if not success then
                Window:Notification("Config", "Decode Error", "Error", 3)
                return
            end
            for flag, value in pairs(data) do
                if ConfigObjects[flag] and ConfigObjects[flag].Set then
                    if type(value) == "table" and value.Type == "Color3" then
                        ConfigObjects[flag].Set(Color3.new(value.R, value.G, value.B))
                    elseif type(value) == "table" and value.Type == "CP" then
                        ConfigObjects[flag].Set({Color = Color3.new(value.R, value.G, value.B), Transparency = value.A})
                    else
                        ConfigObjects[flag].Set(value)
                    end
                end
            end
            Window:Notification("Config", "Loaded config: " .. name, "Success", 3)
        end
        
        local function DeleteConfig(name)
            if not name or name == "" then return end
            local path = ConfigFolder .. "/" .. name .. ".json"
            if isfile(path) then
                delfile(path)
                Window:Notification("Config", "Deleted config: " .. name, "Success", 3)
                RefreshConfigs()
            end
        end
        
        local configs = GetConfigs()
        configDropdown = CfgPage:Dropdown("Available Configs", "ConfigList", configs, "Left", function(v) selConfig = v end)
        CfgPage:TextBox("New Config Name", "ConfigName", "", "Left", function(v) selConfig = v end)
        CfgPage:Button("Save Config", "Saves current settings", "Left", function() SaveConfig(selConfig) end)
        CfgPage:Button("Load Config", "Loads selected config", "Left", function() LoadConfig(selConfig) end)
        CfgPage:Button("Delete Config", "Deletes selected config", "Right", function() DeleteConfig(selConfig) end)
        CfgPage:Button("Refresh List", "Reloads config list", "Right", function() RefreshConfigs() end)

        local presets = {}
        for k, v in pairs(ThemePresets) do
            table.insert(presets, k)
        end
        table.sort(presets)
        
        ThemePage:Dropdown("Theme Presets", "ThemePreset", presets, "Left", function(v) UpdateTheme(v) end)
    end

    function Window:SetKeybind(key) 
        Keybind = key 
    end
    
    function Window:Destroy() 
        ScreenGui:Destroy() 
    end
    
    function Window:SetSubtitle(newSubtitle)
        for _, child in ipairs(Content:GetChildren()) do
            if child:IsA("TextLabel") and child ~= MenuTitle then
                child.Text = newSubtitle
                break
            end
        end
    end

    function Window:SetProjectorDistance(distance)
        distance = clamp(distance, 3, 20)
        Window._ProjectorSettings.distance = distance
        if Window._ProjectorModeEnabled and Window._ProjectorObjects and Window._ProjectorObjects.Screen then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local rootPart = character.HumanoidRootPart
                local forward = rootPart.CFrame.LookVector
                forward = Vector3.new(forward.X, 0, forward.Z).Unit
                local targetPos = rootPart.Position + forward * distance
                targetPos = Vector3.new(targetPos.X, targetPos.Y + 1.2, targetPos.Z)
                local lookAtPoint = Vector3.new(rootPart.Position.X, targetPos.Y, rootPart.Position.Z)
                local screenCF = CFrame.lookAt(targetPos, lookAtPoint, Vector3.new(0, 1, 0))
                Window._ProjectorObjects.Screen.CFrame = screenCF
            end
        end
    end
    
    function Window:SetProjectorSize(width, height)
        width = clamp(width, 4, 24)
        height = clamp(height, 3, 16)
        Window._ProjectorSettings.width = width
        Window._ProjectorSettings.height = height
        Window._ProjectorSettings.autoSize = false
        if Window._ProjectorModeEnabled and Window._ProjectorObjects and Window._ProjectorObjects.Screen then
            Window._ProjectorObjects.Screen.Size = Vector3.new(width, height, 0.1)
        end
    end
    
    function Window:SetProjectorTransparency(transparency)
        transparency = clamp(transparency, 0, 0.8)
        Window._ProjectorSettings.transparency = transparency
        if Window._ProjectorModeEnabled and Window._ProjectorObjects and Window._ProjectorObjects.Screen then
            Window._ProjectorObjects.Screen.Transparency = transparency
        end
    end
    
    function Window:EnableProjectorMode(distance, width, height, transparency)
        return SwitchToProjectorMode(distance, width, height, transparency)
    end
    
    function Window:DisableProjectorMode()
        return SwitchTo2DMode()
    end
    
    function Window:ToggleProjectorMode()
        return ToggleProjectorMode()
    end
    
    function Window:IsProjectorMode()
        return Window._ProjectorModeEnabled
    end

    task.spawn(function()
        task.wait(0.5)
        Window:Notification("Welcome", Title .. " has been loaded!", "Success", 3)
    end)

    return Window
end

return Fenglib