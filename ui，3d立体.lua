local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Fenglib = {}
local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow"
local RainbowSpeed = 1.0
local Registry = {}
local ConfigObjects = {}
local ThemeListeners = {}
local ActiveRainbowConnections = {}

local function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

local function safeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

local function startNeonFlowEffect(object, property, speed)
    speed = speed or 0.008
    local hue = 0
    local connection
    local isActive = true
    connection = RunService.Heartbeat:Connect(function()
        if not isActive or not object or not object.Parent then
            if connection then connection:Disconnect() end
            return
        end
        hue = (hue + speed) % 1
        local r = math.sin(hue * 3 + 0) * 0.3 + 0.7
        local g = math.sin(hue * 3 + 2) * 0.1
        local b = math.sin(hue * 3 + 4) * 0.1
        pcall(function() object[property] = Color3.new(r, g, b) end)
    end)
    table.insert(ActiveRainbowConnections, connection)
    return connection
end

local function stopAllRainbowEffects()
    for _, conn in ipairs(ActiveRainbowConnections) do
        pcall(function() conn:Disconnect() end)
    end
    ActiveRainbowConnections = {}
end

local Themes = {
    Dark   = {Main = Color3.fromRGB(13, 13, 13), Top = Color3.fromRGB(28, 28, 30), Text = Color3.fromRGB(240, 240, 245), Accent = Color3.fromRGB(80, 140, 255), Stroke = Color3.fromRGB(45, 45, 48)},
    White  = {Main = Color3.fromRGB(243, 243, 243), Top = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(20, 20, 20), Accent = Color3.fromRGB(0, 100, 210), Stroke = Color3.fromRGB(220, 220, 225)},
    Purple = {Main = Color3.fromRGB(18, 15, 22), Top = Color3.fromRGB(30, 25, 35), Text = Color3.fromRGB(245, 240, 255), Accent = Color3.fromRGB(160, 90, 255), Stroke = Color3.fromRGB(50, 45, 60)},
    Blue   = {Main = Color3.fromRGB(12, 18, 28), Top = Color3.fromRGB(25, 32, 45), Text = Color3.fromRGB(240, 245, 255), Accent = Color3.fromRGB(70, 130, 255), Stroke = Color3.fromRGB(45, 55, 75)},
    Red    = {Main = Color3.fromRGB(22, 12, 12), Top = Color3.fromRGB(35, 20, 20), Text = Color3.fromRGB(255, 240, 240), Accent = Color3.fromRGB(255, 80, 80), Stroke = Color3.fromRGB(60, 40, 40)},
    Yellow = {Main = Color3.fromRGB(22, 22, 12), Top = Color3.fromRGB(35, 35, 20), Text = Color3.fromRGB(255, 255, 240), Accent = Color3.fromRGB(255, 200, 80), Stroke = Color3.fromRGB(60, 60, 40)},
    Green  = {Main = Color3.fromRGB(12, 22, 15), Top = Color3.fromRGB(20, 35, 25), Text = Color3.fromRGB(240, 255, 245), Accent = Color3.fromRGB(60, 220, 130), Stroke = Color3.fromRGB(40, 60, 50)},
}
local CurrentTheme = Themes.Dark

local function AddToRegistry(obj, prop, themeKey)
    table.insert(Registry, {Object = obj, Property = prop, Type = themeKey})
    pcall(function() obj[prop] = CurrentTheme[themeKey] end)
end

local function Tween(obj, props, time)
    if not obj then return end
    local success, err = pcall(function()
        local tween = TweenService:Create(obj, TweenInfo.new(time or 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
        tween:Play()
    end)
end

function Fenglib:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        for _, r in pairs(Registry) do
            if r.Object and r.Object.Parent then
                Tween(r.Object, {[r.Property] = CurrentTheme[r.Type]})
            end
        end
        for _, fn in pairs(ThemeListeners) do
            pcall(fn)
        end
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
                data[flag] = obj.Value
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
            pcall(function() ConfigObjects[flag].Set(val) end)
        end
    end
    Fenglib._loading = false

    return true
end

function Fenglib:CreateWindow(Config)
    local Window = {}
    local Title = Config.Title or "FengYu"
    local Subtitle = Config.Subtitle
    local Keybind = Config.Keybind
    local IconAsset = Config.Icon
    local DefaultWidth = Config.DefaultWidth or 700
    local DefaultHeight = Config.DefaultHeight or 500

    Window.RootFolder = Title
    Window.ConfigFolder = Title.."/Config"
    Window.CurrentConfig = ""

    if Config.Theme then
        if type(Config.Theme) == "string" then
            if Themes[Config.Theme] then
                CurrentTheme = Themes[Config.Theme]
            end
        elseif type(Config.Theme) == "table" then
            local t = Config.Theme
            local function toC3(v)
                if type(v) == "table" then return Color3.fromRGB(v[1] or 0, v[2] or 0, v[3] or 0)
                elseif type(v) == "userdata" then return v
                else return Color3.new(0,0,0) end
            end
            local customTheme = {
                Main   = t.Main   and toC3(t.Main)   or CurrentTheme.Main,
                Top    = t.Top    and toC3(t.Top)    or CurrentTheme.Top,
                Text   = t.Text   and toC3(t.Text)   or CurrentTheme.Text,
                Accent = t.Accent and toC3(t.Accent) or CurrentTheme.Accent,
                Stroke = t.Stroke and toC3(t.Stroke) or CurrentTheme.Stroke,
            }
            local customName = t.Name or "Custom"
            Themes[customName] = customTheme
            CurrentTheme = customTheme
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FengYu-UI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ScreenInsets = Enum.ScreenInsets.None
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) elseif gethui then ScreenGui.Parent = gethui() end

    -- Notification System
    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "NotificationHolder"
    NotificationHolder.Size = UDim2.new(0, 320, 0, 0)
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
    HolderList.Padding = UDim.new(0, 8)
    HolderList.Parent = NotificationHolder

    local HolderPadding = Instance.new("UIPadding")
    HolderPadding.PaddingRight = UDim.new(0, 8)
    HolderPadding.PaddingBottom = UDim.new(0, 8)
    HolderPadding.Parent = NotificationHolder

    -- Main Window Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, DefaultWidth, 0, DefaultHeight)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.ClipsDescendants = false
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.Parent = ScreenGui
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = MainFrame
    AddToRegistry(MainFrame, "BackgroundColor3", "Main")

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame
    AddToRegistry(MainStroke, "Color", "Stroke")

    local MainGradient = Instance.new("UIGradient")
    MainGradient.Parent = MainStroke
    MainGradient.Enabled = false

    -- Rainbow Effect Loop
    task.spawn(function()
        local rot = 0
        while ScreenGui and ScreenGui.Parent do
            if RainbowEnabled then
                local t = tick() * RainbowSpeed
                pcall(function()
                    if RainbowType == "Linear Gradient (Solid Rainbow)" then
                        MainGradient.Enabled = true
                        MainGradient.Rotation = 0
                        MainGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),
                            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)),
                            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),
                            ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))
                        })
                        MainStroke.Color = Color3.new(1,1,1)
                    elseif RainbowType == "Animated/Cycling Rainbow" then
                        MainGradient.Enabled = false
                        MainStroke.Color = Color3.fromHSV(t % 5 / 5, 1, 1)
                    elseif RainbowType == "Smooth Fading Gradient" then
                        MainGradient.Enabled = true
                        rot = rot + 2
                        MainGradient.Rotation = rot
                        MainGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
                        })
                        MainStroke.Color = Color3.new(1,1,1)
                    elseif RainbowType == "Step/Band Rainbow" then
                        MainGradient.Enabled = false
                        local step = math.floor((t % 2) * 4) / 4
                        MainStroke.Color = Color3.fromHSV(step, 1, 1)
                    elseif RainbowType == "Rainbow Pulse" then
                        MainGradient.Enabled = false
                        local pulse = (math.sin(t * 3) + 1) / 2
                        MainStroke.Color = Color3.fromHSV(t % 5 / 5, pulse, 1)
                    elseif RainbowType == "Radial Rainbow" then
                        MainGradient.Enabled = true
                        rot = rot + 5
                        MainGradient.Rotation = rot
                        MainGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,255)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))
                        })
                        MainStroke.Color = Color3.new(1,1,1)
                    elseif RainbowType == "Neon/Glowing Rainbow" then
                        MainGradient.Enabled = false
                        MainStroke.Color = Color3.fromHSV(t % 2 / 2, 0.8, 1)
                    elseif RainbowType == "Pastel Rainbow" then
                        MainGradient.Enabled = false
                        MainStroke.Color = Color3.fromHSV(t % 5 / 5, 0.4, 1)
                    elseif RainbowType == "Vertical/Horizontal Fade" then
                        MainGradient.Enabled = true
                        MainGradient.Rotation = 90
                        local c = Color3.fromHSV(t % 5/5, 1, 1)
                        local c2 = Color3.fromHSV((t+1) % 5/5, 1, 1)
                        MainGradient.Color = ColorSequence.new(c, c2)
                        MainStroke.Color = Color3.new(1,1,1)
                    end
                end)
            else
                pcall(function()
                    MainGradient.Enabled = false
                    MainStroke.Color = CurrentTheme.Stroke
                end)
            end
            RunService.RenderStepped:Wait()
        end
    end)

    local topbarHeight = Subtitle and 52 or 46

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, topbarHeight)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = MainFrame

    -- Icon
    if IconAsset == nil then IconAsset = "rbxassetid://78229538488090" end
    if tonumber(IconAsset) then IconAsset = "rbxassetid://" .. IconAsset end

    local Icon = Instance.new("ImageLabel")
    Icon.Name = "WindowIcon"
    Icon.Size = UDim2.new(0, 36, 0, 36)
    Icon.Position = UDim2.new(0, 12, 0.5, -18)
    Icon.BackgroundTransparency = 1
    Icon.Image = IconAsset
    Icon.Parent = Topbar
    AddToRegistry(Icon, "ImageColor3", "Text")

    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 8)
    iconCorner.Parent = Icon

    -- Window Buttons
    local ButtonGroup = Instance.new("Frame")
    ButtonGroup.Name = "WindowButtons"
    ButtonGroup.Size = UDim2.new(0, 200, 1, 0)
    ButtonGroup.Position = UDim2.new(1, -210, 0, 0)
    ButtonGroup.BackgroundTransparency = 1
    ButtonGroup.Parent = Topbar

    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ButtonLayout.Padding = UDim.new(0, 8)
    ButtonLayout.Parent = ButtonGroup

    local ButtonPadding = Instance.new("UIPadding")
    ButtonPadding.PaddingRight = UDim.new(0, 12)
    ButtonPadding.Parent = ButtonGroup

    local function createTextButton(textSymbol, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 38, 0, 38)
        btn.Text = textSymbol
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 20
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BackgroundTransparency = 1
        btn.Parent = ButtonGroup

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundTransparency = 0.9
        bg.BackgroundColor3 = Color3.new(1, 1, 1)
        bg.Parent = btn
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 10)
        bgCorner.Parent = bg

        local function onHover() Tween(bg, {BackgroundTransparency = 0.7}, 0.2) end
        local function onLeave() Tween(bg, {BackgroundTransparency = 0.9}, 0.2) end

        btn.MouseEnter:Connect(onHover)
        btn.MouseLeave:Connect(onLeave)
        btn.MouseButton1Click:Connect(callback)

        return btn
    end

    local function createIconButton(iconAsset, tooltip, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 38, 0, 38)
        btn.Text = ""
        btn.BackgroundTransparency = 1
        btn.Parent = ButtonGroup

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundTransparency = 0.9
        bg.BackgroundColor3 = Color3.new(1, 1, 1)
        bg.Parent = btn
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 10)
        bgCorner.Parent = bg

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0.5, -10, 0.5, -10)
        icon.BackgroundTransparency = 1
        icon.Image = iconAsset
        icon.ImageColor3 = Color3.new(1, 1, 1)
        icon.Parent = btn

        if tooltip then
            local tip = Instance.new("TextLabel")
            tip.Text = tooltip
            tip.Size = UDim2.new(0, 120, 0, 24)
            tip.Position = UDim2.new(0.5, -60, 1, 5)
            tip.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            tip.BackgroundTransparency = 0.1
            tip.Font = Enum.Font.Gotham
            tip.TextSize = 11
            tip.TextColor3 = Color3.new(1, 1, 1)
            tip.Visible = false
            tip.Parent = btn
            local tipCorner = Instance.new("UICorner")
            tipCorner.CornerRadius = UDim.new(0, 6)
            tipCorner.Parent = tip

            btn.MouseEnter:Connect(function() tip.Visible = true end)
            btn.MouseLeave:Connect(function() tip.Visible = false end)
        end

        local function onHover() Tween(bg, {BackgroundTransparency = 0.7}, 0.2) end
        local function onLeave() Tween(bg, {BackgroundTransparency = 0.9}, 0.2) end

        btn.MouseEnter:Connect(onHover)
        btn.MouseLeave:Connect(onLeave)
        btn.MouseButton1Click:Connect(callback)

        return btn
    end

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar
    AddToRegistry(TitleLabel, "TextColor3", "Text")

    if Subtitle then
        TitleLabel.Size = UDim2.new(1, -200, 0, 24)
        TitleLabel.Position = UDim2.new(0, 55, 0, 4)

        local SubtitleLabel = Instance.new("TextLabel")
        SubtitleLabel.Text = Subtitle
        SubtitleLabel.Size = UDim2.new(1, -200, 0, 18)
        SubtitleLabel.Position = UDim2.new(0, 55, 0, 28)
        SubtitleLabel.BackgroundTransparency = 1
        SubtitleLabel.Font = Enum.Font.GothamMedium
        SubtitleLabel.TextSize = 12
        SubtitleLabel.TextTransparency = 0.4
        SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        SubtitleLabel.Parent = Topbar
        AddToRegistry(SubtitleLabel, "TextColor3", "Text")
    else
        TitleLabel.Size = UDim2.new(1, -200, 1, 0)
        TitleLabel.Position = UDim2.new(0, 55, 0, 0)
    end

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -24, 1, -(topbarHeight + 16))
    Content.Position = UDim2.new(0, 12, 0, topbarHeight + 8)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    -- Tab Container (Left Sidebar)
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 160, 0.88, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Content
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 6)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer

    -- Profile Frame
    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(0, 160, 0, 52)
    ProfileFrame.Position = UDim2.new(0, 0, 1, -52)
    ProfileFrame.BackgroundTransparency = 0.05
    ProfileFrame.Parent = Content
    local profileCorner = Instance.new("UICorner")
    profileCorner.CornerRadius = UDim.new(0, 12)
    profileCorner.Parent = ProfileFrame
    AddToRegistry(ProfileFrame, "BackgroundColor3", "Top")

    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 32, 0, 32)
    Avatar.Position = UDim2.new(0, 8, 0.5, -16)
    Avatar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    local userId = LocalPlayer.UserId
    local success, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
    end)
    Avatar.Image = success and thumb or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Avatar.Parent = ProfileFrame
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = Avatar

    local DispName = Instance.new("TextLabel")
    DispName.Text = LocalPlayer.DisplayName
    DispName.Size = UDim2.new(1, -50, 0, 18)
    DispName.Position = UDim2.new(0, 46, 0, 6)
    DispName.BackgroundTransparency = 1
    DispName.Font = Enum.Font.GothamMedium
    DispName.TextSize = 12
    DispName.TextXAlignment = Enum.TextXAlignment.Left
    DispName.Parent = ProfileFrame
    AddToRegistry(DispName, "TextColor3", "Text")

    local UsrName = Instance.new("TextLabel")
    UsrName.Text = "@" .. LocalPlayer.Name
    UsrName.Size = UDim2.new(1, -50, 0, 16)
    UsrName.Position = UDim2.new(0, 46, 0, 26)
    UsrName.BackgroundTransparency = 1
    UsrName.Font = Enum.Font.Gotham
    UsrName.TextSize = 10
    UsrName.TextTransparency = 0.5
    UsrName.TextXAlignment = Enum.TextXAlignment.Left
    UsrName.Parent = ProfileFrame
    AddToRegistry(UsrName, "TextColor3", "Text")

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(0, 1, 1, -16)
    Divider.Position = UDim2.new(0, 170, 0, 8)
    Divider.BackgroundTransparency = 0.8
    Divider.Parent = Content
    AddToRegistry(Divider, "BackgroundColor3", "Stroke")

    -- Page Container (Right Content)
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -190, 1, 0)
    PageContainer.Position = UDim2.new(0, 180, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Content

    -- Resizer Handle
    local Resizer = Instance.new("TextButton")
    Resizer.Name = "WindowResizer"
    Resizer.Parent = MainFrame
    Resizer.BackgroundTransparency = 0.85
    Resizer.BackgroundColor3 = Color3.new(1, 1, 1)
    Resizer.Position = UDim2.new(1, 6, 1, 6)
    Resizer.Size = UDim2.new(0, 28, 0, 28)
    Resizer.AnchorPoint = Vector2.new(1, 1)
    Resizer.Text = "↘"
    Resizer.TextSize = 16
    Resizer.TextColor3 = Color3.new(1, 1, 1)
    Resizer.ZIndex = 30
    Resizer.Visible = true

    local resizerCorner = Instance.new("UICorner")
    resizerCorner.CornerRadius = UDim.new(0, 8)
    resizerCorner.Parent = Resizer

    local isResizing = false
    local resizeStart = Vector2.new(0, 0)
    local startSize = UDim2.new(0, 0, 0, 0)

    Resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = true
            resizeStart = input.Position
            startSize = MainFrame.Size
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local newWidth = math.max(500, startSize.X.Offset + delta.X)
            local newHeight = math.max(350, startSize.Y.Offset + delta.Y)
            MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = false
        end
    end)

    -- ========== PROJECTOR MODE (FIXED) ==========
    Window._ProjectorModeEnabled = false
    Window._ProjectorObjects = nil
    Window._ProjectorSettings = {
        distance = 6,
        width = 10,
        height = 7,
        transparency = 0.15,
        autoSize = true
    }

    local function UpdateProjectorScreenPosition(screenPart)
        if not screenPart or not screenPart.Parent then return end
        local character = LocalPlayer.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local camCF = Camera.CFrame
        local forward = camCF.LookVector
        forward = Vector3.new(forward.X, 0, forward.Z).Unit
        if forward.Magnitude < 0.1 then forward = Vector3.new(0, 0, 1) end

        local distance = Window._ProjectorSettings.distance
        local targetPos = rootPart.Position + forward * distance
        targetPos = Vector3.new(targetPos.X, targetPos.Y + 1.5, targetPos.Z)

        local lookAtPoint = rootPart.Position + Vector3.new(0, 1.2, 0)
        local screenCF = CFrame.lookAt(targetPos, lookAtPoint)

        pcall(function()
            screenPart.CFrame = screenCF
        end)
    end

    local function UpdateProjectorSizeFromUI()
        if not Window._ProjectorModeEnabled or not Window._ProjectorObjects then return end
        local surfaceGui = Window._ProjectorObjects.SurfaceGui
        if not surfaceGui then return end
        local mainFrame = surfaceGui:FindFirstChild("FengYu-UI")
        if not mainFrame then return end

        local absSize = mainFrame.AbsoluteSize
        if absSize.X <= 0 or absSize.Y <= 0 then return end

        local aspect = absSize.X / absSize.Y
        local targetHeight = Window._ProjectorSettings.height
        local targetWidth = targetHeight * aspect
        targetWidth = clamp(targetWidth, 5, 14)
        targetHeight = clamp(targetHeight, 4, 10)

        local screen = Window._ProjectorObjects.Screen
        if screen then
            pcall(function()
                screen.Size = Vector3.new(targetWidth, targetHeight, 0.1)
                Window._ProjectorSettings.width = targetWidth
                Window._ProjectorSettings.height = targetHeight
            end)
        end
    end

    local function SwitchToProjectorMode(distance, width, height, transparency)
        if Window._ProjectorModeEnabled then return false end

        distance = distance or Window._ProjectorSettings.distance
        width = width or Window._ProjectorSettings.width
        height = height or Window._ProjectorSettings.height
        transparency = transparency or Window._ProjectorSettings.transparency

        -- Create projector screen part
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

        -- Add selection box for visibility
        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Adornee = projectorScreen
        selectionBox.Color3 = CurrentTheme.Accent
        selectionBox.LineThickness = 0.06
        selectionBox.Transparency = 0.3
        selectionBox.Parent = projectorScreen

        if syn and syn.protect_gui then pcall(function() syn.protect_gui(projectorScreen) end) end
        projectorScreen.Parent = Workspace

        -- Create SurfaceGui
        local surfaceGui = Instance.new("SurfaceGui")
        surfaceGui.Name = "ProjectorUI"
        surfaceGui.ResetOnSpawn = false
        surfaceGui.Face = Enum.NormalId.Front
        surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        surfaceGui.CanvasSize = Vector2.new(1920, 1080)
        surfaceGui.ClipsDescendants = true
        surfaceGui.AlwaysOnTop = true
        surfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        surfaceGui.Adornee = projectorScreen
        surfaceGui.Parent = projectorScreen

        -- Move all UI elements to surfaceGui
        local originalChildren = {}
        for _, child in ipairs(ScreenGui:GetChildren()) do
            if child ~= OpenButton and child ~= NotificationHolder then
                originalChildren[#originalChildren + 1] = child
            end
        end

        for _, child in ipairs(originalChildren) do
            child.Parent = surfaceGui
        end

        -- Save and adjust main frame
        Window._savedMainFrameSize = MainFrame.Size
        Window._savedMainFramePos = MainFrame.Position
        MainFrame.Size = UDim2.new(0, 800, 0, 600)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

        -- Add subtle light effect
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 2
        pointLight.Range = 15
        pointLight.Color = CurrentTheme.Accent
        pointLight.Shadows = false
        pointLight.Parent = projectorScreen

        -- Position update connection
        local updateConnection
        updateConnection = RunService.RenderStepped:Connect(function()
            if not projectorScreen or not projectorScreen.Parent then
                if updateConnection then updateConnection:Disconnect() end
                return
            end
            UpdateProjectorScreenPosition(projectorScreen)
        end)

        -- Size update connection
        local sizeConnection
        sizeConnection = MainFrame:GetPropertyChangedSignal("Size"):Connect(function()
            if Window._ProjectorSettings.autoSize then
                UpdateProjectorSizeFromUI()
            end
        end)

        task.wait(0.1)
        UpdateProjectorSizeFromUI()

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
        if not Window._ProjectorModeEnabled then return false end

        if Window._ProjectorObjects then
            if Window._ProjectorObjects.UpdateConnection then
                pcall(function() Window._ProjectorObjects.UpdateConnection:Disconnect() end)
            end
            if Window._ProjectorObjects.SizeConnection then
                pcall(function() Window._ProjectorObjects.SizeConnection:Disconnect() end)
            end

            if Window._ProjectorObjects.SurfaceGui then
                local surfaceGui = Window._ProjectorObjects.SurfaceGui
                for _, child in ipairs(surfaceGui:GetChildren()) do
                    pcall(function() child.Parent = ScreenGui end)
                end
            end

            if Window._ProjectorObjects.Screen then
                pcall(function() Window._ProjectorObjects.Screen:Destroy() end)
            end
        end

        if Window._savedMainFrameSize then
            MainFrame.Size = Window._savedMainFrameSize
            MainFrame.Position = Window._savedMainFramePos
        else
            MainFrame.Size = UDim2.new(0, 700, 0, 500)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        end

        Window._ProjectorModeEnabled = false
        Window._ProjectorObjects = nil

        return true
    end

    local function ToggleProjectorMode()
        if Window._ProjectorModeEnabled then
            SwitchTo2DMode()
            Window:Notification("投影仪模式", "已关闭投影仪效果", "Info", 2)
        else
            SwitchToProjectorMode()
            Window:Notification("投影仪模式", "UI已投射到前方屏幕", "Success", 2)
        end
    end

    -- Create window buttons
    local ProjectorBtn = createIconButton("rbxassetid://12684119225", "投影仪模式", ToggleProjectorMode)
    local MinimizeBtn = createTextButton("−", function() MainFrame.Visible = false end)
    local CloseBtn = createTextButton("✕", function()
        if Window._ProjectorModeEnabled then
            SwitchTo2DMode()
        end
        safeDestroy(ScreenGui)
    end)

    -- Floating Open Button
    local OpenButton = Instance.new("ImageButton")
    OpenButton.Name = "FloatingOpenButton"
    OpenButton.Parent = ScreenGui
    OpenButton.BackgroundColor3 = CurrentTheme.Accent
    OpenButton.BackgroundTransparency = 0.85
    OpenButton.Position = UDim2.new(0.92, 0, 0.02, 0)
    OpenButton.Size = UDim2.new(0, 48, 0, 48)
    OpenButton.Active = true
    OpenButton.Draggable = true
    OpenButton.Image = "rbxassetid://84830962019412"
    OpenButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    OpenButton.ImageTransparency = 0.15
    OpenButton.ZIndex = 10

    local openCorner = Instance.new("UICorner")
    openCorner.CornerRadius = UDim.new(0, 12)
    openCorner.Parent = OpenButton

    local openStroke = Instance.new("UIStroke")
    openStroke.Parent = OpenButton
    openStroke.Color = Color3.fromRGB(180, 180, 180)
    openStroke.Thickness = 1.5
    openStroke.Transparency = 0.4

    startNeonFlowEffect(OpenButton, "BackgroundColor3", 0.012)

    OpenButton.MouseButton1Click:Connect(function()
        if MainFrame.Visible then
            MainFrame.Visible = false
        else
            MainFrame.Visible = true
        end
    end)

    MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        OpenButton.Visible = not MainFrame.Visible
    end)

    OpenButton.Visible = false

    -- Drag functionality for MainFrame
    local dragging = false
    local dragInput, dragStart, startPos

    local function updateDrag(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    Topbar.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            dragInput = input
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            dragging = false
            dragInput = nil
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            updateDrag(dragInput)
        end
    end)

    local function toggleMainFrame()
        if MainFrame.Visible then
            MainFrame.Visible = false
        else
            MainFrame.Visible = true
            Tween(MainFrame, {Size = MainFrame.Size}, 0.3)
        end
    end

    if Keybind then
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == Keybind then
                toggleMainFrame()
            end
        end)
    end

    -- Animate window appearance
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Visible = true
    Tween(MainFrame, {Size = UDim2.new(0, DefaultWidth, 0, DefaultHeight)}, 0.5)

    -- Notification Function
    function Window:Notification(titleText, descText, notifType, duration)
        notifType = notifType or "Info"
        duration = duration or 3

        local typeColors = {
            Success = Color3.fromRGB(60, 179, 113),
            Error   = Color3.fromRGB(229, 51, 51),
            Info    = Color3.fromRGB(77, 163, 255)
        }
        local typeIcons = {
            Success = "rbxassetid://120659272678891",
            Error   = "rbxassetid://89180847534855",
            Info    = "rbxassetid://75441143875602"
        }

        local accentColor = typeColors[notifType] or typeColors.Info
        local iconAsset = typeIcons[notifType] or typeIcons.Info

        local root = Instance.new("Frame")
        root.Name = "NotificationRoot"
        root.Size = UDim2.new(0, 0, 0, 0)
        root.BackgroundTransparency = 1
        root.BorderSizePixel = 0
        root.ClipsDescendants = true
        root.Parent = NotificationHolder

        local main = Instance.new("Frame")
        main.Name = "Main"
        main.Size = UDim2.new(0, 300, 0, 0)
        main.AutomaticSize = Enum.AutomaticSize.Y
        main.BackgroundColor3 = CurrentTheme.Top
        main.BackgroundTransparency = 0.05
        main.BorderSizePixel = 0
        main.Parent = root

        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 16)
        mainCorner.Parent = main

        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, -80, 1, 0)
        content.Position = UDim2.new(0, 45, 0, 0)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Parent = main

        local icon = Instance.new("ImageLabel")
        icon.Name = "TypeIcon"
        icon.Image = iconAsset
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0, -22, 0.5, -10)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.BorderSizePixel = 0
        icon.ImageColor3 = accentColor
        icon.Parent = content

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Name = "Title"
        titleLbl.Text = titleText
        titleLbl.Size = UDim2.new(1, 0, 0, 0)
        titleLbl.AutomaticSize = Enum.AutomaticSize.Y
        titleLbl.BackgroundTransparency = 1
        titleLbl.BorderSizePixel = 0
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 14
        titleLbl.TextColor3 = CurrentTheme.Text
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.RichText = true
        titleLbl.Parent = content

        local descLbl = Instance.new("TextLabel")
        descLbl.Name = "Description"
        descLbl.Text = descText
        descLbl.Size = UDim2.new(1, 0, 0, 0)
        descLbl.AutomaticSize = Enum.AutomaticSize.Y
        descLbl.BackgroundTransparency = 1
        descLbl.BorderSizePixel = 0
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextSize = 12
        descLbl.TextColor3 = CurrentTheme.Text
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.RichText = true
        descLbl.Parent = content

        local line = Instance.new("Frame")
        line.Name = "Line"
        line.Size = UDim2.new(0, 4, 1, -20)
        line.Position = UDim2.new(0, -18, 0.5, 0)
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BackgroundColor3 = accentColor
        line.BackgroundTransparency = 0.7
        line.BorderSizePixel = 0
        line.Parent = descLbl

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 4)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = content

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 14)
        padding.PaddingBottom = UDim.new(0, 14)
        padding.Parent = content

        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "CloseButton"
        closeBtn.Size = UDim2.new(0, 24, 0, 24)
        closeBtn.Position = UDim2.new(1, -32, 0, 12)
        closeBtn.BackgroundTransparency = 1
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = CurrentTheme.Text
        closeBtn.TextSize = 14
        closeBtn.Font = Enum.Font.Gotham
        closeBtn.Parent = main

        local function updateTheme()
            main.BackgroundColor3 = CurrentTheme.Top
            titleLbl.TextColor3 = CurrentTheme.Text
            descLbl.TextColor3 = CurrentTheme.Text
            closeBtn.TextColor3 = CurrentTheme.Text
        end
        table.insert(ThemeListeners, updateTheme)

        task.wait()
        local mainSize = main.AbsoluteSize
        Tween(root, {Size = UDim2.new(0, mainSize.X, 0, mainSize.Y)}, 0.3)

        local function destroy()
            for i, fn in ipairs(ThemeListeners) do
                if fn == updateTheme then
                    table.remove(ThemeListeners, i)
                    break
                end
            end
            local shrink = TweenService:Create(root, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0)})
            shrink.Completed:Connect(function()
                if root and root.Parent then safeDestroy(root) end
            end)
            shrink:Play()
        end

        closeBtn.MouseButton1Click:Connect(destroy)

        if duration > 0 then
            task.delay(duration, destroy)
        end
    end

    function Window:SetKeybind(key) Keybind = key end
    function Window:Destroy() safeDestroy(ScreenGui) end
    function Window:SetSubtitle(newSubtitle)
        for _, child in ipairs(Topbar:GetChildren()) do
            if child:IsA("TextLabel") and child ~= TitleLabel then
                child.Text = newSubtitle
                break
            end
        end
    end

    function Window:SetProjectorDistance(distance)
        distance = clamp(distance, 3, 15)
        Window._ProjectorSettings.distance = distance
        if Window._ProjectorModeEnabled and Window._ProjectorObjects and Window._ProjectorObjects.Screen then
            UpdateProjectorScreenPosition(Window._ProjectorObjects.Screen)
        end
    end

    function Window:SetProjectorSize(width, height)
        width = clamp(width, 5, 14)
        height = clamp(height, 4, 10)
        Window._ProjectorSettings.width = width
        Window._ProjectorSettings.height = height
        Window._ProjectorSettings.autoSize = false
        if Window._ProjectorModeEnabled and Window._ProjectorObjects and Window._ProjectorObjects.Screen then
            pcall(function()
                Window._ProjectorObjects.Screen.Size = Vector3.new(width, height, 0.1)
            end)
        end
    end

    function Window:SetProjectorTransparency(transparency)
        transparency = clamp(transparency, 0, 0.8)
        Window._ProjectorSettings.transparency = transparency
        if Window._ProjectorModeEnabled and Window._ProjectorObjects and Window._ProjectorObjects.Screen then
            pcall(function()
                Window._ProjectorObjects.Screen.Transparency = transparency
            end)
        end
    end

    function Window:CreateProjectorSettingsTab(parentTab)
        local section = parentTab:Section("📽️ 投影仪设置")
        section:Slider("投影距离", 3, 15, Window._ProjectorSettings.distance, function(val)
            Window:SetProjectorDistance(val)
        end)
        section:Slider("屏幕宽度", 5, 14, Window._ProjectorSettings.width, function(val)
            Window:SetProjectorSize(val, Window._ProjectorSettings.height)
        end)
        section:Slider("屏幕高度", 4, 10, Window._ProjectorSettings.height, function(val)
            Window:SetProjectorSize(Window._ProjectorSettings.width, val)
        end)
        section:Slider("屏幕透明度", 0, 0.8, Window._ProjectorSettings.transparency, function(val)
            Window:SetProjectorTransparency(val)
        end)
        section:Button("自动适配UI大小", function()
            Window._ProjectorSettings.autoSize = true
            if Window._ProjectorModeEnabled then
                UpdateProjectorSizeFromUI()
            end
            Window:Notification("投影仪", "已开启自动适配UI大小", "Success", 1)
        end)
        section:Button("刷新屏幕位置", function()
            if Window._ProjectorModeEnabled and Window._ProjectorObjects and Window._ProjectorObjects.Screen then
                UpdateProjectorScreenPosition(Window._ProjectorObjects.Screen)
                Window:Notification("投影仪", "屏幕位置已刷新", "Success", 1)
            end
        end)
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

    -- Tab and Section Creation
    local firstTab = true
    local controlCounter = 0

    local function createSection(parent, text, icons, defaultOpen)
        if defaultOpen == nil then defaultOpen = true end

        local function formatAssetId(id)
            if type(id) == "number" then
                return "rbxassetid://" .. tostring(id)
            elseif type(id) == "string" then
                if tonumber(id) then
                    return "rbxassetid://" .. id
                else
                    return id
                end
            else
                return nil
            end
        end

        local iconOpen, iconClosed
        if type(icons) == "table" then
            iconOpen = formatAssetId(icons.Y or icons.open) or "rbxassetid://6031091004"
            iconClosed = formatAssetId(icons.F or icons.closed) or iconOpen
        else
            local defaultIcon = formatAssetId(icons) or "rbxassetid://6031091004"
            iconOpen = defaultIcon
            iconClosed = defaultIcon
        end

        local sectionFrame = Instance.new("Frame")
        sectionFrame.Size = UDim2.new(1, 0, 0, 40)
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.Parent = parent
        sectionFrame.ClipsDescendants = true

        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 40)
        titleBar.BackgroundTransparency = 1
        titleBar.Parent = sectionFrame

        local iconLabel = Instance.new("ImageLabel")
        iconLabel.Size = UDim2.new(0, 28, 0, 28)
        iconLabel.Position = UDim2.new(0, 8, 0.5, -14)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Image = defaultOpen and iconOpen or iconClosed
        iconLabel.Parent = titleBar
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0, 8)
        iconCorner.Parent = iconLabel
        AddToRegistry(iconLabel, "ImageColor3", "Text")

        local textLabel = Instance.new("TextLabel")
        textLabel.Text = text
        textLabel.Size = UDim2.new(1, -44, 1, 0)
        textLabel.Position = UDim2.new(0, 44, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 14
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.Parent = titleBar
        AddToRegistry(textLabel, "TextColor3", "Accent")

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(1, 0, 1, 0)
        toggleBtn.BackgroundTransparency = 1
        toggleBtn.Text = ""
        toggleBtn.Parent = titleBar

        local contentContainer = Instance.new("Frame")
        contentContainer.Size = UDim2.new(1, 0, 0, 0)
        contentContainer.Position = UDim2.new(0, 0, 0, 40)
        contentContainer.BackgroundTransparency = 1
        contentContainer.ClipsDescendants = true
        contentContainer.Parent = sectionFrame

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = contentContainer

        local currentContentTween, currentSectionTween
        local open = defaultOpen

        local function updateSectionHeight(instant)
            local targetContentHeight = open and contentLayout.AbsoluteContentSize.Y or 0
            local targetSectionHeight = 40 + targetContentHeight
            if currentContentTween then currentContentTween:Cancel() end
            if currentSectionTween then currentSectionTween:Cancel() end
            local tweenInfo = TweenInfo.new(instant and 0 or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            currentContentTween = TweenService:Create(contentContainer, tweenInfo, {Size = UDim2.new(1, 0, 0, targetContentHeight)})
            currentSectionTween = TweenService:Create(sectionFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, targetSectionHeight)})
            currentContentTween:Play()
            currentSectionTween:Play()
        end

        task.spawn(function()
            task.wait()
            updateSectionHeight(true)
        end)

        local function toggle()
            open = not open
            iconLabel.Image = open and iconOpen or iconClosed
            updateSectionHeight(false)
        end
        toggleBtn.MouseButton1Click:Connect(toggle)

        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if open then updateSectionHeight(false) end
        end)

        local child = {}

        child.Button = function(_, btnText, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 46)
            Btn.Text = ""
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 14
            Btn.Parent = contentContainer
            Btn.BackgroundTransparency = 0.05
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 12)
            btnCorner.Parent = Btn
            AddToRegistry(Btn, "BackgroundColor3", "Top")

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, -36, 1, 0)
            TextLabel.Position = UDim2.new(0, 12, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Font = Enum.Font.GothamMedium
            TextLabel.Text = btnText
            TextLabel.TextSize = 13
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Parent = Btn
            AddToRegistry(TextLabel, "TextColor3", "Text")

            local Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Position = UDim2.new(1, -28, 0.5, -8)
            Icon.BackgroundTransparency = 1
            Icon.Image = "rbxassetid://10709791437"
            Icon.ImageTransparency = 0.5
            Icon.Parent = Btn
            AddToRegistry(Icon, "ImageColor3", "Text")

            Btn.MouseEnter:Connect(function()
                Tween(Btn, {BackgroundTransparency = 0}, 0.18)
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Btn, {BackgroundTransparency = 0.05}, 0.18)
            end)

            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, {Size = UDim2.new(0.98, 0, 0, 42)}, 0.08)
                task.wait(0.08)
                Tween(Btn, {Size = UDim2.new(1, 0, 0, 46)}, 0.12)
                pcall(callback)
            end)

            local self = {}
            function self.UpdateText(newText) TextLabel.Text = newText end
            function self.SetVisible(state) Btn.Visible = state end
            return self
        end

        child.Toggle = function(_, toggleText, default, callback)
            local Enabled = default or false
            controlCounter = controlCounter + 1
            local controlId = toggleText .. "_" .. tostring(controlCounter)

            local Tile = Instance.new("Frame")
            Tile.Size = UDim2.new(1, 0, 0, 46)
            Tile.Parent = contentContainer
            Tile.BackgroundTransparency = 0.05
            local tileCorner = Instance.new("UICorner")
            tileCorner.CornerRadius = UDim.new(0, 12)
            tileCorner.Parent = Tile
            AddToRegistry(Tile, "BackgroundColor3", "Top")

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = Tile

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = toggleText
            TitleLbl.Size = UDim2.new(0.7, 0, 1, 0)
            TitleLbl.Position = UDim2.new(0, 16, 0, 0)
            TitleLbl.BackgroundTransparency = 1
            TitleLbl.Font = Enum.Font.GothamMedium
            TitleLbl.TextSize = 13
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            TitleLbl.Parent = Tile
            AddToRegistry(TitleLbl, "TextColor3", "Text")

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 46, 0, 24)
            Switch.Position = UDim2.new(1, -60, 0.5, -12)
            Switch.Parent = Tile
            local switchCorner = Instance.new("UICorner")
            switchCorner.CornerRadius = UDim.new(1, 0)
            switchCorner.Parent = Switch
            Switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or CurrentTheme.Stroke

            local SwStroke = Instance.new("UIStroke")
            SwStroke.Thickness = 1
            SwStroke.Transparency = 0.6
            SwStroke.Parent = Switch
            AddToRegistry(SwStroke, "Color", "Stroke")

            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0, 18, 0, 18)
            Dot.Position = Enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)
            Dot.BackgroundColor3 = Color3.new(1, 1, 1)
            Dot.Parent = Switch
            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = Dot

            ConfigObjects[controlId] = {
                Type = "Toggle",
                Value = Enabled,
                Set = function(val)
                    Enabled = val
                    Switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or CurrentTheme.Stroke
                    Dot.Position = Enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)
                    pcall(callback, Enabled)
                end
            }

            local function Update()
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or CurrentTheme.Stroke})
                Tween(Dot, {Position = Enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)})
                ConfigObjects[controlId].Value = Enabled
                pcall(callback, Enabled)
            end

            ClickBtn.MouseButton1Click:Connect(function()
                Enabled = not Enabled
                Update()
            end)

            table.insert(ThemeListeners, function()
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or CurrentTheme.Stroke})
            end)

            local self = {}
            function self.SetValue(val) Enabled = val; Update() end
            function self.GetValue() return Enabled end
            return self
        end

        child.Slider = function(_, sliderText, min, max, default, callback)
            min = tonumber(min) or 0
            max = tonumber(max) or 100
            local Val = tonumber(default) or min
            controlCounter = controlCounter + 1
            local controlId = sliderText .. "_" .. tostring(controlCounter)

            local Tile = Instance.new("Frame")
            Tile.Size = UDim2.new(1, 0, 0, 72)
            Tile.Parent = contentContainer
            Tile.BackgroundTransparency = 0.05
            local tileCorner = Instance.new("UICorner")
            tileCorner.CornerRadius = UDim.new(0, 12)
            tileCorner.Parent = Tile
            AddToRegistry(Tile, "BackgroundColor3", "Top")

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = sliderText
            TitleLbl.Size = UDim2.new(0.6, 0, 0, 22)
            TitleLbl.Position = UDim2.new(0, 16, 0, 10)
            TitleLbl.BackgroundTransparency = 1
            TitleLbl.Font = Enum.Font.GothamMedium
            TitleLbl.TextSize = 13
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            TitleLbl.Parent = Tile
            AddToRegistry(TitleLbl, "TextColor3", "Text")

            local Num = Instance.new("TextBox")
            Num.Text = tostring(Val)
            Num.Size = UDim2.new(0, 60, 0, 28)
            Num.Position = UDim2.new(1, -76, 0, 8)
            Num.BackgroundTransparency = 0.08
            Num.Font = Enum.Font.GothamBold
            Num.TextSize = 12
            Num.TextXAlignment = Enum.TextXAlignment.Center
            Num.Parent = Tile
            Num.ClearTextOnFocus = false
            local numCorner = Instance.new("UICorner")
            numCorner.CornerRadius = UDim.new(0, 8)
            numCorner.Parent = Num
            AddToRegistry(Num, "BackgroundColor3", "Main")
            AddToRegistry(Num, "TextColor3", "Accent")
            local NumStroke = Instance.new("UIStroke")
            NumStroke.Thickness = 1
            NumStroke.Transparency = 0.75
            NumStroke.Parent = Num
            AddToRegistry(NumStroke, "Color", "Stroke")

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -32, 0, 5)
            Track.Position = UDim2.new(0, 16, 0, 50)
            Track.BorderSizePixel = 0
            Track.Parent = Tile
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = Track
            AddToRegistry(Track, "BackgroundColor3", "Stroke")

            local initP = (Val - min) / (max - min)
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(initP, 0, 1, 0)
            Fill.Parent = Track
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = Fill
            AddToRegistry(Fill, "BackgroundColor3", "Accent")

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 14, 0, 14)
            Knob.AnchorPoint = Vector2.new(0.5, 0.5)
            Knob.Position = UDim2.new(initP, 0, 0.5, 0)
            Knob.BackgroundColor3 = Color3.new(1, 1, 1)
            Knob.ZIndex = 2
            Knob.Parent = Track
            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = Knob

            local Bar = Instance.new("TextButton")
            Bar.Size = UDim2.new(1, 0, 0, 20)
            Bar.Position = UDim2.new(0, 0, 0.5, -10)
            Bar.BackgroundTransparency = 1
            Bar.Text = ""
            Bar.ZIndex = 3
            Bar.Parent = Track

            local function Update(newVal)
                newVal = clamp(newVal, min, max)
                Val = newVal
                Num.Text = string.format("%.1f", Val)
                if ConfigObjects[controlId] then ConfigObjects[controlId].Value = Val end
                local p = (Val - min) / (max - min)
                Tween(Fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.16)
                Tween(Knob, {Position = UDim2.new(p, 0, 0.5, 0)}, 0.16)
                pcall(callback, Val)
            end

            ConfigObjects[controlId] = {
                Type = "Slider",
                Value = Val,
                Set = function(val) Update(tonumber(val) or Val) end
            }

            local function Drag(input)
                if not Track then return end
                local p = clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                Update(min + (max - min) * p)
            end

            Num.FocusLost:Connect(function()
                Tween(NumStroke, {Transparency = 0.75}, 0.15)
                local typed = tonumber(Num.Text)
                if typed then Update(typed) else Num.Text = string.format("%.1f", Val) end
            end)
            Num.Focused:Connect(function()
                Tween(NumStroke, {Transparency = 0.2}, 0.15)
            end)

            local sliding = false
            Bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    Drag(i)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    Drag(i)
                end
            end)

            local self = {}
            function self.SetValue(val) Update(val) end
            function self.GetValue() return Val end
            return self
        end

        child.Dropdown = function(_, dropText, options, callback)
            local Dropped = false
            local Selected = options[1] or ""
            controlCounter = controlCounter + 1
            local controlId = dropText .. "_" .. tostring(controlCounter)

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 46)
            Btn.Text = ""
            Btn.BackgroundTransparency = 0.05
            Btn.Parent = contentContainer
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 12)
            btnCorner.Parent = Btn
            AddToRegistry(Btn, "BackgroundColor3", "Top")

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = dropText .. ": " .. Selected
            Lbl.Size = UDim2.new(1, -50, 1, 0)
            Lbl.Position = UDim2.new(0, 16, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = Btn
            AddToRegistry(Lbl, "TextColor3", "Text")

            local Icon = Instance.new("ImageLabel")
            Icon.Image = "rbxassetid://18865373378"
            Icon.Size = UDim2.new(0, 18, 0, 18)
            Icon.Position = UDim2.new(1, -30, 0.5, -9)
            Icon.BackgroundTransparency = 1
            Icon.Parent = Btn
            AddToRegistry(Icon, "ImageColor3", "Accent")

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.Visible = false
            Container.ClipsDescendants = true
            Container.ZIndex = 10
            Container.Parent = contentContainer
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 12)
            containerCorner.Parent = Container
            AddToRegistry(Container, "BackgroundColor3", "Top")

            local CSt = Instance.new("UIStroke")
            CSt.Thickness = 1
            CSt.Transparency = 0.65
            CSt.Parent = Container
            AddToRegistry(CSt, "Color", "Accent")

            local List = Instance.new("UIListLayout")
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Parent = Container

            local function Select(opt)
                Dropped = false
                Selected = opt
                Lbl.Text = dropText .. ": " .. opt
                if ConfigObjects[controlId] then ConfigObjects[controlId].Value = opt end
                pcall(callback, opt)

                Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                Tween(Icon, {Rotation = 0}, 0.28)
                task.wait(0.3)
                Container.Visible = false
                updateSectionHeight(false)
            end

            local function RefreshOptions(newOpts)
                for _, v in pairs(Container:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end
                for _, opt in pairs(newOpts) do
                    local O = Instance.new("TextButton")
                    O.Size = UDim2.new(1, 0, 0, 36)
                    O.Text = "   " .. opt
                    O.TextXAlignment = Enum.TextXAlignment.Left
                    O.Font = Enum.Font.GothamMedium
                    O.TextSize = 12
                    O.BackgroundTransparency = 1
                    O.Parent = Container
                    O.TextColor3 = CurrentTheme.Text

                    O.MouseEnter:Connect(function()
                        Tween(O, {TextColor3 = CurrentTheme.Accent}, 0.15)
                    end)
                    O.MouseLeave:Connect(function()
                        Tween(O, {TextColor3 = CurrentTheme.Text}, 0.15)
                    end)
                    O.MouseButton1Click:Connect(function() Select(opt) end)
                end
                if Dropped then
                    local targetHeight = #newOpts * 36
                    Tween(Container, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                end
            end
            RefreshOptions(options)

            Btn.MouseButton1Click:Connect(function()
                Dropped = not Dropped
                if Dropped then
                    Container.Visible = true
                    local buttonCount = 0
                    for _, child in pairs(Container:GetChildren()) do
                        if child:IsA("TextButton") then buttonCount = buttonCount + 1 end
                    end
                    local targetHeight = buttonCount * 36
                    Tween(Container, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.32)
                    Tween(Icon, {Rotation = 180}, 0.32)
                else
                    Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                    Tween(Icon, {Rotation = 0}, 0.28)
                    task.wait(0.3)
                    Container.Visible = false
                end
                updateSectionHeight(false)
            end)

            ConfigObjects[controlId] = {
                Type = "Dropdown",
                Value = Selected,
                Set = function(val) Select(val) end,
                Refresh = RefreshOptions
            }

            local self = {}
            function self.Refresh(newOpts) RefreshOptions(newOpts) end
            function self.SetValue(val) Select(val) end
            return self
        end

        child.Label = function(_, labelText)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, 0, 0, 46)
            LabelFrame.Parent = contentContainer
            LabelFrame.BackgroundTransparency = 0.05
            local labelCorner = Instance.new("UICorner")
            labelCorner.CornerRadius = UDim.new(0, 12)
            labelCorner.Parent = LabelFrame
            AddToRegistry(LabelFrame, "BackgroundColor3", "Top")

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, -24, 1, 0)
            TextLabel.Position = UDim2.new(0, 12, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Font = Enum.Font.GothamMedium
            TextLabel.Text = labelText
            TextLabel.TextSize = 13
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Parent = LabelFrame
            AddToRegistry(TextLabel, "TextColor3", "Text")

            local self = {}
            function self.UpdateText(newText) TextLabel.Text = newText end
            return self
        end

        child.Paragraph = function(_, headerText, bodyText)
            local ParaFrame = Instance.new("Frame")
            ParaFrame.Size = UDim2.new(1, 0, 0, 0)
            ParaFrame.AutomaticSize = Enum.AutomaticSize.Y
            ParaFrame.Parent = contentContainer
            ParaFrame.BackgroundTransparency = 0.05
            local paraCorner = Instance.new("UICorner")
            paraCorner.CornerRadius = UDim.new(0, 12)
            paraCorner.Parent = ParaFrame
            AddToRegistry(ParaFrame, "BackgroundColor3", "Top")

            local Padding = Instance.new("UIPadding")
            Padding.PaddingLeft = UDim.new(0, 16)
            Padding.PaddingRight = UDim.new(0, 16)
            Padding.PaddingTop = UDim.new(0, 14)
            Padding.PaddingBottom = UDim.new(0, 14)
            Padding.Parent = ParaFrame

            local Layout = Instance.new("UIListLayout")
            Layout.Padding = UDim.new(0, 8)
            Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Layout.Parent = ParaFrame

            local HeaderLabel = Instance.new("TextLabel")
            HeaderLabel.Size = UDim2.new(1, 0, 0, 0)
            HeaderLabel.AutomaticSize = Enum.AutomaticSize.Y
            HeaderLabel.BackgroundTransparency = 1
            HeaderLabel.Font = Enum.Font.GothamBold
            HeaderLabel.Text = headerText
            HeaderLabel.TextSize = 15
            HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
            HeaderLabel.TextWrapped = true
            HeaderLabel.Parent = ParaFrame
            AddToRegistry(HeaderLabel, "TextColor3", "Accent")

            local BodyLabel = Instance.new("TextLabel")
            BodyLabel.Size = UDim2.new(1, 0, 0, 0)
            BodyLabel.AutomaticSize = Enum.AutomaticSize.Y
            BodyLabel.BackgroundTransparency = 1
            BodyLabel.Font = Enum.Font.Gotham
            BodyLabel.Text = bodyText
            BodyLabel.TextSize = 12
            BodyLabel.TextXAlignment = Enum.TextXAlignment.Left
            BodyLabel.TextWrapped = true
            BodyLabel.Parent = ParaFrame
            AddToRegistry(BodyLabel, "TextColor3", "Text")

            local self = {}
            function self.UpdateHeader(newHeader) HeaderLabel.Text = newHeader end
            function self.UpdateBody(newBody) BodyLabel.Text = newBody end
            return self
        end

        return child
    end

    -- Tab Creation
    function Window:Tab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = TabContainer
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 10)
        tabCorner.Parent = TabBtn
        TabBtn.Selected = false

        local TabBar = Instance.new("Frame")
        TabBar.Size = UDim2.new(0, 3, 0.7, 0)
        TabBar.Position = UDim2.new(0, 0, 0.15, 0)
        TabBar.BackgroundTransparency = 1
        TabBar.BorderSizePixel = 0
        TabBar.Parent = TabBtn
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = TabBar
        AddToRegistry(TabBar, "BackgroundColor3", "Accent")

        local ContentFrame = Instance.new("Frame")
        ContentFrame.Name = "ContentFrame"
        ContentFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.Parent = TabBtn

        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 6)
        Layout.Parent = ContentFrame

        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 12)
        Padding.Parent = ContentFrame

        if icon then
            local TabIcon = Instance.new("ImageLabel")
            TabIcon.Size = UDim2.new(0, 28, 0, 28)
            TabIcon.BackgroundTransparency = 1
            if tonumber(icon) then TabIcon.Image = "rbxassetid://" .. icon else TabIcon.Image = icon end
            TabIcon.Parent = ContentFrame
            AddToRegistry(TabIcon, "ImageColor3", "Text")
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 8)
            iconCorner.Parent = TabIcon
        end

        local TabText = Instance.new("TextLabel")
        local textWidth = TextService:GetTextSize(name, 14, Enum.Font.GothamMedium, Vector2.new(200, 36)).X
        TabText.Size = UDim2.new(0, textWidth, 1, 0)
        TabText.BackgroundTransparency = 1
        TabText.Font = Enum.Font.GothamMedium
        TabText.Text = name
        TabText.TextColor3 = Color3.fromRGB(150, 150, 158)
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Parent = ContentFrame

        TabBtn.MouseEnter:Connect(function()
            if not TabBtn.Selected then
                Tween(TabText, {TextColor3 = Color3.fromRGB(180, 180, 188)}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if not TabBtn.Selected then
                Tween(TabText, {TextColor3 = Color3.fromRGB(150, 150, 158)}, 0.15)
            end
        end)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85)
        Page.ScrollingDirection = Enum.ScrollingDirection.Y
        Page.Visible = false
        Page.Parent = PageContainer

        local ContentHolder = Instance.new("Frame")
        ContentHolder.Name = "Content"
        ContentHolder.Size = UDim2.new(1, 0, 0, 0)
        ContentHolder.AutomaticSize = Enum.AutomaticSize.Y
        ContentHolder.BackgroundTransparency = 1
        ContentHolder.Parent = Page

        local HolderPadding = Instance.new("UIPadding")
        HolderPadding.PaddingRight = UDim.new(0, 4)
        HolderPadding.Parent = ContentHolder

        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 12)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Parent = ContentHolder

        local function updateCanvas()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 16)
        end
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        task.spawn(function() task.wait(); updateCanvas() end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do
                v.Visible = false
            end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    v.Selected = false
                    Tween(v, {BackgroundTransparency = 1})
                    local content = v:FindFirstChild("ContentFrame")
                    if content then
                        local textLabel = content:FindFirstChildOfClass("TextLabel")
                        if textLabel then Tween(textLabel, {TextColor3 = Color3.fromRGB(150, 150, 158)}) end
                    end
                    local bar = v:FindFirstChildOfClass("Frame")
                    if bar then Tween(bar, {BackgroundTransparency = 1}) end
                end
            end
            Page.Visible = true
            TabBtn.Selected = true
            Tween(TabBtn, {BackgroundTransparency = 0.05})
            Tween(TabText, {TextColor3 = CurrentTheme.Text})
            Tween(TabBar, {BackgroundTransparency = 0})
        end)

        if firstTab then
            firstTab = false
            Page.Visible = true
            TabBtn.Selected = true
            TabBtn.BackgroundTransparency = 0.05
            TabText.TextColor3 = CurrentTheme.Text
            TabBar.BackgroundTransparency = 0
        end

        local Elements = {}
        function Elements:Section(text, icons, defaultOpen)
            return createSection(ContentHolder, text, icons, defaultOpen)
        end
        return Elements
    end

    function Window:DualTab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = TabContainer
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 10)
        tabCorner.Parent = TabBtn
        TabBtn.Selected = false

        local TabBar = Instance.new("Frame")
        TabBar.Size = UDim2.new(0, 3, 0.7, 0)
        TabBar.Position = UDim2.new(0, 0, 0.15, 0)
        TabBar.BackgroundTransparency = 1
        TabBar.BorderSizePixel = 0
        TabBar.Parent = TabBtn
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = TabBar
        AddToRegistry(TabBar, "BackgroundColor3", "Accent")

        local ContentFrame = Instance.new("Frame")
        ContentFrame.Name = "ContentFrame"
        ContentFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.Parent = TabBtn

        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 6)
        Layout.Parent = ContentFrame

        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 12)
        Padding.Parent = ContentFrame

        if icon then
            local TabIcon = Instance.new("ImageLabel")
            TabIcon.Size = UDim2.new(0, 28, 0, 28)
            TabIcon.BackgroundTransparency = 1
            if tonumber(icon) then TabIcon.Image = "rbxassetid://" .. icon else TabIcon.Image = icon end
            TabIcon.Parent = ContentFrame
            AddToRegistry(TabIcon, "ImageColor3", "Text")
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 8)
            iconCorner.Parent = TabIcon
        end

        local TabText = Instance.new("TextLabel")
        local textWidth = TextService:GetTextSize(name, 14, Enum.Font.GothamMedium, Vector2.new(200, 36)).X
        TabText.Size = UDim2.new(0, textWidth, 1, 0)
        TabText.BackgroundTransparency = 1
        TabText.Font = Enum.Font.GothamMedium
        TabText.Text = name
        TabText.TextColor3 = Color3.fromRGB(150, 150, 158)
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Parent = ContentFrame

        TabBtn.MouseEnter:Connect(function()
            if not TabBtn.Selected then
                Tween(TabText, {TextColor3 = Color3.fromRGB(180, 180, 188)}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if not TabBtn.Selected then
                Tween(TabText, {TextColor3 = Color3.fromRGB(150, 150, 158)}, 0.15)
            end
        end)

        local PageFrame = Instance.new("Frame")
        PageFrame.Size = UDim2.new(1, 0, 1, 0)
        PageFrame.BackgroundTransparency = 1
        PageFrame.Visible = false
        PageFrame.Parent = PageContainer

        local Columns = Instance.new("Frame")
        Columns.Size = UDim2.new(1, 0, 1, 0)
        Columns.BackgroundTransparency = 1
        Columns.Parent = PageFrame

        local ColumnsLayout = Instance.new("UIListLayout")
        ColumnsLayout.FillDirection = Enum.FillDirection.Horizontal
        ColumnsLayout.Padding = UDim.new(0, 12)
        ColumnsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ColumnsLayout.Parent = Columns

        local ColumnsPadding = Instance.new("UIPadding")
        ColumnsPadding.PaddingLeft = UDim.new(0, 4)
        ColumnsPadding.PaddingRight = UDim.new(0, 4)
        ColumnsPadding.Parent = Columns

        local LeftColumn = Instance.new("ScrollingFrame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Size = UDim2.new(0.5, -6, 1, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.ScrollingDirection = Enum.ScrollingDirection.Y
        LeftColumn.ScrollBarThickness = 4
        LeftColumn.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85)
        LeftColumn.Parent = Columns

        local LeftHolder = Instance.new("Frame")
        LeftHolder.Name = "Content"
        LeftHolder.Size = UDim2.new(1, 0, 0, 0)
        LeftHolder.AutomaticSize = Enum.AutomaticSize.Y
        LeftHolder.BackgroundTransparency = 1
        LeftHolder.Parent = LeftColumn

        local LeftHolderPadding = Instance.new("UIPadding")
        LeftHolderPadding.PaddingRight = UDim.new(0, 4)
        LeftHolderPadding.Parent = LeftHolder

        local LeftList = Instance.new("UIListLayout")
        LeftList.Padding = UDim.new(0, 12)
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder
        LeftList.Parent = LeftHolder

        local RightColumn = Instance.new("ScrollingFrame")
        RightColumn.Name = "RightColumn"
        RightColumn.Size = UDim2.new(0.5, -6, 1, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.ScrollingDirection = Enum.ScrollingDirection.Y
        RightColumn.ScrollBarThickness = 4
        RightColumn.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85)
        RightColumn.Parent = Columns

        local RightHolder = Instance.new("Frame")
        RightHolder.Name = "Content"
        RightHolder.Size = UDim2.new(1, 0, 0, 0)
        RightHolder.AutomaticSize = Enum.AutomaticSize.Y
        RightHolder.BackgroundTransparency = 1
        RightHolder.Parent = RightColumn

        local RightHolderPadding = Instance.new("UIPadding")
        RightHolderPadding.PaddingRight = UDim.new(0, 4)
        RightHolderPadding.Parent = RightHolder

        local RightList = Instance.new("UIListLayout")
        RightList.Padding = UDim.new(0, 12)
        RightList.SortOrder = Enum.SortOrder.LayoutOrder
        RightList.Parent = RightHolder

        local function updateLeftCanvas()
            LeftColumn.CanvasSize = UDim2.new(0, 0, 0, LeftList.AbsoluteContentSize.Y + 16)
        end
        local function updateRightCanvas()
            RightColumn.CanvasSize = UDim2.new(0, 0, 0, RightList.AbsoluteContentSize.Y + 16)
        end
        LeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLeftCanvas)
        RightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateRightCanvas)
        task.spawn(function() task.wait(); updateLeftCanvas(); updateRightCanvas() end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do
                v.Visible = false
            end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    v.Selected = false
                    Tween(v, {BackgroundTransparency = 1})
                    local content = v:FindFirstChild("ContentFrame")
                    if content then
                        local textLabel = content:FindFirstChildOfClass("TextLabel")
                        if textLabel then Tween(textLabel, {TextColor3 = Color3.fromRGB(150, 150, 158)}) end
                    end
                    local bar = v:FindFirstChildOfClass("Frame")
                    if bar then Tween(bar, {BackgroundTransparency = 1}) end
                end
            end
            PageFrame.Visible = true
            TabBtn.Selected = true
            Tween(TabBtn, {BackgroundTransparency = 0.05})
            Tween(TabText, {TextColor3 = CurrentTheme.Text})
            Tween(TabBar, {BackgroundTransparency = 0})
        end)

        if firstTab then
            firstTab = false
            PageFrame.Visible = true
            TabBtn.Selected = true
            TabBtn.BackgroundTransparency = 0.05
            TabText.TextColor3 = CurrentTheme.Text
            TabBar.BackgroundTransparency = 0
        end

        local DualElements = {}
        function DualElements:section(side, text, icons, defaultOpen)
            local holder = side == "Left" and LeftHolder or RightHolder
            return createSection(holder, text, icons, defaultOpen)
        end
        return DualElements
    end

    return Window
end

return Fenglib