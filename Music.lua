-- COLE AQUI o link direto da imagem (png/jpg), se quiser:
local IMAGE_URL = ""
-- OU o ID da imagem no Roblox (so numeros):
local IMAGE_ID = ""

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TS = game:GetService("TweenService")

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
clean(function() return Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui") end)
pcall(function()
    local s = workspace:FindFirstChild("TutuSound")
    if s then s:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "Tutu"
gui.ResetOnSpawn = false
local okp = pcall(function()
    gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not okp or not gui.Parent then
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local errLabel = Instance.new("TextLabel", gui)
errLabel.Size = UDim2.new(0, 320, 0, 70)
errLabel.Position = UDim2.new(0.5, -160, 0, 10)
errLabel.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
errLabel.TextColor3 = Color3.new(1, 1, 1)
errLabel.TextWrapped = true
errLabel.TextSize = 12
errLabel.Visible = false

local ok, err = pcall(function()
    local ACC = Color3.fromRGB(255, 140, 30)
    local DARK = Color3.fromRGB(28, 12, 58)
    local MID = Color3.fromRGB(70, 40, 140)
    local GREEN = Color3.fromRGB(30, 130, 255)

    local http = (syn and syn.request) or http_request or request

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
    local IMG = loadImage()

    local function tween(o, t, props, style)
        pcall(function()
            TS:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
        end)
    end

    local sound = Instance.new("Sound")
    sound.Name = "TutuSound"
    sound.Looped = true
    sound.Volume = 0.5
    sound.Parent = workspace
    local lastId = nil
    local ppBtn

    local clip = setclipboard or toclipboard

    local FULL = UDim2.new(0.75, 0, 0.9, 0)
    local frame = Instance.new("Frame", gui)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.Size = FULL
    frame.BackgroundColor3 = Color3.new(1, 1, 1)
    frame.Active = true
    frame.Draggable = true
    local maxc = Instance.new("UISizeConstraint", frame)
    maxc.MaxSize = Vector2.new(480, 640)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
    local grad = Instance.new("UIGradient", frame)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 25, 140)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(20, 55, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 70, 20))
    })
    grad.Rotation = 45
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = ACC
    stroke.Thickness = 2

    if IMG then
        local wall = Instance.new("ImageLabel", frame)
        wall.Size = UDim2.new(1, 0, 1, 0)
        wall.BackgroundTransparency = 1
        wall.Image = IMG
        wall.ImageTransparency = 0.55
        wall.ScaleType = Enum.ScaleType.Crop
        Instance.new("UICorner", wall).CornerRadius = UDim.new(0, 16)
    end

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -70, 0, 40)
    title.Position = UDim2.new(0, 14, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = "Tutuzx"
    title.TextColor3 = ACC
    title.Font = Enum.Font.GothamBold
    title.TextSize = 26
    title.TextXAlignment = Enum.TextXAlignment.Left

    local body = Instance.new("Frame", frame)
    body.Size = UDim2.new(1, 0, 1, -50)
    body.Position = UDim2.new(0, 0, 0, 50)
    body.BackgroundTransparency = 1

    local bubble = Instance.new("TextButton", gui)
    bubble.AnchorPoint = Vector2.new(0.5, 0.5)
    bubble.Size = UDim2.new(0, 56, 0, 56)
    bubble.Position = UDim2.new(0, 50, 0.5, 0)
    bubble.BackgroundColor3 = ACC
    bubble.Text = IMG and "" or "Tutuzx"
    bubble.TextColor3 = Color3.new(1, 1, 1)
    bubble.Font = Enum.Font.GothamBold
    bubble.TextSize = 12
    bubble.Visible = false
    bubble.Draggable = true
    Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)
    local bstroke = Instance.new("UIStroke", bubble)
    bstroke.Color = Color3.new(1, 1, 1)
    bstroke.Thickness = 2
    if IMG then
        local bimg = Instance.new("ImageLabel", bubble)
        bimg.Size = UDim2.new(1, 0, 1, 0)
        bimg.BackgroundTransparency = 1
        bimg.Image = IMG
        bimg.ScaleType = Enum.ScaleType.Crop
        Instance.new("UICorner", bimg).CornerRadius = UDim.new(1, 0)
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
    bubble.MouseButton1Down:Connect(function()
        downPos = bubble.AbsolutePosition
    end)
    bubble.MouseButton1Click:Connect(function()
        if (bubble.AbsolutePosition - downPos).Magnitude < 8 then
            openMenu()
        end
    end)
    task.spawn(function()
        while bubble.Parent do
            if bubble.Visible then
                tween(bubble, 0.7, {Size = UDim2.new(0, 62, 0, 62)}, Enum.EasingStyle.Sine)
                task.wait(0.7)
                tween(bubble, 0.7, {Size = UDim2.new(0, 56, 0, 56)}, Enum.EasingStyle.Sine)
                task.wait(0.7)
            else
                task.wait(0.5)
            end
        end
    end)

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
        b.TextSize = 15
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(cb)
        press(b)
        return b
    end

    local closeBtn = mk(frame, "-", MID, closeMenu)
    closeBtn.Size = UDim2.new(0, 36, 0, 32)
    closeBtn.Position = UDim2.new(1, -48, 0, 10)
    closeBtn.TextSize = 22

    local now = Instance.new("TextLabel", body)
    now.Size = UDim2.new(1, -28, 0, 22)
    now.Position = UDim2.new(0, 14, 0, 0)
    now.BackgroundTransparency = 1
    now.Text = "Toque numa musica"
    now.TextColor3 = Color3.fromRGB(255, 240, 220)
    now.Font = Enum.Font.GothamBold
    now.TextSize = 14
    now.TextXAlignment = Enum.TextXAlignment.Left
    now.TextTruncate = Enum.TextTruncate.AtEnd

    local codeBox = Instance.new("TextBox", body)
    codeBox.Size = UDim2.new(1, -140, 0, 38)
    codeBox.Position = UDim2.new(0, 14, 0, 26)
    codeBox.BackgroundColor3 = MID
    codeBox.BackgroundTransparency = 0.1
    codeBox.PlaceholderText = "Codigo da musica"
    codeBox.PlaceholderColor3 = Color3.fromRGB(180, 160, 220)
    codeBox.Text = ""
    codeBox.ClearTextOnFocus = false
    codeBox.TextColor3 = ACC
    codeBox.Font = Enum.Font.GothamBold
    codeBox.TextSize = 15
    Instance.new("UICorner", codeBox)

    local box = Instance.new("TextBox", body)
    box.Size = UDim2.new(1, -140, 0, 40)
    box.Position = UDim2.new(0, 14, 0, 70)
    box.BackgroundColor3 = MID
    box.BackgroundTransparency = 0.1
    box.PlaceholderText = "Nome ou ID"
    box.PlaceholderColor3 = Color3.fromRGB(180, 160, 220)
    box.Text = ""
    box.ClearTextOnFocus = false
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 15
    Instance.new("UICorner", box)

    local list = Instance.new("ScrollingFrame", body)
    list.Size = UDim2.new(1, -28, 1, -170)
    list.Position = UDim2.new(0, 14, 0, 160)
    list.BackgroundTransparency = 1
    list.ScrollBarThickness = 5
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    local layout = Instance.new("UIListLayout", list)
    layout.Padding = UDim.new(0, 8)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)

    local function copyId(id, b)
        if not id then now.Text = "Nenhuma musica ainda" return end
        codeBox.Text = tostring(id)
        local old = b.Text
        if clip then
            pcall(clip, tostring(id))
            b.Text = "Copiado!"
        else
            b.Text = "Veja a barra"
            now.Text = "Seu Delta nao copia: segure na barra do codigo"
        end
        task.delay(1.2, function()
            if b.Parent then b.Text = old end
        end)
    end

    local function play(id, name)
        lastId = id
        sound:Stop()
        sound.SoundId = "rbxassetid://" .. tostring(id)
        sound:Play()
        codeBox.Text = tostring(id)
        if ppBtn then ppBtn.Text = "Pause" end
        now.Text = "Tocando: " .. tostring(name or id)
    end

    local function addItem(name, idText, onPlay, onCopy)
        local row = Instance.new("Frame", list)
        row.Size = UDim2.new(1, -10, 0, 46)
        row.BackgroundColor3 = MID
        row.BackgroundTransparency = 0.1
        Instance.new("UICorner", row)
        local rightW = onCopy and 170 or 70

        local pb = Instance.new("TextButton", row)
        pb.Size = UDim2.new(1, -rightW, 1, 0)
        pb.BackgroundTransparency = 1
        pb.Text = tostring(name)
        pb.TextColor3 = Color3.new(1, 1, 1)
        pb.Font = Enum.Font.Gotham
        pb.TextSize = 14
        pb.TextXAlignment = Enum.TextXAlignment.Left
        pb.TextTruncate = Enum.TextTruncate.AtEnd
        local pad = Instance.new("UIPadding", pb)
        pad.PaddingLeft = UDim.new(0, 10)
        pb.MouseButton1Down:Connect(function() tween(row, 0.08, {BackgroundColor3 = ACC}) end)
        pb.MouseButton1Up:Connect(function() tween(row, 0.2, {BackgroundColor3 = MID}) end)
        pb.MouseLeave:Connect(function() tween(row, 0.2, {BackgroundColor3 = MID}) end)
        pb.MouseButton1Click:Connect(onPlay)

        local lab = Instance.new("TextLabel", row)
        lab.Size = UDim2.new(0, rightW - (onCopy and 70 or 8), 1, 0)
        lab.Position = UDim2.new(1, -rightW, 0, 0)
        lab.BackgroundTransparency = 1
        lab.Text = tostring(idText)
        lab.TextColor3 = ACC
        lab.Font = Enum.Font.GothamBold
        lab.TextSize = 13
        lab.TextXAlignment = Enum.TextXAlignment.Right

        if onCopy then
            local cb = mk(row, "Copiar", ACC, function() end)
            cb.Size = UDim2.new(0, 60, 0, 32)
            cb.Position = UDim2.new(1, -66, 0.5, -16)
            cb.TextSize = 12
            cb.MouseButton1Click:Connect(function() onCopy(cb) end)
        end
    end

    local function clearList()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
    end

    local function get(url)
        local ok1, res = pcall(http, {Url = url, Method = "GET"})
        if ok1 and res and res.StatusCode == 200 then
            local ok2, data = pcall(function()
                return HttpService:JSONDecode(res.Body)
            end)
            if ok2 then return data end
        end
        return nil
    end

    local function search(q, autoplay)
        if not http then now.Text = "Seu Delta nao tem request" return end
        now.Text = "Buscando..."
        local data = get("https://apis.roblox.com/toolbox-service/v1/marketplace/3?limit=30&keyword=" .. HttpService:UrlEncode(q))
        if not data or not data.data or #data.data == 0 then
            now.Text = "Nada encontrado ou erro"
            return
        end
        local ids = {}
        for _, d in ipairs(data.data) do table.insert(ids, d.id) end
        local det = get("https://apis.roblox.com/toolbox-service/v1/items/details?assetIds=" .. table.concat(ids, ","))
        clearList()
        local firstId, firstName
        if det and det.data then
            for _, it in ipairs(det.data) do
                if it.asset then
                    local id, nm = it.asset.id, it.asset.name
                    if not firstId then firstId, firstName = id, nm end
                    addItem(nm, id, function() play(id, nm) end, function(b) copyId(id, b) end)
                end
            end
        else
            for _, id in ipairs(ids) do
                if not firstId then firstId, firstName = id, id end
                addItem(id, id, function() play(id) end, function(b) copyId(id, b) end)
            end
        end
        if autoplay and firstId then
            play(firstId, firstName)
        else
            now.Text = "Resultados: " .. q
        end
    end

    local brasil = {
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
    }

    local function showBrasil()
        clearList()
        now.Text = "Toque numa musica para tocar"
        for _, nm in ipairs(brasil) do
            addItem(nm, "tocar", function()
                box.Text = nm
                task.spawn(search, nm, true)
            end, nil)
        end
    end

    local copyTop = mk(body, "Copiar", ACC, function() end)
    copyTop.Size = UDim2.new(0, 108, 0, 38)
    copyTop.Position = UDim2.new(1, -122, 0, 26)
    copyTop.MouseButton1Click:Connect(function()
        local id = tonumber(codeBox.Text) or lastId
        copyId(id, copyTop)
    end)

    local bs = mk(body, "Buscar", ACC, function()
        local q = box.Text
        if tonumber(q) then
            play(tonumber(q))
        elseif q ~= "" then
            task.spawn(search, q, false)
        end
    end)
    bs.Size = UDim2.new(0, 108, 0, 40)
    bs.Position = UDim2.new(1, -122, 0, 70)

    local function row(i, txt, color, cb)
        local b = mk(body, txt, color, cb)
        b.Size = UDim2.new(0.25, -12, 0, 42)
        b.Position = UDim2.new(0.25 * i, 8, 0, 114)
        return b
    end

    row(0, "Brasil", GREEN, showBrasil)
    ppBtn = row(1, "Play", MID, function()
        if sound.IsPlaying then
            sound:Pause()
            ppBtn.Text = "Play"
        elseif sound.IsPaused then
            sound:Resume()
            ppBtn.Text = "Pause"
        elseif lastId then
            play(lastId)
        else
            now.Text = "Escolha uma musica primeiro"
        end
    end)
    row(2, "Vol -", MID, function()
        sound.Volume = math.max(0, sound.Volume - 0.1)
        now.Text = "Volume: " .. math.floor(sound.Volume * 100 + 0.5) .. "%"
    end)
    row(3, "Vol +", MID, function()
        sound.Volume = math.min(1, sound.Volume + 0.1)
        now.Text = "Volume: " .. math.floor(sound.Volume * 100 + 0.5) .. "%"
    end)

    showBrasil()
    openMenu()
end)

if not ok then
    errLabel.Text = "Erro: " .. tostring(err)
    errLabel.Visible = true
end
