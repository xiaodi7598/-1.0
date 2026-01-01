local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- ====================== 白名单系统 ======================
local WHITELIST = {
    ["3980224147"] = true,
    ["701682546"] = true,
    ["9357193003"] = true,
    ["9181349777"] = true,
    ["826171502"] = true,
    ["7760543937"] = true,
    ["9099458985"] = true,
}

local function checkWhitelist()
    if not localPlayer or not localPlayer.UserId then
        warn("白名单检测失败：玩家信息无效")
        return false
    end

    local playerUID = tostring(localPlayer.UserId)
    if WHITELIST[playerUID] then
        task.wait(0.1)
        if StartSound then StartSound:Destroy() end
        
        local loadSuccess, loadErr = pcall(function()
            local scriptContent = game:HttpGet('https://raw.githubusercontent.com/tfcygvunbind/557/main/天')
            loadstring(scriptContent)()
        end)
        if not loadSuccess then
            warn("脚本加载失败：" .. loadErr)
        end
        
        local function setWalkSpeed(character)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 25
            end
        end
        if localPlayer.Character then
            setWalkSpeed(localPlayer.Character)
        end
        localPlayer.CharacterAdded:Connect(setWalkSpeed)
        
        return true
    end
    return false
end

if checkWhitelist() then return end

-- ========== 启动音效 ==========
local StartSound = Instance.new("Sound")
StartSound.Parent = SoundService
StartSound.SoundId = "rbxassetid://148729028"
StartSound.Volume = 0.5
StartSound:Play()

-- ========== 全局变量 ==========
local attempts = 0
local maxAttempts = 3
local copyCooldown = false
local btnHovering = false
local isCopyHovering = false
local isDragging = false
local dragStart, frameStart
local isMobile = UserInputService.TouchEnabled
local isMouse = UserInputService.MouseEnabled

-- ========== 创建UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KakaScriptUI_CompactEnhanced"
ScreenGui.Parent = localPlayer.PlayerGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100

-- 暗化背景
local BackgroundOverlay = Instance.new("Frame")
BackgroundOverlay.Parent = ScreenGui
BackgroundOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BackgroundOverlay.BackgroundTransparency = 0.7
BackgroundOverlay.Size = UDim2.new(1, 0, 1, 0)
BackgroundOverlay.ZIndex = 1

-- ========== 主窗口（紧凑尺寸） ==========
local MainWin = Instance.new("Frame")
MainWin.Parent = ScreenGui
MainWin.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainWin.Position = UDim2.new(0.5, -150, 0.5, -130) -- 紧凑尺寸位置
MainWin.Size = UDim2.new(0, 300, 0, 260) -- 紧凑尺寸：300x260
MainWin.ZIndex = 2
MainWin.Active = true
MainWin.Selectable = true

local WinCorner = Instance.new("UICorner")
WinCorner.Parent = MainWin
WinCorner.CornerRadius = UDim.new(0, 12)

-- 窗口边框
local WinGlow = Instance.new("UIStroke")
WinGlow.Parent = MainWin
WinGlow.Color = Color3.fromRGB(90, 90, 90)
WinGlow.Thickness = 1.5
WinGlow.Transparency = 0.7

-- ========== 标题栏（拖动区域） ==========
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainWin
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.Size = UDim2.new(1, 0, 0, 40) -- 缩小标题栏高度
TitleBar.ZIndex = 3
TitleBar.Active = true
TitleBar.Selectable = true

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.Parent = TitleBar
TitleBarCorner.CornerRadius = UDim.new(0, 12, 0, 0)

-- 状态指示灯
local StatusLight = Instance.new("Frame")
StatusLight.Parent = TitleBar
StatusLight.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
StatusLight.Position = UDim2.new(0, 8, 0.5, -4)
StatusLight.Size = UDim2.new(0, 8, 0, 8)
StatusLight.ZIndex = 4

local StatusCorner = Instance.new("UICorner")
StatusCorner.Parent = StatusLight
StatusCorner.CornerRadius = UDim.new(1, 0)

local StatusText = Instance.new("TextLabel")
StatusText.Parent = TitleBar
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 20, 0.5, -6)
StatusText.Size = UDim2.new(0, 50, 0, 10)
StatusText.Font = Enum.Font.GothamMedium
StatusText.Text = "未验证"
StatusText.TextColor3 = Color3.fromRGB(255, 150, 150)
StatusText.TextSize = 9
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.ZIndex = 4

-- 标题装饰线
local TitleAccent = Instance.new("Frame")
TitleAccent.Parent = TitleBar
TitleAccent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleAccent.Position = UDim2.new(0, 0, 1, -1)
TitleAccent.Size = UDim2.new(1, 0, 0, 1)
TitleAccent.ZIndex = 4

-- 标题文字
local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Font = Enum.Font.GothamBlack
Title.Text = "黑白脚本 - 卡密验证"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18 -- 缩小字体
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.TextYAlignment = Enum.TextYAlignment.Center
Title.ZIndex = 4

-- 副标题
local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = TitleBar
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 0, 0, 25)
SubTitle.Size = UDim2.new(1, 0, 0, 12)
SubTitle.Font = Enum.Font.Gotham
SubTitle.Text = "卡密验证系统"
SubTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
SubTitle.TextSize = 10 -- 缩小字体
SubTitle.TextXAlignment = Enum.TextXAlignment.Center
SubTitle.ZIndex = 4

-- ========== 警告卡片 ==========
local WarningCard = Instance.new("Frame")
WarningCard.Parent = MainWin
WarningCard.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
WarningCard.Position = UDim2.new(0.5, -135, 0, 45) -- 调整位置
WarningCard.Size = UDim2.new(0, 270, 0, 35) -- 缩小尺寸
WarningCard.ZIndex = 3

local WarningCorner = Instance.new("UICorner")
WarningCorner.Parent = WarningCard
WarningCorner.CornerRadius = UDim.new(0, 6)

local WarningStroke = Instance.new("UIStroke")
WarningStroke.Parent = WarningCard
WarningStroke.Color = Color3.fromRGB(255, 110, 110)
WarningStroke.Thickness = 1
WarningStroke.Transparency = 0.2

local WarningIcon = Instance.new("TextLabel")
WarningIcon.Parent = WarningCard
WarningIcon.BackgroundTransparency = 1
WarningIcon.Position = UDim2.new(0, 8, 0, 8)
WarningIcon.Size = UDim2.new(0, 18, 0, 18)
WarningIcon.Font = Enum.Font.GothamBold
WarningIcon.Text = "⚠"
WarningIcon.TextColor3 = Color3.fromRGB(255, 110, 110)
WarningIcon.TextSize = 14 -- 缩小字体
WarningIcon.TextYAlignment = Enum.TextYAlignment.Center
WarningIcon.ZIndex = 4

local WarningText = Instance.new("TextLabel")
WarningText.Parent = WarningCard
WarningText.BackgroundTransparency = 1
WarningText.Position = UDim2.new(0, 30, 0, 0)
WarningText.Size = UDim2.new(1, -30, 1, 0)
WarningText.Font = Enum.Font.GothamMedium
WarningText.Text = "卡密每周一更换，联系群主获取"
WarningText.TextColor3 = Color3.fromRGB(255, 180, 180)
WarningText.TextSize = 11 -- 缩小字体
WarningText.TextXAlignment = Enum.TextXAlignment.Left
WarningText.TextYAlignment = Enum.TextYAlignment.Center
WarningText.ZIndex = 4

-- ========== 群聊信息卡片 ==========
local GroupCard = Instance.new("Frame")
GroupCard.Parent = MainWin
GroupCard.BackgroundColor3 = Color3.fromRGB(20, 25, 40) -- 调整为深蓝色
GroupCard.Position = UDim2.new(0.5, -135, 0, 85) -- 调整位置
GroupCard.Size = UDim2.new(0, 270, 0, 50) -- 缩小尺寸
GroupCard.ZIndex = 3

local GroupCorner = Instance.new("UICorner")
GroupCorner.Parent = GroupCard
GroupCorner.CornerRadius = UDim.new(0, 8)

-- 发光边框
local GroupGlow = Instance.new("UIStroke")
GroupGlow.Parent = GroupCard
GroupGlow.Color = Color3.fromRGB(80, 120, 200) -- 调整颜色
GroupGlow.Thickness = 1.5
GroupGlow.Transparency = 0.3

-- 图标
local GroupIcon = Instance.new("TextLabel")
GroupIcon.Parent = GroupCard
GroupIcon.BackgroundTransparency = 1
GroupIcon.Position = UDim2.new(0, 12, 0.5, -12)
GroupIcon.Size = UDim2.new(0, 24, 0, 24)
GroupIcon.Font = Enum.Font.GothamBold
GroupIcon.Text = "👥"
GroupIcon.TextColor3 = Color3.fromRGB(150, 180, 220)
GroupIcon.TextSize = 18 -- 缩小字体
GroupIcon.TextYAlignment = Enum.TextYAlignment.Center
GroupIcon.ZIndex = 4

-- 标签
local GroupLabel = Instance.new("TextLabel")
GroupLabel.Parent = GroupCard
GroupLabel.BackgroundTransparency = 1
GroupLabel.Position = UDim2.new(0, 45, 0, 8)
GroupLabel.Size = UDim2.new(0, 120, 0, 16)
GroupLabel.Font = Enum.Font.GothamBold
GroupLabel.Text = "点击复制群号"
GroupLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
GroupLabel.TextSize = 11 -- 缩小字体
GroupLabel.TextXAlignment = Enum.TextXAlignment.Left
GroupLabel.ZIndex = 4

-- 群号显示
local GroupNumber = Instance.new("TextLabel")
GroupNumber.Parent = GroupCard
GroupNumber.BackgroundTransparency = 1
GroupNumber.Position = UDim2.new(0, 45, 0, 24)
GroupNumber.Size = UDim2.new(0, 120, 0, 20)
GroupNumber.Font = Enum.Font.GothamBlack
GroupNumber.Text = "1012033070"
GroupNumber.TextColor3 = Color3.fromRGB(255, 255, 255)
GroupNumber.TextSize = 18 -- 缩小字体
GroupNumber.TextXAlignment = Enum.TextXAlignment.Left
GroupNumber.ZIndex = 4

-- 复制图标
local CopyIcon = Instance.new("TextLabel")
CopyIcon.Parent = GroupCard
CopyIcon.BackgroundTransparency = 1
CopyIcon.Position = UDim2.new(1, -35, 0.5, -12)
CopyIcon.Size = UDim2.new(0, 24, 0, 24)
CopyIcon.Font = Enum.Font.GothamBold
CopyIcon.Text = "📋"
CopyIcon.TextColor3 = Color3.fromRGB(150, 180, 220)
CopyIcon.TextSize = 16 -- 缩小字体
CopyIcon.TextYAlignment = Enum.TextYAlignment.Center
CopyIcon.ZIndex = 4

-- 整个卡片可点击
local CopyButton = Instance.new("TextButton")
CopyButton.Parent = GroupCard
CopyButton.BackgroundTransparency = 1
CopyButton.Size = UDim2.new(1, 0, 1, 0)
CopyButton.Text = ""
CopyButton.ZIndex = 5
CopyButton.AutoButtonColor = false

-- 复制成功提示
local CopySuccess = Instance.new("Frame")
CopySuccess.Parent = MainWin
CopySuccess.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
CopySuccess.Position = UDim2.new(0.5, -65, 0, 75)
CopySuccess.Size = UDim2.new(0, 130, 0, 28)
CopySuccess.ZIndex = 10
CopySuccess.Visible = false

local CopySuccessCorner = Instance.new("UICorner")
CopySuccessCorner.Parent = CopySuccess
CopySuccessCorner.CornerRadius = UDim.new(0, 6)

local CopySuccessStroke = Instance.new("UIStroke")
CopySuccessStroke.Parent = CopySuccess
CopySuccessStroke.Color = Color3.fromRGB(255, 255, 255)
CopySuccessStroke.Thickness = 1

local CopySuccessText = Instance.new("TextLabel")
CopySuccessText.Parent = CopySuccess
CopySuccessText.BackgroundTransparency = 1
CopySuccessText.Size = UDim2.new(1, 0, 1, 0)
CopySuccessText.Font = Enum.Font.GothamBold
CopySuccessText.Text = "✓ 已复制"
CopySuccessText.TextColor3 = Color3.fromRGB(255, 255, 255)
CopySuccessText.TextSize = 10
CopySuccessText.TextXAlignment = Enum.TextXAlignment.Center
CopySuccessText.TextYAlignment = Enum.TextYAlignment.Center

-- ========== 白名单提示 ==========
local WhitelistNote = Instance.new("TextLabel")
WhitelistNote.Parent = MainWin
WhitelistNote.BackgroundTransparency = 1
WhitelistNote.Position = UDim2.new(0, 0, 0, 140)
WhitelistNote.Size = UDim2.new(1, 0, 0, 16)
WhitelistNote.Font = Enum.Font.GothamMedium
WhitelistNote.Text = "✨ 进群有机会获得白名单资格"
WhitelistNote.TextColor3 = Color3.fromRGB(255, 200, 80)
WhitelistNote.TextSize = 11 -- 缩小字体
WhitelistNote.TextXAlignment = Enum.TextXAlignment.Center
WhitelistNote.ZIndex = 3

-- ========== 输入框 ==========
local InputContainer = Instance.new("Frame")
InputContainer.Parent = MainWin
InputContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InputContainer.Position = UDim2.new(0.5, -120, 0, 160) -- 调整位置
InputContainer.Size = UDim2.new(0, 240, 0, 36) -- 缩小尺寸
InputContainer.ZIndex = 3

local InputContainerCorner = Instance.new("UICorner")
InputContainerCorner.Parent = InputContainer
InputContainerCorner.CornerRadius = UDim.new(0, 8)

local InputContainerStroke = Instance.new("UIStroke")
InputContainerStroke.Parent = InputContainer
InputContainerStroke.Color = Color3.fromRGB(50, 50, 50)
InputContainerStroke.Thickness = 1

local Input = Instance.new("TextBox")
Input.Parent = InputContainer
Input.BackgroundTransparency = 1
Input.Position = UDim2.new(0, 12, 0, 0)
Input.Size = UDim2.new(1, -24, 1, 0)
Input.Font = Enum.Font.Gotham
Input.Text = ""
Input.TextColor3 = Color3.fromRGB(255, 255, 255)
Input.TextSize = 13 -- 缩小字体
Input.PlaceholderText = "请输入卡密..."
Input.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
Input.ClearTextOnFocus = false
Input.ZIndex = 4

local InputIcon = Instance.new("TextLabel")
InputIcon.Parent = InputContainer
InputIcon.BackgroundTransparency = 1
InputIcon.Position = UDim2.new(1, -30, 0.5, -9)
InputIcon.Size = UDim2.new(0, 18, 0, 18)
InputIcon.Font = Enum.Font.GothamBold
InputIcon.Text = "🔑"
InputIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
InputIcon.TextSize = 12 -- 缩小字体
InputIcon.TextYAlignment = Enum.TextYAlignment.Center
InputIcon.ZIndex = 4

-- 输入框清空按钮
local ClearInputButton = Instance.new("TextButton")
ClearInputButton.Parent = InputContainer
ClearInputButton.BackgroundTransparency = 1
ClearInputButton.Position = UDim2.new(1, -50, 0.5, -8)
ClearInputButton.Size = UDim2.new(0, 20, 0, 20)
ClearInputButton.Font = Enum.Font.GothamBold
ClearInputButton.Text = "×"
ClearInputButton.TextColor3 = Color3.fromRGB(120, 120, 120)
ClearInputButton.TextSize = 12
ClearInputButton.Visible = false
ClearInputButton.ZIndex = 4

-- ========== 验证按钮 ==========
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Parent = MainWin
VerifyBtn.Position = UDim2.new(0.5, -95, 0, 205) -- 调整位置
VerifyBtn.Size = UDim2.new(0, 190, 0, 36) -- 缩小尺寸
VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Text = "验证卡密"
VerifyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
VerifyBtn.TextSize = 14 -- 缩小字体
VerifyBtn.TextXAlignment = Enum.TextXAlignment.Center
VerifyBtn.BorderSizePixel = 0
VerifyBtn.AutoButtonColor = false
VerifyBtn.ZIndex = 3

local VerifyBtnCorner = Instance.new("UICorner")
VerifyBtnCorner.Parent = VerifyBtn
VerifyBtnCorner.CornerRadius = UDim.new(0, 8)

local VerifyBtnStroke = Instance.new("UIStroke")
VerifyBtnStroke.Parent = VerifyBtn
VerifyBtnStroke.Color = Color3.fromRGB(50, 50, 50)
VerifyBtnStroke.Thickness = 1.5

-- 剩余尝试次数显示
local AttemptsDisplay = Instance.new("TextLabel")
AttemptsDisplay.Parent = MainWin
AttemptsDisplay.BackgroundTransparency = 1
AttemptsDisplay.Position = UDim2.new(0, 0, 1, -35)
AttemptsDisplay.Size = UDim2.new(1, 0, 0, 14)
AttemptsDisplay.Font = Enum.Font.GothamMedium
AttemptsDisplay.Text = string.format("剩余尝试次数: %d/%d", maxAttempts - attempts, maxAttempts)
AttemptsDisplay.TextColor3 = Color3.fromRGB(180, 180, 180)
AttemptsDisplay.TextSize = 10
AttemptsDisplay.TextXAlignment = Enum.TextXAlignment.Center
AttemptsDisplay.ZIndex = 3

-- ========== 关闭按钮 ==========
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainWin
CloseBtn.Position = UDim2.new(1, -35, 0, 8)
CloseBtn.Size = UDim2.new(0, 24, 0, 24) -- 缩小尺寸
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 18 -- 缩小字体
CloseBtn.TextXAlignment = Enum.TextXAlignment.Center
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 10

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.Parent = CloseBtn
CloseBtnCorner.CornerRadius = UDim.new(0, 6)

-- ========== 消息提示 ==========
local Msg = Instance.new("TextLabel")
Msg.Parent = MainWin
Msg.BackgroundTransparency = 1
Msg.Position = UDim2.new(0, 0, 1, -20) -- 调整位置
Msg.Size = UDim2.new(1, 0, 0, 16)
Msg.Font = Enum.Font.Gotham
Msg.Text = ""
Msg.TextColor3 = Color3.fromRGB(150, 150, 150)
Msg.TextSize = 10 -- 缩小字体
Msg.TextXAlignment = Enum.TextXAlignment.Center
Msg.Visible = false
Msg.ZIndex = 3

-- ========== 触摸区域 ==========
local TouchDragArea = Instance.new("TextButton")
TouchDragArea.Parent = MainWin
TouchDragArea.BackgroundTransparency = 1
TouchDragArea.Size = UDim2.new(1, 0, 0, 60) -- 触摸区域
TouchDragArea.Text = ""
TouchDragArea.ZIndex = 5
TouchDragArea.AutoButtonColor = false
TouchDragArea.Visible = isMobile

-- ========== 入场动画 ==========
MainWin.Size = UDim2.new(0, 0, 0, 0)
MainWin.Position = UDim2.new(0.5, 0, 0.5, 0)
MainWin.BackgroundTransparency = 1

local entranceTween = TweenService:Create(MainWin, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 300, 0, 260),
    Position = UDim2.new(0.5, -150, 0.5, -130),
    BackgroundTransparency = 0
})
entranceTween:Play()

-- ========== 功能模块 ==========

-- 更新剩余尝试次数显示
local function updateAttemptsDisplay()
    AttemptsDisplay.Text = string.format("剩余尝试次数: %d/%d", maxAttempts - attempts, maxAttempts)
end

-- 播放音效
local function playSound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.Parent = SoundService
    sound.SoundId = soundId
    sound.Volume = volume or 0.5
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 1)
end

-- 显示消息提示
local function showMessage(text, color, duration)
    Msg.Text = text
    Msg.TextColor3 = color
    Msg.Visible = true
    
    if duration then
        task.wait(duration)
        Msg.Visible = false
    end
end

-- 更新状态指示灯
local function updateStatus(color, text)
    StatusLight.BackgroundColor3 = color
    StatusText.Text = text
    StatusText.TextColor3 = color
end

-- ========== 输入框交互 ==========
Input.Focused:Connect(function()
    InputContainerStroke.Color = Color3.fromRGB(255, 255, 255)
    TweenService:Create(InputContainer, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    }):Play()
    TweenService:Create(InputIcon, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    -- 显示清空按钮
    if #Input.Text > 0 then
        ClearInputButton.Visible = true
    end
end)

Input.FocusLost:Connect(function()
    InputContainerStroke.Color = Color3.fromRGB(50, 50, 50)
    TweenService:Create(InputContainer, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    }):Play()
    TweenService:Create(InputIcon, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(150, 150, 150)
    }):Play()
    
    -- 隐藏清空按钮
    ClearInputButton.Visible = false
end)

-- 输入文本变化时显示/隐藏清空按钮
Input:GetPropertyChangedSignal("Text"):Connect(function()
    ClearInputButton.Visible = #Input.Text > 0
end)

-- 清空输入框按钮
ClearInputButton.MouseEnter:Connect(function()
    TweenService:Create(ClearInputButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

ClearInputButton.MouseLeave:Connect(function()
    TweenService:Create(ClearInputButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(120, 120, 120)
    }):Play()
end)

ClearInputButton.MouseButton1Click:Connect(function()
    Input.Text = ""
    Input:CaptureFocus()
    playSound("rbxassetid://62339698", 0.3)
end)

-- ========== 按钮交互 ==========
VerifyBtn.MouseEnter:Connect(function()
    btnHovering = true
    TweenService:Create(VerifyBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    }):Play()
    TweenService:Create(VerifyBtnStroke, TweenInfo.new(0.2), {
        Color = Color3.fromRGB(75, 75, 75)
    }):Play()
end)

VerifyBtn.MouseLeave:Connect(function()
    btnHovering = false
    TweenService:Create(VerifyBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    TweenService:Create(VerifyBtnStroke, TweenInfo.new(0.2), {
        Color = Color3.fromRGB(50, 50, 50)
    }):Play()
end)

VerifyBtn.MouseButton1Down:Connect(function()
    TweenService:Create(VerifyBtn, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(225, 225, 225),
        Size = UDim2.new(0, 185, 0, 34)
    }):Play()
    playSound("rbxassetid://62339698", 0.2)
end)

VerifyBtn.MouseButton1Up:Connect(function()
    TweenService:Create(VerifyBtn, TweenInfo.new(0.1), {
        BackgroundColor3 = btnHovering and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 190, 0, 36)
    }):Play()
end)

-- ========== 关闭按钮交互 ==========
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        TextColor3 = Color3.fromRGB(200, 200, 200)
    }):Play()
end)

-- ========== 复制功能交互 ==========
CopyButton.MouseEnter:Connect(function()
    isCopyHovering = true
    if not copyCooldown then
        TweenService:Create(GroupCard, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 35, 55),
            Size = UDim2.new(0, 275, 0, 52)
        }):Play()
        TweenService:Create(GroupGlow, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(120, 160, 240),
            Thickness = 2,
            Transparency = 0.2
        }):Play()
        TweenService:Create(GroupIcon, TweenInfo.new(0.2), {
            TextColor3 = Color3.fromRGB(190, 210, 245)
        }):Play()
        TweenService:Create(CopyIcon, TweenInfo.new(0.2), {
            TextColor3 = Color3.fromRGB(190, 210, 245)
        }):Play()
        TweenService:Create(GroupNumber, TweenInfo.new(0.2), {
            TextColor3 = Color3.fromRGB(255, 255, 230)
        }):Play()
    end
end)

CopyButton.MouseLeave:Connect(function()
    isCopyHovering = false
    if not copyCooldown then
        TweenService:Create(GroupCard, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(20, 25, 40),
            Size = UDim2.new(0, 270, 0, 50)
        }):Play()
        TweenService:Create(GroupGlow, TweenInfo.new(0.3), {
            Color = Color3.fromRGB(80, 120, 200),
            Thickness = 1.5,
            Transparency = 0.3
        }):Play()
        TweenService:Create(GroupIcon, TweenInfo.new(0.3), {
            TextColor3 = Color3.fromRGB(150, 180, 220)
        }):Play()
        TweenService:Create(CopyIcon, TweenInfo.new(0.3), {
            TextColor3 = Color3.fromRGB(150, 180, 220)
        }):Play()
        TweenService:Create(GroupNumber, TweenInfo.new(0.3), {
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end
end)

CopyButton.MouseButton1Down:Connect(function()
    if not copyCooldown then
        TweenService:Create(GroupCard, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(15, 20, 35),
            Size = UDim2.new(0, 265, 0, 48)
        }):Play()
        TweenService:Create(GroupGlow, TweenInfo.new(0.1), {
            Color = Color3.fromRGB(150, 190, 255),
            Thickness = 2.2
        }):Play()
        playSound("rbxassetid://62339698", 0.2)
    end
end)

CopyButton.MouseButton1Up:Connect(function()
    if not copyCooldown then
        TweenService:Create(GroupCard, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 270, 0, 50),
            BackgroundColor3 = isCopyHovering and Color3.fromRGB(30, 35, 55) or Color3.fromRGB(20, 25, 40)
        }):Play()
        TweenService:Create(GroupGlow, TweenInfo.new(0.1), {
            Color = isCopyHovering and Color3.fromRGB(120, 160, 240) or Color3.fromRGB(80, 120, 200),
            Thickness = 1.5
        }):Play()
    end
end)

CopyButton.MouseButton1Click:Connect(function()
    if copyCooldown then return end
    
    copyCooldown = true
    
    -- 播放复制音效
    playSound("rbxassetid://62339698", 0.5)
    
    -- 复制群号到剪贴板
    local groupNumber = "1012033070"
    pcall(function()
        setclipboard(groupNumber)
    end)
    
    -- 复制成功动画
    CopyIcon.Text = "✓"
    TweenService:Create(CopyIcon, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(80, 255, 80),
        TextSize = 18
    }):Play()
    
    TweenService:Create(GroupNumber, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(80, 255, 80)
    }):Play()
    
    -- 显示成功提示
    CopySuccess.Visible = true
    CopySuccess.Position = UDim2.new(0.5, -65, 0, 75)
    
    local successTween = TweenService:Create(CopySuccess, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -65, 0, 70)
    })
    successTween:Play()
    
    -- 成功闪烁
    for i = 1, 2 do
        TweenService:Create(GroupCard, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(30, 55, 30)
        }):Play()
        TweenService:Create(GroupGlow, TweenInfo.new(0.1), {
            Color = Color3.fromRGB(100, 255, 100)
        }):Play()
        task.wait(0.1)
        TweenService:Create(GroupCard, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(20, 25, 40)
        }):Play()
        TweenService:Create(GroupGlow, TweenInfo.new(0.1), {
            Color = Color3.fromRGB(80, 120, 200)
        }):Play()
        task.wait(0.1)
    end
    
    task.wait(1.5)
    
    -- 隐藏成功提示
    local hideTween = TweenService:Create(CopySuccess, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -65, 0, 75)
    })
    hideTween:Play()
    hideTween.Completed:Wait()
    CopySuccess.Visible = false
    
    task.wait(0.5)
    
    CopyIcon.Text = "📋"
    TweenService:Create(CopyIcon, TweenInfo.new(0.3), {
        TextColor3 = Color3.fromRGB(150, 180, 220),
        TextSize = 16
    }):Play()
    
    TweenService:Create(GroupNumber, TweenInfo.new(0.3), {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    -- 显示消息提示
    showMessage("✅ 群号已复制到剪贴板", Color3.fromRGB(80, 255, 80), 2)
    
    task.wait(1)
    copyCooldown = false
end)

-- ========== 统一的拖动功能 ==========
local function startDrag(input)
    if (isMouse and input.UserInputType == Enum.UserInputType.MouseButton1) or
       (isMobile and input.UserInputType == Enum.UserInputType.Touch) then
        isDragging = true
        dragStart = input.Position
        frameStart = MainWin.Position
        
        TweenService:Create(TitleBar, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        }):Play()
        TweenService:Create(TitleAccent, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        }):Play()
        
        showMessage("拖动中...", Color3.fromRGB(200, 200, 200))
    end
end

local function endDrag()
    if isDragging then
        isDragging = false
        
        TweenService:Create(TitleBar, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        }):Play()
        TweenService:Create(TitleAccent, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        
        Msg.Visible = false
    end
end

-- 设置拖动区域
if isMobile then
    TouchDragArea.InputBegan:Connect(startDrag)
else
    TitleBar.InputBegan:Connect(startDrag)
end

-- 拖动处理
UserInputService.InputChanged:Connect(function(input)
    if isDragging then
        local delta = input.Position - dragStart
        local newX = frameStart.X.Offset + delta.X
        local newY = frameStart.Y.Offset + delta.Y
        
        local screenWidth = workspace.CurrentCamera.ViewportSize.X
        local screenHeight = workspace.CurrentCamera.ViewportSize.Y
        
        newX = math.clamp(newX, 0, screenWidth - MainWin.Size.X.Offset)
        newY = math.clamp(newY, 0, screenHeight - MainWin.Size.Y.Offset)
        
        MainWin.Position = UDim2.new(0, newX, 0, newY)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if isDragging and ((isMouse and input.UserInputType == Enum.UserInputType.MouseButton1) or
                      (isMobile and input.UserInputType == Enum.UserInputType.Touch)) then
        endDrag()
    end
end)

-- ========== 关闭功能 ==========
CloseBtn.MouseButton1Click:Connect(function()
    playSound("rbxassetid://62339698", 0.3)
    
    local exitTween = TweenService:Create(MainWin, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    })
    exitTween:Play()
    exitTween.Completed:Wait()
    ScreenGui:Destroy()
    if StartSound then
        StartSound:Destroy()
    end
end)

-- ========== 验证功能 ==========
VerifyBtn.MouseButton1Click:Connect(function()
    local key = Input.Text
    
    if #key == 0 then
        showMessage("请输入卡密", Color3.fromRGB(255, 180, 80), 1.5)
        
        -- 输入框震动效果
        for i = 1, 3 do
            InputContainer.Position = UDim2.new(0.5, -120 + (i % 2 == 1 and 3 or -3), 0, 160)
            task.wait(0.05)
        end
        InputContainer.Position = UDim2.new(0.5, -120, 0, 160)
        return
    end
    
    if key == "迪脚本" then
        -- 验证成功
        updateStatus(Color3.fromRGB(80, 255, 80), "已验证")
        showMessage("✓ 验证成功，正在启动脚本...", Color3.fromRGB(80, 255, 80))
        
        TweenService:Create(VerifyBtn, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(80, 255, 80),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        
        TweenService:Create(VerifyBtnStroke, TweenInfo.new(0.3), {
            Color = Color3.fromRGB(80, 255, 80)
        }):Play()
        
        TweenService:Create(WinGlow, TweenInfo.new(0.3), {
            Color = Color3.fromRGB(80, 255, 80),
            Thickness = 2
        }):Play()
        
        -- 成功音效
        playSound("rbxassetid://62339698", 0.6)
        
        task.wait(1.2)
        
        local exitTween = TweenService:Create(MainWin, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        })
        exitTween:Play()
        exitTween.Completed:Wait()
        
        ScreenGui:Destroy()
        if StartSound then
            StartSound:Destroy()
        end
        
        pcall(function()
            loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/aa294a62c2e48bc4c6ea72022c2da28420ba2ea3c233ef97a34688303a76bef9/download"))()
        end)
        
        if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
            localPlayer.Character.Humanoid.WalkSpeed = 25
        end
        
    else
        -- 验证失败
        attempts = attempts + 1
        updateAttemptsDisplay()
        
        showMessage(string.format("验证失败 (%d/%d)", attempts, maxAttempts), Color3.fromRGB(255, 110, 110))
        
        TweenService:Create(VerifyBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(255, 110, 110),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        
        TweenService:Create(VerifyBtnStroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(255, 110, 110)
        }):Play()
        
        -- 失败音效
        playSound("rbxassetid://62339698", 0.3)
        
        -- 震动效果
        for i = 1, 3 do
            InputContainer.Position = UDim2.new(0.5, -120 + (i % 2 == 1 and 4 or -4), 0, 160)
            task.wait(0.05)
        end
        InputContainer.Position = UDim2.new(0.5, -120, 0, 160)
        
        -- 警告闪烁
        for i = 1, 2 do
            WarningStroke.Color = Color3.fromRGB(255, 80, 80)
            task.wait(0.1)
            WarningStroke.Color = Color3.fromRGB(255, 110, 110)
            task.wait(0.1)
        end
        
        task.wait(0.5)
        
        if attempts >= maxAttempts then
            updateStatus(Color3.fromRGB(255, 80, 80), "已锁定")
            showMessage("❌ 验证次数过多，UI将在3秒后关闭", Color3.fromRGB(255, 80, 80))
            
            -- 锁定UI
            VerifyBtn.AutoButtonColor = false
            VerifyBtn.Active = false
            Input.TextEditable = false
            
            task.wait(3)
            
            local exitTween = TweenService:Create(MainWin, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1
            })
            exitTween:Play()
            exitTween.Completed:Wait()
            ScreenGui:Destroy()
        else
            if btnHovering then
                TweenService:Create(VerifyBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(245, 245, 245),
                    TextColor3 = Color3.fromRGB(0, 0, 0)
                }):Play()
                TweenService:Create(VerifyBtnStroke, TweenInfo.new(0.2), {
                    Color = Color3.fromRGB(75, 75, 75)
                }):Play()
            else
                TweenService:Create(VerifyBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    TextColor3 = Color3.fromRGB(0, 0, 0)
                }):Play()
                TweenService:Create(VerifyBtnStroke, TweenInfo.new(0.2), {
                    Color = Color3.fromRGB(50, 50, 50)
                }):Play()
            end
            
            -- 清空输入框
            Input.Text = ""
        end
    end
end)

-- ========== 快捷键功能 ==========
Input.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        VerifyBtn.MouseButton1Click:Fire()
    end
end)

-- 键盘快捷键
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape then
        CloseBtn.MouseButton1Click:Fire()
    end
    
    if input.KeyCode == Enum.KeyCode.F5 then
        -- 重新验证快捷键
        if attempts < maxAttempts then
            attempts = 0
            updateAttemptsDisplay()
            updateStatus(Color3.fromRGB(255, 100, 100), "未验证")
            VerifyBtn.AutoButtonColor = true
            VerifyBtn.Active = true
            Input.TextEditable = true
            
            showMessage("重置验证次数", Color3.fromRGB(100, 200, 255), 1.5)
            playSound("rbxassetid://62339698", 0.3)
        end
    end
end)

-- ========== 输入限制 ==========
Input:GetPropertyChangedSignal("Text"):Connect(function()
    if #Input.Text > 100 then
        Input.Text = string.sub(Input.Text, 1, 100)
        showMessage("输入过长，已自动截断", Color3.fromRGB(255, 160, 60), 1.5)
    end
end)

-- ========== 动态效果 ==========
-- 窗口边框呼吸效果
coroutine.wrap(function()
    while WinGlow.Parent do
        TweenService:Create(WinGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {
            Transparency = 0.8
        }):Play()
        task.wait(2)
    end
end)()

-- 按钮边框呼吸效果
coroutine.wrap(function()
    while VerifyBtnStroke.Parent do
        TweenService:Create(VerifyBtnStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {
            Transparency = 0.5
        }):Play()
        task.wait(1.5)
    end
end)()

-- 状态指示灯闪烁
coroutine.wrap(function()
    while StatusLight.Parent do
        TweenService:Create(StatusLight, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {
            BackgroundTransparency = 0.3
        }):Play()
        task.wait(1)
    end
end)()

-- ========== 移动端优化 ==========
if isMobile then
    -- 软键盘处理
    local function onTextFieldFocused()
        TweenService:Create(MainWin, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0.5, -150, 0, 50)
        }):Play()
    end
    
    local function onTextFieldFocusLost()
        TweenService:Create(MainWin, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0.5, -150, 0.5, -130)
        }):Play()
    end
    
    Input.Focused:Connect(onTextFieldFocused)
    Input.FocusLost:Connect(onTextFieldFocusLost)
    
    -- 双击拖动区域关闭UI
    local lastTapTime = 0
    local doubleTapThreshold = 0.3
    
    TouchDragArea.MouseButton1Click:Connect(function()
        local currentTime = tick()
        if currentTime - lastTapTime < doubleTapThreshold then
            CloseBtn.MouseButton1Click:Fire()
        end
        lastTapTime = currentTime
    end)
end

-- 初始化
updateAttemptsDisplay()
updateStatus(Color3.fromRGB(255, 100, 100), "未验证")

print("黑白脚本紧凑增强版UI已加载完成")
print("窗口尺寸: 300x260 (紧凑尺寸)")
print("设备适配:", isMobile and "移动端" or "电脑端")
print("功能优化完成，用户体验提升")

-- 1. 创建 UI 容器与文本标签
local LBLG = Instance.new("ScreenGui")
LBLG.Name = "LBLG"
LBLG.Parent = game.CoreGui
LBLG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LBLG.Enabled = true

-- 核心：单UI容器，避免冗余
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "VIPTimeDisplay"
mainGui.Parent = game.CoreGui
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Enabled = true

-- 容器优化：尺寸自适应，布局更紧凑
local container = Instance.new("Frame")
container.Name = "Container"
container.Parent = mainGui
container.BackgroundTransparency = 1
container.Position = UDim2.new(0.98, -5, 0.01, 5)
container.AnchorPoint = Vector2.new(1, 0)
container.Size = UDim2.new(0, 210, 0, 36) -- 宽度调整以容纳新按钮

-- 第一行：VIP时间显示
local vipLabel = Instance.new("TextLabel")
vipLabel.Name = "VIPLabel"
vipLabel.Parent = container
vipLabel.BackgroundTransparency = 1
vipLabel.Position = UDim2.new(0, 0, 0, 0)
vipLabel.Size = UDim2.new(0, 75, 0, 18)
vipLabel.Font = Enum.Font.GothamBold
vipLabel.Text = "金贵的VIP时间"
vipLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
vipLabel.TextScaled = true
vipLabel.TextSize = 9
vipLabel.TextXAlignment = Enum.TextXAlignment.Right

-- 发光优化
local vipGlow = Instance.new("UIStroke")
vipGlow.Parent = vipLabel
vipGlow.Color = Color3.fromRGB(255, 230, 100)
vipGlow.Thickness = 1.2
vipGlow.Transparency = 0.5
vipGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- 时间标签
local timeLabel = Instance.new("TextLabel")
timeLabel.Name = "TimeLabel"
timeLabel.Parent = container
timeLabel.BackgroundTransparency = 1
timeLabel.Position = UDim2.new(0, 78, 0, 0)
timeLabel.Size = UDim2.new(0, 85, 0, 18)
timeLabel.Font = Enum.Font.GothamSemibold
timeLabel.Text = os.date("%H:%M:%S")
timeLabel.TextScaled = true
timeLabel.TextSize = 8.5
timeLabel.TextXAlignment = Enum.TextXAlignment.Left

-- 第二行：倒计时显示
local toLabel = Instance.new("TextLabel")
toLabel.Name = "ToLabel"
toLabel.Parent = container
toLabel.BackgroundTransparency = 1
toLabel.Position = UDim2.new(0, 0, 0, 18)
toLabel.Size = UDim2.new(0, 12, 0, 18)
toLabel.Font = Enum.Font.GothamSemibold
toLabel.Text = "到"
toLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
toLabel.TextScaled = true
toLabel.TextSize = 8
toLabel.TextXAlignment = Enum.TextXAlignment.Right

-- 目标事件标签（可自定义）
local eventLabel = Instance.new("TextLabel")
eventLabel.Name = "EventLabel"
eventLabel.Parent = container
eventLabel.BackgroundTransparency = 1
eventLabel.Position = UDim2.new(0, 15, 0, 18)
eventLabel.Size = UDim2.new(0, 45, 0, 18)
eventLabel.Font = Enum.Font.GothamSemibold
eventLabel.Text = "元旦"
eventLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
eventLabel.TextScaled = true
eventLabel.TextSize = 8
eventLabel.TextXAlignment = Enum.TextXAlignment.Left

-- "还有"标签
local leftLabel = Instance.new("TextLabel")
leftLabel.Name = "LeftLabel"
leftLabel.Parent = container
leftLabel.BackgroundTransparency = 1
leftLabel.Position = UDim2.new(0, 62, 0, 18)
leftLabel.Size = UDim2.new(0, 25, 0, 18)
leftLabel.Font = Enum.Font.GothamSemibold
leftLabel.Text = "还有"
leftLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
leftLabel.TextScaled = true
leftLabel.TextSize = 8
leftLabel.TextXAlignment = Enum.TextXAlignment.Right

-- 详细时间显示
local detailLabel = Instance.new("TextLabel")
detailLabel.Name = "DetailLabel"
detailLabel.Parent = container
detailLabel.BackgroundTransparency = 1
detailLabel.Position = UDim2.new(0, 90, 0, 18)
detailLabel.Size = UDim2.new(0, 80, 0, 18)
detailLabel.Font = Enum.Font.GothamBold
detailLabel.Text = "计算中..."
detailLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
detailLabel.TextScaled = true
detailLabel.TextSize = 8
detailLabel.TextXAlignment = Enum.TextXAlignment.Left

-- 创建更醒目的切换按钮容器
local switchButton = Instance.new("TextButton")
switchButton.Name = "SwitchButton"
switchButton.Parent = container
switchButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- 深色背景增强对比
switchButton.BorderSizePixel = 0
switchButton.Position = UDim2.new(1, -26, 0, 0) -- 位置微调
switchButton.Size = UDim2.new(0, 26, 0, 22) -- 稍大一些
switchButton.AutoButtonColor = false -- 禁用默认点击变暗
switchButton.ZIndex = 2

-- 添加圆角，使外观更柔和现代
local buttonCorner = Instance.new("UICorner")
buttonCorner.Parent = switchButton
buttonCorner.CornerRadius = UDim.new(0, 5)

-- 添加边框，提升层次感
local buttonStroke = Instance.new("UIStroke")
buttonStroke.Parent = switchButton
buttonStroke.Color = Color3.fromRGB(120, 120, 120)
buttonStroke.Thickness = 1.5
buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- 按钮文字/图标
switchButton.Font = Enum.Font.GothamBold
switchButton.Text = "⏭️" -- 使用更具语义的"下一个"图标
switchButton.TextColor3 = Color3.fromRGB(255, 215, 0) -- 与VIP文字同色，建立关联
switchButton.TextSize = 13

-- 增强悬停效果：提供更明确的视觉反馈
switchButton.MouseEnter:Connect(function()
    buttonStroke.Color = Color3.fromRGB(255, 230, 100) -- 边框高亮
    switchButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- 背景变亮
    switchButton.Text = "🔁" -- 悬停时变为"切换"图标，提示功能
end)

switchButton.MouseLeave:Connect(function()
    buttonStroke.Color = Color3.fromRGB(120, 120, 120)
    switchButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    switchButton.Text = "⏭️" -- 恢复默认图标
end)

-- 增强点击效果：提供触觉般的反馈
switchButton.MouseButton1Down:Connect(function()
    switchButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    switchButton.Position = UDim2.new(1, -26, 0, 1) -- 模拟按下效果
end)

switchButton.MouseButton1Up:Connect(function()
    switchButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    switchButton.Position = UDim2.new(1, -26, 0, 0)
end)

-- 默认主题
local defaultTheme = {
    name = "默认",
    vipColor = Color3.fromRGB(255, 215, 0), -- 金色
    vipGlowColor = Color3.fromRGB(255, 230, 100),
    timeColor = "rainbow", -- 彩虹色
    eventColor = Color3.fromRGB(0, 200, 255), -- 青色
    detailColor = Color3.fromRGB(255, 100, 100), -- 红色
    buttonColor = Color3.fromRGB(255, 215, 0), -- 金色
    backgroundColor = Color3.fromRGB(30, 30, 30), -- 深灰背景
    specialEffect = "none"
}

-- 当前主题变量
local currentTheme = defaultTheme

-- 彩虹颜色逻辑
local Hue = 0
local function HSVToRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q end
    
    return Color3.new(r, g, b)
end

-- 优化后的中国节日数据库（每个节日都有独特的颜色和特效）
local ChineseFestivals = {
    -- 元旦主题：红色喜庆，雪花特效
    {
        name = "元旦", 
        month = 1, 
        day = 1, 
        color = Color3.fromRGB(255, 50, 50), -- 正红色
        theme = {
            name = "元旦主题",
            vipColor = Color3.fromRGB(255, 50, 50), -- 正红色，喜庆
            vipGlowColor = Color3.fromRGB(255, 100, 100),
            timeColor = "rainbow", -- 彩虹色增加节日氛围
            eventColor = Color3.fromRGB(255, 50, 50), -- 红色
            detailColor = Color3.fromRGB(255, 100, 100), -- 亮红色
            buttonColor = Color3.fromRGB(255, 50, 50), -- 红色
            backgroundColor = Color3.fromRGB(40, 5, 5), -- 深红背景
            specialEffect = "sparkle" -- 闪烁特效
        }
    },
    
    -- 春节主题：金色喜庆，烟花特效
    {
        name = "春节", 
        month = 1, 
        day = 28, 
        color = Color3.fromRGB(255, 215, 0), -- 金色
        theme = {
            name = "春节主题",
            vipColor = Color3.fromRGB(255, 215, 0), -- 金色，富贵吉祥
            vipGlowColor = Color3.fromRGB(255, 230, 100),
            timeColor = Color3.fromRGB(255, 240, 150), -- 浅金色
            eventColor = Color3.fromRGB(255, 215, 0), -- 金色
            detailColor = Color3.fromRGB(255, 180, 0), -- 橙色
            buttonColor = Color3.fromRGB(255, 215, 0), -- 金色
            backgroundColor = Color3.fromRGB(50, 30, 10), -- 深金背景
            specialEffect = "golden_pulse" -- 金色脉动特效
        }
    },
    
    -- 元宵节主题：粉色浪漫，灯笼特效
    {
        name = "元宵节", 
        month = 2, 
        day = 12, 
        color = Color3.fromRGB(255, 120, 180), -- 粉色
        theme = {
            name = "元宵节主题",
            vipColor = Color3.fromRGB(255, 120, 180), -- 粉色，浪漫
            vipGlowColor = Color3.fromRGB(255, 160, 200),
            timeColor = Color3.fromRGB(255, 200, 220), -- 浅粉色
            eventColor = Color3.fromRGB(255, 120, 180), -- 粉色
            detailColor = Color3.fromRGB(255, 80, 150), -- 深粉色
            buttonColor = Color3.fromRGB(255, 120, 180), -- 粉色
            backgroundColor = Color3.fromRGB(50, 20, 35), -- 深粉背景
            specialEffect = "lantern_glow" -- 灯笼光晕特效
        }
    },
    
    -- 清明节主题：青色清新，雨滴特效
    {
        name = "清明节", 
        month = 4, 
        day = 4, 
        color = Color3.fromRGB(80, 220, 120), -- 青绿色
        theme = {
            name = "清明节主题",
            vipColor = Color3.fromRGB(80, 220, 120), -- 青绿色，清新
            vipGlowColor = Color3.fromRGB(130, 240, 150),
            timeColor = Color3.fromRGB(180, 240, 200), -- 浅青绿色
            eventColor = Color3.fromRGB(80, 220, 120), -- 青绿色
            detailColor = Color3.fromRGB(50, 200, 100), -- 深青绿色
            buttonColor = Color3.fromRGB(80, 220, 120), -- 青绿色
            backgroundColor = Color3.fromRGB(15, 40, 25), -- 深绿背景
            specialEffect = "gentle_rain" -- 细雨特效
        }
    },
    
    -- 劳动节主题：橙色活力，工具特效
    {
        name = "劳动节", 
        month = 5, 
        day = 1, 
        color = Color3.fromRGB(255, 140, 50), -- 橙色
        theme = {
            name = "劳动节主题",
            vipColor = Color3.fromRGB(255, 140, 50), -- 橙色，活力
            vipGlowColor = Color3.fromRGB(255, 170, 80),
            timeColor = Color3.fromRGB(255, 200, 150), -- 浅橙色
            eventColor = Color3.fromRGB(255, 140, 50), -- 橙色
            detailColor = Color3.fromRGB(255, 100, 0), -- 深橙色
            buttonColor = Color3.fromRGB(255, 140, 50), -- 橙色
            backgroundColor = Color3.fromRGB(45, 25, 10), -- 深橙背景
            specialEffect = "hammer_spark" -- 锤子火花特效
        }
    },
    
    -- 儿童节主题：多彩欢乐，气球特效
    {
        name = "儿童节", 
        month = 6, 
        day = 1, 
        color = Color3.fromRGB(255, 100, 200), -- 品红
        theme = {
            name = "儿童节主题",
            vipColor = Color3.fromRGB(255, 100, 200), -- 品红，活泼
            vipGlowColor = "rainbow_cycle", -- 彩虹循环特效
            timeColor = "rainbow", -- 彩虹色
            eventColor = Color3.fromRGB(100, 200, 255), -- 天蓝色
            detailColor = Color3.fromRGB(255, 50, 150), -- 深品红
            buttonColor = Color3.fromRGB(255, 100, 200), -- 品红
            backgroundColor = Color3.fromRGB(25, 20, 45), -- 深蓝紫背景
            specialEffect = "colorful_bubbles" -- 多彩气泡特效
        }
    },
    
    -- 端午节主题：青色传统，龙舟特效
    {
        name = "端午节", 
        month = 5, 
        day = 31, 
        color = Color3.fromRGB(60, 200, 140), -- 青色
        theme = {
            name = "端午节主题",
            vipColor = Color3.fromRGB(60, 200, 140), -- 青色，传统
            vipGlowColor = Color3.fromRGB(100, 220, 170),
            timeColor = Color3.fromRGB(160, 230, 190), -- 浅青色
            eventColor = Color3.fromRGB(60, 200, 140), -- 青色
            detailColor = Color3.fromRGB(40, 180, 120), -- 深青色
            buttonColor = Color3.fromRGB(60, 200, 140), -- 青色
            backgroundColor = Color3.fromRGB(15, 40, 30), -- 深青背景
            specialEffect = "dragon_breath" -- 龙息特效
        }
    },
    
    -- 七夕节主题：紫色浪漫，星空特效
    {
        name = "七夕节", 
        month = 8, 
        day = 29, 
        color = Color3.fromRGB(180, 80, 220), -- 紫色
        theme = {
            name = "七夕节主题",
            vipColor = Color3.fromRGB(180, 80, 220), -- 紫色，浪漫
            vipGlowColor = Color3.fromRGB(200, 120, 240),
            timeColor = Color3.fromRGB(220, 180, 240), -- 浅紫色
            eventColor = Color3.fromRGB(180, 80, 220), -- 紫色
            detailColor = Color3.fromRGB(160, 60, 200), -- 深紫色
            buttonColor = Color3.fromRGB(180, 80, 220), -- 紫色
            backgroundColor = Color3.fromRGB(35, 15, 45), -- 深紫背景
            specialEffect = "starry_night" -- 星空特效
        }
    },
    
    -- 中秋节主题：黄色温馨，月亮特效
    {
        name = "中秋节", 
        month = 9, 
        day = 29, 
        color = Color3.fromRGB(255, 220, 100), -- 黄色
        theme = {
            name = "中秋节主题",
            vipColor = Color3.fromRGB(255, 220, 100), -- 黄色，温馨
            vipGlowColor = Color3.fromRGB(255, 240, 150),
            timeColor = Color3.fromRGB(255, 240, 180), -- 浅黄色
            eventColor = Color3.fromRGB(255, 220, 100), -- 黄色
            detailColor = Color3.fromRGB(255, 180, 50), -- 橙色
            buttonColor = Color3.fromRGB(255, 220, 100), -- 黄色
            backgroundColor = Color3.fromRGB(40, 30, 15), -- 深黄背景
            specialEffect = "moon_glow" -- 月亮光晕特效
        }
    },
    
    -- 重阳节主题：橙色秋意，菊花特效
    {
        name = "重阳节", 
        month = 10, 
        day = 29, 
        color = Color3.fromRGB(255, 150, 60), -- 橙色
        theme = {
            name = "重阳节主题",
            vipColor = Color3.fromRGB(255, 150, 60), -- 橙色，秋意
            vipGlowColor = Color3.fromRGB(255, 180, 90),
            timeColor = Color3.fromRGB(255, 210, 150), -- 浅橙色
            eventColor = Color3.fromRGB(255, 150, 60), -- 橙色
            detailColor = Color3.fromRGB(220, 120, 30), -- 深橙色
            buttonColor = Color3.fromRGB(255, 150, 60), -- 橙色
            backgroundColor = Color3.fromRGB(40, 25, 10), -- 深橙背景
            specialEffect = "chrysanthemum_petal" -- 菊花花瓣特效
        }
    },
    
    -- 国庆节主题：红色庄严，烟花特效
    {
        name = "国庆节", 
        month = 10, 
        day = 1, 
        color = Color3.fromRGB(255, 40, 40), -- 深红色
        theme = {
            name = "国庆节主题",
            vipColor = Color3.fromRGB(255, 40, 40), -- 深红色，庄严
            vipGlowColor = Color3.fromRGB(255, 80, 80),
            timeColor = Color3.fromRGB(255, 150, 150), -- 浅红色
            eventColor = Color3.fromRGB(255, 40, 40), -- 深红色
            detailColor = Color3.fromRGB(220, 0, 0), -- 红色
            buttonColor = Color3.fromRGB(255, 40, 40), -- 深红色
            backgroundColor = Color3.fromRGB(45, 10, 10), -- 深红背景
            specialEffect = "fireworks" -- 烟花特效
        }
    }
}

-- 特效管理器
local EffectManager = {
    activeEffects = {},
    lastEffectTime = 0,
    effectInterval = 0.1
}

-- 初始化特效
function EffectManager:init()
    self.activeEffects = {}
end

-- 应用特效
function EffectManager:applyEffect(effectName)
    -- 清除之前的特效
    for _, effect in pairs(self.activeEffects) do
        if effect.cleanup then
            pcall(effect.cleanup)
        end
    end
    self.activeEffects = {}
    
    -- 应用新特效
    if effectName == "sparkle" then
        self:applySparkleEffect()
    elseif effectName == "golden_pulse" then
        self:applyGoldenPulseEffect()
    elseif effectName == "lantern_glow" then
        self:applyLanternGlowEffect()
    elseif effectName == "gentle_rain" then
        self:applyGentleRainEffect()
    elseif effectName == "hammer_spark" then
        self:applyHammerSparkEffect()
    elseif effectName == "colorful_bubbles" then
        self:applyColorfulBubblesEffect()
    elseif effectName == "dragon_breath" then
        self:applyDragonBreathEffect()
    elseif effectName == "starry_night" then
        self:applyStarryNightEffect()
    elseif effectName == "moon_glow" then
        self:applyMoonGlowEffect()
    elseif effectName == "chrysanthemum_petal" then
        self:applyChrysanthemumPetalEffect()
    elseif effectName == "fireworks" then
        self:applyFireworksEffect()
    elseif effectName == "rainbow_cycle" then
        self:applyRainbowCycleEffect()
    end
end

-- 雪花闪烁特效（元旦）
function EffectManager:applySparkleEffect()
    local effect = {
        update = function()
            local pulse = 0.3 + math.sin(tick() * 6) * 0.4
            vipGlow.Transparency = pulse
            vipGlow.Thickness = 1.5 + math.sin(tick() * 3) * 0.5
        end,
        cleanup = function()
            vipGlow.Transparency = 0.5
            vipGlow.Thickness = 1.2
        end
    }
    table.insert(self.activeEffects, effect)
end

-- 金色脉动特效（春节）
function EffectManager:applyGoldenPulseEffect()
    local effect = {
        update = function()
            local pulse = 0.4 + math.sin(tick() * 2) * 0.3
            vipGlow.Transparency = pulse
            local goldPulse = 0.8 + math.sin(tick() * 1.5) * 0.2
            vipGlow.Color = Color3.fromRGB(255, 200 + math.sin(tick() * 2) * 55, 50 + math.sin(tick() * 3) * 50)
        end,
        cleanup = function()
            vipGlow.Transparency = 0.5
            vipGlow.Color = currentTheme.vipGlowColor
        end
    }
    table.insert(self.activeEffects, effect)
end

-- 灯笼光晕特效（元宵节）
function EffectManager:applyLanternGlowEffect()
    local effect = {
        update = function()
            local glow = 0.4 + math.sin(tick() * 1.8) * 0.3
            vipGlow.Transparency = glow
            vipLabel.TextTransparency = 0.1 + math.sin(tick() * 2) * 0.1
        end,
        cleanup = function()
            vipGlow.Transparency = 0.5
            vipLabel.TextTransparency = 0
        end
    }
    table.insert(self.activeEffects, effect)
end

-- 细雨特效（清明节）
function EffectManager:applyGentleRainEffect()
    local effect = {
        update = function()
            local gentlePulse = 0.5 + math.sin(tick() * 1.2) * 0.2
            vipGlow.Transparency = gentlePulse
            vipGlow.Color = Color3.fromRGB(100 + math.sin(tick() * 1.5) * 40, 220, 120 + math.sin(tick() * 2) * 40)
        end,
        cleanup = function()
            vipGlow.Transparency = 0.5
            vipGlow.Color = currentTheme.vipGlowColor
        end
    }
    table.insert(self.activeEffects, effect)
end

-- 锤子火花特效（劳动节）
function EffectManager:applyHammerSparkEffect()
    local effect = {
        update = function()
            local spark = 0.3 + math.sin(tick() * 4) * 0.4
            vipGlow.Transparency = spark
            vipGlow.Thickness = 1.3 + math.sin(tick() * 5) * 0.4
        end,
        cleanup = function()
            vipGlow.Transparency = 0.5
            vipGlow.Thickness = 1.2
        end
    }
    table.insert(self.activeEffects, effect)
end

-- 彩虹循环特效
function EffectManager:applyRainbowCycleEffect()
    local effect = {
        update = function()
            local hue = (tick() * 0.3) % 1
            vipGlow.Color = HSVToRGB(hue, 0.9, 1)
        end,
        cleanup = function()
            vipGlow.Color = currentTheme.vipGlowColor
        end
    }
    table.insert(self.activeEffects, effect)
end

-- 多彩气泡特效（儿童节）
function EffectManager:applyColorfulBubblesEffect()
    local effect = {
        update = function()
            local hue = (tick() * 0.5) % 1
            vipGlow.Color = HSVToRGB(hue, 0.8, 1)
            vipGlow.Transparency = 0.4 + math.sin(tick() * 3) * 0.3
        end,
        cleanup = function()
            vipGlow.Transparency = 0.5
            vipGlow.Color = currentTheme.vipGlowColor
        end
    }
    table.insert(self.activeEffects, effect)
end

-- 龙息特效（端午节）
function EffectManager:applyDragonBreathEffect()
    local effect = {
        update = function()
            local breath = 0.4 + math.sin(tick() * 2.5) * 0.3
            vipGlow.Transparency = breath
            local r = 60 + math.sin(tick() * 2) * 20
            local g = 200 + math.sin(tick() * 1.5) * 30
            local b = 140 + math.sin(tick() * 3) * 20
            vipGlow.Color = Color3.fromRGB(r, g, b)
        end,
        cleanup = function()
            vipGlow.Transparency = 0.5
            vipGlow.Color = currentTheme.vipGlowColor
        end
    }
    table.insert(self.activeEffects, effect)
end

-- 星空特效（七夕节）
function EffectManager:applyStarryNightEffect()
    local effect = {
        update = function()
            local starTwinkle = 0.3 + math.sin(tick() * 5) * 0.4
            vipGlow.Transparency = starTwinkle
            local r = 180 + math.sin(tick() * 2) * 20
            local g = 80 + math.sin(tick() * 3) * 20
            local b = 220 + math.sin(tick() * 1.5) * 20
            vipGlow.Color = Color3.fromRGB(r, g, b)
        end,
        cleanup = function()
            vipGlow.Transparency = 0.5
            vipGlow.Color = currentTheme.vipGlowColor
        end
    }
    table.insert(self.activeEffects, effect)
end

-- 月亮光晕特效（中秋节）
function EffectManager:applyMoonGlowEffect()
    local effect = {
        update = function()
            local moonGlow = 0.4 + math.sin(tick() * 1.2) * 0.3
            vipGlow.Transparency = moonGlow
            vipLabel.TextColor3 = Color3.fromRGB(
                255, 
                220 + math.sin(tick() * 1.5) * 35, 
                100 + math.sin(tick() * 2) * 50
            )
        end,
        cleanup = function()
            vipGlow.Transparency = 0.5
            vipLabel.TextColor3 = currentTheme.vipColor
        end
    }
    table.insert(self.activeEffects, effect)
end

-- 菊花花瓣特效（重阳节）
function EffectManager:applyChrysanthemumPetalEffect()
    local effect = {
        update = function()
            local petal = 0.5 + math.sin(tick() * 2) * 0.3
            vipGlow.Transparency = petal
            vipGlow.Thickness = 1.2 + math.sin(tick() * 1.8) * 0.6
        end,
        cleanup = function()
            vipGlow.Transparency = 0.5
            vipGlow.Thickness = 1.2
        end
    }
    table.insert(self.activeEffects, effect)
end

-- 烟花特效（国庆节）
function EffectManager:applyFireworksEffect()
    local effect = {
        update = function()
            local firework = 0.2 + math.sin(tick() * 7) * 0.5
            vipGlow.Transparency = firework
            vipGlow.Thickness = 1 + math.sin(tick() * 6) * 0.8
        end,
        cleanup = function()
            vipGlow.Transparency = 0.5
            vipGlow.Thickness = 1.2
        end
    }
    table.insert(self.activeEffects, effect)
end

-- 更新所有特效
function EffectManager:updateAllEffects()
    local currentTime = tick()
    if currentTime - self.lastEffectTime > self.effectInterval then
        for _, effect in pairs(self.activeEffects) do
            if effect.update then
                pcall(effect.update)
            end
        end
        self.lastEffectTime = currentTime
    end
end

-- 初始化特效管理器
EffectManager:init()

-- 检测今天是哪个节日
local function checkTodayIsFestival()
    local currentTime = os.time()
    local currentMonth = tonumber(os.date("%m", currentTime))
    local currentDay = tonumber(os.date("%d", currentTime))
    
    for _, festival in ipairs(ChineseFestivals) do
        if festival.month == currentMonth and festival.day == currentDay then
            return festival
        end
    end
    return nil
end

-- 应用主题函数
local function applyTheme(theme)
    currentTheme = theme
    
    -- 应用VIP标签颜色
    vipLabel.TextColor3 = theme.vipColor
    vipGlow.Color = theme.vipGlowColor
    
    -- 应用事件标签颜色
    eventLabel.TextColor3 = theme.color or theme.eventColor
    
    -- 应用按钮颜色
    switchButton.TextColor3 = theme.buttonColor
    
    -- 应用特效
    if theme.specialEffect and theme.specialEffect ~= "none" then
        EffectManager:applyEffect(theme.specialEffect)
    else
        EffectManager:applyEffect("none")
    end
    
    print("已应用主题: " .. theme.name .. " - 特效: " .. (theme.specialEffect or "无"))
end

-- 应用默认主题
local function applyDefaultTheme()
    applyTheme(defaultTheme)
end

-- 获取下一个节日
local function getNextFestival()
    local currentTime = os.time()
    local currentYear = tonumber(os.date("%Y", currentTime))
    local nextFestival = nil
    local minDiff = math.huge
    
    for _, festival in ipairs(ChineseFestivals) do
        -- 计算今年该节日的日期
        local festivalTime = os.time({
            year = currentYear,
            month = festival.month,
            day = festival.day,
            hour = 0,
            min = 0,
            sec = 0
        })
        
        -- 如果今年节日已过，考虑明年
        if festivalTime < currentTime then
            festivalTime = os.time({
                year = currentYear + 1,
                month = festival.month,
                day = festival.day,
                hour = 0,
                min = 0,
                sec = 0
            })
        end
        
        local diff = festivalTime - currentTime
        
        if diff < minDiff and diff > 0 then
            minDiff = diff
            nextFestival = festival
            nextFestival.time = festivalTime
        end
    end
    
    return nextFestival
end

-- VIP闪烁动画
local function vipPulseAnimation()
    while task.wait() and vipLabel and vipLabel.Parent do
        local pulse = 0.4 + math.sin(tick() * 1.8) * 0.08
        vipGlow.Transparency = pulse
        vipLabel.TextTransparency = 0.15 + math.abs(math.sin(tick() * 3.5)) * 0.08
    end
end

-- 计算目标时间
local function getNextTargetTime()
    local nextFestival = getNextFestival()
    if nextFestival then
        eventLabel.Text = nextFestival.name
        return nextFestival.time
    end
    
    -- 默认返回下一个元旦
    local currentTime = os.time()
    local currentYear = tonumber(os.date("%Y", currentTime))
    eventLabel.Text = "元旦"
    
    return os.time({
        year = currentYear + 1,
        month = 1,
        day = 1,
        hour = 0,
        min = 0,
        sec = 0
    })
end

-- 计算详细时间差
local function calculateDetailedTime(targetTime)
    local currentTime = os.time()
    local diff = targetTime - currentTime
    
    -- 检查今天是否是节日
    local todayFestival = checkTodayIsFestival()
    if todayFestival then
        -- 今天是节日，显示庆祝信息
        detailLabel.TextColor3 = todayFestival.color
        return "节日快乐！🎉"
    end
    
    if diff <= 0 then
        return "已到达"
    end
    
    local years = math.floor(diff / (365 * 24 * 60 * 60))
    diff = diff % (365 * 24 * 60 * 60)
    
    local months = math.floor(diff / (30 * 24 * 60 * 60))
    diff = diff % (30 * 24 * 60 * 60)
    
    local days = math.floor(diff / (24 * 60 * 60))
    diff = diff % (24 * 60 * 60)
    
    local hours = math.floor(diff / (60 * 60))
    diff = diff % (60 * 60)
    
    local minutes = math.floor(diff / 60)
    local seconds = diff % 60
    
    if years > 0 then
        return string.format("%d年%d月%d日", years, months, days)
    elseif months > 0 then
        return string.format("%d月%d日%02d时", months, days, hours)
    elseif days > 0 then
        return string.format("%d日%02d:%02d", days, hours, minutes)
    else
        return string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end
end

-- 计算简短时间差
local function calculateShortTime(targetTime)
    local currentTime = os.time()
    local diff = targetTime - currentTime
    local days = math.floor(diff / (24 * 60 * 60))
    return days
end

-- 设置自定义事件函数
function SetCustomEvent(eventName, targetTime, color)
    if eventLabel then
        eventLabel.Text = eventName
        eventLabel.TextColor3 = color or defaultTheme.eventColor
    end
    return targetTime
end

-- 获取当前目标时间
local currentTargetTime = getNextTargetTime()

-- 主更新循环
local lastCheckDate = ""
local function UpdateDisplay()
    if not timeLabel or not timeLabel.Parent then return end
    
    -- 时间标签颜色处理
    if currentTheme.timeColor == "rainbow" then
        -- 彩虹颜色平滑过渡
        Hue = (Hue + 0.006) % 1
        timeLabel.TextColor3 = HSVToRGB(Hue, 0.8, 1)
    else
        -- 使用主题颜色
        timeLabel.TextColor3 = currentTheme.timeColor
    end
    
    -- 时间实时更新
    timeLabel.Text = os.date("%H:%M:%S")
    
    -- 更新特效
    EffectManager:updateAllEffects()
    
    -- 每天检查一次是否是节日
    local currentDate = os.date("%m-%d")
    if currentDate ~= lastCheckDate then
        lastCheckDate = currentDate
        
        -- 检查今天是否是节日
        local todayFestival = checkTodayIsFestival()
        if todayFestival then
            -- 今天是节日，立即应用节日主题
            eventLabel.Text = todayFestival.name
            eventLabel.TextColor3 = todayFestival.color
            
            -- 应用节日主题
            applyTheme(todayFestival.theme)
            
            -- 设置倒计时为"节日快乐"
            detailLabel.Text = "节日快乐！🎉"
            detailLabel.TextColor3 = todayFestival.color
            
            print("🎊 今天是 " .. todayFestival.name .. "！已自动应用节日主题 🎊")
        else
            -- 不是节日，恢复默认主题
            applyDefaultTheme()
            -- 重新获取下一个节日
            currentTargetTime = getNextTargetTime()
        end
    end
    
    -- 更新详细倒计时（如果不是节日当天）
    if detailLabel and detailLabel.Text ~= "节日快乐！🎉" then
        local detailedTime = calculateDetailedTime(currentTargetTime)
        detailLabel.Text = detailedTime
        
        -- 根据剩余天数设置颜色
        local daysLeft = calculateShortTime(currentTargetTime)
        if daysLeft <= 7 then
            detailLabel.TextColor3 = Color3.fromRGB(255, 50, 50)  -- 红色警报
        elseif daysLeft <= 30 then
            detailLabel.TextColor3 = Color3.fromRGB(255, 150, 50)  -- 橙色警告
        else
            detailLabel.TextColor3 = defaultTheme.detailColor or Color3.fromRGB(50, 255, 100)
        end
    end
    
    -- 每天检查是否需要更新目标节日
    if os.date("%H:%M") == "00:00" and not checkTodayIsFestival() then
        currentTargetTime = getNextTargetTime()
    end
end

-- 节日切换功能
local currentFestivalIndex = 1

local function updateFestivalListForDisplay()
    -- 获取按时间排序的节日列表
    local currentTime = os.time()
    local currentYear = tonumber(os.date("%Y", currentTime))
    local festivalList = {}
    
    for _, festival in ipairs(ChineseFestivals) do
        local festivalTime = os.time({
            year = currentYear,
            month = festival.month,
            day = festival.day,
            hour = 0,
            min = 0,
            sec = 0
        })
        
        if festivalTime < currentTime then
            festivalTime = os.time({
                year = currentYear + 1,
                month = festival.month,
                day = festival.day,
                hour = 0,
                min = 0,
                sec = 0
            })
        end
        
        table.insert(festivalList, {
            name = festival.name,
            time = festivalTime,
            color = festival.color,
            theme = festival.theme,
            diff = festivalTime - currentTime
        })
    end
    
    -- 按时间排序
    table.sort(festivalList, function(a, b)
        return a.diff < b.diff
    end)
    
    return festivalList
end

-- 切换到下一个节日（使用默认主题）
local function switchToNextFestival()
    local festivalList = updateFestivalListForDisplay()
    
    -- 查找当前节日在列表中的位置
    local currentEvent = eventLabel.Text
    local foundIndex = 1
    
    for i, festival in ipairs(festivalList) do
        if festival.name == currentEvent then
            foundIndex = i
            break
        end
    end
    
    -- 计算下一个索引
    local nextIndex = foundIndex + 1
    if nextIndex > #festivalList then
        nextIndex = 1
    end
    
    -- 应用下一个节日（但使用默认主题）
    local nextFestival = festivalList[nextIndex]
    eventLabel.Text = nextFestival.name
    currentTargetTime = nextFestival.time
    
    -- 重置节日快乐显示
    detailLabel.Text = calculateDetailedTime(currentTargetTime)
    
    -- 增强的点击反馈：快速颜色闪烁
    local originalColor = switchButton.BackgroundColor3
    switchButton.BackgroundColor3 = nextFestival.color
    
    -- 播放切换动画
    switchButton.Text = "✓"
    switchButton.TextColor3 = Color3.fromRGB(100, 255, 100)
    
    task.wait(0.5)
    
    switchButton.Text = "⏭️"
    switchButton.TextColor3 = currentTheme.buttonColor
    switchButton.BackgroundColor3 = originalColor
    
    print("已切换到节日：" .. nextFestival.name .. " - 使用默认主题")
end

-- 绑定按钮点击事件
switchButton.MouseButton1Click:Connect(switchToNextFestival)

-- 初始化时检测今天是否是节日
local todayFestival = checkTodayIsFestival()
if todayFestival then
    print("🎉 今天是 " .. todayFestival.name .. "！自动应用节日主题 🎊")
    eventLabel.Text = todayFestival.name
    eventLabel.TextColor3 = todayFestival.color
    applyTheme(todayFestival.theme)
    detailLabel.Text = "节日快乐！🎉"
    detailLabel.TextColor3 = todayFestival.color
else
    print("今天不是节日，使用默认主题")
    applyDefaultTheme()
end

-- 启动动画
coroutine.wrap(function()
    pcall(vipPulseAnimation)
end)()

-- 启动主更新循环（包括特效更新）
game:GetService("RunService").Heartbeat:Connect(UpdateDisplay)

-- 节日切换函数（保持向后兼容，使用默认主题）
function SwitchToFestival(festivalName)
    for _, festival in ipairs(ChineseFestivals) do
        if festival.name == festivalName then
            local currentYear = tonumber(os.date("%Y"))
            local festivalTime = os.time({
                year = currentYear,
                month = festival.month,
                day = festival.day,
                hour = 0,
                min = 0,
                sec = 0
            })
            
            if festivalTime < os.time() then
                festivalTime = os.time({
                    year = currentYear + 1,
                    month = festival.month,
                    day = festival.day,
                    hour = 0,
                    min = 0,
                    sec = 0
                })
            end
            
            currentTargetTime = SetCustomEvent(festival.name, festivalTime, festival.color)
            
            -- 重置节日快乐显示
            detailLabel.Text = calculateDetailedTime(festivalTime)
            
            print("已切换到节日：" .. festivalName .. " - 使用默认主题")
            return true
        end
    end
    return false
end

-- 主题切换函数（仅用于测试，不受日期限制）
function SwitchToTheme(themeName)
    for _, festival in ipairs(ChineseFestivals) do
        if festival.theme and festival.theme.name == themeName then
            applyTheme(festival.theme)
            return true
        end
    end
    print("未找到主题: " .. themeName)
    return false
end

print("中国节日倒计时系统已加载！")
print("支持节日：元旦、春节、元宵节、清明节、劳动节、儿童节、端午节、七夕节、中秋节、重阳节、国庆节")
print("每个节日都有独特的主题颜色和特效！")
print("只有在节日当天，系统才会自动切换到对应的节日主题！")
print("手动切换节日时，始终使用默认主题！")
print("点击右上角的⏭️按钮可以切换到下一个节日")
print("也可以使用 SwitchToFestival('节日名称') 来手动切换到特定节日")
