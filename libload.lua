-- [[ Reaper Hub - Smooth Fade & Blur Edition ]] --

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LogService = game:GetService("LogService")

-- 1. Setup Effects (เบลอทันที)
local function ClearEffects()
    for _, v in pairs(Lighting:GetChildren()) do
        if v.Name == "ReaperEffect" then v:Destroy() end
    end
end
ClearEffects()

local blur = Instance.new("BlurEffect")
blur.Name = "ReaperEffect"
blur.Size = 56
blur.Parent = Lighting

local colorCorr = Instance.new("ColorCorrectionEffect")
colorCorr.Name = "ReaperEffect"
colorCorr.Brightness = -0.1
colorCorr.Parent = Lighting

-- 2. UI Structure
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ReaperLoadingUI"
screenGui.Parent = CoreGui
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 99999

local canvasGroup = Instance.new("CanvasGroup")
canvasGroup.Size = UDim2.new(1, 0, 1, 0)
canvasGroup.BackgroundTransparency = 1
canvasGroup.GroupTransparency = 1 -- เริ่มที่โปร่งใสเพื่อทำ Fade In
canvasGroup.Parent = screenGui

-- Background (โปร่งแสงเห็น Blur)
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.BackgroundTransparency = 0.45 
bg.BorderSizePixel = 0
bg.Parent = canvasGroup

-- [[ LOGO & LABELS ]] --
local logo = Instance.new("ImageLabel")
logo.Image = "rbxassetid://131279093559313"
logo.Size = UDim2.new(0, 145, 0, 145)
logo.Position = UDim2.new(0.5, 0, 0.35, 0)
logo.AnchorPoint = Vector2.new(0.5, 0.5)
logo.BackgroundTransparency = 1
logo.Parent = canvasGroup

local title = Instance.new("TextLabel")
title.Text = "REAPER HUB"
title.Font = Enum.Font.Michroma
title.TextSize = 55
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Position = UDim2.new(0.5, 0, 0.52, 0)
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.BackgroundTransparency = 1
title.Parent = canvasGroup

local subtitle = Instance.new("TextLabel")
subtitle.Text = "Initializing..."
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 13
subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitle.Position = UDim2.new(0.5, 0, 0.58, 0)
subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
subtitle.BackgroundTransparency = 1
subtitle.Parent = canvasGroup

local phrases = {
    "Initializing...",
    "Reaper Hub Better",
    "Credit : x2sxqz_",
    "Project by NongDiw",
    "Official Discord",
    "https://discord.gg/RPVTDFZyhw"
}

-- Loading Bar
local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0, 260, 0, 3)
barBg.Position = UDim2.new(0.5, 0, 0.63, 0)
barBg.AnchorPoint = Vector2.new(0.5, 0.5)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBg.BorderSizePixel = 0
barBg.Parent = canvasGroup

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
barFill.BorderSizePixel = 0
barFill.Parent = barBg

-- 3. Logic & Smooth Fade
local isLoaded = false

local function StartAnims()
    -- Smooth Fade In
    TweenService:Create(canvasGroup, TweenInfo.new(1.2, Enum.EasingStyle.Quart), {GroupTransparency = 0}):Play()
    
    -- Subtitle Cycling
    task.spawn(function()
        local i = 1
        while not isLoaded do
            subtitle.Text = phrases[i]
            TweenService:Create(subtitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
            task.wait(2.5)
            if isLoaded then break end
            local f = TweenService:Create(subtitle, TweenInfo.new(0.5), {TextTransparency = 1})
            f:Play()
            f.Completed:Wait()
            i = i % #phrases + 1
        end
    end)

    -- Smart Progress (92%)
    TweenService:Create(barFill, TweenInfo.new(18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0.92, 0, 1, 0)}):Play()
end

local function Finalize()
    if isLoaded then return end
    isLoaded = true
    
    subtitle.Text = "READY"
    TweenService:Create(barFill, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(0.6)
    
    -- [[ Smooth Fade Out Outro ]]
    local outInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    TweenService:Create(blur, outInfo, {Size = 0}):Play()
    TweenService:Create(colorCorr, outInfo, {Brightness = 0}):Play()
    
    local exit = TweenService:Create(canvasGroup, outInfo, {GroupTransparency = 1})
    exit:Play()
    exit.Completed:Wait()
    screenGui:Destroy()
end

-- 4. Execution
StartAnims()

LogService.MessageOut:Connect(function(msg)
    if msg:find("Reaper Hub Loaded") then
        Finalize()
    end
end)

task.delay(30, function() if not isLoaded then Finalize() end end)
