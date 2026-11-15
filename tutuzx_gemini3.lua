--========================================================
--  Tutuzx v4  |  Musicas - Perso - Mods - Danca
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

local ACC = Color3.fromRGB(255, 140, 30)
local MID = Color3.fromRGB(70, 40, 140)
local GREEN = Color3.fromRGB(30, 130, 255)
local PURPLE = Color3.fromRGB(150, 80, 255)
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
local espColor = ACC
local stopFly, clearESP, restoreLight, clearShaders

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
local FULL = UDim2.new(0.75, 0, 0.9, 0)
local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = FULL
frame.BackgroundColor3 = Color3.new(1, 1, 1)
frame.Active = true
corner(frame, 18)
local menuScale = Instance.new("UIScale", frame)
local maxc = Instance.new("UISizeConstraint", frame)
maxc.MaxSize = Vector2.new(480, 640)
maxc.MinSize = Vector2.new(260, 240)
local grad = Instance.new("UIGradient", frame)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 20, 120)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(18, 45, 130)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 60, 15))
})
grad.Rotation = 45
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.new(1, 1, 1)
stroke.Thickness = 2.5
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
    wall.ImageTransparency = 0.6
    wall.ScaleType = Enum.ScaleType.Crop
    corner(wall, 18)
end

do -- arrastar a janela pelo topo
    local dragging, startIn, startPos = false, nil, nil
    local header = Instance.new("Frame", frame)
    header.Size = UDim2.new(1, -60, 0, 50)
    header.BackgroundTransparency = 1
    header.Active = true
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startIn, startPos = i.Position, frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    bind(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startIn
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(0.6, 0, 0, 30)
title.Position = UDim2.new(0, 16, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Tutuzx"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBlack
title.TextSize = 26
title.TextXAlignment = Enum.TextXAlignment.Left
local tgrad = Instance.new("UIGradient", title)
tgrad.Color = ColorSequence.new(ACC, Color3.fromRGB(255, 220, 160))

local sub = Instance.new("TextLabel", frame)
sub.Size = UDim2.new(0.7, 0, 0, 14)
sub.Position = UDim2.new(0, 17, 0, 32)
sub.BackgroundTransparency = 1
sub.Text = "musicas  -  perso  -  mods  -  dancas"
sub.TextColor3 = Color3.fromRGB(200, 190, 230)
sub.Font = Enum.Font.Gotham
sub.TextSize = 11
sub.TextXAlignment = Enum.TextXAlignment.Left

local divider = Instance.new("Frame", frame)
divider.Size = UDim2.new(1, -32, 0, 1)
divider.Position = UDim2.new(0, 16, 0, 48)
divider.BackgroundColor3 = ACC
divider.BackgroundTransparency = 0.6
divider.BorderSizePixel = 0

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
bgrad.Color = ColorSequence.new(Color3.fromRGB(110, 50, 200), ACC)
bgrad.Rotation = 45
local bstroke = Instance.new("UIStroke", bubble)
bstroke.Color = Color3.new(1, 1, 1)
bstroke.Thickness = 3
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
    bl.Text = "Tutuzx"
    bl.TextColor3 = Color3.new(1, 1, 1)
    bl.Font = Enum.Font.GothamBlack
    bl.TextSize = 12
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
        r = (r + 120 * dt) % 360
        sg.Rotation = r
        bsg.Rotation = 360 - r
    end)
end
task.spawn(function()
    while bubble.Parent do
        if bubble.Visible then
            tween(bubble, 0.8, {Size = UDim2.new(0, 66, 0, 66)}, Enum.EasingStyle.Sine)
            task.wait(0.8)
            tween(bubble, 0.8, {Size = UDim2.new(0, 60, 0, 60)}, Enum.EasingStyle.Sine)
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
    b.AutoButtonColor = false
    corner(b, 10)
    b.MouseButton1Click:Connect(cb)
    press(b)
    return b
end

local closeBtn = mk(frame, "-", MID, closeMenu)
closeBtn.Size = UDim2.new(0, 36, 0, 32)
closeBtn.Position = UDim2.new(1, -50, 0, 8)
closeBtn.TextSize = 22

local function mkScroll(parent)
    local s = Instance.new("ScrollingFrame", parent)
    s.Size = UDim2.new(1, 0, 1, 0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 4
    s.ScrollBarImageColor3 = ACC
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
    l.TextColor3 = Color3.fromRGB(255, 240, 220)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
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
    b.PlaceholderColor3 = Color3.fromRGB(180, 160, 220)
    b.Text = ""
    b.ClearTextOnFocus = false
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    corner(b, 10)
    local st = Instance.new("UIStroke", b)
    st.Color = ACC
    st.Transparency = 0.7
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
    row.BackgroundTransparency = 0.1
    row.LayoutOrder = nextOrder(parent)
    corner(row, 10)
    local bar = Instance.new("Frame", row)
    bar.Size = UDim2.new(0, 4, 0.6, 0)
    bar.Position = UDim2.new(0, 4, 0.2, 0)
    bar.BackgroundColor3 = ACC
    bar.BorderSizePixel = 0
    corner(bar, 4)
    local pb = Instance.new("TextButton", row)
    pb.Size = UDim2.new(1, 0, 1, 0)
    pb.BackgroundTransparency = 1
    pb.Text = tostring(name)
    pb.TextColor3 = Color3.new(1, 1, 1)
    pb.Font = Enum.Font.Gotham
    pb.TextSize = 14
    pb.TextXAlignment = Enum.TextXAlignment.Left
    pb.TextTruncate = Enum.TextTruncate.AtEnd
    local pad = Instance.new("UIPadding", pb)
    pad.PaddingLeft = UDim.new(0, 16)
    pad.PaddingRight = UDim.new(0, 80)
    pb.MouseButton1Down:Connect(function() tween(row, 0.08, {BackgroundColor3 = ACC}) end)
    pb.MouseButton1Up:Connect(function() tween(row, 0.2, {BackgroundColor3 = MID}) end)
    pb.MouseLeave:Connect(function() tween(row, 0.2, {BackgroundColor3 = MID}) end)
    pb.MouseButton1Click:Connect(onClick)
    local lab = Instance.new("TextLabel", row)
    lab.Size = UDim2.new(0, 70, 1, 0)
    lab.Position = UDim2.new(1, -78, 0, 0)
    lab.BackgroundTransparency = 1
    lab.Text = tostring(rightText)
    lab.TextColor3 = ACC
    lab.Font = Enum.Font.GothamBold
    lab.TextSize = 12
    lab.TextXAlignment = Enum.TextXAlignment.Right
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
    end)
end

local function stepper(parent, name, init, step, min, max, onChange)
    local val = init
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = MID
    row.BackgroundTransparency = 0.1
    row.LayoutOrder = nextOrder(parent)
    corner(row, 10)
    local lab = Instance.new("TextLabel", row)
    lab.Size = UDim2.new(1, -100, 1, 0)
    lab.Position = UDim2.new(0, 14, 0, 0)
    lab.BackgroundTransparency = 1
    lab.TextColor3 = Color3.new(1, 1, 1)
    lab.Font = Enum.Font.Gotham
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
-- paginas e abas
------------------------------------------------------------
local function mkPage()
    local p = Instance.new("Frame", frame)
    p.Size = UDim2.new(1, 0, 1, -100)
    p.Position = UDim2.new(0, 0, 0, 96)
    p.BackgroundTransparency = 1
    p.Visible = false
    return p, mkScroll(p)
end
local musicPage, ms = mkPage()
local persoPage, ps = mkPage()
local modsPage, mo = mkPage()
local dancePage, ds = mkPage()
local chatPage, cs = mkPage()
local pages = {musicPage, persoPage, modsPage, dancePage, chatPage}

local tabBar = Instance.new("Frame", frame)
tabBar.Size = UDim2.new(1, -28, 0, 38)
tabBar.Position = UDim2.new(0, 14, 0, 54)
tabBar.BackgroundTransparency = 1
local indicator = Instance.new("Frame", tabBar)
indicator.Size = UDim2.new(1 / 5, -6, 0, 3)
indicator.Position = UDim2.new(0, 0, 0, 34)
indicator.BackgroundColor3 = ACC
indicator.BorderSizePixel = 0
corner(indicator, 4)

local tabBtns = {}
local function showTab(n)
    for i, p in ipairs(pages) do p.Visible = (i == n) end
    for i, b in ipairs(tabBtns) do
        tween(b, 0.15, {BackgroundColor3 = (i == n) and ACC or MID})
    end
    tween(indicator, 0.25, {Position = UDim2.new((n - 1) / 5, 0, 0, 34)}, Enum.EasingStyle.Back)
end
for i, nm in ipairs({"Musicas", "Perso", "Mods", "Danca", "Chat"}) do
    local b = mk(tabBar, nm, MID, function() showTab(i) end)
    b.Size = UDim2.new(1 / 5, -6, 0, 32)
    b.Position = UDim2.new((i - 1) / 5, 0, 0, 0)
    b.TextSize = 11
    tabBtns[i] = b
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

local pr = rowFrame(ms, 34)
local timeLab = Instance.new("TextLabel", pr)
timeLab.Size = UDim2.new(1, 0, 0, 16)
timeLab.BackgroundTransparency = 1
timeLab.Text = "0:00 / 0:00"
timeLab.TextColor3 = Color3.fromRGB(220, 210, 240)
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
    playQ(qIndex % #queue + 1)
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
        l.TextColor3 = Color3.fromRGB(200, 190, 230)
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
        {"Laranja", ACC},
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

    local modMsg = mkMsg(mo, "Menu")
    addModStepper("Tamanho do menu", 1, 0.1, 0.6, 1.2, function(v) menuScale.Scale = v end)
    addModStepper("Transparencia do menu", 0, 0.1, 0, 0.6, function(v) frame.BackgroundTransparency = v end)

    -- FPS e ping
    local statLab = Instance.new("TextLabel", gui)
    statLab.Size = UDim2.new(0, 190, 0, 20)
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
                statLab.Text = "FPS " .. math.floor(fpsAcc + 0.5) .. "  |  Ping " .. math.floor(ping) .. " ms"
            end
            task.wait(0.5)
        end
    end)
    toggleRow(mo, "Mostrar FPS e ping", function(s) statLab.Visible = s end)

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
    addModStepper("Hora do dia", 14, 1, 0, 24, function(v) custom.hour = v end)
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
        menuScale.Scale = 1
        frame.BackgroundTransparency = 0
        modMsg.Text = "Tudo resetado"
    end)
    mkRow(mo, "Fechar script", "SAIR", function()
        flyOn, noclip, infJump, spinOn = false, false, false, false
        espNames, espBox, espLines = false, false, false
        fbOn, fogOff, shadowOff = false, false, false
        pcall(stopFly)
        pcall(clearESP)
        pcall(clearShaders)
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
        workspace.Gravity = 196.2
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        pcall(function() sound:Destroy() end)
        gui:Destroy()
    end)
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
            l.TextColor3 = Color3.fromRGB(200, 190, 230)
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
    kinfo.TextColor3 = Color3.fromRGB(200, 190, 230)
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
        l.BackgroundColor3 = isUser and MID or Color3.fromRGB(30, 60, 120)
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

showTab(1)
frame.Size = UDim2.new(0.5, 0, 0.5, 0)
tween(frame, 0.3, {Size = FULL}, Enum.EasingStyle.Back)
