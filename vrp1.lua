local Load = loadstring(game:HttpGet("https://raw.githubusercontent.com/holisman030/Rph/refs/heads/main/libload.lua"))()
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/holisman030/Rph/refs/heads/main/guiv2.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/holisman030/Rph/refs/heads/main/save.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/holisman030/Rph/refs/heads/main/interface.lua"))()
local icon = loadstring(game:HttpGet("https://raw.githubusercontent.com/holisman030/Rph/refs/heads/main/icon.lua"))()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local VU = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local lighting = Lighting
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local localPlayer = Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")	
local DefaultZoom = LocalPlayer.CameraMaxZoomDistance
local LogService = game:GetService("LogService")
local LP = LocalPlayer
local Camera = workspace.CurrentCamera
local lp = LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Window = Fluent:CreateWindow({
    Title = "REAPER HUB",
    SubTitle = "Violence District",
    TabWidth = 160,
    Size = UDim2.fromOffset(480, 330),
    Theme = "ExtremeReaper",
    MinimizeKey = Enum.KeyCode.RightControl
})

local icon = loadstring(game:HttpGet("https://raw.githubusercontent.com/holisman030/Rph/refs/heads/main/icon.lua"))()

--=========================
-- 🔥Tab
--=========================
local Tabs = {
Status = Window:AddTab({ Title = "Status", Icon = "signal-high" }),
Main = Window:AddTab({ Title = "Main", Icon = "home" }),
Automatic = Window:AddTab({ Title = "Automatic", Icon = "compass" }),
Ability = Window:AddTab({ Title = "Ability", Icon = "eye" }),
Player = Window:AddTab({ Title = "Player", Icon = "user" }),
ESP = Window:AddTab({ Title = "ESP", Icon = "box" }),
Object = Window:AddTab({ Title = "Object", Icon = "layout-grid" }),
Teleport = Window:AddTab({ Title = "Teleport", Icon = "menu" }),
Misc = Window:AddTab({ Title = "Misc", Icon = "copy" }),
Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local PlayerLabel = Tabs.Status:AddParagraph({
    Title = "Players",
    Content = "Loading..."
})

local PingLabel = Tabs.Status:AddParagraph({
    Title = "Ping",
    Content = "Loading..."
})

local FPSLabel = Tabs.Status:AddParagraph({
    Title = "FPS",
    Content = "Loading..."
})

local fps = 60
local frameCount = 0
local timeElapsed = 0

RunService.RenderStepped:Connect(function(dt)
    if dt <= 0 or dt > 0.1 then
        return
    end

    frameCount += 1
    timeElapsed += dt

    if timeElapsed >= 0.5 then
        local rawFps = frameCount / timeElapsed
        rawFps = math.clamp(rawFps, 15, 240)

        fps = math.floor(rawFps + 0.5)

        frameCount = 0
        timeElapsed = 0
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            PlayerLabel:SetDesc(#Players:GetPlayers())

            local ping = 0

            pcall(function()
                ping = math.floor(
                    Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                )
            end)

            PingLabel:SetDesc(ping .. " ms")
            FPSLabel:SetDesc(fps)
        end)

        task.wait(0.5)
    end
end)


--Main
-- Anti Knock
local Antiknksec = Tabs.Main:AddSection("Anti")

getgenv().VD = { SURV_AntiKnock = false }

local FLAGS = { "Knocked", "IsKnocked", "Carried", "IsCarried", "Grabbed", "Ragdolled", "Captured", "Disabled" }
local isSurvivor = false

local function UpdateRole()
    isSurvivor = (lp.Team and lp.Team.Name == "Survivors")
end
lp:GetPropertyChangedSignal("Team"):Connect(UpdateRole)
UpdateRole()

local function VD_RunAntiKnock()
    if not getgenv().VD.SURV_AntiKnock or not isSurvivor then return end
    
    local char = lp.Character
    if not char then return end

    -- เช็คเงื่อนไขแรก (Attributes) อย่างรวดเร็วก่อนเข้า Loop หนัก
    local needsFix = false
    for i = 1, #FLAGS do
        if char:GetAttribute(FLAGS[i]) then
            needsFix = true
            break
        end
    end

    -- ถ้าไม่โดน Knock หรือโดนอุ้ม ให้หยุดการทำงานทันที (ประหยัด CPU มหาศาล)
    if not needsFix then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum then return end

    -- เริ่มการล้างสถานะ
    for i = 1, #FLAGS do
        local flag = FLAGS[i]
        char:SetAttribute(flag, false)
        local obj = char:FindFirstChild(flag)
        if obj then
            if obj:IsA("BoolValue") then obj.Value = false
            elseif obj:IsA("NumberValue") or obj:IsA("IntValue") then obj.Value = 0 end
        end
    end

    -- ปรับสถานะ Humanoid
    hum.PlatformStand = false
    hum.Sit = false
    
    if hum:GetState() == Enum.HumanoidStateType.Physics or hum:GetState() == Enum.HumanoidStateType.Ragdoll then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
    if root then root.AssemblyLinearVelocity = Vector3.zero end
    
    task.defer(function()
        if hum and hum.Parent then
            hum.Health = hum.MaxHealth
            hum.WalkSpeed = 16
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end

Tabs.Main:AddToggle("AntiKnock", {
    Title = "Anti Knock", 
    Default = false 
}):OnChanged(function(Value)
    getgenv().VD.SURV_AntiKnock = Value
end)

RunService.Heartbeat:Connect(VD_RunAntiKnock)

-- Silent Aim
local ToF_Config = {
    Enabled = false,
    Laser = true,
    WallCheck = false,
    BlockKnocked = true,
    TargetMode = "Killer"
}

local ToF_State = {
    Connection = nil,
    InputBegan = nil,
    InputEnded = nil,
    TouchInput = nil,
    IsAiming = false,
    Laser = nil,
    ZombieCache = {},
    ZombieCacheTime = 0,
    InputStarted = false
}

local function GetRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local items = remotes and remotes:FindFirstChild("Items")
    local tof = items and items:FindFirstChild("Twist of Fate")
    local fire = tof and tof:FindFirstChild("Fire")

    if fire and fire:IsA("RemoteEvent") then
        return fire
    end

    return nil
end

local function GetGun()
    local char = LocalPlayer.Character

    if not char then
        return nil
    end

    local baseToF = char:FindFirstChild("Twist of Fate", true)

    if not baseToF then
        return nil
    end

    local rightArm = baseToF:FindFirstChild("Right Arm")

    if rightArm then
        local gunPart = rightArm:FindFirstChild("gun")

        if gunPart then
            return gunPart
        end

        local emperorGun = rightArm:FindFirstChild("EmperorGun")

        if emperorGun then
            return emperorGun
        end
    end

    return baseToF
end

local function IsDowned(char)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if not hrp then
        return true
    end

    local state = char:GetAttribute("State")

    return state == "Downed" or state == "Dead"
end

local function GetShootButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local survivorMob = playerGui and playerGui:FindFirstChild("Survivor-mob")
    local controls = survivorMob and survivorMob:FindFirstChild("Controls")
    local guiMob = controls and controls:FindFirstChild("Gui-mob")

    if not guiMob then
        return nil
    end

    local directNames = {
        "attack",
        "Attack",
        "shoot",
        "Shoot",
        "fire",
        "Fire"
    }

    for _, name in ipairs(directNames) do
        local button = guiMob:FindFirstChild(name, true)

        if button and button:IsA("GuiObject") then
            return button
        end
    end

    for _, object in ipairs(guiMob:GetDescendants()) do
        if object:IsA("GuiButton") and object.Visible then
            return object
        end
    end

    if guiMob:IsA("GuiObject") then
        return guiMob
    end

    return nil
end

local function IsTouchOnShootButton(input)
    local shootButton = GetShootButton()

    if not (shootButton and shootButton.Visible) then
        return false
    end

    local pos = input.Position
    local absPos = shootButton.AbsolutePosition
    local absSize = shootButton.AbsoluteSize

    return
        pos.X >= absPos.X
        and pos.X <= absPos.X + absSize.X
        and pos.Y >= absPos.Y
        and pos.Y <= absPos.Y + absSize.Y
end

local function IsVisible(originPos, targetPos, targetCharacter)
    local direction = targetPos - originPos
    local distance = direction.Magnitude

    if distance < 0.1 then
        return true
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local excludeList = {}
    local localChar = LocalPlayer.Character

    if localChar then
        table.insert(excludeList, localChar)
    end

    if targetCharacter and targetCharacter ~= localChar then
        table.insert(excludeList, targetCharacter)
    end

    if ToF_State.Laser then
        table.insert(excludeList, ToF_State.Laser)
    end

    rayParams.FilterDescendantsInstances = excludeList

    local result = workspace:Raycast(
        originPos,
        direction.Unit * distance,
        rayParams
    )

    return result == nil
end

local function GetZombies()
    if tick() - ToF_State.ZombieCacheTime < 0.5 then
        return ToF_State.ZombieCache
    end

    local newTargets = {}
    local mapFolder = workspace:FindFirstChild("Map")

    if mapFolder then
        for _, container in pairs(mapFolder:GetDescendants()) do
            if container:IsA("Model") then
                local attributes = container:GetAttributes()

                if
                    container:GetAttribute("CorpseCreated0492")
                    or next(attributes) ~= nil
                then
                    local root =
                        container:FindFirstChild("HumanoidRootPart")

                    if root then
                        table.insert(newTargets, root)
                    end
                end
            end
        end
    end

    ToF_State.ZombieCache = newTargets
    ToF_State.ZombieCacheTime = tick()

    return ToF_State.ZombieCache
end

local function GetTarget()
    local gunObject = GetGun()
    local char = LocalPlayer.Character

    if not (gunObject and char) then
        return nil, nil, nil, nil
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not hrp then
        return nil, nil, nil, nil
    end

    local myPos = hrp.Position
    local originPos

    if char:GetAttribute("IsCarried") then
        originPos =
            hrp.Position
            + (hrp.CFrame.LookVector * 2)
    else
        pcall(function()
            if gunObject:IsA("BasePart") then
                originPos = gunObject.Position
            else
                local basePart =
                    gunObject:FindFirstChildOfClass("BasePart")

                if basePart then
                    originPos = basePart.Position
                end
            end
        end)

        originPos =
            originPos
            or Vector3.new(
                myPos.X,
                myPos.Y + 1.5,
                myPos.Z
            )
    end

    local function PredictTarget(torso, targetCharacter)
        local targetPos = torso.Position

        if
            ToF_Config.WallCheck
            and not IsVisible(
                originPos,
                targetPos,
                targetCharacter
            )
        then
            return nil, nil, nil, nil
        end

        local targetVelocity = Vector3.new(0, 0, 0)

        local rootPart =
            targetCharacter
            and (
                targetCharacter:FindFirstChild("HumanoidRootPart")
                or torso
            )

        if rootPart then
            targetVelocity = rootPart.Velocity
        end

        local directionRaw = targetPos - originPos
        local distance = directionRaw.Magnitude

        if distance < 0.1 then
            return nil, nil, nil, nil
        end

        if distance < 5 then
            return
                directionRaw.Unit,
                gunObject,
                originPos,
                targetPos
        end

        local travelTime = distance / 400

        local predictedPos =
            targetPos
            + (targetVelocity * travelTime)

        for _ = 1, 2 do
            local newDistance =
                (predictedPos - originPos).Magnitude

            travelTime = newDistance / 400

            predictedPos =
                targetPos
                + (targetVelocity * travelTime)
        end

        local finalDirection =
            predictedPos - originPos

        if finalDirection.Magnitude < 0.1 then
            return nil, nil, nil, nil
        end

        return
            finalDirection.Unit,
            gunObject,
            originPos,
            predictedPos
    end

    if ToF_Config.TargetMode == "Killer" then
        local closestTorso
        local closestCharacter
        local shortestDistance = math.huge

        for _, player in ipairs(Players:GetPlayers()) do
            if
                player ~= LocalPlayer
                and player.Team
                and player.Team.Name == "Killer"
                and player.Character
            then
                local torso =
                    player.Character:FindFirstChild("Torso")
                    or player.Character:FindFirstChild("UpperTorso")
                    or player.Character:FindFirstChild("HumanoidRootPart")

                if torso then
                    local distance =
                        (myPos - torso.Position).Magnitude

                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestTorso = torso
                        closestCharacter = player.Character
                    end
                end
            end
        end

        if not closestTorso then
            return nil, nil, nil, nil
        end

        return PredictTarget(
            closestTorso,
            closestCharacter
        )
    end

    if ToF_Config.TargetMode == "Survivors" then
        local bestTorso
        local bestCharacter
        local bestDot = -math.huge

        local camera = workspace.CurrentCamera

        if not camera then
            return nil, nil, nil, nil
        end

        local cameraPosition = camera.CFrame.Position
        local cameraLook = camera.CFrame.LookVector

        for _, player in ipairs(Players:GetPlayers()) do
            if
                player ~= LocalPlayer
                and player.Team
                and player.Team.Name == "Survivors"
                and player.Character
            then
                local torso =
                    player.Character:FindFirstChild("Torso")
                    or player.Character:FindFirstChild("UpperTorso")
                    or player.Character:FindFirstChild("HumanoidRootPart")

                if torso then
                    local direction =
                        torso.Position - cameraPosition

                    if direction.Magnitude > 0.1 then
                        local dot =
                            cameraLook:Dot(direction.Unit)

                        if dot > 0.5 and dot > bestDot then
                            bestDot = dot
                            bestTorso = torso
                            bestCharacter = player.Character
                        end
                    end
                end
            end
        end

        if not bestTorso then
            return nil, nil, nil, nil
        end

        return PredictTarget(
            bestTorso,
            bestCharacter
        )
    end

    if ToF_Config.TargetMode == "Zombie" then
        local bestPart
        local bestDot = -math.huge

        local camera = workspace.CurrentCamera

        if not camera then
            return nil, nil, nil, nil
        end

        local cameraPosition = camera.CFrame.Position
        local cameraLook = camera.CFrame.LookVector

        for _, root in ipairs(GetZombies()) do
            if root and root.Parent then
                local direction =
                    root.Position - cameraPosition

                if direction.Magnitude > 0.1 then
                    local dot =
                        cameraLook:Dot(direction.Unit)

                    if dot > 0.5 and dot > bestDot then
                        bestDot = dot
                        bestPart = root
                    end
                end
            end
        end

        if not bestPart then
            return nil, nil, nil, nil
        end

        return PredictTarget(
            bestPart,
            bestPart.Parent
        )
    end

    return nil, nil, nil, nil
end

local function UpdateLaser(originPos, targetPos)
    if not ToF_State.Laser then
        local laser = Instance.new("Part")

        laser.Name = "ToFLaser"
        laser.Anchored = true
        laser.CanCollide = false
        laser.CanTouch = false
        laser.CastShadow = false
        laser.Material = Enum.Material.Neon
        laser.Color = Color3.fromRGB(255, 50, 50)
        laser.Parent = workspace

        ToF_State.Laser = laser
    end

    local distance =
        (targetPos - originPos).Magnitude

    ToF_State.Laser.Size =
        Vector3.new(0.05, 0.05, distance)

    ToF_State.Laser.CFrame =
        CFrame.new(
            (originPos + targetPos) / 2,
            targetPos
        )

    ToF_State.Laser.Transparency = 0
end

local function ClearLaser()
    if ToF_State.Laser then
        pcall(function()
            ToF_State.Laser:Destroy()
        end)

        ToF_State.Laser = nil
    end
end

local function Shoot()
    if not ToF_Config.Enabled then
        return
    end

    local char = LocalPlayer.Character

    if char then
        if
            ToF_Config.BlockKnocked
            and IsDowned(char)
        then
            return
        end
    end

    local
        targetDirection,
        gunObject,
        originPos,
        targetPos =
        GetTarget()

    if not (
        targetDirection
        and gunObject
        and targetPos
        and originPos
    ) then
        return
    end

    local tofEvent = GetRemote()

    if not tofEvent then
        return
    end

    local freshDirection =
        targetPos - originPos

    if freshDirection.Magnitude < 0.1 then
        return
    end

    pcall(function()
        tofEvent:FireServer(
            gunObject,
            freshDirection.Unit
        )
    end)
end

local function StopInput()
    if ToF_State.InputBegan then
        ToF_State.InputBegan:Disconnect()
        ToF_State.InputBegan = nil
    end

    if ToF_State.InputEnded then
        ToF_State.InputEnded:Disconnect()
        ToF_State.InputEnded = nil
    end

    ToF_State.TouchInput = nil
    ToF_State.IsAiming = false
    ToF_State.InputStarted = false

    ClearLaser()
end

local function StartInput()
    StopInput()

    ToF_State.InputBegan =
        UserInputService.InputBegan:Connect(function(
            input,
            gameProcessed
        )
            if gameProcessed then
                return
            end

            if
                input.UserInputType
                == Enum.UserInputType.MouseButton1
            then
                ToF_State.IsAiming = true
                ToF_State.InputStarted = true
                return
            end

            if
                input.UserInputType
                == Enum.UserInputType.Touch
            then
                if IsTouchOnShootButton(input) then
                    ToF_State.IsAiming = true
                    ToF_State.TouchInput = input
                    ToF_State.InputStarted = true
                end
            end
        end)

    ToF_State.InputEnded =
        UserInputService.InputEnded:Connect(function(input)
            local isMouseRelease =
                input.UserInputType
                == Enum.UserInputType.MouseButton1

            local isTouchRelease =
                input.UserInputType
                == Enum.UserInputType.Touch
                and input == ToF_State.TouchInput

            if not (isMouseRelease or isTouchRelease) then
                return
            end

            if not ToF_State.InputStarted then
                return
            end

            ToF_State.IsAiming = false
            ToF_State.InputStarted = false
            ToF_State.TouchInput = nil

            if ToF_Config.Enabled then
                Shoot()
            end

            ClearLaser()
        end)
end

local function StopConnection()
    if ToF_State.Connection then
        ToF_State.Connection:Disconnect()
        ToF_State.Connection = nil
    end

    ClearLaser()
end

local function StartConnection()
    StopConnection()

    ToF_State.Connection =
        RunService.Heartbeat:Connect(function()
            if not ToF_Config.Enabled then
                if ToF_State.IsAiming then
                    ToF_State.IsAiming = false
                end

                ClearLaser()
                return
            end

            if not ToF_State.IsAiming then
                ClearLaser()
                return
            end

            local
                direction,
                gunObject,
                originPos,
                targetPos =
                GetTarget()

            if not (
                direction
                and gunObject
                and originPos
                and targetPos
            ) then
                ClearLaser()
                return
            end

            local char = LocalPlayer.Character
            local hrp =
                char
                and char:FindFirstChild("HumanoidRootPart")

            if
                hrp
                and not char:GetAttribute("IsCarried")
            then
                local lookTarget =
                    Vector3.new(
                        targetPos.X,
                        hrp.Position.Y,
                        targetPos.Z
                    )

                if
                    (lookTarget - hrp.Position).Magnitude
                    > 0.1
                then
                    hrp.CFrame =
                        CFrame.lookAt(
                            hrp.Position,
                            lookTarget
                        )
                end
            end

            if ToF_Config.Laser then
                UpdateLaser(
                    originPos,
                    targetPos
                )
            else
                ClearLaser()
            end
        end)
end

local function SetEnabled(value)
    ToF_Config.Enabled = value

    if value then
        StartInput()
        StartConnection()
    else
        StopInput()
        StopConnection()
    end
end

Tabs.Main:AddSection("Twist of Fate")

Tabs.Main:AddToggle("ToFEnabled", {
    Title = "Silent Aim",
    Default = false
}):OnChanged(function(value)
    SetEnabled(value)
end)

Tabs.Main:AddToggle("ToFLaser", {
    Title = "Laser Beam",
    Default = true
}):OnChanged(function(value)
    ToF_Config.Laser = value

    if not value then
        ClearLaser()
    end
end)

Tabs.Main:AddToggle("ToFWallCheck", {
    Title = "Wall Check",
    Default = false
}):OnChanged(function(value)
    ToF_Config.WallCheck = value
end)

Tabs.Main:AddToggle("ToFBlockKnocked", {
    Title = "Block When Knocked",
    Default = true
}):OnChanged(function(value)
    ToF_Config.BlockKnocked = value
end)

Tabs.Main:AddDropdown("ToFTargetMode", {
    Title = "Target Mode",
    Values = {
        "Killer",
        "Survivors",
        "Zombie"
    },
    Multi = false,
    Default = "Killer"
}):OnChanged(function(value)
    if type(value) == "table" then
        value = value[1]
    end

    if
        value == "Killer"
        or value == "Survivors"
        or value == "Zombie"
    then
        ToF_Config.TargetMode = value
    end
end)

StartInput()

task.spawn(function()
    while task.wait(1) do
        if not ToF_Config.Enabled then
            continue
        end

        local char = LocalPlayer.Character

        if not char then
            ClearLaser()
        end
    end
end)


--Auto Kill
local KillerSection = Tabs.Main:AddSection("Killer")

local Options = Fluent.Options

getgenv().VD = getgenv().VD or {
    AUTO_KillAll = false,
    AUTO_Attack = false,
    AUTO_AttackRange = 12,
}

local VD = getgenv().VD

VD.AUTO_KillAllSpeed = nil

local CameraTarget = nil

local function GetRole()
    if not lp.Team then
        return "Unknown"
    end

    return lp.Team.Name == "Killer" and "Killer" or "Survivor"
end

local function GetHumanoid(char)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsHooked(char)
    if not char then
        return false
    end

    return char:GetAttribute("IsHooked") == true
        or char:GetAttribute("isHooked") == true
end

local function IsTargetFinished(char)
    local hum = GetHumanoid(char)

    if not hum then
        return true
    end

    return hum.Health < 30
end

local function GetValidSurvivor()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp
            and p.Team
            and p.Team.Name == "Survivors"
            and p.Character
        then
            local char = p.Character
            local hum = GetHumanoid(char)

            if IsHooked(char) then
                continue
            end

            if hum and hum.Health >= 30 then
                return p
            end
        end
    end

    return nil
end

local function GetBehindTargetCFrame(targetRoot)
    local targetPosition = targetRoot.Position

    local behindPosition =
        targetPosition - (targetRoot.CFrame.LookVector * 2)

    return CFrame.lookAt(
        behindPosition,
        targetPosition,
        Vector3.yAxis
    )
end

local function GetAttackRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")

    if not remotes then
        return nil
    end

    local attacks = remotes:FindFirstChild("Attacks")

    if not attacks then
        return nil
    end

    return attacks:FindFirstChild("BasicAttack")
end

local function UnlockCamera()
    CameraTarget = nil

    local localChar = lp.Character
    local localHum = GetHumanoid(localChar)

    Camera.CameraType = Enum.CameraType.Custom

    if localHum then
        Camera.CameraSubject = localHum
    end
end

local function LockCamera(targetPlayer)
    if not targetPlayer then
        UnlockCamera()
        return
    end

    local targetChar = targetPlayer.Character
    local targetHum = GetHumanoid(targetChar)

    if not targetHum then
        UnlockCamera()
        return
    end

    CameraTarget = targetPlayer

    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = targetHum
end

local function IsCameraTargetValid(targetPlayer)
    if not targetPlayer then
        return false
    end

    local char = targetPlayer.Character

    if not char then
        return false
    end

    local hum = GetHumanoid(char)
    local root = GetHRP(char)

    if not hum or not root then
        return false
    end

    if IsHooked(char) then
        return false
    end

    if hum.Health < 30 then
        return false
    end

    return true
end

local KillAllToggle =
    KillerSection:AddToggle("AutoKillAll", {
        Title = "Auto Kill",
        Default = VD.AUTO_KillAll
    })

KillAllToggle:OnChanged(function(Value)
    VD.AUTO_KillAll = Value

    if not Value then
        UnlockCamera()
    end
end)

KillerSection:AddDropdown("KillSpeed", {
    Title = "Kill Mode",
    Values = {
        "Medium",
        "Instant"
    },
    Callback = function(Value)
        if Value == "Medium" then
            VD.AUTO_KillAllSpeed = 0.5

        elseif Value == "Instant" then
            VD.AUTO_KillAllSpeed = 0
        end
    end
})

task.spawn(function()
    while task.wait() do

        if not VD.AUTO_KillAll then
            continue
        end

        if GetRole() ~= "Killer" then
            UnlockCamera()
            continue
        end

        if VD.AUTO_KillAllSpeed == nil then
            UnlockCamera()
            continue
        end

        local char = lp.Character
        local root = GetHRP(char)

        if not char or not root then
            UnlockCamera()
            continue
        end

        local targetPlayer = GetValidSurvivor()

        if not targetPlayer then
            UnlockCamera()

            VD.AUTO_KillAll = false

            pcall(function()
                KillAllToggle:SetValue(false)
            end)

            Fluent:Notify({
                Title = "Auto Kill",
                Content = "Disabled",
                Duration = 3
            })

            continue
        end

        if CameraTarget ~= targetPlayer then
            LockCamera(targetPlayer)
        end

        local targetChar = targetPlayer.Character
        local targetHum = GetHumanoid(targetChar)
        local targetRoot = GetHRP(targetChar)

        if not targetChar
            or not targetHum
            or not targetRoot
        then
            UnlockCamera()
            continue
        end

        if IsHooked(targetChar) then
            UnlockCamera()
            continue
        end

        if targetHum.Health < 30 then
            UnlockCamera()
            continue
        end

        if not VD.AUTO_KillAll then
            UnlockCamera()
            continue
        end

        root = GetHRP(lp.Character)

        if not root then
            UnlockCamera()
            continue
        end

        root.CFrame = GetBehindTargetCFrame(targetRoot)

        targetChar = targetPlayer.Character
        targetHum = GetHumanoid(targetChar)
        targetRoot = GetHRP(targetChar)

        if not targetChar
            or not targetHum
            or not targetRoot
        then
            UnlockCamera()
            continue
        end

        if IsHooked(targetChar) then
            UnlockCamera()
            continue
        end

        if targetHum.Health < 30 then
            UnlockCamera()
            continue
        end

        if not VD.AUTO_KillAll then
            UnlockCamera()
            continue
        end

        if CameraTarget ~= targetPlayer then
            LockCamera(targetPlayer)
        elseif not IsCameraTargetValid(CameraTarget) then
            UnlockCamera()
            continue
        end

        local basic = GetAttackRemote()

        if basic then
            pcall(function()
                basic:FireServer(false)
            end)
        end

        if VD.AUTO_KillAllSpeed > 0 then
            task.wait(VD.AUTO_KillAllSpeed)
        else
            task.wait()
        end
    end
end)

-- Silent Aim Veil
local VeilSection = Tabs.Main:AddSection("Veil Silent Aim")

VeilConfig = {
    Enabled              = false,
    ShowFOV              = true,
    ShowTargetLaser      = true,
    FOV                  = 150,
    SpearSpeed           = 165,
    Gravity              = workspace.Gravity * 0.5,
    MaxDist              = 200,
    AutoPredict          = false,
    TargetPart           = "Torso",
    HorizontalPredictFactor = 1.0,
}

VeilState = {
    chargingSpear    = false,
    touchInput       = nil,
    attackCooldown   = false,
    passiveCooldown  = false,
    remoteHooked     = false,
    lastPredictedPos = nil,
}

VeilVelocityCache = {}

local function Veil_NewDrawing(className)
    if type(Drawing) == "table" and type(Drawing.new) == "function" then
        local ok, object = pcall(Drawing.new, className)
        if ok and object then
            return object
        end
    end
    return setmetatable({}, {
        __newindex = function(t, k, v) rawset(t, k, v) end
    })
end

VeilDraw = {
    FOVCircle = Veil_NewDrawing("Circle"),
    Highlight = Instance.new("Highlight"),
    Tracer    = Veil_NewDrawing("Circle"),
}

VeilDraw.FOVCircle.Color     = Color3.fromRGB(255, 0, 255)
VeilDraw.FOVCircle.Thickness = 1.5
VeilDraw.FOVCircle.Filled    = false
VeilDraw.FOVCircle.Visible   = false

VeilDraw.Highlight.Name                = "VD_VeilTarget"
VeilDraw.Highlight.FillColor           = Color3.fromRGB(255, 0, 0)
VeilDraw.Highlight.OutlineColor        = Color3.fromRGB(255, 255, 255)
VeilDraw.Highlight.FillTransparency    = 0.5
VeilDraw.Highlight.OutlineTransparency = 0

VeilDraw.Tracer.Thickness = 2
VeilDraw.Tracer.Radius    = 5
VeilDraw.Tracer.Color     = Color3.fromRGB(255, 0, 255)
VeilDraw.Tracer.Filled    = true
VeilDraw.Tracer.Visible   = false

function Veil_GetRealVelocity(part, playerName)
    if not part then return Vector3.zero end
    local currentPos = part.Position
    local currentTime = tick()
    if not VeilVelocityCache[playerName] then
        VeilVelocityCache[playerName] = {lastPos = currentPos, lastTime = currentTime, velocity = Vector3.zero}
        return Vector3.zero
    end
    local cache = VeilVelocityCache[playerName]
    local dt = currentTime - cache.lastTime
    if dt > 0.01 then
        local rawVelocity = (currentPos - cache.lastPos) / dt
        if rawVelocity.Magnitude < 100 then
            cache.velocity = cache.velocity:Lerp(rawVelocity, 0.4)
        end
    end
    cache.lastPos = currentPos
    cache.lastTime = currentTime
    return cache.velocity
end

function veil_getTargetPart(char)
    if VeilConfig.TargetPart == "Head" then
        return char:FindFirstChild("Head")
    elseif VeilConfig.TargetPart == "Root" then
        return char:FindFirstChild("HumanoidRootPart")
    else
        return char:FindFirstChild("Torso")
            or char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("HumanoidRootPart")
    end
end

function veil_getClosestSurvivor()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local cam      = workspace.CurrentCamera
    local center   = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local bestDist = VeilConfig.FOV
    local bestTarget = nil

    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" and p.Character then
            local char = p.Character
            local hum  = char:FindFirstChildOfClass("Humanoid")
            local part = veil_getTargetPart(char)
            if hum and hum.Health > 0 and part then
                local dist3D = (part.Position - myRoot.Position).Magnitude
                if dist3D <= VeilConfig.MaxDist then
                    local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist2D < bestDist then
                            bestDist   = dist2D
                            bestTarget = { Player = p, Part = part }
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

function veil_setupInterceptor()
    if VeilState.remoteHooked then return end
    task.spawn(function()
        pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if not checkcaller() and method == "FireServer" then
                    if self.Name == "Spearthrow" and VeilConfig.Enabled then
                        return nil
                    end
                end
                return oldNamecall(self, ...)
            end)
            VeilState.remoteHooked = true
        end)
    end)
end

veil_setupInterceptor()

function veil_fire()
    if VeilState.attackCooldown then return end
    VeilState.attackCooldown = true
    task.delay(2, function() VeilState.attackCooldown = false end)

    local myChar    = LocalPlayer.Character
    local startPart = myChar and (myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart"))
    if not startPart then return end

    local startPos   = startPart.Position
    local targetInfo = veil_getClosestSurvivor()
    local aimDir

    if targetInfo and targetInfo.Part then
        local targetPart = targetInfo.Part
        local targetPlayer = targetInfo.Player
        local targetPos = targetPart.Position

        local velocity = Veil_GetRealVelocity(targetPart, targetPlayer.Name)
        local horizontalVel = Vector3.new(velocity.X, 0, velocity.Z)
        local speed = horizontalVel.Magnitude

        local distance = (targetPos - startPos).Magnitude
        local timeToHit = distance / VeilConfig.SpearSpeed

        local horizontalPrediction = Vector3.zero
        if speed > 4 and VeilConfig.AutoPredict then
            local factor = VeilConfig.HorizontalPredictFactor
            horizontalPrediction = horizontalVel * timeToHit * factor
        end
        local predictedPos = targetPos + horizontalPrediction

        local autoGravity = math.max(0, distance - 8)
        local gravity = VeilConfig.AutoPredict and autoGravity or VeilConfig.Gravity
        local drop = 0.5 * gravity * (timeToHit ^ 2)
        local finalPos = predictedPos + Vector3.new(0, drop, 0)

        aimDir = (finalPos - startPos).Unit
        VeilState.lastPredictedPos = finalPos
    else
        aimDir = workspace.CurrentCamera.CFrame.LookVector
        VeilState.lastPredictedPos = nil
    end

    pcall(function()
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remotes then
            local killers = remotes:FindFirstChild("Killers")
            if killers then
                local veil = killers:FindFirstChild("Veil")
                if veil and veil:FindFirstChild("Spearthrow") then
                    veil.Spearthrow:FireServer(aimDir, VeilConfig.SpearSpeed, startPos)
                end
            end
        end
    end)

    VeilDraw.FOVCircle.Color = Color3.fromRGB(255, 0, 255)
    if not VeilState.passiveCooldown then
        VeilState.passiveCooldown = true
        task.delay(30, function()
            VeilDraw.FOVCircle.Color = Color3.fromRGB(255, 0, 255)
            VeilState.passiveCooldown = false
        end)
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    local isTouch = input.UserInputType == Enum.UserInputType.Touch
    if gp and not isTouch then return end
    local char = LocalPlayer.Character
    local isSpearMode = char and char:GetAttribute("spearmode") == true
    if not VeilConfig.Enabled then return end
    if not isSpearMode then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        VeilState.chargingSpear = true
    elseif isTouch then
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            local slasher = pGui:FindFirstChild("Slasher-mob")
            if slasher then
                local ctrl = slasher:FindFirstChild("Controls")
                if ctrl then
                    local attackBtn = ctrl:FindFirstChild("attack")
                    if attackBtn and attackBtn.Visible then
                        local pos     = input.Position
                        local absPos  = attackBtn.AbsolutePosition
                        local absSize = attackBtn.AbsoluteSize
                        if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X
                        and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
                            VeilState.chargingSpear = true
                            VeilState.touchInput    = input
                        end
                    end
                end
            end
        end
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input, gp)
    if VeilState.chargingSpear
    and (input == VeilState.touchInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
        VeilState.chargingSpear = false
        if VeilState.touchInput == input then VeilState.touchInput = nil end
        veil_fire()
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    local cam         = workspace.CurrentCamera
    local myChar      = LocalPlayer.Character
    local isSpearMode = myChar and myChar:GetAttribute("spearmode") == true

    if VeilConfig.Enabled and VeilConfig.ShowFOV and isSpearMode then
        VeilDraw.FOVCircle.Visible  = true
        VeilDraw.FOVCircle.Radius   = VeilConfig.FOV
        VeilDraw.FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    else
        VeilDraw.FOVCircle.Visible = false
    end

    if VeilState.chargingSpear and VeilConfig.Enabled and isSpearMode then
        local target = veil_getClosestSurvivor()
        if target and target.Part and target.Part.Parent then
            VeilDraw.Highlight.Parent = target.Part.Parent
            
            if VeilConfig.ShowTargetLaser then
                if not getgenv().KYS_SpearLaserPart then
                    local laser = Instance.new("Part")
                    laser.Name = "SpearSilentAimLaser"
                    laser.Anchored = true
                    laser.CanCollide = false
                    laser.CanTouch = false
                    laser.CastShadow = false
                    laser.Material = Enum.Material.Neon
                    laser.Color = Color3.fromRGB(255, 50, 50)
                    laser.Transparency = 0
                    laser.Parent = workspace
                    getgenv().KYS_SpearLaserPart = laser
                end
                
                local originPart = myChar and (myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart"))
                if originPart then
                    local originPos = originPart.Position
                    local targetPos = target.Part.Position
                    local dist = (targetPos - originPos).Magnitude
                    if dist > 0.1 then
                        local laser = getgenv().KYS_SpearLaserPart
                        laser.Size = Vector3.new(0.16, 0.16, dist)
                        laser.CFrame = CFrame.new((originPos + targetPos) / 2, targetPos)
                        laser.Transparency = 0.5
                    end
                end
            else
                if getgenv().KYS_SpearLaserPart then getgenv().KYS_SpearLaserPart.Transparency = 1 end
            end
        else
            VeilDraw.Highlight.Parent = nil
            if getgenv().KYS_SpearLaserPart then getgenv().KYS_SpearLaserPart.Transparency = 1 end
        end
    else
        VeilDraw.Highlight.Parent = nil
        if getgenv().KYS_SpearLaserPart then getgenv().KYS_SpearLaserPart.Transparency = 1 end
    end

    if VeilConfig.Enabled and isSpearMode and VeilState.lastPredictedPos then
        local screenPos, onScreen = cam:WorldToViewportPoint(VeilState.lastPredictedPos)
        local viewport = cam.ViewportSize
        local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

        if onScreen then
            VeilDraw.Tracer.Position = Vector2.new(screenPos.X, screenPos.Y)
        else
            local dx = screenPos.X - center.X
            local dy = screenPos.Y - center.Y
            if math.abs(dx) < 1 and math.abs(dy) < 1 then
                VeilDraw.Tracer.Position = center
            else
                local angle = math.atan2(dy, dx)
                local maxX = viewport.X / 2 - 10
                local maxY = viewport.Y / 2 - 10
                local scaleX = maxX / math.abs(dx)
                local scaleY = maxY / math.abs(dy)
                local scale = math.min(scaleX, scaleY)
                local borderPos = Vector2.new(
                    center.X + dx * scale,
                    center.Y + dy * scale
                )
                VeilDraw.Tracer.Position = borderPos
            end
        end
        VeilDraw.Tracer.Visible = true
    else
        VeilDraw.Tracer.Visible = false
    end
end)

VeilSection:AddToggle("Veil_Enabled", {
    Title = "Silent Aim (Veil)",
    Default = VeilConfig.Enabled,
    Callback = function(value)
        VeilConfig.Enabled = value
        if not value then
            VeilState.chargingSpear = false
            VeilState.lastPredictedPos = nil
        end
    end,
})

VeilSection:AddToggle("Veil_ShowFOV", {
    Title = "Show FOV",
    Default = VeilConfig.ShowFOV,
    Callback = function(value)
        VeilConfig.ShowFOV = value
    end,
})

VeilSection:AddToggle("Veil_ShowTargetLaser", {
    Title = "Show Target Laser",
    Default = VeilConfig.ShowTargetLaser,
    Callback = function(value)
        VeilConfig.ShowTargetLaser = value
    end,
})

VeilSection:AddSlider("Veil_FOV", {
    Title = "FOV",
    Default = VeilConfig.FOV,
    Min = 1,
    Max = 800,
    Rounding = 0,
    Callback = function(value)
        VeilConfig.FOV = value
    end,
})

VeilSection:AddSlider("Veil_SpearSpeed", {
    Title = "Spear Speed",
    Min = 1,
    Max = 500,
    Default = VeilConfig.SpearSpeed,
    Rounding = 0,
    Callback = function(value)
        VeilConfig.SpearSpeed = value
    end,
})

VeilSection:AddSlider("Veil_Gravity", {
    Title = "Gravity",
    Min = 0,
    Max = 300,
    Default = VeilConfig.Gravity,
    Rounding = 1,
    Callback = function(value)
        VeilConfig.Gravity = value
    end,
})

VeilSection:AddSlider("Veil_MaxDist", {
    Title = "Max Distance",
    Min = 1,
    Max = 500,
    Default = VeilConfig.MaxDist,
    Rounding = 0,
    Callback = function(value)
        VeilConfig.MaxDist = value
    end,
})

VeilSection:AddToggle("Veil_AutoPredict", {
    Title = "Auto Predict",
    Default = VeilConfig.AutoPredict,
    Callback = function(value)
        VeilConfig.AutoPredict = value
    end,
})

VeilSection:AddDropdown("Veil_TargetPart", {
    Title = "Target Part",
    Values = {"Head", "Torso", "Root"},
    Default = VeilConfig.TargetPart,
    Callback = function(value)
        VeilConfig.TargetPart = value
    end,
})

VeilSection:AddSlider("Veil_HorizontalPredict", {
    Title = "Horizontal Predict Factor",
    Min = 0,
    Max = 3,
    Default = VeilConfig.HorizontalPredictFactor,
    Rounding = 2,
    Callback = function(value)
        VeilConfig.HorizontalPredictFactor = value
    end,
})

-- Silent Aim Flask
local _genv = getgenv()

_genv.VD = _genv.VD or {}
local VD = _genv.VD

VD.KILLER_SilentAimFlask =
    VD.KILLER_SilentAimFlask or false

VD.KILLER_FlaskLaser =
    VD.KILLER_FlaskLaser or false

_genv.CureFlaskLaserThread = nil
_genv.CureFlaskLaserPart = nil

function UpdateCureFlaskLaser()

    local char = Players.LocalPlayer.Character

    if not char then
        return
    end

    local targetPos = nil
    local originPos = nil

    local closest = nil
    local minDst = math.huge

    local hrp = char:FindFirstChild("HumanoidRootPart")

    if hrp then

        local hand =
            char:FindFirstChild("LeftHand")
            or char:FindFirstChild("Left Arm")

        originPos =
            hand and hand.Position
            or hrp.Position

        for _, v in pairs(Players:GetPlayers()) do

            if v ~= Players.LocalPlayer
                and v.Character
                and v.Character:FindFirstChild("HumanoidRootPart") then

                if not v.Character:GetAttribute("IsKiller") then

                    local dst =
                        (
                            v.Character.HumanoidRootPart.Position
                            - hrp.Position
                        ).Magnitude

                    if dst < minDst then
                        minDst = dst
                        closest = v
                    end
                end
            end
        end
    end

    if closest then
        targetPos =
            closest.Character.HumanoidRootPart.Position
    end

    local actionActive = false

    for _, child in pairs(char:GetChildren()) do

        if child:IsA("LocalScript")
            and child:GetAttribute("action") == true then

            actionActive = true
            break
        end
    end

    if originPos and targetPos and actionActive then

        if not _genv.CureFlaskLaserPart then

            local laser = Instance.new("Part")

            laser.Name = "FlaskSilentAimLaser"
            laser.Anchored = true
            laser.CanCollide = false
            laser.CanTouch = false
            laser.CastShadow = false

            laser.Material = Enum.Material.Neon
            laser.Color = Color3.fromRGB(0, 100, 255)
            laser.Transparency = 0

            laser.Parent = workspace

            _genv.CureFlaskLaserPart = laser
        end

        local dist =
            (targetPos - originPos).Magnitude

        if dist > 0.1 then

            local laser =
                _genv.CureFlaskLaserPart

            laser.Size =
                Vector3.new(
                    0.16,
                    0.16,
                    dist
                )

            laser.CFrame =
                CFrame.new(
                    (originPos + targetPos) / 2,
                    targetPos
                )

            laser.Transparency = 0
        end

    else

        if _genv.CureFlaskLaserPart then
            _genv.CureFlaskLaserPart.Transparency = 1
        end
    end
end

function StartCureFlaskLaser()

    if _genv.CureFlaskLaserThread then
        return
    end

    _genv.CureFlaskLaserThread =
        RunService.RenderStepped:Connect(function()

            if not VD.KILLER_FlaskLaser then

                if _genv.CureFlaskLaserPart then

                    pcall(function()
                        _genv.CureFlaskLaserPart:Destroy()
                    end)

                    _genv.CureFlaskLaserPart = nil
                end

                if _genv.CureFlaskLaserThread then

                    _genv.CureFlaskLaserThread:Disconnect()
                    _genv.CureFlaskLaserThread = nil

                end

                return
            end

            pcall(UpdateCureFlaskLaser)
        end)
end

local function InstallFlaskHook()

    if _genv.FlaskStandaloneHook then
        return
    end

    if _genv.oldNamecall then
        _genv.FlaskStandaloneHook = true
        return
    end

    _genv.FlaskStandaloneHook = true

    _genv.oldNamecall =
        hookmetamethod(game, "__namecall", function(self, ...)

            local method = getnamecallmethod()

            if VD.KILLER_SilentAimFlask
                and method == "FireServer" then

                local ok, name =
                    pcall(function()
                        return self.Name
                    end)

                if ok and name == "ThrowFlask" then

                    local args = {...}

                    local closest = nil
                    local minDst = math.huge

                    local lp =
                        Players.LocalPlayer

                    local myPos =
                        lp.Character
                        and lp.Character:FindFirstChild(
                            "HumanoidRootPart"
                        )
                        and lp.Character.HumanoidRootPart.Position

                    if myPos then

                        for _, v in pairs(
                            Players:GetPlayers()
                        ) do

                            if v ~= lp
                                and v.Character
                                and v.Character:FindFirstChild(
                                    "HumanoidRootPart"
                                ) then

                                if not v.Character:GetAttribute(
                                    "IsKiller"
                                ) then

                                    local dst =
                                        (
                                            v.Character.HumanoidRootPart.Position
                                            - myPos
                                        ).Magnitude

                                    if dst < minDst then
                                        minDst = dst
                                        closest = v
                                    end
                                end
                            end
                        end
                    end

                    if closest then

                        local targetPos =
                            closest.Character
                            .HumanoidRootPart.Position

                        if args[2]
                            and typeof(args[2]) == "Vector3" then

                            args[1] =
                                (targetPos - args[2]).Unit
                        end

                        setnamecallmethod(method)

                        return _genv.oldNamecall(
                            self,
                            unpack(args)
                        )
                    end
                end
            end

            if _genv.oldNamecall then
                return _genv.oldNamecall(
                    self,
                    ...
                )
            end
        end)
end

InstallFlaskHook()


local FlaskSection = Tabs.Main:AddSection("Silent Aim Flask")

Tabs.Main:AddToggle("FlaskSilentAim",{
        Title = "Silent Aim Flask (Cure)",
        Default = VD.KILLER_SilentAimFlask,
        Callback = function(value)
        VD.KILLER_SilentAimFlask = value
end
    }
)


Tabs.Main:AddToggle("FlaskLaser",{
        Title = "Flask Laser (Cure)",
        Default =
        VD.KILLER_FlaskLaser,
        Callback = function(value)
        VD.KILLER_FlaskLaser = value if value then
        pcall(StartCureFlaskLaser)
            else
                if _genv.CureFlaskLaserThread then
                    _genv.CureFlaskLaserThread:Disconnect()
                    _genv.CureFlaskLaserThread = nil
                end

                if _genv.CureFlaskLaserPart then
                    pcall(function()
                        _genv.CureFlaskLaserPart:Destroy()
                    end)

                    _genv.CureFlaskLaserPart = nil
                end
            end
        end
    }
)

if VD.KILLER_FlaskLaser then
    pcall(StartCureFlaskLaser)
end


-- Automatic
--skillcheck
local SkillCheck = Tabs.Automatic:AddSection("Skill Check")

if _G.HyperX_Loop then _G.HyperX_Loop:Disconnect() end

local Config = {
    Enabled = false,
    Mode = "Legit"
}
local State = { busy = false }


-- [ UI Elements ]
local Dropdown = Tabs.Automatic:AddDropdown("ModeDropdown", {
    Title = "Select Mode",
    Values = {"Legit", "Instant"},
    Multi = false,
    Default = "Legit",
})

Dropdown:OnChanged(function(Value)
    Config.Mode = Value
end)
Config.Mode = Dropdown.Value -- กำหนดค่าทันที

local Toggle = Tabs.Automatic:AddToggle("AutoSkillToggle", { 
    Title = "Auto Skill Check", 
    Default = false 
})

Toggle:OnChanged(function(Value)
    Config.Enabled = Value
end)
Config.Enabled = Toggle.Value -- กำหนดค่าทันที

-- [ Logic เหมือนตัวที่มึงใช้แล้วเวิร์ค ]
local function Trigger()
    if UserInputService.TouchEnabled then
        local ActionPath = "Survivor-mob.Controls.action.check"
        local b = PlayerGui
        for segment in string.gmatch(ActionPath, "[^%.]+") do
            b = b and b:FindFirstChild(segment)
        end
        if b and b:IsA("GuiObject") then
            local p, s = b.AbsolutePosition, b.AbsoluteSize
            local i = game:GetService("GuiService"):GetGuiInset()
            local cx, cy = p.X + (s.X/2) + i.X, p.Y + (s.Y/2) + i.Y
            VirtualInputManager:SendTouchEvent(8822, 0, cx, cy)
            task.wait(0.01)
            VirtualInputManager:SendTouchEvent(8822, 2, cx, cy)
        end
    else
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end
end

_G.HyperX_Loop = RunService.RenderStepped:Connect(function()
    if not Config.Enabled or State.busy then return end
    
    local prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui")
    local check = prompt and prompt:FindFirstChild("Check")
    if not check or not check.Visible then return end
    
    local line = check:FindFirstChild("Line")
    local goal = check:FindFirstChild("Goal")
    if not line or not goal then return end

    if Config.Mode == "Instant" then
        line.Rotation = goal.Rotation + 109
        State.busy = true
        task.spawn(function()
            Trigger()
            task.wait(0.2)
            State.busy = false
        end)
    else
        local lr = line.Rotation % 360
        local gr = goal.Rotation % 360
        local startRange = (gr + 102) % 360
        local endRange   = (gr + 116) % 360
        
        if (startRange > endRange and (lr >= startRange or lr <= endRange)) or (lr >= startRange and lr <= endRange) then
            State.busy = true
            task.spawn(function()
                Trigger()
                task.wait(0.1)
                State.busy = false
            end)
        end
    end
end)

-- Boost Gen Bypass
local GenBypass = {
    Enabled = false,
    LockButton = false,

    Processed = {},
    Cache = {},
    CacheTimer = 0,

    Button = nil,
    UI = nil,

    IsMobile = UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled,

    ButtonPosition = UDim2.new(0.85, 0, 0.5, 0),

    Dragging = false,
    DragStart = nil,
    StartPosition = nil,
    Moved = false
}

local function GB_GetAllGenerators()
    local now = tick()

    if now - GenBypass.CacheTimer < 5 then
        return GenBypass.Cache
    end

    GenBypass.Cache = {}
    GenBypass.CacheTimer = now

    local mapFolder = workspace:FindFirstChild("Map")

    if not mapFolder then
        return GenBypass.Cache
    end

    for _, v in pairs(mapFolder:GetDescendants()) do
        if v:IsA("Model")
            and v.Name == "Generator" then

            if v:GetAttribute("RepairProgress") ~= nil
                or v:GetAttribute("kickcount") ~= nil then

                table.insert(GenBypass.Cache, v)
            end
        end
    end

    return GenBypass.Cache
end

local function GB_GetPoints(genModel)
    local points = {}

    for _, obj in pairs(genModel:GetChildren()) do
        if obj.Name:find("GeneratorPoint")
            and obj:IsA("BasePart") then

            table.insert(points, obj)
        end
    end

    return points
end

local function GB_WaitRepairing(point, timeout)
    local start = tick()

    while tick() - start < (timeout or 1) do
        if point:GetAttribute("IsRepairing") == true then
            return true
        end

        task.wait(0.05)
    end

    return false
end

local function GB_DoRepair(targetPoint)
    local genModel = targetPoint.Parent

    if GenBypass.Processed[genModel] then
        return
    end

    GenBypass.Processed[genModel] = true

    local character = LocalPlayer.Character

    local hrp = character
        and character:FindFirstChild("HumanoidRootPart")

    if not hrp then
        GenBypass.Processed[genModel] = nil
        return
    end

    local RepairEvent =
        ReplicatedStorage:FindFirstChild("Remotes")
        and ReplicatedStorage.Remotes:FindFirstChild("Generator")
        and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")

    if not RepairEvent then
        GenBypass.Processed[genModel] = nil
        return
    end

    local originalCFrame = hrp.CFrame

    pcall(function()
        for _, point in pairs(GB_GetPoints(genModel)) do
            if point ~= targetPoint
                and point.Parent then

                hrp.Anchored = true
                hrp.CFrame = point.CFrame

                task.wait(0.15)

                RepairEvent:FireServer(point, true)

                if not GB_WaitRepairing(point, 0.8) then
                    RepairEvent:FireServer(point, false)

                    task.wait(0.1)

                    hrp.CFrame = point.CFrame

                    task.wait(0.15)

                    RepairEvent:FireServer(point, true)

                    GB_WaitRepairing(point, 0.5)
                end

                hrp.Anchored = false

                task.wait(0.05)
            end
        end
    end)

    pcall(function()
        if hrp and hrp.Parent then
            hrp.Anchored = false
            hrp.CFrame = originalCFrame
        end
    end)

    task.wait(0.1)

    pcall(function()
        RepairEvent:FireServer(targetPoint, false)
    end)

    GenBypass.Processed[genModel] = nil
end

local function GB_GetNearestPoint()
    local character = LocalPlayer.Character

    local hrp = character
        and character:FindFirstChild("HumanoidRootPart")

    if not hrp then
        return nil
    end

    local bestPoint = nil
    local bestDist = math.huge

    for _, gen in pairs(GB_GetAllGenerators()) do
        for _, point in pairs(GB_GetPoints(gen)) do
            local d =
                (hrp.Position - point.Position).Magnitude

            if d < bestDist then
                bestDist = d
                bestPoint = point
            end
        end
    end

    return bestPoint, bestDist
end

local GB_Colors = {
    Background = Color3.fromRGB(8, 8, 10),
    Background2 = Color3.fromRGB(13, 13, 16),
    Red = Color3.fromRGB(255, 30, 50),
    White = Color3.fromRGB(245, 245, 247),
    Muted = Color3.fromRGB(100, 100, 108)
}

local function GB_ApplyStyle(
    object,
    radius,
    strokeColor,
    thickness,
    transparency
)
    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object

    local stroke = Instance.new("UIStroke")

    stroke.Color = strokeColor
    stroke.Thickness = thickness
    stroke.Transparency = transparency or 0
    stroke.Parent = object

    return stroke
end

local function GB_CreateMobileButton()
    if not GenBypass.IsMobile then
        return
    end

    if GenBypass.UI
        and GenBypass.UI.Parent
        and GenBypass.Button
        and GenBypass.Button.Parent then

        GenBypass.Button.Visible = GenBypass.Enabled
        return
    end

    local existingUI =
        CoreGui:FindFirstChild("ReaperGenBypass")

    if existingUI then
        local existingButton =
            existingUI:FindFirstChild("BypassButton")

        if existingButton then
            GenBypass.UI = existingUI
            GenBypass.Button = existingButton
            existingButton.Visible = GenBypass.Enabled
            return
        end

        pcall(function()
            existingUI:Destroy()
        end)
    end

    local Screen = Instance.new("ScreenGui")

    Screen.Name = "ReaperGenBypass"
    Screen.IgnoreGuiInset = true
    Screen.ResetOnSpawn = false
    Screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
    Screen.DisplayOrder = 999999
    Screen.Parent = CoreGui

    GenBypass.UI = Screen

    local Button = Instance.new("ImageButton")

    Button.Name = "BypassButton"
    Button.Size = UDim2.fromOffset(65, 65)
    Button.Position = GenBypass.ButtonPosition
    Button.BackgroundColor3 = GB_Colors.Background
    Button.BackgroundTransparency = 0.08
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.Visible = GenBypass.Enabled
    Button.ZIndex = 999999
    Button.Parent = Screen

    GB_ApplyStyle(
        Button,
        999,
        GB_Colors.Red,
        1.5,
        0.15
    )

    local Glow = Instance.new("UIStroke")

    Glow.Color = GB_Colors.Red
    Glow.Thickness = 5
    Glow.Transparency = 0.82
    Glow.Parent = Button

    local Label = Instance.new("TextLabel")

    Label.Name = "Label"
    Label.Size = UDim2.fromScale(1, 1)
    Label.BackgroundTransparency = 1
    Label.Text = "BOOST"
    Label.TextColor3 = GB_Colors.White
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Center
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.ZIndex = 1000000
    Label.Parent = Button

    local Dot = Instance.new("Frame")

    Dot.Name = "Status"
    Dot.Size = UDim2.fromOffset(7, 7)
    Dot.Position = UDim2.new(1, -12, 0, 6)
    Dot.BackgroundColor3 = Color3.fromRGB(40, 200, 64)
    Dot.BorderSizePixel = 0
    Dot.ZIndex = 1000001
    Dot.Parent = Button

    local DotCorner = Instance.new("UICorner")

    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    GenBypass.Button = Button

    Button.InputBegan:Connect(function(input)
        if GenBypass.LockButton then
            return
        end

        if input.UserInputType == Enum.UserInputType.Touch then
            GenBypass.Dragging = true
            GenBypass.Moved = false
            GenBypass.DragStart = input.Position
            GenBypass.StartPosition = Button.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    GenBypass.Dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not GenBypass.Dragging then
            return
        end

        if GenBypass.LockButton then
            return
        end

        if input.UserInputType == Enum.UserInputType.Touch then
            local delta =
                input.Position - GenBypass.DragStart

            if delta.Magnitude > 8 then
                GenBypass.Moved = true
            end

            Button.Position = UDim2.new(
                GenBypass.StartPosition.X.Scale,
                GenBypass.StartPosition.X.Offset + delta.X,
                GenBypass.StartPosition.Y.Scale,
                GenBypass.StartPosition.Y.Offset + delta.Y
            )

            GenBypass.ButtonPosition = Button.Position
        end
    end)

    Button.Activated:Connect(function()
        if GenBypass.Moved then
            GenBypass.Moved = false
            return
        end

        if not GenBypass.Enabled then
            return
        end

        local bestPoint, bestDist =
            GB_GetNearestPoint()

        if bestPoint and bestDist <= 8 then
            GB_DoRepair(bestPoint)
        end
    end)
end

local function UpdateButtonVisibility()
    if not GenBypass.Button
        or not GenBypass.Button.Parent then

        if GenBypass.Enabled then
            GB_CreateMobileButton()
        end

        return
    end

    GenBypass.Button.Visible =
        GenBypass.Enabled
        and GenBypass.IsMobile
end

task.spawn(function()
    while task.wait(0.5) do
        if not GenBypass.Enabled then
            continue
        end

        if not GenBypass.IsMobile then
            continue
        end

        if not GenBypass.UI
            or not GenBypass.UI.Parent then

            GenBypass.UI = nil
            GenBypass.Button = nil

            GB_CreateMobileButton()

            continue
        end

        if not GenBypass.Button
            or not GenBypass.Button.Parent then

            GenBypass.Button = nil

            GB_CreateMobileButton()

            continue
        end

        if not GenBypass.Button.Visible then
            GenBypass.Button.Visible = true
        end
    end
end)

Tabs.Automatic:AddToggle(
    "GenBypassToggle",
    {
        Title = "Enable Gen Bypass",
        Description = "",
        Default = false,

        Callback = function(Value)
            GenBypass.Enabled = Value

            if Value then
                GB_CreateMobileButton()
                UpdateButtonVisibility()
            else
                if GenBypass.Button
                    and GenBypass.Button.Parent then

                    GenBypass.Button.Visible = false
                end
            end
        end
    }
)

Tabs.Automatic:AddToggle(
    "LockBypassButton",
    {
        Title = "Lock Bypass Button",
        Description = "",
        Default = false,

        Callback = function(Value)
            GenBypass.LockButton = Value
        end
    }
)

-- Parry
local REAPER_ENV = (type(getgenv) == "function" and getgenv()) or _G
local REAPER_V3_RUNNING_KEY = "REAPER_V3_RUNNING"

if REAPER_ENV[REAPER_V3_RUNNING_KEY] then
    return
end

REAPER_ENV[REAPER_V3_RUNNING_KEY] = true

local function InitReaperV3()
local Parry = Tabs.Automatic:AddSection("Parry")
local Config = {
    Enabled = false,
    Distance = 9,
    ShowCircle = false,
    ShowStatusUI = false
}

local State = {
    Cooldown = false,
    CurrentCD = 0,
    Connections = {},
    DashData = {},
    LastInputStatus = "No input observed",
    LastSendStatus = "Not sent",
    FlickData = {},
    LastParryReason = "None",
    ParryRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Parrying Dagger"):WaitForChild("parry"),
    ResultRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Parrying Dagger"):WaitForChild("parryResult"),
    RayParams = RaycastParams.new()
}
State.RayParams.FilterType = Enum.RaycastFilterType.Exclude
local ATTACK_ANIMS = {
    ["113255068724446"] = true,
    ["74968262036854"] = true,
    ["110355011987939"] = true,
    ["139369275981139"] = true,
    ["132817836308238"] = true,
    ["129784271201071"] = true,
    ["133963973694098"] = true,
    ["117042998468241"] = true,
    ["105374834496520"] = true,
    ["111920872708571"] = true,
    ["78432063483146"] = true,
    ["118907603246885"] = true,
    ["138720291317243"] = true,
    ["115244153053858"] = true,
    ["130593238885843"] = true,
    ["122812055447896"] = true,
    ["78935059863801"] = true,
    ["135002183282873"] = true,
    ["121216847022485"] = true
}
local DASH_ANIM = "98163597193511"
local DASH_PARRY_LEAD = 1.10
local DASH_DETECTION_DISTANCE = 53
local DASH_MIN_ANIM_AGE = 0.06
local DASH_CLOSE_RANGE_MIN_ANIM_AGE = 0.65
local DASH_MID_RANGE_MIN_ANIM_AGE = 0.75

local DASH_LEAD_20 = 1.55
local DASH_LEAD_21 = 1.90
local DASH_LEAD_22 = 2.10
local DASH_LEAD_23 = 2.40
local DASH_LEAD_24 = 2.60
local DASH_LEAD_25 = 2.80
local DASH_LEAD_26 = 3.85
local DASH_LEAD_27 = 4.25
local DASH_LEAD_28 = 4.50
local DASH_LEAD_29 = 4.40
local DASH_LEAD_30 = 4.25
local DASH_LEAD_31 = 4.15
local DASH_LEAD_32 = 4.05
local DASH_LEAD_33 = 3.95
local DASH_LEAD_34 = 3.85
local DASH_LEAD_35 = 3.75
local DASH_LEAD_36 = 3.65
local DASH_LEAD_37 = 3.55
local DASH_LEAD_38 = 3.45
local DASH_LEAD_39 = 3.35
local DASH_LEAD_40 = 3.25
local DASH_LEAD_41 = 3.05
local DASH_LEAD_42 = 2.90
local DASH_LEAD_43 = 2.75
local DASH_LEAD_44 = 2.65
local DASH_LEAD_45 = 2.15
local DASH_LEAD_46 = 2.15
local DASH_LEAD_47 = 2.00
local DASH_LEAD_48 = 1.95
local DASH_LEAD_49 = 1.95
local DASH_LEAD_50 = 1.95
local DASH_LEAD_51 = 2.00
local DASH_LEAD_52 = 2.25
local DASH_LEAD_53 = 2.05

local DASH_MAX_LATERAL_MISS = 2.8
local DASH_EXTREME_LATERAL_MISS = 1.8
local DASH_STABLE_DIRECTION_DOT = math.cos(math.rad(24))
local DASH_EXTREME_STABLE_SAMPLES = 2
local DASH_PREDICTIVE_STABLE_SAMPLES = 1
local DASH_LONG_RANGE_FALLBACK_AGE = 0.20
local DASH_MIN_MOVEMENT = 0.025
local DASH_MIN_SPEED = 1.5
local DASH_MIN_DOT = math.cos(math.rad(60))
local DASH_IMPACT_BUFFER = 2.5
local DASH_HARD_MAX_START_DISTANCE = 53.0
local function DashLeadAtDistance(d)
   
    local anchors = {
        {20, DASH_LEAD_20}, {21, DASH_LEAD_21}, {22, DASH_LEAD_22},
        {23, DASH_LEAD_23}, {24, DASH_LEAD_24}, {25, DASH_LEAD_25},
        {26, DASH_LEAD_26}, {27, DASH_LEAD_27}, {28, DASH_LEAD_28},
        {29, DASH_LEAD_29}, {30, DASH_LEAD_30}, {31, DASH_LEAD_31},
        {32, DASH_LEAD_32}, {33, DASH_LEAD_33}, {34, DASH_LEAD_34},
        {35, DASH_LEAD_35}, {36, DASH_LEAD_36}, {37, DASH_LEAD_37},
        {38, DASH_LEAD_38}, {39, DASH_LEAD_39}, {40, DASH_LEAD_40},
        {41, DASH_LEAD_41}, {42, DASH_LEAD_42}, {43, DASH_LEAD_43},
        {44, DASH_LEAD_44}, {45, DASH_LEAD_45}, {46, DASH_LEAD_46},
        {47, DASH_LEAD_47}, {48, DASH_LEAD_48}, {49, DASH_LEAD_49},
        {50, DASH_LEAD_50}, {51, DASH_LEAD_51}, {52, DASH_LEAD_52},
        {53, DASH_LEAD_53}
    }
    
    if d <= 19 then
        return DASH_PARRY_LEAD
    end
    if d <= anchors[1][1] then
        return anchors[1][2]
    end
    for i = 1, #anchors - 1 do
        local x1, y1 = anchors[i][1], anchors[i][2]
        local x2, y2 = anchors[i + 1][1], anchors[i + 1][2]
        if d <= x2 then
            local t = (d - x1) / (x2 - x1)
            return y1 + (y2 - y1) * t
        end
    end
    return anchors[#anchors][2]
end
local FLICK_MIN_SPEED = 20
local FLICK_MIN_ANGLE = 2.5
local FLICK_MAX_TARGET_ANGLE = 72
local FLICK_DETECTION_EXTRA_RANGE = 10
local FLICK_MEMORY = 0.8
local GUI_NAME = "ReaperStatus"
local Colors = {
    Background = Color3.fromRGB(8, 8, 10),
    Background2 = Color3.fromRGB(13, 13, 16),
    Red = Color3.fromRGB(255, 30, 50),
    White = Color3.fromRGB(245, 245, 247),
    Muted = Color3.fromRGB(75, 75, 83),
    TrafficRed = Color3.fromRGB(255, 95, 87),
    TrafficYellow = Color3.fromRGB(254, 188, 46),
    TrafficGreen = Color3.fromRGB(40, 200, 64)
}
if CoreGui:FindFirstChild(GUI_NAME) then
    CoreGui[GUI_NAME]:Destroy()
end
local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = GUI_NAME
Screen.IgnoreGuiInset = true
local Main = Instance.new("Frame", Screen)
Main.Name = "Main"
Main.Size = UDim2.fromOffset(260, 100)
Main.Position = UDim2.fromScale(0.5, 0.4)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Colors.Background
Main.BorderSizePixel = 0
Main.Visible = false
local function ApplyStyle(obj, radius, color, thick, trans)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, radius)
    local s = Instance.new("UIStroke", obj)
    s.Color = color
    s.Thickness = thick
    s.Transparency = trans or 0
    return s
end
ApplyStyle(Main, 12, Colors.Red, 1.5, 0.2)
local MainGlow = Instance.new("UIStroke", Main)
MainGlow.Color = Colors.Red
MainGlow.Thickness = 6
MainGlow.Transparency = 0.8
local TopBar = Instance.new("Frame", Main)
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, -2, 0, 26)
TopBar.Position = UDim2.fromOffset(1, 1)
TopBar.BackgroundColor3 = Colors.Background2
TopBar.BorderSizePixel = 0
ApplyStyle(TopBar, 11, Colors.Red, 1, 0.8)
local Traffic = Instance.new("Frame", TopBar)
Traffic.Size = UDim2.fromOffset(45, 10)
Traffic.Position = UDim2.fromOffset(10, 8)
Traffic.BackgroundTransparency = 1
local tCols = {
    Colors.TrafficRed,
    Colors.TrafficYellow,
    Colors.TrafficGreen
}
for i, col in ipairs(tCols) do
    local d = Instance.new("Frame", Traffic)
    d.Size = UDim2.fromOffset(7, 7)
    d.Position = UDim2.fromOffset((i - 1) * 14, 0)
    d.BackgroundColor3 = col
    d.BorderSizePixel = 0
    Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
end
local Header = Instance.new("TextLabel", TopBar)
Header.Size = UDim2.new(1, -60, 1, 0)
Header.Position = UDim2.fromOffset(55, 0)
Header.BackgroundTransparency = 1
Header.Text = "REAPER X SYSTEM"
Header.TextColor3 = Colors.White
Header.TextTransparency = 0.4
Header.TextSize = 10
Header.Font = Enum.Font.GothamBold
Header.TextXAlignment = Enum.TextXAlignment.Left
local StatusArea = Instance.new("Frame", Main)
StatusArea.Size = UDim2.new(1, -20, 1, -35)
StatusArea.Position = UDim2.fromOffset(10, 35)
StatusArea.BackgroundTransparency = 1
local Indicator = Instance.new("Frame", StatusArea)
Indicator.Size = UDim2.fromOffset(6, 6)
Indicator.Position = UDim2.fromOffset(5, 11)
Indicator.BackgroundColor3 = Colors.TrafficGreen
Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
local IndGlow = Instance.new("UIStroke", Indicator)
IndGlow.Thickness = 3
IndGlow.Color = Colors.TrafficGreen
IndGlow.Transparency = 0.5
local DistLabel = Instance.new("TextLabel", StatusArea)
DistLabel.Size = UDim2.new(1, -20, 0, 15)
DistLabel.Position = UDim2.fromOffset(20, 5)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "Killer Distance : N/A"
DistLabel.TextColor3 = Colors.White
DistLabel.TextSize = 12
DistLabel.Font = Enum.Font.GothamBold
DistLabel.TextXAlignment = Enum.TextXAlignment.Left
local StatusLabel = Instance.new("TextLabel", StatusArea)
StatusLabel.Size = UDim2.new(1, -20, 0, 15)
StatusLabel.Position = UDim2.fromOffset(20, 23)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status : READY"
StatusLabel.TextColor3 = Colors.TrafficGreen
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
local function IsThreatening(killer, victim, range)
    local kPart = killer.PrimaryPart
    if not kPart then
        return false
    end
    local kCF = kPart.CFrame

    local angles = {
        -85, -76, -68, -60, -52, -44, -36, -28, -20, -12, 0,
         12,  20,  28,  36,  44,  52,  60,  68,  76, 85
    }
    local levels = {
        {offset = -2.2, pitch = math.rad(-18)},
        {offset = -1.1, pitch = math.rad(-9)},
        {offset = 0, pitch = 0},
        {offset = 1.1, pitch = math.rad(9)},
        {offset = 2.2, pitch = math.rad(18)}
    }
    State.RayParams.FilterDescendantsInstances = {
        killer,
        workspace.CurrentCamera
    }
    for i = 1, #levels do
        local origin = (kCF * CFrame.new(0, levels[i].offset, 0)).Position
        for j = 1, #angles do
            local direction = (
                kCF * CFrame.Angles(
                    levels[i].pitch,
                    math.rad(angles[j]),
                    0
                )
            ).LookVector
            local rayResult = workspace:Raycast(
                origin,
                direction * (range + 3),
                State.RayParams
            )
            if rayResult and rayResult.Instance:IsDescendantOf(victim) then
                return true
            end
        end
    end
    return false
end

local function IsFlickThreateningFast(killer, victim, range)
    local kPart = killer and killer.PrimaryPart
    if not kPart or not victim then
        return false
    end

    local angles = {-60, -40, -20, 0, 20, 40, 60}
    local levels = {
        {offset = -1.2, pitch = math.rad(-10)},
        {offset = 0, pitch = 0},
        {offset = 1.2, pitch = math.rad(10)}
    }
    State.RayParams.FilterDescendantsInstances = {killer, workspace.CurrentCamera}
    local cf = kPart.CFrame
    local rayLength = range + 3

    for _, level in ipairs(levels) do
        local origin = (cf * CFrame.new(0, level.offset, 0)).Position
        for _, angle in ipairs(angles) do
            local direction = (cf * CFrame.Angles(level.pitch, math.rad(angle), 0)).LookVector
            local result = workspace:Raycast(origin, direction * rayLength, State.RayParams)
            if result and result.Instance:IsDescendantOf(victim) then
                return true
            end
        end
    end
    return false
end

local function GetRole(p)
    local team = p.Team and p.Team.Name or "None"
    local tl = team:lower()
    if tl:find("killer") or tl:find("murder") or tl:find("beast") then
        return "Killer"
    end
    if tl:find("survivor") or tl:find("innocent") or tl:find("human") then
        return "Survivors"
    end
    return "Spectator"
end
State.ResultRemote.OnClientEvent:Connect(function(_, cd)
    State.CurrentCD = tonumber(cd) or 0.8
    State.Cooldown = true
end)

local function IsParryBlocked()
    local char = LocalPlayer.Character
    if not char then return true end

    local state = tostring(char:GetAttribute("State") or ""):lower()
    if state == "downed" or state == "dead" or state == "hook" or state == "hooked" then
        return true
    end

    if char:GetAttribute("Knocked") == true
        or char:GetAttribute("IsHooked") == true
        or char:GetAttribute("isHooked") == true
        or char:GetAttribute("Hooked") == true
        or char:GetAttribute("IsDowned") == true then
        return true
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return true end
    if not char:FindFirstChild("HumanoidRootPart") then return true end
    return false
end

local function PerformInput()
    if IsParryBlocked() then
        State.LastInputStatus = "Blocked: local character Down/Hook/Dead"
        return false
    end
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local mobGui = playerGui and playerGui:FindFirstChild("Survivor-mob", true)
    local mobBtn = mobGui and mobGui:FindFirstChild("Gui-mob", true)

    if mobBtn and mobBtn.Visible then
        local signalOK, signalErr = pcall(function()
            firesignal(mobBtn.MouseButton1Down)
        end)
        State.LastInputStatus = signalOK and "FireSignal MouseButton1Down:ok"
            or ("FireSignal error: " .. tostring(signalErr))
        if signalOK then return true end
    end

    local downOK, downErr = pcall(function()
        VIM:SendMouseButtonEvent(0, 0, 1, true, game, 0)
    end)
    task.wait(0.01)
    local upOK, upErr = pcall(function()
        VIM:SendMouseButtonEvent(0, 0, 1, false, game, 0)
    end)
    local ok = downOK and upOK
    State.LastInputStatus = ok and "VIM mouse press:ok"
        or ("VIM input error: " .. tostring(downErr or upErr))
    return ok
end

local function TriggerParry(reason)
    if IsParryBlocked() then
        State.LastParryReason = (reason or "Attack") .. " blocked: local character Down/Hook/Dead"
        State.LastInputStatus = "Blocked: local character Down/Hook/Dead"
        State.LastSendStatus = "Blocked: FireServer not sent"
        return false
    end
    if State.Cooldown then
        State.LastParryReason = (reason or "Attack") .. " blocked by cooldown"
        return false
    end

    State.Cooldown = true
    State.CurrentCD = math.max(State.CurrentCD, 0.8)
    State.LastParryReason = reason or "Attack"

    local isFastThreat = reason == "Dash" or reason == "Flick Attack"

    local inputOK = false
    if isFastThreat then
        inputOK = PerformInput()
    end

    local sentCount = 0
    local lastRemoteError
    for _ = 1, 8 do

        if IsParryBlocked() then break end
        local ok, err = pcall(function()
            State.ParryRemote:FireServer()
        end)
        if ok then
            sentCount += 1
        else
            lastRemoteError = err
        end
    end
    State.LastSendStatus = IsParryBlocked()
        and (sentCount > 0 and ("FireServer stopped after " .. tostring(sentCount) .. "/8: Down/Hook") or "Blocked: FireServer not sent")
        or (sentCount > 0 and ("FireServer attempted: " .. tostring(sentCount) .. "/8")
            or ("FireServer error: " .. tostring(lastRemoteError)))

    if not isFastThreat and not IsParryBlocked() then
        inputOK = PerformInput()
    end
    return sentCount > 0 or inputOK
end

local function GetActiveAttack(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if not animator then
        return false, false
    end

    local normalAttack = false
    local dashAttack = false
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        local animation = track.Animation
        local animationId = animation and animation.AnimationId and animation.AnimationId:match("%d+")

        local priority = track.Priority
        local actionPriority = priority == Enum.AnimationPriority.Action
            or priority == Enum.AnimationPriority.Action2
            or priority == Enum.AnimationPriority.Action3
            or priority == Enum.AnimationPriority.Action4
        local weight = track.WeightCurrent or 0

        if track.IsPlaying and weight >= 0.08 then
            if animationId == DASH_ANIM then
                dashAttack = true
            elseif actionPriority and animationId and ATTACK_ANIMS[animationId] then
                normalAttack = true
            end
        end
    end

    return normalAttack, dashAttack
end
local function IsValidParryTarget(killer, maxDistance)
    if not Config.Enabled or GetRole(LocalPlayer) ~= "Survivors" then
        return nil, nil
    end
    local myChar = LocalPlayer.Character
    if not myChar or myChar:GetAttribute("State") == "Downed" then
        return nil, nil
    end
    local kRoot = killer and killer.PrimaryPart
    local vRoot = myChar.PrimaryPart
    if not kRoot or not vRoot then
        return nil, nil
    end
    if (vRoot.Position - kRoot.Position).Magnitude > (maxDistance or Config.Distance) then
        return nil, nil
    end
    return myChar, kRoot
end
local function GetHorizontalDirection(vector)
    local flat = Vector3.new(vector.X, 0, vector.Z)
    if flat.Magnitude <= 0.0001 then
        return nil
    end
    return flat.Unit
end
local function GetDirectionToTarget(killer, target)
    local kRoot = killer and killer.PrimaryPart
    local vRoot = target and target.PrimaryPart
    if not kRoot or not vRoot then
        return nil
    end
    local delta = vRoot.Position - kRoot.Position
    local flat = Vector3.new(delta.X, 0, delta.Z)
    if flat.Magnitude <= 0.0001 then
        return nil
    end
    return flat.Unit
end
local function UpdateDashTracking(killer, dashActive)
    local root = killer and killer.PrimaryPart
    if not root then
        State.DashData[killer] = nil
        return nil
    end
    local now = os.clock()
    local position = root.Position
    local velocity = root.AssemblyLinearVelocity
    local data = State.DashData[killer]
    if not data or not data.Active then
        data = {
            Active = true,
            StartTime = now,
            LastPosition = position,
            LastTime = now,
            Direction = nil,
            PreviousDirection = nil,
            DirectionStableSamples = 0,
            Speed = 0,
            InRangeSince = nil,
            Triggered = false,
            LastDot = -1
        }
        State.DashData[killer] = data
        return data
    end
    local deltaTime = now - data.LastTime
    if deltaTime <= 0 then
        return data
    end
    local movement = position - data.LastPosition
    local movementFlat = Vector3.new(movement.X, 0, movement.Z)
    local movementMagnitude = movementFlat.Magnitude
    local movementDirection
    if movementMagnitude >= DASH_MIN_MOVEMENT then
        movementDirection = movementFlat.Unit
    end
    local velocityFlat = Vector3.new(
        velocity.X,
        0,
        velocity.Z
    )
    local velocityMagnitude = velocityFlat.Magnitude
    if not movementDirection and velocityMagnitude >= DASH_MIN_SPEED then
        movementDirection = velocityFlat.Unit
    end
    if movementDirection then
        local previousDirection = data.Direction
        data.PreviousDirection = previousDirection
        if previousDirection and previousDirection:Dot(movementDirection) >= DASH_STABLE_DIRECTION_DOT then
            data.DirectionStableSamples = (data.DirectionStableSamples or 0) + 1
        else
            data.DirectionStableSamples = 0
        end
        data.Direction = movementDirection
    end
    if movementMagnitude > 0 then
        data.Speed = movementMagnitude / deltaTime
    elseif velocityMagnitude > 0 then
        data.Speed = velocityMagnitude
    else
        data.Speed = 0
    end
    data.LastPosition = position
    data.LastTime = now
    return data
end
local function IsDashTrajectoryValid(killer, target, data)
    if not data or not data.Direction then
        return false, nil
    end
    if data.Speed < DASH_MIN_SPEED then
        return false, nil
    end
    local targetDirection = GetDirectionToTarget(killer, target)
    if not targetDirection then
        return false, nil
    end

    local dot = data.Direction:Dot(targetDirection)
    data.LastDot = dot
    if dot < DASH_MIN_DOT then
        return false, dot
    end

    local kRoot = killer and killer.PrimaryPart
    local vRoot = target and target.PrimaryPart
    if not kRoot or not vRoot then
        return false, dot
    end

    local kVel = kRoot.AssemblyLinearVelocity
    local vVel = vRoot.AssemblyLinearVelocity
    local kFlat = Vector3.new(kVel.X, 0, kVel.Z)
    local vFlat = Vector3.new(vVel.X, 0, vVel.Z)

    local flatOffset = Vector3.new(vRoot.Position.X - kRoot.Position.X, 0,
        vRoot.Position.Z - kRoot.Position.Z)
    local lateralMiss = math.abs(flatOffset.X * data.Direction.Z - flatOffset.Z * data.Direction.X)
    data.LateralMiss = lateralMiss
    local allowedLateralMiss = DASH_MAX_LATERAL_MISS
    if flatOffset.Magnitude > 40 then
        allowedLateralMiss = DASH_EXTREME_LATERAL_MISS
    end
    if lateralMiss > allowedLateralMiss then
        return false, dot
    end

    local currentSpeed = kFlat.Magnitude

    local facing = GetHorizontalDirection(kRoot.CFrame.LookVector)
    if not facing then
        return false, dot
    end
    local facingDot = facing:Dot(targetDirection)
    if facingDot < math.cos(math.rad(65)) then
        return false, facingDot
    end

    local predictiveRange = flatOffset.Magnitude >= 20
    local stableSamples = data.DirectionStableSamples or 0

    if currentSpeed >= DASH_MIN_SPEED then
        local velocityDot = kFlat.Unit:Dot(targetDirection)
        local closingSpeed = (kFlat - vFlat):Dot(targetDirection)
        local velocityValid = velocityDot >= DASH_MIN_DOT and closingSpeed > 0.5
        if not velocityValid then
            if not predictiveRange or stableSamples < DASH_PREDICTIVE_STABLE_SAMPLES then
                return false, velocityDot
            end
            local sampledClosingSpeed = (data.Direction * data.Speed - vFlat):Dot(targetDirection)
            if dot < DASH_MIN_DOT or sampledClosingSpeed <= 0.5 then
                return false, dot
            end
        end
    else
        if dot < DASH_MIN_DOT then
            return false, dot
        end
    end
    return true, dot
end
local function EstimateDashImpactTime(killer, target, data, distance)
    local kRoot = killer and killer.PrimaryPart
    local vRoot = target and target.PrimaryPart
    if not kRoot or not vRoot or not data then
        return nil, 0
    end

    local toTarget = GetDirectionToTarget(killer, target)
    if not toTarget then
        return nil, 0
    end

    local targetVelocity = vRoot.AssemblyLinearVelocity
    local targetFlatVelocity = Vector3.new(targetVelocity.X, 0, targetVelocity.Z)
    local killerVelocity = kRoot.AssemblyLinearVelocity
    local killerFlatVelocity = Vector3.new(killerVelocity.X, 0, killerVelocity.Z)

    local dashSpeed = math.max(data.Speed or 0, killerFlatVelocity.Magnitude)
    local dashDirection = data.Direction or GetHorizontalDirection(killerFlatVelocity)
    if not dashDirection or dashSpeed < DASH_MIN_SPEED then
        return nil, 0
    end

    local alignment = math.clamp(dashDirection:Dot(toTarget), -1, 1)
    if alignment < DASH_MIN_DOT then
        return nil, alignment
    end

    local closingSpeed = (dashDirection * dashSpeed - targetFlatVelocity):Dot(toTarget)
    if closingSpeed <= 0.5 then
        return nil, alignment
    end

    local offset = Vector3.new(vRoot.Position.X - kRoot.Position.X, 0,
        vRoot.Position.Z - kRoot.Position.Z)
    local alongPath = offset:Dot(dashDirection)
    if alongPath <= 0 then
        return nil, alignment
    end
    local lateralMiss = math.abs(offset.X * dashDirection.Z - offset.Z * dashDirection.X)
    local allowedLateralMiss = distance > 40 and DASH_EXTREME_LATERAL_MISS or DASH_MAX_LATERAL_MISS
    if lateralMiss > allowedLateralMiss then
        return nil, alignment
    end
    local remainingDistance = math.max(0, alongPath - Config.Distance)
    return remainingDistance / closingSpeed, alignment
end

local function UpdateFlickTracking(killer)
    local root = killer and killer.PrimaryPart
    if not root then
        State.FlickData[killer] = nil
        return nil
    end
    local now = os.clock()
    local look = GetHorizontalDirection(root.CFrame.LookVector)
    if not look then
        return nil
    end
    local data = State.FlickData[killer]
    if not data then
        data = {
            LastDirection = look,
            LastTime = now,
            LastTargetAngle = nil,
            Triggered = false,
            FlickUntil = 0,
            AngularSpeed = 0,
            Angle = 0
        }
        State.FlickData[killer] = data
        return data
    end
    local dt = now - data.LastTime
    if dt <= 0 then
        return data
    end
    local previous = data.LastDirection
    local dot = math.clamp(previous:Dot(look), -1, 1)
    local angle = math.deg(math.acos(dot))
    local angularSpeed = angle / dt
    data.LastDirection = look
    data.LastTime = now
    data.AngularSpeed = angularSpeed
    data.Angle = angle
    if angularSpeed >= FLICK_MIN_SPEED and angle >= FLICK_MIN_ANGLE then
        data.FlickUntil = now + FLICK_MEMORY
        data.Triggered = false
    end
    return data
end
local function IsFlickThreatening(killer, target, data)
    if not data then
        return false
    end
    if data.Triggered or os.clock() > (data.FlickUntil or 0) then
        return false
    end
    local targetDirection = GetDirectionToTarget(killer, target)
    if not targetDirection or not data.LastDirection then
        return false
    end
    local dot = math.clamp(
        data.LastDirection:Dot(targetDirection),
        -1,
        1
    )
    local targetAngle = math.deg(math.acos(dot))
    if targetAngle > FLICK_MAX_TARGET_ANGLE then
        return false
    end
    data.LastTargetAngle = targetAngle
    return true
end
local function ResetDash(killer)
    State.DashData[killer] = nil
end
local function ResetFlick(killer)
    State.FlickData[killer] = nil
end
local function AttachSensor(char)
    if not char then
        return
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if animator then
        State.Connections[char] = animator
    end
end
local RangeAdorn = Instance.new("CylinderHandleAdornment", workspace.Terrain)
RangeAdorn.Height = 0.1
RangeAdorn.Transparency = 0.5
RunService.RenderStepped:Connect(function(dt)
    if State.CurrentCD > 0 then
        State.CurrentCD = math.max(
            0,
            State.CurrentCD - dt
        )
        if State.CurrentCD <= 0 then
            State.Cooldown = false
        end
    end
    local myChar = LocalPlayer.Character
    local myRole = GetRole(LocalPlayer)
    Main.Visible = Config.ShowStatusUI
    if not myChar or not myChar.PrimaryPart then
        return
    end
    local myPos = myChar.PrimaryPart.Position
    local closestDist = 999
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer
            and p.Character
            and p.Character.PrimaryPart
            and GetRole(p) == "Killer"
        then
            local d = (
                myPos -
                p.Character.PrimaryPart.Position
            ).Magnitude
            if d < closestDist then
                closestDist = d
            end
        end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer
            and p.Character
            and p.Character.PrimaryPart
            and GetRole(p) == "Killer"
        then
            local killer = p.Character
            local normalAttack, dashAttack = GetActiveAttack(killer)

            if dashAttack then
                local dashData = UpdateDashTracking(killer, true)
                if dashData and not dashData.Triggered then
                    local targetChar = IsValidParryTarget(killer, DASH_DETECTION_DISTANCE)
                    if targetChar then
                        local kRoot = killer.PrimaryPart
                        local vRoot = targetChar.PrimaryPart
                        local distance = (vRoot.Position - kRoot.Position).Magnitude

                        if dashData.StartTargetDistance == nil then
                            local startTarget = IsValidParryTarget(killer, DASH_HARD_MAX_START_DISTANCE + 10)
                            if startTarget and startTarget.PrimaryPart then
                                dashData.StartTargetDistance = (startTarget.PrimaryPart.Position - kRoot.Position).Magnitude
                            end
                        end
                        local targetDirection = GetDirectionToTarget(killer, targetChar)
                        local facing = GetHorizontalDirection(kRoot.CFrame.LookVector)
                        local facingTarget = false

                        if facing and targetDirection then
                            facingTarget = facing:Dot(targetDirection) >= math.cos(math.rad(55))
                        end

                        local trajectoryValid = IsDashTrajectoryValid(killer, targetChar, dashData)
                        local impactETA = nil
                        if trajectoryValid then
                            impactETA = EstimateDashImpactTime(killer, targetChar, dashData, distance)
                        end
                        local dashAnimationAge = os.clock() - (dashData.StartTime or os.clock())
                        local predictionLead = DashLeadAtDistance(distance)
                        local predictedImpact = impactETA ~= nil and impactETA <= predictionLead
                        local longRangeLead = predictionLead
                        local longRangePredictedImpact = distance >= 11
                            and ((impactETA ~= nil and impactETA <= longRangeLead)
                                or (impactETA == nil and facingTarget
                                    and dashAnimationAge >= DASH_LONG_RANGE_FALLBACK_AGE))

                        local extendedRange = distance >= 26 and distance < 30
                        local midExtendedRange = distance >= 30 and distance <= 35
                        local ultraRange = distance > 35
                        local extremeRange = distance > 40
                        local extendedRangePredictedImpact = extendedRange
                            and ((impactETA ~= nil and impactETA <= predictionLead)
                                or (impactETA == nil and trajectoryValid and facingTarget
                                    and dashAnimationAge >= DASH_MIN_ANIM_AGE))
                        local midExtendedRangePredictedImpact = midExtendedRange
                            and ((impactETA ~= nil and impactETA <= predictionLead)
                                or (impactETA == nil and trajectoryValid and facingTarget
                                    and dashAnimationAge >= DASH_MIN_ANIM_AGE))
                        local ultraLead = predictionLead
                        local ultraRangePredictedImpact = ultraRange
                            and ((impactETA ~= nil and impactETA <= ultraLead)
                                or (impactETA == nil and trajectoryValid and facingTarget
                                    and dashAnimationAge >= DASH_LONG_RANGE_FALLBACK_AGE))
                        local extremeDirectionStable = not extremeRange
                            or (dashData.DirectionStableSamples or 0) >= DASH_EXTREME_STABLE_SAMPLES

                        local nearImpactFallback = distance <= (Config.Distance + DASH_IMPACT_BUFFER)
                        local dashTimingReady = predictedImpact or longRangePredictedImpact or extendedRangePredictedImpact or midExtendedRangePredictedImpact or ultraRangePredictedImpact or nearImpactFallback

                        local finalTrajectoryValid = trajectoryValid
                        local finalTrajectoryDot = nil
                        local finalImpactETA = nil
                        if distance >= 20 then
                            finalTrajectoryValid, finalTrajectoryDot = IsDashTrajectoryValid(killer, targetChar, dashData)
                            if finalTrajectoryValid then
                                finalImpactETA = EstimateDashImpactTime(killer, targetChar, dashData, distance)
                            end
                        end
                            
                        local finalLead = predictionLead
                        local finalEtaTolerance = (distance >= 20 and distance <= 40) and 0.18 or 0
                        local predictiveStableConfirmed = distance < 20
                            or (dashData.DirectionStableSamples or 0) >= DASH_PREDICTIVE_STABLE_SAMPLES
                        local finalEtaConfirmed = distance < 20
                            or (finalImpactETA ~= nil and finalImpactETA <= (finalLead + finalEtaTolerance))
                        local startDistanceAllowed = (dashData.StartTargetDistance or distance) <= DASH_HARD_MAX_START_DISTANCE
                        local triggerDistanceAllowed = distance <= DASH_HARD_MAX_START_DISTANCE
                        local finalDashConfirmed = distance < 20
                            or (finalTrajectoryValid and finalEtaConfirmed and predictiveStableConfirmed
                                and startDistanceAllowed and triggerDistanceAllowed)

                        local closeRangeHold = distance <= 7
                            and dashAnimationAge < DASH_CLOSE_RANGE_MIN_ANIM_AGE
                        local midRangeHold = distance > 7 and distance <= 10
                            and dashAnimationAge < DASH_MID_RANGE_MIN_ANIM_AGE

                        local threatDirectionValid = (extendedRange or ultraRange)
                            and trajectoryValid and extremeDirectionStable
                            or (not extendedRange and not ultraRange and (facingTarget or trajectoryValid))

                        if not State.Cooldown
                            and threatDirectionValid
                            and dashTimingReady
                            and finalDashConfirmed
                            and dashAnimationAge >= DASH_MIN_ANIM_AGE
                            and not closeRangeHold
                            and not midRangeHold
                        then
                            if TriggerParry("Dash") then
                                dashData.Triggered = true
                            end
                        end
                    end
                end
            else
                ResetDash(killer)

                local flickData = UpdateFlickTracking(killer)
                if not State.Cooldown then
                    local targetChar = IsValidParryTarget(killer, Config.Distance + FLICK_DETECTION_EXTRA_RANGE)
                    if targetChar then
                        local targetDistance = (targetChar.PrimaryPart.Position - killer.PrimaryPart.Position).Magnitude
   
                        if normalAttack
                            and targetDistance <= Config.Distance
                            and IsFlickThreatening(killer, targetChar, flickData)
                        then
                            if TriggerParry("Flick Attack") then
                                if flickData then flickData.Triggered = true end
                                break
                            end
                        elseif normalAttack
                            and targetDistance <= Config.Distance
                            and IsThreatening(killer, targetChar, Config.Distance)
                        then
                            TriggerParry("Normal Attack")
                            break
                        end
                    end
                elseif not normalAttack and flickData then
                    flickData.LastTargetAngle = nil
                end
            end
        end
    end
    if Config.ShowStatusUI then
        if myRole ~= "Survivors" then
            DistLabel.Text = "Killer Distance : N/A"
            StatusLabel.Text = "Status : N/A"
            StatusLabel.TextColor3 = Colors.Muted
            Indicator.BackgroundColor3 = Colors.Muted
            IndGlow.Color = Colors.Muted
        else
            DistLabel.Text =
                "Killer Distance : " ..
                (
                    closestDist == 999
                    and "N/A"
                    or string.format("%.1f", closestDist)
                )
            if State.CurrentCD > 0 then
                StatusLabel.Text =
                    string.format(
                        "Status : %s CD (%.1fs)",
                        State.LastParryReason,
                        State.CurrentCD
                    )
                StatusLabel.TextColor3 = Colors.TrafficYellow
                Indicator.BackgroundColor3 = Colors.TrafficYellow
            else
                StatusLabel.Text = "Status : READY"
                StatusLabel.TextColor3 = Colors.TrafficGreen
                Indicator.BackgroundColor3 = Colors.TrafficGreen
            end
            IndGlow.Color = Indicator.BackgroundColor3
        end
    end
    if Config.ShowCircle and myRole == "Survivors" then
        RangeAdorn.Visible = true
        RangeAdorn.Color3 =
            (
                State.CurrentCD > 0
                and Colors.TrafficYellow
            )
            or (
                closestDist <= Config.Distance
                and Colors.TrafficRed
            )
            or Colors.TrafficGreen
        RangeAdorn.Radius = Config.Distance
        RangeAdorn.InnerRadius = Config.Distance - 0.2
        RangeAdorn.Adornee = workspace.Terrain
        RangeAdorn.CFrame =
            CFrame.new(
                myPos - Vector3.new(0, 2.9, 0)
            )
            * CFrame.Angles(math.pi / 2, 0, 0)
    else
        RangeAdorn.Visible = false
    end
end)
if Tabs and Tabs.Automatic then
    Tabs.Automatic:AddToggle("AutoParry", {
        Title = "Auto Parry",
        Default = Config.Enabled,
        Callback = function(V)
            Config.Enabled = V
        end
    })
    Tabs.Automatic:AddSlider("ParryRange", {
        Title = "Parry Range",
        Default = Config.Distance,
        Min = 5,
        Max = 12,
        Rounding = 1,
        Callback = function(V)
            Config.Distance = tonumber(V) or 9
        end
    })
    Tabs.Automatic:AddToggle("ShowRange", {
        Title = "Show Range Circle",
        Default = Config.ShowCircle,
        Callback = function(V)
            Config.ShowCircle = V
        end
    })
    Tabs.Automatic:AddToggle("ShowStatusUI", {
        Title = "Show Status UI",
        Default = Config.ShowStatusUI,
        Callback = function(V)
            Config.ShowStatusUI = V
        end
    })

end
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(AttachSensor)
        if p.Character then
            AttachSensor(p.Character)
        end
    end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(AttachSensor)
end)
end

local ok, err = xpcall(InitReaperV3, function(e)
    return debug.traceback(tostring(e), 2)
end)

if not ok then
    REAPER_ENV[REAPER_V3_RUNNING_KEY] = nil
    error(err, 0)
end




-- Auto Crouch
;(function()
local ACM = getgenv().REAPER_ACM or {}
getgenv().REAPER_ACM = ACM

ACM.Enabled = ACM.Enabled or false
ACM.Busy = false
ACM.Attached = ACM.Attached or {}
ACM.Connections = ACM.Connections or {}
ACM.AnimationId = "80411309607666"
ACM.MaxDistance = 40
ACM.CrouchDuration = 1.2
function ACM.IsDowned(char)
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        return true
    end
    local state = char:GetAttribute("State")
    return state == "Downed" or state == "Dead"
end
function ACM.IsKiller(player)
    return player ~= nil
        and player.Team ~= nil
        and player.Team.Name == "Killer"
end
function ACM.PressButton()
    pcall(function()
        local gui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local mobile = gui and gui:FindFirstChild("Survivor-mob")
        local controls = mobile and mobile:FindFirstChild("Controls")
        local button = controls and controls:FindFirstChild("crouch")
        if button and typeof(firesignal) == "function" then
            firesignal(button.MouseButton1Click)
        end
    end)
end
function ACM.SetCrouch(char, humanoid, enabled)
    pcall(function()
        char:SetAttribute("Crouching", enabled)
    end)
    pcall(function()
        ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer(
            "Crouchingserver", enabled
        )
    end)
    if enabled then
        pcall(function()
            ReplicatedStorage.Remotes.Chase.Runevent:FireServer(char, false)
        end)
    end
    if humanoid then
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Landed)
        end)
    end
end
function ACM.TriggerCrouch()
    if not ACM.Enabled or ACM.Busy then
        return
    end
    ACM.Busy = true
    task.spawn(function()
        local char
        local humanoid
        local started = false
        local ok, err = pcall(function()
            char = LocalPlayer.Character
            if not char or ACM.IsDowned(char) then
                return
            end
            humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                return
            end
            ACM.SetCrouch(char, humanoid, true)
            started = true
            ACM.PressButton()
            local startTime = os.clock()
            while os.clock() - startTime < ACM.CrouchDuration do
                if not ACM.Enabled or LocalPlayer.Character ~= char then
                    break
                end
                pcall(function()
                    ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer(
                        "Crouchingserver", true
                    )
                end)
                task.wait(0.1)
            end
        end)
        if started and char then
            ACM.SetCrouch(char, humanoid, false)
            ACM.PressButton()
        end
        ACM.Busy = false
        if not ok then
            warn("[REAPER Auto Crouch Mobile]", err)
        end
    end)
end
function ACM.AttachCharacter(kChar)
    if not kChar or ACM.Attached[kChar] then
        return
    end
    ACM.Attached[kChar] = true
    task.spawn(function()
        local humanoid =
            kChar:FindFirstChildOfClass("Humanoid")
            or kChar:WaitForChild("Humanoid", 5)
        if not humanoid then
            ACM.Attached[kChar] = nil
            return
        end
        local animator =
            humanoid:FindFirstChildOfClass("Animator")
            or humanoid:WaitForChild("Animator", 5)
        if not animator then
            ACM.Attached[kChar] = nil
            return
        end
        local animConnection
        animConnection = animator.AnimationPlayed:Connect(function(track)
            if not ACM.Enabled then
                return
            end
            local animation = track.Animation
            local id = animation and animation.AnimationId:match("%d+")
            if id ~= ACM.AnimationId then
                return
            end
            local myChar = LocalPlayer.Character
            if ACM.IsDowned(myChar) then
                return
            end
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            local killerRoot = kChar:FindFirstChild("HumanoidRootPart")
            if not myRoot or not killerRoot then
                return
            end
            if (myRoot.Position - killerRoot.Position).Magnitude <= ACM.MaxDistance then
                ACM.TriggerCrouch()
            end
        end)
        ACM.Connections[kChar] = animConnection
        local ancestryConnection
        ancestryConnection = kChar.AncestryChanged:Connect(function(_, parent)
            if parent then
                return
            end
            if animConnection then
                animConnection:Disconnect()
            end
            if ancestryConnection then
                ancestryConnection:Disconnect()
            end
            ACM.Connections[kChar] = nil
            ACM.Attached[kChar] = nil
        end)
    end)
end
function ACM.TryAttach(player)
    if player == LocalPlayer then
        return
    end
    if ACM.IsKiller(player) and player.Character then
        ACM.AttachCharacter(player.Character)
    end
end
function ACM.SetupPlayer(player)
    if player == LocalPlayer then
        return
    end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        ACM.TryAttach(player)
    end)
    player:GetPropertyChangedSignal("Team"):Connect(function()
        ACM.TryAttach(player)
    end)
    ACM.TryAttach(player)
end
for _, player in ipairs(Players:GetPlayers()) do
    ACM.SetupPlayer(player)
end
Players.PlayerAdded:Connect(function(player)
    ACM.SetupPlayer(player)
end)
task.spawn(function()
    while true do
        task.wait(5)
        for _, player in ipairs(Players:GetPlayers()) do
            ACM.TryAttach(player)
        end
    end
end)

    Tabs.Automatic:AddSection("Auto Crouch")

    Tabs.Automatic:AddToggle("AutoCrouchMobile", {
        Title = "Auto Crouch BETA",
        Default = ACM.Enabled,
        Callback = function(v)
            ACM.Enabled = v == true
        end
    })
end)()



        
-- Auto Heal
local HealSection = Tabs.Automatic:AddSection("HEAL")

local HealConnection -- ต้องอยู่นอกฟังก์ชัน

-- 2. ต้องวางฟังก์ชัน fireSelfHeal ไว้ก่อนหน้า Toggle เสมอ
local function fireSelfHeal(state)
    -- เช็คเผื่อกรณี Remote หรือ Character ไม่มีอยู่จริง
    local char = LocalPlayer.Character
    if not char then return end
    
    local remote = ReplicatedStorage:FindFirstChild("Remotes") 
        and ReplicatedStorage.Remotes:FindFirstChild("Healing") 
        and ReplicatedStorage.Remotes.Healing:FindFirstChild("HealEvent")

    if remote then
        pcall(function()
            remote:FireServer(char:FindFirstChild("HumanoidRootPart"), state)
        end)
    end
end

-- 4. ส่วนของ Toggle
Tabs.Automatic:AddToggle("SelfHeal", {
    Title = "Aura Heal (Self)", 
    Default = false,
    Callback = function(Value)
        -- ล้าง Connection เก่าทิ้ง
        if HealConnection then
            HealConnection:Disconnect()
            HealConnection = nil
            -- เช็คก่อนเรียกใช้เพื่อป้องกัน nil error
            if fireSelfHeal then fireSelfHeal(false) end 
        end

        if Value then
            -- ตรวจสอบว่าฟังก์ชันมีตัวตนก่อนเริ่ม Loop
            if not fireSelfHeal then 
                Fluent:Notify({Title = "Error", Content = "Function fireSelfHeal not found!"})
                return 
            end

            HealConnection = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hum then return end

                local checkScript = char:FindFirstChild("CheckInterractable")
                local isHealing = checkScript and checkScript:GetAttribute("isHealing")

                if hum.Health > 0 and hum.Health < hum.MaxHealth * 0.9 then
                    if not isHealing then
                        fireSelfHeal(true)
                    end
                elseif hum.Health >= hum.MaxHealth * 0.9 then
                    if isHealing then
                        fireSelfHeal(false)
                    end
                end
            end)
        end
    end
})


-- Auto Exit
local Exit = Tabs.Automatic:AddSection("Escape")

local function GetRole()
    if not LocalPlayer.Team then return "Unknown" end
    local name = LocalPlayer.Team.Name
    if name == "Killer" then return "Killer" end
    if name == "Survivors" then return "Survivor" end
    return "Lobby"
end

-- // Core Logic: Beat Survivor (Exact Logic)
local function KYS_BeatGameSurvivor()
    -- ตรวจสอบ Role: ถ้าไม่ใช่ Survivor จะไม่ทำงาน (ไม่มีการแจ้งเตือน)
    if GetRole() ~= "Survivor" then return end

    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local exitPos = nil
    local finishPart = nil
    local map = Workspace:FindFirstChild("Map")

    -- 1. Scan finishline
    for _, obj in ipairs(workspace:GetDescendants()) do
        local nameLower = string.lower(obj.Name)
        if (nameLower == "fininshline" or nameLower == "finishline") and obj:IsA("BasePart") then
            finishPart = obj
            exitPos = obj.Position
            break
        end
    end

    -- 2. Fallback Maps
    if not exitPos and map then
        if map:FindFirstChild("RooftopHitbox") or map:FindFirstChild("Rooftop") then
            finishPart = map:FindFirstChild("RooftopHitbox") or map:FindFirstChild("Rooftop")
            if finishPart:IsA("Model") then finishPart = finishPart.PrimaryPart or finishPart:FindFirstChildWhichIsA("BasePart") end
            exitPos = finishPart and finishPart.Position or Vector3.new(3098.16, 454.04, -4918.74)
        elseif map:FindFirstChild("HooksMeat") then
            finishPart = map:FindFirstChild("HooksMeat")
            if finishPart:IsA("Model") then finishPart = finishPart.PrimaryPart or finishPart:FindFirstChildWhichIsA("BasePart") end
            exitPos = finishPart and finishPart.Position or Vector3.new(1546.12, 152.21, -796.72)
        end
    end

    if not exitPos then return end

    -- 3. Execution Loop (10 ครั้ง)
    task.spawn(function()
        for i = 1, 10 do
            if not root or not root.Parent or GetRole() ~= "Survivor" then break end

            -- Fire Remote
            pcall(function()
                local event = ReplicatedStorage:FindFirstChild("Remotes") and 
                              ReplicatedStorage.Remotes:FindFirstChild("Game") and 
                              ReplicatedStorage.Remotes.Game:FindFirstChild("PlayerActionEvent")
                if event then
                    event:FireServer("ESCAPED", 200)
                end
            end)

            -- Touch Interest
            if firetouchinterest and finishPart then
                firetouchinterest(root, finishPart, 0)
                task.wait()
                firetouchinterest(root, finishPart, 1)
            end

            -- Teleport
            if i == 1 then
                root.Velocity = Vector3.zero
                root.CFrame = CFrame.new(exitPos + Vector3.new(0, 3, 0))
            end

            task.wait(0.2)
        end
    end)
end

-- // UI Toggle (ลบ Notify ออกแล้ว)
Tabs.Automatic:AddToggle("BeatSurvivor", {
    Title = "Auto Escape",
    Description = "",
    Default = false,
    Callback = function(Value)
        _G.AutoEscapeEnabled = Value
    end
})

-- // Main Loop
task.spawn(function()
    while true do
        if _G.AutoEscapeEnabled and GetRole() == "Survivor" then
            KYS_BeatGameSurvivor()
            task.wait(5)
        end
        task.wait(1)
    end
end)

-- Ability
local Options = Fluent.Options

getgenv().InfHiddenEnabled = false

local leapFunc, m2Func = nil, nil

task.spawn(function()
    while true do
        if getgenv().InfHiddenEnabled then

            if not leapFunc or not m2Func then
                for _, v in pairs(getgc(true)) do
                    if type(v) == "function" and islclosure(v) then
                        local info = debug.getinfo(v)

                        if info.name == "tryActivate" then
                            leapFunc = v
                        end

                        if info.name == "playM2Animation" then
                            m2Func = v
                        end
                    end
                end
            end

            pcall(function()

                if leapFunc then
                    for i, val in pairs(debug.getupvalues(leapFunc)) do
                        if type(val) == "boolean" and val == true then
                            debug.setupvalue(leapFunc, i, false)
                        end
                    end
                end

                if m2Func then
                    for i, val in pairs(debug.getupvalues(m2Func)) do
                        if type(val) == "boolean" and val == true then
                            debug.setupvalue(m2Func, i, false)
                        end
                    end
                end

            end)
        end

        task.wait(0.1)
    end
end)


-- // [Logic] Grab System

local function GetClosestSurvivor()

    local target
    local dist = math.huge

    local myChar = LP.Character

    if not myChar
        or not myChar:FindFirstChild("HumanoidRootPart")
    then
        return nil
    end

    for _, v in ipairs(Players:GetPlayers()) do

        if v ~= LP
            and v.Character
            and v.Character:FindFirstChild("HumanoidRootPart")
        then

            if v.Team and v.Team.Name == "Survivors" then

                local d = (
                    myChar.HumanoidRootPart.Position
                    - v.Character.HumanoidRootPart.Position
                ).Magnitude

                if d < dist then
                    dist = d
                    target = v.Character
                end

            end
        end

    end

    return target
end


local function DoGrab()

    local target = GetClosestSurvivor()

    if target then
        ReplicatedStorage.Remotes.Killers.Stalker.grab:FireServer(target)
    end

end

-- // Mobile Grab Button
local MobileGrabGui = nil

-- ค่าเริ่มต้น: ปุ่มสามารถลากได้
local GrabButtonLocked = false

local function CreateGrabButton(state)
    if state then
        -- ลบ GUI เก่าก่อนสร้างใหม่
        if MobileGrabGui then
            MobileGrabGui:Destroy()
            MobileGrabGui = nil
        end


        -- // ScreenGui
        local sg = Instance.new(
            "ScreenGui",
            gethui and gethui() or CoreGui
        )

        sg.Name = "GrabButtonUI"

        -- // Grab Button
        local btn = Instance.new("TextButton", sg)
        btn.Name = "GrabBtn"
        btn.Size = UDim2.new(0, 70, 0, 70)
        btn.Position = UDim2.new(0.85, 0, 0.5, 0)
        btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        btn.BackgroundTransparency = 0.2
        btn.Text = "GRAB"
        btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14


        -- // Button Style
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(1, 0)


        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1.5
        stroke.Transparency = 0.5


        -- // Drag Variables
        local dragging = false
        local dragStart
        local startPos


        -- // Start Drag
        btn.InputBegan:Connect(function(input)
            -- ถ้าล็อคอยู่ จะไม่เริ่มลาก
            if GrabButtonLocked then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                dragging = true
                dragStart = input.Position
                startPos = btn.Position
            end
        end)


        -- // Drag Movement
        UIS.InputChanged:Connect(function(input)

            -- ถ้าล็อคอยู่ ให้หยุดการลาก
            if GrabButtonLocked then
                dragging = false
                return
            end

            if dragging
                and (
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                )
            then
             local delta = input.Position - dragStart
                btn.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)


        -- // End Drag
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                dragging = false
            end
        end)


        -- // Grab Action
        btn.MouseButton1Click:Connect(function()
            DoGrab()
        end)

        MobileGrabGui = sg
    else
        if MobileGrabGui then
            MobileGrabGui:Destroy()
            MobileGrabGui = nil
        end

    end

end



-- // Infinite Skill
Tabs.Ability:AddToggle("Ability", {
    Title = "Infinite Skill (Hidden)",
    Default = false,
    Callback = function(Value)
        getgenv().InfHiddenEnabled = Value
        if Value then
            leapFunc = nil
            m2Func = nil
        end
    end
})

-- // Myers NO CD
Tabs.Ability:AddToggle("Myers", {
    Title = "Myers NO CD (Stalker)",
    Default = false,
    Callback = function(Value)
        CreateGrabButton(Value)
    end
})

-- // Grab Button Lock
Tabs.Ability:AddToggle("GrabButtonLock", {
    Title = "Lock Grab Button",
    Default = false,
    Callback = function(Value)
    GrabButtonLocked = Value
    end
})
















        
--player
local State = {
    NC = false 
    
}


local WSState = false
local WSValue = 16  
local DefaultWS = 16
local initialized = false

local function HookChar(char)
    local hum = char:WaitForChild("Humanoid")
    
    -- บันทึกค่าความเร็วปกติของเกมไว้แค่ครั้งเดียวตอนรันสคริปต์
    if not initialized then
        DefaultWS = hum.WalkSpeed
        initialized = true
    end
end

if LP.Character then HookChar(LP.Character) end
LP.CharacterAdded:Connect(HookChar)

RunService.RenderStepped:Connect(function()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- ทำงานเฉพาะตอนเปิด Toggle เท่านั้น
    if WSState then
        hum.WalkSpeed = WSValue
    end
end)

-- walkspeed limit
Tabs.Player:AddInput("WSV", {
    Title = "Speed Value (Limit 40)",
    Default = "16",
    Callback = function(v)
        WSValue = math.clamp(tonumber(v) or 16, 1, 40)
    end
})

-- ปุ่มเปิด/ปิด
Tabs.Player:AddToggle("WS", {
    Title = "WalkSpeed",
    Default = false,
    Callback = function(v) 
        WSState = v 
        
        -- ถ้ากดปิด ให้คืนค่าความเร็วกลับเป็นค่าเริ่มต้นทันที
        if not v then 
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then 
                hum.WalkSpeed = DefaultWS 
            end 
        end
    end
})


local NoclipConnection
local function SetNoclip(state)
    if state then
        -- เริ่มทำงานเมื่อเปิด Toggle
        NoclipConnection = RunService.Stepped:Connect(function()
            if LP.Character then
                for _, v in pairs(LP.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        -- หยุดทำงานและคืนค่าฟิสิกส์เมื่อปิด Toggle
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        -- ตัวละครจะกลับมามี Colllide ปกติเมื่อมีการขยับหรือ Respawn
    end
end

Tabs.Player:AddToggle("NC", {
    Title = "Noclip",
    Default = false,
    Callback = function(Value)
        SetNoclip(Value)
    end
})

-- Swift Vault
-- // Configuration
local Config = {
    Vault = 25,
    Enabled = false
}

getgenv().FastVault = {
    Enabled = Config.Enabled,
    Speed = Config.Vault
}

local Vault = Tabs.Player:AddSection("Vault")
Tabs.Player:AddToggle("Vault", {
    Title = "Swift Vault",
    Default = Config.Enabled,

    Callback = function(Value)
        Config.Enabled = Value
        getgenv().FastVault.Enabled = Value

        if not Value then
            local char = game.Players.LocalPlayer.Character
            if char then
                char:SetAttribute("vaultspeed", 1)
            end
        end
    end
})

-- // Vault Speed
Tabs.Player:AddSlider("VaultSpeed", {
    Title = "Vault Speed",
    Default = Config.Vault,
    Min = 10,
    Max = 40,
    Rounding = 0,
    Callback = function(Value)
        Config.Vault = Value
        getgenv().FastVault.Speed = Value
    end
})

-- // Apply Vault Speed
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then
        return
    end

    pcall(function()
        local char = LocalPlayer.Character

        if char then
            char:SetAttribute(
                "vaultspeed",
                Config.Vault / 10
            )
        end
    end)
end)


-- Invisible API





--esp
local ESP_Config = {
    EnabledRoles = {}, 
    ShowBox = false,
    ShowHighlight = false,
    ShowTracer = false,
    Roles = {
        ["Survivors"] = Color3.fromRGB(0, 255, 0),
        ["Killer"] = Color3.fromRGB(255, 0, 0),
        ["Spectator"] = Color3.fromRGB(255, 255, 255)
    }
}


local RoleDropdown = Tabs.ESP:AddDropdown("ESPRoles", {
    Title = "Select Type",
    Values = {"Survivors", "Killer", "Spectator"},
    Multi = true,
    Default = {},
})

RoleDropdown:OnChanged(function(Value)
    ESP_Config.EnabledRoles = Value
end)

Tabs.ESP:AddToggle("HighlightToggle", {Title = "ESP Highlight", Default = false}):OnChanged(function(v)
    ESP_Config.ShowHighlight = v
end)

Tabs.ESP:AddToggle("BoxToggle", {Title = "ESP Box 3D", Default = false}):OnChanged(function(v)
    ESP_Config.ShowBox = v
end)

Tabs.ESP:AddToggle("TracerToggle", {Title = "ESP Line", Default = false}):OnChanged(function(v)
    ESP_Config.ShowTracer = v
end)

-- =========================
-- 🔥 Optimized Player ESP (Highlight, Box, Line)
-- =========================

local function GetRole(player)
    local team = player.Team and player.Team.Name or "None"
    local teamLower = team:lower()
    if string.find(teamLower, "killer") or string.find(teamLower, "murder") or string.find(teamLower, "beast") then return "Killer"
    elseif string.find(teamLower, "survivor") or string.find(teamLower, "innocent") or string.find(teamLower, "human") then return "Survivors" end
    return "Spectator"
end

local function CreateDrawingESP(player)
    if player == LocalPlayer then return end

    local ESP_Objects = {
        Lines = {},
        Tracer = nil
    }

    local function RemoveDrawing()
        for _, l in pairs(ESP_Objects.Lines) do pcall(function() l:Remove() end) end
        if ESP_Objects.Tracer then pcall(function() ESP_Objects.Tracer:Remove() end) end
        ESP_Objects.Lines = {}
        ESP_Objects.Tracer = nil
    end

    local function RefreshDrawing()
        if #ESP_Objects.Lines < 12 then
            for i = 1, 12 do
                local l = Drawing.new("Line")
                l.Thickness = 1.5
                l.Transparency = 1
                l.Visible = false
                table.insert(ESP_Objects.Lines, l)
            end
        end
        if not ESP_Objects.Tracer then
            local t = Drawing.new("Line")
            t.Thickness = 1.5
            t.Transparency = 1
            t.Visible = false
            ESP_Objects.Tracer = t
        end
    end

    local function ApplyESP(character)
        task.spawn(function()
            local hrp = character:WaitForChild("HumanoidRootPart", 10)
            local hum = character:WaitForChild("Humanoid", 10)
            if not hrp or not hum then return end

            RefreshDrawing()
            
            -- ฟังก์ชันจัดการ Highlight แบบเสถียร
            local function GetHighlight()
                local hl = character:FindFirstChild("R_Highlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "R_Highlight"
                    hl.Parent = character
                end
                return hl
            end

            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not player or not player.Parent or not character or not character.Parent or not hrp.Parent then
                    RemoveDrawing()
                    local oldHl = character:FindFirstChild("R_Highlight")
                    if oldHl then oldHl:Destroy() end
                    connection:Disconnect()
                    return
                end

                local role = GetRole(player)
                local isRoleEnabled = ESP_Config.EnabledRoles[role]
                local roleColor = ESP_Config.Roles[role] or Color3.fromRGB(255, 255, 255)
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                -- 1. 🔥 ESP Highlight (ตัด onScreen ออกเพื่อให้ทะลุกำแพงได้เสถียร)
                local highlight = GetHighlight()
                if hum.Health > 0 and isRoleEnabled and ESP_Config.ShowHighlight then
                    highlight.Enabled = true
                    highlight.FillColor = roleColor
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.6
                    highlight.OutlineTransparency = 0
                else
                    highlight.Enabled = false
                end

                -- 2. 🔥 ESP Box 3D (ต้องใช้ onScreen กันเส้นพุ่งมั่ว)
                if onScreen and hum.Health > 0 and isRoleEnabled and ESP_Config.ShowBox then
                    RefreshDrawing()
                    local size = Vector3.new(2, 3, 2)
                    local cf = hrp.CFrame
                    local vertices = {
                        Camera:WorldToViewportPoint((cf * CFrame.new(-size.X, size.Y, -size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(size.X, size.Y, -size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(size.X, size.Y, size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(-size.X, size.Y, size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(-size.X, -size.Y, -size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(size.X, -size.Y, -size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(size.X, -size.Y, size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(-size.X, -size.Y, size.Z)).Position)
                    }
                    local conns = {{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
                    for i, conn in ipairs(conns) do
                        local l = ESP_Objects.Lines[i]
                        if l then
                            l.Visible = true
                            l.From = Vector2.new(vertices[conn[1]].X, vertices[conn[1]].Y)
                            l.To = Vector2.new(vertices[conn[2]].X, vertices[conn[2]].Y)
                            l.Color = roleColor
                        end
                    end
                else
                    for _, l in pairs(ESP_Objects.Lines) do l.Visible = false end
                end

                -- 3. 🔥 ESP Tracer (Line)
                if onScreen and hum.Health > 0 and isRoleEnabled and ESP_Config.ShowTracer then
                    RefreshDrawing()
                    if ESP_Objects.Tracer then
                        ESP_Objects.Tracer.Visible = true
                        ESP_Objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        ESP_Objects.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        ESP_Objects.Tracer.Color = roleColor
                    end
                else
                    if ESP_Objects.Tracer then ESP_Objects.Tracer.Visible = false end
                end
            end)
        end)
    end

    player.CharacterAdded:Connect(ApplyESP)
    if player.Character then ApplyESP(player.Character) end
end


-- ลบส่วน player.Removing ออก แล้วเปลี่ยนมาใช้ PlayerRemoving ของ Players แทน
Players.PlayerRemoving:Connect(function(player)
    -- ระบบจะจัดการผ่าน connection:Disconnect() ในลูป RenderStepped อยู่แล้ว
end)

task.spawn(function()
    for _, p in ipairs(Players:GetPlayers()) do CreateDrawingESP(p) end
    Players.PlayerAdded:Connect(CreateDrawingESP)
end)







-- esp all
local MaxDistance = 3500

_G.NameESPEnabled = false
_G.HealthESPEnabled = false
_G.DistanceESPEnabled = false -- เพิ่มบรรทัดนี้


--========================
-- CACHE
--========================
local ESPCache = {}

--========================
-- CREATE ESP
--========================
--========================
-- CREATE ESP (Billboard Version)
--========================
local function CreateESP(Player)
    if Player == LocalPlayer then return end

    -- สร้าง Billboard สำหรับชื่อและระยะทาง (คมชัดกว่า)
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ReaperTag"
    Billboard.AlwaysOnTop = true
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.ExtentsOffset = Vector3.new(0, 3, 0)
    Billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local NameLabel = Instance.new("TextLabel", Billboard)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Size = UDim2.new(1, 0, 1, 0)
    NameLabel.Text = ""
    NameLabel.Font = Enum.Font.RobotoMono -- ฟอนต์ RobotoMono ตามสั่ง
    NameLabel.TextSize = 14
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextStrokeTransparency = 0
    NameLabel.RichText = true

    -- ระบบแถบเลือด Drawing (คงไว้ตามเดิม)
    local HealthOutline = Drawing.new("Square")
    HealthOutline.Visible = false
    HealthOutline.Filled = true
    HealthOutline.Thickness = 0
    HealthOutline.Color = Color3.fromRGB(0,0,0)
    HealthOutline.Transparency = 0.6

    local HealthBar = Drawing.new("Square")
    HealthBar.Visible = false
    HealthBar.Filled = true
    HealthBar.Thickness = 0
    HealthBar.Color = Color3.fromRGB(0,255,100)
    HealthBar.Transparency = 1

    ESPCache[Player] = {
        Billboard = Billboard,
        NameLabel = NameLabel,
        HealthOutline = HealthOutline,
        HealthBar = HealthBar
    }
end

local function RemoveESP(Player)
    local ESP = ESPCache[Player]
    if ESP then
        if ESP.Billboard then ESP.Billboard:Destroy() end
        if ESP.HealthOutline then ESP.HealthOutline:Remove() end
        if ESP.HealthBar then ESP.HealthBar:Remove() end
        ESPCache[Player] = nil
    end
end

local function HideESP(ESP)
    if ESP.Billboard then ESP.Billboard.Enabled = false end
    ESP.HealthOutline.Visible = false
    ESP.HealthBar.Visible = false
end



--========================
-- PLAYER HANDLING
--========================
for _,Player in ipairs(Players:GetPlayers()) do
    CreateESP(Player)
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

--========================
-- MAIN RENDER
--========================
RunService.RenderStepped:Connect(function()

    for Player,ESP in pairs(ESPCache) do

        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        local Head = Character and Character:FindFirstChild("Head")

        --========================
        -- VALIDATION
        --========================
        if not Character
        or not Humanoid
        or not Root
        or not Head
        or Humanoid.Health <= 0 then

            HideESP(ESP)
            continue
        end

        --========================
        -- DISTANCE
        --========================
        local Distance = (Camera.CFrame.Position - Root.Position).Magnitude

        if Distance > MaxDistance then
            HideESP(ESP)
            continue
        end

        --========================
        -- VIEWPORT
        --========================
        local RootPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)

        if not OnScreen then
            HideESP(ESP)
            continue
        end

        local HeadPos = Camera:WorldToViewportPoint(
            Head.Position + Vector3.new(0,0.6,0)
        )

        local LegPos = Camera:WorldToViewportPoint(
            Root.Position - Vector3.new(0,3,0)
        )

        --========================
        -- SCALE
        --========================
        local Height = math.abs(HeadPos.Y - LegPos.Y)
        local Width = Height / 2

        local X = RootPos.X - Width / 2
        local Y = RootPos.Y - Height / 2

                --========================
        -- NAME & DISTANCE ESP
        --========================
                --========================
        -- NAME & DISTANCE ESP (Format: NAME [ Distance ])
        --========================
        if _G.NameESPEnabled or _G.DistanceESPEnabled then
            ESP.Billboard.Enabled = true
            ESP.Billboard.Parent = Head
            
            local NameTag = _G.NameESPEnabled and Player.Name or "" -- ใช้ Username
            local DistTag = _G.DistanceESPEnabled and string.format(" <font color='#AAAAAA'>[ %dm ]</font>", math.floor(Distance)) or ""
            
            -- รวมข้อความ NAME [ Distance ]
            if _G.NameESPEnabled and _G.DistanceESPEnabled then
                ESP.NameLabel.Text = NameTag .. " " .. DistTag
            else
                ESP.NameLabel.Text = NameTag .. DistTag
            end
            
            -- ปรับขนาดตามระยะทาง
            ESP.NameLabel.TextSize = math.clamp(16 - (Distance / 150), 12, 16)
        else
            if ESP.Billboard then ESP.Billboard.Enabled = false end
        end




        --========================
        -- HEALTH BAR
        --========================
        if _G.HealthESPEnabled then

            local HealthPercent = math.clamp(
                Humanoid.Health / Humanoid.MaxHealth,
                0,
                1
            )

            local BarHeight = Height * HealthPercent

            local BarX = X - 7
            local BarY = Y

            -- OUTLINE
            ESP.HealthOutline.Visible = true
            ESP.HealthOutline.Size = Vector2.new(
                4,
                Height + 2
            )

            ESP.HealthOutline.Position = Vector2.new(
                BarX - 1,
                BarY - 1
            )

            -- BAR
            ESP.HealthBar.Visible = true
            ESP.HealthBar.Size = Vector2.new(
                2,
                BarHeight
            )

            ESP.HealthBar.Position = Vector2.new(
                BarX,
                BarY + (Height - BarHeight)
            )

            -- HEALTH COLOR
            ESP.HealthBar.Color = Color3.fromRGB(
                255 - (255 * HealthPercent),
                255 * HealthPercent,
                0
            )

        else

            ESP.HealthOutline.Visible = false
            ESP.HealthBar.Visible = false
        end
    end
end)

--========================
-- TOGGLES
--========================
Tabs.ESP:AddToggle("NameESP", {
    Title = "ESP Name",
    Default = false,
    Callback = function(v)
        _G.NameESPEnabled = v
    end
})

Tabs.ESP:AddToggle("HealthESP", {
    Title = "ESP Health",
    Default = false,
    Callback = function(v)
        _G.HealthESPEnabled = v
    end
})

Tabs.ESP:AddToggle("DistanceESP", {
    Title = "ESP Distance",
    Default = false,
    Callback = function(v)
        _G.DistanceESPEnabled = v
    end
})






-- Object
--=========================
-- 🔥 Optimized & Fixed Object ESP
--=========================
local Object_Config = {
    Generator = false,
    Hook = false,
    Gate = false,
  	Pallet = false
}

local Object_Highlights = {}

local OBJ_COLORS = {
    Generator = Color3.fromRGB(255, 255, 0),
    Hook = Color3.fromRGB(170, 0, 255),
    Gate = Color3.fromRGB(0, 170, 255),
    Pallet = Color3.fromRGB(255, 150, 0)
}

local OBJ_MAPPING = {
    ["generator"] = "Generator", ["generators"] = "Generator", 
    ["new generator"] = "Generator", ["new generators"] = "Generator",
    ["hook"] = "Hook", ["hooks"] = "Hook",
    ["gate"] = "Gate", ["gates"] = "Gate",
    ["palletwrong"] = "Pallet",
    ["palletpoint"] = "Pallet"
}


-- ฟังก์ชันจัดการลบ Highlight ให้สิ้นซาก
local function ClearESP(obj)
    if Object_Highlights[obj] then
        pcall(function()
            Object_Highlights[obj]:Destroy()
        end)
        Object_Highlights[obj] = nil
    end
end

-- ฟังก์ชันจัดการ Highlight รายชิ้น
local function ManageESP(obj)
    local typeName = OBJ_MAPPING[string.lower(obj.Name)]
    if not typeName then return end

    local isEnabled = Object_Config[typeName]

    -- [เพิ่มเฉพาะส่วน Generator] 
    if isEnabled and typeName == "Generator" then
        local progress = obj:GetAttribute("RepairProgress") or obj:GetAttribute("ProgressRepair") or 0
        if progress >= 100 then
            ClearESP(obj)
            return -- ถ้าเครื่องเสร็จแล้วให้หยุดทำงานตรงนี้เลย
        end

        -- ดักจับสัญญาณเผื่อซ่อมเสร็จทีหลัง (Real-time)
        if not obj:GetAttribute("Reaper_Hooked") then
            obj:SetAttribute("Reaper_Hooked", true)
            obj:GetAttributeChangedSignal("RepairProgress"):Connect(function() ManageESP(obj) end)
            obj:GetAttributeChangedSignal("ProgressRepair"):Connect(function() ManageESP(obj) end)
        end
    end
    -- [จบส่วนที่เพิ่ม]

    if isEnabled then
        -- Logic เดิมของคุณ 100% (Hook, Gate, Pallet ทำงานผ่านส่วนนี้)
        if not Object_Highlights[obj] or not Object_Highlights[obj].Parent then
            local highlight = Instance.new("Highlight")
            highlight.Name = "Reaper_ObjESP"
            highlight.Adornee = obj
            highlight.FillColor = OBJ_COLORS[typeName]
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = obj
            Object_Highlights[obj] = highlight
        end
        Object_Highlights[obj].Enabled = true
    else
        ClearESP(obj)
    end
end


-- ฟังก์ชันสแกน
local function RefreshType(typeName)
    for _, obj in ipairs(workspace:GetDescendants()) do
        local nameLower = obj.Name:lower()
        if OBJ_MAPPING[nameLower] == typeName then
            ManageESP(obj)
        end
    end
end


--=========================
-- 🔥 UI Setup (Object Tab)
--=========================
Tabs.Object:AddToggle("GenESP", {
    Title = "ESP Generator",
    Default = false,
    Callback = function(v)
        Object_Config.Generator = v
        if v then 
            RefreshType("Generator") 
        else
            -- ลบเฉพาะ Highlight ของ Generator เมื่อปิด (ส่วนเดิมของคุณ)
            for obj, _ in pairs(Object_Highlights) do
                if OBJ_MAPPING[obj.Name:lower()] == "Generator" then ClearESP(obj) end
            end
        end
    end
})


Tabs.Object:AddToggle("HookESP", {
    Title = "ESP Hook",
    Default = false,
    Callback = function(v)
        Object_Config.Hook = v
        if v then RefreshType("Hook") else
            for obj, _ in pairs(Object_Highlights) do
                if OBJ_MAPPING[obj.Name:lower()] == "Hook" then ClearESP(obj) end
            end
        end
    end
})

Tabs.Object:AddToggle("GateESP", {
    Title = "ESP Gate",
    Default = false,
    Callback = function(v)
        Object_Config.Gate = v
        if v then RefreshType("Gate") else
            for obj, _ in pairs(Object_Highlights) do
                if OBJ_MAPPING[obj.Name:lower()] == "Gate" then ClearESP(obj) end
            end
        end
    end
})


Tabs.Object:AddToggle("PalletESP", {
    Title = "ESP Pallet",
    Default = false,
    Callback = function(v)
        Object_Config.Pallet = v
        if v then 
            RefreshType("Pallet") 
        else
            -- ล้างเฉพาะ Pallet โดยเช็คผ่าน Mapping
            for obj, _ in pairs(Object_Highlights) do
                if OBJ_MAPPING[obj.Name:lower()] == "Pallet" then 
                    ClearESP(obj) 
                end
            end
        end
    end
})


--=========================
-- 🔥 Event Listeners
--=========================
workspace.DescendantAdded:Connect(function(obj)
    -- เพิ่ม Delay เล็กน้อย เผื่อ Object สปอว์นแล้วยังไม่ได้ Set Name
    task.wait(0.2) 
    if OBJ_MAPPING[string.lower(obj.Name)] then
        ManageESP(obj)
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    ClearESP(obj)
end)




--teleport
local selectedPlayer = nil
local teleportEnabled = false

local function getList()
    local list = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(list, p.Name)
        end
    end

    return list
end

local Dropdown = Tabs.Teleport:AddDropdown("PlayerDropdown", {
    Title = "Select Player",
    Values = getList(),
    Multi = false,
    Default = nil
})

Dropdown:OnChanged(function(value)
    if value then
        selectedPlayer = Players:FindFirstChild(value)
    end
end)

Tabs.Teleport:AddButton({
    Title = "Refresh Players",
    Callback = function()
        Dropdown:SetValues(getList())
    end
})

Tabs.Teleport:AddToggle("tp", {
    Title = "Teleport",
    Default = false,
    Callback = function(state)
        teleportEnabled = state

        if state then
            task.spawn(function()
                while teleportEnabled do
                    if selectedPlayer and selectedPlayer.Character then
                        local char = LP.Character
                        local target = selectedPlayer.Character

                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        local tRoot = target and target:FindFirstChild("HumanoidRootPart")

                        if root and tRoot then
                            TweenService:Create(
                                root,
                                TweenInfo.new(0.4, Enum.EasingStyle.Linear),
                                {
                                    CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
                                }
                            ):Play()
                        end
                    end

                    task.wait(0.5)
                end
            end)
        end
    end
})

-- Teleport to Object or something
local ObjectSection = Tabs.Teleport:AddSection("TP Object")
--// 1. Variables & Mapping
local OBJ_MAPPING = {
    ["generator"] = "Generator", ["generators"] = "Generator", 
    ["new generator"] = "Generator", ["new generators"] = "Generator",
    ["hook"] = "Hook", ["hooks"] = "Hook",
    ["gate"] = "Gate", ["gates"] = "Gate",
    ["palletwrong"] = "Pallet", ["palletpoint"] = "Pallet"
}

--// 2. Core Helper Functions
local function GetHRP(model)
    return model and model:FindFirstChild("HumanoidRootPart")
end

local function GetRole(p)
    local team = p.Team and p.Team.Name or "None"
    local tl = team:lower()
    if tl:find("killer") or tl:find("murder") or tl:find("beast") then return "Killer" end
    if tl:find("survivor") or tl:find("innocent") or tl:find("human") then return "Survivors" end
    return "Spectator"
end

local function TeleportTo(pos)
    local char = lp.Character
    if char and GetHRP(char) and pos then
        char:PivotTo(pos)
    end
end

--// 3. Optimized Logic: ค้นหาวัตถุที่ใกล้ที่สุด (เพิ่มระบบกรองป้องกันวาร์ปไปหาคน)
local function GetNearestObject(targetType)
    local nearest = nil
    local minDist = math.huge
    local hrp = GetHRP(lp.Character)
    if not hrp then return nil end
    local myPos = hrp.Position

    for _, v in ipairs(workspace:GetDescendants()) do
        local name = v.Name:lower()
        local mappedName = OBJ_MAPPING[name]
        
        if mappedName == targetType then
            --// [จุดแก้ไข] ตรวจสอบว่าไม่ใช่ส่วนประกอบของตัวละครผู้เล่น หรือ Tool
            local model = v:FindFirstAncestorOfClass("Model")
            if model and game.Players:GetPlayerFromCharacter(model) then 
                continue 
            end
            if v:FindFirstAncestorOfClass("Tool") or v:IsA("Tool") then
                continue
            end

            -- Logic: สำหรับ Generator (ข้ามตัวที่ซ่อมเสร็จแล้ว)
            if targetType == "Generator" then
                local progress = v:GetAttribute("RepairProgress") or v:GetAttribute("ProgressRepair") or 0
                if progress >= 100 then continue end
            end

            -- Logic: สำหรับ Gate (กรอง Barrier และเช็คขนาดเพื่อให้เจอประตูจริงๆ)
            if targetType == "Gate" then
                if v:IsA("BasePart") then
                    if v.Transparency > 0.8 or not v.CanCollide then continue end -- ข้าม Barrier ล่องหน
                    if v.Size.Magnitude < 5 then continue end -- ข้าม Part เล็กๆ ที่ไม่ใช่ประตู
                end
            end
            
            local success, targetCFrame = pcall(function() return v:GetPivot() end)
            if success and targetCFrame then
                local dist = (myPos - targetCFrame.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = targetCFrame
                end
            end
        end
    end
    return nearest
end

--// 4. Teleport Buttons (ครบทุกฟังก์ชั่นเดิม)
Tabs.Teleport:AddButton({
    Title = "Teleport to Generator",
    Callback = function()
        if GetRole(lp) == "Spectator" then return end
        local target = GetNearestObject("Generator")
        if target then 
            TeleportTo(target * CFrame.new(0, 3, 0)) 
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Gate",
    Callback = function()
        if GetRole(lp) == "Spectator" then return end
        local target = GetNearestObject("Gate")
        if target then 
            TeleportTo(target * CFrame.new(0, 3, 0)) 
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Pallet",
    Callback = function()
        if GetRole(lp) == "Spectator" then return end
        local target = GetNearestObject("Pallet")
        if target then 
            TeleportTo(target * CFrame.new(0, 3, 0)) 
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Hook",
    Callback = function()
        if GetRole(lp) == "Spectator" then return end
        local target = GetNearestObject("Hook")
        if target then 
            TeleportTo(target * CFrame.new(0, 3, 0)) 
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Killer",
    Callback = function()
        if GetRole(lp) == "Spectator" then return end
        for _, v in ipairs(game.Players:GetPlayers()) do
            if v ~= lp and GetRole(v) == "Killer" then
                local targetHRP = GetHRP(v.Character)
                if targetHRP then
                    TeleportTo(targetHRP.CFrame * CFrame.new(0, 0, 3))
                    break
                end
            end
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Low Health Player",
    Callback = function()
        if GetRole(lp) == "Spectator" then return end
        for _, v in ipairs(game.Players:GetPlayers()) do
            if v ~= lp and v.UserId ~= lp.UserId and v.Character and v.Character:FindFirstChild("Humanoid") then
                local hum = v.Character.Humanoid
                if hum.Health > 0 and hum.Health < (hum.MaxHealth * 0.9) then
                    local targetHRP = GetHRP(v.Character)
                    if targetHRP then
                        TeleportTo(targetHRP.CFrame * CFrame.new(0, 0, 3))
                        break
                    end
                end
            end
        end
    end
})



-- Misc
-- // [BACKUP ORIGINAL] เก็บค่าดั้งเดิมไว้ตาม Codex
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- // [PRESETS] ดึงมาจากตาราง KYS_WeatherPresets ใน Codex เป๊ะๆ
local WeatherPresets = {
    ["Default"] = {},
    ["Christmas (Snow)"] = {
        Lighting = { FogColor = Color3.fromRGB(150, 180, 220), FogEnd = 200, ClockTime = 8, OutdoorAmbient = Color3.fromRGB(100, 120, 150) },
        Atmosphere = { Density = 0.5, Color = Color3.fromRGB(180, 200, 220), Decay = Color3.fromRGB(150, 180, 220), Haze = 5, Glare = 0 },
        Particle = { Texture = "rbxasset://textures/particles/sparkles_main.dds", Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)), Size = NumberSequence.new(1.5), Rate = 150, Speed = NumberRange.new(15, 25), Lifetime = NumberRange.new(4, 6), EmissionDirection = Enum.NormalId.Bottom, RotSpeed = NumberRange.new(-45, 45) }
    },
    ["Heavy Rain (Storm)"] = {
        Lighting = { FogColor = Color3.fromRGB(50, 50, 60), FogEnd = 150, OutdoorAmbient = Color3.fromRGB(40, 40, 50), Brightness = 0.2, ClockTime = 12 },
        CC = { TintColor = Color3.fromRGB(150, 150, 180), Contrast = 0.2, Saturation = -0.5 },
        Particle = { Texture = "rbxasset://textures/particles/sparkles_main.dds", AnchorSize = Vector3.new(260, 1, 260), CameraOffset = Vector3.new(0, 38, -18), Squash = NumberSequence.new(16), Color = ColorSequence.new(Color3.fromRGB(235, 245, 255)), Size = NumberSequence.new(1.25), Rate = 2600, Speed = NumberRange.new(110, 145), Lifetime = NumberRange.new(0.85, 1.25), EmissionDirection = Enum.NormalId.Bottom, Transparency = NumberSequence.new(0), Acceleration = Vector3.new(-18, -75, 0), SpreadAngle = Vector2.new(3, 3), LightEmission = 1 }
    },
    ["Autumn (Musim Gugur)"] = {
        Lighting = { FogColor = Color3.fromRGB(200, 150, 80), FogEnd = 500, OutdoorAmbient = Color3.fromRGB(180, 140, 70), ClockTime = 16.5 },
        CC = { TintColor = Color3.fromRGB(255, 220, 180), Contrast = 0.1, Saturation = 0.2 },
        Particle = { Texture = "rbxasset://textures/particles/sparkles_main.dds", AnchorSize = Vector3.new(210, 1, 210), CameraOffset = Vector3.new(0, 28, -16), Squash = NumberSequence.new(3.2), Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 190, 45)), ColorSequenceKeypoint.new(0.45, Color3.fromRGB(235, 95, 20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(135, 45, 10)) }), Size = NumberSequence.new(2.05), Rate = 360, Speed = NumberRange.new(8, 15), Lifetime = NumberRange.new(6, 10), EmissionDirection = Enum.NormalId.Bottom, Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-220, 220), Transparency = NumberSequence.new(0), Acceleration = Vector3.new(18, -8, 6), SpreadAngle = Vector2.new(38, 38), LightEmission = 0.6 }
    },
    ["Cherry Blossom (Sakura)"] = {
        Lighting = { FogColor = Color3.fromRGB(255, 200, 220), FogEnd = 600, OutdoorAmbient = Color3.fromRGB(255, 180, 200), ClockTime = 9 },
        CC = { TintColor = Color3.fromRGB(255, 230, 240), Saturation = 0.3 },
        Particle = { Texture = "rbxasset://textures/particles/sparkles_main.dds", AnchorSize = Vector3.new(160, 1, 160), CameraOffset = Vector3.new(0, 25, -18), Squash = NumberSequence.new(1.2), Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 235)), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(255, 165, 205)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 180)) }), Size = NumberSequence.new(1.25), Rate = 190, Speed = NumberRange.new(5, 10), Lifetime = NumberRange.new(7, 10), EmissionDirection = Enum.NormalId.Bottom, Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-170, 170), Transparency = NumberSequence.new(0), Acceleration = Vector3.new(14, -5, 5), SpreadAngle = Vector2.new(32, 32), LightEmission = 0.55 }
    },
    ["Sunset (Golden Hour)"] = {
        Lighting = { FogColor = Color3.fromRGB(255, 120, 50), FogEnd = 1200, OutdoorAmbient = Color3.fromRGB(200, 100, 50), ClockTime = 17.5, Brightness = 1.5 },
        CC = { TintColor = Color3.fromRGB(255, 200, 150), Contrast = 0.2, Saturation = 0.4 }
    },
    ["Blood Moon (Spooky)"] = {
        Lighting = { FogColor = Color3.fromRGB(150, 10, 10), FogEnd = 500, OutdoorAmbient = Color3.fromRGB(80, 0, 0), ClockTime = 0, Brightness = 0.3 },
        CC = { TintColor = Color3.fromRGB(255, 50, 50), Contrast = 0.4, Saturation = 0.5 },
        Atmosphere = { Density = 0.35, Color = Color3.fromRGB(255, 0, 0), Decay = Color3.fromRGB(100, 0, 0), Haze = 5, Glare = 0 }
    },
    ["Toxic Wasteland"] = {
        Lighting = { FogColor = Color3.fromRGB(80, 150, 50), FogEnd = 250, OutdoorAmbient = Color3.fromRGB(50, 120, 40), ClockTime = 12, Brightness = 1 },
        CC = { TintColor = Color3.fromRGB(150, 255, 150), Contrast = 0.1, Saturation = 0.3 },
        Particle = { Texture = "rbxasset://textures/particles/sparkles_main.dds", Color = ColorSequence.new(Color3.fromRGB(100, 255, 50)), Size = NumberSequence.new(0.8), Rate = 200, Speed = NumberRange.new(50, 60), Lifetime = NumberRange.new(2, 3), EmissionDirection = Enum.NormalId.Bottom, Transparency = NumberSequence.new(0.5) }
    },
    ["Vaporwave (Synthwave)"] = {
        Lighting = { FogColor = Color3.fromRGB(200, 50, 255), FogEnd = 500, OutdoorAmbient = Color3.fromRGB(150, 0, 200), ClockTime = 20, Brightness = 1 },
        CC = { TintColor = Color3.fromRGB(255, 100, 255), Contrast = 0.3, Saturation = 0.5 }
    },
    ["Midnight (Pitch Black)"] = {
        Lighting = { FogColor = Color3.fromRGB(0, 0, 0), FogEnd = 100, OutdoorAmbient = Color3.fromRGB(0, 0, 0), Brightness = 0, ClockTime = 0 },
        CC = { TintColor = Color3.fromRGB(50, 50, 50), Contrast = 0.5, Saturation = -0.8 }
    }
}

-- // [CORE FUNCTION] VD_ApplyWeather (Exact Copy from Codex)
local function ApplyWeather(themeName)
    local theme = WeatherPresets[themeName] or WeatherPresets["Default"]
    
    -- Cleanup
    if getgenv().VD_WeatherCC then getgenv().VD_WeatherCC:Destroy() end
    if getgenv().VD_WeatherAtmosphere then getgenv().VD_WeatherAtmosphere:Destroy() end
    if getgenv().VD_ParticleAnchor then getgenv().VD_ParticleAnchor:Destroy() end
    
    -- Apply Atmosphere
    if theme.Atmosphere then
        local atm = Instance.new("Atmosphere", Lighting)
        atm.Name = "VD_WeatherAtmosphere"
        for k, v in pairs(theme.Atmosphere) do pcall(function() atm[k] = v end) end
        getgenv().VD_WeatherAtmosphere = atm
    end
    
    -- Apply ColorCorrection
    if theme.CC then
        local cc = Instance.new("ColorCorrectionEffect", Lighting)
        cc.Name = "VD_WeatherCC"
        for k, v in pairs(theme.CC) do pcall(function() cc[k] = v end) end
        getgenv().VD_WeatherCC = cc
    end
    
    -- Apply Lighting
    if theme.Lighting then
        for k, v in pairs(theme.Lighting) do pcall(function() Lighting[k] = v end) end
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end

    -- Setup Particles (เม็ดฝน/หิมะ/ใบไม้ แบบเต็มระบบ)
    if theme.Particle then
        local anchor = Instance.new("Part", workspace)
        anchor.Name = "VD_WeatherAnchor"; anchor.Transparency = 1; anchor.CanCollide = false; anchor.Anchored = true
        anchor.Size = theme.Particle.AnchorSize or Vector3.new(120, 1, 120)
        anchor:SetAttribute("VD_CameraOffsetX", theme.Particle.CameraOffset and theme.Particle.CameraOffset.X or 0)
        anchor:SetAttribute("VD_CameraOffsetY", theme.Particle.CameraOffset and theme.Particle.CameraOffset.Y or 30)
        anchor:SetAttribute("VD_CameraOffsetZ", theme.Particle.CameraOffset and theme.Particle.CameraOffset.Z or 0)
        
        local pe = Instance.new("ParticleEmitter", anchor)
        pe.Enabled = true; pe.EmissionDirection = Enum.NormalId.Bottom
        for k, v in pairs(theme.Particle) do
            if k ~= "AnchorSize" and k ~= "CameraOffset" then pcall(function() pe[k] = v end) end
        end

        -- พิเศษ: Heavy Rain มี 3 ชั้นตามต้นฉบับ
        if themeName == "Heavy Rain (Storm)" then
            local nearRain = pe:Clone(); nearRain.Rate = 1800; nearRain.Size = NumberSequence.new(1.65); nearRain.Squash = NumberSequence.new(20); nearRain.Parent = anchor
            local rainSheet = pe:Clone(); rainSheet.Texture = "rbxasset://textures/particles/smoke_main.dds"; rainSheet.Rate = 650; rainSheet.Size = NumberSequence.new(3.2); rainSheet.Transparency = NumberSequence.new(0.45); rainSheet.Parent = anchor
        end
        
        -- พิเศษ: Autumn มีใบไม้ใหญ่ตามต้นฉบับ
        if themeName == "Autumn (Musim Gugur)" then
            local bigLeaves = pe:Clone(); bigLeaves.Rate = 150; bigLeaves.Size = NumberSequence.new(3.1); bigLeaves.Squash = NumberSequence.new(4.5); bigLeaves.Parent = anchor
        end

        getgenv().VD_ParticleAnchor = anchor
    end
end

-- // [LOGIC] Remove Fog (ปุ่มแยกตามสั่ง)
local function UpdateFog()
    if _G.RemoveFogEnabled then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        if getgenv().VD_WeatherAtmosphere then getgenv().VD_WeatherAtmosphere.Density = 0 end
    else
        local theme = WeatherPresets[_G.CurrentWeather]
        Lighting.FogEnd = (theme and theme.Lighting and theme.Lighting.FogEnd) or originalLighting.FogEnd
    end
end

-- // UI Elements
Tabs.Misc:AddToggle("RemoveFog", {
    Title = "Remove Fog",
    Default = false,
    Callback = function(v) _G.RemoveFogEnabled = v UpdateFog() end
})

Tabs.Misc:AddDropdown("Weather", {
    Title = "Select Weather Theme",
    Values = {"Default", "Christmas (Snow)", "Heavy Rain (Storm)", "Autumn (Musim Gugur)", "Cherry Blossom (Sakura)", "Sunset (Golden Hour)", "Blood Moon (Spooky)", "Toxic Wasteland", "Vaporwave (Synthwave)", "Midnight (Pitch Black)"},
    Default = "Default",
    Callback = function(v) _G.CurrentWeather = v ApplyWeather(v) UpdateFog() end
})

-- // [LOOP] Particle Follow (Exact Camera Logic from Codex)
RunService.Heartbeat:Connect(function()
    local anchor = getgenv().VD_ParticleAnchor
    local camera = workspace.CurrentCamera
    if anchor and camera then
        local offset = Vector3.new(anchor:GetAttribute("VD_CameraOffsetX") or 0, anchor:GetAttribute("VD_CameraOffsetY") or 30, anchor:GetAttribute("VD_CameraOffsetZ") or 0)
        anchor.CFrame = CFrame.new(camera.CFrame.Position + camera.CFrame.RightVector * offset.X + Vector3.new(0, offset.Y, 0) + camera.CFrame.LookVector * math.abs(offset.Z))
    end
    if _G.RemoveFogEnabled then Lighting.FogEnd = 100000 end
end)

-- Hide Icon Survivals
getgenv().ReaperSurvivorLogoState = getgenv().ReaperSurvivorLogoState or {
    Connection = nil,
    AnimationConnection = nil,
    Originals = {},
}

getgenv().ReaperSurvivorLogoImage = "rbxassetid://131279093559313"
getgenv().ReaperSurvivorLogoText = "REAPER"
getgenv().ReaperSurvivorLogoTextSize = 11
getgenv().ReaperSurvivorLogoSpeed = 4.5

function ReaperGetSurvivorSlots()
    local slots = {}
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")

    if not playerGui then
        return slots
    end

    for _, gui in ipairs(playerGui:GetChildren()) do
        if not (gui:IsA("ScreenGui") and gui.Name:match("%-mob$")) then
            continue
        end

        local frame = gui:FindFirstChild("Frame")

        if frame then
            for i = 1, 5 do
                local survivorFrame = frame:FindFirstChild("Survivor" .. i)
                local imageLabel = survivorFrame and survivorFrame:FindFirstChild("ImageLabel")
                local textLabel = survivorFrame and survivorFrame:FindFirstChild("TextLabel")

                if (imageLabel and imageLabel:IsA("ImageLabel"))
                    or (textLabel and textLabel:IsA("TextLabel")) then
                    table.insert(slots, {
                        ImageLabel = imageLabel,
                        TextLabel = textLabel,
                    })
                end
            end
        end
    end

    return slots
end

function ReaperCreateTextGradient(textLabel)
    local gradient = textLabel:FindFirstChild("ReaperTextGradient")

    if not gradient then
        gradient = Instance.new("UIGradient")
        gradient.Name = "ReaperTextGradient"
        gradient.Rotation = 0
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.38, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.46, Color3.fromRGB(90, 0, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.54, Color3.fromRGB(90, 0, 0)),
            ColorSequenceKeypoint.new(0.62, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        })
        gradient.Offset = Vector2.new(1, 0)
        gradient.Parent = textLabel
    end

    return gradient
end

function ReaperApplySurvivorLogo()
    for _, slot in ipairs(ReaperGetSurvivorSlots()) do
        local imageLabel = slot.ImageLabel

        if imageLabel and imageLabel:IsA("ImageLabel") then
            if not getgenv().ReaperSurvivorLogoState.Originals[imageLabel] then
                getgenv().ReaperSurvivorLogoState.Originals[imageLabel] = {
                    Image = imageLabel.Image,
                    ImageColor3 = imageLabel.ImageColor3,
                    ImageTransparency = imageLabel.ImageTransparency,
                    ImageRectOffset = imageLabel.ImageRectOffset,
                    ImageRectSize = imageLabel.ImageRectSize,
                    ScaleType = imageLabel.ScaleType,
                }
            end

            imageLabel.Image = getgenv().ReaperSurvivorLogoImage
            imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
            imageLabel.ImageTransparency = 0
            imageLabel.ImageRectOffset = Vector2.new(0, 0)
            imageLabel.ImageRectSize = Vector2.new(0, 0)
            imageLabel.ScaleType = Enum.ScaleType.Crop
        end

        local textLabel = slot.TextLabel

        if textLabel and textLabel:IsA("TextLabel") then
            if not getgenv().ReaperSurvivorLogoState.Originals[textLabel] then
                getgenv().ReaperSurvivorLogoState.Originals[textLabel] = {
                    Text = textLabel.Text,
                    TextColor3 = textLabel.TextColor3,
                    TextTransparency = textLabel.TextTransparency,
                    TextSize = textLabel.TextSize,
                    TextScaled = textLabel.TextScaled,
                    TextStrokeColor3 = textLabel.TextStrokeColor3,
                    TextStrokeTransparency = textLabel.TextStrokeTransparency,
                }
            end

            textLabel.Text = getgenv().ReaperSurvivorLogoText
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextTransparency = 0
            textLabel.TextSize = getgenv().ReaperSurvivorLogoTextSize
            textLabel.TextScaled = false

            ReaperCreateTextGradient(textLabel)
        end
    end
end

function ReaperRestoreSurvivorLogo()
    for object, original in pairs(getgenv().ReaperSurvivorLogoState.Originals) do
        if object and object.Parent and original then
            pcall(function()
                if original.Image ~= nil and object:IsA("ImageLabel") then
                    object.Image = original.Image
                    object.ImageColor3 = original.ImageColor3
                    object.ImageTransparency = original.ImageTransparency
                    object.ImageRectOffset = original.ImageRectOffset
                    object.ImageRectSize = original.ImageRectSize
                    object.ScaleType = original.ScaleType
                end

                if original.Text ~= nil and object:IsA("TextLabel") then
                    object.Text = original.Text
                    object.TextColor3 = original.TextColor3
                    object.TextTransparency = original.TextTransparency
                    object.TextSize = original.TextSize
                    object.TextScaled = original.TextScaled
                    object.TextStrokeColor3 = original.TextStrokeColor3
                    object.TextStrokeTransparency = original.TextStrokeTransparency

                    local gradient = object:FindFirstChild("ReaperTextGradient")

                    if gradient then
                        gradient:Destroy()
                    end
                end
            end)
        end
    end

    getgenv().ReaperSurvivorLogoState.Originals = {}
end

function ReaperStopSurvivorLogo()
    if getgenv().ReaperSurvivorLogoState.Connection then
        pcall(function()
            getgenv().ReaperSurvivorLogoState.Connection:Disconnect()
        end)

        getgenv().ReaperSurvivorLogoState.Connection = nil
    end

    if getgenv().ReaperSurvivorLogoState.AnimationConnection then
        pcall(function()
            getgenv().ReaperSurvivorLogoState.AnimationConnection:Disconnect()
        end)

        getgenv().ReaperSurvivorLogoState.AnimationConnection = nil
    end

    ReaperRestoreSurvivorLogo()
end

function ReaperSetSurvivorLogo(enabled)
    if enabled then
        ReaperStopSurvivorLogo()
        ReaperApplySurvivorLogo()

        getgenv().ReaperSurvivorLogoState.Connection =
            RunService.Heartbeat:Connect(function()
                ReaperApplySurvivorLogo()
            end)

        getgenv().ReaperSurvivorLogoState.AnimationConnection =
            RunService.RenderStepped:Connect(function()
                local slots = ReaperGetSurvivorSlots()
                local cycle = getgenv().ReaperSurvivorLogoSpeed
                local progress = (os.clock() % cycle) / cycle
                local offset = 1 - (progress * 2.5)

                for _, slot in ipairs(slots) do
                    local textLabel = slot.TextLabel

                    if textLabel and textLabel:IsA("TextLabel") then
                        local gradient = textLabel:FindFirstChild("ReaperTextGradient")

                        if gradient then
                            gradient.Offset = Vector2.new(offset, 0)
                        end
                    end
                end
            end)
    else
        ReaperStopSurvivorLogo()
    end
end

getgenv().ReaperSetSurvivorLogo = ReaperSetSurvivorLogo

Tabs.Misc:AddSection("Hide Survivor Logo")

Tabs.Misc:AddToggle("ReaperSurvivorLogo", {
    Title = "Hide Survivor Logo",
    Default = false,
    Callback = function(value)
        ReaperSetSurvivorLogo(value)
    end
})


--// =========================
--// ANTI AFK
--// =========================

local AntiAFKThread = 0

local function SetAntiAFK(enabled)

    getgenv().REAPER_AntiAFK = enabled

    AntiAFKThread += 1
    local CurrentThread = AntiAFKThread

    if not enabled then
        return
    end

    task.spawn(function()

        while getgenv().REAPER_AntiAFK
            and AntiAFKThread == CurrentThread
        do

            task.wait(30)

            if not getgenv().REAPER_AntiAFK
                or AntiAFKThread ~= CurrentThread
            then
                break
            end

            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)

        end
    end)
end

Tabs.Misc:AddSection("AFK")

local AntiAFKToggle = Tabs.Misc:AddToggle("AntiAFK", {
    Title = "Anti AFK",
    Default = false
})

AntiAFKToggle:OnChanged(function(Value)
    SetAntiAFK(Value)
end)



---------------

InterfaceManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)

InterfaceManager:SetFolder("ReaperHub")
SaveManager:SetFolder("ReaperHub/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)


if game.CoreGui:FindFirstChild("ToggleUI") then
    game.CoreGui.ToggleUI:Destroy()
end



local gui = Instance.new("ScreenGui")
gui.Name = "ToggleUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = game.CoreGui


local border = Instance.new("Frame")
border.Parent = gui
border.Size = UDim2.new(0,0,0,0)
border.BackgroundColor3 = Color3.fromRGB(0,0,0)
border.ZIndex = 1
border.AnchorPoint = Vector2.new(0,0)

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0,14)
borderCorner.Parent = border


local button = Instance.new("ImageButton")
button.Parent = gui
button.Size = UDim2.new(0,60,0,60)
button.Position = UDim2.new(0,60,0.2,0)
button.AnchorPoint = Vector2.new(0,0)

button.BackgroundTransparency = 1
button.ZIndex = 999999
button.AutoButtonColor = false

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,12)
corner.Parent = button

local imgOn = "rbxassetid://86279908104891"
local imgOff = "rbxassetid://86279908104891"

button.Image = imgOn
button.ScaleType = Enum.ScaleType.Fit


local function UpdateBorder()

    local offset = (border.Size.X.Offset - button.Size.X.Offset) / 2

    border.Position = UDim2.new(
        button.Position.X.Scale,
        button.Position.X.Offset - offset,
        button.Position.Y.Scale,
        button.Position.Y.Offset - offset
    )
end

UpdateBorder()


local dragging = false
local dragStart, startPos

button.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = button.Position
    end
end)

UIS.InputChanged:Connect(function(input)

    if dragging then

        local delta = input.Position - dragStart

        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

        UpdateBorder()
    end
end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)


local isOpen = true

button.MouseButton1Click:Connect(function()

    isOpen = not isOpen

    if Window then
        Window:Minimize(not isOpen)
    end

    button.Image = isOpen and imgOff or imgOn

end)


-- Load Success 
task.wait(0.5)
print("Reaper Hub Loaded")
