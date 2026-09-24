--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║   NAMI  ·  Blox Fruits  ·  ONE-CLICK FARM  Lv1 → 2800+     ║
    ║   Auto-detects level → picks mob → teleports → farms        ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- ══════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RepStore     = game:GetService("ReplicatedStorage")
local Workspace    = game:GetService("Workspace")

local LP    = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ══════════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════════
local function GetChar()  return LP.Character end
local function GetHRP()
    local c = GetChar(); return c and c:FindFirstChild("HumanoidRootPart")
end
local function GetHum()
    local c = GetChar(); return c and c:FindFirstChild("Humanoid")
end
local function GetLevel()
    pcall(function()
        local stats = LP:FindFirstChild("leaderstats") or LP:WaitForChild("leaderstats", 2)
        if stats then
            local lv = stats:FindFirstChild("Level") or stats:FindFirstChild("Lv")
            if lv then return lv.Value end
        end
    end)
    -- fallback: read from Character stats
    local c = GetChar()
    if c then
        local hum = c:FindFirstChild("Humanoid")
        if hum then return math.floor(hum.Health / 10) end
    end
    return 1
end

local function Tween(obj, goals, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quad), goals):Play()
end

local function Notify(title, body, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title=title, Text=body, Duration=dur or 3
        })
    end)
end

local function TeleportTo(pos)
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0)) end
end

local function Dist(a, b) return (a - b).Magnitude end

-- ══════════════════════════════════════════════════════════
--  FULL LEVEL → MOB + ISLAND ROUTING TABLE
--  Format: { minLv, maxLv, mob, island, spawnPos }
-- ══════════════════════════════════════════════════════════
local Routes = {
    -- ─────────── SEA 1 ───────────
    { 1,   15,   "Bandit",              "Starter Island",      Vector3.new(-1234, 5, 234)    },
    { 15,  30,   "Pirate",              "Pirate Village",      Vector3.new(-1413, 5, -2955)  },
    { 30,  60,   "Brute",               "Jungle",              Vector3.new(-1627, 5, 407)    },
    { 60,  90,   "Monkey",              "Jungle",              Vector3.new(-1530, 5, 500)    },
    { 90,  120,  "Desert Bandit",       "Desert",              Vector3.new(923, 5, -5181)    },
    { 120, 150,  "Desert Pirate",       "Desert",              Vector3.new(980, 5, -5050)    },
    { 150, 185,  "Snow Bandit",         "Snow Island",         Vector3.new(1177, 5, -3197)   },
    { 185, 220,  "Snowman",             "Snow Island",         Vector3.new(1200, 5, -3100)   },
    { 220, 275,  "Sky Bandit",          "Sky Islands",         Vector3.new(-5008, 459, -4124)},
    { 275, 325,  "Dark Master",         "Sky Islands",         Vector3.new(-5100, 465, -4200)},
    { 325, 375,  "Gorilla King",        "Colosseum",           Vector3.new(-1403, 5, -5290)  },
    { 375, 450,  "Military Soldier",    "Marine Fortress",     Vector3.new(-2567, 5, -187)   },
    { 450, 500,  "Military Detective",  "Marine Fortress",     Vector3.new(-2620, 5, -230)   },
    { 500, 575,  "Toga Warrior",        "Magma Village",       Vector3.new(-5765, 5, 2440)   },
    { 575, 625,  "Magma Ninja",         "Magma Village",       Vector3.new(-5820, 5, 2380)   },
    { 625, 700,  "Dragon Crew Warrior", "Kingdom of Rose",     Vector3.new(-240, 5, 1000)    },

    -- ─────────── SEA 2 ───────────
    { 700,  750,  "Dragon Crew Warrior",  "Kingdom of Rose",    Vector3.new(-240, 5, 1000)   },
    { 750,  800,  "Jeremy",               "Kingdom of Rose",    Vector3.new(-300, 5, 970)    },
    { 800,  875,  "Saber Expert",         "Cursed Ship",        Vector3.new(-9912, 5, -8050) },
    { 875,  925,  "Zombie",               "Cursed Ship",        Vector3.new(-9950, 5, -8080) },
    { 925,  975,  "Living Zombie",        "Cursed Ship",        Vector3.new(-9980, 5, -8050) },
    { 975,  1025, "Vampire",              "Cursed Ship",        Vector3.new(-9900, 8, -8100) },
    { 1025, 1075, "Ice Admiral",          "Hot & Cold",         Vector3.new(-9625, 5, -6775) },
    { 1075, 1125, "Snow Demon",           "Hot & Cold",         Vector3.new(-9700, 5, -6700) },
    { 1125, 1175, "Arctic Warrior",       "Ice Castle",         Vector3.new(-11640, 65, -4610)},
    { 1175, 1250, "Ice Cremator",         "Ice Castle",         Vector3.new(-11700, 65, -4550)},
    { 1250, 1325, "Forest Pirate",        "Port Town",          Vector3.new(-2887, 5, -10744)},
    { 1325, 1400, "Corrupted Zoro",       "Port Town",          Vector3.new(-2950, 5, -10700)},
    { 1400, 1475, "Water Fighter",        "Underwater City",    Vector3.new(-3764, -2015, -1720)},
    { 1475, 1500, "God's Guard",          "Fountain City",      Vector3.new(-1174, 2, -3143) },

    -- ─────────── SEA 3 ───────────
    { 1500, 1575, "Pirate Millionaire",   "Hydra Island",       Vector3.new(-14584, 5, 5412) },
    { 1575, 1650, "Female Pirate",        "Great Tree",         Vector3.new(-17445, 185, 3835)},
    { 1650, 1700, "Forest Boss",          "Great Tree",         Vector3.new(-17500, 185, 3900)},
    { 1700, 1775, "Sick Scientist",       "Floating Turtle",    Vector3.new(-17427, 1585, 3807)},
    { 1775, 1850, "Island Empress",       "Floating Turtle",    Vector3.new(-17400, 1590, 3750)},
    { 1850, 1925, "Mythological Pirate",  "Haunted Castle",     Vector3.new(-13292, 5, -9827) },
    { 1925, 2000, "Demonic Soul",         "Haunted Castle",     Vector3.new(-13350, 5, -9900) },
    { 2000, 2075, "Poseidon Soldier",     "Sea of Treats",      Vector3.new(6674, 5, -10394) },
    { 2075, 2150, "Sweet Thief",          "Sea of Treats",      Vector3.new(6700, 5, -10350) },
    { 2150, 2225, "Cake Guard",           "Sea of Treats",      Vector3.new(6720, 5, -10300) },
    { 2225, 2300, "Tiki Outpost Worker",  "Tiki Outpost",       Vector3.new(5745, 5, -6155)  },
    { 2300, 2400, "Beautiful Pirate",     "Tiki Outpost",       Vector3.new(5780, 5, -6100)  },
    { 2400, 2475, "Gem Collector",        "Mirage Island",      Vector3.new(-2056, 40, 21170) },
    { 2475, 2550, "Dragon of the East",   "Mirage Island",      Vector3.new(-2100, 40, 21200) },
    { 2550, 2625, "Order Soldier",        "Castle on the Sea",  Vector3.new(6440, 5, -3270)  },
    { 2625, 2700, "Order Knight",         "Castle on the Sea",  Vector3.new(6480, 5, -3300)  },
    { 2700, 2775, "Elite Pirate",         "Haunted Castle",     Vector3.new(-13292, 5, -9827) },
    { 2775, 2800, "Ship Deckhand",        "Haunted Castle",     Vector3.new(-13400, 5, -9870) },
    { 2800, 9999, "Bandit King",          "Haunted Castle",     Vector3.new(-13450, 5, -9900) },
}

local function GetRouteForLevel(lv)
    for _, r in ipairs(Routes) do
        if lv >= r[1] and lv < r[2] then
            return r
        end
    end
    return Routes[#Routes]
end

-- ══════════════════════════════════════════════════════════
--  FARM STATE
-- ══════════════════════════════════════════════════════════
local Farm = {
    Running    = false,
    Kills      = 0,
    StartTime  = 0,
    LastMob    = "",
    LastIsland = "",
    LastLv     = 0,
    AutoQuest  = true,
    AutoStats  = true,
    StatType   = "Melee",
    LogLines   = {},
}

local function AddLog(msg)
    table.insert(Farm.LogLines, 1, msg)
    if #Farm.LogLines > 6 then table.remove(Farm.LogLines) end
end

-- ══════════════════════════════════════════════════════════
--  ANTI-AFK
-- ══════════════════════════════════════════════════════════
local VU = game:GetService("VirtualUser")
LP.Idled:Connect(function()
    VU:Button2Down(Vector2.zero, Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VU:Button2Up(Vector2.zero, Workspace.CurrentCamera.CFrame)
end)

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then hum.WalkSpeed = 32; hum.JumpPower = 80 end
end)

-- ══════════════════════════════════════════════════════════
--  CORE FARM LOOP
-- ══════════════════════════════════════════════════════════
local function FindMob(name)
    local hrp = GetHRP()
    if not hrp then return nil end
    local best, bestDist = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == name then
            local mHRP = obj:FindFirstChild("HumanoidRootPart")
            local mHum = obj:FindFirstChild("Humanoid")
            if mHRP and mHum and mHum.Health > 0 then
                local d = Dist(hrp.Position, mHRP.Position)
                if d < bestDist then bestDist = d; best = obj end
            end
        end
    end
    return best
end

local function DoQuest()
    pcall(function()
        local rem = RepStore:FindFirstChild("Remotes")
        if rem then
            local ctrl = rem:FindFirstChild("ServerControl")
            if ctrl then
                ctrl:FireServer({Action = "AcceptQuest"})
                ctrl:FireServer({Action = "TurnInQuest"})
            end
        end
    end)
end

local function DoStats()
    pcall(function()
        local rem = RepStore:FindFirstChild("Remotes")
        if rem then
            local ctrl = rem:FindFirstChild("ServerControl")
            if ctrl then
                ctrl:FireServer({Action = "StatPoint", Type = Farm.StatType})
            end
        end
    end)
end

local function AttackNearest(mobName)
    local hrp = GetHRP()
    if not hrp then return false end

    local mob = FindMob(mobName)
    if not mob then return false end

    local mHRP = mob:FindFirstChild("HumanoidRootPart")
    local mHum = mob:FindFirstChild("Humanoid")
    if not mHRP or not mHum or mHum.Health <= 0 then return false end

    -- Bring mob to us (server-side won't always work, so we go to mob)
    hrp.CFrame = mHRP.CFrame * CFrame.new(0, 0, 4)

    -- Attack via tool
    pcall(function()
        local char = GetChar()
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local rem = RepStore:FindFirstChild("Remotes")
            if rem then
                local ctrl = rem:FindFirstChild("ServerControl")
                if ctrl then
                    ctrl:FireServer({Action="Attack", Target=mob})
                end
            end
            -- Fallback activate
            pcall(function() tool:Activate() end)
        end
    end)

    return true
end

-- Main loop
task.spawn(function()
    while true do
        task.wait(0.05)
        if not Farm.Running then continue end

        local lv = GetLevel() or 1
        local route = GetRouteForLevel(lv)
        local mobName  = route[3]
        local island   = route[4]
        local islandPos = route[5]

        -- Update state
        if Farm.LastMob ~= mobName then
            Farm.LastMob = mobName
            Farm.LastIsland = island
            Farm.LastLv = lv
            AddLog("[Lv "..lv.."] → "..mobName.." @ "..island)
            -- Teleport to correct island
            TeleportTo(islandPos)
            task.wait(1.5)
        end

        -- Quest
        if Farm.AutoQuest then
            pcall(DoQuest)
        end

        -- Stats
        if Farm.AutoStats then
            pcall(DoStats)
        end

        -- Attack
        local attacked = AttackNearest(mobName)
        if attacked then
            Farm.Kills += 1
        else
            -- Mob not found nearby, re-teleport to island
            TeleportTo(islandPos)
            task.wait(0.8)
        end

        -- Re-check level and update route if changed
        local newLv = GetLevel() or 1
        if newLv ~= lv then
            Farm.LastMob = "" -- force re-route
        end
    end
end)

-- ══════════════════════════════════════════════════════════
--  FLIGHT
-- ══════════════════════════════════════════════════════════
local FlightOn = false
local FV, FG

local function EnableFlight()
    local hrp = GetHRP(); if not hrp then return end
    FV = Instance.new("BodyVelocity", hrp)
    FV.MaxForce = Vector3.new(1e9,1e9,1e9)
    FV.Velocity = Vector3.zero
    FG = Instance.new("BodyGyro", hrp)
    FG.MaxTorque = Vector3.new(1e9,1e9,1e9)
    FG.P = 10000
end

local function DisableFlight()
    if FV then FV:Destroy(); FV = nil end
    if FG then FG:Destroy(); FG = nil end
end

RunService.RenderStepped:Connect(function()
    if not FlightOn or not FV then return end
    local cam = Workspace.CurrentCamera
    local d = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then d = d + cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then d = d - cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then d = d - cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then d = d + cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then d = d + Vector3.new(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d = d - Vector3.new(0,1,0) end
    FV.Velocity = d.Magnitude > 0 and d.Unit * 180 or Vector3.zero
    FG.CFrame = cam.CFrame
end)

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.F then
        FlightOn = not FlightOn
        if FlightOn then EnableFlight() else DisableFlight() end
    end
end)

-- ══════════════════════════════════════════════════════════
--  GUI — NAMI ONE-CLICK
-- ══════════════════════════════════════════════════════════
pcall(function()
    local old = game.CoreGui:FindFirstChild("NAMI_OCF")
    if old then old:Destroy() end
end)

local SG = Instance.new("ScreenGui", game.CoreGui)
SG.Name = "NAMI_OCF"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ── Color palette ──
local C = {
    BG       = Color3.fromRGB(9, 8, 18),
    BG2      = Color3.fromRGB(14, 13, 28),
    Panel    = Color3.fromRGB(18, 17, 36),
    Alt      = Color3.fromRGB(24, 22, 46),
    Accent   = Color3.fromRGB(130, 80, 255),
    Accent2  = Color3.fromRGB(70, 160, 255),
    Green    = Color3.fromRGB(50, 220, 110),
    Red      = Color3.fromRGB(220, 55, 75),
    Text     = Color3.fromRGB(235, 230, 255),
    Dim      = Color3.fromRGB(130, 120, 170),
    Border   = Color3.fromRGB(45, 40, 90),
    Gold     = Color3.fromRGB(255, 200, 60),
}

local function R(p, r) local u = Instance.new("UICorner",p); u.CornerRadius = UDim.new(0,r or 8); return u end
local function S(p, col, th) local s = Instance.new("UIStroke",p); s.Color=col or C.Border; s.Thickness=th or 1; return s end
local function Lbl(p, txt, sz, col, fnt, xa)
    local l = Instance.new("TextLabel",p)
    l.BackgroundTransparency = 1
    l.Size = sz or UDim2.new(1,0,1,0)
    l.Text = txt or ""
    l.TextColor3 = col or C.Text
    l.TextScaled = true
    l.Font = fnt or Enum.Font.Gotham
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    return l
end

-- ── Window ──
local Win = Instance.new("Frame", SG)
Win.Size = UDim2.new(0, 520, 0, 580)
Win.Position = UDim2.new(0.5,-260, 0.5,-290)
Win.BackgroundColor3 = C.BG
Win.BorderSizePixel = 0
Win.Active = true
Win.Draggable = true
R(Win, 14)
S(Win, C.Accent, 1.5)

do
    local g = Instance.new("UIGradient", Win)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(9,8,20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14,9,28)),
    })
    g.Rotation = 135
end

-- ── Top Bar ──
local Top = Instance.new("Frame", Win)
Top.Size = UDim2.new(1,0,0,54)
Top.BackgroundColor3 = C.BG2
Top.BorderSizePixel = 0
R(Top, 14)

do
    local g = Instance.new("UIGradient", Top)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(110,55,230)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60,130,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(90,40,210)),
    })
    g.Rotation = 90
end

-- Logo box
local LogoBx = Instance.new("Frame", Top)
LogoBx.Size = UDim2.new(0,44,0,38)
LogoBx.Position = UDim2.new(0,8,0.5,-19)
LogoBx.BackgroundColor3 = Color3.fromRGB(25,12,60)
LogoBx.BorderSizePixel = 0
R(LogoBx, 8)
local LogoL = Lbl(LogoBx,"N",nil,Color3.new(1,1,1),Enum.Font.GothamBlack,Enum.TextXAlignment.Center)

local TitleL = Lbl(Top, "NAMI", UDim2.new(0,180,1,0), Color3.new(1,1,1), Enum.Font.GothamBlack)
TitleL.Position = UDim2.new(0,60,0,0)
local SubL = Lbl(Top, "One-Click Farm  ·  Lv 1 → 2800+",
    UDim2.new(0,280,0,16), Color3.fromRGB(200,180,255), Enum.Font.Gotham)
SubL.Position = UDim2.new(0,60,1,-20)

-- Close button
local CloseB = Instance.new("TextButton", Top)
CloseB.Size = UDim2.new(0,28,0,28)
CloseB.Position = UDim2.new(1,-38,0.5,-14)
CloseB.BackgroundColor3 = C.Red
CloseB.Text = "✕"
CloseB.TextColor3 = Color3.new(1,1,1)
CloseB.TextScaled = true
CloseB.Font = Enum.Font.GothamBold
CloseB.BorderSizePixel = 0
R(CloseB, 6)
CloseB.MouseButton1Click:Connect(function() Win.Visible = false end)

-- Min button
local MinB = Instance.new("TextButton", Top)
MinB.Size = UDim2.new(0,28,0,28)
MinB.Position = UDim2.new(1,-70,0.5,-14)
MinB.BackgroundColor3 = Color3.fromRGB(40,160,60)
MinB.Text = "–"
MinB.TextColor3 = Color3.new(1,1,1)
MinB.TextScaled = true
MinB.Font = Enum.Font.GothamBold
MinB.BorderSizePixel = 0
R(MinB, 6)

local body = Instance.new("Frame", Win)
body.Size = UDim2.new(1,-16, 1,-62)
body.Position = UDim2.new(0,8,0,58)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0

local minimized = false
MinB.MouseButton1Click:Connect(function()
    minimized = not minimized
    Tween(Win, {Size = minimized and UDim2.new(0,520,0,54) or UDim2.new(0,520,0,580)})
    body.Visible = not minimized
end)

-- ══════════════════════════════════════════════════════════
--  STATUS CARD
-- ══════════════════════════════════════════════════════════
local StatusCard = Instance.new("Frame", body)
StatusCard.Size = UDim2.new(1, 0, 0, 120)
StatusCard.BackgroundColor3 = C.Panel
StatusCard.BorderSizePixel = 0
R(StatusCard, 10)
S(StatusCard, C.Border)

do
    local g = Instance.new("UIGradient", StatusCard)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20,15,45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14,12,30)),
    })
    g.Rotation = 90
end

-- Level badge
local LvBadge = Instance.new("Frame", StatusCard)
LvBadge.Size = UDim2.new(0,80,0,80)
LvBadge.Position = UDim2.new(0,12,0.5,-40)
LvBadge.BackgroundColor3 = Color3.fromRGB(25,15,60)
LvBadge.BorderSizePixel = 0
R(LvBadge, 12)
S(LvBadge, C.Accent, 1.5)

local LvNumL = Lbl(LvBadge,"—",nil,C.Gold,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
local LvTagL = Lbl(LvBadge,"LEVEL",UDim2.new(1,0,0,16),C.Dim,Enum.Font.Gotham,Enum.TextXAlignment.Center)
LvTagL.Position = UDim2.new(0,0,0.78,0)

-- Info lines
local MobL = Lbl(StatusCard, "Mob: —",
    UDim2.new(1,-104,0,22), C.Text, Enum.Font.GothamSemibold)
MobL.Position = UDim2.new(0,100,0,12)

local IslandL = Lbl(StatusCard, "Island: —",
    UDim2.new(1,-104,0,18), C.Dim, Enum.Font.Gotham)
IslandL.Position = UDim2.new(0,100,0,38)

local KillsL = Lbl(StatusCard, "Kills: 0",
    UDim2.new(0,160,0,18), C.Dim, Enum.Font.Gotham)
KillsL.Position = UDim2.new(0,100,0,60)

local TimeL = Lbl(StatusCard, "Time: 0:00",
    UDim2.new(0,160,0,18), C.Dim, Enum.Font.Gotham)
TimeL.Position = UDim2.new(0,100,0,82)

-- Progress bar
local PBarBG = Instance.new("Frame", StatusCard)
PBarBG.Size = UDim2.new(1,-104,0,8)
PBarBG.Position = UDim2.new(0,100,1,-16)
PBarBG.BackgroundColor3 = C.Alt
PBarBG.BorderSizePixel = 0
R(PBarBG, 4)

local PBar = Instance.new("Frame", PBarBG)
PBar.Size = UDim2.new(0,0,1,0)
PBar.BackgroundColor3 = C.Accent
PBar.BorderSizePixel = 0
R(PBar, 4)
do
    local g = Instance.new("UIGradient", PBar)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(130,80,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(70,160,255)),
    })
    g.Rotation = 90
end

-- ══════════════════════════════════════════════════════════
--  GIANT START BUTTON
-- ══════════════════════════════════════════════════════════
local StartBtn = Instance.new("TextButton", body)
StartBtn.Size = UDim2.new(1,0,0,64)
StartBtn.Position = UDim2.new(0,0,0,130)
StartBtn.BackgroundColor3 = C.Green
StartBtn.Text = ""
StartBtn.BorderSizePixel = 0
R(StartBtn, 12)

do
    local g = Instance.new("UIGradient", StartBtn)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60,240,130)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30,180,80)),
    })
    g.Rotation = 90
end

local StartIcon = Lbl(StartBtn,"▶",UDim2.new(0,54,1,0),Color3.new(1,1,1),Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
StartIcon.Position = UDim2.new(0,0,0,0)

local StartTxt = Lbl(StartBtn,"START FARM",UDim2.new(1,-60,1,0),Color3.new(1,1,1),Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
StartTxt.Position = UDim2.new(0,50,0,0)

local function UpdateStartBtn()
    if Farm.Running then
        Tween(StartBtn, {BackgroundColor3 = C.Red})
        StartIcon.Text = "■"
        StartTxt.Text = "STOP FARM"
        do
            local g = StartBtn:FindFirstChildOfClass("UIGradient")
            if g then
                g.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(240,70,90)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(180,30,50)),
                })
            end
        end
    else
        Tween(StartBtn, {BackgroundColor3 = C.Green})
        StartIcon.Text = "▶"
        StartTxt.Text = "START FARM"
        do
            local g = StartBtn:FindFirstChildOfClass("UIGradient")
            if g then
                g.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(60,240,130)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(30,180,80)),
                })
            end
        end
    end
end

StartBtn.MouseButton1Click:Connect(function()
    Farm.Running = not Farm.Running
    if Farm.Running then
        Farm.StartTime = tick()
        Farm.Kills = 0
        Farm.LastMob = ""
        Notify("NAMI", "Auto Farm STARTED → detecting level...", 3)
        AddLog("Farm started")
    else
        Notify("NAMI", "Auto Farm STOPPED", 3)
        AddLog("Farm stopped")
    end
    UpdateStartBtn()
end)

StartBtn.MouseEnter:Connect(function() Tween(StartBtn, {BackgroundTransparency = 0.12}) end)
StartBtn.MouseLeave:Connect(function() Tween(StartBtn, {BackgroundTransparency = 0}) end)

-- ══════════════════════════════════════════════════════════
--  OPTIONS
-- ══════════════════════════════════════════════════════════
local OptionsCard = Instance.new("Frame", body)
OptionsCard.Size = UDim2.new(1,0,0,48)
OptionsCard.Position = UDim2.new(0,0,0,204)
OptionsCard.BackgroundColor3 = C.Panel
OptionsCard.BorderSizePixel = 0
R(OptionsCard, 10)
S(OptionsCard, C.Border)

local OptLayout = Instance.new("UIListLayout", OptionsCard)
OptLayout.FillDirection = Enum.FillDirection.Horizontal
OptLayout.SortOrder = Enum.SortOrder.LayoutOrder
OptLayout.Padding = UDim.new(0,6)

local OptPad = Instance.new("UIPadding", OptionsCard)
OptPad.PaddingLeft = UDim.new(0,8)
OptPad.PaddingRight = UDim.new(0,8)
OptPad.PaddingTop = UDim.new(0,6)
OptPad.PaddingBottom = UDim.new(0,6)

local function SmallToggle(parent, text, state, cb)
    local f = Instance.new("TextButton", parent)
    f.Size = UDim2.new(0, 144, 1, 0)
    f.BackgroundColor3 = state and C.Accent or C.Alt
    f.Text = text .. (state and "  ✓" or "  ✗")
    f.TextColor3 = Color3.new(1,1,1)
    f.TextScaled = true
    f.Font = Enum.Font.GothamSemibold
    f.BorderSizePixel = 0
    R(f, 7)

    f.MouseButton1Click:Connect(function()
        state = not state
        f.Text = text .. (state and "  ✓" or "  ✗")
        Tween(f, {BackgroundColor3 = state and C.Accent or C.Alt})
        if cb then cb(state) end
    end)
    return f
end

SmallToggle(OptionsCard, "Auto Quest", Farm.AutoQuest, function(v) Farm.AutoQuest = v end)
SmallToggle(OptionsCard, "Auto Stats", Farm.AutoStats, function(v) Farm.AutoStats = v end)

-- Stat type toggle
local statOpts = {"Melee","Defense","Sword","Gun","Fruit"}
local statIdx = 1
local StatBtn = Instance.new("TextButton", OptionsCard)
StatBtn.Size = UDim2.new(0,118,1,0)
StatBtn.BackgroundColor3 = C.Alt
StatBtn.Text = "Stat: Melee"
StatBtn.TextColor3 = C.Accent2
StatBtn.TextScaled = true
StatBtn.Font = Enum.Font.GothamSemibold
StatBtn.BorderSizePixel = 0
R(StatBtn, 7)
StatBtn.MouseButton1Click:Connect(function()
    statIdx = statIdx % #statOpts + 1
    Farm.StatType = statOpts[statIdx]
    StatBtn.Text = "Stat: "..Farm.StatType
end)

-- ══════════════════════════════════════════════════════════
--  LOG FEED
-- ══════════════════════════════════════════════════════════
local LogCard = Instance.new("Frame", body)
LogCard.Size = UDim2.new(1,0,0,162)
LogCard.Position = UDim2.new(0,0,0,262)
LogCard.BackgroundColor3 = C.Panel
LogCard.BorderSizePixel = 0
R(LogCard, 10)
S(LogCard, C.Border)

local LogTitle = Lbl(LogCard,"  LOG FEED",UDim2.new(1,0,0,24),C.Accent,Enum.Font.GothamBold)
LogTitle.Position = UDim2.new(0,0,0,4)

local LogLines = {}
for i = 1, 6 do
    local l = Lbl(LogCard, "",
        UDim2.new(1,-16,0,19),
        i == 1 and C.Text or C.Dim,
        i == 1 and Enum.Font.GothamSemibold or Enum.Font.Gotham)
    l.Position = UDim2.new(0,8,0,24+(i-1)*22)
    table.insert(LogLines, l)
end

-- ══════════════════════════════════════════════════════════
--  ROUTE TABLE PREVIEW (compact)
-- ══════════════════════════════════════════════════════════
local RouteCard = Instance.new("Frame", body)
RouteCard.Size = UDim2.new(1,0,0,104)
RouteCard.Position = UDim2.new(0,0,0,434)
RouteCard.BackgroundColor3 = C.Panel
RouteCard.BorderSizePixel = 0
R(RouteCard, 10)
S(RouteCard, C.Border)

local RouteTitle = Lbl(RouteCard,"  CURRENT ROUTE RANGE",UDim2.new(1,0,0,22),C.Accent,Enum.Font.GothamBold)
RouteTitle.Position = UDim2.new(0,0,0,4)

local RouteRange  = Lbl(RouteCard,"Lv: —",UDim2.new(1,-8,0,20),C.Text,Enum.Font.GothamSemibold)
RouteRange.Position = UDim2.new(0,8,0,28)
local RouteMobL   = Lbl(RouteCard,"Mob: —",UDim2.new(1,-8,0,18),C.Dim,Enum.Font.Gotham)
RouteMobL.Position = UDim2.new(0,8,0,50)
local RouteIslandL = Lbl(RouteCard,"Island: —",UDim2.new(1,-8,0,18),C.Dim,Enum.Font.Gotham)
RouteIslandL.Position = UDim2.new(0,8,0,70)

-- ── Help strip ──
local HelpL = Lbl(body,
    "[H] Toggle   [F] Flight   [INS] Destroy",
    UDim2.new(1,0,0,16),
    C.Dim, Enum.Font.Gotham, Enum.TextXAlignment.Center)
HelpL.Position = UDim2.new(0,0,1,-2)

-- ══════════════════════════════════════════════════════════
--  HUD UPDATE LOOP
-- ══════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.5) do
        -- Level
        local lv = GetLevel() or 1
        LvNumL.Text = tostring(lv)

        -- Route
        local route = GetRouteForLevel(lv)
        local pct = (lv - route[1]) / math.max(1, route[2] - route[1])
        pct = math.clamp(pct, 0, 1)
        Tween(PBar, {Size = UDim2.new(pct, 0, 1, 0)}, 0.4)

        MobL.Text    = "Mob: " .. route[3]
        IslandL.Text = "Island: " .. route[4]
        KillsL.Text  = "Kills: " .. Farm.Kills

        RouteRange.Text   = "Lv range: " .. route[1] .. " – " .. (route[2] == 9999 and "MAX" or tostring(route[2]))
        RouteMobL.Text    = "Mob: " .. route[3]
        RouteIslandL.Text = "Island: " .. route[4]

        -- Timer
        if Farm.Running then
            local elapsed = math.floor(tick() - Farm.StartTime)
            local m = math.floor(elapsed/60)
            local s = elapsed % 60
            TimeL.Text = string.format("Time: %d:%02d", m, s)
        else
            TimeL.Text = "Time: —"
        end

        -- Log
        for i, line in ipairs(LogLines) do
            line.Text = Farm.LogLines[i] or ""
        end
    end
end)

-- ══════════════════════════════════════════════════════════
--  KEYBINDS
-- ══════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.H then
        Win.Visible = not Win.Visible
    end
    if inp.KeyCode == Enum.KeyCode.Insert then
        Farm.Running = false
        SG:Destroy()
        print("[NAMI] Destroyed")
    end
end)

-- ══════════════════════════════════════════════════════════
Notify("NAMI — One-Click Farm", "Press START → Auto farms Lv1 to 2800+", 5)
print("[NAMI] One-Click Farm ready — "..#Routes.." routes loaded")
