-- ====================== UI文本自动汉化（前置模块，不删原内容）======================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
-- 汉化文本配置（整合原脚本所有翻译项，不重复）
local Translations = {
    ["CloseWindowTitle"] = "关闭窗口",
    ["CloseWindowConfirm"] = "求你了别关脚本😭😭😭😭",
    ["CancelBtn"] = "取消",
    ["CloseBtn"] = "关闭窗口",
    ["LockedText"] = "锁定",
    ["Close Window"] = "关闭窗口",
    ["Do you want to close this window? You will not be able to open it again."] = "求你了别关脚本😭😭😭😭，再用用呗🙏🙏🙏🙏🙏🙏",
    ["Cancel"] = "取消",
    ["Locked"] = "锁定",
    ["Search"] = "搜索",
    ["No results found."] = "没有",
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

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/raw/main/dist/main.lua"))()

local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaodi7598/-1.0/refs/heads/main/%E9%80%9A%E7%9F%A51.lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaodi7598/-1.0/refs/heads/main/%E9%80%9A%E7%9F%A52.lua"))()

Notification:Notify(
    {Title = "欢迎使用小迪黑白脚本", Description = "请加入QQ群：946671668"},
    {OutlineColor = Color3.fromRGB(255, 255, 255), Time = 9, Type = "image"},
    {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(150, 150, 150)}
)

local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaodi7598/-1.0/refs/heads/main/%E9%80%9A%E7%9F%A51.lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaodi7598/-1.0/refs/heads/main/%E9%80%9A%E7%9F%A52.lua"))()

Notification:Notify(
    {Title = "已开启反挂机", Description = "作者帮助你开启反挂机了"},
    {OutlineColor = Color3.fromRGB(255, 255, 255), Time = 9, Type = "image"},
    {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(150, 150, 150)}
)

-- 反挂机脚本保持不变
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

local Window = WindUI:CreateWindow({
    Title = '<font color="#FF3333">黑</font><font color="#FF9933">白</font><font color="#FFFF33">脚</font><font color="#33FF33">本</font>',  
    Icon = "rbxassetid://7040347038",
    Author = "作者:小迪",
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
    Background = "rbxassetid://75083826531216",
})

-- 定义浮动参数：幅度（像素）、速度（秒）
local floatAmplitude = 2 -- 上下浮动的幅度（越小越轻微）
local floatSpeed = 2 -- 浮动周期（秒）
local currentOffset = 0 -- 当前偏移量

-- 绑定渲染事件，实现动态漂浮
game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
    -- 用正弦函数计算上下偏移（实现平滑浮动）
    currentOffset = math.sin(tick() * (math.pi * 2) / floatSpeed) * floatAmplitude
    -- 动态修改窗口标题的位置（轻微上下移动）
    if Window.TitleLabel then
        Window.TitleLabel.Position = UDim2.new(0, 0, 0, currentOffset)
    end
end)

Window:Tag({
    Title = "诞生于2025年暑假",
    Color = Color3.fromHex("#4169E1")  
})

Window:EditOpenButton({
    Title = "打开黑白脚本2",
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
        ["聊天室💬💬 [阿拉伯语]"] = "eye",
        ["[✨2倍经验✨]植物进化"] = "leaf",
        ["🦘🦘🦘跳跃去见辫inrots！"] = "arrow-up",
        ["钓鱼！ 🐟🐟🐟"] = "fish",
        ["[史莱姆]键盘ASMR塔"] = "keyboard",
        ["[🎣🎣鱼+🐶🐶宠物]安吉尔山🥴🥴"] = "eye",
        ["🍰🍰 烘焙或死亡 💀💀"] = "cake",
        ["打破朋友 🦴🦴🦴"] = "eye",
        ["【⚔⚔️公会战争】[第38卷]修炼：凡人至仙人"] = "scroll",
        ["杀人犯对警长决斗"] = "eye",
        ["🥊🥊拳击怪兽！ 🥊🥊🥊"] = "eye",
        ["隐形藏匿"] = "eye",
        ["[第一人称射击]电影上传者"] = "camera",
        ["成为杀手级重码"] = "skull",
        ["[✨] NPC或者死！ 💢💢"] = "user",
        ["免费UGC✨奥比"] = "gift",
        [" [1.0] 基础论文教育 RP"] = "book",
        ["在筏子上生存"] = "life-ring",
        ["挂杆塔"] = "eye",
        ["捉迷藏"] = "eye",
        ["[更新]🎉🎉动漫拍打塔 🖐🖐🖐️"] = "hand-paper",
        ["[🏈🏈标签]音速速度模拟器"] = "bolt",
        ["终极采矿大亨"] = "pickaxe", -- 采矿核心图标，贴合游戏玩法
        ["无家可归模拟器"] = "person", -- 新增：无家可归模拟器图标，用person贴合人物场景
        ["亡命速递"] = "life-ring",
        ["在超市打架"] = "shopping-cart",
        ["黑暗欺骗"] = "eye",
        ["锻造"] = "hammer",
        ["恐怖电梯"] = "arrow-up",
        ["后悔电梯"] = "arrow-up",
        ["无标题机器人"] = "robot",
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
    Min = 0,
    Max = 1,
    Default = 0.2,
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

local Tab1 = Tab("无家可归模拟器")

-- 无家可归模拟器 (Tab1)
Button(Tab1, "无家可归模拟器1", function()
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local ReduceHunger = ReplicatedStorage.ReduceHunger
        ReduceHunger:FireServer(math.huge)
    end)
end)

local Tab2 = Tab("亡命速递")
-- 亡命速递 (Tab2)
Button(Tab2, "英文", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/VGXMODPLAYER68/Vgxmod-Hub/refs/heads/main/Deadly%20delivery.lua"))()
    end)
end)

Button(Tab2, "需要加入群", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ShenJiaoBen/ScriptLoader/refs/heads/main/Linni_FreeLoader.lua"))()
    end)
end)

local Tab3 = Tab("在超市打架")
-- 在超市打架 (Tab3)
Button(Tab3, "英文", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/FightinaSupermarket"))()
    end)
end)

local Tab4 = Tab("黑暗欺骗")
-- 黑暗欺骗 (Tab4)
Button(Tab4, "英文", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/9kn-1/Dark/main/Auto.lua"))()
    end)
end)

local Tab5 = Tab("锻造")
-- 锻造 (Tab5)
Button(Tab5, "要卡密", function()
    pcall(function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/280c3c5ae0ed18010fea0d86c424fdb5.lua"))()
    end)
end)

Button(Tab5, "无卡密", function()
    pcall(function()
        loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/f3e2379f5d38627e"))()
    end)
end)

local Tab6 = Tab("恐怖电梯")
-- 恐怖电梯 (Tab6)
Button(Tab6, "恐怖电梯里传送到VIP室", function()
    pcall(function()
        local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
        local Window = Library.CreateLib("TITLE", "DarkTheme")
        local Tab = Window:NewTab("TabName")
        local Section = Tab:NewSection("Section Name")

        Section:NewButton("Tp To Vip Room", "ButtonInfo", function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1881.45361328125, -396.8499755859375, 911.4960327148438)
        end)

        Section:NewButton("Tp To Lobby", "ButtonInfo", function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1916.3992919921875, -396.74810791015625, 919.82666015625)
        end)
    end)
end)

local Tab7 = Tab("后悔电梯")
-- 后悔电梯刷钱 (Tab7)
Button(Tab7, "刷钱脚本", function()
    pcall(function()
        loadstring(game:HttpGet('https://gist.githubusercontent.com/474375w/78e054d605cbff8153456f949ef9509e/raw/bce8b53479f1e47f50a16535b76f9c88d064d3e7/sxzy'))()
    end)
end)

Button(Tab7, "手本", function()
    pcall(function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Regretevator-ELEVATOR-SIMULATOR-OP-Script-21449"))()
    end)
end)

local Tab8 = Tab("无标题机器人")
-- 无标题机器人 (Tab8)
Button(Tab8, "脚本一", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/机器人.txt"))()
    end)
end)

local Tab9 = Tab("脑腐进化")
-- 脑腐进化 (Tab9)
Button(Tab9, "脚本一", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/diepedyt/bui/refs/heads/main/BananaHubLoader.lua"))()
    end)
end)

local Tab10 = Tab("🎄逃避🎄")
-- 🎄逃避🎄 (Tab10)
Button(Tab10, "脚本一", function()
    pcall(function()
        --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/EvadeEvent"))()
    end)
end)

local Tab11 = Tab("知名度：一次发薪日®体验")
-- 知名度：一次发薪日®体验 (Tab11)
Button(Tab11, "脚本一", function()
    pcall(function()
        --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://raw.githubusercontent.com/Rhbtx/Updated-Notoriety-/refs/heads/main/Notoriety%20Updated"))()
    end)
end)

local Tab12 = Tab("[❄️冬季节]驾驶帝国🏎️汽车赛车")
-- [❄️冬季节]驾驶帝国🏎️汽车赛车 (Tab12)
Button(Tab12, "脚本一", function()
    pcall(function()
        --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/ef0f370aca817d72e5871e49cd8bded2f696352eae86754a46e4372ce200ffd2/download"))()
    end)
end)

local Tab13 = Tab("[第一人称射击]弗利克")
-- [第一人称射击]弗利克 (Tab13)
Button(Tab13, "脚本一", function()
    pcall(function()
        --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Fominkal/NeverHook-2.0/refs/heads/main/FlickV1.0"))()
    end)
end)

local Tab14 = Tab("重力塔2 ✋")
-- 重力塔2 ✋ (Tab14)
Button(Tab14, "脚本一", function()
    pcall(function()
        --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://raw.githubusercontent.com/AX-Archive/ArceusXArchive/refs/heads/main/2026"))()
    end)
end)

local Tab15 = Tab("头蟹试验3（M1886）")
-- 头蟹试验3（M1886） (Tab15)
Button(Tab15, "脚本一", function()
    pcall(function()
        --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local modif = require(game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Configuration)
modif.fireRate = 0.022
modif.minSpread = 0
modif.maxSpread = 0.01
modif.aimMinSpread = 0
modif.aimMaxSpread = 0.01
modif.screenShakeIntensity = vector.create(0,0,0)
    end)
end)

local Tab16 = Tab("⛏️挖掘逃脱")
-- ⛏️挖掘逃脱 (Tab16)
Button(Tab16, "自动赢", function()
    pcall(function()
        --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://pastefy.app/gS9WFmKI/raw"))()
    end)
end)

local Tab17 = Tab("盲射")
-- 盲射 (Tab17)
Button(Tab17, "盲射脚本1", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/BlindShot"))()
end)

local Tab18 = Tab("格林威尔")
-- 格林威尔 (Tab18)
Button(Tab18, "脚本1", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaodi7598/-1.0/refs/heads/main/%E4%B8%BB%E8%84%9A%E6%9C%AC%E7%AC%AC%E4%BA%8C%E9%83%A8%E5%88%86.lua"))()
    end)
end)
