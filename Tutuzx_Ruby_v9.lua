--========================================================
--  Tutuzx Ruby v9  -  menu estilo hub + abas novas (base: Tutuzx v8)
--  Cole inteiro no Delta e execute
--========================================================
local IMAGE_URL = ""
local IMAGE_ID = ""

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TS = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local lp = Players.LocalPlayer

local function clean(getp)
    pcall(function()
        local p = getp()
        if p then
            local o = p:FindFirstChild("Tutu")
            if o then o:Destroy() end
        end
    end)
end
clean(function() return gethui and gethui() end)
clean(function() return game:GetService("CoreGui") end)
clean(function() return lp and lp:FindFirstChild("PlayerGui") end)
pcall(function()
    local s = workspace:FindFirstChild("TutuSound")
    if s then s:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "Tutu"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
local okp = pcall(function()
    gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not okp or not gui.Parent then
    gui.Parent = lp:WaitForChild("PlayerGui")
end

-- camada das linhas do ESP (fica atras do menu)
local tracerLayer = Instance.new("Frame", gui)
tracerLayer.Name = "Tracers"
tracerLayer.Size = UDim2.new(1, 0, 1, 0)
tracerLayer.BackgroundTransparency = 1
tracerLayer.Active = false

local ORANGE = Color3.fromRGB(255, 140, 30)
local ACC = Color3.fromRGB(225, 29, 72)
local MID = Color3.fromRGB(22, 26, 44)
local GREEN = Color3.fromRGB(255, 90, 125)
local PURPLE = Color3.fromRGB(255, 160, 175)
local GOOD = Color3.fromRGB(80, 220, 130)
local RED = Color3.fromRGB(170, 50, 70)

local http = (syn and syn.request) or http_request or request
local clip = setclipboard or toclipboard

local conns = {}
local function bind(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end

local function tween(o, t, props, style)
    pcall(function()
        TS:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end)
end
local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = o
    return c
end
local function nextOrder(p)
    local n = (p:GetAttribute("n") or 0) + 1
    p:SetAttribute("n", n)
    return n
end

------------------------------------------------------------
-- tela de carregamento (aparece ao executar)
------------------------------------------------------------
local LD = {done = true, ready = false}
do
    local rootRef
    local ok = pcall(function()
        local root = Instance.new("CanvasGroup")
        rootRef = root
        root.Name = "Loader"
        root.Size = UDim2.new(1, 0, 1, 0)
        root.BackgroundColor3 = Color3.fromRGB(6, 8, 14)
        root.BorderSizePixel = 0
        root.ZIndex = 100
        root.Active = true
        root.Parent = gui

        local C1, C2, C3 = Color3.fromRGB(225, 29, 72), Color3.fromRGB(255, 90, 125), Color3.fromRGB(255, 215, 222)
        local bgG = Instance.new("UIGradient", root)
        bgG.Rotation = 90
        bgG.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 6, 12)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 14, 26)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 6, 12)),
        })

        -- grade de fundo
        for i = 1, 11 do
            local l = Instance.new("Frame", root)
            l.Size = UDim2.new(0, 1, 1, 0)
            l.Position = UDim2.new(i / 12, 0, 0, 0)
            l.BackgroundColor3 = C1
            l.BackgroundTransparency = 0.94
            l.BorderSizePixel = 0
        end
        for i = 1, 7 do
            local l = Instance.new("Frame", root)
            l.Size = UDim2.new(1, 0, 0, 1)
            l.Position = UDim2.new(0, 0, i / 8, 0)
            l.BackgroundColor3 = C1
            l.BackgroundTransparency = 0.94
            l.BorderSizePixel = 0
        end
        -- cantos
        for _, c in ipairs({{0, 0}, {1, 0}, {0, 1}, {1, 1}}) do
            for _, h in ipairs({true, false}) do
                local b = Instance.new("Frame", root)
                b.AnchorPoint = Vector2.new(c[1], c[2])
                b.Position = UDim2.new(c[1], c[1] == 0 and 18 or -18, c[2], c[2] == 0 and 18 or -18)
                b.Size = h and UDim2.new(0, 30, 0, 2) or UDim2.new(0, 2, 0, 30)
                b.BackgroundColor3 = C1
                b.BorderSizePixel = 0
            end
        end
        -- feixe
        local beam = Instance.new("Frame", root)
        beam.Size = UDim2.new(1, 0, 0, 2)
        beam.BackgroundColor3 = C1
        beam.BackgroundTransparency = 0.5
        beam.BorderSizePixel = 0
        local bg = Instance.new("UIGradient", beam)
        bg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1),
        })

        local font = Enum.Font.GothamBlack
        pcall(function() font = Enum.Font.Michroma end)

        local box = Instance.new("Frame", root)
        box.AnchorPoint = Vector2.new(0.5, 0.5)
        box.Position = UDim2.new(0.5, 0, 0.5, 0)
        box.Size = UDim2.new(0, 300, 0, 250)
        box.BackgroundTransparency = 1
        local bscale = Instance.new("UIScale", box)

        -- emblema giratorio
        local function sq(size, color, thick)
            local f = Instance.new("Frame", box)
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.Position = UDim2.new(0.5, 0, 0, 40)
            f.Size = UDim2.new(0, size, 0, size)
            f.BackgroundTransparency = 1
            local s = Instance.new("UIStroke", f)
            s.Color = color
            s.Thickness = thick
            return f
        end
        local outer = sq(76, C1, 2)
        local inner = sq(52, C2, 2)
        local core = Instance.new("TextLabel", box)
        core.AnchorPoint = Vector2.new(0.5, 0.5)
        core.Position = UDim2.new(0.5, 0, 0, 40)
        core.Size = UDim2.new(0, 60, 0, 30)
        core.BackgroundTransparency = 1
        core.Text = "TX"
        core.TextColor3 = C3
        core.Font = font
        core.TextSize = 18

        local title = Instance.new("TextLabel", box)
        title.Position = UDim2.new(0, 0, 0, 86)
        title.Size = UDim2.new(1, 0, 0, 36)
        title.BackgroundTransparency = 1
        title.Text = "TUTUZX"
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Font = font
        title.TextSize = 30
        local tg = Instance.new("UIGradient", title)
        tg.Color = ColorSequence.new(C1, C3)

        local sub = Instance.new("TextLabel", box)
        sub.Position = UDim2.new(0, 0, 0, 124)
        sub.Size = UDim2.new(1, 0, 0, 16)
        sub.BackgroundTransparency = 1
        sub.Text = "RUBY  //  INICIANDO"
        sub.TextColor3 = Color3.fromRGB(140, 148, 175)
        sub.Font = Enum.Font.Code
        sub.TextSize = 11

        local track = Instance.new("Frame", box)
        track.Position = UDim2.new(0, 10, 0, 158)
        track.Size = UDim2.new(1, -20, 0, 6)
        track.BackgroundColor3 = Color3.fromRGB(26, 30, 50)
        track.BorderSizePixel = 0
        corner(track, 3)
        local ts = Instance.new("UIStroke", track)
        ts.Color = C1
        ts.Transparency = 0.6
        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Color3.new(1, 1, 1)
        fill.BorderSizePixel = 0
        corner(fill, 3)
        local fg = Instance.new("UIGradient", fill)
        fg.Color = ColorSequence.new(C1, C3)

        local status = Instance.new("TextLabel", box)
        status.Position = UDim2.new(0, 10, 0, 170)
        status.Size = UDim2.new(1, -70, 0, 18)
        status.BackgroundTransparency = 1
        status.Text = "Iniciando nucleo..."
        status.TextColor3 = Color3.fromRGB(185, 190, 214)
        status.Font = Enum.Font.Code
        status.TextSize = 12
        status.TextXAlignment = Enum.TextXAlignment.Left
        local pct = Instance.new("TextLabel", box)
        pct.Position = UDim2.new(1, -70, 0, 170)
        pct.Size = UDim2.new(0, 60, 0, 18)
        pct.BackgroundTransparency = 1
        pct.Text = "0%"
        pct.TextColor3 = C1
        pct.Font = Enum.Font.Code
        pct.TextSize = 12
        pct.TextXAlignment = Enum.TextXAlignment.Right

        local logs = {}
        for i = 1, 3 do
            local l = Instance.new("TextLabel", box)
            l.Position = UDim2.new(0, 10, 0, 196 + (i - 1) * 14)
            l.Size = UDim2.new(1, -20, 0, 14)
            l.BackgroundTransparency = 1
            l.Text = ""
            l.TextColor3 = Color3.fromRGB(120, 126, 152)
            l.Font = Enum.Font.Code
            l.TextSize = 10
            l.TextXAlignment = Enum.TextXAlignment.Left
            logs[i] = l
        end
        local foot = Instance.new("TextLabel", root)
        foot.AnchorPoint = Vector2.new(0.5, 1)
        foot.Position = UDim2.new(0.5, 0, 1, -22)
        foot.Size = UDim2.new(0, 300, 0, 14)
        foot.BackgroundTransparency = 1
        foot.Text = "TUTUZX RUBY  •  v9"
        foot.TextColor3 = Color3.fromRGB(100, 106, 130)
        foot.Font = Enum.Font.Code
        foot.TextSize = 10

        local stages = {
            {0, "Iniciando nucleo"}, {0.15, "Carregando interface"}, {0.32, "Montando abas e modulos"},
            {0.5, "Sincronizando HUD"}, {0.68, "Conectando funcoes"}, {0.84, "Aplicando tema"}, {0.95, "Finalizando"},
        }
        local logLines = {}
        local function pushLog(txt)
            logLines[#logLines + 1] = "[ OK ] " .. txt
            for i = 1, 3 do
                local idx = #logLines - 3 + i
                logs[i].Text = logLines[idx] or ""
            end
        end

        local function finish()
            status.Text = "ACESSO LIBERADO"
            status.TextColor3 = GOOD
            pct.Text = "100%"
            fill.Size = UDim2.new(1, 0, 1, 0)
            tween(bscale, 0.5, {Scale = 1.12})
            task.wait(0.45)
            tween(root, 0.45, {GroupTransparency = 1})
            task.wait(0.5)
            pcall(function() root:Destroy() end)
            LD.root = nil
            LD.done = true
            if LD.onDone then LD.onDone() end
        end

        LD.root = root
        LD.done = false
        task.spawn(function()
            local t, stage, failT, spin, beamY = 0, 0, 0, 0, 0
            pushLog("nucleo carregado")
            while root.Parent do
                local dt = math.min(RunService.RenderStepped:Wait(), 0.05)
                spin = spin + dt * 110
                outer.Rotation = spin
                inner.Rotation = -spin * 1.4
                beamY = (beamY + dt * 0.45) % 1
                beam.Position = UDim2.new(0, 0, beamY, 0)
                t = t + dt / 2.6
                local target = LD.ready and 1 or 0.9
                if not LD.ready then failT = failT + dt end
                local p = math.min(t, target)
                local sp = p * p * (3 - 2 * p)
                fill.Size = UDim2.new(sp, 0, 1, 0)
                pct.Text = math.floor(sp * 100) .. "%"
                local want = 1
                for i, s in ipairs(stages) do
                    if p >= s[1] then want = i end
                end
                if want > stage then
                    if stage > 0 then pushLog(stages[stage][2]) end
                    stage = want
                    status.Text = stages[stage][2] .. "..."
                end
                if failT > 10 then
                    status.Text = "Falha ao iniciar - toque para fechar"
                    status.TextColor3 = Color3.fromRGB(255, 90, 90)
                    root.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            pcall(function() root:Destroy() end)
                            LD.root, LD.done = nil, true
                        end
                    end)
                    return
                end
                if p >= 1 then
                    finish()
                    return
                end
            end
        end)
    end)
    if not ok then
        if rootRef then pcall(function() rootRef:Destroy() end) end
        LD.root, LD.done = nil, true
    end
end
task.wait()


local function loadImage()
    local canFile = writefile and isfile and getcustomasset
    if canFile then
        local ok1, ex = pcall(isfile, "tutuzx.png")
        if ok1 and ex then
            local ok2, a = pcall(getcustomasset, "tutuzx.png")
            if ok2 and a and a ~= "" then return a end
        end
        if IMAGE_URL ~= "" and http then
            local ok3, res = pcall(http, {Url = IMAGE_URL, Method = "GET"})
            if ok3 and res and res.StatusCode == 200 and res.Body then
                pcall(writefile, "tutuzx.png", res.Body)
                local ok4, a = pcall(getcustomasset, "tutuzx.png")
                if ok4 and a and a ~= "" then return a end
            end
        end
    end
    if IMAGE_ID ~= "" then return "rbxassetid://" .. IMAGE_ID end
    return nil
end
local IMG = nil
pcall(function() IMG = loadImage() end)

------------------------------------------------------------
-- estado compartilhado
------------------------------------------------------------
local custom = {}
local flyOn, flySpeed = false, 60
local noclip, infJump, spinOn, spinSpeed = false, false, false, 10
local fbOn, fogOff, shadowOff = false, false, false
local animSpeed = 1
local afkOn = false
local espNames, espBox, espLines, espFromScreen = false, false, false, false
local espMax = 2000
local espColor = ORANGE
local stopFly, clearESP, restoreLight, clearShaders, closeScript
local TX = {bub = 60, startMin = false, cleanups = {}}

local function getHum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local sound = Instance.new("Sound")
sound.Name = "TutuSound"
sound.Looped = false
sound.Volume = 0.5
sound.Parent = workspace

------------------------------------------------------------
-- janela
------------------------------------------------------------
local FULL = UDim2.new(0.74, 0, 0.88, 0)
local menuLocked, borderSpin = false, true
local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = FULL
frame.BackgroundColor3 = Color3.new(1, 1, 1)
frame.Active = true
corner(frame, 14)
local menuScale = Instance.new("UIScale", frame)
local maxc = Instance.new("UISizeConstraint", frame)
maxc.MaxSize = Vector2.new(720, 430)
maxc.MinSize = Vector2.new(420, 230)
local grad = Instance.new("UIGradient", frame)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 22, 42)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(9, 11, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 26, 46))
})
grad.Rotation = 45
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.new(1, 1, 1)
stroke.Thickness = 1.5
local sg = Instance.new("UIGradient", stroke)
sg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ACC),
    ColorSequenceKeypoint.new(0.5, PURPLE),
    ColorSequenceKeypoint.new(1, GREEN)
})

if IMG then
    local wall = Instance.new("ImageLabel", frame)
    wall.Size = UDim2.new(1, 0, 1, 0)
    wall.BackgroundTransparency = 1
    wall.Image = IMG
    wall.ImageTransparency = 0.75
    wall.ScaleType = Enum.ScaleType.Crop
    corner(wall, 14)
    TX.wall = wall
end

-- detalhes neon (listras no topo e linha de brilho embaixo)
for i = 0, -1 do
    local st = Instance.new("Frame", frame)
    st.Size = UDim2.new(0, 7, 0, 13)
    st.Position = UDim2.new(0.5, i * 13 - 20, 0, 8)
    st.Rotation = 25
    st.BackgroundColor3 = ACC
    st.BackgroundTransparency = 0.1 + i * 0.18
    st.BorderSizePixel = 0
end
local glowLine = Instance.new("Frame", frame)
glowLine.AnchorPoint = Vector2.new(0.5, 1)
glowLine.Position = UDim2.new(0.5, 0, 1, -2)
glowLine.Size = UDim2.new(0.45, 0, 0, 2)
glowLine.BackgroundColor3 = ACC
glowLine.BackgroundTransparency = 0.25
glowLine.BorderSizePixel = 0
corner(glowLine, 2)

do -- arrastar a janela pelo topo
    local dragging, startIn, startPos = false, nil, nil
    local header = Instance.new("Frame", frame)
    header.Size = UDim2.new(1, -110, 0, 46)
    header.BackgroundTransparency = 1
    header.Active = true
    header.InputBegan:Connect(function(i)
        if menuLocked then return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startIn, startPos = i.Position, frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    bind(UIS.InputChanged, function(i)
        if dragging and not menuLocked and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startIn
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

TX.titleFont = Enum.Font.GothamBlack
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(0, 175, 0, 24)
title.Position = UDim2.new(0, 14, 0, 4)
title.BackgroundTransparency = 1
title.Text = "TUTUZX - RUBY"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = TX.titleFont
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
local tgrad = Instance.new("UIGradient", title)
tgrad.Color = ColorSequence.new(ACC, Color3.fromRGB(255, 215, 222))

local sub = Instance.new("TextLabel", frame)
sub.Size = UDim2.new(0, 150, 0, 13)
sub.Position = UDim2.new(0, 15, 0, 29)
sub.BackgroundTransparency = 1
sub.RichText = true
sub.Text = 'v9 by Tutuzx <font color="#50dc82">●</font>'
sub.TextColor3 = Color3.fromRGB(140, 148, 175)
sub.Font = Enum.Font.GothamMedium
sub.TextSize = 10
sub.TextXAlignment = Enum.TextXAlignment.Left

local divider = Instance.new("Frame", frame)
divider.Size = UDim2.new(1, -24, 0, 1)
divider.Position = UDim2.new(0, 12, 0, 46)
divider.BackgroundColor3 = ACC
divider.BackgroundTransparency = 0.15
divider.BorderSizePixel = 0
local dvg = Instance.new("UIGradient", divider)
dvg.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.18, 0),
    NumberSequenceKeypoint.new(0.82, 0), NumberSequenceKeypoint.new(1, 1),
})

------------------------------------------------------------
-- visual futurista: HUD, cantos, scanlines e feixe de luz
------------------------------------------------------------
do
    -- scanlines (por cima de tudo, bem fracas, nao bloqueiam toque)
    local scan = Instance.new("Frame", frame)
    scan.Name = "Scan"
    scan.Position = UDim2.new(0, 6, 0, 50)
    scan.Size = UDim2.new(1, -12, 1, -56)
    scan.BackgroundTransparency = 1
    scan.ClipsDescendants = true
    scan.ZIndex = 2
    for i = 0, 59 do
        local l = Instance.new("Frame", scan)
        l.Position = UDim2.new(0, 0, i / 60, 0)
        l.Size = UDim2.new(1, 0, 0, 1)
        l.BackgroundColor3 = Color3.new(1, 1, 1)
        l.BackgroundTransparency = 0.965
        l.BorderSizePixel = 0
        l.ZIndex = 2
    end
    TX.scan = scan

    -- feixe de luz que varre a janela
    local beam = Instance.new("Frame", frame)
    beam.Name = "Beam"
    beam.Position = UDim2.new(0, 8, 0, 50)
    beam.Size = UDim2.new(1, -16, 0, 2)
    beam.BackgroundColor3 = ACC
    beam.BackgroundTransparency = 0.5
    beam.BorderSizePixel = 0
    beam.ZIndex = 3
    local bgr = Instance.new("UIGradient", beam)
    bgr.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    TX.beam, TX.beamOn = beam, true
    task.spawn(function()
        while gui.Parent do
            if TX.beamOn and frame.Visible then
                beam.Position = UDim2.new(0, 8, 0, 50)
                tween(beam, 3, {Position = UDim2.new(0, 8, 1, -14)}, Enum.EasingStyle.Linear)
                task.wait(3.8)
            else
                task.wait(0.5)
            end
        end
    end)

    -- cantos de HUD
    for _, c in ipairs({{0, 0}, {1, 0}, {0, 1}, {1, 1}}) do
        for _, horiz in ipairs({true, false}) do
            local b = Instance.new("Frame", frame)
            b.AnchorPoint = Vector2.new(c[1], c[2])
            b.Position = UDim2.new(c[1], c[1] == 0 and 5 or -5, c[2], c[2] == 0 and 5 or -5)
            b.Size = horiz and UDim2.new(0, 18, 0, 2) or UDim2.new(0, 2, 0, 18)
            b.BackgroundColor3 = ACC
            b.BorderSizePixel = 0
            b.ZIndex = 6
        end
    end

    -- HUD no topo: status, FPS, ping e jogadores
    local dot = Instance.new("Frame", frame)
    dot.Position = UDim2.new(0, 170, 0, 19)
    dot.Size = UDim2.new(0, 7, 0, 7)
    dot.BackgroundColor3 = GOOD
    dot.BorderSizePixel = 0
    corner(dot, 4)
    local hud = Instance.new("TextLabel", frame)
    hud.Position = UDim2.new(0, 184, 0, 11)
    hud.Size = UDim2.new(1, -300, 0, 22)
    hud.BackgroundTransparency = 1
    hud.Font = Enum.Font.Code
    hud.TextSize = 11
    hud.TextColor3 = Color3.fromRGB(170, 176, 202)
    hud.TextXAlignment = Enum.TextXAlignment.Left
    hud.TextTruncate = Enum.TextTruncate.AtEnd
    hud.Text = "ONLINE"
    TX.hud, TX.hudDot = hud, dot
    local fpsE, pingV = 60, 0
    bind(RunService.RenderStepped, function(dt)
        fpsE = fpsE * 0.92 + (1 / math.max(dt, 0.001)) * 0.08
    end)
    task.spawn(function()
        while gui.Parent do
            pcall(function()
                pingV = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            if hud.Visible then
                hud.Text = "ONLINE  " .. math.floor(fpsE + 0.5) .. "FPS  " .. math.floor(pingV) .. "ms  " .. #Players:GetPlayers() .. "P"
            end
            tween(dot, 0.6, {BackgroundTransparency = 0.75})
            task.wait(0.6)
            tween(dot, 0.6, {BackgroundTransparency = 0})
            task.wait(0.6)
        end
    end)
end


------------------------------------------------------------
-- bolinha
------------------------------------------------------------
local bubble = Instance.new("TextButton", gui)
bubble.AnchorPoint = Vector2.new(0.5, 0.5)
bubble.Size = UDim2.new(0, 60, 0, 60)
bubble.Position = UDim2.new(0, 52, 0.5, 0)
bubble.BackgroundColor3 = Color3.new(1, 1, 1)
bubble.Text = ""
bubble.AutoButtonColor = false
bubble.Visible = false
bubble.Draggable = true
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)
local bgrad = Instance.new("UIGradient", bubble)
bgrad.Color = ColorSequence.new(Color3.fromRGB(130, 15, 45), ACC)
bgrad.Rotation = 45
local bstroke = Instance.new("UIStroke", bubble)
bstroke.Color = Color3.new(1, 1, 1)
bstroke.Thickness = 2
local bsg = Instance.new("UIGradient", bstroke)
bsg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ACC),
    ColorSequenceKeypoint.new(0.5, GREEN),
    ColorSequenceKeypoint.new(1, PURPLE)
})
local glow = Instance.new("Frame", bubble)
glow.AnchorPoint = Vector2.new(0.5, 0.5)
glow.Position = UDim2.new(0.5, 0, 0.5, 0)
glow.Size = UDim2.new(1.45, 0, 1.45, 0)
glow.BackgroundColor3 = ACC
glow.BackgroundTransparency = 0.8
glow.BorderSizePixel = 0
glow.ZIndex = 1
Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)
if IMG then
    local bimg = Instance.new("ImageLabel", bubble)
    bimg.AnchorPoint = Vector2.new(0.5, 0.5)
    bimg.Position = UDim2.new(0.5, 0, 0.5, 0)
    bimg.Size = UDim2.new(1, -10, 1, -10)
    bimg.BackgroundTransparency = 1
    bimg.Image = IMG
    bimg.ScaleType = Enum.ScaleType.Crop
    bimg.ZIndex = 2
    Instance.new("UICorner", bimg).CornerRadius = UDim.new(1, 0)
else
    local bl = Instance.new("TextLabel", bubble)
    bl.Size = UDim2.new(1, 0, 1, 0)
    bl.BackgroundTransparency = 1
    bl.Text = "TX"
    bl.TextColor3 = Color3.new(1, 1, 1)
    bl.Font = TX.titleFont
    bl.TextSize = 17
    bl.ZIndex = 2
end

local function openMenu()
    bubble.Visible = false
    frame.Size = UDim2.new(0.5, 0, 0.5, 0)
    frame.Visible = true
    tween(frame, 0.3, {Size = FULL}, Enum.EasingStyle.Back)
end
local function closeMenu()
    tween(frame, 0.18, {Size = UDim2.new(0.4, 0, 0.4, 0)})
    task.delay(0.2, function()
        frame.Visible = false
        bubble.Visible = true
    end)
end
local downPos = Vector2.new(0, 0)
bubble.MouseButton1Down:Connect(function() downPos = bubble.AbsolutePosition end)
bubble.MouseButton1Click:Connect(function()
    if (bubble.AbsolutePosition - downPos).Magnitude < 8 then openMenu() end
end)

do
    local r = 0
    bind(RunService.RenderStepped, function(dt)
        if borderSpin then
            r = (r + 120 * dt) % 360
            sg.Rotation = r
            bsg.Rotation = 360 - r
        end
    end)
end
task.spawn(function()
    while bubble.Parent do
        if bubble.Visible then
            tween(bubble, 0.8, {Size = UDim2.new(0, TX.bub + 6, 0, TX.bub + 6)}, Enum.EasingStyle.Sine)
            task.wait(0.8)
            tween(bubble, 0.8, {Size = UDim2.new(0, TX.bub, 0, TX.bub)}, Enum.EasingStyle.Sine)
            task.wait(0.8)
        else
            task.wait(0.5)
        end
    end
end)

------------------------------------------------------------
-- componentes
------------------------------------------------------------
local function press(b)
    b.MouseButton1Down:Connect(function() tween(b, 0.08, {BackgroundTransparency = 0.45}) end)
    b.MouseButton1Up:Connect(function() tween(b, 0.18, {BackgroundTransparency = 0}) end)
    b.MouseLeave:Connect(function() tween(b, 0.18, {BackgroundTransparency = 0}) end)
end
local function mk(parent, txt, color, cb)
    local b = Instance.new("TextButton", parent)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextStrokeColor3 = Color3.new(0, 0, 0)
    b.TextStrokeTransparency = 0.6
    b.AutoButtonColor = false
    corner(b, 8)
    local bst = Instance.new("UIStroke", b)
    bst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bst.Color = Color3.new(1, 1, 1)
    bst.Transparency = 0.85
    bst.Thickness = 1
    b.MouseButton1Click:Connect(cb)
    press(b)
    return b
end

local minBtn = mk(frame, "—", MID, closeMenu)
minBtn.Size = UDim2.new(0, 38, 0, 26)
minBtn.Position = UDim2.new(1, -94, 0, 9)
minBtn.TextSize = 16
local xArmed = false
local xBtn
xBtn = mk(frame, "✕", Color3.fromRGB(120, 30, 70), function()
    if not xArmed then
        xArmed = true
        xBtn.Text = "?"
        task.delay(2, function()
            xArmed = false
            pcall(function() xBtn.Text = "✕" end)
        end)
    elseif closeScript then
        closeScript()
    end
end)
xBtn.Size = UDim2.new(0, 38, 0, 26)
xBtn.Position = UDim2.new(1, -50, 0, 9)
xBtn.TextSize = 14

local function mkScroll(parent)
    local s = Instance.new("ScrollingFrame", parent)
    s.Size = UDim2.new(1, 0, 1, 0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 3
    s.ScrollBarImageColor3 = ACC
    s.ScrollBarImageTransparency = 0.2
    s.CanvasSize = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    s.ScrollingDirection = Enum.ScrollingDirection.Y
    local pad = Instance.new("UIPadding", s)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 16)
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 14)
    local lay = Instance.new("UIListLayout", s)
    lay.Padding = UDim.new(0, 8)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    return s
end

local function mkMsg(parent, txt)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, 0, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(235, 238, 250)
    l.Font = Enum.Font.Code
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.LayoutOrder = nextOrder(parent)
    return l
end

local function mkBox(parent, ph)
    local b = Instance.new("TextBox", parent)
    b.BackgroundColor3 = MID
    b.BackgroundTransparency = 0.1
    b.PlaceholderText = ph
    b.PlaceholderColor3 = Color3.fromRGB(135, 142, 168)
    b.Text = ""
    b.ClearTextOnFocus = false
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    corner(b, 8)
    local st = Instance.new("UIStroke", b)
    st.Color = ACC
    st.Transparency = 0.45
    st.Thickness = 1
    return b
end

local function rowFrame(parent, h)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, h)
    f.BackgroundTransparency = 1
    f.LayoutOrder = nextOrder(parent)
    return f
end

local function mkRow(parent, name, rightText, onClick)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = MID
    row.BackgroundTransparency = 0.12
    row.LayoutOrder = nextOrder(parent)
    corner(row, 8)
    local rs = Instance.new("UIStroke", row)
    rs.Color = ACC
    rs.Transparency = 0.8
    rs.Thickness = 1
    local pb = Instance.new("TextButton", row)
    pb.Size = UDim2.new(1, 0, 1, 0)
    pb.BackgroundTransparency = 1
    pb.Text = tostring(name)
    pb.TextColor3 = Color3.new(1, 1, 1)
    pb.Font = Enum.Font.GothamMedium
    pb.TextSize = 14
    pb.TextXAlignment = Enum.TextXAlignment.Left
    pb.TextTruncate = Enum.TextTruncate.AtEnd
    local pad = Instance.new("UIPadding", pb)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 80)
    pb.MouseButton1Down:Connect(function() tween(row, 0.08, {BackgroundColor3 = ACC, BackgroundTransparency = 0.55}) end)
    pb.MouseButton1Up:Connect(function() tween(row, 0.2, {BackgroundColor3 = MID, BackgroundTransparency = 0.12}) end)
    pb.MouseLeave:Connect(function() tween(row, 0.2, {BackgroundColor3 = MID, BackgroundTransparency = 0.12}) end)
    pb.MouseButton1Click:Connect(onClick)
    local lab = Instance.new("TextLabel", row)
    lab.BackgroundTransparency = 1
    lab.Text = tostring(rightText)
    lab.TextColor3 = ACC
    lab.Font = Enum.Font.GothamBold
    lab.TextSize = 12
    lab.TextXAlignment = Enum.TextXAlignment.Right
    local lc = Instance.new("UICorner", lab)
    lc.CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", lab)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Visible = false
    corner(knob, 8)
    local first = true
    local function skin()
        local t = lab.Text
        if t == "ON" or t == "OFF" then
            local on = (t == "ON")
            lab.Size = UDim2.new(0, 44, 0, 24)
            lab.Position = UDim2.new(1, -56, 0.5, -12)
            lab.TextTransparency = 1
            lab.BackgroundTransparency = 0
            lab.BackgroundColor3 = on and ACC or Color3.fromRGB(42, 48, 72)
            knob.Visible = true
            local goal = on and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
            if first then knob.Position = goal else tween(knob, 0.15, {Position = goal}) end
        else
            lab.Size = UDim2.new(0, 70, 1, 0)
            lab.Position = UDim2.new(1, -78, 0, 0)
            lab.TextTransparency = 0
            lab.BackgroundTransparency = 1
            knob.Visible = false
        end
        first = false
    end
    lab:GetPropertyChangedSignal("Text"):Connect(skin)
    skin()
    return row, lab
end

local function toggleRow(parent, name, fn)
    local state = false
    local lab
    local _
    _, lab = mkRow(parent, name, "OFF", function()
        state = not state
        lab.Text = state and "ON" or "OFF"
        lab.TextColor3 = state and GOOD or ACC
        fn(state)
        if TX.notify then TX.notify(tostring(name) .. (state and "  ON" or "  OFF")) end
    end)
end

local function stepper(parent, name, init, step, min, max, onChange)
    local val = init
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = MID
    row.BackgroundTransparency = 0.25
    row.LayoutOrder = nextOrder(parent)
    corner(row, 8)
    local rs = Instance.new("UIStroke", row)
    rs.Color = ACC
    rs.Transparency = 0.78
    rs.Thickness = 1
    local bar = Instance.new("Frame", row)
    bar.Size = UDim2.new(0, 3, 0.56, 0)
    bar.Position = UDim2.new(0, 5, 0.22, 0)
    bar.BackgroundColor3 = ACC
    bar.BorderSizePixel = 0
    corner(bar, 2)
    local lab = Instance.new("TextLabel", row)
    lab.Size = UDim2.new(1, -112, 1, 0)
    lab.Position = UDim2.new(0, 18, 0, 0)
    lab.BackgroundTransparency = 1
    lab.TextColor3 = Color3.new(1, 1, 1)
    lab.Font = Enum.Font.GothamMedium
    lab.TextSize = 14
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.TextTruncate = Enum.TextTruncate.AtEnd
    local function set(v, silent)
        val = math.clamp(math.floor(v * 100 + 0.5) / 100, min, max)
        lab.Text = name .. ": " .. tostring(val)
        if not silent then onChange(val) end
    end
    local m = mk(row, "-", ACC, function() set(val - step) end)
    m.Size = UDim2.new(0, 34, 0, 32)
    m.Position = UDim2.new(1, -82, 0.5, -16)
    m.TextSize = 18
    local p = mk(row, "+", ACC, function() set(val + step) end)
    p.Size = UDim2.new(0, 34, 0, 32)
    p.Position = UDim2.new(1, -44, 0.5, -16)
    p.TextSize = 18
    set(init, true)
    return set
end

------------------------------------------------------------
-- registro de funcoes (alimenta Busca global e Favoritos)
------------------------------------------------------------
local REG = {list = {}, allowed = {}, on = true}
REG.add = function(parent, name, row, click, lab)
    if not REG.on or not REG.allowed[parent] then return end
    REG.list[#REG.list + 1] = {name = tostring(name), parent = parent, row = row, click = click, lab = lab}
end
do
    local baseRow, baseStepper = mkRow, stepper
    mkRow = function(parent, name, rightText, onClick)
        local row, lab = baseRow(parent, name, rightText, onClick)
        REG.add(parent, name, row, onClick, lab)
        return row, lab
    end
    stepper = function(parent, name, init, step, min, max, onChange)
        local set = baseStepper(parent, name, init, step, min, max, onChange)
        if REG.on and REG.allowed[parent] then
            local n = parent:GetAttribute("n")
            for _, c in ipairs(parent:GetChildren()) do
                if c:IsA("Frame") and c.LayoutOrder == n then
                    REG.add(parent, name, c, nil, nil)
                    break
                end
            end
        end
        return set
    end
end

------------------------------------------------------------
-- paginas e abas
------------------------------------------------------------
local content = Instance.new("Frame", frame)
content.Position = UDim2.new(0, 178, 0, 54)
content.Size = UDim2.new(1, -190, 1, -68)
content.BackgroundColor3 = Color3.fromRGB(9, 11, 20)
content.BackgroundTransparency = 0.2
content.ClipsDescendants = true
corner(content, 10)
local cstroke = Instance.new("UIStroke", content)
cstroke.Color = ACC
cstroke.Transparency = 0.55
cstroke.Thickness = 1.2

local function mkPage()
    local p = Instance.new("Frame", content)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    return p, mkScroll(p)
end
local persoPage, ps = mkPage()
local musicPage, ms = mkPage()
local modsPage, mo = mkPage()
local dancePage, ds = mkPage()
local chatPage, cs = mkPage()
local overboardPage, os = mkPage()
local gamesPage, gs = mkPage()
local calcPage, calcs = mkPage()
local configPage, cfs = mkPage()
local UI = {}
UI.favPage, UI.favs = mkPage()
UI.searchPage, UI.srs = mkPage()
UI.notesPage, UI.ns = mkPage()
UI.timerPage, UI.tms = mkPage()
UI.convPage, UI.cvs = mkPage()
UI.credPage, UI.creds = mkPage()
UI.updPage, UI.upds = mkPage()
UI.plrPage, UI.plrs = mkPage()
UI.extPage, UI.exts = mkPage()
UI.carPage, UI.cars = mkPage()
UI.rgbPage, UI.rgbs = mkPage()
UI.protPage, UI.prots = mkPage()
UI.tpPage, UI.tps = mkPage()
UI.scrPage, UI.scrs = mkPage()
local pages = {UI.favPage, UI.searchPage, persoPage, musicPage, modsPage, dancePage, chatPage, overboardPage, gamesPage, calcPage, UI.notesPage, UI.timerPage, UI.convPage, configPage, UI.credPage, UI.updPage, UI.plrPage, UI.extPage, UI.carPage, UI.rgbPage, UI.protPage, UI.tpPage, UI.scrPage}
for _, sc in ipairs({ps, mo, os, ds, cfs, UI.plrs, UI.exts, UI.cars, UI.rgbs, UI.prots, UI.tps, UI.scrs}) do REG.allowed[sc] = true end

local side = Instance.new("ScrollingFrame", frame)
side.Position = UDim2.new(0, 10, 0, 54)
side.Size = UDim2.new(0, 160, 1, -68)
side.BackgroundTransparency = 1
side.BorderSizePixel = 0
side.ScrollBarThickness = 0
side.CanvasSize = UDim2.new(0, 0, 0, 0)
side.AutomaticCanvasSize = Enum.AutomaticSize.Y
side.ScrollingDirection = Enum.ScrollingDirection.Y
local sideLay = Instance.new("UIListLayout", side)
sideLay.Padding = UDim.new(0, 6)
sideLay.SortOrder = Enum.SortOrder.LayoutOrder
local sidePad = Instance.new("UIPadding", side)
sidePad.PaddingTop = UDim.new(0, 2)
sidePad.PaddingBottom = UDim.new(0, 4)
sidePad.PaddingLeft = UDim.new(0, 2)
sidePad.PaddingRight = UDim.new(0, 2)

local tabBtns = {}
TX.tabx = {bars = {}, strokes = {}, names = {}, first = true}
local function showTab(n)
    for i, p in ipairs(pages) do
        local on = (i == n)
        if on and not p.Visible and not TX.tabx.first then
            p.Position = UDim2.new(0, 16, 0, 0)
            tween(p, 0.22, {Position = UDim2.new(0, 0, 0, 0)})
        end
        p.Visible = on
    end
    TX.tabx.first = false
    for i, b in ipairs(tabBtns) do
        local on = (i == n)
        tween(b, 0.15, {BackgroundColor3 = on and ACC or MID, BackgroundTransparency = on and 0.08 or 0.2})
        local s, br, nm = TX.tabx.strokes[i], TX.tabx.bars[i], TX.tabx.names[i]
        if s then tween(s, 0.15, {Transparency = on and 0.05 or 0.75}) end
        if br then tween(br, 0.15, {BackgroundTransparency = on and 0 or 1}) end
        if nm then nm.TextColor3 = on and Color3.new(1, 1, 1) or Color3.fromRGB(175, 182, 205) end
    end
end
local tabInfo = {
    {"FAVORITOS", "⭐", 12}, {"BUSCA", "🔎", 13},
    {"PERSO", "👤", 13}, {"MUSIC", "🎵", 13}, {"MODS", "🧩", 13}, {"DANÇA", "💃", 13},
    {"GEMINI", "✦", 13}, {"OVERBOARD", "🚀", 13}, {"JOGOS", "🎮", 13}, {"CALCULADORA", "🧮", 11},
    {"NOTAS", "📝", 13}, {"CRONÔMETRO", "⏱", 11}, {"CONVERSOR", "🔄", 12},
    {"CONFIGURAÇÕES", "⚙", 10},
    {"CRÉDITOS", "💎", 13}, {"UPDATE", "🔔", 13}, {"JOGADOR", "👤", 13}, {"EXTRA", "✦", 13},
    {"CAR", "🚗", 13}, {"RGB", "🎨", 13}, {"PROTEÇÃO", "🛡", 13}, {"TELEPORTE", "📍", 12}, {"SCRIPTS", "📜", 13},
}
local GROUPS = {}
for i, inf in ipairs(tabInfo) do
    if GROUPS[i] then
        local gl = Instance.new("TextLabel", side)
        gl.Size = UDim2.new(1, 0, 0, 14)
        gl.BackgroundTransparency = 1
        gl.Text = GROUPS[i]
        gl.TextColor3 = Color3.fromRGB(110, 116, 140)
        gl.Font = Enum.Font.Code
        gl.TextSize = 10
        gl.TextXAlignment = Enum.TextXAlignment.Left
        gl.LayoutOrder = i * 10 - 5
    end
    local b = Instance.new("TextButton", side)
    b.Size = UDim2.new(1, 0, 0, 38)
    b.BackgroundColor3 = MID
    b.BackgroundTransparency = 0.2
    b.Text = ""
    b.AutoButtonColor = false
    b.LayoutOrder = i * 10
    corner(b, 8)
    local bs = Instance.new("UIStroke", b)
    bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bs.Color = ACC
    bs.Transparency = 0.75
    bs.Thickness = 1
    local lb = Instance.new("Frame", b)
    lb.Size = UDim2.new(0, 3, 0, 20)
    lb.Position = UDim2.new(0, 2, 0.5, -10)
    lb.BackgroundColor3 = ACC
    lb.BackgroundTransparency = 1
    lb.BorderSizePixel = 0
    corner(lb, 2)
    local ic = Instance.new("TextLabel", b)
    ic.Size = UDim2.new(0, 30, 1, 0)
    ic.Position = UDim2.new(0, 8, 0, 0)
    ic.BackgroundTransparency = 1
    ic.Text = inf[2]
    ic.TextColor3 = Color3.fromRGB(232, 236, 250)
    ic.Font = Enum.Font.GothamBold
    ic.TextSize = 17
    local nm = Instance.new("TextLabel", b)
    nm.Size = UDim2.new(1, -62, 1, 0)
    nm.Position = UDim2.new(0, 40, 0, 0)
    nm.BackgroundTransparency = 1
    nm.Text = inf[1]
    nm.TextColor3 = Color3.fromRGB(175, 182, 205)
    nm.Font = Enum.Font.GothamMedium
    nm.TextSize = math.clamp(math.floor(88 / ((utf8.len(inf[1]) or #inf[1]) * 0.68)), 9, 12)
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.TextTruncate = Enum.TextTruncate.AtEnd
    local ix = Instance.new("TextLabel", b)
    ix.Size = UDim2.new(0, 22, 1, 0)
    ix.Position = UDim2.new(1, -26, 0, 0)
    ix.BackgroundTransparency = 1
    ix.Text = "›"
    ix.TextColor3 = Color3.fromRGB(110, 116, 140)
    ix.Font = Enum.Font.GothamBold
    ix.TextSize = 18
    ix.TextXAlignment = Enum.TextXAlignment.Right
    b.MouseButton1Click:Connect(function() showTab(i) end)
    tabBtns[i] = b
    TX.tabx.bars[i], TX.tabx.strokes[i], TX.tabx.names[i] = lb, bs, nm
end


------------------------------------------------------------
-- ABA OVERBOARD: controles e musicas integrados ao Tutuzx
------------------------------------------------------------
do
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local overboardLoop, overboardPaused, overboardLastId = false, false, nil

    local function hoverboardPlay(id)
        local ok = false
        pcall(function()
            local re = ReplicatedStorage:FindFirstChild("RE")
            local remote = re and re:FindFirstChild("1NoMoto1rVehicle1s")
            if remote then
                remote:FireServer("PickingScooterMusicText", tostring(id))
                ok = true
            end
        end)
        return ok
    end

    local function pauseCharacterSounds()
        overboardPaused, overboardLoop = true, false
        pcall(function()
            local char = lp.Character
            if char then
                for _, obj in ipairs(char:GetDescendants()) do
                    if obj:IsA("Sound") and obj.IsPlaying then obj:Pause() end
                end
            end
        end)
    end

    local function resumeCharacterSounds()
        overboardPaused = false
        pcall(function()
            local char = lp.Character
            if char then
                for _, obj in ipairs(char:GetDescendants()) do
                    if obj:IsA("Sound") and not obj.IsPlaying then obj:Resume() end
                end
            end
        end)
        if overboardLastId then hoverboardPlay(overboardLastId) end
    end

    local overboardSongs = {
        {Nome = "Phonk popular", ID = 9636876193},
        {Nome = "Funk (teste)", ID = 1848354536},
        {Nome = "Sirene Nuclear", ID = 675587093},
        {Nome = "Risada de John", ID = 130759239},
        {Nome = "Sonic.exe", ID = 2496367477},
        {Nome = "SUS", ID = 7153419575},
        {Nome = "Gritao", ID = 5853668794},
        {Nome = "Estora tímpano", ID = 268116333},
        {Nome = "AAAHHHH", ID = 9084006093},
        {Nome = "Áudio Alto", ID = 6855150757},
    }

    mkMsg(os, "OVERBOARD  •  música do veículo")
    local idBox = mkBox(os, "Digite o ID da música")
    idBox.Size = UDim2.new(1, 0, 0, 38)
    idBox.LayoutOrder = nextOrder(os)
    local status = mkMsg(os, "Selecione uma música ou digite um ID")

    local playBtn = mk(os, "TOCAR NO OVERBOARD", ACC, function()
        local id = tonumber(idBox.Text)
        if not id then status.Text = "Digite um ID numérico válido." return end
        overboardLastId = id
        status.Text = hoverboardPlay(id) and ("Solicitado: " .. tostring(id)) or "Remote do veículo não encontrado."
    end)
    playBtn.Size = UDim2.new(1, 0, 0, 38)
    playBtn.LayoutOrder = nextOrder(os)

    local loopBtn
    loopBtn = mk(os, "LOOP: OFF", MID, function()
        overboardLoop = not overboardLoop
        if overboardLoop then
            overboardPaused = false
            loopBtn.Text, loopBtn.BackgroundColor3 = "LOOP: ON", GOOD
            task.spawn(function()
                while overboardLoop and gui.Parent do
                    if not overboardPaused then
                        local id = tonumber(idBox.Text)
                        if id then overboardLastId = id hoverboardPlay(id) end
                    end
                    task.wait(1)
                end
            end)
        else
            loopBtn.Text, loopBtn.BackgroundColor3 = "LOOP: OFF", MID
        end
    end)
    loopBtn.Size = UDim2.new(1, 0, 0, 36)
    loopBtn.LayoutOrder = nextOrder(os)

    local controls = rowFrame(os, 38)
    local pauseBtn = mk(controls, "PAUSAR", Color3.fromRGB(150, 90, 30), function()
        if not overboardLastId then status.Text = "Nenhuma música selecionada." return end
        pauseCharacterSounds()
        loopBtn.Text, loopBtn.BackgroundColor3 = "LOOP: OFF", MID
        status.Text = "Pausado."
    end)
    pauseBtn.Size = UDim2.new(0.49, 0, 1, 0)
    local resumeBtn = mk(controls, "RETOMAR", Color3.fromRGB(150, 30, 70), function()
        if not overboardPaused then status.Text = "A música não está pausada." return end
        resumeCharacterSounds()
        status.Text = overboardLastId and ("Retomada: " .. tostring(overboardLastId)) or "Retomado."
    end)
    resumeBtn.Size = UDim2.new(0.49, 0, 1, 0)
    resumeBtn.Position = UDim2.new(0.51, 0, 0, 0)

    local stopBtn = mk(os, "PARAR LOOP / LIMPAR ESTADO", RED, function()
        overboardLoop, overboardPaused, overboardLastId = false, false, nil
        loopBtn.Text, loopBtn.BackgroundColor3 = "LOOP: OFF", MID
        status.Text = "Loop desligado e seleção limpa."
    end)
    stopBtn.Size = UDim2.new(1, 0, 0, 36)
    stopBtn.LayoutOrder = nextOrder(os)

    mkMsg(os, "LISTA DE MÚSICAS  •  toque para selecionar")
    for _, song in ipairs(overboardSongs) do
        mkRow(os, song.Nome, tostring(song.ID), function()
            idBox.Text = tostring(song.ID)
            status.Text = "Selecionada: " .. song.Nome
        end)
    end
end

------------------------------------------------------------
-- ABA MUSICAS  (igual a versao anterior)
------------------------------------------------------------
do
local cats = {
    {"Mix", {
        "Bum Bum Tam Tam MC Fioti", "Baile de Favela MC Joao",
        "Que Tiro Foi Esse Jojo Todynho", "Dona de Mim IZA",
        "Pesadao IZA Marcelo Falcao", "Vai Malandra Anitta",
        "Envolver Anitta", "Show das Poderosas Anitta",
        "Sua Cara Major Lazer Anitta", "Rave de Favela MC Lan",
        "Dancarina MC Pedrinho", "Lovezinho Treyce",
        "Jenifer Gabriel Diniz", "Loka Simone e Simaria",
        "Regime Fechado Simone e Simaria", "Medo Bobo Maiara e Maraisa",
        "Batom de Cereja Israel e Rodolffo", "Notificacao Preferida Ze Neto e Cristiano",
        "Camaro Amarelo Munhoz e Mariano", "Facas Diego e Victor Hugo",
        "Zona de Perigo Leo Santana", "Lepo Lepo Psirico",
        "Cheia de Manias Raca Negra", "Infiel Marilia Mendonca",
        "Evidencias Chitaozinho e Xororo", "Ai Se Eu Te Pego Michel Telo",
        "Meteoro Luan Santana", "Balada Gusttavo Lima",
        "Flor e o Beija-Flor Henrique e Juliano", "Parabens Pabllo Vittar",
        "Olha a Explosao MC Kevinho", "Verdinha Ludmilla",
        "Zoio de Lula Charlie Brown Jr", "Garota Nacional Skank",
        "Mulher de Fases Raimundos", "Garota de Ipanema",
        "Mas que Nada Jorge Ben Jor", "Trevo Anavitoria",
        "Dias Melhores Jota Quest", "Pra Te Ver Matheus e Kauan"
    }},
    {"Funk", {
        "Deu Onda MC G15", "Bola Rebola Anitta", "Bum Bum Tam Tam MC Fioti",
        "Baile de Favela MC Joao", "Rave de Favela MC Lan",
        "Olha a Explosao MC Kevinho", "Dancarina MC Pedrinho",
        "Vai Malandra Anitta", "Que Tiro Foi Esse Jojo Todynho",
        "Fazer Falta MC Livinho", "Funk 2024", "Funk Mandelao",
        "Funk Rave", "Funk Consciente", "Funk Proibidao",
        "Funk Carioca", "Funk 150 bpm", "Baile Funk",
        "Funk Remix", "Montagem Funk", "Funk Brasileiro",
        "Funk Melody", "Funk Ostentacao", "Funk Pesado"
    }},
    {"Sertan", {
        "Evidencias Chitaozinho e Xororo", "Ai Se Eu Te Pego Michel Telo",
        "Meteoro Luan Santana", "Balada Gusttavo Lima",
        "Flor e o Beija-Flor Henrique e Juliano", "Infiel Marilia Mendonca",
        "Medo Bobo Maiara e Maraisa", "Batom de Cereja Israel e Rodolffo",
        "Notificacao Preferida Ze Neto e Cristiano", "Camaro Amarelo Munhoz e Mariano",
        "Facas Diego e Victor Hugo", "Pra Te Ver Matheus e Kauan",
        "Propaganda Jorge e Mateus", "Largado as Tracas Ze Neto e Cristiano",
        "Tudo Que Voce Quiser Luan Santana", "Jenifer Gabriel Diniz",
        "Loka Simone e Simaria", "Regime Fechado Simone e Simaria",
        "Sertanejo Universitario", "Modao Sertanejo", "Sofrencia",
        "Sertanejo Raiz", "Sertanejo Romantico", "Sertanejo Cantoras"
    }},
    {"Pagode", {
        "Deixa a Vida Me Levar Zeca Pagodinho", "Vou Festejar Beth Carvalho",
        "Camisa 10 Turma do Pagode", "Se Joga Grupo Revelacao",
        "Deixa Acontecer Grupo Revelacao", "Cheia de Manias Raca Negra",
        "Sorriso Maroto", "Thiaguinho", "Pericles", "Exaltasamba",
        "Menos e Mais", "Ferrugem", "Belo", "Dilsinho",
        "Pagode 90", "Pagode Romantico", "Pagode Churrasco",
        "Roda de Samba", "Samba Enredo", "Pagode 2024"
    }},
    {"Pop", {
        "Blinding Lights The Weeknd", "Shape of You Ed Sheeran",
        "Bad Guy Billie Eilish", "Levitating Dua Lipa",
        "Dance Monkey Tones and I", "Uptown Funk Bruno Mars",
        "Believer Imagine Dragons", "Shake It Off Taylor Swift",
        "Stay Kid Laroi", "As It Was Harry Styles",
        "Flowers Miley Cyrus", "Anti-Hero Taylor Swift",
        "Peaches Justin Bieber", "Havana Camila Cabello",
        "Senorita Shawn Mendes", "Despacito Luis Fonsi"
    }},
    {"Rock", {
        "Bohemian Rhapsody Queen", "Smells Like Teen Spirit Nirvana",
        "Back in Black ACDC", "Thunderstruck ACDC",
        "Sweet Child O Mine Guns N Roses", "Numb Linkin Park",
        "In the End Linkin Park", "Seven Nation Army White Stripes",
        "Pais e Filhos Legiao Urbana", "Tempo Perdido Legiao Urbana",
        "Exagerado Cazuza", "Ciumes Skank",
        "Detonautas Quando o Sol Bater", "Charlie Brown Jr Dias de Luta",
        "Capital Inicial Primeiros Erros", "Barao Vermelho Pro Dia Nascer Feliz"
    }},
    {"Rap", {
        "Lose Yourself Eminem", "Sicko Mode Travis Scott",
        "Gods Plan Drake", "HUMBLE Kendrick Lamar",
        "In Da Club 50 Cent", "Racionais Capitulo 4 Versiculo 3",
        "Sabotage Rap", "Djonga", "Matue", "Filipe Ret",
        "Orochi", "Haikaiss", "Xama", "Trap Brasileiro", "Rap Nacional"
    }},
    {"Eletro", {
        "Faded Alan Walker", "Titanium David Guetta",
        "Animals Martin Garrix", "Closer Chainsmokers",
        "Lean On Major Lazer", "Wake Me Up Avicii",
        "Levels Avicii", "Alone Marshmello",
        "Sandstorm Darude", "Alok Hear Me Now",
        "Vintage Culture", "Alok Eletronica", "House Music", "EDM Mix"
    }},
    {"Memes", {
        "Never Gonna Give You Up Rick Astley", "Megalovania Undertale",
        "Nyan Cat", "Sweden Minecraft", "Coffin Dance",
        "Crab Rave", "Gangnam Style", "Bad Apple",
        "Vine Boom", "Sad Violin", "Mission Impossible Theme",
        "Sigma Male Song", "Taco Bell Bong", "Meme Sound Effect"
    }},
    {"Phonk", {
        "Phonk Brasileiro", "Montagem Coral", "Montagem Tomada",
        "Funk Phonk Automotivo", "Automotivo Bass", "Phonk Drift",
        "Aggressive Phonk", "Memphis Phonk", "Montagem Xonada",
        "Sigma Phonk", "Montagem Mysterious Game", "Montagem Bandido"
    }},
}

local MARKET = "https://apis.roblox.com/toolbox-service/v1/marketplace/3?limit=30&keyword="
local DETAILS = "https://apis.roblox.com/toolbox-service/v1/items/details?assetIds="

local play, nextSong, prevSong
local showSaved, showRecent, showCategory
local queue, qIndex = {}, 0
local recent, savedSongs = {}, {}
local currentSong = nil
local token = 0
local idCache = {}

local now = mkMsg(ms, "Toque numa musica")

local sr = rowFrame(ms, 38)
local box = mkBox(sr, "Nome ou ID da musica")
box.Size = UDim2.new(1, -148, 1, 0)
local searchBtn = mk(sr, "Buscar", MID, function() end)
searchBtn.Size = UDim2.new(0, 68, 1, 0)
searchBtn.Position = UDim2.new(1, -142, 0, 0)
searchBtn.TextSize = 13
local goBtn = mk(sr, "Tocar", ACC, function() end)
goBtn.Size = UDim2.new(0, 70, 1, 0)
goBtn.Position = UDim2.new(1, -70, 0, 0)
goBtn.TextSize = 13

local cr = rowFrame(ms, 34)
local codeBox = mkBox(cr, "Codigo da musica")
codeBox.Size = UDim2.new(1, -150, 1, 0)
codeBox.TextColor3 = ACC
codeBox.Font = Enum.Font.GothamBold
local copyBtn = mk(cr, "Copiar", MID, function() end)
copyBtn.Size = UDim2.new(0, 70, 1, 0)
copyBtn.Position = UDim2.new(1, -144, 0, 0)
copyBtn.TextSize = 12
local saveBtn = mk(cr, "Salvar", Color3.fromRGB(40, 160, 90), function() end)
saveBtn.Size = UDim2.new(0, 70, 1, 0)
saveBtn.Position = UDim2.new(1, -70, 0, 0)
saveBtn.TextSize = 12

local ctr = rowFrame(ms, 36)
local function ctrBtn(i, txt, color, cb)
    local b = mk(ctr, txt, color, cb)
    b.Size = UDim2.new(0.2, -4, 1, 0)
    b.Position = UDim2.new((i - 1) * 0.2, 0, 0, 0)
    b.TextSize = 12
    return b
end
ctrBtn(1, "<", MID, function() prevSong() end)
local ppBtn
ppBtn = ctrBtn(2, "Play", ACC, function()
    if sound.SoundId == "" then return end
    if sound.IsPlaying then
        sound:Pause()
        ppBtn.Text = "Play"
    else
        sound:Play()
        ppBtn.Text = "Pause"
    end
end)
ctrBtn(3, ">", MID, function() nextSong() end)
ctrBtn(4, "Parar", RED, function()
    sound:Stop()
    ppBtn.Text = "Play"
    now.Text = "Parado"
end)
local loopBtn
loopBtn = ctrBtn(5, "Rep: OFF", MID, function()
    sound.Looped = not sound.Looped
    loopBtn.Text = sound.Looped and "Rep: ON" or "Rep: OFF"
    loopBtn.BackgroundColor3 = sound.Looped and ACC or MID
end)

local mx = {shuffleOn = false, queue = {}}
local showFila
do
local sleepEnd = nil
local ctr2 = rowFrame(ms, 34)
local function ctr2Btn(i, txt, color, cb)
    local b = mk(ctr2, txt, color, cb)
    b.Size = UDim2.new(0.25, -4, 1, 0)
    b.Position = UDim2.new((i - 1) * 0.25, 0, 0, 0)
    b.TextSize = 11
    return b
end
local shufBtn
shufBtn = ctr2Btn(1, "Shuffle: OFF", MID, function()
    mx.shuffleOn = not mx.shuffleOn
    shufBtn.Text = mx.shuffleOn and "Shuffle: ON" or "Shuffle: OFF"
    shufBtn.BackgroundColor3 = mx.shuffleOn and ACC or MID
end)
local sleepOpts, sleepIdx = {0, 15, 30, 45, 60, 90}, 1
local sleepBtn
sleepBtn = ctr2Btn(2, "Timer: OFF", MID, function()
    sleepIdx = sleepIdx % #sleepOpts + 1
    local m = sleepOpts[sleepIdx]
    if m == 0 then
        sleepEnd = nil
        sleepBtn.Text = "Timer: OFF"
        sleepBtn.BackgroundColor3 = MID
    else
        sleepEnd = tick() + m * 60
        sleepBtn.Text = "Timer " .. m .. "m"
        sleepBtn.BackgroundColor3 = ACC
    end
end)
ctr2Btn(3, "+ Fila", Color3.fromRGB(40, 160, 90), function()
    if not currentSong then
        now.Text = "Toque uma musica antes de por na fila"
        return
    end
    for _, s in ipairs(mx.queue) do
        if s[2] == currentSong[2] then
            now.Text = "Ja esta na fila"
            return
        end
    end
    mx.queue[#mx.queue + 1] = {currentSong[1], currentSong[2]}
    now.Text = "Na fila (" .. #mx.queue .. "): " .. currentSong[1]
end)
ctr2Btn(4, "Limpar fila", RED, function()
    for k = #mx.queue, 1, -1 do mx.queue[k] = nil end
    now.Text = "Fila limpa"
end)
task.spawn(function()
    while gui.Parent do
        if sleepEnd then
            local left = sleepEnd - tick()
            if left <= 0 then
                sleepEnd = nil
                sleepIdx = 1
                sound:Stop()
                ppBtn.Text = "Play"
                now.Text = "Temporizador: musica parada"
                sleepBtn.Text = "Timer: OFF"
                sleepBtn.BackgroundColor3 = MID
                if TX.notify then TX.notify("Temporizador: musica parada") end
            else
                sleepBtn.Text = string.format("Timer %d:%02d", math.floor(left / 60), math.floor(left % 60))
            end
        end
        task.wait(1)
    end
end)
end

local pr = rowFrame(ms, 34)
local timeLab = Instance.new("TextLabel", pr)
timeLab.Size = UDim2.new(1, 0, 0, 16)
timeLab.BackgroundTransparency = 1
timeLab.Text = "0:00 / 0:00"
timeLab.TextColor3 = Color3.fromRGB(195, 200, 222)
timeLab.Font = Enum.Font.Gotham
timeLab.TextSize = 12
timeLab.TextXAlignment = Enum.TextXAlignment.Right
local hit = Instance.new("TextButton", pr)
hit.Size = UDim2.new(1, 0, 0, 18)
hit.Position = UDim2.new(0, 0, 0, 16)
hit.BackgroundTransparency = 1
hit.Text = ""
local barBg = Instance.new("Frame", hit)
barBg.Size = UDim2.new(1, 0, 0, 8)
barBg.Position = UDim2.new(0, 0, 0.5, -4)
barBg.BackgroundColor3 = MID
barBg.BorderSizePixel = 0
corner(barBg, 4)
local barFill = Instance.new("Frame", barBg)
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = ACC
barFill.BorderSizePixel = 0
corner(barFill, 4)
hit.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        local w = barBg.AbsoluteSize.X
        if w > 0 and sound.TimeLength > 0 then
            local frac = math.clamp((i.Position.X - barBg.AbsolutePosition.X) / w, 0, 1)
            sound.TimePosition = frac * sound.TimeLength
        end
    end
end)
local function fmt(t)
    t = math.floor(t or 0)
    return string.format("%d:%02d", math.floor(t / 60), t % 60)
end
task.spawn(function()
    while gui.Parent do
        pcall(function()
            local len = sound.TimeLength
            if len > 0 then
                barFill.Size = UDim2.new(math.clamp(sound.TimePosition / len, 0, 1), 0, 1, 0)
            else
                barFill.Size = UDim2.new(0, 0, 1, 0)
            end
            timeLab.Text = fmt(sound.TimePosition) .. " / " .. fmt(len)
        end)
        task.wait(0.25)
    end
end)

local vr = rowFrame(ms, 34)
local volLabel = Instance.new("TextLabel", vr)
volLabel.Size = UDim2.new(1, -90, 1, 0)
volLabel.Position = UDim2.new(0, 45, 0, 0)
volLabel.BackgroundTransparency = 1
volLabel.TextColor3 = Color3.new(1, 1, 1)
volLabel.Font = Enum.Font.GothamBold
volLabel.TextSize = 14
local function setVol(v)
    v = math.clamp(math.floor(v * 10 + 0.5) / 10, 0, 2)
    sound.Volume = v
    volLabel.Text = "Volume: " .. math.floor(v * 100) .. "%"
end
local vMinus = mk(vr, "-", MID, function() setVol(sound.Volume - 0.1) end)
vMinus.Size = UDim2.new(0, 38, 1, 0)
vMinus.TextSize = 18
local vPlus = mk(vr, "+", ACC, function() setVol(sound.Volume + 0.1) end)
vPlus.Size = UDim2.new(0, 38, 1, 0)
vPlus.Position = UDim2.new(1, -38, 0, 0)
vPlus.TextSize = 18
setVol(0.5)

local catWrap = rowFrame(ms, 36)
local catBar = Instance.new("ScrollingFrame", catWrap)
catBar.Size = UDim2.new(1, 0, 1, 0)
catBar.BackgroundTransparency = 1
catBar.BorderSizePixel = 0
catBar.ScrollBarThickness = 0
catBar.ScrollingDirection = Enum.ScrollingDirection.X
catBar.CanvasSize = UDim2.new(0, 0, 0, 0)
catBar.AutomaticCanvasSize = Enum.AutomaticSize.X
local catLay = Instance.new("UIListLayout", catBar)
catLay.FillDirection = Enum.FillDirection.Horizontal
catLay.SortOrder = Enum.SortOrder.LayoutOrder
catLay.Padding = UDim.new(0, 6)

local catBtns = {}
local function setCat(n)
    for i, b in ipairs(catBtns) do
        tween(b, 0.15, {BackgroundColor3 = (i == n) and ACC or MID})
    end
end

local holder = Instance.new("Frame", ms)
holder.Size = UDim2.new(1, 0, 0, 0)
holder.AutomaticSize = Enum.AutomaticSize.Y
holder.BackgroundTransparency = 1
holder.LayoutOrder = nextOrder(ms)
local hl = Instance.new("UIListLayout", holder)
hl.Padding = UDim.new(0, 6)
hl.SortOrder = Enum.SortOrder.LayoutOrder

local SONG_FILE = "tutu_songs.json"
pcall(function()
    if isfile and readfile and isfile(SONG_FILE) then
        local d = HttpService:JSONDecode(readfile(SONG_FILE))
        if type(d) == "table" then savedSongs = d end
    end
end)
local function writeSongs()
    if writefile then
        pcall(function() writefile(SONG_FILE, HttpService:JSONEncode(savedSongs)) end)
    end
end
local function isSaved(id)
    for _, sv in ipairs(savedSongs) do
        if sv[2] == tostring(id) then return true end
    end
    return false
end
local function addSaved(name, id)
    if isSaved(id) then return false end
    table.insert(savedSongs, {tostring(name), tostring(id)})
    writeSongs()
    return true
end

local function get(url)
    if not http then return nil end
    local ok1, res = pcall(http, {Url = url, Method = "GET"})
    if ok1 and res and res.StatusCode == 200 then
        local ok2, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
        if ok2 then return data end
    end
    return nil
end

local function resolve(q)
    local key = q:lower()
    if idCache[key] then return idCache[key] end
    local data = get(MARKET .. HttpService:UrlEncode(q))
    if not data or not data.data or #data.data == 0 then return nil end
    local id = tostring(data.data[1].id)
    idCache[key] = id
    return id
end

local function findQ(id, name)
    for i, s in ipairs(queue) do
        if (id and s[2] == tostring(id)) or s[1] == name then return i end
    end
    return 0
end

local function copyId(id, b)
    if not id or id == "" then
        now.Text = "Nenhuma musica ainda"
        return
    end
    codeBox.Text = tostring(id)
    local old = b.Text
    if clip then
        pcall(clip, tostring(id))
        b.Text = "Copiado!"
    else
        b.Text = "Veja a barra"
        now.Text = "Seu executor nao copia: segure na barra do codigo"
    end
    task.delay(1.2, function()
        if b.Parent then b.Text = old end
    end)
end

play = function(id, name)
    id = tostring(id)
    name = tostring(name or ("ID " .. id))
    currentSong = {name, id}
    sound:Stop()
    sound.SoundId = "rbxassetid://" .. id
    sound.TimePosition = 0
    sound:Play()
    token = token + 1
    local my = token
    qIndex = findQ(id, name)
    codeBox.Text = id
    ppBtn.Text = "Pause"
    now.Text = "Tocando: " .. name
    for i, s in ipairs(recent) do
        if s[2] == id then table.remove(recent, i) break end
    end
    table.insert(recent, 1, {name, id})
    if #recent > 40 then table.remove(recent) end
    task.delay(4, function()
        if my == token and not sound.IsLoaded then
            now.Text = "Nao carregou (ID bloqueado?) tente outra"
        end
    end)
end

local function playQ(i)
    local s = queue[i]
    if not s then return end
    qIndex = i
    local id = s[2]
    if not id then
        now.Text = "Buscando: " .. s[1]
        id = resolve(s[1])
        if not id then
            now.Text = "Nao achei: " .. s[1]
            return
        end
        s[2] = id
    end
    play(id, s[1])
end
nextSong = function()
    if #queue == 0 then return end
    if mx.shuffleOn and #queue > 1 then
        local i = qIndex
        while i == qIndex do i = math.random(#queue) end
        playQ(i)
    else
        playQ(qIndex % #queue + 1)
    end
end
prevSong = function()
    if #queue == 0 then return end
    local i = qIndex - 1
    if i < 1 then i = #queue end
    playQ(i)
end
bind(sound.Ended, function()
    if sound.Looped then return end
    if #queue > 1 then nextSong() else ppBtn.Text = "Play" end
end)

local function mkSongRow(name, id, removeMode)
    id = id and tostring(id) or nil
    local row = Instance.new("Frame", holder)
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = MID
    row.BackgroundTransparency = 0.1
    row.LayoutOrder = nextOrder(holder)
    corner(row, 10)
    local bar = Instance.new("Frame", row)
    bar.Size = UDim2.new(0, 4, 0.6, 0)
    bar.Position = UDim2.new(0, 4, 0.2, 0)
    bar.BackgroundColor3 = ACC
    bar.BorderSizePixel = 0
    corner(bar, 4)

    local idLab = Instance.new("TextLabel", row)
    idLab.Size = UDim2.new(0, 82, 1, 0)
    idLab.Position = UDim2.new(1, -190, 0, 0)
    idLab.BackgroundTransparency = 1
    idLab.Text = id or "toque"
    idLab.TextColor3 = ACC
    idLab.Font = Enum.Font.GothamBold
    idLab.TextSize = 11
    idLab.TextXAlignment = Enum.TextXAlignment.Right

    local function getId()
        if id then return id end
        now.Text = "Buscando: " .. name
        local rid = resolve(name)
        if rid then
            id = rid
            idLab.Text = rid
        else
            now.Text = "Nao achei: " .. name
        end
        return id
    end

    local pb = Instance.new("TextButton", row)
    pb.Size = UDim2.new(1, -196, 1, 0)
    pb.BackgroundTransparency = 1
    pb.Text = tostring(name)
    pb.TextColor3 = Color3.new(1, 1, 1)
    pb.Font = Enum.Font.Gotham
    pb.TextSize = 14
    pb.TextXAlignment = Enum.TextXAlignment.Left
    pb.TextTruncate = Enum.TextTruncate.AtEnd
    local pad = Instance.new("UIPadding", pb)
    pad.PaddingLeft = UDim.new(0, 16)
    pb.MouseButton1Down:Connect(function() tween(row, 0.08, {BackgroundColor3 = ACC}) end)
    pb.MouseButton1Up:Connect(function() tween(row, 0.2, {BackgroundColor3 = MID}) end)
    pb.MouseLeave:Connect(function() tween(row, 0.2, {BackgroundColor3 = MID}) end)
    pb.MouseButton1Click:Connect(function()
        local i = getId()
        if i then play(i, name) end
    end)

    local cb = mk(row, "Copiar", ACC, function() end)
    cb.Size = UDim2.new(0, 60, 0, 32)
    cb.Position = UDim2.new(1, -66, 0.5, -16)
    cb.TextSize = 12
    cb.MouseButton1Click:Connect(function()
        local i = getId()
        if i then copyId(i, cb) end
    end)

    local sb
    if removeMode then
        sb = mk(row, "X", RED, function()
            for i, sv in ipairs(savedSongs) do
                if sv[1] == tostring(name) and sv[2] == tostring(id) then
                    table.remove(savedSongs, i)
                    break
                end
            end
            writeSongs()
            showSaved()
        end)
    else
        sb = mk(row, (id and isSaved(id)) and "OK" or "+", Color3.fromRGB(40, 160, 90), function()
            local i = getId()
            if not i then return end
            if addSaved(name, i) then now.Text = "Salva: " .. tostring(name) end
            sb.Text = "OK"
        end)
    end
    sb.Size = UDim2.new(0, 34, 0, 32)
    sb.Position = UDim2.new(1, -104, 0.5, -16)
    sb.TextSize = 14
end

local function showList(items, removeMode, emptyText)
    for _, c in ipairs(holder:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    queue = {}
    for _, s in ipairs(items) do queue[#queue + 1] = {s[1], s[2]} end
    if currentSong then qIndex = findQ(currentSong[2], currentSong[1]) else qIndex = 0 end
    if #items == 0 then
        local l = Instance.new("TextLabel", holder)
        l.Size = UDim2.new(1, 0, 0, 40)
        l.BackgroundTransparency = 1
        l.Text = emptyText
        l.TextWrapped = true
        l.TextColor3 = Color3.fromRGB(175, 182, 205)
        l.Font = Enum.Font.Gotham
        l.TextSize = 13
        l.LayoutOrder = nextOrder(holder)
    else
        for _, s in ipairs(items) do mkSongRow(s[1], s[2], removeMode) end
    end
end

showSaved = function()
    setCat(1)
    showList(savedSongs, true, "Nenhuma salva ainda. Aperte + em uma musica ou Salvar.")
end
showRecent = function()
    setCat(2)
    showList(recent, false, "Nada tocado ainda.")
end
showCategory = function(ci)
    setCat(ci + 2)
    local items = {}
    for _, q in ipairs(cats[ci][2]) do items[#items + 1] = {q} end
    showList(items, false, "")
    now.Text = "Categoria: " .. cats[ci][1] .. " (toque para tocar)"
end

local function addCatBtn(i, txt, cb)
    local b = mk(catBar, txt, MID, cb)
    b.Size = UDim2.new(0, 84, 1, 0)
    b.LayoutOrder = i
    b.TextSize = 13
    catBtns[i] = b
end
addCatBtn(1, "Salvas", function() showSaved() end)
addCatBtn(2, "Recentes", function() showRecent() end)
for ci, c in ipairs(cats) do
    addCatBtn(ci + 2, c[1], function() showCategory(ci) end)
end
do
local FILA_IDX = #cats + 3
showFila = function()
    setCat(FILA_IDX)
    showList(mx.queue, false, "Fila vazia. Toque uma musica e aperte + Fila.")
    now.Text = "Fila (" .. #mx.queue .. ")  toque para tocar"
end
addCatBtn(FILA_IDX, "Fila", function() showFila() end)
end

local function doSearch(q)
    q = q or ""
    local id = q:match("^%s*(%d+)%s*$") or q:match("rbxassetid://(%d+)")
    if id then
        play(id)
        return
    end
    if q:gsub("%s", "") == "" then
        now.Text = "Digite um nome ou ID"
        return
    end
    if not http then
        now.Text = "Seu executor nao tem request (use o ID)"
        return
    end
    now.Text = "Buscando..."
    local data = get(MARKET .. HttpService:UrlEncode(q))
    if not data or not data.data or #data.data == 0 then
        now.Text = "Nada encontrado ou erro"
        return
    end
    local ids = {}
    for _, d in ipairs(data.data) do table.insert(ids, d.id) end
    local det = get(DETAILS .. table.concat(ids, ","))
    local items = {}
    if det and det.data then
        for _, it in ipairs(det.data) do
            if it.asset then items[#items + 1] = {it.asset.name, tostring(it.asset.id)} end
        end
    else
        for _, i in ipairs(ids) do items[#items + 1] = {tostring(i), tostring(i)} end
    end
    setCat(0)
    showList(items, false, "Nada encontrado")
    now.Text = "Resultados: " .. q
end

searchBtn.MouseButton1Click:Connect(function() doSearch(box.Text) end)
goBtn.MouseButton1Click:Connect(function()
    local q = box.Text or ""
    local id = q:match("^%s*(%d+)%s*$") or q:match("rbxassetid://(%d+)")
    if id then
        play(id)
    elseif q:gsub("%s", "") ~= "" then
        now.Text = "Buscando: " .. q
        local rid = resolve(q)
        if rid then play(rid, q) else now.Text = "Nao achei: " .. q end
    else
        now.Text = "Digite um nome ou ID"
    end
end)
box.FocusLost:Connect(function(enter)
    if enter then doSearch(box.Text) end
end)
copyBtn.MouseButton1Click:Connect(function() copyId(codeBox.Text, copyBtn) end)
saveBtn.MouseButton1Click:Connect(function()
    if not currentSong then
        now.Text = "Toque uma musica antes de salvar"
        return
    end
    if addSaved(currentSong[1], currentSong[2]) then
        now.Text = "Salva: " .. currentSong[1]
    else
        now.Text = "Ja estava salva"
    end
end)

showCategory(1)
end -- fim aba musicas

------------------------------------------------------------
-- ABA PERSO
------------------------------------------------------------
do
    local resets = {}
    local function addStepper(name, init, step, min, max, cb)
        local set = stepper(ps, name, init, step, min, max, cb)
        resets[#resets + 1] = function() set(init, true) end
    end

    local pmsg = mkMsg(ps, "Seu personagem")
    addStepper("Velocidade", 16, 8, 16, 250, function(v) custom.speed = v end)
    addStepper("Pulo", 50, 10, 50, 400, function(v) custom.jump = v end)
    addStepper("Gravidade", 196, 20, 20, 196, function(v) custom.grav = v end)

    toggleRow(ps, "Pulo infinito", function(s) infJump = s end)
    bind(UIS.JumpRequest, function()
        if infJump then
            local h = getHum()
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    toggleRow(ps, "Atravessar paredes", function(s) noclip = s end)
    bind(RunService.Stepped, function()
        if noclip and lp.Character then
            for _, p in ipairs(lp.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)

    local bv, bg
    stopFly = function()
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        local h = getHum()
        if h then h.PlatformStand = false end
    end
    local function startFly()
        local root, h = getRoot(), getHum()
        if not root or not h then return end
        stopFly()
        bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.zero
        bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.P = 1e4
        h.PlatformStand = true
    end
    bind(RunService.RenderStepped, function()
        if not flyOn then return end
        local root, h, cam = getRoot(), getHum(), workspace.CurrentCamera
        if not (root and h and cam) then return end
        if not bv or bv.Parent ~= root then startFly() end
        if not bv then return end
        local rel = cam.CFrame:VectorToObjectSpace(h.MoveDirection)
        local vel = Vector3.zero
        if rel.Magnitude > 0 then
            rel = rel.Unit
            vel = (cam.CFrame.LookVector * -rel.Z + cam.CFrame.RightVector * rel.X) * flySpeed
        end
        bv.Velocity = vel
        bg.CFrame = cam.CFrame
    end)
    toggleRow(ps, "Voar", function(s)
        flyOn = s
        if s then startFly() else stopFly() end
    end)
    addStepper("Veloc. voo", 60, 20, 20, 250, function(v) flySpeed = v end)

    toggleRow(ps, "Girar personagem", function(s) spinOn = s end)
    addStepper("Veloc. giro", 10, 5, 5, 60, function(v) spinSpeed = v end)
    toggleRow(ps, "Congelar personagem", function(s)
        local r = getRoot()
        if r then r.Anchored = s end
    end)

    local savedCF = nil
    mkRow(ps, "Salvar posicao aqui", "SALVAR", function()
        local r = getRoot()
        if r then
            savedCF = r.CFrame
            pmsg.Text = "Posicao salva"
        end
    end)
    mkRow(ps, "Voltar para posicao salva", "IR", function()
        local r = getRoot()
        if r and savedCF then
            r.CFrame = savedCF
            pmsg.Text = "Voltou para a posicao salva"
        else
            pmsg.Text = "Salve uma posicao primeiro"
        end
    end)

    ---------------- ESP ----------------
    mkMsg(ps, "ESP (ver os jogadores)")
    toggleRow(ps, "Nome + distancia + vida", function(s) espNames = s end)
    toggleRow(ps, "Destaque no corpo", function(s) espBox = s end)
    toggleRow(ps, "Linhas ate os jogadores", function(s) espLines = s end)
    toggleRow(ps, "Linhas saem de baixo da tela", function(s) espFromScreen = s end)
    addStepper("Distancia maxima", 2000, 500, 500, 10000, function(v) espMax = v end)

    local espColors = {
        {"Laranja", ORANGE},
        {"Vermelho", Color3.fromRGB(255, 60, 60)},
        {"Verde", GOOD},
        {"Azul", Color3.fromRGB(60, 160, 255)},
        {"Branco", Color3.new(1, 1, 1)},
        {"Rosa", Color3.fromRGB(255, 100, 200)},
        {"Amarelo", Color3.fromRGB(255, 230, 60)},
    }
    local ci = 1
    local colLab
    local _
    _, colLab = mkRow(ps, "Cor do ESP (toque para trocar)", "Laranja", function()
        ci = ci % #espColors + 1
        espColor = espColors[ci][2]
        colLab.Text = espColors[ci][1]
        colLab.TextColor3 = espColor
    end)

    local tracers = {}
    bind(Players.PlayerRemoving, function(p)
        if tracers[p] then
            tracers[p]:Destroy()
            tracers[p] = nil
        end
    end)

    -- linhas (desenhadas na tela, passam por tras de paredes)
    bind(RunService.RenderStepped, function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local myRoot = getRoot()
        local A = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
        if myRoot and not espFromScreen then
            local a = cam:WorldToViewportPoint(myRoot.Position)
            if a.Z > 0 then A = Vector2.new(a.X, a.Y) end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                local tr = tracers[p]
                local show = false
                if espLines and root and myRoot then
                    local dist = (root.Position - myRoot.Position).Magnitude
                    local pt = cam:WorldToViewportPoint(root.Position)
                    if dist <= espMax and pt.Z > 0 then
                        show = true
                        if not tr then
                            tr = Instance.new("Frame")
                            tr.AnchorPoint = Vector2.new(0.5, 0.5)
                            tr.BorderSizePixel = 0
                            tr.BackgroundTransparency = 0.15
                            tr.Parent = tracerLayer
                            tracers[p] = tr
                        end
                        local B = Vector2.new(pt.X, pt.Y)
                        local d = B - A
                        tr.BackgroundColor3 = espColor
                        tr.Size = UDim2.fromOffset(d.Magnitude, 2)
                        tr.Position = UDim2.fromOffset((A.X + B.X) / 2, (A.Y + B.Y) / 2)
                        tr.Rotation = math.deg(math.atan2(d.Y, d.X))
                        tr.Visible = true
                    end
                end
                if not show and tr then tr.Visible = false end
            end
        end
    end)

    -- nomes e destaque
    task.spawn(function()
        while gui.Parent do
            local myRoot = getRoot()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp then
                    local c = p.Character
                    local root = c and c:FindFirstChild("HumanoidRootPart")
                    local head = c and (c:FindFirstChild("Head") or root)
                    local dist = (root and myRoot) and (root.Position - myRoot.Position).Magnitude or 0
                    local inRange = dist <= espMax

                    local bb = c and c:FindFirstChild("TutuName")
                    if espNames and head and inRange then
                        if not bb then
                            bb = Instance.new("BillboardGui")
                            bb.Name = "TutuName"
                            bb.Size = UDim2.new(0, 180, 0, 38)
                            bb.StudsOffset = Vector3.new(0, 2.8, 0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = head
                            local nl = Instance.new("TextLabel", bb)
                            nl.Name = "L"
                            nl.Size = UDim2.new(1, 0, 1, 0)
                            nl.BackgroundTransparency = 1
                            nl.Font = Enum.Font.GothamBold
                            nl.TextSize = 13
                            nl.TextStrokeTransparency = 0.3
                            nl.TextWrapped = true
                            bb.Parent = c
                        end
                        local l = bb:FindFirstChild("L")
                        local hum = c:FindFirstChildOfClass("Humanoid")
                        if l then
                            l.TextColor3 = espColor
                            l.Text = p.DisplayName .. " (@" .. p.Name .. ")\n" .. math.floor(dist) .. "m  |  " .. (hum and math.floor(hum.Health) or 0) .. " HP"
                        end
                    elseif bb then
                        bb:Destroy()
                    end

                    local hl = c and c:FindFirstChild("TutuESP")
                    if espBox and c and inRange then
                        if not hl then
                            pcall(function()
                                local h = Instance.new("Highlight")
                                h.Name = "TutuESP"
                                h.FillColor = espColor
                                h.OutlineColor = Color3.new(1, 1, 1)
                                h.FillTransparency = 0.5
                                h.Adornee = c
                                h.Parent = c
                            end)
                        else
                            hl.FillColor = espColor
                        end
                    elseif hl then
                        hl:Destroy()
                    end
                end
            end
            task.wait(0.25)
        end
    end)

    clearESP = function()
        for _, p in ipairs(Players:GetPlayers()) do
            local c = p.Character
            if c then
                for _, n in ipairs({"TutuESP", "TutuName"}) do
                    local o = c:FindFirstChild(n)
                    if o then o:Destroy() end
                end
            end
        end
        for _, f in pairs(tracers) do f:Destroy() end
        tracers = {}
    end

    ---------------- helpers de lista ----------------
    local function listRow(holder, text, onClick)
        local row = Instance.new("Frame", holder)
        row.Size = UDim2.new(1, 0, 0, 46)
        row.BackgroundColor3 = MID
        row.BackgroundTransparency = 0.1
        row.LayoutOrder = nextOrder(holder)
        corner(row, 10)
        local bar = Instance.new("Frame", row)
        bar.Size = UDim2.new(0, 4, 0.6, 0)
        bar.Position = UDim2.new(0, 4, 0.2, 0)
        bar.BackgroundColor3 = ACC
        bar.BorderSizePixel = 0
        corner(bar, 4)
        local pb = Instance.new("TextButton", row)
        pb.Size = UDim2.new(1, -110, 1, 0)
        pb.BackgroundTransparency = 1
        pb.Text = tostring(text)
        pb.TextColor3 = Color3.new(1, 1, 1)
        pb.Font = Enum.Font.Gotham
        pb.TextSize = 14
        pb.TextXAlignment = Enum.TextXAlignment.Left
        pb.TextTruncate = Enum.TextTruncate.AtEnd
        local pad = Instance.new("UIPadding", pb)
        pad.PaddingLeft = UDim.new(0, 16)
        pb.MouseButton1Down:Connect(function() tween(row, 0.08, {BackgroundColor3 = ACC}) end)
        pb.MouseButton1Up:Connect(function() tween(row, 0.2, {BackgroundColor3 = MID}) end)
        pb.MouseLeave:Connect(function() tween(row, 0.2, {BackgroundColor3 = MID}) end)
        pb.MouseButton1Click:Connect(onClick)
        return row
    end
    local function listHolder(parent)
        local h = Instance.new("Frame", parent)
        h.Size = UDim2.new(1, 0, 0, 0)
        h.AutomaticSize = Enum.AutomaticSize.Y
        h.BackgroundTransparency = 1
        h.LayoutOrder = nextOrder(parent)
        local l = Instance.new("UIListLayout", h)
        l.Padding = UDim.new(0, 6)
        l.SortOrder = Enum.SortOrder.LayoutOrder
        return h
    end
    local function clearHolder(h)
        for _, c in ipairs(h:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
    end

    ---------------- TELEPORTAR / SPECTAR JOGADOR ----------------
    mkMsg(ps, "Jogadores (IR = teleportar, VER = spectar)")
    local specTarget = nil
    local function stopSpec()
        specTarget = nil
        local cam, h = workspace.CurrentCamera, getHum()
        if cam and h then cam.CameraSubject = h end
    end
    TX.cleanups[#TX.cleanups + 1] = stopSpec
    bind(RunService.RenderStepped, function()
        if not specTarget then return end
        if not specTarget.Parent then
            stopSpec()
            return
        end
        local cam = workspace.CurrentCamera
        local ch = specTarget.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if cam and hum and cam.CameraSubject ~= hum then cam.CameraSubject = hum end
    end)
    mkRow(ps, "Parar de spectar (voltar a camera)", "PARAR", function()
        stopSpec()
        pmsg.Text = "Camera normal"
    end)
    local tpBoxRow = rowFrame(ps, 38)
    local tpBox = mkBox(tpBoxRow, "Buscar jogador (nome ou apelido)")
    tpBox.Size = UDim2.new(1, 0, 1, 0)
    local plHolder = listHolder(ps)
    local function tpToPlayer(p)
        local r = getRoot()
        local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if r and tr then
            r.CFrame = tr.CFrame * CFrame.new(0, 0, 3)
            pmsg.Text = "Teleportou ate " .. p.DisplayName
        else
            pmsg.Text = "Esse jogador esta sem personagem"
        end
    end
    local function refreshPlayers()
        clearHolder(plHolder)
        local q = tpBox.Text:lower()
        local n = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and (q == "" or p.Name:lower():find(q, 1, true) or p.DisplayName:lower():find(q, 1, true)) then
                n = n + 1
                local row = listRow(plHolder, p.DisplayName .. " (@" .. p.Name .. ")", function() tpToPlayer(p) end)
                local go = mk(row, "IR", ACC, function() tpToPlayer(p) end)
                go.Size = UDim2.new(0, 44, 0, 32)
                go.Position = UDim2.new(1, -98, 0.5, -16)
                go.TextSize = 12
                local sp = mk(row, "VER", Color3.fromRGB(40, 160, 90), function()
                    if specTarget == p then
                        stopSpec()
                        pmsg.Text = "Spectar desligado"
                    else
                        specTarget = p
                        pmsg.Text = "Spectando " .. p.DisplayName
                    end
                end)
                sp.Size = UDim2.new(0, 44, 0, 32)
                sp.Position = UDim2.new(1, -50, 0.5, -16)
                sp.TextSize = 12
            end
        end
        if n == 0 then
            local l = Instance.new("TextLabel", plHolder)
            l.Size = UDim2.new(1, 0, 0, 30)
            l.BackgroundTransparency = 1
            l.Text = "Nenhum jogador encontrado"
            l.TextColor3 = Color3.fromRGB(175, 182, 205)
            l.Font = Enum.Font.Gotham
            l.TextSize = 13
            l.LayoutOrder = nextOrder(plHolder)
        end
    end
    tpBox:GetPropertyChangedSignal("Text"):Connect(refreshPlayers)
    bind(Players.PlayerAdded, function() task.delay(0.3, refreshPlayers) end)
    bind(Players.PlayerRemoving, function() task.delay(0.3, refreshPlayers) end)
    refreshPlayers()

    ---------------- CLIQUE PARA TELEPORTAR ----------------
    local clickTp = false
    local tapStart = {}
    toggleRow(ps, "Clique para teleportar (toque na tela)", function(s) clickTp = s end)
    bind(UIS.InputBegan, function(i, gp)
        if not clickTp or gp then return end
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            tapStart[i] = {pos = Vector2.new(i.Position.X, i.Position.Y), t = tick()}
        end
    end)
    bind(UIS.InputEnded, function(i)
        local st = tapStart[i]
        tapStart[i] = nil
        if not st or not clickTp then return end
        local p = Vector2.new(i.Position.X, i.Position.Y)
        if (p - st.pos).Magnitude > 14 or tick() - st.t > 0.35 then return end
        local cam, root = workspace.CurrentCamera, getRoot()
        if not cam or not root then return end
        local ray = cam:ScreenPointToRay(p.X, p.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {lp.Character}
        local res = workspace:Raycast(ray.Origin, ray.Direction * 3000, params)
        if res then
            root.CFrame = CFrame.new(res.Position + Vector3.new(0, 3, 0)) * (root.CFrame - root.CFrame.Position)
        end
    end)

    ---------------- POSICOES SALVAS COM NOME ----------------
    mkMsg(ps, "Posicoes salvas (com nome)")
    local POS_FILE = "tutu_positions.json"
    local savedPos = {}
    pcall(function()
        if isfile and readfile and isfile(POS_FILE) then
            local d = HttpService:JSONDecode(readfile(POS_FILE))
            if type(d) == "table" then savedPos = d end
        end
    end)
    local function writePos()
        if writefile then
            pcall(function() writefile(POS_FILE, HttpService:JSONEncode(savedPos)) end)
        end
    end
    local posRow = rowFrame(ps, 38)
    local posBox = mkBox(posRow, "Nome da posicao (ex: base, spawn)")
    posBox.Size = UDim2.new(1, -96, 1, 0)
    local posSave = mk(posRow, "SALVAR", ACC, function() end)
    posSave.Size = UDim2.new(0, 88, 1, 0)
    posSave.Position = UDim2.new(1, -88, 0, 0)
    posSave.TextSize = 13
    local posHolder = listHolder(ps)
    local refreshPos
    local function goPos(sp)
        local r = getRoot()
        if r and sp.c then
            r.CFrame = CFrame.new(table.unpack(sp.c))
            pmsg.Text = "Foi para: " .. tostring(sp.name)
        end
    end
    refreshPos = function()
        clearHolder(posHolder)
        local n = 0
        for _, sp in ipairs(savedPos) do
            if sp.place == game.PlaceId then
                n = n + 1
                local row = listRow(posHolder, sp.name, function() goPos(sp) end)
                local del = mk(row, "X", RED, function()
                    for k, v in ipairs(savedPos) do
                        if v == sp then
                            table.remove(savedPos, k)
                            break
                        end
                    end
                    writePos()
                    refreshPos()
                end)
                del.Size = UDim2.new(0, 40, 0, 32)
                del.Position = UDim2.new(1, -48, 0.5, -16)
                del.TextSize = 14
            end
        end
        if n == 0 then
            local l = Instance.new("TextLabel", posHolder)
            l.Size = UDim2.new(1, 0, 0, 30)
            l.BackgroundTransparency = 1
            l.Text = "Nenhuma posicao salva neste jogo"
            l.TextColor3 = Color3.fromRGB(175, 182, 205)
            l.Font = Enum.Font.Gotham
            l.TextSize = 13
            l.LayoutOrder = nextOrder(posHolder)
        end
    end
    posSave.MouseButton1Click:Connect(function()
        local r = getRoot()
        if not r then
            pmsg.Text = "Sem personagem"
            return
        end
        local name = posBox.Text
        if name:gsub("%s", "") == "" then name = "Posicao " .. (#savedPos + 1) end
        savedPos[#savedPos + 1] = {name = name, place = game.PlaceId, c = {r.CFrame:GetComponents()}}
        writePos()
        posBox.Text = ""
        pmsg.Text = "Posicao salva: " .. name
        refreshPos()
    end)
    refreshPos()

    mkMsg(ps, "Resetar")
    mkRow(ps, "Resetar personagem (morrer)", "RESET", function()
        local h = getHum()
        if h then h.Health = 0 end
    end)
    mkRow(ps, "Voltar valores ao normal", "RESET", function()
        custom.speed, custom.jump, custom.grav = nil, nil, nil
        workspace.Gravity = 196.2
        local h = getHum()
        if h then
            h.WalkSpeed = 16
            h.JumpPower = 50
        end
        for _, f in ipairs(resets) do f() end
    end)
end

------------------------------------------------------------
-- ABA MODS
------------------------------------------------------------
local origLight = {}
for _, k in ipairs({"Brightness", "ClockTime", "FogEnd", "FogStart", "FogColor", "GlobalShadows",
    "Ambient", "OutdoorAmbient", "ExposureCompensation", "ColorShift_Top", "ColorShift_Bottom"}) do
    pcall(function() origLight[k] = Lighting[k] end)
end
restoreLight = function()
    for k, v in pairs(origLight) do
        pcall(function() Lighting[k] = v end)
    end
end

do
    local modResets, shaderResets = {}, {}
    local function addModStepper(name, init, step, min, max, cb, list)
        local set = stepper(mo, name, init, step, min, max, cb)
        local t = list or modResets
        t[#t + 1] = function() set(init, true) end
    end

    local modMsg = mkMsg(mo, "Mods")

    -- FPS e ping
    local statLab = Instance.new("TextLabel", gui)
    statLab.Size = UDim2.new(0, 460, 0, 20)
    statLab.Position = UDim2.new(0, 10, 0, 6)
    statLab.BackgroundTransparency = 1
    statLab.TextColor3 = Color3.new(1, 1, 1)
    statLab.TextStrokeTransparency = 0.4
    statLab.Font = Enum.Font.GothamBold
    statLab.TextSize = 13
    statLab.TextXAlignment = Enum.TextXAlignment.Left
    statLab.Visible = false
    local fpsAcc = 60
    bind(RunService.RenderStepped, function(dt)
        fpsAcc = fpsAcc * 0.9 + (1 / math.max(dt, 0.001)) * 0.1
    end)
    task.spawn(function()
        while gui.Parent do
            if statLab.Visible then
                local ping = 0
                pcall(function()
                    ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                end)
                local parts = {}
                if TX.showStat then
                    parts[#parts + 1] = "FPS " .. math.floor(fpsAcc + 0.5) .. "  |  Ping " .. math.floor(ping) .. " ms  |  " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers .. " jog"
                end
                if TX.showClock then
                    local okd, dstr = pcall(function() return DateTime.now():FormatLocalTime("HH:mm:ss  DD/MM/YYYY", "pt-br") end)
                    parts[#parts + 1] = okd and dstr or "--:--"
                end
                statLab.Text = table.concat(parts, "  |  ")
            end
            task.wait(0.5)
        end
    end)
    local function updStat() statLab.Visible = (TX.showStat or TX.showClock) and true or false end
    toggleRow(mo, "Mostrar FPS e ping", function(s)
        TX.showStat = s
        updStat()
    end)
    toggleRow(mo, "Mostrar relogio e data (ao lado do FPS)", function(s)
        TX.showClock = s
        updStat()
    end)
    local plMsg = mkMsg(mo, "Jogadores no servidor: ...")
    task.spawn(function()
        while gui.Parent do
            plMsg.Text = "Jogadores no servidor: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
            task.wait(2)
        end
    end)

    mkMsg(mo, "Camera")
    addModStepper("Zoom maximo", 128, 100, 128, 5000, function(v) custom.zoom = v end)
    addModStepper("Campo de visao", 70, 10, 30, 120, function(v) custom.fov = v end)
    toggleRow(mo, "Forcar 1a pessoa", function(s)
        pcall(function()
            lp.CameraMode = s and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
        end)
    end)

    ---------------- SHADERS ----------------
    mkMsg(mo, "Shaders (toque para usar)")
    local fx = {}
    local function getFx(class, name)
        local e = fx[name]
        if e and e.Parent then return e end
        e = Lighting:FindFirstChild(name) or Instance.new(class)
        e.Name = name
        e.Parent = Lighting
        fx[name] = e
        return e
    end
    clearShaders = function()
        for _, n in ipairs({"TutuCC", "TutuBloom", "TutuRays", "TutuAtmos", "TutuBlur"}) do
            local e = Lighting:FindFirstChild(n)
            if e then e:Destroy() end
        end
        fx = {}
        restoreLight()
    end
    local function C(r, g, b) return Color3.fromRGB(r, g, b) end
    local shaders = {
        {"Cinematografico", {cc = {Contrast = 0.15, Saturation = 0.1, TintColor = C(255, 245, 230)}, bloom = {Intensity = 0.4, Size = 24, Threshold = 0.9}, rays = {Intensity = 0.08, Spread = 0.8}, light = {Brightness = 2.2, ExposureCompensation = 0.1}}},
        {"Vibrante", {cc = {Contrast = 0.1, Saturation = 0.5}, bloom = {Intensity = 0.5, Size = 30, Threshold = 0.85}, light = {Brightness = 2.5}}},
        {"Por do sol", {cc = {Contrast = 0.1, Saturation = 0.25, TintColor = C(255, 215, 180)}, bloom = {Intensity = 0.6, Size = 32, Threshold = 0.8}, rays = {Intensity = 0.3, Spread = 1}, atmos = {Density = 0.3, Color = C(255, 190, 140), Haze = 1.5, Glare = 0.5}, light = {ClockTime = 17.8, Brightness = 2}}},
        {"Noite azul", {cc = {Contrast = 0.12, Saturation = 0.1, TintColor = C(170, 195, 255), Brightness = -0.03}, bloom = {Intensity = 0.5, Size = 28, Threshold = 0.8}, light = {ClockTime = 0, Brightness = 1.2, Ambient = C(40, 50, 90), OutdoorAmbient = C(50, 60, 110)}}},
        {"Neon Cyberpunk", {cc = {Contrast = 0.2, Saturation = 0.6, TintColor = C(255, 190, 255)}, bloom = {Intensity = 0.9, Size = 40, Threshold = 0.7}, light = {ClockTime = 22, Brightness = 1.5, Ambient = C(70, 30, 120), OutdoorAmbient = C(90, 40, 140)}}},
        {"Preto e Branco", {cc = {Contrast = 0.2, Saturation = -1}}},
        {"Vintage Sepia", {cc = {Contrast = 0.1, Saturation = -0.4, TintColor = C(255, 225, 180)}, bloom = {Intensity = 0.2, Size = 20, Threshold = 1}}},
        {"Terror", {cc = {Contrast = 0.3, Saturation = -0.5, Brightness = -0.08, TintColor = C(200, 230, 210)}, atmos = {Density = 0.5, Color = C(40, 50, 45), Haze = 2, Offset = 0.2}, light = {ClockTime = 0, Brightness = 0.5, Ambient = C(15, 20, 18), OutdoorAmbient = C(20, 25, 22)}}},
        {"Sonho Rosa", {cc = {Contrast = 0.05, Saturation = 0.3, TintColor = C(255, 220, 240)}, bloom = {Intensity = 1.2, Size = 44, Threshold = 0.6}, atmos = {Density = 0.25, Color = C(255, 200, 230), Haze = 1}, light = {Brightness = 2.4}}},
        {"Realista", {cc = {Contrast = 0.1, Saturation = 0.15}, bloom = {Intensity = 0.3, Size = 24, Threshold = 0.95}, rays = {Intensity = 0.15, Spread = 0.9}, atmos = {Density = 0.3, Haze = 0.6, Glare = 0.2}, light = {Brightness = 2.5, ExposureCompensation = 0.2}}},
        {"Verao", {cc = {Contrast = 0.08, Saturation = 0.35, TintColor = C(255, 248, 225)}, bloom = {Intensity = 0.35, Size = 26, Threshold = 0.9}, rays = {Intensity = 0.25, Spread = 1}, light = {ClockTime = 13, Brightness = 3}}},
        {"Gelo", {cc = {Contrast = 0.1, Saturation = -0.1, TintColor = C(200, 230, 255)}, bloom = {Intensity = 0.5, Size = 30, Threshold = 0.85}, atmos = {Density = 0.35, Color = C(200, 225, 255), Haze = 1.2}, light = {Brightness = 2.2}}},
        {"Matrix Verde", {cc = {Contrast = 0.25, Saturation = -0.3, TintColor = C(150, 255, 170)}, bloom = {Intensity = 0.6, Size = 26, Threshold = 0.8}, light = {ClockTime = 0, Brightness = 1}}},
        {"Vermelho Sangue", {cc = {Contrast = 0.25, Saturation = 0.2, TintColor = C(255, 170, 170)}, atmos = {Density = 0.4, Color = C(120, 20, 20), Haze = 1.5}, light = {ClockTime = 19, Brightness = 1.2}}},
    }
    local function setProps(e, props)
        for k, v in pairs(props) do
            pcall(function() e[k] = v end)
        end
    end
    local function applyShader(d)
        clearShaders()
        if d.cc then setProps(getFx("ColorCorrectionEffect", "TutuCC"), d.cc) end
        if d.bloom then setProps(getFx("BloomEffect", "TutuBloom"), d.bloom) end
        if d.rays then setProps(getFx("SunRaysEffect", "TutuRays"), d.rays) end
        if d.atmos and not Lighting:FindFirstChildOfClass("Atmosphere") then
            setProps(getFx("Atmosphere", "TutuAtmos"), d.atmos)
        end
        if d.light then
            for k, v in pairs(d.light) do
                pcall(function() Lighting[k] = v end)
            end
        end
    end
    for _, s in ipairs(shaders) do
        mkRow(mo, s[1], "USAR", function()
            applyShader(s[2])
            for _, f in ipairs(shaderResets) do f() end
            modMsg.Text = "Shader: " .. s[1]
        end)
    end
    mkRow(mo, "Desligar shaders", "OFF", function()
        clearShaders()
        for _, f in ipairs(shaderResets) do f() end
        modMsg.Text = "Shaders desligados"
    end)

    mkMsg(mo, "Ajuste fino do visual")
    addModStepper("Saturacao", 0, 0.1, -1, 2, function(v) getFx("ColorCorrectionEffect", "TutuCC").Saturation = v end, shaderResets)
    addModStepper("Contraste", 0, 0.1, -1, 1, function(v) getFx("ColorCorrectionEffect", "TutuCC").Contrast = v end, shaderResets)
    addModStepper("Brilho da cor", 0, 0.05, -0.5, 0.5, function(v) getFx("ColorCorrectionEffect", "TutuCC").Brightness = v end, shaderResets)
    addModStepper("Bloom (brilho)", 0, 0.2, 0, 3, function(v)
        local e = getFx("BloomEffect", "TutuBloom")
        e.Intensity = v
        e.Size = 30
        e.Threshold = 0.8
    end, shaderResets)
    addModStepper("Raios de sol", 0, 0.1, 0, 1, function(v) getFx("SunRaysEffect", "TutuRays").Intensity = v end, shaderResets)
    addModStepper("Desfoque", 0, 2, 0, 24, function(v) getFx("BlurEffect", "TutuBlur").Size = v end, shaderResets)
    addModStepper("Exposicao", 0, 0.25, -2, 2, function(v) Lighting.ExposureCompensation = v end, shaderResets)

    ---------------- VISUAL ----------------
    mkMsg(mo, "Visual do mundo")
    do -- slider de hora do dia (dia/noite)
        local row = Instance.new("Frame", mo)
        row.Size = UDim2.new(1, 0, 0, 46)
        row.BackgroundColor3 = MID
        row.BackgroundTransparency = 0.1
        row.LayoutOrder = nextOrder(mo)
        corner(row, 10)
        local lab = Instance.new("TextLabel", row)
        lab.Size = UDim2.new(0, 124, 1, 0)
        lab.Position = UDim2.new(0, 14, 0, 0)
        lab.BackgroundTransparency = 1
        lab.TextColor3 = Color3.new(1, 1, 1)
        lab.Font = Enum.Font.Gotham
        lab.TextSize = 14
        lab.TextXAlignment = Enum.TextXAlignment.Left
        local track = Instance.new("Frame", row)
        track.Position = UDim2.new(0, 142, 0.5, -3)
        track.Size = UDim2.new(1, -162, 0, 6)
        track.BackgroundColor3 = Color3.fromRGB(46, 52, 76)
        track.BorderSizePixel = 0
        corner(track, 3)
        local fill = Instance.new("Frame", track)
        fill.BackgroundColor3 = ACC
        fill.BorderSizePixel = 0
        corner(fill, 3)
        local knob = Instance.new("Frame", track)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Size = UDim2.new(0, 20, 0, 20)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.ZIndex = 3
        corner(knob, 10)
        local hit = Instance.new("TextButton", row)
        hit.Position = UDim2.new(0, 130, 0, 0)
        hit.Size = UDim2.new(1, -142, 1, 0)
        hit.BackgroundTransparency = 1
        hit.Text = ""
        local function set(v, silent)
            v = math.clamp(math.floor(v * 4 + 0.5) / 4, 0, 24)
            local fr = v / 24
            fill.Size = UDim2.new(fr, 0, 1, 0)
            knob.Position = UDim2.new(fr, 0, 0.5, 0)
            local hh = math.floor(v)
            local mm = math.floor((v - hh) * 60 + 0.5)
            lab.Text = string.format("%s %02d:%02d", (v >= 6 and v < 18) and "Dia" or "Noite", hh, mm)
            if not silent then custom.hour = v end
        end
        local dragging = false
        local function fromX(x)
            local w = track.AbsoluteSize.X
            if w > 0 then set((x - track.AbsolutePosition.X) / w * 24) end
        end
        hit.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                fromX(i.Position.X)
            end
        end)
        bind(UIS.InputChanged, function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                fromX(i.Position.X)
            end
        end)
        bind(UIS.InputEnded, function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        set(14, true)
        modResets[#modResets + 1] = function() set(14, true) end
        REG.add(mo, "Hora do dia (slider dia/noite)", row, nil, nil)
    end
    toggleRow(mo, "Claridade total", function(s)
        fbOn = s
        if not s then restoreLight() end
    end)
    toggleRow(mo, "Sem neblina", function(s)
        fogOff = s
        if not s then restoreLight() end
    end)
    toggleRow(mo, "Sem sombras", function(s)
        shadowOff = s
        if not s then restoreLight() end
    end)
    toggleRow(mo, "Modo FPS (graficos baixos)", function(s)
        pcall(function()
            settings().Rendering.QualityLevel = s and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
        end)
    end)
    mkRow(mo, "Modo batata (nao volta)", "USAR", function()
        modMsg.Text = "Aplicando modo batata..."
        task.spawn(function()
            pcall(function() Lighting.GlobalShadows = false end)
            local n = 0
            for _, d in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") or d:IsA("Beam") then
                        d.Enabled = false
                    elseif d:IsA("Decal") or d:IsA("Texture") then
                        d.Transparency = 1
                    elseif d:IsA("BasePart") then
                        d.Material = Enum.Material.SmoothPlastic
                        d.Reflectance = 0
                    end
                end)
                n = n + 1
                if n % 400 == 0 then task.wait() end
            end
            modMsg.Text = "Modo batata ativado"
        end)
    end)

    ---------------- UTILIDADES ----------------
    mkMsg(mo, "Utilidades")
    toggleRow(mo, "Anti-AFK", function(s) afkOn = s end)
    bind(lp.Idled, function()
        if afkOn then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    end)
    toggleRow(mo, "Esconder interface do jogo", function(s)
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, not s) end)
    end)
    ---------------- MODO FOTO ----------------
    do
        local photo = false
        local pYaw, pPitch, pPos = 0, 0, Vector3.zero
        local wasAnchored, vert = false, 0
        local photoBar = Instance.new("Frame", gui)
        photoBar.AnchorPoint = Vector2.new(1, 0.5)
        photoBar.Position = UDim2.new(1, -10, 0.5, 0)
        photoBar.Size = UDim2.new(0, 64, 0, 224)
        photoBar.BackgroundTransparency = 1
        photoBar.Visible = false
        photoBar.ZIndex = 20
        local function pbtn(y, txt, color, onClick)
            local b = mk(photoBar, txt, color, onClick)
            b.Size = UDim2.new(1, 0, 0, 40)
            b.Position = UDim2.new(0, 0, 0, y)
            b.BackgroundTransparency = 0.3
            b.ZIndex = 20
            b.TextSize = 13
            return b
        end
        local up = pbtn(0, "SUBIR", MID, function() end)
        up.MouseButton1Down:Connect(function() vert = 1 end)
        up.MouseButton1Up:Connect(function() vert = 0 end)
        up.MouseLeave:Connect(function() vert = 0 end)
        local dn = pbtn(46, "DESCER", MID, function() end)
        dn.MouseButton1Down:Connect(function() vert = -1 end)
        dn.MouseButton1Up:Connect(function() vert = 0 end)
        dn.MouseLeave:Connect(function() vert = 0 end)
        local function setFov(d)
            local cam = workspace.CurrentCamera
            if not cam then return end
            local v = math.clamp(cam.FieldOfView + d, 15, 120)
            cam.FieldOfView = v
            if custom.fov then custom.fov = v end
        end
        pbtn(92, "ZOOM +", MID, function() setFov(-5) end)
        pbtn(138, "ZOOM -", MID, function() setFov(5) end)

        local function restore()
            if not photo then return end
            photo = false
            vert = 0
            local cam = workspace.CurrentCamera
            if cam then
                cam.CameraType = Enum.CameraType.Custom
                local h = getHum()
                if h then cam.CameraSubject = h end
            end
            local root = getRoot()
            if root then root.Anchored = wasAnchored end
            photoBar.Visible = false
            tracerLayer.Visible = true
            statLab.Visible = (TX.showStat or TX.showClock) and true or false
            pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
        end
        TX.cleanups[#TX.cleanups + 1] = restore
        pbtn(184, "SAIR", RED, function()
            restore()
            openMenu()
        end)

        local function enterPhoto()
            local cam = workspace.CurrentCamera
            if not cam or photo then return end
            photo = true
            local cf = cam.CFrame
            pPos = cf.Position
            local rx, ry = cf:ToOrientation()
            pPitch, pYaw = rx, ry
            cam.CameraType = Enum.CameraType.Scriptable
            local root = getRoot()
            if root then
                wasAnchored = root.Anchored
                root.Anchored = true
            end
            frame.Visible = false
            bubble.Visible = false
            statLab.Visible = false
            tracerLayer.Visible = false
            photoBar.Visible = true
            pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
            if TX.notify then TX.notify("Modo foto: tire o print pelo aparelho") end
        end
        bind(RunService.RenderStepped, function(dt)
            if not photo then return end
            local cam, h = workspace.CurrentCamera, getHum()
            if not cam then return end
            local rel = h and cam.CFrame:VectorToObjectSpace(h.MoveDirection) or Vector3.zero
            local move = Vector3.zero
            if rel.Magnitude > 0 then
                move = cam.CFrame.LookVector * -rel.Z + cam.CFrame.RightVector * rel.X
            end
            move = move + Vector3.new(0, vert, 0)
            local speed = UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 90 or 30
            pPos = pPos + move * speed * dt
            cam.CFrame = CFrame.new(pPos) * CFrame.fromOrientation(pPitch, pYaw, 0)
        end)
        bind(UIS.InputChanged, function(i, gp)
            if not photo or gp then return end
            local t = i.UserInputType
            if t == Enum.UserInputType.Touch or (t == Enum.UserInputType.MouseMovement and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
                pYaw = pYaw - i.Delta.X * 0.005
                pPitch = math.clamp(pPitch - i.Delta.Y * 0.005, -1.5, 1.5)
            end
        end)
        mkRow(mo, "Modo foto (esconde a UI, camera livre)", "ENTRAR", function()
            enterPhoto()
        end)
    end
    mkRow(mo, "Copiar ID do jogo (PlaceId)", "COPIAR", function()
        if clip then
            pcall(clip, tostring(game.PlaceId))
            modMsg.Text = "PlaceId copiado: " .. game.PlaceId
        else
            modMsg.Text = "PlaceId: " .. game.PlaceId
        end
    end)
    mkRow(mo, "Trocar de servidor", "HOP", function()
        if not http then
            modMsg.Text = "Seu executor nao tem request"
            return
        end
        modMsg.Text = "Procurando servidor..."
        local ok, res = pcall(http, {
            Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100",
            Method = "GET"
        })
        if ok and res and res.StatusCode == 200 then
            local ok2, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if ok2 and data and data.data then
                for _, sv in ipairs(data.data) do
                    if sv.id ~= game.JobId and sv.playing and sv.maxPlayers and sv.playing < sv.maxPlayers then
                        modMsg.Text = "Indo para outro servidor..."
                        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, sv.id, lp) end)
                        return
                    end
                end
            end
        end
        modMsg.Text = "Nao achei outro servidor"
    end)
    mkRow(mo, "Reentrar no jogo", "REJOIN", function()
        pcall(function() TeleportService:Teleport(game.PlaceId, lp) end)
    end)
    mkRow(mo, "Resetar camera e visual", "RESET", function()
        custom.zoom, custom.fov, custom.hour = nil, nil, nil
        fbOn, fogOff, shadowOff = false, false, false
        clearShaders()
        pcall(function() lp.CameraMaxZoomDistance = 128 end)
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = 70 end
        for _, f in ipairs(modResets) do f() end
        for _, f in ipairs(shaderResets) do f() end
        modMsg.Text = "Tudo resetado"
    end)
    closeScript = function()
        flyOn, noclip, infJump, spinOn = false, false, false, false
        espNames, espBox, espLines = false, false, false
        fbOn, fogOff, shadowOff = false, false, false
        for _, f in ipairs(TX.cleanups) do pcall(f) end
        pcall(stopFly)
        pcall(clearESP)
        pcall(clearShaders)
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
        workspace.Gravity = 196.2
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        pcall(function() sound:Destroy() end)
        gui:Destroy()
    end
    mkRow(mo, "Fechar script", "SAIR", function() closeScript() end)
end

------------------------------------------------------------
-- ABA DANCA (R15, R6, por ID e salvas)
------------------------------------------------------------
do
    local danceLists = {
        R15 = {
            {"Danca 1", "507771019"}, {"Danca 2", "507776043"}, {"Danca 3", "507777268"},
            {"Tchau", "507770239"}, {"Apontar", "507770453"},
            {"Comemorar", "507770677"}, {"Rir", "507770818"},
            {"Continencia", "3360689775"}, {"Estadio", "3360686498"},
            {"Inclinar a cabeca", "3360692915"}, {"Dar de ombros", "3576968026"},
            {"Ola", "3344650532"}, {"Hype Dance", "3695333486"},
            {"Floss", "5917459365"}, {"Dorky", "4212455378"},
        },
        R6 = {
            {"Danca 1", "182435998"}, {"Danca 2", "182436842"}, {"Danca 3", "182436935"},
            {"Tchau", "128777973"}, {"Apontar", "128853357"},
            {"Comemorar", "129423030"}, {"Rir", "129423131"},
        },
    }
    local DANCE_FILE = "tutu_dances.json"
    local savedDances = {}
    pcall(function()
        if isfile and readfile and isfile(DANCE_FILE) then
            local d = HttpService:JSONDecode(readfile(DANCE_FILE))
            if type(d) == "table" then savedDances = d end
        end
    end)
    local function writeDances()
        if writefile then
            pcall(function() writefile(DANCE_FILE, HttpService:JSONEncode(savedDances)) end)
        end
    end
    local function isDSaved(id)
        for _, s in ipairs(savedDances) do
            if s[2] == tostring(id) then return true end
        end
        return false
    end

    local dmsg = mkMsg(ds, "Escolha uma danca")
    local curTrack, currentDance = nil, nil
    local danceLoop = true
    local dQueue = {}
    local showSavedD, showRig, showEmotes
    local emoteToken = 0
    local realCache = {}
    local codeD

    local function myRig()
        local h = getHum()
        if h and h.RigType == Enum.HumanoidRigType.R6 then return "R6" end
        return "R15"
    end
    local function stopDance()
        if curTrack then
            pcall(function() curTrack:Stop() end)
            curTrack = nil
        end
    end
    -- emotes do catalogo: o ID da pagina nao e o ID da animacao, entao pegamos o real
    local function resolveAnimId(id)
        local real = nil
        pcall(function()
            local objs = game:GetObjects("rbxassetid://" .. id)
            for _, o in ipairs(objs) do
                local an = o:IsA("Animation") and o or o:FindFirstChildWhichIsA("Animation", true)
                if an and an.AnimationId and an.AnimationId ~= "" then
                    real = an.AnimationId:match("(%d+)")
                    break
                end
            end
            for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
        end)
        return real
    end
    local function playDance(id, name, rig, catalog)
        id = tostring(id)
        local h = getHum()
        if not h then
            dmsg.Text = "Sem personagem"
            return
        end
        local mine = myRig()
        stopDance()
        local animator = h:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = h
        end
        local function load(animId)
            local a = Instance.new("Animation")
            a.AnimationId = "rbxassetid://" .. animId
            local ok, track = pcall(function() return animator:LoadAnimation(a) end)
            if not ok or not track then return nil end
            track.Priority = Enum.AnimationPriority.Action
            track.Looped = danceLoop
            track:Play()
            track:AdjustSpeed(animSpeed)
            return track
        end
        local useId = id
        if catalog then
            useId = realCache[id]
            if not useId then
                dmsg.Text = "Carregando emote..."
                useId = resolveAnimId(id)
                if useId then realCache[id] = useId end
            end
            useId = useId or id
        end
        local track = load(useId)
        if track then
            curTrack = track
            currentDance = {name, useId, rig or mine}
            codeD.Text = useId
            local msg = "Dancando: " .. name
            if rig and rig ~= mine then msg = msg .. " (e " .. rig .. " e voce esta de " .. mine .. ")" end
            dmsg.Text = msg
        else
            dmsg.Text = "Nao carregou essa animacao"
        end
        task.delay(1.5, function()
            if (track and curTrack == track and track.Length == 0) or not track then
                -- tenta achar o ID real da animacao (emote do catalogo)
                dmsg.Text = "Procurando animacao real do emote..."
                local real = resolveAnimId(id)
                if real and real ~= id then
                    stopDance()
                    local t2 = load(real)
                    if t2 then
                        curTrack = t2
                        currentDance = {name, real, rig or mine}
                        codeD.Text = real
                        dmsg.Text = "Dancando: " .. name .. " (ID real " .. real .. ")"
                        task.delay(1.5, function()
                            if curTrack == t2 and t2.Length == 0 then
                                dmsg.Text = "Nao carregou (animacao bloqueada ou rig errado)"
                            end
                        end)
                        return
                    end
                end
                dmsg.Text = "Nao carregou (animacao bloqueada ou rig errado)"
            end
        end)
    end

    -- entrada por ID
    local linkLbl = Instance.new("TextLabel", ds)
    linkLbl.Size = UDim2.new(1, 0, 0, 20)
    linkLbl.BackgroundTransparency = 1
    linkLbl.Text = "ADICIONAR DANCA POR LINK / ID"
    linkLbl.TextColor3 = ACC
    linkLbl.Font = Enum.Font.GothamBold
    linkLbl.TextSize = 12
    linkLbl.TextXAlignment = Enum.TextXAlignment.Left
    linkLbl.LayoutOrder = nextOrder(ds)
    local ir = rowFrame(ds, 42)
    local idBox = mkBox(ir, "Cole o link ou ID da danca")
    idBox.Size = UDim2.new(1, -148, 1, 0)
    local idPlay = mk(ir, "Dancar", ACC, function() end)
    idPlay.Size = UDim2.new(0, 70, 1, 0)
    idPlay.Position = UDim2.new(1, -142, 0, 0)
    idPlay.TextSize = 13
    local idSave = mk(ir, "Salvar", Color3.fromRGB(40, 160, 90), function() end)
    idSave.Size = UDim2.new(0, 70, 1, 0)
    idSave.Position = UDim2.new(1, -70, 0, 0)
    idSave.TextSize = 13

    local cr = rowFrame(ds, 34)
    codeD = mkBox(cr, "ID tocando agora")
    codeD.Size = UDim2.new(1, -78, 1, 0)
    codeD.TextColor3 = ACC
    codeD.Font = Enum.Font.GothamBold
    local cpD = mk(cr, "Copiar", MID, function()
        if codeD.Text ~= "" and clip then
            pcall(clip, codeD.Text)
            dmsg.Text = "ID copiado"
        end
    end)
    cpD.Size = UDim2.new(0, 70, 1, 0)
    cpD.Position = UDim2.new(1, -70, 0, 0)
    cpD.TextSize = 12

    -- controles
    local ctrl = rowFrame(ds, 36)
    local function cb3(i, txt, color, cb)
        local b = mk(ctrl, txt, color, cb)
        b.Size = UDim2.new(1 / 3, -4, 1, 0)
        b.Position = UDim2.new((i - 1) / 3, 0, 0, 0)
        b.TextSize = 12
        return b
    end
    cb3(1, "Parar", RED, function()
        stopDance()
        local h = getHum()
        local a = h and h:FindFirstChildOfClass("Animator")
        if a then
            for _, t in ipairs(a:GetPlayingAnimationTracks()) do
                pcall(function() t:Stop() end)
            end
        end
        dmsg.Text = "Parado (ande um pouco se ficar travado)"
    end)
    cb3(2, "Aleatoria", MID, function()
        if #dQueue == 0 then
            dmsg.Text = "Abra uma lista primeiro"
            return
        end
        local s = dQueue[math.random(1, #dQueue)]
        playDance(s[2], s[1], s[3], s[4])
    end)
    local loopB
    loopB = cb3(3, "Repetir: ON", ACC, function()
        danceLoop = not danceLoop
        loopB.Text = danceLoop and "Repetir: ON" or "Repetir: OFF"
        loopB.BackgroundColor3 = danceLoop and ACC or MID
        if curTrack then pcall(function() curTrack.Looped = danceLoop end) end
    end)

    stepper(ds, "Veloc. da danca", 1, 0.5, 0.5, 5, function(v)
        animSpeed = v
        if curTrack then pcall(function() curTrack:AdjustSpeed(v) end) end
    end)

    -- sincronizar com a musica (usa as dancas salvas/favoritas quando existirem)
    local syncOn, lastSid, lastAuto = false, "", 0
    toggleRow(ds, "Dancar ao ritmo da musica (favoritas)", function(s)
        syncOn = s
        if not s and curTrack then pcall(function() curTrack:AdjustSpeed(animSpeed) end) end
    end)
    bind(RunService.Heartbeat, function()
        if not syncOn then return end
        local playing = sound.IsPlaying
        local sid = sound.SoundId
        local newSong = playing and sid ~= lastSid
        if playing then lastSid = sid end
        if playing and (newSong or not curTrack) and tick() - lastAuto > 1.5 then
            lastAuto = tick()
            local pool = (#savedDances > 0) and savedDances or danceLists[myRig()]
            if pool and #pool > 0 then
                local d = pool[math.random(#pool)]
                playDance(d[2], d[1], d[3] or myRig())
            end
        end
        if curTrack then
            local sp = playing and (math.clamp(0.6 + sound.PlaybackLoudness / 350, 0.5, 2.5) * animSpeed) or 0
            pcall(function() curTrack:AdjustSpeed(sp) end)
        end
    end)

    -- categorias
    local cw = rowFrame(ds, 36)
    local dBtns = {}
    local function setDCat(n)
        for i, b in ipairs(dBtns) do
            tween(b, 0.15, {BackgroundColor3 = (i == n) and ACC or MID})
        end
    end
    local function dcat(i, txt, cb)
        local b = mk(cw, txt, MID, cb)
        b.Size = UDim2.new(1 / 3, -4, 1, 0)
        b.Position = UDim2.new((i - 1) / 3, 0, 0, 0)
        b.TextSize = 13
        dBtns[i] = b
    end
    dcat(1, "Salvas", function() showSavedD() end)
    dcat(2, "R15", function() showRig("R15") end)
    dcat(3, "R6", function() showRig("R6") end)

    local cw2 = rowFrame(ds, 36)
    local function dcat2(i, txt, cb)
        local b = mk(cw2, txt, MID, cb)
        b.Size = UDim2.new(1 / 3, -4, 1, 0)
        b.Position = UDim2.new((i - 1) / 3, 0, 0, 0)
        b.TextSize = 13
        dBtns[i + 3] = b
    end
    dcat2(1, "Populares", function() showEmotes("pop") end)
    dcat2(2, "Brasil", function() showEmotes("br") end)
    dcat2(3, "Emotes", function() showEmotes("search", "") end)

    local sr = rowFrame(ds, 38)
    local eBox = mkBox(sr, "Buscar emote (ex: jamal, floss)")
    eBox.Size = UDim2.new(1, -78, 1, 0)
    local eGo = mk(sr, "Buscar", ACC, function() end)
    eGo.Size = UDim2.new(0, 70, 1, 0)
    eGo.Position = UDim2.new(1, -70, 0, 0)
    eGo.TextSize = 13

    local dHolder = Instance.new("Frame", ds)
    dHolder.Size = UDim2.new(1, 0, 0, 0)
    dHolder.AutomaticSize = Enum.AutomaticSize.Y
    dHolder.BackgroundTransparency = 1
    dHolder.LayoutOrder = nextOrder(ds)
    local dl = Instance.new("UIListLayout", dHolder)
    dl.Padding = UDim.new(0, 6)
    dl.SortOrder = Enum.SortOrder.LayoutOrder

    local function mkDanceRow(name, id, rig, removeMode, isEmote)
        local row = Instance.new("Frame", dHolder)
        row.Size = UDim2.new(1, 0, 0, 46)
        row.BackgroundColor3 = MID
        row.BackgroundTransparency = 0.1
        row.LayoutOrder = nextOrder(dHolder)
        corner(row, 10)
        local bar = Instance.new("Frame", row)
        bar.Size = UDim2.new(0, 4, 0.6, 0)
        bar.Position = UDim2.new(0, 4, 0.2, 0)
        bar.BackgroundColor3 = ACC
        bar.BorderSizePixel = 0
        corner(bar, 4)

        local rl = Instance.new("TextLabel", row)
        rl.Size = UDim2.new(0, 40, 1, 0)
        rl.Position = UDim2.new(1, -88, 0, 0)
        rl.BackgroundTransparency = 1
        rl.Text = rig
        rl.TextColor3 = ACC
        rl.Font = Enum.Font.GothamBold
        rl.TextSize = 12

        local pb = Instance.new("TextButton", row)
        pb.Size = UDim2.new(1, -94, 1, 0)
        pb.BackgroundTransparency = 1
        pb.Text = tostring(name)
        pb.TextColor3 = Color3.new(1, 1, 1)
        pb.Font = Enum.Font.Gotham
        pb.TextSize = 14
        pb.TextXAlignment = Enum.TextXAlignment.Left
        pb.TextTruncate = Enum.TextTruncate.AtEnd
        local pad = Instance.new("UIPadding", pb)
        pad.PaddingLeft = UDim.new(0, 16)
        pb.MouseButton1Down:Connect(function() tween(row, 0.08, {BackgroundColor3 = ACC}) end)
        pb.MouseButton1Up:Connect(function() tween(row, 0.2, {BackgroundColor3 = MID}) end)
        pb.MouseLeave:Connect(function() tween(row, 0.2, {BackgroundColor3 = MID}) end)
        pb.MouseButton1Click:Connect(function() playDance(id, name, rig, isEmote) end)

        local sb
        if removeMode then
            sb = mk(row, "X", RED, function()
                for i, s in ipairs(savedDances) do
                    if s[2] == tostring(id) and s[1] == tostring(name) then
                        table.remove(savedDances, i)
                        break
                    end
                end
                writeDances()
                showSavedD()
            end)
        else
            sb = mk(row, isDSaved(id) and "OK" or "+", Color3.fromRGB(40, 160, 90), function()
                if not isDSaved(id) then
                    table.insert(savedDances, {tostring(name), realCache[tostring(id)] or tostring(id), rig})
                    writeDances()
                    dmsg.Text = "Danca salva: " .. name
                end
                sb.Text = "OK"
            end)
        end
        sb.Size = UDim2.new(0, 34, 0, 32)
        sb.Position = UDim2.new(1, -44, 0.5, -16)
        sb.TextSize = 14
    end

    local function showDList(items, removeMode, emptyText)
        for _, c in ipairs(dHolder:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        dQueue = {}
        for _, s in ipairs(items) do dQueue[#dQueue + 1] = s end
        if #items == 0 then
            local l = Instance.new("TextLabel", dHolder)
            l.Size = UDim2.new(1, 0, 0, 40)
            l.BackgroundTransparency = 1
            l.Text = emptyText
            l.TextWrapped = true
            l.TextColor3 = Color3.fromRGB(175, 182, 205)
            l.Font = Enum.Font.Gotham
            l.TextSize = 13
            l.LayoutOrder = nextOrder(dHolder)
        else
            for _, s in ipairs(items) do mkDanceRow(s[1], s[2], s[3], removeMode) end
        end
    end
    showSavedD = function()
        emoteToken = emoteToken + 1
        setDCat(1)
        showDList(savedDances, true, "Nenhuma danca salva. Aperte + ou Salvar.")
    end
    showRig = function(rig)
        emoteToken = emoteToken + 1
        setDCat(rig == "R15" and 2 or 3)
        local items = {}
        for _, s in ipairs(danceLists[rig]) do items[#items + 1] = {s[1], s[2], rig} end
        showDList(items, false, "")
        dmsg.Text = "Lista " .. rig .. " (voce esta de " .. myRig() .. ")"
    end

    -- emotes do catalogo: populares, brasil e busca
    local EMOTE_URL = "https://catalog.roblox.com/v1/search/items/details?Category=12&Subcategory=39&Limit=30&SortAggregation=5"
    local EMOTE_MAX = 1000
    local BR_KEYS = {"jamal", "brasil", "brazil", "brazilian", "funk", "passinho", "baile", "samba", "capoeira", "favela"}
    local BR_FIXED = {
        {"Jamal Brazil Groove", "123783266553014"},
        {"Passinho do Jamal - EMOVA", "105928003031423"},
    }
    local eMoreBtn = nil

    local function eget(url)
        if not http then return nil end
        local ok1, res = pcall(http, {Url = url, Method = "GET"})
        if ok1 and res and res.StatusCode == 200 then
            local ok2, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if ok2 then return data end
        end
        return nil
    end
    local function fetchEmotes(keyword, sort, cursor)
        local url = EMOTE_URL .. "&SortType=" .. sort
        if keyword and keyword ~= "" then url = url .. "&Keyword=" .. HttpService:UrlEncode(keyword) end
        if cursor then url = url .. "&Cursor=" .. HttpService:UrlEncode(cursor) end
        local d = eget(url)
        if not d or type(d.data) ~= "table" then return nil end
        local out = {}
        for _, it in ipairs(d.data) do
            if it.id and it.name then out[#out + 1] = {tostring(it.name), tostring(it.id)} end
        end
        return out, d.nextPageCursor
    end
    local function clearDHolder()
        for _, c in ipairs(dHolder:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        dQueue = {}
        eMoreBtn = nil
    end
    local function appendEmotes(items)
        for _, s in ipairs(items) do
            dQueue[#dQueue + 1] = {s[1], s[2], "R15", true}
            mkDanceRow(s[1], s[2], "R15", false, true)
        end
    end
    local function setMoreBtn(onClick)
        if eMoreBtn then pcall(function() eMoreBtn:Destroy() end) eMoreBtn = nil end
        if not onClick then return end
        local b = mk(dHolder, "Carregar mais", MID, onClick)
        b.Size = UDim2.new(1, 0, 0, 40)
        b.LayoutOrder = nextOrder(dHolder)
        eMoreBtn = b
    end

    showEmotes = function(mode, q)
        emoteToken = emoteToken + 1
        local my = emoteToken
        if not http then
            dmsg.Text = "Seu executor nao tem request"
            return
        end
        local keyword, sort, label = nil, 2, "Populares"
        if mode == "search" then
            keyword = tostring(q or ""):match("^%s*(.-)%s*$")
            sort = 0
            label = (keyword ~= "") and ("Busca: " .. keyword) or "Emotes"
        end
        setDCat(mode == "pop" and 4 or (mode == "br" and 5 or 6))
        clearDHolder()
        local seen, total = {}, 0

        if mode == "br" then
            local list = {}
            for _, s in ipairs(BR_FIXED) do
                seen[s[2]] = true
                list[#list + 1] = s
            end
            appendEmotes(list)
            total = #list
            for i, k in ipairs(BR_KEYS) do
                if my ~= emoteToken then return end
                dmsg.Text = "Brasil: buscando '" .. k .. "' (" .. i .. "/" .. #BR_KEYS .. ")"
                local items = fetchEmotes(k, 2, nil)
                if my ~= emoteToken then return end
                if items then
                    local fresh = {}
                    for _, s in ipairs(items) do
                        if not seen[s[2]] then
                            seen[s[2]] = true
                            fresh[#fresh + 1] = s
                        end
                    end
                    appendEmotes(fresh)
                    total = total + #fresh
                end
                task.wait(0.5)
            end
            dmsg.Text = "Brasil: " .. total .. " emotes (toque pra dancar)"
            return
        end

        local function page(cursor)
            setMoreBtn(nil)
            dmsg.Text = "Carregando emotes..."
            local items, nextC = fetchEmotes(keyword, sort, cursor)
            if my ~= emoteToken then return end
            if not items then
                dmsg.Text = "Falhou (limite do Roblox). Espere um pouco e tente de novo"
                setMoreBtn(function() page(cursor) end)
                return
            end
            local fresh = {}
            for _, s in ipairs(items) do
                if not seen[s[2]] and total + #fresh < EMOTE_MAX then
                    seen[s[2]] = true
                    fresh[#fresh + 1] = s
                end
            end
            appendEmotes(fresh)
            total = total + #fresh
            if total == 0 then
                dmsg.Text = "Nenhum emote encontrado"
            else
                dmsg.Text = label .. ": " .. total .. " emotes (toque pra dancar)"
            end
            if nextC and total < EMOTE_MAX then
                setMoreBtn(function() page(nextC) end)
            end
        end
        page(nil)
    end

    eGo.MouseButton1Click:Connect(function() showEmotes("search", eBox.Text) end)
    eBox.FocusLost:Connect(function(enter)
        if enter then showEmotes("search", eBox.Text) end
    end)

    local function parseId(t)
        t = t or ""
        return t:match("^%s*(%d+)%s*$")
            or t:match("rbxassetid://(%d+)")
            or t:match("/catalog/(%d+)")
            or t:match("/library/(%d+)")
            or t:match("/store/asset/(%d+)")
            or t:match("[?&]id=(%d+)")
    end
    idPlay.MouseButton1Click:Connect(function()
        local id = parseId(idBox.Text)
        if not id then
            dmsg.Text = "Cole o link ou ID da danca"
            return
        end
        playDance(id, "Danca " .. id, nil)
    end)
    idSave.MouseButton1Click:Connect(function()
        local id = parseId(idBox.Text)
        local name, rig
        if id then
            name, rig = "Danca " .. id, myRig()
        elseif currentDance then
            name, id, rig = currentDance[1], currentDance[2], currentDance[3]
        else
            dmsg.Text = "Digite um ID ou toque uma danca"
            return
        end
        if isDSaved(id) then
            dmsg.Text = "Ja estava salva"
        else
            table.insert(savedDances, {name, id, rig})
            writeDances()
            dmsg.Text = "Danca salva: " .. name .. " (" .. rig .. ")"
        end
    end)
    idBox.FocusLost:Connect(function(enter)
        if enter then
            local id = parseId(idBox.Text)
            if id then playDance(id, "Danca " .. id, nil) end
        end
    end)

    showRig(myRig())
end

------------------------------------------------------------
-- ABA CHAT (IA: Gemini ou ChatGPT) - a chave fica so no seu celular
------------------------------------------------------------
do
    local AI_FILE = "tutu_ai.json"
    local SYSTEM = "Voce e um assistente dentro de um menu de Roblox. Responda sempre em portugues do Brasil, de forma curta e clara."
    local GEMINI_MODELS = {"gemini-2.5-flash-lite", "gemini-3.5-flash", "gemini-3.8-flash"}
    local OPENAI_MODELS = {"gpt-4o-mini", "gpt-5-mini"}

    local cfg = {provider = "gemini", keys = {}}
    pcall(function()
        if isfile and readfile and isfile(AI_FILE) then
            local d = HttpService:JSONDecode(readfile(AI_FILE))
            if type(d) == "table" then
                cfg.provider = (d.provider == "openai") and "openai" or "gemini"
                if type(d.keys) == "table" then cfg.keys = d.keys end
            end
        end
    end)
    local function saveCfg()
        if writefile then
            pcall(function() writefile(AI_FILE, HttpService:JSONEncode(cfg)) end)
        end
    end

    local history = {}
    local busy = false
    local count = 0
    local curBubble = nil
    local updKey

    local cmsg = mkMsg(cs, "Chat com IA")

    -- escolher IA
    local pr = rowFrame(cs, 36)
    local provBtns = {}
    local function paintProv()
        for k, b in pairs(provBtns) do
            tween(b, 0.15, {BackgroundColor3 = (k == cfg.provider) and ACC or MID})
        end
    end
    local function provBtn(i, key, txt)
        local b = mk(pr, txt, MID, function()
            cfg.provider = key
            saveCfg()
            paintProv()
            updKey()
        end)
        b.Size = UDim2.new(1 / 2, -4, 1, 0)
        b.Position = UDim2.new((i - 1) / 2, 0, 0, 0)
        b.TextSize = 13
        provBtns[key] = b
    end
    provBtn(1, "gemini", "Gemini")
    provBtn(2, "openai", "ChatGPT")

    -- chave
    local kinfo = mkMsg(cs, "")
    kinfo.TextSize = 12
    kinfo.TextColor3 = Color3.fromRGB(175, 182, 205)
    local kr = rowFrame(cs, 38)
    local kBox = mkBox(kr, "Cole sua chave aqui")
    kBox.Size = UDim2.new(1, -78, 1, 0)
    local kBtn = mk(kr, "Salvar", Color3.fromRGB(40, 160, 90), function() end)
    kBtn.Size = UDim2.new(0, 70, 1, 0)
    kBtn.Position = UDim2.new(1, -70, 0, 0)
    kBtn.TextSize = 13
    updKey = function()
        local k = cfg.keys[cfg.provider]
        local nm = (cfg.provider == "openai") and "ChatGPT" or "Gemini"
        if k and k ~= "" then
            kinfo.Text = nm .. ": chave salva (termina em " .. tostring(k):sub(-4) .. ")"
        else
            kinfo.Text = nm .. ": cole sua chave acima e toque em Salvar"
        end
    end
    kBtn.MouseButton1Click:Connect(function()
        local k = (kBox.Text or ""):gsub("%s", "")
        if k == "" then
            kinfo.Text = "Cole a chave primeiro"
            return
        end
        cfg.keys[cfg.provider] = k
        saveCfg()
        kBox.Text = ""
        updKey()
    end)

    -- mensagem
    local ir2 = rowFrame(cs, 42)
    local inBox = mkBox(ir2, "Escreva sua mensagem")
    inBox.Size = UDim2.new(1, -148, 1, 0)
    local sendBtn = mk(ir2, "Enviar", ACC, function() end)
    sendBtn.Size = UDim2.new(0, 70, 1, 0)
    sendBtn.Position = UDim2.new(1, -142, 0, 0)
    sendBtn.TextSize = 13
    local clrBtn = mk(ir2, "Limpar", RED, function() end)
    clrBtn.Size = UDim2.new(0, 70, 1, 0)
    clrBtn.Position = UDim2.new(1, -70, 0, 0)
    clrBtn.TextSize = 13

    local function addBubble(text, isUser, order)
        local l = Instance.new("TextLabel", cs)
        l.Name = "ChatBubble"
        l.Size = UDim2.new(1, 0, 0, 0)
        l.AutomaticSize = Enum.AutomaticSize.Y
        l.BackgroundColor3 = isUser and MID or Color3.fromRGB(110, 26, 56)
        l.BackgroundTransparency = 0.1
        l.TextWrapped = true
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Top
        l.TextColor3 = Color3.new(1, 1, 1)
        l.Font = Enum.Font.Gotham
        l.TextSize = 14
        l.Text = text
        l.LayoutOrder = order
        corner(l, 10)
        local pad = Instance.new("UIPadding", l)
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)
        pad.PaddingTop = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 8)
        return l
    end

    local function decode(res)
        local ok, d = pcall(function() return HttpService:JSONDecode(res.Body) end)
        if ok then return d end
        return nil
    end
    local function errText(res, d)
        local code = res and res.StatusCode or 0
        local msg = d and type(d.error) == "table" and d.error.message or nil
        local low = msg and tostring(msg):lower() or ""
        if code == 401 or code == 403 or low:find("api key") then
            return "Chave invalida ou sem permissao"
        end
        if code == 500 or code == 503 then
            return "Servidor do Google lotado agora (" .. code .. "). Tente de novo em instantes"
        end
        if code == 429 then
            return "Limite ou credito acabou (429)" .. (msg and (": " .. tostring(msg):sub(1, 100)) or "")
        end
        return "Erro " .. tostring(code) .. (msg and (": " .. tostring(msg):sub(1, 120)) or "")
    end

    local function askGemini(key)
        local contents = {}
        for _, m in ipairs(history) do
            contents[#contents + 1] = {
                role = (m.role == "user") and "user" or "model",
                parts = {{text = m.text}},
            }
        end
        local lastErr = "Erro desconhecido"
        for _, model in ipairs(GEMINI_MODELS) do
            if curBubble then curBubble.Text = "Pensando... (" .. model .. ")" end
            local payload = {
                systemInstruction = {parts = {{text = SYSTEM}}},
                contents = contents,
                generationConfig = {maxOutputTokens = 800},
            }
            -- modelos 2.5: desliga o "pensar" pra responder mais rapido
            if model:find("2.5") then
                payload.generationConfig.thinkingConfig = {thinkingBudget = 0}
            end
            local ok, res = pcall(http, {
                Url = "https://generativelanguage.googleapis.com/v1beta/models/" .. model .. ":generateContent",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json", ["x-goog-api-key"] = key},
                Body = HttpService:JSONEncode(payload),
            })
            if not ok or not res then
                -- timeout ou queda de conexao: tenta o proximo modelo
                lastErr = "Falha de conexao: " .. tostring(res):sub(1, 100)
            else
                local d = decode(res)
                if res.StatusCode == 200 and d then
                    local text
                    pcall(function()
                        local t = {}
                        for _, p in ipairs(d.candidates[1].content.parts) do
                            if p.text then t[#t + 1] = p.text end
                        end
                        text = table.concat(t)
                    end)
                    if text and text ~= "" then return text end
                    lastErr = "Resposta vazia (tente de novo)"
                else
                    lastErr = errText(res, d)
                    local sc = res.StatusCode
                    if sc ~= 404 and sc ~= 429 and sc ~= 500 and sc ~= 503 then
                        return nil, lastErr
                    end
                end
            end
        end
        return nil, lastErr
    end

    local function askOpenAI(key)
        local msgs = {{role = "system", content = SYSTEM}}
        for _, m in ipairs(history) do
            msgs[#msgs + 1] = {role = m.role, content = m.text}
        end
        local lastErr = "Erro desconhecido"
        for _, model in ipairs(OPENAI_MODELS) do
            if curBubble then curBubble.Text = "Pensando... (" .. model .. ")" end
            local ok, res = pcall(http, {
                Url = "https://api.openai.com/v1/chat/completions",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json", ["Authorization"] = "Bearer " .. key},
                Body = HttpService:JSONEncode({model = model, messages = msgs}),
            })
            if not ok or not res then return nil, "Falha de conexao: " .. tostring(res):sub(1, 100) end
            local d = decode(res)
            if res.StatusCode == 200 and d then
                local text
                pcall(function() text = d.choices[1].message.content end)
                if text and text ~= "" then return text end
                return nil, "Resposta vazia (tente de novo)"
            end
            lastErr = errText(res, d)
            if res.StatusCode ~= 404 then return nil, lastErr end
        end
        return nil, lastErr
    end

    local function send()
        if busy then return end
        local text = tostring(inBox.Text or ""):match("^%s*(.-)%s*$")
        if text == "" then return end
        if not http then
            cmsg.Text = "Seu executor nao tem request"
            return
        end
        local key = cfg.keys[cfg.provider]
        if not key or key == "" then
            updKey()
            cmsg.Text = "Cole a chave e toque em Salvar"
            return
        end
        busy = true
        cmsg.Text = "Chat com IA"
        inBox.Text = ""
        count = count + 1
        addBubble("Voce: " .. text, true, 1000000 - count * 10)
        local ab = addBubble("Pensando...", false, 1000000 - count * 10 + 1)
        curBubble = ab
        local finished = false
        task.delay(60, function()
            if not finished then
                finished = true
                busy = false
                ab.Text = "Sem resposta em 60s. Veja a internet ou troque de rede (Wi-Fi/dados) e tente de novo."
            end
        end)
        history[#history + 1] = {role = "user", text = text}
        while #history > 20 do table.remove(history, 1) end
        local okk, reply, err = pcall(function()
            if cfg.provider == "openai" then return askOpenAI(key) end
            return askGemini(key)
        end)
        finished = true
        if okk and reply then
            history[#history + 1] = {role = "assistant", text = reply}
            ab.Text = reply
        else
            table.remove(history)
            ab.Text = "Erro: " .. tostring(okk and err or reply)
        end
        busy = false
    end
    sendBtn.MouseButton1Click:Connect(send)
    inBox.FocusLost:Connect(function(enter)
        if enter then send() end
    end)
    clrBtn.MouseButton1Click:Connect(function()
        for _, c in ipairs(cs:GetChildren()) do
            if c.Name == "ChatBubble" then c:Destroy() end
        end
        history = {}
        count = 0
        cmsg.Text = "Conversa limpa"
    end)

    paintProv()
    updKey()
end

------------------------------------------------------------
-- ABA JOGOS (velha, cobrinha e memoria)
------------------------------------------------------------
do
    mkMsg(gs, "Jogos  •  escolha um")
    local selRow = rowFrame(gs, 38)
    local selRow2 = rowFrame(gs, 38)
    local gameNames = {"VELHA", "COBRINHA", "MEMÓRIA", "2048", "PONG", "MINAS", "FLAPPY"}
    local selBtns, frames, stoppers = {}, {}, {}
    local active = 1
    local snakeRunning = false

    local function showGame(i)
        active = i
        if i ~= 2 then snakeRunning = false end
        for k, fn in pairs(stoppers) do
            if k ~= i then fn() end
        end
        for k = 1, #gameNames do
            frames[k].Visible = (k == i)
            selBtns[k].BackgroundColor3 = (k == i) and ACC or MID
        end
    end
    for k = 1, #gameNames do
        local top = k <= 4
        local per = top and 4 or 3
        local idx = top and (k - 1) or (k - 5)
        local b = mk(top and selRow or selRow2, gameNames[k], MID, function() showGame(k) end)
        b.Size = UDim2.new(1 / per, -4, 1, 0)
        b.Position = UDim2.new(idx / per, 2, 0, 0)
        b.TextSize = 12
        selBtns[k] = b
    end

    local function newFrame(h)
        local f = Instance.new("Frame", gs)
        f.Size = UDim2.new(1, 0, 0, h)
        f.BackgroundTransparency = 1
        f.LayoutOrder = nextOrder(gs)
        f.Visible = false
        return f
    end
    local function newLabel(parent, y, h, size)
        local l = Instance.new("TextLabel", parent)
        l.Size = UDim2.new(1, 0, 0, h)
        l.Position = UDim2.new(0, 0, 0, y)
        l.BackgroundTransparency = 1
        l.TextColor3 = Color3.new(1, 1, 1)
        l.Font = Enum.Font.GothamBold
        l.TextSize = size
        return l
    end

    ----------------------------------------------------------
    -- 1) JOGO DA VELHA (voce = X, CPU = O)
    ----------------------------------------------------------
    do
        local f = newFrame(318)
        frames[1] = f
        local status = newLabel(f, 0, 24, 15)
        status.Text = "Sua vez  (você é X)"
        local board = Instance.new("Frame", f)
        board.AnchorPoint = Vector2.new(0.5, 0)
        board.Position = UDim2.new(0.5, 0, 0, 30)
        board.Size = UDim2.new(0, 204, 0, 204)
        board.BackgroundTransparency = 1
        local scoreLab = newLabel(f, 240, 20, 12)
        scoreLab.TextColor3 = Color3.fromRGB(170, 178, 205)

        local b = {"", "", "", "", "", "", "", "", ""}
        local cells = {}
        local score = {w = 0, l = 0, d = 0}
        local hard, over = false, false
        local LINES = {{1,2,3},{4,5,6},{7,8,9},{1,4,7},{2,5,8},{3,6,9},{1,5,9},{3,5,7}}

        local function winner(t)
            for _, l in ipairs(LINES) do
                local a = t[l[1]]
                if a ~= "" and a == t[l[2]] and a == t[l[3]] then return a end
            end
            for i = 1, 9 do
                if t[i] == "" then return nil end
            end
            return "draw"
        end
        local function minimax(t, turn)
            local w = winner(t)
            if w == "O" then return 1 end
            if w == "X" then return -1 end
            if w == "draw" then return 0 end
            local best = (turn == "O") and -2 or 2
            for i = 1, 9 do
                if t[i] == "" then
                    t[i] = turn
                    local s = minimax(t, turn == "O" and "X" or "O")
                    t[i] = ""
                    if turn == "O" then
                        if s > best then best = s end
                    else
                        if s < best then best = s end
                    end
                end
            end
            return best
        end
        local function cpuMove()
            local empties = {}
            for i = 1, 9 do
                if b[i] == "" then empties[#empties + 1] = i end
            end
            if #empties == 0 then return end
            local pick
            if hard or math.random() > 0.4 then
                local bestS, bestI = -2, empties[1]
                for _, i in ipairs(empties) do
                    b[i] = "O"
                    local s = minimax(b, "X")
                    b[i] = ""
                    if s > bestS then bestS, bestI = s, i end
                end
                pick = bestI
            else
                pick = empties[math.random(#empties)]
            end
            b[pick] = "O"
        end
        local function render()
            for i = 1, 9 do
                cells[i].Text = b[i]
                cells[i].TextColor3 = (b[i] == "X") and Color3.new(1, 1, 1) or GOOD
            end
            scoreLab.Text = "Vitórias " .. score.w .. "   Empates " .. score.d .. "   Derrotas " .. score.l
        end
        local function reset()
            for i = 1, 9 do b[i] = "" end
            over = false
            status.Text = "Sua vez  (você é X)"
            render()
        end
        local function play(i)
            if over or b[i] ~= "" then return end
            b[i] = "X"
            local w = winner(b)
            if not w then
                cpuMove()
                w = winner(b)
            end
            if w then
                over = true
                if w == "X" then
                    score.w = score.w + 1
                    status.Text = "Você venceu!"
                elseif w == "O" then
                    score.l = score.l + 1
                    status.Text = "A CPU venceu"
                else
                    score.d = score.d + 1
                    status.Text = "Empate"
                end
            end
            render()
        end
        for i = 1, 9 do
            local c = mk(board, "", MID, function() play(i) end)
            c.Size = UDim2.new(0, 64, 0, 64)
            c.Position = UDim2.new(0, ((i - 1) % 3) * 70, 0, math.floor((i - 1) / 3) * 70)
            c.TextSize = 34
            cells[i] = c
        end
        local nb = mk(f, "NOVO JOGO", ACC, reset)
        nb.Size = UDim2.new(0.5, -4, 0, 36)
        nb.Position = UDim2.new(0, 0, 0, 268)
        nb.TextSize = 12
        local db
        db = mk(f, "NÍVEL: NORMAL", MID, function()
            hard = not hard
            db.Text = hard and "NÍVEL: IMPOSSÍVEL" or "NÍVEL: NORMAL"
            reset()
        end)
        db.Size = UDim2.new(0.5, -4, 0, 36)
        db.Position = UDim2.new(0.5, 4, 0, 268)
        db.TextSize = 12
        render()
    end

    ----------------------------------------------------------
    -- 2) COBRINHA
    ----------------------------------------------------------
    do
        local N, CS = 11, 20
        local f = newFrame(342)
        frames[2] = f
        local status = newLabel(f, 0, 24, 14)
        status.Text = "Toque em INICIAR"
        local board = Instance.new("Frame", f)
        board.AnchorPoint = Vector2.new(0.5, 0)
        board.Position = UDim2.new(0.5, 0, 0, 30)
        board.Size = UDim2.new(0, N * CS, 0, N * CS)
        board.BackgroundColor3 = Color3.fromRGB(14, 8, 32)
        board.ClipsDescendants = true
        corner(board, 6)
        local EMPTY = Color3.fromRGB(18, 21, 38)
        local cells = {}
        for y = 0, N - 1 do
            for x = 0, N - 1 do
                local c = Instance.new("Frame", board)
                c.Size = UDim2.new(0, CS - 2, 0, CS - 2)
                c.Position = UDim2.new(0, x * CS + 1, 0, y * CS + 1)
                c.BorderSizePixel = 0
                c.BackgroundColor3 = EMPTY
                cells[y * N + x + 1] = c
            end
        end

        local snake, dir, nextDir, food = {}, {x = 1, y = 0}, {x = 1, y = 0}, {x = 0, y = 0}
        local score, best = 0, 0

        local function draw()
            for i = 1, N * N do cells[i].BackgroundColor3 = EMPTY end
            cells[food.y * N + food.x + 1].BackgroundColor3 = ORANGE
            for i, s in ipairs(snake) do
                cells[s.y * N + s.x + 1].BackgroundColor3 = (i == 1) and Color3.new(1, 1, 1) or GOOD
            end
        end
        local function placeFood()
            local free = {}
            for y = 0, N - 1 do
                for x = 0, N - 1 do
                    local used = false
                    for _, s in ipairs(snake) do
                        if s.x == x and s.y == y then used = true break end
                    end
                    if not used then free[#free + 1] = {x = x, y = y} end
                end
            end
            if #free == 0 then return false end
            food = free[math.random(#free)]
            return true
        end
        local function setStatus()
            status.Text = "Pontos: " .. score .. "   Recorde: " .. best
        end
        local function die()
            snakeRunning = false
            if score > best then best = score end
            status.Text = "Fim!  Pontos: " .. score .. "   Recorde: " .. best
        end
        local function start()
            snake = {{x = 5, y = 5}, {x = 4, y = 5}, {x = 3, y = 5}}
            dir = {x = 1, y = 0}
            nextDir = dir
            score = 0
            placeFood()
            snakeRunning = true
            setStatus()
            draw()
        end
        local function step()
            dir = nextDir
            local head = snake[1]
            local nx, ny = head.x + dir.x, head.y + dir.y
            if nx < 0 or nx >= N or ny < 0 or ny >= N then die() draw() return end
            for i = 1, #snake - 1 do
                if snake[i].x == nx and snake[i].y == ny then die() draw() return end
            end
            table.insert(snake, 1, {x = nx, y = ny})
            if nx == food.x and ny == food.y then
                score = score + 1
                if not placeFood() then
                    draw()
                    die()
                    status.Text = "Você ganhou!  Pontos: " .. score
                    return
                end
                setStatus()
            else
                table.remove(snake)
            end
            draw()
        end
        local function turn(dx, dy)
            if dx == -dir.x and dy == -dir.y then return end
            nextDir = {x = dx, y = dy}
        end

        local pad = {{"◀", -1, 0}, {"▲", 0, -1}, {"▼", 0, 1}, {"▶", 1, 0}}
        for k, p in ipairs(pad) do
            local b = mk(f, p[1], MID, function() turn(p[2], p[3]) end)
            b.Size = UDim2.new(0.25, -4, 0, 44)
            b.Position = UDim2.new((k - 1) / 4, 2, 0, 244)
            b.TextSize = 20
        end
        local sb = mk(f, "INICIAR / REINICIAR", ACC, start)
        sb.Size = UDim2.new(1, 0, 0, 36)
        sb.Position = UDim2.new(0, 0, 0, 296)
        sb.TextSize = 13

        snake = {{x = 5, y = 5}, {x = 4, y = 5}, {x = 3, y = 5}}
        food = {x = 8, y = 5}
        draw()

        task.spawn(function()
            while gui.Parent do
                task.wait(math.max(0.08, 0.2 - score * 0.004))
                if snakeRunning and active == 2 and gamesPage.Visible and frame.Visible then
                    step()
                end
            end
        end)
        bind(UIS.InputBegan, function(i, gp)
            if gp or not snakeRunning or active ~= 2 then return end
            local k = i.KeyCode
            if k == Enum.KeyCode.Up or k == Enum.KeyCode.W then turn(0, -1)
            elseif k == Enum.KeyCode.Down or k == Enum.KeyCode.S then turn(0, 1)
            elseif k == Enum.KeyCode.Left or k == Enum.KeyCode.A then turn(-1, 0)
            elseif k == Enum.KeyCode.Right or k == Enum.KeyCode.D then turn(1, 0) end
        end)
    end

    ----------------------------------------------------------
    -- 3) MEMORIA (8 pares)
    ----------------------------------------------------------
    do
        local f = newFrame(344)
        frames[3] = f
        local status = newLabel(f, 0, 24, 14)
        local grid = Instance.new("Frame", f)
        grid.AnchorPoint = Vector2.new(0.5, 0)
        grid.Position = UDim2.new(0.5, 0, 0, 30)
        grid.Size = UDim2.new(0, 266, 0, 266)
        grid.BackgroundTransparency = 1
        local symbols = {"🍎", "🍌", "🍇", "🍒", "🍋", "🍉", "🍓", "🥝"}
        local vals, shown, done = {}, {}, {}
        local first, lock, moves, found = nil, false, 0, 0
        local cards = {}
        local HID, SHOW, OK = Color3.fromRGB(40, 46, 70), Color3.fromRGB(20, 24, 42), Color3.fromRGB(34, 120, 80)

        local function paint(i)
            local c = cards[i]
            if done[i] then
                c.BackgroundColor3 = OK
                c.Text = vals[i]
            elseif shown[i] then
                c.BackgroundColor3 = SHOW
                c.Text = vals[i]
            else
                c.BackgroundColor3 = HID
                c.Text = "?"
            end
        end
        local function setStatus()
            status.Text = "Jogadas: " .. moves .. "   Pares: " .. found .. "/8"
        end
        local function reset()
            local list = {}
            for _, s in ipairs(symbols) do
                list[#list + 1] = s
                list[#list + 1] = s
            end
            for i = #list, 2, -1 do
                local j = math.random(i)
                list[i], list[j] = list[j], list[i]
            end
            vals = list
            for i = 1, 16 do shown[i] = false done[i] = false end
            first, lock, moves, found = nil, false, 0, 0
            for i = 1, 16 do paint(i) end
            setStatus()
        end
        local function click(i)
            if lock or done[i] or shown[i] then return end
            shown[i] = true
            paint(i)
            if not first then first = i return end
            moves = moves + 1
            local a, c = first, i
            first = nil
            if vals[a] == vals[c] then
                done[a], done[c] = true, true
                shown[a], shown[c] = false, false
                found = found + 1
                paint(a) paint(c)
                if found == 8 then
                    status.Text = "Parabéns! Terminou em " .. moves .. " jogadas"
                else
                    setStatus()
                end
            else
                lock = true
                setStatus()
                task.delay(0.7, function()
                    shown[a], shown[c] = false, false
                    paint(a) paint(c)
                    lock = false
                end)
            end
        end
        for i = 1, 16 do
            local c = mk(grid, "?", HID, function() click(i) end)
            c.Size = UDim2.new(0, 62, 0, 62)
            c.Position = UDim2.new(0, ((i - 1) % 4) * 68, 0, math.floor((i - 1) / 4) * 68)
            c.TextSize = 28
            cards[i] = c
        end
        local nb = mk(f, "NOVO JOGO", ACC, reset)
        nb.Size = UDim2.new(1, 0, 0, 36)
        nb.Position = UDim2.new(0, 0, 0, 302)
        nb.TextSize = 13
        reset()
    end

    ----------------------------------------------------------
    -- 4) 2048
    ----------------------------------------------------------
    do
        local f = newFrame(380)
        frames[4] = f
        local status = newLabel(f, 0, 24, 14)
        local grid = Instance.new("Frame", f)
        grid.AnchorPoint = Vector2.new(0.5, 0)
        grid.Position = UDim2.new(0.5, 0, 0, 28)
        grid.Size = UDim2.new(0, 272, 0, 272)
        grid.BackgroundColor3 = Color3.fromRGB(15, 18, 32)
        corner(grid, 10)
        local bd, cells, score, over = {}, {}, 0, false
        local function tileColor(v)
            if v == 0 then return Color3.fromRGB(30, 36, 58) end
            local t = math.clamp(math.log(v, 2) / 11, 0, 1)
            return Color3.fromRGB(20, 90, 190):Lerp(Color3.fromRGB(255, 150, 40), t)
        end
        for i = 1, 16 do
            local c = Instance.new("TextLabel", grid)
            c.Size = UDim2.new(0, 62, 0, 62)
            c.Position = UDim2.new(0, 4 + ((i - 1) % 4) * 68, 0, 4 + math.floor((i - 1) / 4) * 68)
            c.Font = Enum.Font.GothamBold
            c.TextColor3 = Color3.new(1, 1, 1)
            corner(c, 8)
            cells[i] = c
            bd[i] = 0
        end
        local function paint()
            for i = 1, 16 do
                local v = bd[i]
                cells[i].Text = v > 0 and tostring(v) or ""
                cells[i].BackgroundColor3 = tileColor(v)
                cells[i].TextSize = v >= 1024 and 18 or (v >= 128 and 22 or 26)
            end
            status.Text = over and ("Fim de jogo!  Pontos: " .. score) or ("Pontos: " .. score)
        end
        local function addTile()
            local e = {}
            for i = 1, 16 do
                if bd[i] == 0 then e[#e + 1] = i end
            end
            if #e == 0 then return end
            bd[e[math.random(#e)]] = (math.random() < 0.9) and 2 or 4
        end
        local function canMove()
            for i = 1, 16 do
                if bd[i] == 0 then return true end
                local c = (i - 1) % 4
                if c < 3 and bd[i] == bd[i + 1] then return true end
                if i <= 12 and bd[i] == bd[i + 4] then return true end
            end
            return false
        end
        local function slideLine(line)
            local vals = {}
            for _, v in ipairs(line) do
                if v ~= 0 then vals[#vals + 1] = v end
            end
            local out, gain, i = {}, 0, 1
            while i <= #vals do
                if vals[i + 1] and vals[i] == vals[i + 1] then
                    out[#out + 1] = vals[i] * 2
                    gain = gain + vals[i] * 2
                    i = i + 2
                else
                    out[#out + 1] = vals[i]
                    i = i + 1
                end
            end
            while #out < 4 do out[#out + 1] = 0 end
            return out, gain
        end
        local function move(dir) -- 1 esquerda, 2 direita, 3 cima, 4 baixo
            if over then return end
            local moved = false
            for k = 0, 3 do
                local idx = {}
                for j = 0, 3 do
                    if dir == 1 then idx[#idx + 1] = k * 4 + j + 1
                    elseif dir == 2 then idx[#idx + 1] = k * 4 + (3 - j) + 1
                    elseif dir == 3 then idx[#idx + 1] = j * 4 + k + 1
                    else idx[#idx + 1] = (3 - j) * 4 + k + 1 end
                end
                local line = {}
                for j = 1, 4 do line[j] = bd[idx[j]] end
                local out, gain = slideLine(line)
                for j = 1, 4 do
                    if bd[idx[j]] ~= out[j] then moved = true end
                    bd[idx[j]] = out[j]
                end
                score = score + gain
            end
            if moved then
                addTile()
                if not canMove() then over = true end
            end
            paint()
        end
        local function reset()
            for i = 1, 16 do bd[i] = 0 end
            score, over = 0, false
            addTile()
            addTile()
            paint()
        end
        local labels = {"<", "^", "v", ">"}
        local dirs = {1, 3, 4, 2}
        for k = 1, 4 do
            local b = mk(f, labels[k], MID, function() move(dirs[k]) end)
            b.Size = UDim2.new(0.25, -4, 0, 38)
            b.Position = UDim2.new((k - 1) * 0.25, 2, 0, 282)
            b.TextSize = 18
        end
        local nb = mk(f, "NOVO JOGO", ACC, reset)
        nb.Size = UDim2.new(1, 0, 0, 36)
        nb.Position = UDim2.new(0, 0, 0, 328)
        nb.TextSize = 13
        bind(UIS.InputBegan, function(i, gp)
            if gp or not (f.Visible and gamesPage.Visible) then return end
            local k = i.KeyCode
            if k == Enum.KeyCode.Left or k == Enum.KeyCode.A then move(1)
            elseif k == Enum.KeyCode.Right or k == Enum.KeyCode.D then move(2)
            elseif k == Enum.KeyCode.Up or k == Enum.KeyCode.W then move(3)
            elseif k == Enum.KeyCode.Down or k == Enum.KeyCode.S then move(4) end
        end)
        reset()
    end

    ----------------------------------------------------------
    -- 5) PONG (voce a esquerda, CPU a direita)
    ----------------------------------------------------------
    do
        local f = newFrame(252)
        frames[5] = f
        local status = newLabel(f, 0, 22, 14)
        local W, H, PH, PW, BS = 300, 170, 44, 8, 10
        local area = Instance.new("Frame", f)
        area.AnchorPoint = Vector2.new(0.5, 0)
        area.Position = UDim2.new(0.5, 0, 0, 26)
        area.Size = UDim2.new(0, W, 0, H)
        area.BackgroundColor3 = Color3.fromRGB(13, 15, 28)
        area.ClipsDescendants = true
        corner(area, 8)
        local function box(w, h, color)
            local b = Instance.new("Frame", area)
            b.Size = UDim2.new(0, w, 0, h)
            b.BackgroundColor3 = color
            b.BorderSizePixel = 0
            return b
        end
        local p1 = box(PW, PH, Color3.new(1, 1, 1))
        local p2 = box(PW, PH, Color3.new(1, 1, 1))
        local ball = box(BS, BS, Color3.fromRGB(255, 190, 60))
        local py, cy, bx, by, vx, vy = (H - PH) / 2, (H - PH) / 2, W / 2, H / 2, 0, 0
        local sp, sc, running, dir = 0, 0, false, 0
        local function serve(d)
            bx, by = W / 2, H / 2
            vx = 160 * d
            vy = math.random(-90, 90)
        end
        local function setStatus()
            status.Text = "Voce " .. sp .. "  x  " .. sc .. " CPU   (ate 7)"
        end
        local function newMatch()
            sp, sc, running = 0, 0, true
            py, cy = (H - PH) / 2, (H - PH) / 2
            serve(1)
            setStatus()
        end
        stoppers[5] = function() running = false end
        bind(RunService.Heartbeat, function(dt)
            if not (f.Visible and gamesPage.Visible) then return end
            dt = math.min(dt, 0.05)
            if running then
                local d = dir
                if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Up) then d = -1 end
                if UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.Down) then d = 1 end
                py = math.clamp(py + d * 220 * dt, 0, H - PH)
                bx = bx + vx * dt
                by = by + vy * dt
                if by < 0 then
                    by = 0
                    vy = -vy
                elseif by > H - BS then
                    by = H - BS
                    vy = -vy
                end
                local target = by + BS / 2 - PH / 2
                if cy < target then cy = math.min(cy + 125 * dt, target) else cy = math.max(cy - 125 * dt, target) end
                cy = math.clamp(cy, 0, H - PH)
                if vx < 0 and bx <= 12 + PW and bx >= 4 and by + BS >= py and by <= py + PH then
                    bx = 12 + PW
                    vx = math.min(math.abs(vx) * 1.06, 420)
                    vy = (((by + BS / 2) - (py + PH / 2)) / (PH / 2)) * 170
                end
                if vx > 0 and bx + BS >= W - 12 - PW and bx + BS <= W - 4 and by + BS >= cy and by <= cy + PH then
                    bx = W - 12 - PW - BS
                    vx = -math.min(math.abs(vx) * 1.06, 420)
                    vy = (((by + BS / 2) - (cy + PH / 2)) / (PH / 2)) * 170
                end
                if bx < -BS then
                    sc = sc + 1
                    serve(1)
                    setStatus()
                elseif bx > W then
                    sp = sp + 1
                    serve(-1)
                    setStatus()
                end
                if sp >= 7 or sc >= 7 then
                    running = false
                    status.Text = (sp >= 7 and "Voce venceu!" or "A CPU venceu") .. "  " .. sp .. " x " .. sc
                end
            end
            p1.Position = UDim2.new(0, 12, 0, py)
            p2.Position = UDim2.new(0, W - 12 - PW, 0, cy)
            ball.Position = UDim2.new(0, bx, 0, by)
        end)
        local up = mk(f, "^", MID, function() end)
        up.Size = UDim2.new(0.3, -4, 0, 38)
        up.Position = UDim2.new(0, 0, 0, 204)
        up.TextSize = 18
        up.MouseButton1Down:Connect(function() dir = -1 end)
        up.MouseButton1Up:Connect(function() dir = 0 end)
        up.MouseLeave:Connect(function() dir = 0 end)
        local nb = mk(f, "NOVO JOGO", ACC, newMatch)
        nb.Size = UDim2.new(0.4, -4, 0, 38)
        nb.Position = UDim2.new(0.3, 2, 0, 204)
        nb.TextSize = 13
        local dn = mk(f, "v", MID, function() end)
        dn.Size = UDim2.new(0.3, -4, 0, 38)
        dn.Position = UDim2.new(0.7, 4, 0, 204)
        dn.TextSize = 18
        dn.MouseButton1Down:Connect(function() dir = 1 end)
        dn.MouseButton1Up:Connect(function() dir = 0 end)
        dn.MouseLeave:Connect(function() dir = 0 end)
        status.Text = "Pong  •  segure ^ e v para mexer, toque em NOVO JOGO"
    end

    ----------------------------------------------------------
    -- 6) CAMPO MINADO (8x8, 10 minas)
    ----------------------------------------------------------
    do
        local f = newFrame(386)
        frames[6] = f
        local status = newLabel(f, 0, 24, 14)
        local N, MINES = 8, 10
        local grid = Instance.new("Frame", f)
        grid.AnchorPoint = Vector2.new(0.5, 0)
        grid.Position = UDim2.new(0.5, 0, 0, 28)
        grid.Size = UDim2.new(0, 264, 0, 264)
        grid.BackgroundTransparency = 1
        local cellB, mine, adj, opened, flag = {}, {}, {}, {}, {}
        local flagMode, over, first, nOpen, nFlags = false, false, true, 0, 0
        local CLOSED, OPEN = Color3.fromRGB(40, 46, 70), Color3.fromRGB(18, 21, 38)
        local NUMC = {
            Color3.fromRGB(90, 160, 255), Color3.fromRGB(80, 210, 120), Color3.fromRGB(255, 100, 100),
            Color3.fromRGB(190, 120, 255), Color3.fromRGB(255, 170, 60), Color3.fromRGB(80, 220, 220),
            Color3.new(1, 1, 1), Color3.fromRGB(160, 160, 160),
        }
        local function nb(i)
            local r, c = math.floor((i - 1) / N), (i - 1) % N
            local t = {}
            for dr = -1, 1 do
                for dc = -1, 1 do
                    if not (dr == 0 and dc == 0) then
                        local rr, cc = r + dr, c + dc
                        if rr >= 0 and rr < N and cc >= 0 and cc < N then t[#t + 1] = rr * N + cc + 1 end
                    end
                end
            end
            return t
        end
        local function setStatus()
            status.Text = "Minas: " .. (MINES - nFlags) .. (flagMode and "   [modo bandeira]" or "")
        end
        local function paint(i)
            local b = cellB[i]
            if opened[i] then
                b.BackgroundColor3 = OPEN
                if mine[i] then
                    b.Text = "*"
                    b.TextColor3 = Color3.fromRGB(255, 80, 80)
                elseif adj[i] > 0 then
                    b.Text = tostring(adj[i])
                    b.TextColor3 = NUMC[adj[i]]
                else
                    b.Text = ""
                end
            else
                b.BackgroundColor3 = CLOSED
                if flag[i] then
                    b.Text = "F"
                    b.TextColor3 = Color3.fromRGB(255, 210, 60)
                else
                    b.Text = ""
                end
            end
        end
        local function placeMines(safe)
            local block = {[safe] = true}
            for _, n in ipairs(nb(safe)) do block[n] = true end
            local pool = {}
            for i = 1, N * N do
                if not block[i] then pool[#pool + 1] = i end
            end
            for _ = 1, MINES do
                local k = math.random(#pool)
                mine[pool[k]] = true
                table.remove(pool, k)
            end
            for i = 1, N * N do
                local c = 0
                for _, n in ipairs(nb(i)) do
                    if mine[n] then c = c + 1 end
                end
                adj[i] = c
            end
        end
        local function reveal(i)
            local stack = {i}
            while #stack > 0 do
                local k = table.remove(stack)
                if not opened[k] and not flag[k] then
                    opened[k] = true
                    nOpen = nOpen + 1
                    paint(k)
                    if adj[k] == 0 and not mine[k] then
                        for _, n in ipairs(nb(k)) do
                            if not opened[n] then stack[#stack + 1] = n end
                        end
                    end
                end
            end
        end
        local function click(i)
            if over then return end
            if flagMode then
                if not opened[i] then
                    flag[i] = not flag[i] or nil
                    nFlags = nFlags + (flag[i] and 1 or -1)
                    paint(i)
                    setStatus()
                end
                return
            end
            if flag[i] or opened[i] then return end
            if first then
                placeMines(i)
                first = false
            end
            if mine[i] then
                over = true
                for k = 1, N * N do
                    if mine[k] then
                        opened[k] = true
                        paint(k)
                    end
                end
                status.Text = "Boom! Voce perdeu"
                return
            end
            reveal(i)
            if nOpen == N * N - MINES then
                over = true
                status.Text = "Parabens! Voce venceu"
            end
        end
        local function reset()
            mine, adj, opened, flag = {}, {}, {}, {}
            over, first, nOpen, nFlags = false, true, 0, 0
            for i = 1, N * N do
                adj[i] = 0
                paint(i)
            end
            setStatus()
        end
        for i = 1, N * N do
            local b = mk(grid, "", CLOSED, function() click(i) end)
            b.Size = UDim2.new(0, 30, 0, 30)
            b.Position = UDim2.new(0, ((i - 1) % N) * 33, 0, math.floor((i - 1) / N) * 33)
            b.TextSize = 15
            local uc = b:FindFirstChildOfClass("UICorner")
            if uc then uc.CornerRadius = UDim.new(0, 6) end
            cellB[i] = b
        end
        local modeBtn
        modeBtn = mk(f, "MODO: ABRIR", MID, function()
            flagMode = not flagMode
            modeBtn.Text = flagMode and "MODO: BANDEIRA" or "MODO: ABRIR"
            modeBtn.BackgroundColor3 = flagMode and ACC or MID
            setStatus()
        end)
        modeBtn.Size = UDim2.new(1, 0, 0, 36)
        modeBtn.Position = UDim2.new(0, 0, 0, 298)
        modeBtn.TextSize = 13
        local nb2 = mk(f, "NOVO JOGO", ACC, reset)
        nb2.Size = UDim2.new(1, 0, 0, 36)
        nb2.Position = UDim2.new(0, 0, 0, 340)
        nb2.TextSize = 13
        reset()
    end

    ----------------------------------------------------------
    -- 7) FLAPPY (toque na area para pular)
    ----------------------------------------------------------
    do
        local f = newFrame(246)
        frames[7] = f
        local status = newLabel(f, 0, 22, 14)
        local W, H, GAP, PWID, BX, BSZ = 280, 200, 78, 38, 60, 18
        local area = Instance.new("TextButton", f)
        area.AnchorPoint = Vector2.new(0.5, 0)
        area.Position = UDim2.new(0.5, 0, 0, 26)
        area.Size = UDim2.new(0, W, 0, H)
        area.BackgroundColor3 = Color3.fromRGB(13, 15, 28)
        area.Text = ""
        area.AutoButtonColor = false
        area.ClipsDescendants = true
        corner(area, 8)
        local bird = Instance.new("Frame", area)
        bird.Size = UDim2.new(0, BSZ, 0, BSZ)
        bird.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        bird.BorderSizePixel = 0
        bird.ZIndex = 3
        corner(bird, 9)
        local pipes = {}
        local running, dead, by, vy, score, best = false, false, H / 2, 0, 0, 0
        local function clearPipes()
            for _, p in ipairs(pipes) do
                p.top:Destroy()
                p.bot:Destroy()
            end
            pipes = {}
        end
        local function addPipe()
            local function part()
                local b = Instance.new("Frame", area)
                b.BackgroundColor3 = Color3.fromRGB(60, 200, 110)
                b.BorderSizePixel = 0
                b.ZIndex = 2
                return b
            end
            pipes[#pipes + 1] = {x = W, gy = math.random(24, H - 24 - GAP), top = part(), bot = part(), passed = false}
        end
        local function die()
            running, dead = false, true
            best = math.max(best, score)
        end
        local function startGame()
            clearPipes()
            by, vy, score, dead, running = H / 2, -280, 0, false, true
        end
        stoppers[7] = function()
            running = false
            dead = false
            clearPipes()
        end
        area.MouseButton1Down:Connect(function()
            if running then vy = -280 else startGame() end
        end)
        bind(UIS.InputBegan, function(i, gp)
            if gp or not (f.Visible and gamesPage.Visible) then return end
            if i.KeyCode == Enum.KeyCode.Space then
                if running then vy = -280 else startGame() end
            end
        end)
        bind(RunService.Heartbeat, function(dt)
            if not (f.Visible and gamesPage.Visible) then return end
            dt = math.min(dt, 0.05)
            if running then
                vy = vy + 900 * dt
                by = by + vy * dt
                if #pipes == 0 or pipes[#pipes].x < W - 150 then addPipe() end
                for k = #pipes, 1, -1 do
                    local p = pipes[k]
                    p.x = p.x - 110 * dt
                    if p.x < -PWID then
                        p.top:Destroy()
                        p.bot:Destroy()
                        table.remove(pipes, k)
                    else
                        if BX + BSZ > p.x and BX < p.x + PWID then
                            if by < p.gy or by + BSZ > p.gy + GAP then die() end
                        end
                        if not p.passed and p.x + PWID < BX then
                            p.passed = true
                            score = score + 1
                        end
                    end
                end
                if by < 0 or by + BSZ > H then die() end
            end
            bird.Position = UDim2.new(0, BX, 0, by)
            for _, p in ipairs(pipes) do
                p.top.Position = UDim2.new(0, p.x, 0, 0)
                p.top.Size = UDim2.new(0, PWID, 0, p.gy)
                p.bot.Position = UDim2.new(0, p.x, 0, p.gy + GAP)
                p.bot.Size = UDim2.new(0, PWID, 0, H - (p.gy + GAP))
            end
            if running then
                status.Text = "Pontos: " .. score .. "   (recorde " .. best .. ")"
            elseif dead then
                status.Text = "Bateu! Pontos: " .. score .. "  -  toque para jogar de novo"
            else
                status.Text = "Toque na area para comecar"
            end
        end)
        status.Text = "Toque na area para comecar"
    end


    showGame(1)
end

------------------------------------------------------------
-- ABA CALCULADORA
------------------------------------------------------------
do
    local expr, lastAns, fresh = "", "0", false
    local hist = {}

    -- avaliador proprio (sem loadstring): + - * / ^ % e parenteses
    local function evaluate(src)
        local pos = 1
        local function peek() return src:sub(pos, pos) end
        local parseExpr
        local function parseNumber()
            local s, e = src:find("^%d*%.?%d*", pos)
            local str = src:sub(s, e)
            if str == "" or str == "." then error("numero") end
            pos = e + 1
            return tonumber(str)
        end
        local parsePrimary
        parsePrimary = function()
            local c = peek()
            if c == "(" then
                pos = pos + 1
                local v = parseExpr()
                if peek() ~= ")" then error("parenteses") end
                pos = pos + 1
                return v
            elseif c == "-" then
                pos = pos + 1
                return -parsePrimary()
            elseif c == "+" then
                pos = pos + 1
                return parsePrimary()
            end
            return parseNumber()
        end
        local function parsePostfix()
            local v = parsePrimary()
            while peek() == "%" do
                pos = pos + 1
                v = v / 100
            end
            return v
        end
        local function parsePow()
            local v = parsePostfix()
            if peek() == "^" then
                pos = pos + 1
                local e = parsePow()
                v = v ^ e
            end
            return v
        end
        local function parseTerm()
            local v = parsePow()
            while true do
                local c = peek()
                if c == "*" then
                    pos = pos + 1
                    v = v * parsePow()
                elseif c == "/" then
                    pos = pos + 1
                    local d = parsePow()
                    if d == 0 then error("div0") end
                    v = v / d
                else
                    break
                end
            end
            return v
        end
        parseExpr = function()
            local v = parseTerm()
            while true do
                local c = peek()
                if c == "+" then
                    pos = pos + 1
                    v = v + parseTerm()
                elseif c == "-" then
                    pos = pos + 1
                    v = v - parseTerm()
                else
                    break
                end
            end
            return v
        end
        local v = parseExpr()
        if pos <= #src then error("sintaxe") end
        return v
    end

    local function fmt(v)
        if v == math.floor(v) and math.abs(v) < 1e15 then
            return string.format("%.0f", v)
        end
        return string.format("%.10g", v)
    end
    local function pretty(s)
        local a = s:gsub("%*", "×")
        local b = a:gsub("/", "÷")
        return b
    end

    -- visor
    local dispF = rowFrame(calcs, 74)
    local dbg = Instance.new("Frame", dispF)
    dbg.Size = UDim2.new(1, 0, 1, 0)
    dbg.BackgroundColor3 = Color3.fromRGB(10, 5, 24)
    corner(dbg, 10)
    local dst = Instance.new("UIStroke", dbg)
    dst.Color = ACC
    dst.Transparency = 0.6
    dst.Thickness = 1
    local small = Instance.new("TextLabel", dbg)
    small.Size = UDim2.new(1, -20, 0, 20)
    small.Position = UDim2.new(0, 10, 0, 6)
    small.BackgroundTransparency = 1
    small.Text = ""
    small.TextColor3 = Color3.fromRGB(165, 172, 198)
    small.Font = Enum.Font.Gotham
    small.TextSize = 12
    small.TextXAlignment = Enum.TextXAlignment.Right
    small.TextTruncate = Enum.TextTruncate.AtEnd
    local big = Instance.new("TextLabel", dbg)
    big.Size = UDim2.new(1, -20, 0, 38)
    big.Position = UDim2.new(0, 10, 0, 28)
    big.BackgroundTransparency = 1
    big.Text = "0"
    big.TextColor3 = Color3.new(1, 1, 1)
    big.Font = Enum.Font.GothamBold
    big.TextSize = 28
    big.TextXAlignment = Enum.TextXAlignment.Right

    local function update()
        local s = pretty(expr)
        if s == "" then s = "0" end
        if #s > 16 then s = "…" .. s:sub(-15) end
        big.Text = s
    end

    local histLab
    local function pushHist(line)
        table.insert(hist, 1, line)
        while #hist > 5 do table.remove(hist) end
        if histLab then histLab.Text = table.concat(hist, "\n") end
    end

    local OPS = {["+"] = true, ["-"] = true, ["*"] = true, ["/"] = true, ["^"] = true}
    local function add(tok)
        if fresh then
            if OPS[tok] or tok == "%" then
                expr = lastAns
            else
                expr = ""
            end
            fresh = false
        end
        local last = expr:sub(-1)
        if OPS[tok] and tok ~= "-" and (expr == "" or OPS[last]) then
            if expr ~= "" then expr = expr:sub(1, -2) .. tok end
            update()
            return
        end
        if tok == "." or tok:match("^%d$") then
            local seg = expr:match("[%d%.]*$") or ""
            if tok == "." then
                if seg:find("%.") then return end
                if seg == "" then tok = "0." end
            end
        end
        if #expr < 60 then expr = expr .. tok end
        update()
    end

    local function equals()
        if expr == "" then return end
        local ok, v = pcall(evaluate, expr)
        if ok and type(v) == "number" and v == v and math.abs(v) ~= math.huge then
            local s = fmt(v)
            pushHist(pretty(expr) .. " = " .. s)
            small.Text = pretty(expr) .. " ="
            lastAns = s
            expr = s
            fresh = true
        else
            small.Text = "Erro"
            expr = ""
            fresh = false
        end
        update()
    end

    local function press(t)
        if t == "C" then
            expr = "" fresh = false small.Text = ""
            update()
        elseif t == "⌫" then
            if fresh then expr = "" fresh = false else expr = expr:sub(1, -2) end
            update()
        elseif t == "=" then
            equals()
        elseif t == "ANS" then
            add(lastAns)
        elseif t == "÷" then add("/")
        elseif t == "×" then add("*")
        elseif t == "−" then add("-")
        else
            add(t)
        end
    end

    -- teclado
    local grid = Instance.new("Frame", calcs)
    grid.Size = UDim2.new(1, 0, 0, 5 * 46)
    grid.BackgroundTransparency = 1
    grid.LayoutOrder = nextOrder(calcs)
    local gl = Instance.new("UIGridLayout", grid)
    gl.CellSize = UDim2.new(0.25, -5, 0, 40)
    gl.CellPadding = UDim2.new(0, 6, 0, 6)
    gl.SortOrder = Enum.SortOrder.LayoutOrder

    local NUM = Color3.fromRGB(36, 42, 66)
    local FN = Color3.fromRGB(120, 28, 58)
    local rows = {
        {"C", "⌫", "(", ")"},
        {"7", "8", "9", "÷"},
        {"4", "5", "6", "×"},
        {"1", "2", "3", "−"},
        {"0", ".", "%", "+"},
    }
    local idx = 0
    for _, r in ipairs(rows) do
        for _, t in ipairs(r) do
            idx = idx + 1
            local col = NUM
            if t == "C" then col = RED
            elseif t == "⌫" or t == "(" or t == ")" or t == "%" then col = FN
            elseif t == "÷" or t == "×" or t == "−" or t == "+" then col = ACC end
            local b = mk(grid, t, col, function() press(t) end)
            b.LayoutOrder = idx
            b.TextSize = 18
        end
    end

    local last = rowFrame(calcs, 40)
    local function wide(txt, col, x0, w, off, cb)
        local b = mk(last, txt, col, cb)
        b.Position = UDim2.new(x0, off, 0, 0)
        b.Size = UDim2.new(w, -5, 1, 0)
        b.TextSize = 18
        return b
    end
    wide("^", FN, 0, 0.25, 0, function() press("^") end)
    wide("ANS", FN, 0.25, 0.25, 3, function() press("ANS") end)
    wide("=", GOOD, 0.5, 0.5, 6, function() press("=") end)

    mkRow(calcs, "Copiar resultado", "COPIAR", function()
        if clip then
            pcall(clip, lastAns)
            if TX.notify then TX.notify("Resultado copiado") end
        end
    end)

    mkMsg(calcs, "Histórico")
    local hf = rowFrame(calcs, 84)
    histLab = Instance.new("TextLabel", hf)
    histLab.Size = UDim2.new(1, 0, 1, 0)
    histLab.BackgroundTransparency = 1
    histLab.Text = ""
    histLab.TextColor3 = Color3.fromRGB(170, 178, 205)
    histLab.Font = Enum.Font.Gotham
    histLab.TextSize = 13
    histLab.TextXAlignment = Enum.TextXAlignment.Left
    histLab.TextYAlignment = Enum.TextYAlignment.Top
    histLab.TextWrapped = true
    update()
end

------------------------------------------------------------
-- ABA NOTAS (bloco de notas salvo no arquivo local)
------------------------------------------------------------
do
    local ns = UI.ns
    local NOTE_FILE = "tutu_notes.json"
    local canSaveN = (writefile and readfile and isfile) and true or false
    local notes = {"", "", ""}
    pcall(function()
        if canSaveN and isfile(NOTE_FILE) then
            local d = HttpService:JSONDecode(readfile(NOTE_FILE))
            if type(d) == "table" then
                for k = 1, 3 do
                    if type(d[k]) == "string" then notes[k] = d[k] end
                end
            end
        end
    end)
    mkMsg(ns, canSaveN and "Notas  •  salvas no arquivo" or "Notas  •  seu executor nao salva arquivo")
    local slot = 1
    local slotRow = rowFrame(ns, 36)
    local slotBtns = {}
    local tb
    local function writeNotes()
        if not canSaveN then return end
        pcall(function() writefile(NOTE_FILE, HttpService:JSONEncode(notes)) end)
    end
    local function paintSlots()
        for k, b in ipairs(slotBtns) do
            b.BackgroundColor3 = (k == slot) and ACC or MID
        end
    end
    for k = 1, 3 do
        local b = mk(slotRow, "Nota " .. k, MID, function()
            notes[slot] = tb.Text
            slot = k
            tb.Text = notes[k]
            paintSlots()
        end)
        b.Size = UDim2.new(1 / 3, -4, 1, 0)
        b.Position = UDim2.new((k - 1) / 3, 2, 0, 0)
        b.TextSize = 13
        slotBtns[k] = b
    end
    local boxRow = rowFrame(ns, 210)
    tb = Instance.new("TextBox", boxRow)
    tb.Size = UDim2.new(1, 0, 1, 0)
    tb.BackgroundColor3 = MID
    tb.BackgroundTransparency = 0.1
    tb.MultiLine = true
    tb.TextWrapped = true
    tb.ClearTextOnFocus = false
    tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.TextYAlignment = Enum.TextYAlignment.Top
    tb.PlaceholderText = "Escreva suas notas aqui..."
    tb.PlaceholderColor3 = Color3.fromRGB(135, 142, 168)
    tb.TextColor3 = Color3.new(1, 1, 1)
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 14
    tb.Text = notes[1]
    corner(tb, 10)
    local nst = Instance.new("UIStroke", tb)
    nst.Color = ACC
    nst.Transparency = 0.7
    nst.Thickness = 1
    local npad = Instance.new("UIPadding", tb)
    npad.PaddingLeft = UDim.new(0, 10)
    npad.PaddingRight = UDim.new(0, 10)
    npad.PaddingTop = UDim.new(0, 8)
    npad.PaddingBottom = UDim.new(0, 8)
    local saveTokN = 0
    tb:GetPropertyChangedSignal("Text"):Connect(function()
        notes[slot] = tb.Text
        saveTokN = saveTokN + 1
        local t = saveTokN
        task.delay(0.8, function()
            if t == saveTokN then writeNotes() end
        end)
    end)
    tb.FocusLost:Connect(function() writeNotes() end)
    paintSlots()

    local act = rowFrame(ns, 36)
    local function actBtn(i, txt, color, cb)
        local b = mk(act, txt, color, cb)
        b.Size = UDim2.new(1 / 3, -4, 1, 0)
        b.Position = UDim2.new((i - 1) / 3, 2, 0, 0)
        b.TextSize = 13
        return b
    end
    actBtn(1, "COPIAR", MID, function()
        if clip then pcall(clip, tb.Text) end
        if TX.notify then TX.notify(clip and "Nota copiada" or "Executor sem copiar") end
    end)
    local armed = false
    local clr
    clr = actBtn(2, "LIMPAR", RED, function()
        if not armed then
            armed = true
            clr.Text = "CONFIRMAR?"
            task.delay(2, function()
                armed = false
                pcall(function() clr.Text = "LIMPAR" end)
            end)
        else
            armed = false
            clr.Text = "LIMPAR"
            tb.Text = ""
            writeNotes()
        end
    end)
    actBtn(3, "SALVAR", Color3.fromRGB(40, 160, 90), function()
        notes[slot] = tb.Text
        writeNotes()
        if TX.notify then TX.notify(canSaveN and "Nota salva" or "Sem arquivo: so nesta sessao") end
    end)
end

------------------------------------------------------------
-- ABA CRONOMETRO E TIMER
------------------------------------------------------------
do
    local tms, timerPage = UI.tms, UI.timerPage
    local function fmtT(t, tenth)
        t = math.max(t, 0)
        local m = math.floor(t / 60)
        local s = math.floor(t % 60)
        if tenth then return string.format("%02d:%02d.%d", m, s, math.floor((t * 10) % 10)) end
        return string.format("%02d:%02d", m, s)
    end
    local function bigLabel(parent)
        local r = rowFrame(parent, 56)
        local l = Instance.new("TextLabel", r)
        l.Size = UDim2.new(1, 0, 1, 0)
        l.BackgroundTransparency = 1
        l.TextColor3 = Color3.new(1, 1, 1)
        l.Font = Enum.Font.GothamBlack
        l.TextSize = 38
        return l
    end
    local function btnRow(parent, defs)
        local r = rowFrame(parent, 38)
        local n = #defs
        local out = {}
        for i, d in ipairs(defs) do
            local b = mk(r, d[1], d[2], d[3])
            b.Size = UDim2.new(1 / n, -4, 1, 0)
            b.Position = UDim2.new((i - 1) / n, 2, 0, 0)
            b.TextSize = 13
            out[i] = b
        end
        return out
    end

    ---------------- cronometro ----------------
    mkMsg(tms, "Cronometro")
    local swLab = bigLabel(tms)
    swLab.Text = "00:00.0"
    local swRun, swStart, swAcc, laps = false, 0, 0, {}
    local lapLab
    local function swElapsed()
        return swAcc + (swRun and (tick() - swStart) or 0)
    end
    local swBtns
    swBtns = btnRow(tms, {
        {"INICIAR", ACC, function()
            if swRun then
                swAcc = swElapsed()
                swRun = false
                swBtns[1].Text = "CONTINUAR"
            else
                swStart = tick()
                swRun = true
                swBtns[1].Text = "PAUSAR"
            end
        end},
        {"VOLTA", MID, function()
            if swElapsed() <= 0 then return end
            laps[#laps + 1] = fmtT(swElapsed(), true)
            local lines = {}
            for k = #laps, math.max(#laps - 9, 1), -1 do
                lines[#lines + 1] = k .. ".  " .. laps[k]
            end
            lapLab.Text = table.concat(lines, "\n")
        end},
        {"ZERAR", RED, function()
            swRun, swAcc, laps = false, 0, {}
            swBtns[1].Text = "INICIAR"
            lapLab.Text = ""
            swLab.Text = "00:00.0"
        end},
    })
    lapLab = Instance.new("TextLabel", tms)
    lapLab.Size = UDim2.new(1, 0, 0, 0)
    lapLab.AutomaticSize = Enum.AutomaticSize.Y
    lapLab.BackgroundTransparency = 1
    lapLab.TextColor3 = Color3.fromRGB(190, 196, 220)
    lapLab.Font = Enum.Font.Gotham
    lapLab.TextSize = 13
    lapLab.TextXAlignment = Enum.TextXAlignment.Left
    lapLab.TextYAlignment = Enum.TextYAlignment.Top
    lapLab.Text = ""
    lapLab.LayoutOrder = nextOrder(tms)

    ---------------- timer ----------------
    mkMsg(tms, "Timer (contagem regressiva)")
    local tmLab = bigLabel(tms)
    local tmMin, tmSec = 5, 0
    local tmRun, tmLeft, tmEnd = false, 300, 0
    tmLab.Text = fmtT(tmLeft)
    local function total() return tmMin * 60 + tmSec end
    stepper(tms, "Minutos", 5, 1, 0, 180, function(v)
        tmMin = v
        if not tmRun then
            tmLeft = total()
            tmLab.Text = fmtT(tmLeft)
        end
    end)
    stepper(tms, "Segundos", 0, 5, 0, 55, function(v)
        tmSec = v
        if not tmRun then
            tmLeft = total()
            tmLab.Text = fmtT(tmLeft)
        end
    end)
    local beep = Instance.new("Sound", gui)
    beep.SoundId = "rbxasset://sounds/electronicpingshort.wav"
    beep.Volume = 1
    btnRow(tms, {
        {"INICIAR", ACC, function()
            if tmRun then return end
            if tmLeft <= 0 then tmLeft = total() end
            if tmLeft <= 0 then return end
            tmEnd = tick() + tmLeft
            tmRun = true
        end},
        {"PAUSAR", MID, function()
            if not tmRun then return end
            tmLeft = math.max(tmEnd - tick(), 0)
            tmRun = false
        end},
        {"ZERAR", RED, function()
            tmRun = false
            tmLeft = total()
            tmLab.TextColor3 = Color3.new(1, 1, 1)
            tmLab.Text = fmtT(tmLeft)
        end},
    })
    bind(RunService.Heartbeat, function()
        if timerPage.Visible then
            swLab.Text = fmtT(swElapsed(), true)
        end
        if tmRun then
            local left = tmEnd - tick()
            if left <= 0 then
                tmRun = false
                tmLeft = 0
                tmLab.Text = "00:00"
                tmLab.TextColor3 = Color3.fromRGB(255, 90, 90)
                if TX.notify then TX.notify("Timer acabou!") end
                task.spawn(function()
                    for _ = 1, 4 do
                        pcall(function() beep:Play() end)
                        task.wait(0.5)
                    end
                end)
            elseif timerPage.Visible then
                tmLab.TextColor3 = Color3.new(1, 1, 1)
                tmLab.Text = fmtT(left)
            end
        end
    end)
end

------------------------------------------------------------
-- ABA CONVERSOR (unidades e moeda)
------------------------------------------------------------
do
    local cvs = UI.cvs
    local CATS = {
        {"Comprimento", {{"m", 1}, {"km", 1000}, {"cm", 0.01}, {"mm", 0.001}, {"milha", 1609.344}, {"pe", 0.3048}, {"polegada", 0.0254}}},
        {"Peso", {{"kg", 1}, {"g", 0.001}, {"libra", 0.45359237}, {"onca", 0.028349523}}},
        {"Volume", {{"litro", 1}, {"mL", 0.001}, {"galao US", 3.785411784}, {"copo", 0.25}}},
        {"Velocidade", {{"km/h", 1}, {"m/s", 3.6}, {"mph", 1.609344}, {"nos", 1.852}}},
        {"Temperatura", {{"C"}, {"F"}, {"K"}}, kind = "temp"},
        {"Moeda", {{"BRL"}, {"USD"}, {"EUR"}, {"GBP"}, {"JPY"}, {"ARS"}}, kind = "cur"},
    }
    local cat, from, to = 1, 1, 2
    local rates, ratesAt = nil, 0
    local msg = mkMsg(cvs, "Conversor")
    local fnum
    fnum = function(x)
        if x ~= x or x == math.huge or x == -math.huge then return "?" end
        return string.format("%.8g", x)
    end
    local resLab
    local function loadRates()
        if rates and tick() - ratesAt < 600 then return end
        if not http then
            msg.Text = "Conversor  •  executor sem request (sem cotacao)"
            return
        end
        msg.Text = "Conversor  •  buscando cotacao..."
        task.spawn(function()
            local ok, res = pcall(http, {Url = "https://open.er-api.com/v6/latest/USD", Method = "GET"})
            if ok and res and res.StatusCode == 200 then
                local ok2, d = pcall(function() return HttpService:JSONDecode(res.Body) end)
                if ok2 and d and d.rates then
                    rates, ratesAt = d.rates, tick()
                    msg.Text = "Conversor  •  cotacao atualizada"
                    if TX.convRefresh then TX.convRefresh() end
                    return
                end
            end
            msg.Text = "Conversor  •  nao consegui a cotacao"
        end)
    end
    local function convert(v)
        local c = CATS[cat]
        local fu, tu = c[2][from], c[2][to]
        if c.kind == "temp" then
            local cc
            if fu[1] == "C" then cc = v
            elseif fu[1] == "F" then cc = (v - 32) * 5 / 9
            else cc = v - 273.15 end
            if tu[1] == "C" then return cc
            elseif tu[1] == "F" then return cc * 9 / 5 + 32
            else return cc + 273.15 end
        elseif c.kind == "cur" then
            if not rates or not rates[fu[1]] or not rates[tu[1]] then return nil end
            return v / rates[fu[1]] * rates[tu[1]]
        end
        return v * fu[2] / tu[2]
    end
    local inRow = rowFrame(cvs, 40)
    local inBox = mkBox(inRow, "Valor")
    inBox.Size = UDim2.new(1, 0, 1, 0)
    inBox.Text = "1"
    inBox.TextXAlignment = Enum.TextXAlignment.Center
    local catLab, fromLab, toLab
    local function refresh()
        local c = CATS[cat]
        catLab.Text = c[1]
        fromLab.Text = c[2][from][1]
        toLab.Text = c[2][to][1]
        local v = tonumber((inBox.Text:gsub(",", ".")))
        if not v then
            resLab.Text = "..."
            return
        end
        local r = convert(v)
        resLab.Text = r and (fnum(v) .. " " .. c[2][from][1] .. "  =  " .. fnum(r) .. " " .. c[2][to][1]) or "sem cotacao ainda"
    end
    TX.convRefresh = refresh
    local _
    _, catLab = mkRow(cvs, "Tipo (toque para trocar)", "", function()
        cat = cat % #CATS + 1
        from, to = 1, 2
        if CATS[cat].kind == "cur" then loadRates() end
        refresh()
    end)
    _, fromLab = mkRow(cvs, "De", "", function()
        from = from % #CATS[cat][2] + 1
        refresh()
    end)
    _, toLab = mkRow(cvs, "Para", "", function()
        to = to % #CATS[cat][2] + 1
        refresh()
    end)
    mkRow(cvs, "Inverter De / Para", "TROCAR", function()
        from, to = to, from
        refresh()
    end)
    local resRow = rowFrame(cvs, 60)
    resLab = Instance.new("TextLabel", resRow)
    resLab.Size = UDim2.new(1, 0, 1, 0)
    resLab.BackgroundTransparency = 1
    resLab.TextColor3 = Color3.new(1, 1, 1)
    resLab.Font = Enum.Font.GothamBold
    resLab.TextSize = 16
    resLab.TextWrapped = true
    mkRow(cvs, "Copiar resultado", "COPIAR", function()
        if clip then
            local v = tonumber((inBox.Text:gsub(",", ".")))
            local r = v and convert(v)
            if r then pcall(clip, fnum(r)) end
        end
    end)
    inBox:GetPropertyChangedSignal("Text"):Connect(refresh)
    refresh()
end

------------------------------------------------------------
-- ABA CONFIGURACOES (cor RGB, perfis, visual, bolinha e janela)
------------------------------------------------------------
do
    local CFG_FILE = "tutuzx_ruby_cfg.json"
    local canSave = (writefile and readfile and isfile) and true or false
    local themes = {
        {"Ruby", Color3.fromRGB(225, 29, 72)},
        {"Ciano", Color3.fromRGB(0, 190, 255)},
        {"Roxo", Color3.fromRGB(150, 70, 255)},
        {"Azul", Color3.fromRGB(50, 130, 255)},
        {"Rosa", Color3.fromRGB(255, 80, 190)},
        {"Verde", Color3.fromRGB(40, 200, 120)},
        {"Laranja", ORANGE},
        {"Vermelho", Color3.fromRGB(235, 55, 75)},
    }
    local KEYS = {"RightShift", "RightControl", "Insert", "F4", "Home"}
    local KEYN = {"RShift", "RCtrl", "Insert", "F4", "Home"}
    local FONTN = {"Gotham", "Arial", "Code", "Ubuntu"}
    local POSN = {"Topo", "Baixo"}
    local DEF = {
        scale = 1, trans = 0, text = 1,
        r = 225, g = 29, b = 72, rainbow = false, rspeed = 1,
        compact = false, font = 1, spin = false, bg = true, bgtrans = 0.75,
        bsize = 60, btrans = 0,
        lock = false, key = true, keyIdx = 1, startMin = false, dbl = true, scan = false, beam = false, hudc = false,
        notif = true, npos = 1, clicks = false,
        p1 = "", p2 = "", p3 = "",
    }
    local cur = {}
    for k, v in pairs(DEF) do cur[k] = v end
    pcall(function()
        if canSave and isfile(CFG_FILE) then
            local d = HttpService:JSONDecode(readfile(CFG_FILE))
            for k, v in pairs(d) do
                if DEF[k] ~= nil and type(v) == type(DEF[k]) then cur[k] = v end
            end
            if d.r == nil and type(d.theme) == "number" and themes[d.theme] then
                local c = themes[d.theme][2]
                cur.r = math.floor(c.R * 255 + 0.5)
                cur.g = math.floor(c.G * 255 + 0.5)
                cur.b = math.floor(c.B * 255 + 0.5)
            end
        end
    end)
    cur.r = math.clamp(math.floor(cur.r), 0, 255)
    cur.g = math.clamp(math.floor(cur.g), 0, 255)
    cur.b = math.clamp(math.floor(cur.b), 0, 255)
    if cur.keyIdx < 1 or cur.keyIdx > #KEYS then cur.keyIdx = 1 end
    if cur.font < 1 or cur.font > #FONTN then cur.font = 1 end
    if cur.npos < 1 or cur.npos > 2 then cur.npos = 1 end

    local function curColor() return Color3.fromRGB(cur.r, cur.g, cur.b) end
    -- deixa a cor 1 ponto diferente pra nao ser "recolorida" junto com o tema
    local function distinct(c)
        local r = math.floor(c.R * 255 + 0.5)
        local g = math.floor(c.G * 255 + 0.5)
        local b = math.floor(c.B * 255 + 0.5)
        if b < 255 then b = b + 1 else b = b - 1 end
        return Color3.fromRGB(r, g, b)
    end

    local function save()
        if not canSave then return end
        pcall(function() writefile(CFG_FILE, HttpService:JSONEncode(cur)) end)
    end
    local saveTok = 0
    local function saveSoon()
        saveTok = saveTok + 1
        local t = saveTok
        task.delay(0.6, function()
            if t == saveTok then save() end
        end)
    end

    ----------------------------------------------------------
    -- avisos e sons
    ----------------------------------------------------------
    local toast = Instance.new("TextLabel", gui)
    toast.Size = UDim2.new(0, 210, 0, 34)
    toast.BackgroundColor3 = Color3.fromRGB(15, 18, 32)
    toast.TextColor3 = Color3.new(1, 1, 1)
    toast.Font = Enum.Font.GothamBold
    toast.TextSize = 14
    toast.ZIndex = 50
    toast.Visible = false
    corner(toast, 10)
    local toastStroke = Instance.new("UIStroke", toast)
    toastStroke.Thickness = 1.5
    toastStroke.Color = ACC
    local toastId = 0
    TX.notify = function(txt)
        if not cur.notif then return end
        toastId = toastId + 1
        local id = toastId
        toast.Text = txt
        if cur.npos == 1 then
            toast.AnchorPoint = Vector2.new(1, 0)
            toast.Position = UDim2.new(1, -14, 0, 14)
        else
            toast.AnchorPoint = Vector2.new(1, 1)
            toast.Position = UDim2.new(1, -14, 1, -14)
        end
        toastStroke.Color = ACC
        toast.Visible = true
        task.delay(1.6, function()
            if id == toastId then toast.Visible = false end
        end)
    end

    local clickSnd = Instance.new("Sound", gui)
    clickSnd.SoundId = "rbxasset://sounds/button.wav"
    clickSnd.Volume = 0.4
    bind(UIS.InputBegan, function(i)
        if not cur.clicks or not frame.Visible then return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            local p = i.Position
            local ap, as = frame.AbsolutePosition, frame.AbsoluteSize
            if p.X >= ap.X and p.X <= ap.X + as.X and p.Y >= ap.Y and p.Y <= ap.Y + as.Y then
                pcall(function() clickSnd:Play() end)
            end
        end
    end)

    ----------------------------------------------------------
    -- texto, fonte e modo compacto
    ----------------------------------------------------------
    local function fontFor(baseName, idx)
        if idx == 1 then return Enum.Font[baseName] end
        local bold = baseName:find("Bold") or baseName:find("Black")
        if idx == 2 then return bold and Enum.Font.ArialBold or Enum.Font.Arial end
        if idx == 3 then return Enum.Font.Code end
        return Enum.Font.Ubuntu
    end
    local function rowBase(d)
        if d.Size.Y.Scale == 0 and d.Size.X.Scale == 1 and d.Size.X.Offset == 0 then
            local y = d.Size.Y.Offset
            if d:IsA("Frame") and y == 46 then return 46 end
            if d:IsA("TextButton") and d.Parent == side and y == 40 then return 40 end
        end
        return nil
    end
    local function reg(d)
        if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
            if d:GetAttribute("base") == nil then d:SetAttribute("base", d.TextSize) end
            if d:GetAttribute("bf") == nil then d:SetAttribute("bf", d.Font.Name) end
            d.TextSize = math.max(8, math.floor(d:GetAttribute("base") * cur.text + 0.5))
            pcall(function() d.Font = fontFor(d:GetAttribute("bf"), cur.font) end)
        end
        if d:IsA("GuiObject") then
            if d:GetAttribute("rowh") == nil then
                local rb = rowBase(d)
                if rb then d:SetAttribute("rowh", rb) end
            end
            local rh = d:GetAttribute("rowh")
            if rh then
                local h = rh
                if cur.compact then h = (rh == 46) and 36 or 32 end
                d.Size = UDim2.new(1, 0, 0, h)
            end
        end
    end
    local function applyText()
        for _, d in ipairs(frame:GetDescendants()) do reg(d) end
    end
    local function applyScale() menuScale.Scale = cur.scale end
    local function applyTrans()
        frame.BackgroundTransparency = cur.trans
        content.BackgroundTransparency = math.clamp(0.2 + cur.trans, 0, 0.95)
    end

    ----------------------------------------------------------
    -- cor do menu (RGB de verdade)
    ----------------------------------------------------------
    local function paintCore(new)
        local black, white = Color3.new(0, 0, 0), Color3.new(1, 1, 1)
        local light = new:Lerp(white, 0.45)
        local dark = new:Lerp(black, 0.25)
        sg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, new), ColorSequenceKeypoint.new(0.5, light), ColorSequenceKeypoint.new(1, dark)})
        bsg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, new), ColorSequenceKeypoint.new(0.5, dark), ColorSequenceKeypoint.new(1, light)})
        bgrad.Color = ColorSequence.new(new:Lerp(black, 0.5), new)
        tgrad.Color = ColorSequence.new(new, Color3.fromRGB(255, 215, 222))
        divider.BackgroundColor3 = new
        glowLine.BackgroundColor3 = new
        glow.BackgroundColor3 = new
        cstroke.Color = new
    end
    local function applyColor(new)
        local old = ACC
        if old == new then return end
        -- devolve os detalhes animados pra cor antiga antes de trocar
        divider.BackgroundColor3 = old
        glowLine.BackgroundColor3 = old
        glow.BackgroundColor3 = old
        cstroke.Color = old
        ACC = new
        local function recolor(root)
            for _, d in ipairs(root:GetDescendants()) do
                for _, p in ipairs({"BackgroundColor3", "TextColor3", "ScrollBarImageColor3", "Color", "ImageColor3"}) do
                    pcall(function() if d[p] == old then d[p] = new end end)
                end
            end
            pcall(function() if root.BackgroundColor3 == old then root.BackgroundColor3 = new end end)
        end
        recolor(frame)
        recolor(bubble)
        paintCore(new)
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, new:Lerp(Color3.new(0, 0, 0), 0.82)),
            ColorSequenceKeypoint.new(0.55, Color3.fromRGB(9, 11, 20)),
            ColorSequenceKeypoint.new(1, new:Lerp(Color3.new(0, 0, 0), 0.8))
        })
    end
    local applyTok = 0
    local function scheduleApply()
        applyTok = applyTok + 1
        local t = applyTok
        task.delay(0.2, function()
            if t == applyTok then applyColor(curColor()) end
        end)
    end

    -- arco-iris animado (so os detalhes: contorno, linha, bolinha e titulo)
    do
        local hue = 0
        bind(RunService.RenderStepped, function(dt)
            if not cur.rainbow then return end
            hue = (hue + dt * 0.12 * cur.rspeed) % 1
            paintCore(Color3.fromHSV(hue, 0.75, 1))
        end)
    end

    ----------------------------------------------------------
    -- bolinha e imagem de fundo
    ----------------------------------------------------------
    local function applyBubble()
        TX.bub = cur.bsize
        bubble.Size = UDim2.new(0, cur.bsize, 0, cur.bsize)
        bubble.BackgroundTransparency = cur.btrans
        bstroke.Transparency = cur.btrans
        for _, ch in ipairs(bubble:GetChildren()) do
            pcall(function()
                if ch:IsA("ImageLabel") then ch.ImageTransparency = cur.btrans end
                if ch:IsA("TextLabel") then ch.TextTransparency = cur.btrans end
            end)
        end
    end
    local function applyWall()
        if TX.wall then
            TX.wall.Visible = cur.bg
            TX.wall.ImageTransparency = cur.bgtrans
        end
    end

    ----------------------------------------------------------
    -- componentes da aba
    ----------------------------------------------------------
    local refreshAll
    local togglers, cyclers = {}, {}

    local function cfgToggle(name, key, fn)
        local lab
        local function paint()
            lab.Text = cur[key] and "ON" or "OFF"
            lab.TextColor3 = cur[key] and GOOD or ACC
        end
        local _
        _, lab = mkRow(cfs, name, "", function()
            cur[key] = not cur[key]
            paint()
            fn(cur[key])
            save()
        end)
        togglers[#togglers + 1] = function() paint() fn(cur[key]) end
        paint()
        fn(cur[key])
    end
    local function cfgCycle(name, key, list, fn)
        local lab
        local _
        _, lab = mkRow(cfs, name, list[cur[key]], function()
            cur[key] = cur[key] % #list + 1
            lab.Text = list[cur[key]]
            fn(cur[key])
            save()
        end)
        cyclers[#cyclers + 1] = function() lab.Text = list[cur[key]] fn(cur[key]) end
        fn(cur[key])
    end
    local function boxRow(ph, btnTxt, cb)
        local r = rowFrame(cfs, 40)
        local tb = mkBox(r, ph)
        tb.Size = UDim2.new(1, -96, 1, 0)
        local b = mk(r, btnTxt, ACC, function() cb(tb.Text, tb) end)
        b.Size = UDim2.new(0, 88, 1, 0)
        b.Position = UDim2.new(1, -88, 0, 0)
        b.TextSize = 13
        return tb
    end
    local function slider(parent, name, init, fillColor, onChange)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, 46)
        row.BackgroundColor3 = MID
        row.BackgroundTransparency = 0.1
        row.LayoutOrder = nextOrder(parent)
        corner(row, 10)
        local lab = Instance.new("TextLabel", row)
        lab.Size = UDim2.new(0, 70, 1, 0)
        lab.Position = UDim2.new(0, 14, 0, 0)
        lab.BackgroundTransparency = 1
        lab.TextColor3 = Color3.new(1, 1, 1)
        lab.Font = Enum.Font.Gotham
        lab.TextSize = 14
        lab.TextXAlignment = Enum.TextXAlignment.Left
        local track = Instance.new("Frame", row)
        track.Position = UDim2.new(0, 96, 0.5, -3)
        track.Size = UDim2.new(1, -116, 0, 6)
        track.BackgroundColor3 = Color3.fromRGB(46, 52, 76)
        track.BorderSizePixel = 0
        corner(track, 3)
        local fill = Instance.new("Frame", track)
        fill.BackgroundColor3 = fillColor
        fill.BorderSizePixel = 0
        corner(fill, 3)
        local knob = Instance.new("Frame", track)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Size = UDim2.new(0, 20, 0, 20)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.ZIndex = 3
        corner(knob, 10)
        local hit = Instance.new("TextButton", row)
        hit.Position = UDim2.new(0, 84, 0, 0)
        hit.Size = UDim2.new(1, -100, 1, 0)
        hit.BackgroundTransparency = 1
        hit.Text = ""
        local val = init
        local function set(v, silent)
            val = math.clamp(math.floor(v + 0.5), 0, 255)
            local fr = val / 255
            fill.Size = UDim2.new(fr, 0, 1, 0)
            knob.Position = UDim2.new(fr, 0, 0.5, 0)
            lab.Text = name .. ": " .. val
            if not silent then onChange(val) end
        end
        local dragging = false
        local function fromX(x)
            local w = track.AbsoluteSize.X
            if w <= 0 then return end
            set((x - track.AbsolutePosition.X) / w * 255)
        end
        hit.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                fromX(i.Position.X)
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        bind(UIS.InputChanged, function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                fromX(i.Position.X)
            end
        end)
        set(init, true)
        return set
    end

    ----------------------------------------------------------
    -- montagem da aba
    ----------------------------------------------------------
    local cfgMsg = mkMsg(cfs, "Configurações  •  menu")
    if not canSave then
        local w = mkMsg(cfs, "Seu executor não salva arquivos: vale só nesta sessão")
        w.TextSize = 11
        w.TextColor3 = Color3.fromRGB(165, 172, 198)
    end

    -- COR DO MENU
    mkMsg(cfs, "Cor do menu (RGB)")
    local swRow = Instance.new("Frame", cfs)
    swRow.Size = UDim2.new(1, 0, 0, 46)
    swRow.BackgroundColor3 = MID
    swRow.BackgroundTransparency = 0.1
    swRow.LayoutOrder = nextOrder(cfs)
    corner(swRow, 10)
    local swLab = Instance.new("TextLabel", swRow)
    swLab.Size = UDim2.new(1, -90, 1, 0)
    swLab.Position = UDim2.new(0, 14, 0, 0)
    swLab.BackgroundTransparency = 1
    swLab.TextColor3 = Color3.new(1, 1, 1)
    swLab.Font = Enum.Font.Gotham
    swLab.TextSize = 14
    swLab.TextXAlignment = Enum.TextXAlignment.Left
    local sw = Instance.new("Frame", swRow)
    sw.Size = UDim2.new(0, 56, 0, 30)
    sw.Position = UDim2.new(1, -66, 0.5, -15)
    sw.BorderSizePixel = 0
    corner(sw, 8)
    local function swatchPaint()
        sw.BackgroundColor3 = distinct(curColor())
        swLab.Text = string.format("Cor atual: #%02X%02X%02X", cur.r, cur.g, cur.b)
    end
    swatchPaint()

    local function colorChanged()
        swatchPaint()
        scheduleApply()
        saveSoon()
    end
    local slR = slider(cfs, "R", cur.r, Color3.fromRGB(255, 90, 100), function(v) cur.r = v colorChanged() end)
    local slG = slider(cfs, "G", cur.g, Color3.fromRGB(90, 230, 120), function(v) cur.g = v colorChanged() end)
    local slB = slider(cfs, "B", cur.b, Color3.fromRGB(90, 150, 255), function(v) cur.b = v colorChanged() end)

    boxRow("Código hex  ex: #FF8800", "APLICAR", function(txt)
        local h = string.gsub(txt, "[^%x]", "")
        if #h ~= 6 then
            TX.notify("Hex inválido")
            return
        end
        cur.r = tonumber(h:sub(1, 2), 16)
        cur.g = tonumber(h:sub(3, 4), 16)
        cur.b = tonumber(h:sub(5, 6), 16)
        slR(cur.r, true) slG(cur.g, true) slB(cur.b, true)
        swatchPaint()
        applyColor(curColor())
        save()
    end)

    local preRow = rowFrame(cfs, 34)
    for k, t in ipairs(themes) do
        local pb = mk(preRow, "", distinct(t[2]), function()
            local c = t[2]
            cur.r = math.floor(c.R * 255 + 0.5)
            cur.g = math.floor(c.G * 255 + 0.5)
            cur.b = math.floor(c.B * 255 + 0.5)
            slR(cur.r, true) slG(cur.g, true) slB(cur.b, true)
            swatchPaint()
            applyColor(curColor())
            save()
        end)
        pb.Size = UDim2.new(1 / #themes, -4, 1, 0)
        pb.Position = UDim2.new((k - 1) / #themes, 2, 0, 0)
    end

    cfgToggle("Modo arco-íris (RGB animado)", "rainbow", function(v)
        if not v then paintCore(ACC) end
    end)
    local sRsp = stepper(cfs, "Velocidade do arco-íris", cur.rspeed, 0.5, 0.5, 3, function(v)
        cur.rspeed = v save()
    end)

    -- PERFIS
    mkMsg(cfs, "Perfis")
    local slot = 1
    local slotRow = rowFrame(cfs, 38)
    local slotBtns = {}
    local function paintSlots()
        for k = 1, 3 do
            local filled = cur["p" .. k] ~= ""
            slotBtns[k].Text = "Perfil " .. k .. (filled and " •" or "")
            slotBtns[k].BackgroundColor3 = (k == slot) and ACC or MID
        end
    end
    for k = 1, 3 do
        local b = mk(slotRow, "", MID, function() slot = k paintSlots() end)
        b.Size = UDim2.new(1 / 3, -4, 1, 0)
        b.Position = UDim2.new((k - 1) / 3, 2, 0, 0)
        b.TextSize = 13
        slotBtns[k] = b
    end
    local function snapshot()
        local t = {}
        for k, v in pairs(cur) do
            if k ~= "p1" and k ~= "p2" and k ~= "p3" then t[k] = v end
        end
        return HttpService:JSONEncode(t)
    end
    local function applySnapshot(js)
        local ok, d = pcall(function() return HttpService:JSONDecode(js) end)
        if not ok or type(d) ~= "table" then return false end
        for k, v in pairs(d) do
            if DEF[k] ~= nil and k ~= "p1" and k ~= "p2" and k ~= "p3" and type(v) == type(DEF[k]) then
                cur[k] = v
            end
        end
        cur.r = math.clamp(math.floor(cur.r), 0, 255)
        cur.g = math.clamp(math.floor(cur.g), 0, 255)
        cur.b = math.clamp(math.floor(cur.b), 0, 255)
        if cur.keyIdx < 1 or cur.keyIdx > #KEYS then cur.keyIdx = 1 end
        if cur.font < 1 or cur.font > #FONTN then cur.font = 1 end
        if cur.npos < 1 or cur.npos > 2 then cur.npos = 1 end
        refreshAll()
        save()
        return true
    end
    mkRow(cfs, "Salvar no perfil", "SALVAR", function()
        cur["p" .. slot] = snapshot()
        save()
        paintSlots()
        TX.notify("Perfil " .. slot .. " salvo")
    end)
    mkRow(cfs, "Carregar perfil", "CARREGAR", function()
        local js = cur["p" .. slot]
        if js == "" then
            TX.notify("Perfil " .. slot .. " está vazio")
        elseif applySnapshot(js) then
            TX.notify("Perfil " .. slot .. " carregado")
        else
            TX.notify("Perfil inválido")
        end
    end)
    mkRow(cfs, "Copiar config (texto)", "COPIAR", function()
        if clip then
            pcall(clip, snapshot())
            TX.notify("Config copiada")
        else
            TX.notify("Sem área de transferência")
        end
    end)
    boxRow("Cole a config aqui", "APLICAR", function(txt)
        if applySnapshot(txt) then TX.notify("Config aplicada") else TX.notify("Texto inválido") end
    end)

    -- APARENCIA
    mkMsg(cfs, "Aparência")
    local sScale = stepper(cfs, "Tamanho do menu", cur.scale, 0.1, 0.6, 1.2, function(v)
        cur.scale = v applyScale() save()
    end)
    local sTrans = stepper(cfs, "Transparência do menu", cur.trans, 0.1, 0, 0.8, function(v)
        cur.trans = v applyTrans() save()
    end)
    local sText = stepper(cfs, "Tamanho do texto", cur.text, 0.1, 0.8, 1.4, function(v)
        cur.text = v applyText() save()
    end)
    cfgToggle("Modo compacto", "compact", function() applyText() end)
    cfgCycle("Fonte do menu", "font", FONTN, function() applyText() end)
    cfgToggle("Contorno animado", "spin", function(v) borderSpin = v end)
    local sBgT
    if TX.wall then
        cfgToggle("Imagem de fundo", "bg", function() applyWall() end)
        sBgT = stepper(cfs, "Transparência da imagem", cur.bgtrans, 0.05, 0.3, 0.95, function(v)
            cur.bgtrans = v applyWall() save()
        end)
    end

    -- BOLINHA
    mkMsg(cfs, "Bolinha")
    local sBsz = stepper(cfs, "Tamanho da bolinha", cur.bsize, 5, 40, 90, function(v)
        cur.bsize = v applyBubble() save()
    end)
    local sBtr = stepper(cfs, "Transparência da bolinha", cur.btrans, 0.1, 0, 0.7, function(v)
        cur.btrans = v applyBubble() save()
    end)
    mkRow(cfs, "Resetar posição da bolinha", "RESET", function()
        bubble.Position = UDim2.new(0, 52, 0.5, 0)
    end)

    -- JANELA
    mkMsg(cfs, "Janela")
    cfgToggle("Travar posição do menu", "lock", function(v) menuLocked = v end)
    cfgToggle("Atalho do menu (PC)", "key", function() end)
    cfgCycle("Tecla do atalho", "keyIdx", KEYN, function() end)
    bind(UIS.InputBegan, function(i, gp)
        if gp or not cur.key then return end
        if i.KeyCode == Enum.KeyCode[KEYS[cur.keyIdx]] then
            if frame.Visible then closeMenu() else openMenu() end
        end
    end)
    cfgToggle("Abrir minimizado (só a bolinha)", "startMin", function(v) TX.startMin = v end)
    cfgToggle("Toque duplo no título minimiza", "dbl", function(v) TX.dbl = v end)
    cfgToggle("Linhas de varredura (scanlines)", "scan", function(v) if TX.scan then TX.scan.Visible = v end end)
    cfgToggle("Feixe de luz animado", "beam", function(v)
        TX.beamOn = v
        if TX.beam then TX.beam.Visible = v end
    end)
    cfgToggle("HUD no topo (FPS, ping, jogadores)", "hudc", function(v)
        if TX.hud then TX.hud.Visible = v end
        if TX.hudDot then TX.hudDot.Visible = v end
    end)
    mkRow(cfs, "Centralizar menu", "CENTRO", function()
        tween(frame, 0.25, {Position = UDim2.new(0.5, 0, 0.5, 0)})
    end)

    -- AVISOS E SONS
    mkMsg(cfs, "Avisos e sons")
    cfgToggle("Avisos no canto da tela", "notif", function() end)
    cfgCycle("Posição do aviso", "npos", POSN, function() end)
    cfgToggle("Sons de clique", "clicks", function() end)
    mkRow(cfs, "Testar aviso", "TESTAR", function() TX.notify("Aviso de teste") end)

    -- RESTAURAR
    refreshAll = function()
        slR(cur.r, true) slG(cur.g, true) slB(cur.b, true)
        swatchPaint()
        sRsp(cur.rspeed, true)
        sScale(cur.scale, true) sTrans(cur.trans, true) sText(cur.text, true)
        sBsz(cur.bsize, true) sBtr(cur.btrans, true)
        if sBgT then sBgT(cur.bgtrans, true) end
        for _, f in ipairs(togglers) do f() end
        for _, f in ipairs(cyclers) do f() end
        applyScale() applyTrans() applyText() applyBubble() applyWall()
        applyColor(curColor())
        paintSlots()
    end
    mkRow(cfs, "Restaurar padrão do menu", "RESET", function()
        for k, v in pairs(DEF) do
            if k ~= "p1" and k ~= "p2" and k ~= "p3" then cur[k] = v end
        end
        refreshAll()
        frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        save()
        cfgMsg.Text = "Configurações  •  restaurado"
    end)

    mkMsg(cfs, "Tutuzx Ruby v9")

    -- aplica o que estava salvo e cuida dos textos criados depois
    refreshAll()
    bind(frame.DescendantAdded, function(d)
        task.defer(function()
            if d.Parent then reg(d) end
        end)
    end)
end

------------------------------------------------------------
-- ABAS RUBY: Creditos, Update, Jogador, Extra, Car, RGB, Protecao, Teleporte, Scripts
------------------------------------------------------------
;(function()
local function notify(t) pcall(function() if TX.notify then TX.notify(t) end end) end
local function cam() return workspace.CurrentCamera end
local function cleanup(f) TX.cleanups[#TX.cleanups + 1] = f end
local FIELD = Color3.fromRGB(30, 36, 60)
local GREY = Color3.fromRGB(150, 156, 182)
local function copy(txt)
    if clip then pcall(clip, txt) notify("Copiado") else notify("Executor sem setclipboard") end
end

-- ---------- componentes no estilo do video ----------
local function section(parent, text)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundColor3 = MID
    f.BackgroundTransparency = 0.3
    f.LayoutOrder = nextOrder(parent)
    corner(f, 8)
    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(0, 3, 0, 16)
    bar.Position = UDim2.new(0, 8, 0.5, -8)
    bar.BackgroundColor3 = ACC
    bar.BorderSizePixel = 0
    corner(bar, 2)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -24, 1, 0)
    l.Position = UDim2.new(0, 18, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    return f
end
local function info(parent, title, sub)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 46)
    f.BackgroundColor3 = MID
    f.BackgroundTransparency = 0.12
    f.LayoutOrder = nextOrder(parent)
    corner(f, 8)
    local st = Instance.new("UIStroke", f)
    st.Color = ACC
    st.Transparency = 0.8
    st.Thickness = 1
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, -20, 0, 20)
    t.Position = UDim2.new(0, 14, 0, 5)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = Color3.new(1, 1, 1)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextTruncate = Enum.TextTruncate.AtEnd
    local s = Instance.new("TextLabel", f)
    s.Size = UDim2.new(1, -20, 0, 16)
    s.Position = UDim2.new(0, 14, 0, 25)
    s.BackgroundTransparency = 1
    s.Text = sub
    s.TextColor3 = GREY
    s.Font = Enum.Font.Gotham
    s.TextSize = 11
    s.TextXAlignment = Enum.TextXAlignment.Left
    s.TextTruncate = Enum.TextTruncate.AtEnd
    return f, t, s
end
local function note(parent, text)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 0)
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.BackgroundColor3 = Color3.fromRGB(10, 16, 14)
    f.BackgroundTransparency = 0.1
    f.LayoutOrder = nextOrder(parent)
    corner(f, 8)
    local pad = Instance.new("UIPadding", f)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 0, 0)
    l.AutomaticSize = Enum.AutomaticSize.Y
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextWrapped = true
    l.TextColor3 = Color3.fromRGB(120, 235, 160)
    l.Font = Enum.Font.Code
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Top
    return l
end
local function inputRow(parent, name, ph, onEnter, tall)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, tall or 46)
    row.BackgroundColor3 = MID
    row.BackgroundTransparency = 0.12
    row.LayoutOrder = nextOrder(parent)
    corner(row, 8)
    local st = Instance.new("UIStroke", row)
    st.Color = ACC
    st.Transparency = 0.8
    st.Thickness = 1
    local l = Instance.new("TextLabel", row)
    l.Size = UDim2.new(0.4, 0, 0, 46)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    local box = mkBox(row, ph)
    box.BackgroundColor3 = FIELD
    box.Size = UDim2.new(0.56, -12, 0, (tall or 46) - 16)
    box.Position = UDim2.new(0.44, 0, 0, 8)
    box.TextSize = 13
    if tall then
        box.MultiLine = true
        box.TextWrapped = true
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.TextYAlignment = Enum.TextYAlignment.Top
        box.Font = Enum.Font.Code
    end
    box.FocusLost:Connect(function(enter)
        if onEnter then onEnter(box.Text, enter) end
    end)
    return box
end
local function dropdown(parent, name, getList, onPick, initText)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 46)
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.BackgroundTransparency = 1
    holder.LayoutOrder = nextOrder(parent)
    local lay = Instance.new("UIListLayout", holder)
    lay.Padding = UDim.new(0, 4)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    local row = Instance.new("Frame", holder)
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = MID
    row.BackgroundTransparency = 0.12
    row.LayoutOrder = 1
    corner(row, 8)
    local st = Instance.new("UIStroke", row)
    st.Color = ACC
    st.Transparency = 0.8
    st.Thickness = 1
    local nl = Instance.new("TextLabel", row)
    nl.Size = UDim2.new(0.42, 0, 1, 0)
    nl.Position = UDim2.new(0, 14, 0, 0)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = Color3.new(1, 1, 1)
    nl.Font = Enum.Font.GothamMedium
    nl.TextSize = 13
    nl.TextXAlignment = Enum.TextXAlignment.Left
    nl.TextTruncate = Enum.TextTruncate.AtEnd
    local btn = Instance.new("TextButton", row)
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.Position = UDim2.new(1, -8, 0.5, 0)
    btn.Size = UDim2.new(0.54, -8, 0, 30)
    btn.BackgroundColor3 = FIELD
    btn.Text = tostring(initText) .. "  ⌄"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    corner(btn, 8)
    local opts = Instance.new("Frame", holder)
    opts.Size = UDim2.new(1, 0, 0, 0)
    opts.AutomaticSize = Enum.AutomaticSize.Y
    opts.BackgroundTransparency = 1
    opts.Visible = false
    opts.LayoutOrder = 2
    local ol = Instance.new("UIListLayout", opts)
    ol.Padding = UDim.new(0, 3)
    ol.SortOrder = Enum.SortOrder.LayoutOrder
    local obj = {}
    function obj.set(txt) btn.Text = tostring(txt) .. "  ⌄" end
    function obj.refresh()
        for _, c in ipairs(opts:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local list = getList()
        if #list == 0 then
            local b = mk(opts, "(nenhum disponivel)", FIELD, function() opts.Visible = false end)
            b.Size = UDim2.new(1, 0, 0, 32)
            b.TextSize = 12
            return
        end
        for i, v in ipairs(list) do
            local b = mk(opts, tostring(v), FIELD, function()
                obj.set(v)
                opts.Visible = false
                onPick(v)
            end)
            b.Size = UDim2.new(1, 0, 0, 32)
            b.TextSize = 13
            b.LayoutOrder = i
        end
    end
    btn.MouseButton1Click:Connect(function()
        opts.Visible = not opts.Visible
        if opts.Visible then obj.refresh() end
    end)
    return obj
end

-- ---------- jogador selecionado (compartilhado) ----------
local SEL = {name = nil, setters = {}}
local function plist()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then t[#t + 1] = p.Name end
    end
    table.sort(t)
    return t
end
local function selPlayer()
    if not SEL.name then return nil end
    return Players:FindFirstChild(SEL.name)
end
local refreshInfo
local function setSel(n)
    SEL.name = n
    for _, f in ipairs(SEL.setters) do pcall(f, n) end
    if refreshInfo then refreshInfo() end
end
local function tpTo(p)
    local r = getRoot()
    local tr = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if r and tr then
        r.CFrame = tr.CFrame * CFrame.new(0, 0, 3)
        return true
    end
    return false
end
local function seatPart() local h = getHum() return h and h.SeatPart end
local function carRoot()
    local s = seatPart()
    if not s then return nil end
    return s.AssemblyRootPart or s
end

----------------------------------------------------------
-- CREDITOS
----------------------------------------------------------
do
    local cr = UI.creds
    local exe = "Desconhecido"
    pcall(function()
        if identifyexecutor then
            local a, b = identifyexecutor()
            exe = tostring(a) .. (b and (" " .. tostring(b)) or "")
        end
    end)
    section(cr, "Créditos do Hub")
    info(cr, "Tutuzx Ruby", "Menu v9  •  baseado no Tutuzx v8")
    info(cr, "Executor", exe)
    info(cr, "Jogador", lp.DisplayName .. "  (@" .. lp.Name .. ")")
    info(cr, "Jogo (PlaceId)", tostring(game.PlaceId))
    section(cr, "Compatibilidade do executor")
    local checks = {
        {"Salvar dados (writefile/readfile)", (writefile and readfile and isfile) and true or false},
        {"Copiar (setclipboard)", clip and true or false},
        {"Requisições (request) - Server Hop", http and true or false},
        {"Executar código (loadstring)", loadstring and true or false},
        {"GUI protegida (gethui)", gethui and true or false},
    }
    for _, c in ipairs(checks) do
        info(cr, c[1], c[2] and "✓ disponível" or "✗ indisponível (recurso desativado)")
    end
end

----------------------------------------------------------
-- UPDATE
----------------------------------------------------------
do
    local up = UI.upds
    section(up, "Atualizações")
    note(up, "Tutuzx Ruby v9\n\n+ Novo visual (tema Ruby) no estilo do hub do vídeo\n+ Abas novas: Créditos, Update, Jogador, Extra, Car, RGB, Proteção, Teleporte e Scripts\n+ Switches animados nos botões ON/OFF\n+ Lista de jogadores (dropdown) com teleporte, visualizar e seguir\n+ Car: boost de velocidade, turbo, aderência, desvirar e Fly Car\n+ RGB: arco-íris ou cor fixa (hex) no corpo, acessórios, carro e mundo\n+ Proteção: Anti-AFK, Anti-Fling, Anti-Void, Anti-Sit e mais\n+ Teleporte: locais salvos, coordenadas e Click TP\n+ Scripts: executor de código Lua, Rejoin e Server Hop\n+ Todas as funções do Tutuzx v8 foram mantidas")
end

----------------------------------------------------------
-- JOGADOR
----------------------------------------------------------
do
    local pl = UI.plrs
    section(pl, "Selecionar Jogador")
    local dd = dropdown(pl, "Jogador", plist, function(n) setSel(n) end, "...")
    SEL.setters[#SEL.setters + 1] = dd.set
    mkRow(pl, "Atualizar lista", "›", function()
        dd.refresh()
        notify(#plist() .. " jogador(es) no servidor")
    end)
    local _, t1, s1 = info(pl, "Nome", "Nenhum jogador selecionado")
    local _, t2, s2 = info(pl, "Conta / UserId", "-")
    refreshInfo = function()
        local p = selPlayer()
        if p then
            s1.Text = p.DisplayName .. "  (@" .. p.Name .. ")"
            s2.Text = p.AccountAge .. " dias  •  ID " .. p.UserId
        else
            s1.Text = "Nenhum jogador selecionado"
            s2.Text = "-"
        end
    end
    section(pl, "Ações no jogador")
    mkRow(pl, "Teleportar até o jogador", "›", function()
        local p = selPlayer()
        if not p then notify("Selecione um jogador") return end
        notify(tpTo(p) and "Teleportado" or "Jogador sem personagem")
    end)
    toggleRow(pl, "Visualizar jogador", function(v)
        local h
        if v then
            local p = selPlayer()
            h = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid")
            if not h then notify("Selecione um jogador") return end
        else
            h = getHum()
        end
        if h and cam() then cam().CameraSubject = h end
    end)
    local follow = false
    toggleRow(pl, "Seguir jogador", function(v) follow = v end)
    do
        local acc = 0
        bind(RunService.Heartbeat, function(dt)
            if not follow then return end
            acc = acc + dt
            if acc < 0.25 then return end
            acc = 0
            local p, h = selPlayer(), getHum()
            local tr = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if h and tr then h:MoveTo(tr.Position) end
        end)
    end
    mkRow(pl, "Copiar nome", "›", function()
        local p = selPlayer()
        if p then copy(p.Name) else notify("Selecione um jogador") end
    end)
    mkRow(pl, "Copiar UserId", "›", function()
        local p = selPlayer()
        if p then copy(tostring(p.UserId)) else notify("Selecione um jogador") end
    end)
    mkRow(pl, "Copiar avatar (visual local)", "›", function()
        local p = selPlayer()
        if not p then notify("Selecione um jogador") return end
        task.spawn(function()
            local ok = pcall(function()
                local d = Players:GetHumanoidDescriptionFromUserId(p.UserId)
                getHum():ApplyDescription(d)
            end)
            notify(ok and "Avatar aplicado (só você vê)" or "Não foi possível aplicar")
        end)
    end)
    section(pl, "Meu personagem")
    mkRow(pl, "Resetar personagem", "›", function()
        local h = getHum()
        if h then h.Health = 0 end
    end)
    mkRow(pl, "Respawn no mesmo lugar", "›", function()
        local r, h = getRoot(), getHum()
        if not (r and h) then return end
        local cf = r.CFrame
        local c
        c = lp.CharacterAdded:Connect(function(nc)
            c:Disconnect()
            local rr = nc:WaitForChild("HumanoidRootPart", 5)
            task.wait(0.3)
            if rr then rr.CFrame = cf end
        end)
        h.Health = 0
    end)
    bind(Players.PlayerRemoving, function(p)
        if p.Name == SEL.name then setSel(nil) for _, f in ipairs(SEL.setters) do pcall(f, "...") end end
    end)
end

----------------------------------------------------------
-- CAR
----------------------------------------------------------
local CB = {boost = false, max = 120, fly = false, fspeed = 80, turbo = 60, grip = 3}
do
    local cs = UI.cars
    section(cs, "Configurações do Meu Veículo")
    info(cs, "Dica", "Entre em um veículo para usar estas funções")
    stepper(cs, "Velocidade máxima", 120, 20, 20, 500, function(v) CB.max = v end)
    toggleRow(cs, "Boost de velocidade (acelerando)", function(v) CB.boost = v end)
    stepper(cs, "Força do turbo", 60, 10, 10, 300, function(v) CB.turbo = v end)
    mkRow(cs, "Aplicar turbo", "›", function()
        local rp = carRoot()
        if not rp then notify("Entre em um veículo") return end
        local v = rp.AssemblyLinearVelocity
        local d = Vector3.new(v.X, 0, v.Z)
        if d.Magnitude < 3 then
            local lv = rp.CFrame.LookVector
            d = Vector3.new(lv.X, 0, lv.Z)
        end
        rp.AssemblyLinearVelocity = d.Unit * math.min(d.Magnitude + CB.turbo, 500) + Vector3.new(0, v.Y, 0)
    end)
    section(cs, "Controle")
    mkRow(cs, "Desvirar / endireitar carro", "›", function()
        local rp = carRoot()
        if not rp then notify("Entre em um veículo") return end
        local _, yaw = rp.CFrame:ToOrientation()
        rp.AssemblyLinearVelocity = Vector3.zero
        rp.AssemblyAngularVelocity = Vector3.zero
        rp.CFrame = CFrame.new(rp.Position + Vector3.new(0, 5, 0)) * CFrame.Angles(0, yaw, 0)
    end)
    mkRow(cs, "Parar carro", "›", function()
        local rp = carRoot()
        if not rp then notify("Entre em um veículo") return end
        for _, p in ipairs(rp:GetConnectedParts(true)) do
            p.AssemblyLinearVelocity = Vector3.zero
            p.AssemblyAngularVelocity = Vector3.zero
        end
    end)
    toggleRow(cs, "Visualizar câmera do carro", function(v)
        local s = seatPart()
        if not cam() then return end
        if v and s then cam().CameraSubject = s
        else
            local h = getHum()
            if h then cam().CameraSubject = h end
            if v then notify("Entre em um veículo") end
        end
    end)
    section(cs, "Fly Car")
    stepper(cs, "Velocidade de voo", 80, 10, 10, 400, function(v) CB.fspeed = v end)
    toggleRow(cs, "Fly Car (joystick + câmera)", function(v) CB.fly = v end)
    section(cs, "Aderência")
    stepper(cs, "Aderência (atrito)", 3, 1, 1, 10, function(v) CB.grip = v end)
    local gripOrig = {}
    toggleRow(cs, "Aderência extra", function(v)
        if v then
            local rp = carRoot()
            if not rp then notify("Entre em um veículo") return end
            for _, p in ipairs(rp:GetConnectedParts(true)) do
                if gripOrig[p] == nil then gripOrig[p] = p.CustomPhysicalProperties or false end
                local cp = p.CurrentPhysicalProperties
                p.CustomPhysicalProperties = PhysicalProperties.new(cp.Density, CB.grip, cp.Elasticity, 100, cp.ElasticityWeight)
            end
        else
            for p, o in pairs(gripOrig) do
                pcall(function() p.CustomPhysicalProperties = o or nil end)
            end
            gripOrig = {}
        end
    end)
    bind(RunService.Heartbeat, function()
        if not (CB.boost or CB.fly) then return end
        local h, rp = getHum(), carRoot()
        if not (h and rp) then return end
        local v = rp.AssemblyLinearVelocity
        if CB.fly then
            local c = cam()
            local mv = c.CFrame:VectorToObjectSpace(h.MoveDirection)
            local dir = c.CFrame.LookVector * (-mv.Z) + c.CFrame.RightVector * mv.X
            rp.AssemblyLinearVelocity = dir * CB.fspeed
            rp.AssemblyAngularVelocity = Vector3.zero
        elseif CB.boost then
            local hv = Vector3.new(v.X, 0, v.Z)
            if h.MoveDirection.Magnitude > 0.1 and hv.Magnitude > 4 then
                rp.AssemblyLinearVelocity = hv.Unit * CB.max + Vector3.new(0, v.Y, 0)
            end
        end
    end)
    cleanup(function()
        CB.boost, CB.fly = false, false
        for p, o in pairs(gripOrig) do pcall(function() p.CustomPhysicalProperties = o or nil end) end
    end)
end

----------------------------------------------------------
-- RGB (visual local: so voce enxerga)
----------------------------------------------------------
do
    local rs = UI.rgbs
    local RG = {body = false, hair = false, car = false, world = false, mode = 1, speed = 1, hue = 0, fixed = Color3.fromRGB(174, 26, 26)}
    local orig = {body = {}, hair = {}, car = {}}
    local worldOrig
    local function restore(k)
        for p, c in pairs(orig[k]) do pcall(function() p.Color = c end) end
        orig[k] = {}
    end
    local function restoreWorld()
        if worldOrig then
            Lighting.Ambient = worldOrig[1]
            Lighting.OutdoorAmbient = worldOrig[2]
            worldOrig = nil
        end
    end
    local function paint(k, parts, col)
        for _, p in ipairs(parts) do
            if p:IsA("BasePart") then
                if orig[k][p] == nil then orig[k][p] = p.Color end
                p.Color = col
            end
        end
    end
    local function hexToColor(s)
        s = tostring(s):gsub("#", ""):gsub("%s", "")
        if #s ~= 6 then return nil end
        local r, g, b = tonumber(s:sub(1, 2), 16), tonumber(s:sub(3, 4), 16), tonumber(s:sub(5, 6), 16)
        if r and g and b then return Color3.fromRGB(r, g, b) end
        return nil
    end
    section(rs, "Modo de cor")
    local prevHolder
    dropdown(rs, "Modo", function() return {"Arco-íris", "Cor fixa"} end, function(v)
        RG.mode = (v == "Cor fixa") and 2 or 1
    end, "Arco-íris")
    stepper(rs, "Velocidade do arco-íris", 1, 1, 1, 10, function(v) RG.speed = v end)
    local box = inputRow(rs, "Cor personalizada", "#AE1A1A", function(txt)
        local c = hexToColor(txt)
        if c then
            RG.fixed = c
            if prevHolder then prevHolder.BackgroundColor3 = c end
            notify("Cor fixa definida")
        else
            notify("Use o formato #RRGGBB")
        end
    end)
    do
        prevHolder = Instance.new("Frame", box.Parent)
        prevHolder.Size = UDim2.new(0, 18, 0, 18)
        prevHolder.Position = UDim2.new(0.4, -4, 0.5, -9)
        prevHolder.BackgroundColor3 = RG.fixed
        corner(prevHolder, 9)
    end
    section(rs, "Personagem")
    toggleRow(rs, "Corpo", function(v) RG.body = v if not v then restore("body") end end)
    toggleRow(rs, "Cabelo / acessórios", function(v) RG.hair = v if not v then restore("hair") end end)
    section(rs, "Veículo e mundo")
    toggleRow(rs, "Carro (veículo atual)", function(v) RG.car = v if not v then restore("car") end end)
    toggleRow(rs, "Luz do mundo (neon)", function(v) RG.world = v if not v then restoreWorld() end end)
    note(rs, "As cores são locais: só você vê. Desligar o botão devolve a cor original.")
    bind(RunService.Heartbeat, function(dt)
        if not (RG.body or RG.hair or RG.car or RG.world) then return end
        RG.hue = (RG.hue + dt * 0.15 * RG.speed) % 1
        local col = (RG.mode == 2) and RG.fixed or Color3.fromHSV(RG.hue, 0.9, 1)
        local ch = lp.Character
        if RG.body and ch then
            local parts = {}
            for _, d in ipairs(ch:GetChildren()) do
                if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then parts[#parts + 1] = d end
            end
            paint("body", parts, col)
        end
        if RG.hair and ch then
            local parts = {}
            for _, a in ipairs(ch:GetChildren()) do
                if a:IsA("Accessory") then
                    local h = a:FindFirstChild("Handle")
                    if h then parts[#parts + 1] = h end
                end
            end
            paint("hair", parts, col)
        end
        if RG.car then
            local rp = carRoot()
            if rp then paint("car", rp:GetConnectedParts(true), col) end
        end
        if RG.world then
            if not worldOrig then worldOrig = {Lighting.Ambient, Lighting.OutdoorAmbient} end
            Lighting.Ambient = col
            Lighting.OutdoorAmbient = col
        end
    end)
    cleanup(function()
        RG.body, RG.hair, RG.car, RG.world = false, false, false, false
        restore("body") restore("hair") restore("car") restoreWorld()
    end)
end

----------------------------------------------------------
-- PROTECAO
----------------------------------------------------------
do
    local ps2 = UI.prots
    local PR = {afk = false, fling = false, void = false, sit = false, rag = false, deathback = false, safe = nil, deathCF = nil}
    local VU
    pcall(function() VU = game:GetService("VirtualUser") end)
    local function applyStates()
        local h = getHum()
        if not h then return end
        pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Seated, not PR.sit) end)
        pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not PR.rag) end)
        pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not PR.rag) end)
        pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, not PR.rag) end)
    end
    local function hookChar(ch)
        local h = ch:WaitForChild("Humanoid", 5)
        if not h then return end
        h.Died:Connect(function()
            local r = ch:FindFirstChild("HumanoidRootPart")
            if r then PR.deathCF = r.CFrame end
        end)
        task.wait(0.4)
        applyStates()
        if PR.deathback and PR.deathCF then
            local r = ch:WaitForChild("HumanoidRootPart", 5)
            if r then r.CFrame = PR.deathCF end
        end
    end
    if lp.Character then task.spawn(hookChar, lp.Character) end
    bind(lp.CharacterAdded, function(ch) task.spawn(hookChar, ch) end)
    bind(lp.Idled, function()
        if PR.afk and VU then
            pcall(function()
                VU:CaptureController()
                VU:ClickButton2(Vector2.new())
            end)
        end
    end)
    section(ps2, "Proteção")
    toggleRow(ps2, "Anti-AFK", function(v) PR.afk = v end)
    toggleRow(ps2, "Anti-Fling (sem colisão com outros)", function(v) PR.fling = v end)
    toggleRow(ps2, "Anti-Void (volta ao chão seguro)", function(v) PR.void = v end)
    toggleRow(ps2, "Bloquear sentar (anti-sit)", function(v) PR.sit = v applyStates() end)
    toggleRow(ps2, "Anti-Ragdoll / cair", function(v) PR.rag = v applyStates() end)
    toggleRow(ps2, "Voltar ao local da morte", function(v) PR.deathback = v end)
    note(ps2, "Anti-sit também impede você de sentar em carros e bancos. Desligue quando quiser sentar.")
    bind(RunService.Stepped, function()
        local h, r = getHum(), getRoot()
        if PR.fling then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    for _, d in ipairs(p.Character:GetDescendants()) do
                        if d:IsA("BasePart") then d.CanCollide = false end
                    end
                end
            end
            if r and h and not h.SeatPart and (r.AssemblyLinearVelocity.Magnitude > 250 or r.AssemblyAngularVelocity.Magnitude > 60) then
                r.AssemblyLinearVelocity = Vector3.zero
                r.AssemblyAngularVelocity = Vector3.zero
            end
        end
        if PR.void and r and h then
            if h.FloorMaterial ~= Enum.Material.Air and r.Position.Y > -50 then
                PR.safe = r.CFrame
            elseif PR.safe and r.Position.Y < workspace.FallenPartsDestroyHeight + 120 then
                r.AssemblyLinearVelocity = Vector3.zero
                r.CFrame = PR.safe + Vector3.new(0, 5, 0)
            end
        end
    end)
    cleanup(function()
        PR.afk, PR.fling, PR.void, PR.sit, PR.rag, PR.deathback = false, false, false, false, false, false
        applyStates()
    end)
end

----------------------------------------------------------
-- EXTRA (graficos e drone)
----------------------------------------------------------
do
    local ex = UI.exts
    local function fxToggle(name, class, props)
        return function(on)
            local e = Lighting:FindFirstChild(name)
            if on then
                if not e then e = Instance.new(class) end
                e.Name = name
                for k, v in pairs(props) do e[k] = v end
                e.Parent = Lighting
            elseif e then
                e:Destroy()
            end
        end
    end
    section(ex, "Gráficos")
    toggleRow(ex, "Brilho cinematográfico (Bloom)", fxToggle("TutuzxFX_Bloom", "BloomEffect", {Intensity = 0.6, Size = 30, Threshold = 1}))
    toggleRow(ex, "Cores vivas", fxToggle("TutuzxFX_Color", "ColorCorrectionEffect", {Saturation = 0.25, Contrast = 0.1}))
    toggleRow(ex, "Raios de sol", fxToggle("TutuzxFX_Rays", "SunRaysEffect", {Intensity = 0.15, Spread = 0.6}))
    toggleRow(ex, "Profundidade de campo", fxToggle("TutuzxFX_Dof", "DepthOfFieldEffect", {FarIntensity = 0.2, FocusDistance = 30, InFocusRadius = 40, NearIntensity = 0}))
    local neon
    toggleRow(ex, "Noite neon", function(on)
        if on then
            neon = {Lighting.ClockTime, Lighting.Ambient, Lighting.OutdoorAmbient}
            Lighting.ClockTime = 0
            Lighting.Ambient = Color3.fromRGB(110, 20, 60)
            Lighting.OutdoorAmbient = Color3.fromRGB(110, 20, 60)
            fxToggle("TutuzxFX_Neon", "BloomEffect", {Intensity = 1.1, Size = 40, Threshold = 0.8})(true)
        else
            fxToggle("TutuzxFX_Neon", "BloomEffect", {})(false)
            if neon then
                Lighting.ClockTime, Lighting.Ambient, Lighting.OutdoorAmbient = neon[1], neon[2], neon[3]
                neon = nil
            end
        end
    end)
    local perf
    toggleRow(ex, "Desempenho do gráfico", function(on)
        if on then
            perf = {Lighting.GlobalShadows}
            pcall(function() perf[2] = settings().Rendering.QualityLevel end)
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
            Lighting.GlobalShadows = false
            pcall(function() workspace.Terrain.Decoration = false end)
        elseif perf then
            Lighting.GlobalShadows = perf[1]
            pcall(function() settings().Rendering.QualityLevel = perf[2] or Enum.QualityLevel.Automatic end)
            pcall(function() workspace.Terrain.Decoration = true end)
            perf = nil
        end
    end)

    section(ex, "Drone (câmera livre)")
    local dr = {on = false, yaw = 0, pitch = 0, pos = Vector3.zero, speed = 40, ws = 16}
    local function droneStop()
        if not dr.on then return end
        dr.on = false
        local c, h = cam(), getHum()
        if c then c.CameraType = Enum.CameraType.Custom end
        if h then
            h.WalkSpeed = dr.ws
            if c then c.CameraSubject = h end
        end
    end
    local function droneStart()
        local c, h = cam(), getHum()
        if not (c and h) then return false end
        local x, y = c.CFrame:ToOrientation()
        dr.pitch, dr.yaw, dr.pos = x, y, c.CFrame.Position
        dr.ws = h.WalkSpeed
        h.WalkSpeed = 0
        c.CameraType = Enum.CameraType.Scriptable
        dr.on = true
        return true
    end
    toggleRow(ex, "Drone (joystick move, arraste a tela gira)", function(v)
        if v then
            if not droneStart() then notify("Personagem indisponível") end
        else
            droneStop()
        end
    end)
    stepper(ex, "Velocidade do drone", 40, 10, 10, 300, function(v) dr.speed = v end)
    mkRow(ex, "Subir 10", "›", function() dr.pos = dr.pos + Vector3.new(0, 10, 0) end)
    mkRow(ex, "Descer 10", "›", function() dr.pos = dr.pos - Vector3.new(0, 10, 0) end)
    bind(UIS.InputChanged, function(i, gpe)
        if not dr.on or gpe then return end
        local t = i.UserInputType
        local ok = (t == Enum.UserInputType.Touch) or (t == Enum.UserInputType.MouseMovement and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
        if ok then
            dr.yaw = dr.yaw - i.Delta.X * 0.005
            dr.pitch = math.clamp(dr.pitch - i.Delta.Y * 0.005, -1.4, 1.4)
        end
    end)
    bind(RunService.RenderStepped, function(dt)
        if not dr.on then return end
        local c, h = cam(), getHum()
        if not c then return end
        local rot = CFrame.fromOrientation(dr.pitch, dr.yaw, 0)
        local md = h and h.MoveDirection or Vector3.zero
        local lv = rot:VectorToObjectSpace(md)
        local dir = rot.LookVector * (-lv.Z) + rot.RightVector * lv.X
        dr.pos = dr.pos + dir * dr.speed * dt
        c.CFrame = CFrame.new(dr.pos) * rot
    end)
    cleanup(function()
        droneStop()
        for _, d in ipairs(Lighting:GetChildren()) do
            if d.Name:sub(1, 10) == "TutuzxFX_" then d:Destroy() end
        end
        if neon then Lighting.ClockTime, Lighting.Ambient, Lighting.OutdoorAmbient = neon[1], neon[2], neon[3] end
    end)
end

----------------------------------------------------------
-- TELEPORTE
----------------------------------------------------------
do
    local ts = UI.tps
    local FILE = "tutuzx_ruby_locais.json"
    local pid = tostring(game.PlaceId)
    local db = {}
    pcall(function()
        if isfile and readfile and isfile(FILE) then
            local d = HttpService:JSONDecode(readfile(FILE))
            if type(d) == "table" then db = d end
        end
    end)
    local function saveDb()
        if writefile then pcall(function() writefile(FILE, HttpService:JSONEncode(db)) end) end
    end
    db[pid] = db[pid] or {}
    local function names()
        local t = {}
        for _, l in ipairs(db[pid]) do t[#t + 1] = l.name end
        return t
    end
    local function tpCF(cf)
        local r = getRoot()
        if r then
            r.AssemblyLinearVelocity = Vector3.zero
            r.CFrame = cf
            return true
        end
        return false
    end
    section(ts, "Jogador")
    local dd = dropdown(ts, "Jogador", plist, function(n) setSel(n) end, "...")
    SEL.setters[#SEL.setters + 1] = dd.set
    mkRow(ts, "Teleportar até o jogador", "›", function()
        local p = selPlayer()
        if not p then notify("Selecione um jogador") return end
        notify(tpTo(p) and "Teleportado" or "Jogador sem personagem")
    end)
    section(ts, "Locais salvos (deste jogo)")
    local nameBox = inputRow(ts, "Nome do local", "Ex: Praça", nil)
    local picked
    local ld
    ld = dropdown(ts, "Locais", names, function(n) picked = n end, "...")
    mkRow(ts, "Salvar local atual", "›", function()
        local r = getRoot()
        local n = nameBox.Text
        if not r then return end
        if n == "" then n = "Local " .. (#db[pid] + 1) end
        local p = r.Position
        db[pid][#db[pid] + 1] = {name = n, x = p.X, y = p.Y, z = p.Z}
        saveDb()
        nameBox.Text = ""
        notify("Local salvo: " .. n)
    end)
    mkRow(ts, "Teleportar para o local", "›", function()
        for _, l in ipairs(db[pid]) do
            if l.name == picked then
                tpCF(CFrame.new(l.x, l.y + 3, l.z))
                notify("Teleportado: " .. l.name)
                return
            end
        end
        notify("Selecione um local")
    end)
    mkRow(ts, "Apagar local selecionado", "›", function()
        for i, l in ipairs(db[pid]) do
            if l.name == picked then
                table.remove(db[pid], i)
                saveDb()
                picked = nil
                ld.set("...")
                notify("Local apagado")
                return
            end
        end
        notify("Selecione um local")
    end)
    section(ts, "Outros")
    local cb = inputRow(ts, "Coordenadas", "x, y, z", function(txt, enter)
        local x, y, z = tostring(txt):match("(-?[%d%.]+)%s*,%s*(-?[%d%.]+)%s*,%s*(-?[%d%.]+)")
        if x and enter then
            tpCF(CFrame.new(tonumber(x), tonumber(y), tonumber(z)))
            notify("Teleportado")
        end
    end)
    mkRow(ts, "Ir para o spawn", "›", function()
        local sp = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
        if sp then tpCF(sp.CFrame + Vector3.new(0, 5, 0)) else notify("Spawn não encontrado") end
    end)
    mkRow(ts, "Copiar minha posição", "›", function()
        local r = getRoot()
        if r then
            local p = r.Position
            copy(string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z))
        end
    end)
    local clickTp = false
    toggleRow(ts, "Click TP (toque no chão para ir)", function(v) clickTp = v end)
    bind(UIS.InputBegan, function(i, gpe)
        if not clickTp or gpe then return end
        if i.UserInputType ~= Enum.UserInputType.Touch and i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local c = cam()
        if not c then return end
        local ray = c:ScreenPointToRay(i.Position.X, i.Position.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {lp.Character}
        local res = workspace:Raycast(ray.Origin, ray.Direction * 3000, params)
        if res then tpCF(CFrame.new(res.Position + Vector3.new(0, 3, 0))) end
    end)
    cleanup(function() clickTp = false end)
end

----------------------------------------------------------
-- SCRIPTS
----------------------------------------------------------
do
    local sc = UI.scrs
    section(sc, "Executar código Lua")
    local code = inputRow(sc, "Código", "cole o script aqui", nil, 96)
    mkRow(sc, "Executar", "▶", function()
        local src = code.Text
        if src == "" then notify("Cole um script primeiro") return end
        if not loadstring then notify("Executor sem loadstring") return end
        local f, err = loadstring(src)
        if not f then notify("Erro de sintaxe") warn(err) return end
        local ok, e = pcall(f)
        notify(ok and "Script executado" or "Erro ao executar")
        if not ok then warn(e) end
    end)
    mkRow(sc, "Limpar", "›", function() code.Text = "" end)
    section(sc, "Servidor")
    mkRow(sc, "Rejoin (entrar de novo)", "›", function()
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp) end)
    end)
    mkRow(sc, "Server Hop (outro servidor)", "›", function()
        if not http then notify("Executor sem request") return end
        task.spawn(function()
            local ok, res = pcall(function()
                return http({Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100", Method = "GET"})
            end)
            if not ok or not res or not res.Body then notify("Falha ao buscar servidores") return end
            local okd, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if not okd or type(data) ~= "table" or not data.data then notify("Resposta inválida") return end
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers then
                    notify("Entrando em outro servidor...")
                    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, lp) end)
                    return
                end
            end
            notify("Nenhum servidor livre")
        end)
    end)
    mkRow(sc, "Copiar PlaceId", "›", function() copy(tostring(game.PlaceId)) end)
    mkRow(sc, "Copiar JobId", "›", function() copy(tostring(game.JobId)) end)
    section(sc, "Atalhos")
    mkRow(sc, "Fly GUI  (aba MODS)", "IR", function() TX.showTab(5) end)
    mkRow(sc, "Danças e emotes  (aba DANÇA)", "IR", function() TX.showTab(6) end)
    mkRow(sc, "Músicas  (aba MUSIC)", "IR", function() TX.showTab(4) end)
    mkRow(sc, "Fly Car  (aba CAR)", "IR", function() TX.showTab(19) end)
end

----------------------------------------------------------
-- cabecalho (FREE + engrenagem), ordem do menu
----------------------------------------------------------
TX.showTab = showTab
do
    local pill = Instance.new("TextLabel", frame)
    pill.Size = UDim2.new(0, 62, 0, 24)
    pill.Position = UDim2.new(0, 190, 0, 11)
    pill.BackgroundColor3 = MID
    pill.Text = "FREE"
    pill.TextColor3 = Color3.new(1, 1, 1)
    pill.Font = Enum.Font.GothamBold
    pill.TextSize = 12
    corner(pill, 8)
    local ps3 = Instance.new("UIStroke", pill)
    ps3.Color = ACC
    ps3.Thickness = 1
    local gear = mk(frame, "⚙", MID, function() showTab(14) end)
    gear.Size = UDim2.new(0, 38, 0, 26)
    gear.Position = UDim2.new(1, -138, 0, 9)
    gear.TextSize = 16
    -- ordem da barra lateral (igual ao hub do video primeiro)
    local order = {15, 16, 17, 18, 19, 20, 21, 22, 23, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 2, 1, 14}
    for pos, idx in ipairs(order) do
        if tabBtns[idx] then tabBtns[idx].LayoutOrder = pos * 10 end
    end
end
end)()

------------------------------------------------------------
-- BUSCA GLOBAL, FAVORITOS e GESTO PARA MINIMIZAR
------------------------------------------------------------
do
    local favs, favPage, srs = UI.favs, UI.favPage, UI.srs
    local GuiService = game:GetService("GuiService")
    local FAV_FILE = "tutu_favs.json"
    local favSet = {}
    pcall(function()
        if isfile and readfile and isfile(FAV_FILE) then
            local d = HttpService:JSONDecode(readfile(FAV_FILE))
            if type(d) == "table" then
                for _, k in ipairs(d) do favSet[k] = true end
            end
        end
    end)
    local function saveFavs()
        if not writefile then return end
        local arr = {}
        for k in pairs(favSet) do arr[#arr + 1] = k end
        table.sort(arr)
        pcall(function() writefile(FAV_FILE, HttpService:JSONEncode(arr)) end)
    end
    TX.startTab = next(favSet) and 1 or 15

    local scrollIdx = {}
    for i, p in ipairs(pages) do
        local sc = p:FindFirstChildOfClass("ScrollingFrame")
        if sc then scrollIdx[sc] = i end
    end
    local function keyOf(e) return tabInfo[scrollIdx[e.parent]][1] .. "|" .. e.name end
    local function goTo(e)
        local idx = scrollIdx[e.parent]
        if not idx then return end
        showTab(idx)
        task.spawn(function()
            task.wait(0.12)
            pcall(function()
                local sc = e.parent
                local y = e.row.AbsolutePosition.Y - sc.AbsolutePosition.Y + sc.CanvasPosition.Y - 6
                sc.CanvasPosition = Vector2.new(0, math.max(y, 0))
                tween(e.row, 0.15, {BackgroundColor3 = GOOD})
                task.wait(0.6)
                tween(e.row, 0.3, {BackgroundColor3 = MID})
            end)
        end)
    end

    local refreshFavs
    local function addStar(row, e)
        local k = keyOf(e)
        local star = mk(row, favSet[k] and "★" or "☆", MID, function() end)
        star.Size = UDim2.new(0, 30, 0, 28)
        star.Position = UDim2.new(1, -118, 0.5, -14)
        star.TextSize = 16
        star.TextColor3 = Color3.fromRGB(255, 220, 80)
        star.MouseButton1Click:Connect(function()
            if favSet[k] then favSet[k] = nil else favSet[k] = true end
            star.Text = favSet[k] and "★" or "☆"
            saveFavs()
            refreshFavs()
        end)
        local pb = row:FindFirstChildOfClass("TextButton")
        local pad = pb and pb:FindFirstChildOfClass("UIPadding")
        if pad then pad.PaddingRight = UDim.new(0, 124) end
    end

    ---------------- BUSCA ----------------
    mkMsg(srs, "Busca global de funcoes")
    local sRow = rowFrame(srs, 40)
    local sBox = mkBox(sRow, "Digite o nome da funcao...")
    sBox.Size = UDim2.new(1, 0, 1, 0)
    local sInfo = mkMsg(srs, "Digite para buscar")
    local sHolder = Instance.new("Frame", srs)
    sHolder.Size = UDim2.new(1, 0, 0, 0)
    sHolder.AutomaticSize = Enum.AutomaticSize.Y
    sHolder.BackgroundTransparency = 1
    sHolder.LayoutOrder = nextOrder(srs)
    local sLay = Instance.new("UIListLayout", sHolder)
    sLay.Padding = UDim.new(0, 6)
    sLay.SortOrder = Enum.SortOrder.LayoutOrder
    local function render()
        for _, c in ipairs(sHolder:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        local q = sBox.Text:lower()
        if q:gsub("%s", "") == "" then
            sInfo.Text = "Digite para buscar  (" .. #REG.list .. " funcoes)"
            return
        end
        local n = 0
        for _, e in ipairs(REG.list) do
            local info = tabInfo[scrollIdx[e.parent]]
            if info and (e.name:lower():find(q, 1, true) or info[1]:lower():find(q, 1, true)) then
                n = n + 1
                if n > 40 then break end
                local row = mkRow(sHolder, e.name, info[2], function() goTo(e) end)
                addStar(row, e)
            end
        end
        sInfo.Text = math.min(n, 40) .. " resultado(s)  •  toque para ir  •  ☆ para favoritar"
    end
    sBox:GetPropertyChangedSignal("Text"):Connect(render)

    ---------------- FAVORITOS ----------------
    local mirror = {}
    refreshFavs = function()
        for _, c in ipairs(favs:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
        favs:SetAttribute("n", 0)
        mirror = {}
        mkMsg(favs, "Favoritos  •  use ☆ na aba BUSCA")
        local any = false
        for _, e in ipairs(REG.list) do
            if favSet[keyOf(e)] then
                any = true
                local row, lab = mkRow(favs, e.name, e.lab and e.lab.Text or "IR", function()
                    if e.click then e.click() else goTo(e) end
                end)
                if e.lab then mirror[#mirror + 1] = {lab, e.lab} end
                addStar(row, e)
            end
        end
        if not any then
            local l = mkMsg(favs, "Nenhum favorito ainda")
            l.TextColor3 = Color3.fromRGB(175, 182, 205)
        end
    end
    task.spawn(function()
        while gui.Parent do
            if favPage.Visible then
                for _, m in ipairs(mirror) do
                    pcall(function()
                        m[1].Text = m[2].Text
                        m[1].TextColor3 = m[2].TextColor3
                    end)
                end
            end
            task.wait(0.3)
        end
    end)

    ---------------- GESTO: toque duplo no titulo minimiza ----------------
    local lastTap = 0
    bind(UIS.InputBegan, function(i)
        if not TX.dbl or not frame.Visible then return end
        if i.UserInputType ~= Enum.UserInputType.Touch and i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local ins = GuiService:GetGuiInset()
        local x, y = i.Position.X, i.Position.Y + ins.Y
        local fp, fs, sc = frame.AbsolutePosition, frame.AbsoluteSize, menuScale.Scale
        if x >= fp.X and x <= fp.X + fs.X - 120 * sc and y >= fp.Y and y <= fp.Y + 46 * sc then
            if tick() - lastTap < 0.35 then
                lastTap = 0
                closeMenu()
            else
                lastTap = tick()
            end
        end
    end)

    REG.on = false
    refreshFavs()
end

------------------------------------------------------------
-- loop principal
------------------------------------------------------------
bind(RunService.Heartbeat, function()
    local h = getHum()
    if h then
        if custom.speed then h.WalkSpeed = custom.speed end
        if custom.jump then
            h.UseJumpPower = true
            h.JumpPower = custom.jump
        end
    end
    if custom.grav then workspace.Gravity = custom.grav end
    if custom.zoom then pcall(function() lp.CameraMaxZoomDistance = custom.zoom end) end
    local cam = workspace.CurrentCamera
    if custom.fov and cam then cam.FieldOfView = custom.fov end
    if custom.hour then Lighting.ClockTime = custom.hour end
    if fbOn then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end
    if fogOff then
        Lighting.FogEnd = 1e5
        Lighting.FogStart = 1e5
    end
    if shadowOff then Lighting.GlobalShadows = false end
    if spinOn then
        local r = getRoot()
        if r then r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0) end
    end
end)

showTab(TX.startTab or 3)
frame.Visible = false
local function launchMenu()
    if TX.startMin then
        bubble.Visible = true
    else
        openMenu()
    end
    pcall(function()
        if TX.notify then TX.notify("Bem-vindo, " .. lp.DisplayName) end
    end)
end
LD.ready = true
if LD.done then launchMenu() else LD.onDone = launchMenu end
