--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║   NAMI  ·  Blox Fruits  ·  ONE-CLICK FARM  Lv1 → 2800+     ║
    ║   v2  |  Fixed Auto Attack  |  Custom Code Executor         ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RepStore     = game:GetService("ReplicatedStorage")
local Workspace    = game:GetService("Workspace")

local LP = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════════
local function GetChar() return LP.Character end
local function GetHRP()
    local c = GetChar(); return c and c:FindFirstChild("HumanoidRootPart")
end
local function GetHum()
    local c = GetChar(); return c and c:FindFirstChild("Humanoid")
end

-- Fixed GetLevel — pcall was swallowing the return value
local function GetLevel()
    local ok, val = pcall(function()
        local stats = LP:FindFirstChild("leaderstats")
        if not stats then stats = LP:WaitForChild("leaderstats", 3) end
        if stats then
            local lv = stats:FindFirstChild("Level")
                    or stats:FindFirstChild("Lv")
                    or stats:FindFirstChild("level")
            if lv then return lv.Value end
        end
        return nil
    end)
    if ok and val then return val end
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
--  ROUTING TABLE  (Lv 1 → 2800+)
-- ══════════════════════════════════════════════════════════
local Routes = {
    -- SEA 1
    { 1,   15,   "Bandit",              "Starter Island",   Vector3.new(-1234, 5, 234)     },
    { 15,  30,   "Pirate",              "Pirate Village",   Vector3.new(-1413, 5, -2955)   },
    { 30,  60,   "Brute",               "Jungle",           Vector3.new(-1627, 5, 407)     },
    { 60,  90,   "Monkey",              "Jungle",           Vector3.new(-1530, 5, 500)     },
    { 90,  120,  "Desert Bandit",       "Desert",           Vector3.new(923, 5, -5181)     },
    { 120, 150,  "Desert Pirate",       "Desert",           Vector3.new(980, 5, -5050)     },
    { 150, 185,  "Snow Bandit",         "Snow Island",      Vector3.new(1177, 5, -3197)    },
    { 185, 220,  "Snowman",             "Snow Island",      Vector3.new(1200, 5, -3100)    },
    { 220, 275,  "Sky Bandit",          "Sky Islands",      Vector3.new(-5008, 459, -4124) },
    { 275, 325,  "Dark Master",         "Sky Islands",      Vector3.new(-5100, 465, -4200) },
    { 325, 375,  "Gorilla King",        "Colosseum",        Vector3.new(-1403, 5, -5290)   },
    { 375, 450,  "Military Soldier",    "Marine Fortress",  Vector3.new(-2567, 5, -187)    },
    { 450, 500,  "Military Detective",  "Marine Fortress",  Vector3.new(-2620, 5, -230)    },
    { 500, 575,  "Toga Warrior",        "Magma Village",    Vector3.new(-5765, 5, 2440)    },
    { 575, 625,  "Magma Ninja",         "Magma Village",    Vector3.new(-5820, 5, 2380)    },
    { 625, 700,  "Dragon Crew Warrior", "Kingdom of Rose",  Vector3.new(-240, 5, 1000)     },
    -- SEA 2
    { 700,  750,  "Dragon Crew Warrior",  "Kingdom of Rose",   Vector3.new(-240, 5, 1000)    },
    { 750,  800,  "Jeremy",               "Kingdom of Rose",   Vector3.new(-300, 5, 970)     },
    { 800,  875,  "Saber Expert",         "Cursed Ship",       Vector3.new(-9912, 5, -8050)  },
    { 875,  925,  "Zombie",               "Cursed Ship",       Vector3.new(-9950, 5, -8080)  },
    { 925,  975,  "Living Zombie",        "Cursed Ship",       Vector3.new(-9980, 5, -8050)  },
    { 975,  1025, "Vampire",              "Cursed Ship",       Vector3.new(-9900, 8, -8100)  },
    { 1025, 1075, "Ice Admiral",          "Hot & Cold",        Vector3.new(-9625, 5, -6775)  },
    { 1075, 1125, "Snow Demon",           "Hot & Cold",        Vector3.new(-9700, 5, -6700)  },
    { 1125, 1175, "Arctic Warrior",       "Ice Castle",        Vector3.new(-11640, 65, -4610) },
    { 1175, 1250, "Ice Cremator",         "Ice Castle",        Vector3.new(-11700, 65, -4550) },
    { 1250, 1325, "Forest Pirate",        "Port Town",         Vector3.new(-2887, 5, -10744) },
    { 1325, 1400, "Corrupted Zoro",       "Port Town",         Vector3.new(-2950, 5, -10700) },
    { 1400, 1475, "Water Fighter",        "Underwater City",   Vector3.new(-3764, -2015, -1720) },
    { 1475, 1500, "God's Guard",          "Fountain City",     Vector3.new(-1174, 2, -3143)  },
    -- SEA 3
    { 1500, 1575, "Pirate Millionaire",  "Hydra Island",      Vector3.new(-14584, 5, 5412)  },
    { 1575, 1650, "Female Pirate",       "Great Tree",        Vector3.new(-17445, 185, 3835) },
    { 1650, 1700, "Forest Boss",         "Great Tree",        Vector3.new(-17500, 185, 3900) },
    { 1700, 1775, "Sick Scientist",      "Floating Turtle",   Vector3.new(-17427, 1585, 3807) },
    { 1775, 1850, "Island Empress",      "Floating Turtle",   Vector3.new(-17400, 1590, 3750) },
    { 1850, 1925, "Mythological Pirate", "Haunted Castle",    Vector3.new(-13292, 5, -9827)  },
    { 1925, 2000, "Demonic Soul",        "Haunted Castle",    Vector3.new(-13350, 5, -9900)  },
    { 2000, 2075, "Poseidon Soldier",    "Sea of Treats",     Vector3.new(6674, 5, -10394)   },
    { 2075, 2150, "Sweet Thief",         "Sea of Treats",     Vector3.new(6700, 5, -10350)   },
    { 2150, 2225, "Cake Guard",          "Sea of Treats",     Vector3.new(6720, 5, -10300)   },
    { 2225, 2300, "Tiki Outpost Worker", "Tiki Outpost",      Vector3.new(5745, 5, -6155)    },
    { 2300, 2400, "Beautiful Pirate",    "Tiki Outpost",      Vector3.new(5780, 5, -6100)    },
    { 2400, 2475, "Gem Collector",       "Mirage Island",     Vector3.new(-2056, 40, 21170)  },
    { 2475, 2550, "Dragon of the East",  "Mirage Island",     Vector3.new(-2100, 40, 21200)  },
    { 2550, 2625, "Order Soldier",       "Castle on the Sea", Vector3.new(6440, 5, -3270)    },
    { 2625, 2700, "Order Knight",        "Castle on the Sea", Vector3.new(6480, 5, -3300)    },
    { 2700, 2775, "Elite Pirate",        "Haunted Castle",    Vector3.new(-13292, 5, -9827)  },
    { 2775, 2800, "Ship Deckhand",       "Haunted Castle",    Vector3.new(-13400, 5, -9870)  },
    { 2800, 9999, "Bandit King",         "Haunted Castle",    Vector3.new(-13450, 5, -9900)  },
}

local function GetRouteForLevel(lv)
    for _, r in ipairs(Routes) do
        if lv >= r[1] and lv < r[2] then return r end
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
--  SYSTEMS
-- ══════════════════════════════════════════════════════════
-- Anti-AFK
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
--  FIXED AUTO ATTACK ENGINE
-- ══════════════════════════════════════════════════════════
local function FindMob(name)
    local hrp = GetHRP(); if not hrp then return nil end
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

local function AutoEquipTool()
    -- Auto equip first tool in backpack if nothing equipped
    local char = GetChar(); if not char then return end
    if char:FindFirstChildOfClass("Tool") then return end  -- already equipped
    local bp = LP:FindFirstChild("Backpack"); if not bp then return end
    local tool = bp:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() LP.Character.Humanoid:EquipTool(tool) end)
    end
end

local function AttackMob(mob)
    if not mob then return false end
    local hrp  = GetHRP(); if not hrp then return false end
    local char = GetChar(); if not char then return false end
    local mHRP = mob:FindFirstChild("HumanoidRootPart")
    local mHum = mob:FindFirstChild("Humanoid")
    if not mHRP or not mHum or mHum.Health <= 0 then return false end

    -- Step 1: Teleport onto mob
    hrp.CFrame = mHRP.CFrame * CFrame.new(0, 0, 3.5)

    -- Step 2: firetouchinterest (works on most exploits)
    pcall(function()
        firetouchinterest(hrp, mHRP, 0)
        firetouchinterest(hrp, mHRP, 1)
    end)

    -- Step 3: Auto equip tool
    AutoEquipTool()

    -- Step 4: Fire all RemoteEvents on equipped tool (M1 simulation)
    pcall(function()
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            -- Activate the tool
            tool:Activate()

            -- Fire every remote on the tool
            for _, rem in ipairs(tool:GetDescendants()) do
                if rem:IsA("RemoteEvent") then
                    pcall(function() rem:FireServer(mHRP.Position) end)
                end
            end

            -- Fire Blox Fruits main combat remote
            local rem = RepStore:FindFirstChild("Remotes")
            if rem then
                local ctrl = rem:FindFirstChild("ServerControl")
                if ctrl then
                    ctrl:FireServer({
                        Action = "Attack",
                        Target = mob,
                        Position = mHRP.Position,
                    })
                end
            end
        end
    end)

    -- Step 5: Simulate mouse click on mob HRP
    pcall(function()
        mouse1press()
        task.wait(0.05)
        mouse1release()
    end)

    -- Step 6: firetouchinterest loop on all mob parts
    pcall(function()
        for _, part in ipairs(mob:GetDescendants()) do
            if part:IsA("BasePart") then
                firetouchinterest(hrp, part, 0)
                firetouchinterest(hrp, part, 1)
            end
        end
    end)

    return true
end

local function DoQuest()
    pcall(function()
        local rem = RepStore:FindFirstChild("Remotes")
        if not rem then return end
        local ctrl = rem:FindFirstChild("ServerControl")
        if ctrl then
            ctrl:FireServer({Action = "AcceptQuest"})
            ctrl:FireServer({Action = "TurnInQuest"})
        end
    end)
end

local function DoStats()
    pcall(function()
        local rem = RepStore:FindFirstChild("Remotes")
        if not rem then return end
        local ctrl = rem:FindFirstChild("ServerControl")
        if ctrl then ctrl:FireServer({Action = "StatPoint", Type = Farm.StatType}) end
    end)
end

-- ── Kill Aura running in parallel ──
RunService.Heartbeat:Connect(function()
    if not Farm.Running then return end
    local hrp = GetHRP(); if not hrp then return end
    local char = GetChar(); if not char then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health > 0
            and not Players:GetPlayerFromCharacter(obj.Parent)
        then
            local mHRP = obj.Parent:FindFirstChild("HumanoidRootPart")
            if mHRP and Dist(hrp.Position, mHRP.Position) <= 30 then
                -- Touch attack
                pcall(function()
                    firetouchinterest(hrp, mHRP, 0)
                    firetouchinterest(hrp, mHRP, 1)
                end)
                -- Tool attack
                pcall(function()
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end)
                -- M1 click
                pcall(function() mouse1click() end)
            end
        end
    end
end)

-- ── Main Farm Loop ──
task.spawn(function()
    while true do
        task.wait(0.1)
        if not Farm.Running then continue end

        local lv = GetLevel() or 1
        local route = GetRouteForLevel(lv)
        local mobName   = route[3]
        local island    = route[4]
        local islandPos = route[5]

        if Farm.LastMob ~= mobName then
            Farm.LastMob    = mobName
            Farm.LastIsland = island
            AddLog("[Lv "..lv.."] → "..mobName.." @ "..island)
            TeleportTo(islandPos)
            task.wait(1.5)
        end

        if Farm.AutoQuest then pcall(DoQuest) end
        if Farm.AutoStats  then pcall(DoStats)  end

        -- Equip tool first
        AutoEquipTool()

        local mob = FindMob(mobName)
        if mob then
            local ok = AttackMob(mob)
            if ok then
                Farm.Kills += 1
            end
        else
            -- Re-teleport to island and look again
            TeleportTo(islandPos)
            task.wait(0.8)
        end

        -- Level change check → force re-route
        local newLv = GetLevel() or 1
        if newLv ~= lv then Farm.LastMob = "" end
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
    FV.MaxForce = Vector3.new(1e9,1e9,1e9); FV.Velocity = Vector3.zero
    FG = Instance.new("BodyGyro", hrp)
    FG.MaxTorque = Vector3.new(1e9,1e9,1e9); FG.P = 10000
end
local function DisableFlight()
    if FV then FV:Destroy(); FV = nil end
    if FG then FG:Destroy(); FG = nil end
end

RunService.RenderStepped:Connect(function()
    if not FlightOn or not FV then return end
    local cam = Workspace.CurrentCamera
    local d = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then d = d + cam.CFrame.LookVector  end
    if UIS:IsKeyDown(Enum.KeyCode.S) then d = d - cam.CFrame.LookVector  end
    if UIS:IsKeyDown(Enum.KeyCode.A) then d = d - cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then d = d + cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space)       then d = d + Vector3.new(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d = d - Vector3.new(0,1,0) end
    FV.Velocity = d.Magnitude > 0 and d.Unit * 180 or Vector3.zero
    FG.CFrame = cam.CFrame
end)

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.F then
        FlightOn = not FlightOn
        if FlightOn then EnableFlight() else DisableFlight() end
        Notify("NAMI", "Flight: "..(FlightOn and "ON" or "OFF"))
    end
end)

-- ══════════════════════════════════════════════════════════
--  GUI — NAMI v2
-- ══════════════════════════════════════════════════════════
pcall(function()
    local old = game.CoreGui:FindFirstChild("NAMI_OCF")
    if old then old:Destroy() end
end)

local SG = Instance.new("ScreenGui", game.CoreGui)
SG.Name = "NAMI_OCF"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local C = {
    BG      = Color3.fromRGB(9, 8, 18),
    BG2     = Color3.fromRGB(14, 13, 28),
    Panel   = Color3.fromRGB(18, 17, 36),
    Alt     = Color3.fromRGB(24, 22, 46),
    Accent  = Color3.fromRGB(130, 80, 255),
    Accent2 = Color3.fromRGB(70, 160, 255),
    Green   = Color3.fromRGB(50, 220, 110),
    Red     = Color3.fromRGB(220, 55, 75),
    Orange  = Color3.fromRGB(255, 150, 40),
    Text    = Color3.fromRGB(235, 230, 255),
    Dim     = Color3.fromRGB(130, 120, 170),
    Border  = Color3.fromRGB(45, 40, 90),
    Gold    = Color3.fromRGB(255, 200, 60),
}

local function R(p, r) local u=Instance.new("UICorner",p); u.CornerRadius=UDim.new(0,r or 8); return u end
local function S(p,col,th) local s=Instance.new("UIStroke",p); s.Color=col or C.Border; s.Thickness=th or 1; return s end
local function Lbl(p,txt,sz,col,fnt,xa)
    local l=Instance.new("TextLabel",p)
    l.BackgroundTransparency=1; l.Size=sz or UDim2.new(1,0,1,0)
    l.Text=txt or ""; l.TextColor3=col or C.Text; l.TextScaled=true
    l.Font=fnt or Enum.Font.Gotham; l.TextXAlignment=xa or Enum.TextXAlignment.Left
    return l
end

-- ── TABS ──
local TabNames = {"Farm","Code"}
local TabPages = {}
local TabBtns  = {}

local Win = Instance.new("Frame", SG)
Win.Size = UDim2.new(0, 530, 0, 620)
Win.Position = UDim2.new(0.5,-265, 0.5,-310)
Win.BackgroundColor3 = C.BG
Win.BorderSizePixel = 0
Win.Active = true; Win.Draggable = true
R(Win, 14); S(Win, C.Accent, 1.5)

do local g=Instance.new("UIGradient",Win)
   g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(9,8,20)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,9,28))})
   g.Rotation=135 end

-- Top bar
local Top = Instance.new("Frame",Win)
Top.Size=UDim2.new(1,0,0,54); Top.BackgroundColor3=C.BG2; Top.BorderSizePixel=0; R(Top,14)
do local g=Instance.new("UIGradient",Top)
   g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(110,55,230)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(60,130,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(90,40,210))})
   g.Rotation=90 end

local LogoBx=Instance.new("Frame",Top); LogoBx.Size=UDim2.new(0,44,0,38); LogoBx.Position=UDim2.new(0,8,0.5,-19)
LogoBx.BackgroundColor3=Color3.fromRGB(25,12,60); LogoBx.BorderSizePixel=0; R(LogoBx,8)
Lbl(LogoBx,"N",nil,Color3.new(1,1,1),Enum.Font.GothamBlack,Enum.TextXAlignment.Center)

local TitleL=Lbl(Top,"NAMI",UDim2.new(0,180,1,0),Color3.new(1,1,1),Enum.Font.GothamBlack); TitleL.Position=UDim2.new(0,60,0,0)
local SubL=Lbl(Top,"One-Click Farm · v2 Fixed",UDim2.new(0,280,0,16),Color3.fromRGB(200,180,255),Enum.Font.Gotham); SubL.Position=UDim2.new(0,60,1,-20)

local CloseB=Instance.new("TextButton",Top); CloseB.Size=UDim2.new(0,28,0,28); CloseB.Position=UDim2.new(1,-38,0.5,-14)
CloseB.BackgroundColor3=C.Red; CloseB.Text="✕"; CloseB.TextColor3=Color3.new(1,1,1); CloseB.TextScaled=true; CloseB.Font=Enum.Font.GothamBold; CloseB.BorderSizePixel=0; R(CloseB,6)
CloseB.MouseButton1Click:Connect(function() Win.Visible=false end)

local MinB=Instance.new("TextButton",Top); MinB.Size=UDim2.new(0,28,0,28); MinB.Position=UDim2.new(1,-70,0.5,-14)
MinB.BackgroundColor3=Color3.fromRGB(40,160,60); MinB.Text="–"; MinB.TextColor3=Color3.new(1,1,1); MinB.TextScaled=true; MinB.Font=Enum.Font.GothamBold; MinB.BorderSizePixel=0; R(MinB,6)

-- Tab bar
local TabBar=Instance.new("Frame",Win); TabBar.Size=UDim2.new(1,-16,0,34); TabBar.Position=UDim2.new(0,8,0,58)
TabBar.BackgroundColor3=C.BG2; TabBar.BorderSizePixel=0; R(TabBar,8); S(TabBar,C.Border)
local TBLayout=Instance.new("UIListLayout",TabBar); TBLayout.FillDirection=Enum.FillDirection.Horizontal
TBLayout.SortOrder=Enum.SortOrder.LayoutOrder; TBLayout.Padding=UDim.new(0,4)
local TBPad=Instance.new("UIPadding",TabBar); TBPad.PaddingLeft=UDim.new(0,4); TBPad.PaddingTop=UDim.new(0,4); TBPad.PaddingBottom=UDim.new(0,4); TBPad.PaddingRight=UDim.new(0,4)

-- Body
local Body=Instance.new("Frame",Win); Body.Size=UDim2.new(1,-16,1,-100); Body.Position=UDim2.new(0,8,0,100); Body.BackgroundTransparency=1; Body.BorderSizePixel=0

local minimized=false
MinB.MouseButton1Click:Connect(function()
    minimized=not minimized
    Tween(Win,{Size=minimized and UDim2.new(0,530,0,54) or UDim2.new(0,530,0,620)})
    Body.Visible=not minimized; TabBar.Visible=not minimized
end)

local function SwitchTab(idx)
    for i,p in ipairs(TabPages) do
        p.Visible=(i==idx)
        Tween(TabBtns[i],{BackgroundColor3=i==idx and C.Accent or C.Alt,TextColor3=i==idx and Color3.new(1,1,1) or C.Dim})
    end
end

for i, name in ipairs(TabNames) do
    local page=Instance.new("ScrollingFrame",Body)
    page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.BorderSizePixel=0
    page.ScrollBarThickness=3; page.ScrollBarImageColor3=C.Accent; page.CanvasSize=UDim2.new(0,0,0,0); page.Visible=false
    local ll=Instance.new("UIListLayout",page); ll.SortOrder=Enum.SortOrder.LayoutOrder; ll.Padding=UDim.new(0,6)
    local pp=Instance.new("UIPadding",page); pp.PaddingLeft=UDim.new(0,2); pp.PaddingRight=UDim.new(0,2); pp.PaddingTop=UDim.new(0,4)
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize=UDim2.new(0,0,0,ll.AbsoluteContentSize.Y+10) end)
    table.insert(TabPages, page)

    local btn=Instance.new("TextButton",TabBar); btn.Size=UDim2.new(0,118,1,0)
    btn.BackgroundColor3=C.Alt; btn.Text=name; btn.TextColor3=C.Dim; btn.TextScaled=true
    btn.Font=Enum.Font.GothamSemibold; btn.BorderSizePixel=0; R(btn,6)
    local idx=i
    btn.MouseButton1Click:Connect(function() SwitchTab(idx) end)
    table.insert(TabBtns, btn)
end

-- ══════════════════════════════════════════════════════════
--  TAB 1: FARM
-- ══════════════════════════════════════════════════════════
local FarmPage = TabPages[1]

-- Status card
local SC=Instance.new("Frame",FarmPage); SC.Size=UDim2.new(1,0,0,118); SC.BackgroundColor3=C.Panel; SC.BorderSizePixel=0; R(SC,10); S(SC,C.Border)
do local g=Instance.new("UIGradient",SC); g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(20,15,45)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,12,30))}); g.Rotation=90 end

local LvBadge=Instance.new("Frame",SC); LvBadge.Size=UDim2.new(0,78,0,78); LvBadge.Position=UDim2.new(0,12,0.5,-39)
LvBadge.BackgroundColor3=Color3.fromRGB(25,15,60); LvBadge.BorderSizePixel=0; R(LvBadge,12); S(LvBadge,C.Accent,1.5)
local LvNumL=Lbl(LvBadge,"—",nil,C.Gold,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
local LvTagL=Lbl(LvBadge,"LV",UDim2.new(1,0,0,14),C.Dim,Enum.Font.Gotham,Enum.TextXAlignment.Center); LvTagL.Position=UDim2.new(0,0,0.8,0)

local MobL=Lbl(SC,"Mob: —",UDim2.new(1,-102,0,22),C.Text,Enum.Font.GothamSemibold); MobL.Position=UDim2.new(0,98,0,10)
local IslandL=Lbl(SC,"Island: —",UDim2.new(1,-102,0,18),C.Dim,Enum.Font.Gotham); IslandL.Position=UDim2.new(0,98,0,34)
local KillsL=Lbl(SC,"Kills: 0",UDim2.new(0,160,0,18),C.Dim,Enum.Font.Gotham); KillsL.Position=UDim2.new(0,98,0,56)
local TimeL=Lbl(SC,"Time: 0:00",UDim2.new(0,160,0,18),C.Dim,Enum.Font.Gotham); TimeL.Position=UDim2.new(0,98,0,76)

local PBarBG=Instance.new("Frame",SC); PBarBG.Size=UDim2.new(1,-102,0,7); PBarBG.Position=UDim2.new(0,98,1,-14); PBarBG.BackgroundColor3=C.Alt; PBarBG.BorderSizePixel=0; R(PBarBG,4)
local PBar=Instance.new("Frame",PBarBG); PBar.Size=UDim2.new(0,0,1,0); PBar.BackgroundColor3=C.Accent; PBar.BorderSizePixel=0; R(PBar,4)
do local g=Instance.new("UIGradient",PBar); g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(130,80,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(70,160,255))}); g.Rotation=90 end

-- START/STOP button
local StartBtn=Instance.new("TextButton",FarmPage); StartBtn.Size=UDim2.new(1,0,0,62); StartBtn.BackgroundColor3=C.Green
StartBtn.Text=""; StartBtn.BorderSizePixel=0; R(StartBtn,12)
do local g=Instance.new("UIGradient",StartBtn); g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(60,240,130)),ColorSequenceKeypoint.new(1,Color3.fromRGB(30,180,80))}); g.Rotation=90 end
local SIcon=Lbl(StartBtn,"▶",UDim2.new(0,52,1,0),Color3.new(1,1,1),Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
local STxt=Lbl(StartBtn,"START FARM",UDim2.new(1,-58,1,0),Color3.new(1,1,1),Enum.Font.GothamBlack,Enum.TextXAlignment.Center); STxt.Position=UDim2.new(0,50,0,0)

local function UpdateStartBtn()
    if Farm.Running then
        Tween(StartBtn,{BackgroundColor3=C.Red})
        SIcon.Text="■"; STxt.Text="STOP FARM"
    else
        Tween(StartBtn,{BackgroundColor3=C.Green})
        SIcon.Text="▶"; STxt.Text="START FARM"
    end
end

StartBtn.MouseButton1Click:Connect(function()
    Farm.Running=not Farm.Running
    if Farm.Running then
        Farm.StartTime=tick(); Farm.Kills=0; Farm.LastMob=""; AddLog("Farm started")
        Notify("NAMI","Auto Farm STARTED",3)
    else
        AddLog("Farm stopped"); Notify("NAMI","Stopped",3)
    end
    UpdateStartBtn()
end)
StartBtn.MouseEnter:Connect(function() Tween(StartBtn,{BackgroundTransparency=0.12}) end)
StartBtn.MouseLeave:Connect(function() Tween(StartBtn,{BackgroundTransparency=0}) end)

-- Options row
local OptRow=Instance.new("Frame",FarmPage); OptRow.Size=UDim2.new(1,0,0,46); OptRow.BackgroundColor3=C.Panel; OptRow.BorderSizePixel=0; R(OptRow,10); S(OptRow,C.Border)
local OL=Instance.new("UIListLayout",OptRow); OL.FillDirection=Enum.FillDirection.Horizontal; OL.SortOrder=Enum.SortOrder.LayoutOrder; OL.Padding=UDim.new(0,6)
local OP=Instance.new("UIPadding",OptRow); OP.PaddingLeft=UDim.new(0,8); OP.PaddingRight=UDim.new(0,8); OP.PaddingTop=UDim.new(0,6); OP.PaddingBottom=UDim.new(0,6)

local function SmToggle(parent, text, state, cb)
    local f=Instance.new("TextButton",parent); f.Size=UDim2.new(0,138,1,0)
    f.BackgroundColor3=state and C.Accent or C.Alt; f.Text=text..(state and "  ✓" or "  ✗")
    f.TextColor3=Color3.new(1,1,1); f.TextScaled=true; f.Font=Enum.Font.GothamSemibold; f.BorderSizePixel=0; R(f,7)
    f.MouseButton1Click:Connect(function()
        state=not state; f.Text=text..(state and "  ✓" or "  ✗")
        Tween(f,{BackgroundColor3=state and C.Accent or C.Alt}); if cb then cb(state) end
    end)
    return f
end

SmToggle(OptRow,"Auto Quest",Farm.AutoQuest,function(v) Farm.AutoQuest=v end)
SmToggle(OptRow,"Auto Stats",Farm.AutoStats,function(v) Farm.AutoStats=v end)

local statOpts={"Melee","Defense","Sword","Gun","Fruit"}; local statIdx=1
local StatBtn=Instance.new("TextButton",OptRow); StatBtn.Size=UDim2.new(0,110,1,0)
StatBtn.BackgroundColor3=C.Alt; StatBtn.Text="Stat: Melee"; StatBtn.TextColor3=C.Accent2; StatBtn.TextScaled=true; StatBtn.Font=Enum.Font.GothamSemibold; StatBtn.BorderSizePixel=0; R(StatBtn,7)
StatBtn.MouseButton1Click:Connect(function()
    statIdx=statIdx%#statOpts+1; Farm.StatType=statOpts[statIdx]; StatBtn.Text="Stat: "..Farm.StatType
end)

-- Log feed
local LogCard=Instance.new("Frame",FarmPage); LogCard.Size=UDim2.new(1,0,0,150); LogCard.BackgroundColor3=C.Panel; LogCard.BorderSizePixel=0; R(LogCard,10); S(LogCard,C.Border)
Lbl(LogCard,"  LOG FEED",UDim2.new(1,0,0,22),C.Accent,Enum.Font.GothamBold).Position=UDim2.new(0,0,0,4)
local LogLineLabels={}
for i=1,6 do
    local l=Lbl(LogCard,"",UDim2.new(1,-16,0,18),i==1 and C.Text or C.Dim,i==1 and Enum.Font.GothamSemibold or Enum.Font.Gotham)
    l.Position=UDim2.new(0,8,0,22+(i-1)*20)
    table.insert(LogLineLabels,l)
end

-- Route card
local RouteCard=Instance.new("Frame",FarmPage); RouteCard.Size=UDim2.new(1,0,0,88); RouteCard.BackgroundColor3=C.Panel; RouteCard.BorderSizePixel=0; R(RouteCard,10); S(RouteCard,C.Border)
Lbl(RouteCard,"  CURRENT ROUTE",UDim2.new(1,0,0,22),C.Accent,Enum.Font.GothamBold).Position=UDim2.new(0,0,0,4)
local RouteRange=Lbl(RouteCard,"Lv: —",UDim2.new(1,-8,0,18),C.Text,Enum.Font.GothamSemibold); RouteRange.Position=UDim2.new(0,8,0,26)
local RouteMobL=Lbl(RouteCard,"Mob: —",UDim2.new(1,-8,0,16),C.Dim,Enum.Font.Gotham); RouteMobL.Position=UDim2.new(0,8,0,46)
local RouteIslandL=Lbl(RouteCard,"Island: —",UDim2.new(1,-8,0,16),C.Dim,Enum.Font.Gotham); RouteIslandL.Position=UDim2.new(0,8,0,64)

-- Help
Lbl(FarmPage,"[H] Toggle   [F] Flight   [INS] Destroy",UDim2.new(1,0,0,16),C.Dim,Enum.Font.Gotham,Enum.TextXAlignment.Center)

-- ══════════════════════════════════════════════════════════
--  TAB 2: CUSTOM CODE EXECUTOR
-- ══════════════════════════════════════════════════════════
local CodePage = TabPages[2]

local CodeTitleCard=Instance.new("Frame",CodePage); CodeTitleCard.Size=UDim2.new(1,0,0,36); CodeTitleCard.BackgroundColor3=C.Panel; CodeTitleCard.BorderSizePixel=0; R(CodeTitleCard,10); S(CodeTitleCard,C.Border)
Lbl(CodeTitleCard,"  ⚡  CUSTOM LUA EXECUTOR",UDim2.new(1,0,1,0),C.Orange,Enum.Font.GothamBold)

local CodeBox=Instance.new("TextBox",CodePage); CodeBox.Size=UDim2.new(1,0,0,300)
CodeBox.BackgroundColor3=Color3.fromRGB(10,10,22); CodeBox.BorderSizePixel=0
CodeBox.TextColor3=Color3.fromRGB(160,255,130); CodeBox.PlaceholderText="-- Paste or type Lua code here...\n-- Example:\nprint('Hello NAMI')"
CodeBox.PlaceholderColor3=Color3.fromRGB(80,80,120); CodeBox.Text=""
CodeBox.TextScaled=false; CodeBox.TextSize=14; CodeBox.Font=Enum.Font.Code
CodeBox.MultiLine=true; CodeBox.ClearTextOnFocus=false; CodeBox.TextXAlignment=Enum.TextXAlignment.Left
CodeBox.TextYAlignment=Enum.TextYAlignment.Top
R(CodeBox,10); S(CodeBox,C.Border)
local CP=Instance.new("UIPadding",CodeBox); CP.PaddingLeft=UDim.new(0,8); CP.PaddingTop=UDim.new(0,8)

-- Status label
local ExecStatusL=Lbl(CodePage,"Ready.",UDim2.new(1,0,0,20),C.Dim,Enum.Font.Gotham); ExecStatusL.TextXAlignment=Enum.TextXAlignment.Left

-- Buttons row
local BtnRow=Instance.new("Frame",CodePage); BtnRow.Size=UDim2.new(1,0,0,46); BtnRow.BackgroundTransparency=1; BtnRow.BorderSizePixel=0
local BRL=Instance.new("UIListLayout",BtnRow); BRL.FillDirection=Enum.FillDirection.Horizontal; BRL.SortOrder=Enum.SortOrder.LayoutOrder; BRL.Padding=UDim.new(0,8)

local ExecBtn=Instance.new("TextButton",BtnRow); ExecBtn.Size=UDim2.new(0,200,1,0)
ExecBtn.BackgroundColor3=C.Orange; ExecBtn.Text="⚡  EXECUTE"; ExecBtn.TextColor3=Color3.new(1,1,1)
ExecBtn.TextScaled=true; ExecBtn.Font=Enum.Font.GothamBold; ExecBtn.BorderSizePixel=0; R(ExecBtn,10)
do local g=Instance.new("UIGradient",ExecBtn); g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,170,50)),ColorSequenceKeypoint.new(1,Color3.fromRGB(220,100,20))}); g.Rotation=90 end

local ClearBtn=Instance.new("TextButton",BtnRow); ClearBtn.Size=UDim2.new(0,140,1,0)
ClearBtn.BackgroundColor3=C.Alt; ClearBtn.Text="✕  CLEAR"; ClearBtn.TextColor3=C.Dim
ClearBtn.TextScaled=true; ClearBtn.Font=Enum.Font.GothamSemibold; ClearBtn.BorderSizePixel=0; R(ClearBtn,10); S(ClearBtn,C.Border)

local CopyBtn=Instance.new("TextButton",BtnRow); CopyBtn.Size=UDim2.new(0,140,1,0)
CopyBtn.BackgroundColor3=C.Alt; CopyBtn.Text="📋  COPY"; CopyBtn.TextColor3=C.Dim
CopyBtn.TextScaled=true; CopyBtn.Font=Enum.Font.GothamSemibold; CopyBtn.BorderSizePixel=0; R(CopyBtn,10); S(CopyBtn,C.Border)

ExecBtn.MouseButton1Click:Connect(function()
    local code = CodeBox.Text
    if code == "" or code == nil then
        ExecStatusL.Text = "⚠ No code to execute."
        ExecStatusL.TextColor3 = C.Orange
        return
    end
    local fn, err = loadstring(code)
    if not fn then
        ExecStatusL.Text = "❌ Syntax error: "..(err or "unknown")
        ExecStatusL.TextColor3 = C.Red
        return
    end
    local ok, runErr = pcall(fn)
    if ok then
        ExecStatusL.Text = "✅ Executed successfully."
        ExecStatusL.TextColor3 = C.Green
    else
        ExecStatusL.Text = "❌ Runtime error: "..(runErr or "?")
        ExecStatusL.TextColor3 = C.Red
    end
end)

ClearBtn.MouseButton1Click:Connect(function()
    CodeBox.Text = ""
    ExecStatusL.Text = "Cleared."
    ExecStatusL.TextColor3 = C.Dim
end)

CopyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(CodeBox.Text) end)
    ExecStatusL.Text = "📋 Copied to clipboard."
    ExecStatusL.TextColor3 = C.Accent2
end)

-- Quick inject snippets
local SnipCard=Instance.new("Frame",CodePage); SnipCard.Size=UDim2.new(1,0,0,100); SnipCard.BackgroundColor3=C.Panel; SnipCard.BorderSizePixel=0; R(SnipCard,10); S(SnipCard,C.Border)
Lbl(SnipCard,"  QUICK SNIPPETS",UDim2.new(1,0,0,24),C.Accent,Enum.Font.GothamBold).Position=UDim2.new(0,0,0,2)

local SnipLayout=Instance.new("UIListLayout",SnipCard); SnipLayout.FillDirection=Enum.FillDirection.Horizontal
SnipLayout.SortOrder=Enum.SortOrder.LayoutOrder; SnipLayout.Padding=UDim.new(0,6)
local SnipPad=Instance.new("UIPadding",SnipCard); SnipPad.PaddingLeft=UDim.new(0,6); SnipPad.PaddingTop=UDim.new(0,28); SnipPad.PaddingBottom=UDim.new(0,6); SnipPad.PaddingRight=UDim.new(0,6)

local Snippets = {
    {"WalkSpeed x2", 'game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 64'},
    {"Inf Jump",     'game:GetService("UserInputService").JumpRequest:Connect(function()\n  game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)\nend)'},
    {"Kill All",     'for _,v in pairs(game.Workspace:GetDescendants()) do\n  if v:IsA("Humanoid") and not game.Players:GetPlayerFromCharacter(v.Parent) then\n    pcall(function() v.Health=0 end)\n  end\nend'},
}

for _, snip in ipairs(Snippets) do
    local sb=Instance.new("TextButton",SnipCard); sb.Size=UDim2.new(0,150,1,0)
    sb.BackgroundColor3=C.Alt; sb.Text=snip[1]; sb.TextColor3=C.Accent2; sb.TextScaled=true
    sb.Font=Enum.Font.GothamSemibold; sb.BorderSizePixel=0; R(sb,7); S(sb,C.Border)
    sb.MouseButton1Click:Connect(function()
        CodeBox.Text=snip[2]
        ExecStatusL.Text="Snippet loaded: "..snip[1]
        ExecStatusL.TextColor3=C.Accent2
    end)
end

-- ══════════════════════════════════════════════════════════
--  HUD UPDATER
-- ══════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.5) do
        local lv = GetLevel() or 1
        LvNumL.Text = tostring(lv)

        local route = GetRouteForLevel(lv)
        local pct = math.clamp((lv - route[1]) / math.max(1, route[2] - route[1]), 0, 1)
        Tween(PBar, {Size = UDim2.new(pct, 0, 1, 0)}, 0.4)

        MobL.Text    = "Mob: "    .. route[3]
        IslandL.Text = "Island: " .. route[4]
        KillsL.Text  = "Kills: "  .. Farm.Kills

        RouteRange.Text    = "Lv range: "..route[1].." – "..(route[2]==9999 and "MAX" or tostring(route[2]))
        RouteMobL.Text     = "Mob: "    .. route[3]
        RouteIslandL.Text  = "Island: " .. route[4]

        if Farm.Running then
            local e = math.floor(tick() - Farm.StartTime)
            TimeL.Text = string.format("Time: %d:%02d", math.floor(e/60), e%60)
        else
            TimeL.Text = "Time: —"
        end

        for i, line in ipairs(LogLineLabels) do
            line.Text = Farm.LogLines[i] or ""
        end
    end
end)

-- ══════════════════════════════════════════════════════════
--  KEYBINDS
-- ══════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.H then Win.Visible=not Win.Visible end
    if inp.KeyCode == Enum.KeyCode.Insert then
        Farm.Running=false; SG:Destroy(); print("[NAMI] Destroyed")
    end
end)

SwitchTab(1)  -- default Farm tab

Notify("NAMI v2","Fixed attack! Press START → instant farm",5)
print("[NAMI v2] One-Click Farm ready — "..#Routes.." routes loaded")
